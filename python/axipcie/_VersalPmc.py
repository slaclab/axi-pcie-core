#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
# Title      : Versal PMC / OSPI access for the Xilinx Alveo V80
#-----------------------------------------------------------------------------
# Description:
# Exposes the Versal PMC CRP/GPIO and OSPI-controller registers, plus a
# WriteFirmwareDac() helper that programs a raw image into the OSPI flash
# (MT35XU02G) through the direct-access (DAC) linear window at 0xC0000000.
#
# ADDRESS MODEL (important): on the V80 the kernel driver maps the card's BAR2
# at rogue/AXI address 0x2_0000_0000, and that BAR covers the whole Versal
# AXI space 1:1.  So a Versal physical address P is reachable at rogue address
# 0x2_0000_0000 + P.  This Device therefore MUST be instantiated at offset
# 0x2_0000_0000; its register offsets below are the raw Versal physical
# addresses and the DAC window base is 0xC0000000 (device-relative), i.e.
# absolute rogue address 0x2_C000_0000.
#
# NOTE on the data path: the DAC program issues plain 32-bit writes only (no
# write-combining).  AxiMemMap accesses are 4 bytes wide, so a page-sized block
# transaction is emitted as consecutive 32-bit AXI writes
#-----------------------------------------------------------------------------

import time

import click

import gzip

import pyrogue                     as pr
import rogue.interfaces.memory     as rim


