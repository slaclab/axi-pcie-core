#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue              as pr
import surf.axi             as axi
import surf.devices.micron  as micron
import surf.devices.nxp     as nxp
import surf.devices.silabs  as silabs
import surf.xilinx          as xil

import surf.devices.transceivers as xceiver

import axipcie
import click
import time

class AxiPcieCore(pr.Device):
    """This class maps to axi-pcie-core/shared/rtl/AxiPcieReg.vhd"""
    def __init__(self,
                 description = 'Base components of the PCIe firmware core',
                 useBpi      = False,
                 useGpu      = False,
                 useSpi      = False,
                 numDmaLanes = 1,
                 boardType   = None,
                 extended    = False,
                 sim         = False,
                 **kwargs):
        super().__init__(description=description, **kwargs)

        self.numDmaLanes = numDmaLanes
        self.startArmed  = True
        self.sim         = sim
        self.boardType   = boardType

        # AxiVersion Module
        self.add(axipcie.PcieAxiVersion(
            offset       = 0x20000,
            expand       = False,
        ))

        if useGpu:
            self.add(axipcie.AxiGpuAsyncCore(
                name     = 'AxiGpuAsyncCore',
                offset    = 0x28000,
                expand    = False,
            ))
        # DMA AXI Stream Inbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'DmaIbAxisMon',
            offset      = 0x60000,
            numberLanes = self.numDmaLanes,
            expand      = False,
        ))

        # DMA AXI Stream Outbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'DmaObAxisMon',
            offset      = 0x68000,
            numberLanes = self.numDmaLanes,
            expand      = False,
        ))

        if not (self.sim):

            # PCI PHY status
            self.add(xil.AxiPciePhy(
                offset       = 0x10000,
                expand       = False,
            ))

            # Check if using BPI PROM (Micron MT28 or Cypress S29GL)
            if (useBpi):
                self.add(micron.AxiMicronMt28ew(
                    offset       =  0x30000,
                    expand       =  False,
                    hidden       =  True,
                ))

            # Check if using SPI PROM
            if (useSpi):
                for i in range(2):
                    self.add(micron.AxiMicronN25Q(
                        name         = f'AxiMicronN25Q[{i}]',
                        offset       =  0x40000 + (i * 0x10000),
                        expand       =  False,
                        addrMode     =  True, # True = 32-bit Address Mode
                        hidden       =  True,
                    ))

            # I2C access is slow.  So using a AXI-Lite proxy to prevent holding up CPU during a BAR0 memory map transaction
            if not (extended):
                self.add(axi.AxiLiteMasterProxy(
                    name   = 'AxilBridge',
                    offset = 0x70000,
                ))

            # Check for the SLAC GEN4 PGP Card
            if (boardType == 'SlacPgpCardG4'):

                for i in range(2):
                    self.add(xceiver.Qsfp(
                        name    = f'Qsfp[{i}]',
                        offset  = i*0x1000+0x70000,
                        memBase = self.AxilBridge.proxy,
                        enabled = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                    ))

                self.add(xceiver.Sfp(
                    name        = 'Sfp',
                    offset      = 0x72000,
                    memBase     = self.AxilBridge.proxy,
                    enabled     = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                ))

                self.add(nxp.Sa56004x(
                    name        = 'BoardTemp',
                    description = 'This device monitors the board temperature and FPGA junction temperature',
                    offset      = 0x73000,
                    memBase     = self.AxilBridge.proxy,
                    enabled     = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                ))

            elif (boardType == 'XilinxKcu1500'):

                qsfpOffset = [0x74_000,0x71_000]

                for i in range(2):
                    self.add(xceiver.Qsfp(
                        name    = f'Qsfp[{i}]',
                        offset  = qsfpOffset[i],
                        memBase = self.AxilBridge.proxy,
                        enabled = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                    ))

            elif (boardType == 'XilinxAlveoU200') or (boardType == 'XilinxAlveoU250'):

                for i in range(2):
                    self.add(xceiver.Qsfp(
                        name    = f'Qsfp[{i}]',
                        offset  = i*0x1000+0x70000,
                        memBase = self.AxilBridge.proxy,
                        enabled = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                    ))

            elif (boardType == 'XilinxAlveoU55c') or (boardType == 'XilinxVariumC1100'):
                self.add(silabs.Si5394(
                    offset  = 0x70000,
                    memBase = self.AxilBridge.proxy,
                    enabled = False, # enabled=False because I2C are slow transactions and might "log jam" register transaction pipeline
                ))

    def _start(self):
        super()._start()

        # Check if not a simulation and armed for start
        if not (self.sim) and (self.startArmed):

            # Get the number of DMA lanes built in the firmware
            DMA_SIZE_G = self.AxiVersion.DMA_SIZE_G.get()

            # Check if the number of software DMA lanes does not match the hardware
            if ( self.numDmaLanes is not DMA_SIZE_G ):
                click.secho(f'WARNING: {self.path}.numDmaLanes = {self.numDmaLanes} != {self.path}.AxiVersion.DMA_SIZE_G = {DMA_SIZE_G}', bg='cyan')

            # Get the hardware type built in the firmware
            PCIE_HW_TYPE_G = self.AxiVersion.PCIE_HW_TYPE_G.getDisp()

            # Check if the software board type does not match the hardware
            if (self.boardType != PCIE_HW_TYPE_G) and (self.boardType is not None):
                errMsg = f'ERROR: {self.path}.boardType = {self.boardType} != {self.path}.AxiVersion.PCIE_HW_TYPE_G = {PCIE_HW_TYPE_G}'
                click.secho(errMsg, bg='red')
                raise ValueError(errMsg)

        # Set the flag
        self.startArmed = False

    def CardReset(self):
        # Send a local PCIe reset
        self.AxiVersion.UserRst()

        # Wait for the AXI-Lite to recover from reset
        while (self.AxiVersion.AppReset.get() != 0):
            time.sleep(0.001)
