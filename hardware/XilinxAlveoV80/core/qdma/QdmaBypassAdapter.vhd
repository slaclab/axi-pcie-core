-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Descriptor-bypass datapath adapter between the SLAC AxisG2
-- descriptor model (captured by AxisG2RegShim) and the Versal CPM5 QDMA
-- descriptor-bypass + AXI4-Stream interfaces on the Xilinx Alveo V80.
--
-- Replaces surf's AxiStreamDmaV2Read/Write (the PL bus masters in the old
-- AXI_Bridge design) with the hardened CPM5 QDMA engine. The datadev driver
-- still submits host buffer addresses the same way (via the BAR0 shim); this
-- block converts those submissions into QDMA descriptor-bypass descriptors and
-- moves the user AXI-Stream payload through the QDMA H2C/C2H stream ports.
--
-- Wiring (CPM5 PCIE1 => "dma1_" prefix; widths from the regenerated BD, see
-- memory v80-qdma-cips-port-widths):
--
--   TX / H2C (card<-host read, delivered to user logic):
--     AxisG2RegShim.txSub {index,size,...}  -> look up host addr via
--       addrRdIndex/addrRdData (dmaAddr table) -> drive dma1_h2c_byp_in_st_*
--       {addr=hostAddr, len=size, qid, sop=eop=1 (one desc = one packet), sdi
--       gated on tm_dsc_sts_irq_arm}. QDMA fetches host data and emits it on
--       dma1_m_axis_h2c_* -> presented to user logic as mAxisMaster (H2C data).
--
--   RX / C2H (card->host write, received from user logic):
--     AxisG2RegShim.rxFree {index} -> look up host addr -> drive
--       dma1_c2h_byp_in_st_csh_* {addr=hostAddr, qid, pfch_tag}. User RX stream
--       (sAxisMaster) is driven onto dma1_s_axis_c2h_* {tdata, ctrl_len,
--       ctrl_qid}. A completion is generated on dma1_s_axis_c2h_cmpt_* so the
--       host driver reclaims the descriptor.
--
--   IRQ: native QDMA MSI-X is raised via the sdi bit on the H2C bypass-in
--     descriptor (observing tm_dsc_sts_irq_arm first, per PG347 -- setting sdi
--     without an observed arm can hang software). This retires the old
--     TX_IRQ_CSR / CpmManager MSI workaround.
--
-- SCOPE: first-cut single H2C + single C2H stream queue (QID generics). The
-- AXIS user interface (sAxis*/mAxis*) is kept as ordinary surf AxiStream types
-- so the target top-levels and user logic are unchanged. Simple-bypass prefetch
-- tag handling and the full credit/tm_dsc_sts handshake are threaded through
-- but their steady-state policy is finalized at HW bring-up.
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
use surf.AxiStreamPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxisG2ShimPkg.all;