class VersalPmc(pr.Device):
    """Versal PMC OSPI access for the Alveo V80.

    Instantiate at the BAR2 base so the raw Versal physical addresses below
    resolve correctly::

        self.add(VersalPmc(offset=0x2_0000_0000, memBase=memMap))
    """

    # ---- DAC (direct-access linear) window, device-relative ----
    DAC_BASE      = 0xC000_0000   # absolute rogue addr 0x2_C000_0000

    # ---- flash parameters (Micron MT35XU02G, JEDEC 0x2C5B1C) ----
    EXPECT_ID     = 0x1C5B2C      # raw RDID word (bytes 2C 5B 1C)
    PAGE          = 256
    SECTOR        = 0x2_0000      # 128 kB
    DEVSIZE       = 0x1000_0000   # 2 Gb = 256 MB

    # ---- flash opcodes ----
    OP_WREN       = 0x06
    OP_PP4B       = 0x12
    OP_SE4B       = 0xDC
    OP_RD4B       = 0x13
    OP_RDFSR      = 0x70

    # Default program offset: flash byte 0 == start of the Versal boot image.
    DEFAULT_START = 0x0000_0000

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        # Programming-done flag, mirroring the Micron PROM devices so
        # updatePcieFpga can drive this uniformly (see _LoadMcsFile).
        self._progDone = False

        # -----------------------------------------------------------------
        # Exposed registers (manual poking / GUI).  Offsets are the raw Versal
        # physical addresses (this Device sits at the BAR2 base - see class
        # docstring).  WriteFirmwareDac() issues raw 32-bit transactions keyed
        # off these same offsets (self.<Var>.offset) to mirror the .tcl's
        # independent mrd/mwr accesses and avoid block read-modify-write.
        # -----------------------------------------------------------------

        # ---- PMC CRP (clock & reset) ----
        self.add(pr.RemoteVariable(
            name         = 'CRP_WPROT',
            description  = 'CRP write-protect register',
            offset       = 0xF126_001C,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'CRP_OSPI_REF_CTRL',
            description  = 'OSPI reference clock control (bit24 = clock enable)',
            offset       = 0xF126_0120,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'RST_OSPI',
            description  = 'OSPI controller reset (bit0 = hold in reset)',
            offset       = 0xF126_0304,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'CRP_RST_PS',
            description  = 'CRP PS reset; writing 0x8 triggers a POR_B-equivalent '
                           'reset (reboots the device so it reloads from OSPI)',
            offset       = 0xF126_031C,
            bitSize      = 32,
            mode         = 'RW',
        ))

        # ---- PMC GPIO (flash HW reset recovery, MIO12 on bit12) ----
        self.add(pr.RemoteVariable(
            name         = 'PMC_GPIO_DATA0',
            description  = 'PMC GPIO bank-0 data (bit12 pulses the flash RESET#)',
            offset       = 0xF102_0040,
            bitSize      = 32,
            mode         = 'RW',
        ))

        # ---- OSPI controller registers ----
        self.add(pr.RemoteVariable(
            name         = 'OSPI_CONFIG',
            description  = 'OSPI Config register (bit31 = controller idle status)',
            offset       = 0xF101_0000,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_RD_INSTR',
            description  = 'Read_Instr_Config (rd_opcode[7:0], dummy[28:24])',
            offset       = 0xF101_0004,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_WR_INSTR',
            description  = 'Write_Instr_Config (wr_opcode[7:0], wel_dis[8])',
            offset       = 0xF101_0008,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_DEV_SIZE',
            description  = 'Device_Size_Cfg (num_addr_bytes[3:0], bytes_per_page[15:4])',
            offset       = 0xF101_0014,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_WR_COMPLETION',
            description  = 'Write_Completion_Ctrl (controller auto-polls WIP)',
            offset       = 0xF101_0038,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_WR_PROT',
            description  = 'WProt_Ctrl (bit1 en = flash-region write protect)',
            offset       = 0xF101_0058,
            bitSize      = 32,
            mode         = 'RW',
        ))

        # ---- STIG command control (FLASH_CMD_CTRL @ 0xF101_0090) ----
        # Split into fields so a write verifies ONLY the RW bits.  The WO
        # cmd_exec (bit0) and the RO cmd_exec_status (bit1) / reserved (6:3)
        # bits do NOT read back the written value and would otherwise trip a
        # Block verify error.  _stigRun() stages the fields then flushes the
        # whole 32-bit block (with CmdExec=1) in one write, which launches the
        # command; verify then checks only the readable RW bits.
        self.add(pr.RemoteVariable(
            name         = 'CmdOpcode',
            description  = 'Command opcode [31:24] (write of block w/ CmdExec=1 launches it)',
            offset       = 0xF101_0090,
            bitOffset    = 24,
            bitSize      = 8,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EnbReadData',
            description  = 'Read Data Enable [23]: command returns read data bytes',
            offset       = 0xF101_0090,
            bitOffset    = 23,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'NumRdDataBytes',
            description  = 'Number of read data bytes - 1 [22:20] (0=1 byte .. 7=8 bytes)',
            offset       = 0xF101_0090,
            bitOffset    = 20,
            bitSize      = 3,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EnbCmdAddr',
            description  = 'Command Address Enable [19]: command requires an address',
            offset       = 0xF101_0090,
            bitOffset    = 19,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EnbModeBit',
            description  = 'Mode Bit Enable [18]',
            offset       = 0xF101_0090,
            bitOffset    = 18,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'NumAddrBytes',
            description  = 'Number of address bytes - 1 [17:16] (00=1 .. 11=4)',
            offset       = 0xF101_0090,
            bitOffset    = 16,
            bitSize      = 2,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EnbWriteData',
            description  = 'Write Data Enable [15]: command sends write data bytes',
            offset       = 0xF101_0090,
            bitOffset    = 15,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'NumWrDataBytes',
            description  = 'Number of write data bytes - 1 [14:12] (0=1 byte .. 7=8 bytes)',
            offset       = 0xF101_0090,
            bitOffset    = 12,
            bitSize      = 3,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'NumDummyCycles',
            description  = 'Number of dummy cycles [11:7]',
            offset       = 0xF101_0090,
            bitOffset    = 7,
            bitSize      = 5,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'FlashCmdCtrlResv1',
            description  = 'Reserved [6:3]',
            offset       = 0xF101_0090,
            bitOffset    = 3,
            bitSize      = 4,
            mode         = 'RO',
            hidden       = True,
        ))

        self.add(pr.RemoteVariable(
            name         = 'StigMemBankEn',
            description  = 'STIG Memory Bank enable [2]',
            offset       = 0xF101_0090,
            bitOffset    = 2,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'CmdExecStatus',
            description  = 'Command execution in progress [1] (read-only busy flag)',
            offset       = 0xF101_0090,
            bitOffset    = 1,
            bitSize      = 1,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'CmdExec',
            description  = 'Execute the command [0] (write-only strobe)',
            offset       = 0xF101_0090,
            bitOffset    = 0,
            bitSize      = 1,
            mode         = 'WO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_CMD_ADDR',
            description  = 'STIG command address',
            offset       = 0xF101_0094,
            bitSize      = 32,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_RD_DATA_LOWER',
            description  = 'STIG read-data lower word',
            offset       = 0xF101_00A0,
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_RD_DATA_UPPER',
            description  = 'STIG read-data upper word',
            offset       = 0xF101_00A4,
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'OSPI_AXI_SEL',
            description  = 'PMC IOU SLCR OSPI_AXI_Sel (bit1: 0=DMA, 1=Linear/DAC)',
            offset       = 0xF106_0504,
            bitSize      = 32,
            mode         = 'RW',
        ))

        # ---- PROM-style programming command (matches the Micron _LoadMcsFile
        #      model so updatePcieFpga drives every PROM the same way) ----
        self.add(pr.LocalCommand(
            name        = 'LoadMcsFile',
            description = 'Program the value (path to a raw .bin/.pdi boot image) into '
                          'the OSPI flash at offset 0 via the 0xC0000000 DAC window',
            value       = '',
            function    = self._LoadMcsFile,
        ))

        self.add(pr.LocalCommand(
            name        = 'PorReset',
            description = 'POR_B-equivalent reset (write 0x8 to 0xF126031C): reboots '
                          'the Versal so it reloads firmware from OSPI',
            function    = lambda: self.porReset(),
        ))

    # =====================================================================
    # Raw 32-bit access - USED ONLY for the 0xC0000000 DAC window.
    # The DAC linear window has no RemoteVariable (it is a 256 MB flash
    # aperture), so it is driven with raw 32-bit transactions.  Every other
    # register goes through its RemoteVariable's .set()/.get() instead.
    #
    # NOTE: a self-initiated _reqTransaction does NOT apply this Device's own
    # hub offset (unlike a RemoteVariable's Block, whose address is the full
    # accumulated offset).  So the DEVICE-RELATIVE `addr` must be turned into an
    # absolute memory-map address by adding self.address (the device's
    # accumulated base, e.g. 0x2_0000_0000 for the BAR2-mapped VersalPmc).
    # =====================================================================
    def _wr32(self, addr, value):
        """Raw 32-bit write (DAC window only); addr is device-relative."""
        abs_addr = self.address + addr
        data = bytearray(int(value & 0xFFFFFFFF).to_bytes(4, 'little'))
        tid = self._reqTransaction(abs_addr, data, 4, 0, rim.Write)
        self._waitTransaction(tid)
        err = self._getError()
        if err != '':
            self._clearError()
            raise pr.MemoryError(name=self.path, address=abs_addr, msg=err, size=4)

    def _rd32(self, addr):
        """Raw 32-bit read (DAC window only); addr is device-relative."""
        abs_addr = self.address + addr
        data = bytearray(4)
        tid = self._reqTransaction(abs_addr, data, 4, 0, rim.Read)
        self._waitTransaction(tid)
        err = self._getError()
        if err != '':
            self._clearError()
            raise pr.MemoryError(name=self.path, address=abs_addr, msg=err, size=4)
        return int.from_bytes(data, 'little')

    def porReset(self):
        """Trigger a POR_B-equivalent reset by writing 0x8 to CRP 0xF126031C.

        This reboots the Versal so it re-reads the (freshly programmed) OSPI
        boot image.  The PCIe link drops as a side effect, so the write is
        POSTed (fire-and-forget) and not waited on - the device is gone before
        any response could come back."""
        rel = self.CRP_RST_PS.offset
        print('POR_B reset: writing 0x8 to CRP 0x%08X (device will reboot from OSPI)'
              % rel)
        data = bytearray((0x8).to_bytes(4, 'little'))
        self._reqTransaction(self.address + rel, data, 4, 0, rim.Post)

    # =====================================================================
    # STIG primitives (control-register path; never touch 0xC0000000)
    # =====================================================================
    def _stigRun(self, opcode, enbRead=0, numRd=0, enbAddr=0, numAddr=0):
        # Stage every writable field (write=False -> no hardware access), then
        # flush the whole FLASH_CMD_CTRL block with ONE verified write via a RW
        # field (CmdOpcode).  The flushed 32-bit word carries CmdExec=1, which
        # launches the STIG command.  Verify checks only the readable RW bits;
        # the WO cmd_exec and RO status/reserved bits are excluded from the
        # verify mask, so there are no false read-back errors.  All writable
        # fields are set explicitly so no stale bits leak from a prior command.
        self.EnbReadData.set(enbRead,  write=False)
        self.NumRdDataBytes.set(numRd, write=False)
        self.EnbCmdAddr.set(enbAddr,   write=False)
        self.EnbModeBit.set(0,         write=False)
        self.NumAddrBytes.set(numAddr, write=False)
        self.EnbWriteData.set(0,       write=False)
        self.NumWrDataBytes.set(0,     write=False)
        self.NumDummyCycles.set(0,     write=False)
        self.StigMemBankEn.set(0,      write=False)
        self.CmdExec.set(1,            write=False)   # trigger bit (WO), staged
        self.CmdOpcode.set(opcode)                    # flush block + verify RW + launch
        
        deadline = time.monotonic() + 1.0
        while time.monotonic() < deadline:
            if self.CmdExecStatus.get() == 0:         # cmd_exec_status (busy) cleared
                return
        raise RuntimeError(f'OSPI STIG command 0x{opcode:02X} timed out')

    def _rdid(self):
        self._stigRun(0x9F, enbRead=1, numRd=2)       # RDID: read 3 bytes
        return self.OSPI_RD_DATA_LOWER.get() & 0xFFFFFF

    def _wren(self):
        self._stigRun(self.OP_WREN)

    def _rdFsr(self):
        self._stigRun(self.OP_RDFSR, enbRead=1)       # read 1 byte (numRd=0)
        return self.OSPI_RD_DATA_LOWER.get() & 0xFF

    def _waitReady(self):
        for _ in range(20000):
            f = self._rdFsr()
            if (f >> 7) & 1:
                if (f >> 5) & 1:
                    print('  !!FSR erase err')
                    return False
                if (f >> 4) & 1:
                    print('  !!FSR prog err')
                    return False
                return True
        print('  !!FSR ready timeout')
        return False

    def _waitIdle(self):
        for _ in range(200000):
            if (self.OSPI_CONFIG.get() >> 31) & 1:
                return True
        return False

    # =====================================================================
    # Public API
    # =====================================================================
    def _LoadMcsFile(self, arg, iprogPrint=True):
        """Program a boot image into the OSPI flash.

        Mirrors the Micron PROM devices' _LoadMcsFile(arg, iprogPrint) interface
        (including the self._progDone flag) so updatePcieFpga can treat this the
        same as any other PROM.  Despite the name, 'arg' is a raw image (e.g. a
        Versal .pdi), programmed at flash offset 0 via the DAC window."""
        self._progDone = False
        self.writeFirmwareDac(arg, start=self.DEFAULT_START)
        self._progDone = True
        if iprogPrint:
            print('\nOSPI flash programmed. A POR reset (PorReset) or power cycle '
                  'is required to reload the FPGA from it.\n')

    def writeFirmwareDac(self, binFile, start=None, dryRun=False, verify=True):
        """Program a raw image into OSPI flash via the 0xC0000000 DAC window.

        Port of ospi_dac_page_write.tcl using 32-bit rogue transactions.

        Parameters
        ----------
        binFile : str
            Path to the raw image (e.g. a Versal .pdi) to program.
        start : int, optional
            Flash byte offset (256 B aligned).  Default 0 (boot image start).
        dryRun : bool, optional
            If True, print the erase/program plan and return without writing.
        verify : bool, optional
            If True, read every programmed page back through the DAC window and
            compare against the file.
        """
        if start is None:
            start = self.DEFAULT_START

        if (start % self.PAGE) != 0:
            raise ValueError(f'start 0x{start:X} must be 256 B page-aligned')

        opener = gzip.open if binFile.endswith('.gz') else open
        with opener(binFile, 'rb') as fh:
            blob = fh.read()
        length = len(blob)
        if length == 0:
            raise ValueError('empty image file')
        if start + length > self.DEVSIZE:
            raise ValueError(
                f'range 0x{start:X}..0x{start + length:X} exceeds 256 MB device')

        # Ensure the device is enabled so the control-register .set()/.get()
        # transactions below go through (the DAC _wr32/_rd32 are raw and would
        # work regardless, but the registers need an enabled block).
        self.enable.set(True)

        # ---------- bring-up: OSPI ref clock on, controller out of reset -------
        ref = self.CRP_OSPI_REF_CTRL.get()
        if not ((ref >> 24) & 1):
            self.CRP_OSPI_REF_CTRL.set(ref | 0x0100_0000)
        if self.RST_OSPI.get() & 1:
            self.RST_OSPI.set(0)

        # ---------- confirm the part (HW-reset recovery if stuck) -------------
        fid = self._rdid()
        if fid in (0xFFFFFF, 0):
            d = self.PMC_GPIO_DATA0.get()
            self.PMC_GPIO_DATA0.set(d & ~0x1000)
            time.sleep(0.05)
            self.PMC_GPIO_DATA0.set(d | 0x1000)
            time.sleep(0.2)
            fid = self._rdid()
        print(f'JEDEC ID = 0x{fid:06X}')
        if fid != self.EXPECT_ID:
            raise RuntimeError('OSPI flash not MT35XU02G - aborting')

        # ---------- plan ------------------------------------------------------
        end    = start + length
        sfirst = start - (start % self.SECTOR)
        slast  = (end - 1) - ((end - 1) % self.SECTOR)
        nsec   = ((slast - sfirst) // self.SECTOR) + 1
        nwords = (length + 3) // 4
        if dryRun:
            print(f'DRY RUN: would erase {nsec} x 128KB sector(s) and program '
                  f'{length} bytes at flash 0x{start:08X} (nothing written)')
            return

        # ---------- ERASE sectors (STIG SE4B) ---------------------------------
        with click.progressbar(
            length = nsec,
            label  = click.style('Erasing OSPI:   ', fg='green'),
        ) as bar:
            for s in range(sfirst, slast + 1, self.SECTOR):
                self._wren()
                self.OSPI_CMD_ADDR.set(s)
                self._stigRun(self.OP_SE4B, enbAddr=1, numAddr=3)   # SE4B: 4-byte address
                if not self._waitIdle():
                    raise RuntimeError('OSPI controller not idle before DAC enable')
                bar.update(1)

        # ---------- configure DAC write path, then enable Linear mode ---------
        axi_prev = self.OSPI_AXI_SEL.get()
        self.OSPI_WR_PROT.set(0)               # no flash-region write protect
        self.OSPI_WR_INSTR.set(self.OP_PP4B)   # PP4B, wel_dis=0 (auto-WREN)
        self.OSPI_RD_INSTR.set(self.OP_RD4B)   # READ 4B (DAC read-back)
        dz = (self.OSPI_DEV_SIZE.get() & ~0xF) | 0x3         # num_addr_bytes=4
        self.OSPI_DEV_SIZE.set(dz)
        if not self._waitIdle():
            print('WARN: controller not idle before DAC enable')
        self.OSPI_AXI_SEL.set(0x3)             # Linear mode: interconnect -> DAC

        try:
            # ---------- PROGRAM via DAC: one 32-bit word at a time ------------
            # These are the ONLY raw writes (to the 0xC0000000 window).  The
            # controller auto-WRENs + PP4B + auto-polls WIP; consecutive writes
            # self-pace via AXI back-pressure.  A final partial word is padded
            # with 0xFF (leaves erased flash unchanged).
            with click.progressbar(
                length = length,
                label  = click.style('Writing OSPI:   ', fg='green'),
            ) as bar:
                for w in range(nwords):
                    chunk = blob[w * 4:w * 4 + 4]
                    word  = int.from_bytes(chunk + b'\xFF' * (4 - len(chunk)), 'little')
                    self._wr32(self.DAC_BASE + start + w * 4, word)
                    if (w & 0xFFF) == 0xFFF:
                        bar.update(0x4000)     # 0x1000 words * 4 bytes
                bar.update(length)

            # ---------- let the last write finish, then verify via DAC reads --
            if not self._waitIdle():
                print('WARN: controller not idle before verify')

            if verify:
                with click.progressbar(
                    length = length,
                    label  = click.style('Verifying OSPI: ', fg='green'),
                ) as bar:
                    for w in range(nwords):
                        got = self._rd32(self.DAC_BASE + start + w * 4)
                        for b in range(4):
                            idx = w * 4 + b
                            if idx >= length:
                                break
                            fv = (got >> (8 * b)) & 0xFF   # DAC word is little-endian
                            if fv != blob[idx]:
                                raise RuntimeError(
                                    f'verify failed @ flash 0x{start + idx:08X}: '
                                    f'flash=0x{fv:02X} file=0x{blob[idx]:02X}')
                        if (w & 0xFFF) == 0xFFF:
                            bar.update(0x4000)
                    bar.update(length)
        finally:
            # ---------- restore AXI mux to as-found ---------------------------
            self._waitIdle()
            self.OSPI_AXI_SEL.set(axi_prev)
