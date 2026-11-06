-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Versal CPM5 QDMA queue-context auto-init block for the Alveo V80.
--
-- Programs the CPM5 QDMA per-queue context over the QDMA config BAR so that one
-- H2C-stream and one C2H-stream queue come up in DESCRIPTOR BYPASS (simple
-- bypass) mode, ready to accept descriptors driven from PL by QdmaBypassAdapter.
-- The host datadev (aes-stream) driver performs none of this setup, so -- like
-- the BDF-table programming in XilinxAlveoV80CpmManager -- a PL state machine
-- does it once, after the CPM5 is past boot and PCIe link is up.
--
-- Sequence (PG347 v3.4 "Queue Setup" / "Context Programming" + the AXI-ST
-- worked example, Fig 59/60). All indirect-context ops below are followed by a
-- read-poll of QDMA_IND_CTXT_CMD[0] (busy) until it clears:
--   1) Global ring-size table (0x204) and C2H buffer-size table (0xAB0).
--   2) Global function map (0x400).
--   3) CLR hardware + credit contexts for H2C and C2H.
--   4) MASK_0..7 = all 1s (write-enable every context bit).
--   5) WR SW descriptor context (H2C, then C2H), PFCH context, CMPT context,
--      each as 8x DATA words then a CMD write.
--   6) Enable the H2C (0x1204) and C2H (0x1004) engines.
--
-- Implemented as a table-driven FSM: a compile-time "op ROM" (OP_ADDR_C /
-- OP_DATA_C / OP_POLL_C) is walked one entry at a time by a QdmaMgmtMaster
-- REQ/ACK engine driving the CPM5 dma1_mgmt req/cpl handshake (the CPM5 PL-side
-- QDMA config path is mgmt req/cpl, NOT AXI-Lite). Entries flagged OP_POLL_C
-- are CMD writes, after which the FSM reads CMD back until busy clears. This
-- mirrors the flattened-array style of XilinxAlveoV80CpmManagerPkg so the whole
-- program is table-driven.
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

library axi_pcie_core;
use axi_pcie_core.QdmaCtxtPkg.all;

entity QdmaCtxtInit is
   generic (
      TPD_G        : time              := 1 ns;
      -- QID of the H2C and C2H stream queues to bring up (CMD-reg Qid is [17:7])
      H2C_QID_G    : slv(10 downto 0)  := (others => '0');
      C2H_QID_G    : slv(10 downto 0)  := (others => '0');
      -- PCIe function id these queues belong to (mgmt req_fnc is 13-bit)
      FUNC_ID_G    : slv(12 downto 0)  := (others => '0');
      -- MSI-X vector index to raise on queue status updates
      MSIX_VEC_G   : slv(10 downto 0)  := (others => '0');
      -- Global ring-size-table index value written to 0x204 (log2-style index
      -- into the 16-entry ring size register bank)
      RING_SZ_VAL_G : slv(31 downto 0) := x"00000008";
      -- C2H stream buffer size written to 0xAB0 (bytes)
      C2H_BUF_SZ_G  : slv(31 downto 0) := x"00001000";  -- 4 KiB
      -- Re-arm watchdog (cycles) if a transaction hangs; 250e6 ~ 1 s @ 250 MHz
      WATCHDOG_G    : positive         := 250000000);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rstL            : in  sl;         -- active LOW reset
      -- Trigger: assert once the CPM5/PCIe is up (e.g. link-up or first IRQ).
      -- Rising-edge latched; the program runs exactly once per assertion of
      -- start while not already done.
      start           : in  sl;
      -- Status
      ctxtDone        : out sl;         -- all contexts programmed, engines enabled
      -- QDMA Management interface (drives the CIPS dma1_mgmt req/cpl handshake)
      mgmtMaster      : out QdmaMgmtReqMasterType;
      mgmtSlave       : in  QdmaMgmtReqSlaveType);
end QdmaCtxtInit;