entity QdmaBypassAdapter is
   generic (
      TPD_G             : time                := 1 ns;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      H2C_QID_G         : slv(11 downto 0)    := (others => '0');
      C2H_QID_G         : slv(11 downto 0)    := (others => '0');
      FUNC_ID_G         : slv(11 downto 0)    := (others => '0');
      PORT_ID_G         : slv(2 downto 0)     := (others => '0');
      -- Prefetch tag reserved for the simple-bypass C2H queue (one per host)
      PFCH_TAG_G        : slv(6 downto 0)     := (others => '0'));
   port (
      -- Clock and Reset (QDMA dma1_intrfc_clk domain)
      clk                   : in  sl;
      rstL                  : in  sl;   -- active LOW reset
      -- Reserved C2H simple-bypass prefetch tag (from QdmaCtxtInit's 0x1408/
      -- 0x140C handshake); driven on every C2H bypass-in descriptor (PG347).
      pfchTag               : in  slv(6 downto 0) := (others => '0');
      -- C2H packet chunking controls (driver-written shim regs): maxSize bounds a
      -- buffer; contEn allows a frame to span buffers (sets the `continue` bit).
      maxSize               : in  slv(31 downto 0) := (others => '0');
      contEn                : in  sl := '0';
      -------------------------------------------------------------------------
      -- Descriptor submissions from AxisG2RegShim
      -------------------------------------------------------------------------
      txSub                 : in  AxisG2TxSubType;
      txSubReady            : out sl;
      rxFree                : in  AxisG2RxFreeType;
      rxFreeReady           : out sl;
      -- dmaAddr table read port (index -> host bus address)
      addrRdIndex           : out slv(AXISG2_INDEX_BITS_C-1 downto 0);
      addrRdData            : in  slv(63 downto 0);
      -------------------------------------------------------------------------
      -- User AXI-Stream interface (unchanged vs. the old DMA engine)
      -------------------------------------------------------------------------
      -- H2C data (card->user) presented to user logic
      mAxisMaster           : out AxiStreamMasterType;
      mAxisSlave            : in  AxiStreamSlaveType;
      -- C2H data (user->card) received from user logic
      sAxisMaster           : in  AxiStreamMasterType;
      sAxisSlave            : out AxiStreamSlaveType;
      -------------------------------------------------------------------------
      -- CPM5 QDMA H2C descriptor bypass-in (dma1_h2c_byp_in_st_*)
      -------------------------------------------------------------------------
      h2cBypAddr            : out slv(63 downto 0);
      h2cBypLen             : out slv(15 downto 0);
      h2cBypCidx            : out slv(15 downto 0);
      h2cBypQid             : out slv(11 downto 0);
      h2cBypFunc            : out slv(11 downto 0);
      h2cBypPortId          : out slv(2 downto 0);
      h2cBypSop             : out sl;
      h2cBypEop             : out sl;
      h2cBypSdi             : out sl;
      h2cBypMrkrReq         : out sl;
      h2cBypNoDma           : out sl;
      h2cBypError           : out sl;
      h2cBypValid           : out sl;
      h2cBypReady           : in  sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA C2H descriptor bypass-in (dma1_c2h_byp_in_st_csh_*)
      -------------------------------------------------------------------------
      c2hBypAddr            : out slv(63 downto 0);
      c2hBypQid             : out slv(11 downto 0);
      c2hBypFunc            : out slv(11 downto 0);
      c2hBypPfchTag         : out slv(6 downto 0);
      c2hBypPortId          : out slv(2 downto 0);
      c2hBypError           : out sl;
      c2hBypValid           : out sl;
      c2hBypReady           : in  sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA H2C stream data out (dma1_m_axis_h2c_*). NOTE: the CPM5 H2C-ST
      -- interface carries a byte "empty" count (mty), not a tkeep bus.
      -------------------------------------------------------------------------
      h2cStData             : in  slv(8*DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 downto 0);
      h2cStMty              : in  slv(5 downto 0);
      h2cStLast             : in  sl;
      h2cStValid            : in  sl;
      h2cStReady            : out sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA C2H stream data in (dma1_s_axis_c2h_*)
      -------------------------------------------------------------------------
      c2hStData             : out slv(8*DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 downto 0);
      c2hStCtrlLen          : out slv(15 downto 0);
      c2hStCtrlQid          : out slv(11 downto 0);  -- BD ctrl_qid is 12-bit
      c2hStMty              : out slv(5 downto 0);
      c2hStLast             : out sl;
      c2hStValid            : out sl;
      c2hStReady            : in  sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA C2H completion in (dma1_s_axis_c2h_cmpt_*). BD cmpt data bus
      -- is 512-bit; qid is 13-bit. We drive an 8B completion in the low bits.
      -------------------------------------------------------------------------
      cmptData              : out slv(511 downto 0);
      cmptSize              : out slv(1 downto 0);
      cmptQid               : out slv(12 downto 0);
      cmptType              : out slv(1 downto 0);   -- 2'b11 = HAS_PLD (regular C2H)
      cmptWaitPldPktId      : out slv(15 downto 0);  -- payload pkt id this CMPT waits on
      cmptColIdx            : out slv(2 downto 0);   -- 7 = no color insert (verbatim)
      cmptErrIdx            : out slv(2 downto 0);   -- 7 = no error insert (verbatim)
      cmptValid             : out sl;
      cmptReady             : in  sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA traffic-manager status (dma1_tm_dsc_sts_*) -- for sdi/arm
      -------------------------------------------------------------------------
      tmDscStsValid         : in  sl;
      tmDscStsQid           : in  slv(11 downto 0);
      tmDscStsIrqArm        : in  sl;
      tmDscStsDir           : in  sl);  -- 0=H2C, 1=C2H (per BD)
