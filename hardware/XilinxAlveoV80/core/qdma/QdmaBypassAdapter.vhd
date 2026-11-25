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
-- C2H completion model (design R3, docs/plans/v80-qdma-c2h/):
--   The CPM5 C2H-ST interface requires ctrl_len (packet byte length) on the
--   FIRST beat, and QDMA emits one CMPT per data packet, whereas datadev
--   reclaims one host buffer per ring entry. To square this WITHOUT assuming
--   the frame length and WITHOUT buffering a whole frame, we:
--     * treat one driver-posted host buffer (maxSize bytes) as N = maxSize/4KiB
--       contiguous 4 KiB "fake" bypass descriptors (addr = base + i*4KiB),
--     * re-frame the user stream into 4 KiB chunks via a BOUNDED one-chunk
--       look-ahead FIFO (so the exact chunk length and the frame-end flag are
--       known at each chunk's SOP -- no padding, ctrl_len exact),
--     * drive ctrl_has_cmpt = 0 on every chunk EXCEPT the one that closes a
--       real buffer (buffer full OR user tLast). On that closing chunk we emit
--       ONE CMPT whose user data IS datadev's 16 B AxisG2 ring entry
--       {valid, buffId, real byte count in this buffer, continue}.
--   PG347 simple bypass explicitly supports user-supplied descriptors with no
--   credit bookkeeping, and ctrl_has_cmpt=0 still DMAs + consumes a descriptor.
--
--   H2C (card<-host): AxisG2RegShim.txSub -> dmaAddr lookup -> h2c_byp_in_st_*
--   descriptor; QDMA emits data on dma1_m_axis_h2c_* -> mAxisMaster.
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
      -- C2H chunk / QDMA C2H buffer size (bytes). MUST equal the value
      -- QdmaCtxtInit programs into QDMA_C2H_BUF_SZ (0xAB0). Default 4 KiB.
      CHUNK_BYTES_G     : positive            := 4096;
      PFCH_TAG_G        : slv(6 downto 0)     := (others => '0'));
   port (
      -- Clock and Reset (QDMA dma1_intrfc_clk domain)
      clk                   : in  sl;
      rstL                  : in  sl;   -- active LOW reset
      -- Reserved C2H simple-bypass prefetch tag (from QdmaCtxtInit's 0x1408/
      -- 0x140C handshake); driven on every C2H bypass-in descriptor (PG347).
      pfchTag               : in  slv(6 downto 0) := (others => '0');
      -- C2H host-buffer size (driver's AxisG2 maxSize reg, BAR0 0x28). A chunk
      -- fills one 4 KiB fake descriptor; maxSize/CHUNK_BYTES_G = chunks/buffer.
      -- Assumed a multiple of CHUNK_BYTES_G (a 4 KiB multiple), >= CHUNK_BYTES_G.
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
      c2hStCtrlHasCmpt      : out sl;                 -- per-chunk: 1 only on a buffer-closing chunk
      c2hStMty              : out slv(5 downto 0);
      c2hStLast             : out sl;
      c2hStValid            : out sl;
      c2hStReady            : in  sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA C2H completion in (dma1_s_axis_c2h_cmpt_*). BD cmpt data bus
      -- is 512-bit; qid is 13-bit. We drive a 16B datadev entry in the low bits.
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
      -- One-cycle pulse when a completion (a finished host buffer) is accepted by
      -- QDMA. Feeds the AxisG2RegShim interrupt engine so datadev gets an IRQ.
      cmptDone              : out sl;
      -------------------------------------------------------------------------
      -- CPM5 QDMA traffic-manager status (dma1_tm_dsc_sts_*) -- for sdi/arm
      -------------------------------------------------------------------------
      tmDscStsValid         : in  sl;
      tmDscStsQid           : in  slv(11 downto 0);
      tmDscStsIrqArm        : in  sl;
      tmDscStsDir           : in  sl);  -- 0=H2C, 1=C2H (per BD)
end QdmaBypassAdapter;

architecture rtl of QdmaBypassAdapter is

   constant DATA_BYTES_C : positive := DMA_AXIS_CONFIG_G.TDATA_BYTES_C;   -- 64
   constant DAT_W_C      : positive := 8*DATA_BYTES_C;                    -- 512
   constant CHUNK_BEATS_C: positive := CHUNK_BYTES_G / DATA_BYTES_C;      -- 64

   -- dmaAddr table read latency (AxisG2RegShim's AxiDualPortRam READ_LATENCY_G=2),
   -- plus a margin cycle. A LOOKUP state holds the index on the shared read port
   -- for this many cycles before capturing the host base, or it latches stale data.
   constant ADDR_RD_LAT_C : slv(2 downto 0) := "011";  -- 3 cycles

   -- Data FIFO beat: {chunkLast(1), mty(6), data(DAT_W)}
   constant DFIFO_W_C : positive := DAT_W_C + 6 + 1;
   -- Info FIFO entry (one per chunk): {frameEnd(1), byteCount(16), firstUser(8), lastUser(8)}
   constant IFIFO_W_C : positive := 1 + 16 + 8 + 8;  -- 33

   type H2cStateType is (H2C_IDLE_S, H2C_LOOKUP_S, H2C_DRIVE_S);
   type C2hStateType is (C2H_IDLE_S, C2H_GETBUF_S, C2H_LOOKUP_S,
                         C2H_DESC_S, C2H_DATA_S, C2H_CMPT_S);

   type RegType is record
      -- H2C / TX descriptor issue
      h2cState   : H2cStateType;
      txSubReady : sl;
      txAddrIdx  : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      h2cAddr    : slv(63 downto 0);
      h2cLen     : slv(15 downto 0);
      h2cValid   : sl;
      h2cSdi     : sl;
      h2cArmed   : sl;
      lkCnt      : slv(2 downto 0);     -- dmaAddr read-latency wait (shared; one LOOKUP active)
      -- C2H ingress chunk framer
      inBeat     : slv(6 downto 0);     -- beat index within the current in-chunk
      inBytes    : slv(15 downto 0);    -- accumulated bytes in the current in-chunk
      inFirst    : slv(7 downto 0);     -- firstUser captured for the current chunk
      inFirstVld : sl;
      -- C2H egress
      c2hState   : C2hStateType;
      rxFreeReady: sl;
      c2hAddrIdx : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      haveBuf    : sl;
      curBase    : slv(63 downto 0);
      curBuffId  : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      chunkIdx   : slv(19 downto 0);    -- which 4 KiB chunk within the buffer
      nChunksM1  : slv(19 downto 0);    -- (maxSize/CHUNK) - 1, latched per buffer
      bufBytes   : slv(31 downto 0);    -- real bytes accumulated in current buffer
      bufFirst   : slv(7 downto 0);     -- firstUser of the buffer's first chunk
      egClosing  : sl;                  -- current chunk closes the buffer
      egFrameEnd : sl;                  -- current chunk carries the frame tLast
      egByteCnt  : slv(15 downto 0);    -- current chunk byte count (= ctrl_len)
      egLast     : slv(7 downto 0);     -- lastUser of the closing chunk
      pldPktId   : slv(15 downto 0);    -- QDMA data-packet id (from 1), per chunk
      cmptWaitId : slv(15 downto 0);    -- pld_pkt_id the CMPT waits on
      cmptDone   : sl;                  -- registered 1-cycle IRQ pulse (buffer delivered)
   end record RegType;

   constant REG_INIT_C : RegType := (
      h2cState   => H2C_IDLE_S,
      txSubReady => '0',
      txAddrIdx  => (others => '0'),
      h2cAddr    => (others => '0'),
      h2cLen     => (others => '0'),
      h2cValid   => '0',
      h2cSdi     => '0',
      h2cArmed   => '0',
      lkCnt      => (others => '0'),
      inBeat     => (others => '0'),
      inBytes    => (others => '0'),
      inFirst    => (others => '0'),
      inFirstVld => '0',
      c2hState   => C2H_IDLE_S,
      rxFreeReady=> '0',
      c2hAddrIdx => (others => '0'),
      haveBuf    => '0',
      curBase    => (others => '0'),
      curBuffId  => (others => '0'),
      chunkIdx   => (others => '0'),
      nChunksM1  => (others => '0'),
      bufBytes   => (others => '0'),
      bufFirst   => (others => '0'),
      egClosing  => '0',
      egFrameEnd => '0',
      egByteCnt  => (others => '0'),
      egLast     => (others => '0'),
      pldPktId   => x"0001",
      cmptWaitId => (others => '0'),
      cmptDone   => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal rstHigh : sl;

   -- Data FIFO (bounded chunk look-ahead)
   signal dFifoDin   : slv(DFIFO_W_C-1 downto 0);
   signal dFifoWr    : sl;
   signal dFifoAFull : sl;
   signal dFifoDout  : slv(DFIFO_W_C-1 downto 0);
   signal dFifoRd    : sl;
   signal dFifoValid : sl;

   -- Info FIFO (one entry per chunk)
   signal iFifoDin   : slv(IFIFO_W_C-1 downto 0);
   signal iFifoWr    : sl;
   signal iFifoAFull : sl;
   signal iFifoDout  : slv(IFIFO_W_C-1 downto 0);
   signal iFifoRd    : sl;
   signal iFifoValid : sl;

   -- Decoded data-FIFO head
   signal headData : slv(DAT_W_C-1 downto 0);
   signal headMty  : slv(5 downto 0);
   signal headLast : sl;
   -- Decoded info-FIFO head
   signal infFrameEnd : sl;
   signal infByteCnt  : slv(15 downto 0);
   signal infFirst    : slv(7 downto 0);
   signal infLast     : slv(7 downto 0);

begin

   rstHigh <= not rstL;

   headData <= dFifoDout(DAT_W_C-1 downto 0);
   headMty  <= dFifoDout(DAT_W_C+5 downto DAT_W_C);
   headLast <= dFifoDout(DAT_W_C+6);

   infLast     <= iFifoDout(7 downto 0);
   infFirst    <= iFifoDout(15 downto 8);
   infByteCnt  <= iFifoDout(31 downto 16);
   infFrameEnd <= iFifoDout(32);

   U_DatFifo : entity surf.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         FWFT_EN_G       => true,
         MEMORY_TYPE_G   => "block",
         DATA_WIDTH_G    => DFIFO_W_C,
         ADDR_WIDTH_G    => 8,            -- 256 beats (>= 2 chunks)
         FULL_THRES_G    => 192)          -- almost_full margin
      port map (
         rst         => rstHigh,
         wr_clk      => clk,
         wr_en       => dFifoWr,
         din         => dFifoDin,
         almost_full => dFifoAFull,
         rd_clk      => clk,
         rd_en       => dFifoRd,
         dout        => dFifoDout,
         valid       => dFifoValid);

   U_InfFifo : entity surf.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         FWFT_EN_G       => true,
         MEMORY_TYPE_G   => "distributed",
         DATA_WIDTH_G    => IFIFO_W_C,
         ADDR_WIDTH_G    => 5,            -- 32 chunks in flight
         FULL_THRES_G    => 24)
      port map (
         rst         => rstHigh,
         wr_clk      => clk,
         wr_en       => iFifoWr,
         din         => iFifoDin,
         almost_full => iFifoAFull,
         rd_clk      => clk,
         rd_en       => iFifoRd,
         dout        => iFifoDout,
         valid       => iFifoValid);

   comb : process (addrRdData, c2hBypReady, c2hStReady, cmptReady, dFifoAFull,
                   dFifoValid, h2cBypReady, headData, headLast, headMty,
                   iFifoAFull, iFifoValid, infByteCnt, infFirst, infFrameEnd,
                   infLast, maxSize, pfchTag, r, rstL, rxFree, sAxisMaster,
                   tmDscStsDir, tmDscStsIrqArm, tmDscStsQid, tmDscStsValid,
                   txSub) is
      variable v        : RegType;
      variable popCnt   : natural;
      variable thisByte : slv(15 downto 0);
      variable chunkEnd : sl;
      variable mtyBeat  : slv(5 downto 0);
      variable ingReady : sl;
      variable ingAcc   : sl;
      variable byteNew  : slv(15 downto 0);
      variable entry    : slv(511 downto 0);
      variable offset64 : slv(63 downto 0);
      variable closing  : sl;
   begin
      v := r;

      -- Default single-cycle strobes
      v.txSubReady  := '0';
      v.rxFreeReady := '0';
      v.cmptDone    := '0';

      ----------------------------------------------------------------------
      -- Latch tm_dsc_sts irq_arm for the H2C queue (PG347: observe arm before
      -- setting sdi on the H2C bypass-in descriptor).
      ----------------------------------------------------------------------
      if (tmDscStsValid = '1' and tmDscStsDir = '0' and
          tmDscStsQid = H2C_QID_G and tmDscStsIrqArm = '1') then
         v.h2cArmed := '1';
      end if;

      ----------------------------------------------------------------------
      -- H2C / TX descriptor issue FSM (one descriptor = one packet)
      ----------------------------------------------------------------------
      case r.h2cState is
         when H2C_IDLE_S =>
            v.h2cValid := '0';
            if (txSub.valid = '1') then
               v.txAddrIdx := txSub.index;
               v.h2cLen    := resize(txSub.size, 16);
               v.lkCnt     := (others => '0');
               v.h2cState  := H2C_LOOKUP_S;
            end if;
         when H2C_LOOKUP_S =>
            -- Hold txAddrIdx on the read port until the dmaAddr table responds.
            if (r.lkCnt = ADDR_RD_LAT_C) then
               v.h2cAddr  := addrRdData;
               v.h2cSdi   := r.h2cArmed;
               v.h2cValid := '1';
               v.h2cState := H2C_DRIVE_S;
            else
               v.lkCnt := r.lkCnt + 1;
            end if;
         when H2C_DRIVE_S =>
            if (h2cBypReady = '1') then
               v.h2cValid   := '0';
               v.txSubReady := '1';
               if (r.h2cSdi = '1') then
                  v.h2cArmed := '0';
               end if;
               v.h2cState := H2C_IDLE_S;
            end if;
      end case;

      ----------------------------------------------------------------------
      -- C2H ingress: re-frame the user stream into CHUNK_BYTES_G chunks and
      -- push beats to the data FIFO + one metadata entry per chunk to the info
      -- FIFO. A chunk ends on a CHUNK boundary OR the user's tLast (frame end).
      ----------------------------------------------------------------------
      popCnt := 0;
      for i in 0 to DATA_BYTES_C-1 loop
         if (sAxisMaster.tKeep(i) = '1') then
            popCnt := popCnt + 1;
         end if;
      end loop;
      if (sAxisMaster.tLast = '1') then
         thisByte := toSlv(popCnt, 16);
         mtyBeat   := toSlv(DATA_BYTES_C - popCnt, 6);
      else
         thisByte := toSlv(DATA_BYTES_C, 16);
         mtyBeat   := (others => '0');
      end if;

      -- A chunk's last beat is a CHUNK-boundary beat or the frame tLast.
      if (r.inBeat = CHUNK_BEATS_C-1) or (sAxisMaster.tLast = '1') then
         chunkEnd := '1';
      else
         chunkEnd := '0';
      end if;

      ingReady := (not dFifoAFull) and (not iFifoAFull);
      ingAcc   := sAxisMaster.tValid and ingReady;
      byteNew  := r.inBytes + thisByte;

      dFifoWr   <= ingAcc;
      dFifoDin  <= chunkEnd & mtyBeat & sAxisMaster.tData(DAT_W_C-1 downto 0);
      iFifoWr   <= ingAcc and chunkEnd;
      iFifoDin  <= sAxisMaster.tLast & byteNew &
                   ite(r.inFirstVld = '1', r.inFirst, sAxisMaster.tUser(7 downto 0)) &
                   sAxisMaster.tUser(7 downto 0);

      sAxisSlave.tReady <= ingReady;

      if (ingAcc = '1') then
         if (r.inFirstVld = '0') then
            v.inFirst    := sAxisMaster.tUser(7 downto 0);
            v.inFirstVld := '1';
         end if;
         if (chunkEnd = '1') then
            v.inBeat     := (others => '0');
            v.inBytes    := (others => '0');
            v.inFirstVld := '0';
         else
            v.inBeat  := r.inBeat + 1;
            v.inBytes := byteNew;
         end if;
      end if;

      ----------------------------------------------------------------------
      -- C2H egress FSM: per real buffer, issue up to N fake 4 KiB descriptors
      -- and emit exactly one CMPT (on the buffer-closing chunk).
      ----------------------------------------------------------------------
      -- Egress-driven output defaults (idle)
      c2hBypValid      <= '0';
      c2hBypAddr       <= (others => '0');
      c2hStValid       <= '0';
      c2hStData        <= (others => '0');
      c2hStLast        <= '0';
      c2hStMty         <= (others => '0');
      c2hStCtrlLen     <= (others => '0');
      c2hStCtrlHasCmpt <= '0';
      cmptValid        <= '0';
      cmptData         <= (others => '0');
      cmptWaitPldPktId <= (others => '0');
      dFifoRd          <= '0';
      iFifoRd          <= '0';

      offset64 := x"00000000" & r.chunkIdx & x"000";  -- chunkIdx * 4096

      case r.c2hState is
         when C2H_IDLE_S =>
            if (iFifoValid = '1') then
               if (r.haveBuf = '1') then
                  v.c2hState := C2H_DESC_S;
               else
                  v.c2hState := C2H_GETBUF_S;
               end if;
            end if;

         when C2H_GETBUF_S =>
            -- Grab a free host buffer (and the shared dmaAddr port; TX wins).
            if (rxFree.valid = '1' and r.h2cState = H2C_IDLE_S and txSub.valid = '0') then
               v.c2hAddrIdx  := rxFree.index;
               v.rxFreeReady := '1';
               v.curBuffId   := rxFree.index;
               if (maxSize(31 downto 12) = 0) then
                  v.nChunksM1 := (others => '0');          -- < 1 chunk -> treat as 1
               else
                  v.nChunksM1 := maxSize(31 downto 12) - 1;
               end if;
               v.chunkIdx := (others => '0');
               v.bufBytes := (others => '0');
               v.lkCnt    := (others => '0');
               v.c2hState := C2H_LOOKUP_S;
            end if;

         when C2H_LOOKUP_S =>
            -- Hold c2hAddrIdx on the read port until the dmaAddr table responds.
            if (r.lkCnt = ADDR_RD_LAT_C) then
               v.curBase  := addrRdData;
               v.haveBuf  := '1';
               v.c2hState := C2H_DESC_S;
            else
               v.lkCnt := r.lkCnt + 1;
            end if;

         when C2H_DESC_S =>
            -- Peek the next chunk's metadata; issue its fake descriptor.
            if (iFifoValid = '1') then
               if (infFrameEnd = '1') or (r.chunkIdx = r.nChunksM1) then
                  closing := '1';
               else
                  closing := '0';
               end if;
               v.egClosing  := closing;
               v.egFrameEnd := infFrameEnd;
               v.egByteCnt  := infByteCnt;
               v.egLast     := infLast;
               if (r.chunkIdx = 0) then
                  v.bufFirst := infFirst;
               end if;
               c2hBypValid <= '1';
               c2hBypAddr  <= r.curBase + offset64;
               if (c2hBypReady = '1') then
                  v.c2hState := C2H_DATA_S;
               end if;
            end if;

         when C2H_DATA_S =>
            -- Stream the chunk's beats from the data FIFO onto the QDMA C2H ST
            -- input. ctrl_len/has_cmpt are valid on the first beat (held here).
            c2hStValid       <= dFifoValid;
            c2hStData        <= headData;
            c2hStLast        <= headLast;
            c2hStMty         <= headMty;
            c2hStCtrlLen     <= r.egByteCnt;
            c2hStCtrlHasCmpt <= r.egClosing;
            dFifoRd          <= dFifoValid and c2hStReady;
            if (dFifoValid = '1' and c2hStReady = '1' and headLast = '1') then
               iFifoRd      <= '1';                 -- consume this chunk's metadata
               v.bufBytes   := r.bufBytes + r.egByteCnt;
               v.cmptWaitId := r.pldPktId;          -- this packet's id
               v.pldPktId   := r.pldPktId + 1;      -- count every data packet
               if (r.egClosing = '1') then
                  v.c2hState := C2H_CMPT_S;
               else
                  v.chunkIdx := r.chunkIdx + 1;
                  v.c2hState := C2H_DESC_S;
               end if;
            end if;

         when C2H_CMPT_S =>
            -- Emit the 16B datadev ring entry (R2 section 3 layout).
            entry := (others => '0');
            entry(31 downto 24) := r.bufFirst;              -- firstUser
            entry(23 downto 16) := r.egLast;                -- lastUser
            entry(15 downto 8)  := (others => '0');         -- id
            entry(3)            := not r.egFrameEnd;        -- continue (frame spans buffers)
            entry(2 downto 0)   := (others => '0');         -- result
            entry(63 downto 32) := resize(r.curBuffId, 32); -- buffId
            entry(95 downto 64) := r.bufBytes;              -- size (bytes in this buffer)
            entry(127)          := '1';                     -- word3 bit31 = valid marker
            cmptValid        <= '1';
            cmptData         <= entry;
            cmptWaitPldPktId <= r.cmptWaitId;
            if (cmptReady = '1') then
               v.cmptDone := '1';     -- buffer delivered -> raise datadev IRQ
               v.haveBuf  := '0';
               v.c2hState := C2H_IDLE_S;
            end if;
      end case;

      ----------------------------------------------------------------------
      -- Shared dmaAddr read-port mux (TX has priority; by construction only
      -- one side is in its LOOKUP state at a time).
      ----------------------------------------------------------------------
      if (r.h2cState = H2C_LOOKUP_S) then
         addrRdIndex <= r.txAddrIdx;
      else
         addrRdIndex <= r.c2hAddrIdx;
      end if;

      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      ----------------------------------------------------------------------
      -- Static / registered outputs
      ----------------------------------------------------------------------
      txSubReady  <= r.txSubReady;
      rxFreeReady <= r.rxFreeReady;
      cmptDone    <= r.cmptDone;

      -- H2C bypass-in descriptor
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

      -- C2H bypass-in (fake 4 KiB descriptor) static fields
      c2hBypQid     <= C2H_QID_G;
      c2hBypFunc    <= FUNC_ID_G;
      c2hBypPfchTag <= pfchTag;
      c2hBypPortId  <= PORT_ID_G;
      c2hBypError   <= '0';

      -- C2H stream + completion static fields
      c2hStCtrlQid <= C2H_QID_G;
      cmptSize     <= "01";          -- 16B completion = AxisG2 entry
      cmptQid      <= '0' & C2H_QID_G;
      cmptType     <= "11";          -- HAS_PLD
      cmptColIdx   <= "111";         -- no color insert (entry = cmpt_data verbatim)
      cmptErrIdx   <= "111";         -- no error insert

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   --------------------------------------------------------------------------
   -- H2C stream data (QDMA -> user). Flatten the QDMA ST bus into the user
   -- AxiStreamMaster; reconstruct tKeep from the QDMA "empty byte" count (mty).
   --------------------------------------------------------------------------
   process (h2cStData, h2cStLast, h2cStMty, h2cStValid, mAxisSlave) is
      variable m      : AxiStreamMasterType;
      variable nBytes : integer;
   begin
      m         := AXI_STREAM_MASTER_INIT_C;
      m.tData(DAT_W_C-1 downto 0) := h2cStData;
      m.tKeep := (others => '0');
      if (h2cStLast = '1') then
         nBytes := DATA_BYTES_C - conv_integer(h2cStMty);
      else
         nBytes := DATA_BYTES_C;
      end if;
      for i in 0 to DATA_BYTES_C-1 loop
         if (i < nBytes) then
            m.tKeep(i) := '1';
         end if;
      end loop;
      m.tLast     := h2cStLast;
      m.tValid    := h2cStValid;
      mAxisMaster <= m;
      h2cStReady  <= mAxisSlave.tReady;
   end process;

end rtl;