architecture rtl of QdmaCtxtInit is

   ----------------------------------------------------------------------------
   -- Compile-time context images
   ----------------------------------------------------------------------------
   -- H2C stream, descriptor-bypass: 16B descriptors, fetch-credit off, qen.
   constant SW_H2C_C : QdmaSwCtxtType := (
      vec      => MSIX_VEC_G,
      dscBase  => (others => '0'),     -- no host ring fetched in simple bypass
      isMm     => '0',
      portId   => (others => '0'),
      irqEn    => '1',
      wbkEn    => '1',
      bypass   => '1',
      dscSz    => "01",                -- 16B required for H2C ST
      rngSz    => RING_SZ_VAL_G(3 downto 0),
      fetchMax => (others => '0'),
      fcrdEn   => '0',
      qen      => '1',
      fncId    => FUNC_ID_G(7 downto 0),
      irqArm   => '0',
      pidx     => (others => '0'));

   -- C2H stream, descriptor-bypass: 8B descriptors, fetch-credit on (per PG347).
   constant SW_C2H_C : QdmaSwCtxtType := (
      vec      => MSIX_VEC_G,
      dscBase  => (others => '0'),
      isMm     => '0',
      portId   => (others => '0'),
      irqEn    => '0',                 -- "Set to 0 for C2H ST"
      wbkEn    => '1',
      bypass   => '1',
      dscSz    => "00",                -- 8B required for C2H ST
      rngSz    => RING_SZ_VAL_G(3 downto 0),
      fetchMax => (others => '0'),
      fcrdEn   => '1',                 -- "Set to 1 for C2H ST"
      qen      => '1',
      fncId    => FUNC_ID_G(7 downto 0),
      irqArm   => '0',
      pidx     => (others => '0'));

   constant PFCH_C : QdmaPfchCtxtType := (
      valid      => '1',
      pfchEn     => '0',               -- simple bypass: no prefetch
      portId     => (others => '0'),
      bufSizeIdx => (others => '0'),
      bypass     => '1');              -- simple bypass (Table 129)

   constant CMPT_C : QdmaCmptCtxtType := (
      portId     => (others => '0'),
      dirC2h     => '1',
      intAggr    => '0',
      vec        => MSIX_VEC_G,
      baddr      => (others => '0'),
      descSize   => "00",              -- 8B completion
      qsizeIdx   => RING_SZ_VAL_G(3 downto 0),
      color      => '0',
      timerIdx   => (others => '0'),
      fncId      => FUNC_ID_G(7 downto 0),
      trigMode   => "001",             -- Every
      enInt      => '1',
      enStatDesc => '1',
      valid      => '1');

   constant SW_H2C_IMG_C : slv(255 downto 0) := toSlv256(SW_H2C_C);
   constant SW_C2H_IMG_C : slv(255 downto 0) := toSlv256(SW_C2H_C);
   constant PFCH_IMG_C   : slv(255 downto 0) := toSlv256(PFCH_C);
   constant CMPT_IMG_C    : slv(255 downto 0) := toSlv256(CMPT_C);

   ----------------------------------------------------------------------------
   -- Op ROM. Each op is one mgmt-interface write; OP_POLL_C marks CMD writes
   -- after which busy must be polled. Helper functions below expand each context
   -- program (8 MASK + 8 DATA + 1 CMD) into ordered (addr,data,poll) triples.
   ----------------------------------------------------------------------------
   constant NW_C : natural := QDMA_IND_CTXT_NUM_WORDS_C;  -- 8

   -- An indirect context WR program = 8 DATA writes + 1 CMD write (poll).
   -- (MASK is written once globally up front; the HW holds it, so we re-write
   --  MASK before each context to be safe -- cheap and matches the worked flow.)
   constant CTXT_OPS_C : natural := NW_C + NW_C + 1;  -- MASK + DATA + CMD

   -- Program length:
   --   globals: ring-size, c2h-buf-size, fmap                        = 3
   --   clears : HW_H2C, HW_C2H, CR_H2C, CR_C2H  (CMD writes, poll)    = 4
   --   ctxts  : SW_H2C, SW_C2H, PFCH, CMPT  (CTXT_OPS_C each)         = 4*CTXT_OPS_C
   --   enables: H2C engine, C2H engine                               = 2
   constant PROG_LEN_C : natural := 3 + 4 + 4*CTXT_OPS_C + 2;

   type OpArray is array (natural range <>) of slv(31 downto 0);

   -- Build the three parallel ROMs.
   impure function buildAddr return OpArray is
      variable a   : OpArray(0 to PROG_LEN_C-1) := (others => (others => '0'));
      variable i   : natural := 0;
      -- append one context program (MASK*8, DATA*8, CMD)
      procedure ctxtProg (sel : slv(3 downto 0); qid : slv(10 downto 0)) is
      begin
         for w in 0 to NW_C-1 loop
            a(i) := QDMA_IND_CTXT_MASK_BASE_C + toSlv(4*w, 32); i := i + 1;
         end loop;
         for w in 0 to NW_C-1 loop
            a(i) := QDMA_IND_CTXT_DATA_BASE_C + toSlv(4*w, 32); i := i + 1;
         end loop;
         a(i) := QDMA_IND_CTXT_CMD_ADDR_C; i := i + 1;  -- CMD (poll)
      end procedure;
   begin
      -- globals
      a(i) := QDMA_GLBL_RNG_SZ_C; i := i + 1;
      a(i) := QDMA_C2H_BUF_SZ_C;  i := i + 1;
      a(i) := QDMA_TRQ_FMAP_C;    i := i + 1;
      -- clears (CMD writes)
      a(i) := QDMA_IND_CTXT_CMD_ADDR_C; i := i + 1;  -- HW_H2C clr
      a(i) := QDMA_IND_CTXT_CMD_ADDR_C; i := i + 1;  -- HW_C2H clr
      a(i) := QDMA_IND_CTXT_CMD_ADDR_C; i := i + 1;  -- CR_H2C clr
      a(i) := QDMA_IND_CTXT_CMD_ADDR_C; i := i + 1;  -- CR_C2H clr
      -- contexts
      ctxtProg(CTXT_SEL_SW_H2C_C, H2C_QID_G);
      ctxtProg(CTXT_SEL_SW_C2H_C, C2H_QID_G);
      ctxtProg(CTXT_SEL_PFCH_C,   C2H_QID_G);
      ctxtProg(CTXT_SEL_CMPT_C,   C2H_QID_G);
      -- engine enables
      a(i) := QDMA_H2C_ENGINE_EN_C; i := i + 1;
      a(i) := QDMA_C2H_ENGINE_EN_C; i := i + 1;
      return a;
   end function buildAddr;

   impure function buildData return OpArray is
      variable d : OpArray(0 to PROG_LEN_C-1) := (others => (others => '0'));
      variable i : natural := 0;
      procedure ctxtProg (img : slv(255 downto 0); sel : slv(3 downto 0); qid : slv(10 downto 0)) is
      begin
         for w in 0 to NW_C-1 loop
            d(i) := (others => '1'); i := i + 1;              -- MASK = all 1s
         end loop;
         for w in 0 to NW_C-1 loop
            d(i) := img(32*w+31 downto 32*w); i := i + 1;     -- DATA word w
         end loop;
         d(i) := genCtxtCmd(qid, CTXT_OP_WR_C, sel); i := i + 1;  -- CMD WR
      end procedure;
   begin
      d(i) := RING_SZ_VAL_G; i := i + 1;
      d(i) := C2H_BUF_SZ_G;  i := i + 1;
      -- FMAP: qid base 0, 1 queue for this function (low bits). Exact field
      -- packing is tuned at bring-up; a single-queue function needs qbase=0,
      -- qmax>=1. Placeholder sets qmax=1.
      d(i) := x"00000001"; i := i + 1;
      -- clears
      d(i) := genCtxtCmd(H2C_QID_G, CTXT_OP_CLR_C, CTXT_SEL_HW_H2C_C); i := i + 1;
      d(i) := genCtxtCmd(C2H_QID_G, CTXT_OP_CLR_C, CTXT_SEL_HW_C2H_C); i := i + 1;
      d(i) := genCtxtCmd(H2C_QID_G, CTXT_OP_CLR_C, CTXT_SEL_CR_H2C_C); i := i + 1;
      d(i) := genCtxtCmd(C2H_QID_G, CTXT_OP_CLR_C, CTXT_SEL_CR_C2H_C); i := i + 1;
      -- contexts
      ctxtProg(SW_H2C_IMG_C, CTXT_SEL_SW_H2C_C, H2C_QID_G);
      ctxtProg(SW_C2H_IMG_C, CTXT_SEL_SW_C2H_C, C2H_QID_G);
      ctxtProg(PFCH_IMG_C,   CTXT_SEL_PFCH_C,   C2H_QID_G);
      ctxtProg(CMPT_IMG_C,   CTXT_SEL_CMPT_C,   C2H_QID_G);
      -- engine enables
      d(i) := x"00000001"; i := i + 1;
      d(i) := x"00000001"; i := i + 1;
      return d;
   end function buildData;

   -- poll flag: true on every CMD-register write (addr = 0x824)
   impure function buildPoll return slv is
      variable p : slv(0 to PROG_LEN_C-1) := (others => '0');
      variable addrRom : OpArray(0 to PROG_LEN_C-1) := buildAddr;
   begin
      for k in 0 to PROG_LEN_C-1 loop
         if (addrRom(k) = QDMA_IND_CTXT_CMD_ADDR_C) then
            p(k) := '1';
         end if;
      end loop;
      return p;
   end function buildPoll;

   constant OP_ADDR_C : OpArray(0 to PROG_LEN_C-1) := buildAddr;
   constant OP_DATA_C : OpArray(0 to PROG_LEN_C-1) := buildData;
   constant OP_POLL_C : slv(0 to PROG_LEN_C-1)     := buildPoll;

   type StateType is (
      IDLE_S,
      WRITE_REQ_S,
      WRITE_WAIT_S,
      POLL_REQ_S,
      POLL_WAIT_S,
      NEXT_S,
      DONE_S);

   type RegType is record
      req      : QdmaMgmtReqType;
      ctxtDone : sl;
      opIndex  : natural range 0 to PROG_LEN_C;
      timer    : slv(31 downto 0);
      startDly : sl;
      state    : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      req      => QDMA_MGMT_REQ_INIT_C,
      ctxtDone => '0',
      opIndex  => 0,
      timer    => (others => '0'),
      startDly => '0',
      state    => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ack : QdmaMgmtAckType;