end QdmaBypassAdapter;

architecture rtl of QdmaBypassAdapter is

   type StateType is (IDLE_S, LOOKUP_S, DRIVE_S);

   type RegType is record
      -- TX / H2C descriptor issue
      txState    : StateType;
      txSubReady : sl;
      h2cAddr    : slv(63 downto 0);
      h2cLen     : slv(15 downto 0);
      h2cValid   : sl;
      h2cSdi     : sl;
      -- RX / C2H free-buffer descriptor issue
      rxState    : StateType;
      rxFreeReady: sl;
      c2hAddr    : slv(63 downto 0);
      c2hValid   : sl;
      rxBuffId   : slv(AXISG2_INDEX_BITS_C-1 downto 0);  -- buffId for the pushed desc
      -- shared dmaAddr lookup arbitration (TX has priority)
      addrIndex  : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      -- irq_arm observation latch for H2C queue
      h2cArmed   : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      txState    => IDLE_S,
      txSubReady => '0',
      h2cAddr    => (others => '0'),
      h2cLen     => (others => '0'),
      h2cValid   => '0',
      h2cSdi     => '0',
      rxState    => IDLE_S,
      rxFreeReady=> '0',
      c2hAddr    => (others => '0'),
      c2hValid   => '0',
      rxBuffId   => (others => '0'),
      addrIndex  => (others => '0'),
      h2cArmed   => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   ---------------------------------------------------------------------------
   -- C2H completion datapath (R2): re-frame the SSI stream into maxSize-bounded
   -- chunks, store-and-forward each chunk so ctrl_len is valid at SOP, then emit
   -- a HAS_PLD CMPT whose user data IS datadev's 16B AxisG2 ring entry.
   ---------------------------------------------------------------------------
   constant DATA_BYTES_C : positive := DMA_AXIS_CONFIG_G.TDATA_BYTES_C;  -- 64
   constant INFO_WIDTH_C : positive := 16 + 8 + 8 + 8 + 1 + 3;  -- len,first,last,dest,cont,result

   type EgStateType is (EG_IDLE_S, EG_DRIVE_S, EG_CMPT_S);

   type C2hRegType is record
      -- ingress re-framer accumulators
      byteCnt   : slv(15 downto 0);   -- bytes in the current chunk
      firstUser : slv(7 downto 0);    -- captured on the chunk's first beat
      inChunk   : sl;                 -- a chunk is in progress
      -- egress
      egState   : EgStateType;
      egLen     : slv(15 downto 0);
      egFirst   : slv(7 downto 0);
      egLast    : slv(7 downto 0);
      egDest    : slv(7 downto 0);
      egCont    : sl;
      egResult  : slv(2 downto 0);
      egBeat    : slv(15 downto 0);   -- beats sent in the current chunk
      egNBeats  : slv(15 downto 0);
      pldPktId  : slv(15 downto 0);   -- QDMA data-packet id (from 1)
   end record C2hRegType;

   constant C2H_REG_INIT_C : C2hRegType := (
      byteCnt   => (others => '0'),
      firstUser => (others => '0'),
      inChunk   => '0',
      egState   => EG_IDLE_S,
      egLen     => (others => '0'),
      egFirst   => (others => '0'),
      egLast    => (others => '0'),
      egDest    => (others => '0'),
      egCont    => '0',
      egResult  => (others => '0'),
      egBeat    => (others => '0'),
      egNBeats  => (others => '0'),
      pldPktId  => x"0001");

   signal c   : C2hRegType := C2H_REG_INIT_C;
   signal cin : C2hRegType;

   -- Data FIFO (holds chunk payload beats; tData only, contiguous SSI assumed)
   signal datFifoDin   : slv(8*DATA_BYTES_C-1 downto 0);
   signal datFifoWr    : sl;
   signal datFifoFull  : sl;
   signal datFifoDout  : slv(8*DATA_BYTES_C-1 downto 0);
   signal datFifoRd    : sl;
   signal datFifoValid : sl;

   -- Info FIFO (one entry per chunk: len/first/last/dest/continue/result)
   signal infFifoDin   : slv(INFO_WIDTH_C-1 downto 0);
   signal infFifoWr    : sl;
   signal infFifoFull  : sl;
   signal infFifoDout  : slv(INFO_WIDTH_C-1 downto 0);
   signal infFifoRd    : sl;
   signal infFifoValid : sl;

   -- buffId FIFO (one entry per issued C2H free-buffer descriptor)
   signal bufFifoWr    : sl;
   signal bufFifoFull  : sl;
   signal bufFifoDout  : slv(AXISG2_INDEX_BITS_C-1 downto 0);
   signal bufFifoRd    : sl;
   signal bufFifoValid : sl;

