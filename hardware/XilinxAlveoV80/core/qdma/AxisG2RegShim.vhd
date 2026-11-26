-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: BAR0 compatibility register shim for the Versal CPM5 QDMA
-- descriptor-bypass migration on the Xilinx Alveo V80.
--
-- Reproduces the register layout that the SLAC aes-stream (datadev) driver
-- expects on PCIe BAR0 -- the "AxisG2" register map (struct AxisG2Reg in the
-- driver's axis_gen2.h) -- so that datadev binds (1a4a:2030) and runs WITHOUT
-- modification against the new QDMA-based data path. In the previous
-- (AXI_Bridge) design this map was presented by surf's AxiStreamDmaV2Desc; here
-- the hardened CPM5 QDMA moves the data, so this shim recreates the driver-
-- facing contract and forwards the captured descriptors to QdmaBypassAdapter.
--
-- What the driver writes (see axis_gen2.c AxisG2_WriteTx / AxisG2_WriteFree,
-- 64-bit descriptor path, desc128En = 0):
--   * TX submit : host buffer bus-address -> dmaAddr[index] (0x4000 + 4*index),
--     then a control word -> readFifoA (0x0040) carrying, per WriteTx:
--        rdData[0][3]     = continue   (flags[16])
--        rdData[0][4]     = timeout    (flags[17])
--        rdData[0][15:4]  = buffer id / index
--        rdData[0][23:16] = lastUser   (flags[15:8])
--        rdData[0][31:24] = firstUser  (flags[7:0])
--        rdData[1][23:0]  = size   -> written to readFifoB? No: in the 64-bit
--           path WriteTx packs size+dest into a SECOND word that the hardware
--           reads from the same FIFO sequence. Here we expose size/dest via the
--           companion capture of rdData[1] (readFifoB, 0x0044) which WriteTx
--           writes for the 64-bit path: rdData[1][23:0]=size, [31:24]=dest.
--   * RX free  : 64-bit mode (desc128En=0) wrote the host address to the 0x4000
--     dmaAddr[index] table, then the index -> writeFifoA (0x0048)[27:0]. 128-bit
--     mode (desc128En=1, what this QDMA shim advertises) does NOT use the table:
--     it posts addr[39:8] -> writeFifoB (0x0070), then addr[7:4] in
--     writeFifoA[31:28] with the index in writeFifoA[27:0]. The shim reconstructs
--     the full address from those two words and writes it into dmaAddr[index], so
--     the adapter's index-based read port is unchanged across both modes.
--
-- The shim therefore:
--   * Presents every AxisG2Reg field as an AXI-Lite register (config regs are
--     captured/driven out; status regs are driven from parent inputs; RO ID
--     regs return constants).
--   * Stores dmaAddr[index] -> host bus address in a surf AxiDualPortRam, and
--     exposes a read port so QdmaBypassAdapter can fetch the host address for a
--     given descriptor index.
--   * Emits a valid/ready "TX submit" record on each readFifoA write and a
--     valid/ready "RX free submit" record on each writeFifoA write.
--
-- QDMA-agnostic by design: this block never names a QDMA port; the adapter does
-- the QDMA-specific descriptor formatting.  See [[v80-qdma-bypass-migration]].
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'axi-pcie-core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library axi_pcie_core;
use axi_pcie_core.AxisG2ShimPkg.all;

entity AxisG2RegShim is
   generic (
      TPD_G          : time             := 1 ns;
      -- Descriptor-format version the driver cases on, returned in 0x000[31:24].
      -- 0x05 = 128-bit-capable gen2 v5, paired with desc128En=0x000[16]=1 so datadev
      -- uses the 16B descriptor/return-descriptor format our completion entries use.
      VERSION_G      : slv(7 downto 0)  := x"05";  -- aes-stream driver cases on this (=5)
      -- AXI address width advertised at 0x034[15:8]; datadev uses it for the DMA
      -- mask (DMA_BIT_MASK(ADDR_WIDTH_G)). surf asserts this must be <= 40.
      ADDR_WIDTH_G   : slv(7 downto 0)  := x"28";  -- addrWidth readback (40)
      -- Return/completion RING address width advertised at 0x038[7:0] (surf
      -- DESC_AWIDTH slot). datadev computes its RX ring depth as
      -- addrCount = 1 << RING_AWIDTH_G and wraps reads modulo that. It MUST equal
      -- log2 of the QDMA CMPT ring size (QdmaCtxtInit RING_SZ_VAL_G) or the two
      -- rings desync after one lap. 12 => 4096 entries (SLAC-standard
      -- DESC_AWIDTH_G=12). NOTE: distinct from ADDR_WIDTH_G -- do not merge them.
      RING_AWIDTH_G  : slv(7 downto 0)  := x"0C";  -- 12 -> 4096-entry ring
      CHAN_COUNT_G   : slv(7 downto 0)  := x"01");
   port (
      -- Clock and Reset
      clk             : in  sl;
      rstL            : in  sl;         -- active LOW reset
      -------------------------------------------------------------------------
      -- AXI-Lite slave (host BAR0 face; datadev AxisG2 register map)
      -------------------------------------------------------------------------
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -------------------------------------------------------------------------
      -- Descriptor submit outputs to QdmaBypassAdapter
      -------------------------------------------------------------------------
      -- TX (readFifo) submissions
      txSub           : out AxisG2TxSubType;
      txSubReady      : in  sl := '1';
      -- RX free-buffer (writeFifo) submissions
      rxFree          : out AxisG2RxFreeType;
      rxFreeReady     : in  sl := '1';
      -- dmaAddr table read port (adapter supplies index, gets host bus address)
      addrRdIndex     : in  slv(AXISG2_INDEX_BITS_C-1 downto 0) := (others => '0');
      addrRdData      : out slv(63 downto 0);
      -------------------------------------------------------------------------
      -- Config outputs (driven from captured registers)
      -------------------------------------------------------------------------
      online          : out slv(31 downto 0);
      intEnable       : out sl;
      contEnable      : out sl;
      dropEnable      : out sl;
      maxSize         : out slv(31 downto 0);
      -- Captured C2H completion-ring base {wrBaseHi,wrBaseLo} (BAR0 0x14/0x10).
      -- Routed to QdmaCtxtInit so the CMPT context baddr tracks the driver's ring.
      wrBase          : out slv(63 downto 0);
      fifoReset       : out sl;
      acknowledge     : out sl;
      forceInt        : out sl;
      irqHoldOff      : out slv(31 downto 0);
      -------------------------------------------------------------------------
      -- Hardware interrupt request (one-cycle pulse). The QdmaBypassAdapter
      -- pulses this when a C2H completion (a finished host buffer) is delivered,
      -- so a card->host transfer raises the datadev IRQ exactly like a hardware
      -- DMA-done would -- the forceInt path alone only covers driver self-kicks.
      -------------------------------------------------------------------------
      hwIntReq        : in  sl := '0';
      -------------------------------------------------------------------------
      -- Interrupt request to the parent (-> QDMA usr_irq / MSI-X). Level-held
      -- while a request is pending and IRQs are enabled; cleared when software
      -- acknowledges via the intAckAndEnable (0x4C) register. This reproduces
      -- the AxiStreamDmaV2Desc interrupt the datadev driver depends on: the
      -- driver queues TX descriptors, writes forceInt, then runs AxisG2_Process
      -- ONLY from the interrupt handler -- without this IRQ no descriptors are
      -- ever pushed and no data moves.
      -------------------------------------------------------------------------
      interrupt       : out sl;
      -------------------------------------------------------------------------
      -- Status inputs (driven back into read-only registers by the parent)
      -------------------------------------------------------------------------
      hwWrIndex       : in  slv(31 downto 0) := (others => '0');
      hwRdIndex       : in  slv(31 downto 0) := (others => '0');
      wrReqMissed     : in  slv(31 downto 0) := (others => '0');
      -------------------------------------------------------------------------
      -- Debug observability inputs (QDMA-side status). Counted/sampled into the
      -- read-only debug registers at 0x90.. so the C2H bring-up stall can be
      -- localized from the host (BAR0 dmaCtrl(0) base = 0x0) without an ILA.
      -------------------------------------------------------------------------
      dbgCtxtDone     : in  sl := '0';   -- QdmaCtxtInit done (engines enabled)
      dbgC2hBypValid  : in  sl := '0';   -- C2H free-buffer descriptor valid (->QDMA)
      dbgC2hBypReady  : in  sl := '0';   -- C2H free-buffer descriptor ready (<-QDMA)
      dbgC2hStValid   : in  sl := '0';   -- C2H payload tvalid (user->QDMA)
      dbgC2hStReady   : in  sl := '0';   -- C2H payload tready (QDMA->user)
      dbgTmDscValid   : in  sl := '0';   -- tm_dsc_sts valid (queue status strobe)
      dbgStartupDone  : in  sl := '0';   -- CpmManager startup writes done (IRQ service armed)
      dbgCmptValid    : in  sl := '0';   -- C2H CMPT tvalid (adapter -> QDMA)
      dbgCmptReady    : in  sl := '0';   -- C2H CMPT tready (QDMA -> adapter)
      dbgStsValid     : in  sl := '0';   -- dma1_axis_c2h_status_valid
      dbgStsDrop      : in  sl := '0';   -- dma1_axis_c2h_status_drop (no descriptors)
      dbgStsCmp       : in  sl := '0';   -- dma1_axis_c2h_status_status_cmp (packet had CMPT)
      dbgReprogBase   : in  slv(31 downto 0) := (others => '0');  -- latched CMPT baddr[31:0]
      dbgCtxtState    : in  slv(31 downto 0) := (others => '0'));  -- QdmaCtxtInit FSM status
end AxisG2RegShim;

architecture rtl of AxisG2RegShim is

   -- Register byte offsets (struct AxisG2Reg, axis_gen2.h)
   constant ADDR_ENABLE_VER_C : slv(15 downto 0) := x"0000";
   constant ADDR_INT_EN_C     : slv(15 downto 0) := x"0004";
   constant ADDR_CONT_EN_C    : slv(15 downto 0) := x"0008";
   constant ADDR_DROP_EN_C    : slv(15 downto 0) := x"000C";
   constant ADDR_WR_BASE_LO_C : slv(15 downto 0) := x"0010";
   constant ADDR_WR_BASE_HI_C : slv(15 downto 0) := x"0014";
   constant ADDR_RD_BASE_LO_C : slv(15 downto 0) := x"0018";
   constant ADDR_RD_BASE_HI_C : slv(15 downto 0) := x"001C";
   constant ADDR_FIFO_RST_C   : slv(15 downto 0) := x"0020";
   constant ADDR_MAX_SIZE_C   : slv(15 downto 0) := x"0028";
   constant ADDR_ONLINE_C     : slv(15 downto 0) := x"002C";
   constant ADDR_ACK_C        : slv(15 downto 0) := x"0030";
   constant ADDR_CHAN_CNT_C   : slv(15 downto 0) := x"0034";
   constant ADDR_ADDR_WIDTH_C : slv(15 downto 0) := x"0038";
   constant ADDR_CACHE_CFG_C  : slv(15 downto 0) := x"003C";
   constant ADDR_READ_FIFOA_C : slv(15 downto 0) := x"0040";
   constant ADDR_READ_FIFOB_C : slv(15 downto 0) := x"0044";
   constant ADDR_WRITE_FIFOA_C: slv(15 downto 0) := x"0048";
   constant ADDR_INT_ACK_EN_C : slv(15 downto 0) := x"004C";
   constant ADDR_INT_REQ_CNT_C: slv(15 downto 0) := x"0050";
   constant ADDR_HW_WR_IDX_C  : slv(15 downto 0) := x"0054";
   constant ADDR_HW_RD_IDX_C  : slv(15 downto 0) := x"0058";
   constant ADDR_WR_REQ_MISS_C: slv(15 downto 0) := x"005C";
   constant ADDR_READ_FIFOC_C : slv(15 downto 0) := x"0060";
   constant ADDR_READ_FIFOD_C : slv(15 downto 0) := x"0064";
   constant ADDR_WRITE_FIFOB_C: slv(15 downto 0) := x"0070";
   constant ADDR_FORCE_INT_C  : slv(15 downto 0) := x"0080";
   constant ADDR_IRQ_HOLDOFF_C: slv(15 downto 0) := x"0084";
   constant ADDR_TIMEOUT_C    : slv(15 downto 0) := x"0088";

   -- Debug/observability read-only registers (NOT part of the datadev AxisG2
   -- map; added for QDMA bring-up). Free-running counters, cleared only by
   -- reset; read via BAR0 at these offsets (dmaCtrl(0) base = 0x0).
   constant ADDR_DBG_WRFIFOA_C : slv(15 downto 0) := x"0090";  -- driver RX-buffer posts (writeFifoA)
   constant ADDR_DBG_RXFREE_C  : slv(15 downto 0) := x"0094";  -- rxFree accepted by adapter
   constant ADDR_DBG_TXSUB_C   : slv(15 downto 0) := x"0098";  -- txSub accepted by adapter
   constant ADDR_DBG_FORCEINT_C: slv(15 downto 0) := x"009C";  -- driver forceInt writes
   constant ADDR_DBG_INTRISE_C : slv(15 downto 0) := x"00A0";  -- shim interrupt rising edges
   constant ADDR_DBG_C2HBYP_C  : slv(15 downto 0) := x"00A4";  -- C2H free-buf descs accepted by QDMA
   constant ADDR_DBG_C2HST_C   : slv(15 downto 0) := x"00A8";  -- C2H payload beats accepted by QDMA
   constant ADDR_DBG_TMDSC_C   : slv(15 downto 0) := x"00AC";  -- tm_dsc_sts strobes
   constant ADDR_DBG_STATUS_C  : slv(15 downto 0) := x"00B0";  -- live status bits (see comb)
   constant ADDR_DBG_CTXT_C    : slv(15 downto 0) := x"00B4";  -- QdmaCtxtInit FSM status word
   constant ADDR_DBG_CMPTACC_C : slv(15 downto 0) := x"00B8";  -- CMPT packets QDMA accepted (tvalid&tready)
   constant ADDR_DBG_STSVLD_C  : slv(15 downto 0) := x"00BC";  -- c2h status strobes (valid)
   constant ADDR_DBG_STSDROP_C : slv(15 downto 0) := x"00C0";  -- c2h status: packets dropped
   constant ADDR_DBG_STSCMP_C  : slv(15 downto 0) := x"00C4";  -- c2h status: packets that had a completion
   constant ADDR_DBG_BADDR_C   : slv(15 downto 0) := x"00C8";  -- latched CMPT ring baddr[31:0] (from ctxtInit)

   -- dmaAddr[] table region: 0x4000 .. 0x7FFC (4096 x 32-bit). The driver
   -- writes a 32-bit host handle per index; we assemble the 64-bit address
   -- from the single 32-bit write (the 64-bit path stores addr[39:0] directly;
   -- upper bits are 0 for the host DMA window).
   constant ADDR_DMA_BASE_C : slv(15 downto 0) := x"4000";

   type RegType is record
      intEnable   : sl;
      contEnable  : sl;
      dropEnable  : sl;
      wrBaseLo    : slv(31 downto 0);
      wrBaseHi    : slv(31 downto 0);
      rdBaseLo    : slv(31 downto 0);
      rdBaseHi    : slv(31 downto 0);
      fifoReset   : sl;
      maxSize     : slv(31 downto 0);
      online      : slv(31 downto 0);
      acknowledge : sl;
      cacheConfig : slv(31 downto 0);
      forceInt    : sl;
      irqHoldOff  : slv(31 downto 0);
      timeout     : slv(31 downto 0);
      -- interrupt engine
      intReqCount : slv(31 downto 0);    -- pending interrupt requests (0x50 RO)
      intAckCount : slv(31 downto 0);    -- handled count from 0x4C write
      intSwAckReq : sl;                  -- software ack in progress (0x4C write)
      interrupt   : sl;                  -- level IRQ output
      -- descriptor capture
      txSub       : AxisG2TxSubType;
      txSizeDest  : slv(31 downto 0);    -- latched readFifoB (size/dest) word
      rxFree      : AxisG2RxFreeType;
      -- dmaAddr write capture (64-bit: 128-bit-mode host addresses are up to 40 bits)
      addrWrEn    : sl;
      addrWrIdx   : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      addrWrData  : slv(63 downto 0);
      -- writeFifoB (0x0070) latch: 128-bit free-buffer posting delivers the host
      -- address high word (addr[39:8]) here, before the writeFifoA write that
      -- carries addr[7:4] (in [31:28]) and the buffer index (in [27:0]).
      wrFifoBHold : slv(31 downto 0);
      -- debug observability counters (free-running; cleared only by reset)
      dbgWrFifoA  : slv(31 downto 0);
      dbgRxFree   : slv(31 downto 0);
      dbgTxSub    : slv(31 downto 0);
      dbgForceInt : slv(31 downto 0);
      dbgIntRise  : slv(31 downto 0);
      dbgC2hByp   : slv(31 downto 0);
      dbgC2hSt    : slv(31 downto 0);
      dbgTmDsc    : slv(31 downto 0);
      dbgCmptAcc  : slv(31 downto 0);    -- CMPT packets QDMA accepted
      dbgStsVldCnt: slv(31 downto 0);    -- c2h status strobes
      dbgStsDropCnt:slv(31 downto 0);    -- c2h status drops
      dbgStsCmpCnt: slv(31 downto 0);    -- c2h status completions
      dbgTmPrev   : sl;
      -- AXI-Lite
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      intEnable   => '0',
      contEnable  => '0',
      dropEnable  => '0',
      wrBaseLo    => (others => '0'),
      wrBaseHi    => (others => '0'),
      rdBaseLo    => (others => '0'),
      rdBaseHi    => (others => '0'),
      fifoReset   => '0',
      maxSize     => (others => '0'),
      online      => (others => '0'),
      acknowledge => '0',
      cacheConfig => (others => '0'),
      forceInt    => '0',
      irqHoldOff  => (others => '0'),
      timeout     => (others => '0'),
      intReqCount => (others => '0'),
      intAckCount => (others => '0'),
      intSwAckReq => '0',
      interrupt   => '0',
      txSub       => AXISG2_TX_SUB_INIT_C,
      txSizeDest  => (others => '0'),
      rxFree      => AXISG2_RX_FREE_INIT_C,
      addrWrEn    => '0',
      addrWrIdx   => (others => '0'),
      addrWrData  => (others => '0'),
      wrFifoBHold => (others => '0'),
      dbgWrFifoA  => (others => '0'),
      dbgRxFree   => (others => '0'),
      dbgTxSub    => (others => '0'),
      dbgForceInt => (others => '0'),
      dbgIntRise  => (others => '0'),
      dbgC2hByp   => (others => '0'),
      dbgC2hSt    => (others => '0'),
      dbgTmDsc    => (others => '0'),
      dbgCmptAcc  => (others => '0'),
      dbgStsVldCnt=> (others => '0'),
      dbgStsDropCnt=>(others => '0'),
      dbgStsCmpCnt=> (others => '0'),
      dbgTmPrev   => '0',
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ramRdData : slv(63 downto 0);

begin

   --------------------------------------------------------------------------
   -- dmaAddr[] table: 4096 x 64-bit. Written (low 32b) by the host via the
   -- AXI-Lite region 0x4000..0x7FFC; read by the adapter via addrRdIndex.
   -- Port A: shim write (addrWrEn), Port B: adapter read (addrRdIndex).
   --------------------------------------------------------------------------
   U_DmaAddrRam : entity surf.TrueDualPortRam
      generic map (
         TPD_G        => TPD_G,
         SYNTH_MODE_G => "inferred",
         MEMORY_TYPE_G=> "block",
         READ_LATENCY_G => 2,
         COMMON_CLK_G => true,
         ADDR_WIDTH_G => AXISG2_INDEX_BITS_C,
         DATA_WIDTH_G => 64)
      port map (
         -- Port A : host handle capture (write only)
         clka              => clk,
         wea               => r.addrWrEn,
         addra             => r.addrWrIdx,
         dina              => r.addrWrData,
         -- Port B : adapter read
         clkb              => clk,
         addrb             => addrRdIndex,
         doutb             => ramRdData);

   addrRdData <= ramRdData;

   comb : process (axilReadMaster, axilWriteMaster, dbgC2hBypReady,
                   dbgC2hBypValid, dbgC2hStReady, dbgC2hStValid, dbgCtxtDone,
                   dbgCmptReady, dbgCmptValid, dbgCtxtState, dbgReprogBase,
                   dbgStartupDone, dbgStsCmp, dbgStsDrop, dbgStsValid,
                   dbgTmDscValid, hwIntReq, hwRdIndex, hwWrIndex, r, rstL,
                   rxFreeReady, txSubReady, wrReqMissed) is
      variable v         : RegType;
      variable axilEp    : AxiLiteEndpointType;
      variable wrFifoA   : sl;
      variable wrFifoB   : sl;
      variable wrWrFifoA : sl;
      variable wrDmaAddr : sl;
      variable dummy     : slv(31 downto 0);
   begin
      v := r;

      -- Clear single-cycle submit pulses once accepted.
      if (txSubReady = '1') then
         v.txSub.valid := '0';
      end if;
      if (rxFreeReady = '1') then
         v.rxFree.valid := '0';
      end if;
      v.addrWrEn    := '0';
      v.acknowledge := '0';
      v.forceInt    := '0';
      v.intSwAckReq := '0';

      wrFifoA   := '0';
      wrFifoB   := '0';
      wrWrFifoA := '0';
      wrDmaAddr := '0';
      dummy     := (others => '0');

      --------------------------------------------------------------------
      -- AXI-Lite endpoint
      --------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Read-only / identity registers
      -- 0x000 capability word -- MUST match surf AxiStreamDmaV2Desc so the datadev
      -- driver picks the 128-bit (16B) descriptor/return-descriptor format our
      -- completion entries use. [16]=DESC_128_EN=1, [24]=version (driver cases on
      -- =5). The old packing put version at [0] and left [16]=0, so the driver read
      -- Desc128En=0, used the 64B path, and misread our 16B entries (cnt=0).
      axiSlaveRegisterR(axilEp, ADDR_ENABLE_VER_C, 16, '1');        -- DESC_128_EN
      axiSlaveRegisterR(axilEp, ADDR_ENABLE_VER_C, 24, VERSION_G);  -- version = 5
      -- 0x034 mirrors surf AxiStreamDmaV2Desc: [7:0]=chan count, [15:8]=AXI
      -- address width, [23:16]=data bytes. datadev reads [15:8] as axiWidth and
      -- calls dma_set_mask(DMA_BIT_MASK(axiWidth)) -- ONLY when desc128En(0x000[16])
      -- is set, which it now is. The width MUST live at 0x034[15:8]; leaving it at
      -- 0 makes dma_set_mask(0) fail with -EINVAL and the probe aborts.
      axiSlaveRegisterR(axilEp, ADDR_CHAN_CNT_C,   0, CHAN_COUNT_G);
      axiSlaveRegisterR(axilEp, ADDR_CHAN_CNT_C,   8, ADDR_WIDTH_G);  -- 0x034[15:8] AXI addr width (driver DMA mask)
      -- 0x038[7:0] = return/completion RING address width (surf DESC_AWIDTH slot).
      -- datadev: addrCount = 1 << this. MUST be log2(QDMA CMPT ring size), NOT the
      -- 40-bit AXI width above, or the C2H return ring desyncs after one lap.
      axiSlaveRegisterR(axilEp, ADDR_ADDR_WIDTH_C, 0, RING_AWIDTH_G);
      axiSlaveRegisterR(axilEp, ADDR_INT_REQ_CNT_C,0, r.intReqCount);
      axiSlaveRegisterR(axilEp, ADDR_HW_WR_IDX_C,  0, hwWrIndex);
      axiSlaveRegisterR(axilEp, ADDR_HW_RD_IDX_C,  0, hwRdIndex);
      axiSlaveRegisterR(axilEp, ADDR_WR_REQ_MISS_C,0, wrReqMissed);

      -- Debug/observability read-only registers (QDMA bring-up; see counters)
      axiSlaveRegisterR(axilEp, ADDR_DBG_WRFIFOA_C, 0, r.dbgWrFifoA);
      axiSlaveRegisterR(axilEp, ADDR_DBG_RXFREE_C,  0, r.dbgRxFree);
      axiSlaveRegisterR(axilEp, ADDR_DBG_TXSUB_C,   0, r.dbgTxSub);
      axiSlaveRegisterR(axilEp, ADDR_DBG_FORCEINT_C,0, r.dbgForceInt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_INTRISE_C, 0, r.dbgIntRise);
      axiSlaveRegisterR(axilEp, ADDR_DBG_C2HBYP_C,  0, r.dbgC2hByp);
      axiSlaveRegisterR(axilEp, ADDR_DBG_C2HST_C,   0, r.dbgC2hSt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_TMDSC_C,   0, r.dbgTmDsc);
      -- Live status bits at ADDR_DBG_STATUS_C:
      --   [0]=interrupt level  [1]=intEnable  [2]=ctxtDone
      --   [3]=c2hBypValid [4]=c2hBypReady [5]=c2hStValid [6]=c2hStReady
      --   [7]=tmDscValid
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 0, r.interrupt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 1, r.intEnable);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 2, dbgCtxtDone);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 3, dbgC2hBypValid);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 4, dbgC2hBypReady);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 5, dbgC2hStValid);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 6, dbgC2hStReady);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 7, dbgTmDscValid);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STATUS_C, 8, dbgStartupDone);
      -- QdmaCtxtInit FSM status word (see QdmaCtxtInit dbgStatus packing):
      --   [6:0]=curOpIndex [10:8]=curState [14:12]=hangState
      --   [22:16]=hangOpIndex [23]=sawMgmtAck [31:24]=watchdogAbortCount
      axiSlaveRegisterR(axilEp, ADDR_DBG_CTXT_C, 0, dbgCtxtState);
      axiSlaveRegisterR(axilEp, ADDR_DBG_CMPTACC_C, 0, r.dbgCmptAcc);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STSVLD_C,  0, r.dbgStsVldCnt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STSDROP_C, 0, r.dbgStsDropCnt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_STSCMP_C,  0, r.dbgStsCmpCnt);
      axiSlaveRegisterR(axilEp, ADDR_DBG_BADDR_C,   0, dbgReprogBase);

      -- Interrupt acknowledge + enable (0x4C): driver writes 0x30000 +
      -- handleCount, i.e. intAckCount[15:0]=handleCount, bit16=intReqEn (ack),
      -- bit17=intEnable (matches AxiStreamDmaV2Desc's x"04C" offset 17). Capture
      -- intAckCount[15:0] and intEnable (bit 17); the write itself is the
      -- software-ack request (wrDetect -> intSwAckReq).
      axiSlaveRegister(axilEp, ADDR_INT_ACK_EN_C, 0,  v.intAckCount(15 downto 0));
      axiSlaveRegister(axilEp, ADDR_INT_ACK_EN_C, 17, v.intEnable);
      axiWrDetect(axilEp, ADDR_INT_ACK_EN_C, v.intSwAckReq);

      -- Config registers (read/write capture)
      axiSlaveRegister(axilEp, ADDR_INT_EN_C,    0, v.intEnable);
      axiSlaveRegister(axilEp, ADDR_CONT_EN_C,   0, v.contEnable);
      axiSlaveRegister(axilEp, ADDR_DROP_EN_C,   0, v.dropEnable);
      axiSlaveRegister(axilEp, ADDR_WR_BASE_LO_C,0, v.wrBaseLo);
      axiSlaveRegister(axilEp, ADDR_WR_BASE_HI_C,0, v.wrBaseHi);
      axiSlaveRegister(axilEp, ADDR_RD_BASE_LO_C,0, v.rdBaseLo);
      axiSlaveRegister(axilEp, ADDR_RD_BASE_HI_C,0, v.rdBaseHi);
      axiSlaveRegister(axilEp, ADDR_FIFO_RST_C,  0, v.fifoReset);
      axiSlaveRegister(axilEp, ADDR_MAX_SIZE_C,  0, v.maxSize);
      axiSlaveRegister(axilEp, ADDR_ONLINE_C,    0, v.online);
      axiSlaveRegister(axilEp, ADDR_CACHE_CFG_C, 0, v.cacheConfig);
      axiSlaveRegister(axilEp, ADDR_IRQ_HOLDOFF_C,0, v.irqHoldOff);
      axiSlaveRegister(axilEp, ADDR_TIMEOUT_C,   0, v.timeout);

      -- Write-trigger registers (pulse on write; data captured into dummy/regs)
      axiWrDetect(axilEp, ADDR_ACK_C,       v.acknowledge);
      axiWrDetect(axilEp, ADDR_FORCE_INT_C, v.forceInt);

      -- readFifoA (TX control word) and readFifoB (size/dest word): capture
      -- data then detect the write.
      axiSlaveRegister(axilEp, ADDR_READ_FIFOA_C, 0, dummy);
      axiWrDetect(axilEp, ADDR_READ_FIFOA_C, wrFifoA);
      axiSlaveRegister(axilEp, ADDR_READ_FIFOB_C, 0, v.txSizeDest);
      axiWrDetect(axilEp, ADDR_READ_FIFOB_C, wrFifoB);
      axiSlaveRegister(axilEp, ADDR_WRITE_FIFOA_C, 0, dummy);
      axiWrDetect(axilEp, ADDR_WRITE_FIFOA_C, wrWrFifoA);
      -- writeFifoB (0x0070): 128-bit RX free-buffer address high word (addr[39:8]).
      -- Latch-and-hold until the paired writeFifoA write. Claiming it here also
      -- avoids a DECERR on the driver's writeFifoB write (previously undecoded).
      axiSlaveRegister(axilEp, ADDR_WRITE_FIFOB_C, 0, v.wrFifoBHold);

      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      --------------------------------------------------------------------
      -- dmaAddr[] region decode (outside the endpoint: large address range).
      -- Any write with address[15:14]="01" (0x4000..0x7FFC) targets the table.
      --------------------------------------------------------------------
      -- Legacy 64-bit-mode path (desc128En=0): host writes the 32-bit buffer
      -- handle directly to dmaAddr[index]. Zero-extended to the 64-bit RAM word.
      -- Unused in 128-bit mode (the driver never writes this region then).
      if (axilWriteMaster.awvalid = '1' and axilWriteMaster.wvalid = '1' and
          axilWriteMaster.awaddr(15 downto 14) = "01") then
         v.addrWrEn   := '1';
         v.addrWrIdx  := axilWriteMaster.awaddr(AXISG2_INDEX_BITS_C+1 downto 2);
         v.addrWrData := x"00000000" & axilWriteMaster.wdata;
      end if;

      --------------------------------------------------------------------
      -- TX submit: on a readFifoA write, decode the control word (captured in
      -- dummy at the moment of write is not retained; instead re-derive from
      -- axilWriteMaster.wdata, valid during the write cycle) and combine with
      -- the previously-written readFifoB size/dest word.
      --------------------------------------------------------------------
      if (wrFifoA = '1') then
         v.txSub.valid     := '1';
         v.txSub.cont      := axilWriteMaster.wdata(3);
         v.txSub.timeout   := axilWriteMaster.wdata(4);
         v.txSub.index     := axilWriteMaster.wdata(AXISG2_INDEX_BITS_C+3 downto 4);
         v.txSub.lastUser  := axilWriteMaster.wdata(23 downto 16);
         v.txSub.firstUser := axilWriteMaster.wdata(31 downto 24);
         v.txSub.size      := r.txSizeDest(23 downto 0);
         v.txSub.dest      := r.txSizeDest(31 downto 24);
      end if;

      --------------------------------------------------------------------
      -- RX free submit: on a writeFifoA write, wdata[index-1:0] = buffer index.
      -- In 128-bit mode (desc128En=1) the free-buffer host address is NOT written
      -- to the 0x4000 table; it arrives split across writeFifoB (addr[39:8], already
      -- latched in wrFifoBHold) and writeFifoA[31:28] (addr[7:4]). Reconstruct the
      -- full address (addr[3:0]=0, 16B aligned) and store it into dmaAddr[index] so
      -- the adapter's existing table-read path finds it. This mirrors the legacy
      -- 0x4000 capture but sources the address from the FIFO words.
      --------------------------------------------------------------------
      if (wrWrFifoA = '1') then
         v.rxFree.valid := '1';
         v.rxFree.index := axilWriteMaster.wdata(AXISG2_INDEX_BITS_C-1 downto 0);
         -- Store reconstructed host address into dmaAddr[index].
         v.addrWrEn                := '1';
         v.addrWrIdx               := axilWriteMaster.wdata(AXISG2_INDEX_BITS_C-1 downto 0);
         v.addrWrData              := (others => '0');
         v.addrWrData(39 downto 8) := r.wrFifoBHold;                     -- addr[39:8]
         v.addrWrData(7 downto 4)  := axilWriteMaster.wdata(31 downto 28);  -- addr[7:4]
      end if;

      -- Keep the wrFifoB-only case from being lost: txSizeDest already captured
      -- by axiSlaveRegister above.
      if (wrFifoB = '1') then
         null;  -- data already latched into v.txSizeDest
      end if;

      --------------------------------------------------------------------
      -- Interrupt engine (reproduces AxiStreamDmaV2Desc semantics).
      -- A forceInt write (0x80) posts one interrupt request. The pending
      -- request count is readable at 0x50 (intReqCount). An intAckAndEnable
      -- write (0x4C) is the software acknowledge: it subtracts the handled
      -- count (intAckCount) from the pending count and updates intEnable.
      -- interrupt is held high while requests are pending and IRQs enabled,
      -- except during the single-cycle ack to avoid a false re-fire.
      --------------------------------------------------------------------
      if (r.intSwAckReq = '1') then
         -- Software acknowledged intAckCount requests; clear forceInt and
         -- subtract (saturating at 0).
         if (r.intAckCount >= r.intReqCount) then
            v.intReqCount := (others => '0');
         else
            v.intReqCount := r.intReqCount - r.intAckCount;
         end if;
         -- A new request on the same cycle as an ack is still counted.
         if (v.forceInt = '1' or hwIntReq = '1') then
            v.intReqCount := v.intReqCount + 1;
         end if;
      elsif (v.forceInt = '1' or hwIntReq = '1') then
         -- Software forceInt, or a hardware C2H-completion (buffer delivered),
         -- posts an interrupt request.
         v.intReqCount := r.intReqCount + 1;
      end if;

      -- Drive the level interrupt: pending requests AND enabled, but not while
      -- an ack is being processed this cycle.
      if (v.intReqCount /= 0 and v.intEnable = '1' and r.intSwAckReq = '0') then
         v.interrupt := '1';
      else
         v.interrupt := '0';
      end if;

      --------------------------------------------------------------------
      -- Debug observability counters (free-running; cleared only by reset).
      -- These localize the C2H bring-up stall from the host:
      --   dbgWrFifoA : driver posted RX buffers (writeFifoA writes)
      --   dbgRxFree  : rxFree submissions the adapter consumed
      --   dbgTxSub   : txSub submissions the adapter consumed
      --   dbgForceInt: driver forceInt writes (interrupt requests)
      --   dbgIntRise : shim interrupt (-> CpmManager/MSI-X) rising edges
      --   dbgC2hByp  : C2H free-buffer descriptors QDMA accepted (valid&ready)
      --   dbgC2hSt   : C2H payload beats QDMA accepted (tvalid&tready)
      --   dbgTmDsc   : tm_dsc_sts strobes (queue alive)
      --------------------------------------------------------------------
      if (wrWrFifoA = '1') then
         v.dbgWrFifoA := r.dbgWrFifoA + 1;
      end if;
      if (r.rxFree.valid = '1' and rxFreeReady = '1') then
         v.dbgRxFree := r.dbgRxFree + 1;
      end if;
      if (r.txSub.valid = '1' and txSubReady = '1') then
         v.dbgTxSub := r.dbgTxSub + 1;
      end if;
      if (v.forceInt = '1') then
         v.dbgForceInt := r.dbgForceInt + 1;
      end if;
      if (v.interrupt = '1' and r.interrupt = '0') then
         v.dbgIntRise := r.dbgIntRise + 1;
      end if;
      if (dbgC2hBypValid = '1' and dbgC2hBypReady = '1') then
         v.dbgC2hByp := r.dbgC2hByp + 1;
      end if;
      if (dbgC2hStValid = '1' and dbgC2hStReady = '1') then
         v.dbgC2hSt := r.dbgC2hSt + 1;
      end if;
      if (dbgCmptValid = '1' and dbgCmptReady = '1') then
         v.dbgCmptAcc := r.dbgCmptAcc + 1;
      end if;
      if (dbgStsValid = '1') then
         v.dbgStsVldCnt := r.dbgStsVldCnt + 1;
         if (dbgStsDrop = '1') then
            v.dbgStsDropCnt := r.dbgStsDropCnt + 1;
         end if;
         if (dbgStsCmp = '1') then
            v.dbgStsCmpCnt := r.dbgStsCmpCnt + 1;
         end if;
      end if;
      v.dbgTmPrev := dbgTmDscValid;
      if (dbgTmDscValid = '1' and r.dbgTmPrev = '0') then
         v.dbgTmDsc := r.dbgTmDsc + 1;
      end if;

      -- Reset
      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;
      txSub          <= r.txSub;
      rxFree         <= r.rxFree;
      online         <= r.online;
      intEnable      <= r.intEnable;
      contEnable     <= r.contEnable;
      dropEnable     <= r.dropEnable;
      maxSize        <= r.maxSize;
      wrBase         <= r.wrBaseHi & r.wrBaseLo;
      fifoReset      <= r.fifoReset;
      acknowledge    <= r.acknowledge;
      forceInt       <= r.forceInt;
      irqHoldOff     <= r.irqHoldOff;
      interrupt      <= r.interrupt;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