begin

   U_QdmaMgmtMaster : entity axi_pcie_core.QdmaMgmtMaster
      generic map (
         TPD_G => TPD_G)
      port map (
         clk        => clk,
         rstL       => rstL,
         req        => r.req,
         ack        => ack,
         mgmtMaster => mgmtMaster,
         mgmtSlave  => mgmtSlave);

   comb : process (ack, r, rstL, start) is
      variable v : RegType;
   begin
      v := r;

      v.startDly := start;

      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            v.timer   := (others => '0');
            v.opIndex := 0;
            -- Run once on a rising edge of start, while not already done.
            if (start = '1' and r.startDly = '0' and r.ctxtDone = '0') then
               v.state := WRITE_REQ_S;
            end if;
         ----------------------------------------------------------------------
         when WRITE_REQ_S =>
            -- Issue the current op's 32-bit write.
            v.req.request := '1';
            v.req.rnw     := '0';
            v.req.address := OP_ADDR_C(r.opIndex);
            v.req.wrData  := OP_DATA_C(r.opIndex);
            v.req.func    := FUNC_ID_G;
            v.timer       := (others => '0');
            v.state       := WRITE_WAIT_S;
         ----------------------------------------------------------------------
         when WRITE_WAIT_S =>
            if (ack.done = '1') then
               v.req.request := '0';
               if (OP_POLL_C(r.opIndex) = '1') then
                  v.state := POLL_REQ_S;    -- CMD write -> poll busy
               else
                  v.state := NEXT_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when POLL_REQ_S =>
            -- Read back QDMA_IND_CTXT_CMD to check the busy bit [0].
            v.req.request := '1';
            v.req.rnw     := '1';
            v.req.address := QDMA_IND_CTXT_CMD_ADDR_C;
            v.req.func    := FUNC_ID_G;
            v.state       := POLL_WAIT_S;
         ----------------------------------------------------------------------
         when POLL_WAIT_S =>
            if (ack.done = '1') then
               v.req.request := '0';
               if (ack.rdData(0) = '0') then
                  v.state := NEXT_S;        -- busy clear -> op complete
               else
                  v.state := POLL_REQ_S;    -- still busy -> re-read
               end if;
            end if;
         ----------------------------------------------------------------------
         when NEXT_S =>
            if (r.opIndex = PROG_LEN_C-1) then
               v.state := DONE_S;
            else
               v.opIndex := r.opIndex + 1;
               v.state   := WRITE_REQ_S;
            end if;
         ----------------------------------------------------------------------
         when DONE_S =>
            v.ctxtDone := '1';
            v.state    := IDLE_S;
      ----------------------------------------------------------------------
      end case;

      -- Watchdog: if any wait state hangs, abort back to IDLE (do not latch
      -- done) so a retrigger can retry.
      if (r.state = WRITE_WAIT_S or r.state = POLL_WAIT_S) then
         v.timer := r.timer + 1;
         if (r.timer = toSlv(WATCHDOG_G, 32)) then
            v.req.request := '0';
            v.state       := IDLE_S;
         end if;
      end if;

      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      rin      <= v;
      ctxtDone <= r.ctxtDone;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