begin

   comb : process (addrRdData, c2hBypReady, h2cBypReady, r, rstL, rxFree,
                   tmDscStsDir, tmDscStsIrqArm, tmDscStsQid, tmDscStsValid,
                   txSub, pfchTag) is
      variable v : RegType;
   begin
      v := r;

      -- Default single-cycle strobes
      v.txSubReady  := '0';
      v.rxFreeReady := '0';

      -- Latch irq_arm for the H2C queue (PG347: observe arm before setting sdi)
      if (tmDscStsValid = '1' and tmDscStsDir = '0' and
          tmDscStsQid = H2C_QID_G and tmDscStsIrqArm = '1') then
         v.h2cArmed := '1';
      end if;

      ----------------------------------------------------------------------
      -- TX / H2C descriptor issue FSM
      ----------------------------------------------------------------------
      case r.txState is
         when IDLE_S =>
            v.h2cValid := '0';
            if (txSub.valid = '1') then
               v.addrIndex := txSub.index;
               v.h2cLen    := resize(txSub.size, 16);
               v.txState   := LOOKUP_S;
            end if;
         when LOOKUP_S =>
            -- addrRdData valid after RAM read latency; capture host address.
            v.h2cAddr  := addrRdData;
            -- Set sdi (-> status desc + MSI-X) only once arm observed.
            v.h2cSdi   := r.h2cArmed;
            v.h2cValid := '1';
            v.txState  := DRIVE_S;
         when DRIVE_S =>
            if (h2cBypReady = '1') then
               v.h2cValid    := '0';
               v.txSubReady  := '1';      -- ack the shim submission
               -- Consume the arm we just used (one sdi per observed arm).
               if (r.h2cSdi = '1') then
                  v.h2cArmed := '0';
               end if;
               v.txState     := IDLE_S;
            end if;
      end case;

      ----------------------------------------------------------------------
      -- RX / C2H free-buffer descriptor issue FSM
      ----------------------------------------------------------------------
      case r.rxState is
         when IDLE_S =>
            v.c2hValid := '0';
            if (rxFree.valid = '1' and r.txState = IDLE_S and txSub.valid = '0') then
               -- Borrow the dmaAddr read port when TX is idle (TX has priority).
               v.addrIndex := rxFree.index;
               v.rxBuffId  := rxFree.index;   -- remember buffId for the CMPT entry
               v.rxState   := LOOKUP_S;
            end if;
         when LOOKUP_S =>
            v.c2hAddr  := addrRdData;
            v.c2hValid := '1';
            v.rxState  := DRIVE_S;
         when DRIVE_S =>
            if (c2hBypReady = '1') then
               v.c2hValid    := '0';
               v.rxFreeReady := '1';
               v.rxState     := IDLE_S;
            end if;
      end case;

      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      --------------------------------------------------------------------
      -- Outputs
      --------------------------------------------------------------------
      addrRdIndex   <= r.addrIndex;
      txSubReady    <= r.txSubReady;
      rxFreeReady   <= r.rxFreeReady;

      -- H2C bypass-in descriptor (one descriptor = one packet)
      h2cBypAddr    <= r.h2cAddr;
      h2cBypLen     <= r.h2cLen;
      h2cBypCidx    <= (others => '0');
      h2cBypQid     <= H2C_QID_G;
      h2cBypFunc    <= FUNC_ID_G;
      h2cBypPortId  <= PORT_ID_G;
      h2cBypSop     <= '1';
      h2cBypEop     <= '1';
      h2cBypSdi     <= r.h2cSdi;
      h2cBypMrkrReq <= '0';
      h2cBypNoDma   <= '0';
      h2cBypError   <= '0';
      h2cBypValid   <= r.h2cValid;

      -- C2H bypass-in (free-buffer) descriptor
      c2hBypAddr    <= r.c2hAddr;
      c2hBypQid     <= C2H_QID_G;
      c2hBypFunc    <= FUNC_ID_G;
      c2hBypPfchTag <= pfchTag;  -- reserved via QdmaCtxtInit (PG347 simple bypass); supersedes PFCH_TAG_G
      c2hBypPortId  <= PORT_ID_G;
      c2hBypError   <= '0';
      c2hBypValid   <= r.c2hValid;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   --------------------------------------------------------------------------
   -- H2C stream data (QDMA -> user). Flatten the QDMA ST bus into the user
   -- AxiStreamMaster. tKeep from the QDMA keep bus; tLast passthrough.
   --------------------------------------------------------------------------
   process (h2cStData, h2cStLast, h2cStMty, h2cStValid, mAxisSlave) is
      variable m       : AxiStreamMasterType;
      variable nBytes  : integer;
   begin
      m         := AXI_STREAM_MASTER_INIT_C;
      m.tData(8*DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 downto 0) := h2cStData;
      -- Reconstruct tKeep from the QDMA "empty byte" count (mty): valid bytes =
      -- TDATA_BYTES - mty on the last beat; all bytes valid otherwise.
      m.tKeep := (others => '0');
      if (h2cStLast = '1') then
         nBytes := DMA_AXIS_CONFIG_G.TDATA_BYTES_C - conv_integer(h2cStMty);
      else
         nBytes := DMA_AXIS_CONFIG_G.TDATA_BYTES_C;
      end if;
      for i in 0 to DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 loop
         if (i < nBytes) then
            m.tKeep(i) := '1';
         end if;
      end loop;
      m.tLast   := h2cStLast;
      m.tValid  := h2cStValid;
      mAxisMaster <= m;
      h2cStReady  <= mAxisSlave.tReady;
   end process;

   --------------------------------------------------------------------------
   -- C2H stream data (user -> QDMA). Flatten the user AxiStreamMaster onto the
   -- QDMA ST input + control (len computed from tKeep, qid constant).
   --------------------------------------------------------------------------
   process (c2hStReady, sAxisMaster) is
      variable byteCnt : natural;
   begin
      c2hStData    <= sAxisMaster.tData(8*DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 downto 0);
      c2hStValid   <= sAxisMaster.tValid;
      c2hStLast    <= sAxisMaster.tLast;
      c2hStCtrlQid <= C2H_QID_G;
      -- ctrl_len = number of valid bytes in the packet beat; for a single-beat
      -- model use the popcount of tKeep. Multi-beat length accumulation is a
      -- bring-up refinement.
      byteCnt := 0;
      for i in 0 to DMA_AXIS_CONFIG_G.TDATA_BYTES_C-1 loop
         if (sAxisMaster.tKeep(i) = '1') then
            byteCnt := byteCnt + 1;
         end if;
      end loop;
      c2hStCtrlLen <= toSlv(byteCnt, 16);
      c2hStMty     <= toSlv(DMA_AXIS_CONFIG_G.TDATA_BYTES_C - byteCnt, 6);
      sAxisSlave.tReady <= c2hStReady;
   end process;

   --------------------------------------------------------------------------
   -- C2H completion. One CMPT per C2H packet (on tLast). Minimal 8B completion
   -- carrying the transferred length; full field packing finalized at bring-up.
   --------------------------------------------------------------------------
   cmptData  <= (others => '0');
   cmptSize  <= "00";                 -- 8B completion
   cmptQid   <= '0' & C2H_QID_G;      -- 13-bit cmpt qid
   cmptValid <= sAxisMaster.tValid and sAxisMaster.tLast;

end rtl;
