-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Package for the Versal CPM5 QDMA queue-context auto-init block
-- (QdmaCtxtInit) on the Xilinx Alveo V80.
--
-- The CPM5 QDMA descriptor engine keeps per-queue configuration in "context"
-- structures that MUST be programmed before a queue can move data -- this is
-- true even in descriptor-bypass mode (PG347 v3.4, Section IV "QDMA Subsystem
-- for CPM5"). The host datadev (aes-stream) driver does none of this, so a PL
-- state machine (QdmaCtxtInit) programs the contexts over the QDMA config BAR
-- using the indirect-context access mechanism.
--
-- Indirect context programming (PG347 v3.4 "Context Programming", worked
-- example Fig 59/60 and the ST flow):
--   1) Program QDMA_IND_CTXT_MASK_0..7 (0x824..0x840) = all 1s (write-enable
--      every bit).
--   2) Program the context payload into QDMA_IND_CTXT_DATA_0..7 (0x804..0x820)
--      -- 8 x 32-bit = 256 bits, matching the CPM5 context width (Tables 120,
--      128, 130; note CPM5 contexts are 256-bit, WIDER than CPM4's 128-bit).
--   3) Write QDMA_IND_CTXT_CMD (0x844): Qid[17:7], Op[6:5], Sel[4:1], busy[0].
--      Op: 0=CLR 1=WR 2=RD 3=INV.  Sel: 0=SW_C2H 1=SW_H2C 2=HW_C2H 3=HW_H2C
--      4=CR_C2H 5=CR_H2C 6=CMPT/WRB 7=PFCH 8=INT_COAL.
--   4) Poll QDMA_IND_CTXT_CMD[0] (busy) clear between operations.
--
-- This package provides:
--   * The three context records we actually program for a stream-bypass queue
--     (SW descriptor, C2H prefetch, C2H completion), with bit layouts taken
--     verbatim from the CPM5 tables.
--   * toSlv256() functions that pack each record into the 256-bit DATA image.
--   * Register-offset and command-encoding constants.
--
-- This mirrors the style of XilinxAlveoV80CpmManagerPkg (record -> flattened
-- Slv helpers), so the init block stays table-driven and reviewable.
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

package QdmaCtxtPkg is

   ----------------------------------------------------------------------------
   -- QDMA indirect-context register offsets (relative to the QDMA config BAR
   -- window; PG347 v3.4 CPM5, p248). There are 8 x 32-bit DATA words
   -- (0x804..0x820), 8 x 32-bit MASK words (0x824..0x840), then the command
   -- register (0x844). DATA_n = 0x804 + 4*n, MASK_n = 0x824 + 4*n.
   ----------------------------------------------------------------------------
   -- PG347 v3.4 CPM5 (p248): DATA_0..7 = 0x804..0x820, MASK_0..7 = 0x824..0x840,
   -- CMD = 0x844. (The earlier MASK=0x814/CMD=0x824 overlapped DATA and each
   -- other -> MASK_4 collided with the old CMD addr and wedged the init poll.)
   constant QDMA_IND_CTXT_DATA_BASE_C : slv(31 downto 0) := x"00000804";  -- DATA_0 (0x804..0x820)
   constant QDMA_IND_CTXT_MASK_BASE_C : slv(31 downto 0) := x"00000824";  -- MASK_0 (0x824..0x840)
   constant QDMA_IND_CTXT_CMD_ADDR_C  : slv(31 downto 0) := x"00000844";  -- CMD
   constant QDMA_IND_CTXT_NUM_WORDS_C : positive         := 8;

   -- Global QDMA registers used during queue setup (PG347 worked example).
   constant QDMA_GLBL_RNG_SZ_C   : slv(31 downto 0) := x"00000204";  -- ring size table base
   constant QDMA_TRQ_FMAP_C      : slv(31 downto 0) := x"00000400";  -- global function map
   constant QDMA_C2H_BUF_SZ_C    : slv(31 downto 0) := x"00000AB0";  -- C2H buffer size table base
   constant QDMA_H2C_ENGINE_EN_C : slv(31 downto 0) := x"00001204";  -- H2C engine command (val 0x1)
   constant QDMA_C2H_ENGINE_EN_C : slv(31 downto 0) := x"00001004";  -- C2H engine command (val 0x1)

   -- C2H simple-bypass prefetch-tag reservation (PG347 v3.4 "Simple Bypass
   -- Mode"): write the qid to BYP_QID, then read the tag back from BYP_TAG.
   -- Mandatory before any C2H traffic on a simple-bypass queue.
   constant QDMA_C2H_PFCH_BYP_QID_C : slv(31 downto 0) := x"00001408";
   constant QDMA_C2H_PFCH_BYP_TAG_C : slv(31 downto 0) := x"0000140C";

   -- Indirect command opcodes (QDMA_IND_CTXT_CMD bits [6:5]).
   constant CTXT_OP_CLR_C : slv(1 downto 0) := "00";
   constant CTXT_OP_WR_C  : slv(1 downto 0) := "01";
   constant CTXT_OP_RD_C  : slv(1 downto 0) := "10";
   constant CTXT_OP_INV_C : slv(1 downto 0) := "11";

   -- Indirect command context selects (QDMA_IND_CTXT_CMD bits [4:1]).
   constant CTXT_SEL_SW_C2H_C   : slv(3 downto 0) := x"0";
   constant CTXT_SEL_SW_H2C_C   : slv(3 downto 0) := x"1";
   constant CTXT_SEL_HW_C2H_C   : slv(3 downto 0) := x"2";
   constant CTXT_SEL_HW_H2C_C   : slv(3 downto 0) := x"3";
   constant CTXT_SEL_CR_C2H_C   : slv(3 downto 0) := x"4";
   constant CTXT_SEL_CR_H2C_C   : slv(3 downto 0) := x"5";
   constant CTXT_SEL_CMPT_C     : slv(3 downto 0) := x"6";  -- CMPT / used-ring (WRB)
   constant CTXT_SEL_PFCH_C     : slv(3 downto 0) := x"7";
   constant CTXT_SEL_INT_COAL_C : slv(3 downto 0) := x"8";

   -- Build a QDMA_IND_CTXT_CMD word. busy bit [0] is read-only status; we write
   -- 0 there (the write itself sets busy in HW).
   function genCtxtCmd (qid : slv(10 downto 0); op : slv(1 downto 0); sel : slv(3 downto 0)) return slv;

   ----------------------------------------------------------------------------
   -- QDMA Management (dma1_mgmt) interface req/ack records.
   --
   -- PL-side QDMA register/context access on CPM5 is NOT AXI-Lite: it is the
   -- dma1_mgmt req/cpl handshake (PG347 v3.4 Table 184). req carries a 32-bit
   -- address, 32-bit data, a 2-bit command (00=read, 01=write) and a 13-bit
   -- function number; one-cycle vld when rdy. Every transaction (read AND
   -- write) returns a cpl: cpl_sts[0]=error, cpl_sts[1]=1 for write-response /
   -- 0 for read-response; cpl_dat holds read data.
   --
   -- QdmaMgmtMaster presents these as a REQ/ACK pair (mirroring surf
   -- AxiLiteMaster's req/ack usage) so QdmaCtxtInit's state machine is
   -- transaction-engine agnostic.
   ----------------------------------------------------------------------------
   constant MGMT_CMD_RD_C : slv(1 downto 0) := "00";
   constant MGMT_CMD_WR_C : slv(1 downto 0) := "01";

   type QdmaMgmtReqType is record
      request : sl;                  -- assert to start a transaction
      rnw     : sl;                  -- 1 = read, 0 = write
      address : slv(31 downto 0);
      wrData  : slv(31 downto 0);
      func    : slv(12 downto 0);
   end record QdmaMgmtReqType;

   constant QDMA_MGMT_REQ_INIT_C : QdmaMgmtReqType := (
      request => '0',
      rnw     => '0',
      address => (others => '0'),
      wrData  => (others => '0'),
      func    => (others => '0'));

   type QdmaMgmtAckType is record
      done   : sl;                   -- transaction complete (1-cycle)
      error  : sl;                   -- cpl_sts[0]
      rdData : slv(31 downto 0);     -- cpl_dat (valid on read completion)
   end record QdmaMgmtAckType;

   constant QDMA_MGMT_ACK_INIT_C : QdmaMgmtAckType := (
      done   => '0',
      error  => '0',
      rdData => (others => '0'));

   -- Flattened CIPS dma1_mgmt port record (PL -> QDMA request side).
   type QdmaMgmtReqMasterType is record
      reqAdr : slv(31 downto 0);
      reqDat : slv(31 downto 0);
      reqCmd : slv(1 downto 0);
      reqFnc : slv(12 downto 0);
      reqMsc : slv(5 downto 0);
      reqVld : sl;
      cplRdy : sl;
   end record QdmaMgmtReqMasterType;

   -- QDMA -> PL completion / ready side.
   type QdmaMgmtReqSlaveType is record
      reqRdy : sl;
      cplDat : slv(31 downto 0);
      cplSts : slv(1 downto 0);
      cplVld : sl;
   end record QdmaMgmtReqSlaveType;

   ----------------------------------------------------------------------------
   -- Software Descriptor Context (PG347 v3.4 Table 120, CPM5, 256-bit).
   -- Only the fields we set for an AXI4-Stream descriptor-bypass queue are
   -- modeled; everything else packs as 0 (which matches the "initialize to 0"
   -- guidance for the HW-owned fields).
   ----------------------------------------------------------------------------
   type QdmaSwCtxtType is record
      vec      : slv(10 downto 0);   -- [138:128] MSI-X vector for this queue
      dscBase  : slv(63 downto 0);   -- [127:64]  4K-aligned descriptor ring base
      isMm     : sl;                 -- [63]      1=MM, 0=Stream  (0 for ST)
      portId   : slv(2 downto 0);    -- [56:54]   port id
      irqEn    : sl;                 -- [53]      interrupt enable (0 for C2H ST)
      wbkEn    : sl;                 -- [52]      writeback enable
      bypass   : sl;                 -- [50]      1=bypass mode
      dscSz    : slv(1 downto 0);    -- [49:48]   0:8B 1:16B 2:32B 3:64B
      rngSz    : slv(3 downto 0);    -- [47:44]   ring size index
      fetchMax : slv(3 downto 0);    -- [40:37]   max outstanding fetches - 1
      fcrdEn   : sl;                 -- [33]      fetch-credit enable (1 for C2H ST)
      qen      : sl;                 -- [32]      queue enable
      fncId    : slv(7 downto 0);    -- [24:17]   function id
      irqArm   : sl;                 -- [16]      interrupt arm
      pidx     : slv(15 downto 0);   -- [15:0]    producer index (init 0)
   end record QdmaSwCtxtType;

   constant QDMA_SW_CTXT_INIT_C : QdmaSwCtxtType := (
      vec      => (others => '0'),
      dscBase  => (others => '0'),
      isMm     => '0',
      portId   => (others => '0'),
      irqEn    => '0',
      wbkEn    => '0',
      bypass   => '1',
      dscSz    => "00",
      rngSz    => (others => '0'),
      fetchMax => (others => '0'),
      fcrdEn   => '0',
      qen      => '1',
      fncId    => (others => '0'),
      irqArm   => '0',
      pidx     => (others => '0'));

   function toSlv256 (ctxt : QdmaSwCtxtType) return slv;

   ----------------------------------------------------------------------------
   -- C2H Prefetch Context (PG347 v3.4 Table 128, CPM5; low 46 bits used).
   ----------------------------------------------------------------------------
   type QdmaPfchCtxtType is record
      valid      : sl;              -- [45] context valid
      pfchEn     : sl;              -- [27] enable prefetch (0 for simple bypass)
      portId     : slv(2 downto 0); -- [7:5]
      bufSizeIdx : slv(3 downto 0); -- [4:1]
      bypass     : sl;              -- [0] 1=simple bypass
   end record QdmaPfchCtxtType;

   constant QDMA_PFCH_CTXT_INIT_C : QdmaPfchCtxtType := (
      valid      => '1',
      pfchEn     => '0',
      portId     => (others => '0'),
      bufSizeIdx => (others => '0'),
      bypass     => '1');

   function toSlv256 (ctxt : QdmaPfchCtxtType) return slv;

   ----------------------------------------------------------------------------
   -- C2H Completion (CMPT) Context (PG347 v3.4 Table 130, CPM5, 256-bit).
   ----------------------------------------------------------------------------
   type QdmaCmptCtxtType is record
      portId     : slv(2 downto 0);  -- [182:180]
      dirC2h     : sl;               -- [146] 1=C2H
      ovfChkDis  : sl;               -- [130] completion-ring overflow check disable
      intAggr    : sl;               -- [143] interrupt aggregation
      vec        : slv(10 downto 0); -- [142:132] interrupt vector
      baddr      : slv(57 downto 0); -- [89:32] completion ring base [63:6]
      descSize   : slv(1 downto 0);  -- [91:90] 0:8B 1:16B 2:32B 3:64B
      qsizeIdx   : slv(3 downto 0);  -- [31:28] ring size index
      color      : sl;               -- [27]
      timerIdx   : slv(3 downto 0);  -- [24:21]
      fncId      : slv(7 downto 0);  -- [12:5]
      trigMode   : slv(2 downto 0);  -- [4:2]
      enInt      : sl;               -- [1] enable completion interrupts
      enStatDesc : sl;               -- [0] enable completion status writes
      valid      : sl;               -- [124] context valid (PG347 v3.4 Table 130)
   end record QdmaCmptCtxtType;

   constant QDMA_CMPT_CTXT_INIT_C : QdmaCmptCtxtType := (
      portId     => (others => '0'),
      dirC2h     => '1',
      ovfChkDis  => '1',             -- datadev never writes CIDX -> free-run the ring
      intAggr    => '0',
      vec        => (others => '0'),
      baddr      => (others => '0'),
      descSize   => "00",
      qsizeIdx   => (others => '0'),
      color      => '0',
      timerIdx   => (others => '0'),
      fncId      => (others => '0'),
      trigMode   => "001",           -- 0x1 = Every
      enInt      => '0',
      enStatDesc => '0',
      valid      => '1');

   function toSlv256 (ctxt : QdmaCmptCtxtType) return slv;

end package QdmaCtxtPkg;

package body QdmaCtxtPkg is

   function genCtxtCmd (qid : slv(10 downto 0); op : slv(1 downto 0); sel : slv(3 downto 0)) return slv is
      variable retVar : slv(31 downto 0);
   begin
      retVar             := (others => '0');
      retVar(17 downto 7) := qid;
      retVar(6 downto 5)  := op;
      retVar(4 downto 1)  := sel;
      -- bit[0] busy: left 0 on write
      return retVar;
   end function genCtxtCmd;

   function toSlv256 (ctxt : QdmaSwCtxtType) return slv is
      variable v : slv(255 downto 0);
   begin
      v := (others => '0');
      v(138 downto 128) := ctxt.vec;
      v(127 downto 64)  := ctxt.dscBase;
      v(63)             := ctxt.isMm;
      v(56 downto 54)   := ctxt.portId;
      v(53)             := ctxt.irqEn;
      v(52)             := ctxt.wbkEn;
      v(50)             := ctxt.bypass;
      v(49 downto 48)   := ctxt.dscSz;
      v(47 downto 44)   := ctxt.rngSz;
      v(40 downto 37)   := ctxt.fetchMax;
      v(33)             := ctxt.fcrdEn;
      v(32)             := ctxt.qen;
      v(24 downto 17)   := ctxt.fncId;
      v(16)             := ctxt.irqArm;
      v(15 downto 0)    := ctxt.pidx;
      return v;
   end function toSlv256;

   function toSlv256 (ctxt : QdmaPfchCtxtType) return slv is
      variable v : slv(255 downto 0);
   begin
      v := (others => '0');
      v(45)           := ctxt.valid;
      v(27)           := ctxt.pfchEn;
      v(7 downto 5)   := ctxt.portId;
      v(4 downto 1)   := ctxt.bufSizeIdx;
      v(0)            := ctxt.bypass;
      return v;
   end function toSlv256;

   function toSlv256 (ctxt : QdmaCmptCtxtType) return slv is
      variable v : slv(255 downto 0);
   begin
      v := (others => '0');
      v(182 downto 180) := ctxt.portId;
      v(146)            := ctxt.dirC2h;
      v(130)            := ctxt.ovfChkDis;  -- PG347 Table 130: overflow check disable
      v(143)            := ctxt.intAggr;
      v(142 downto 132) := ctxt.vec;
      v(123 downto 108) := (others => '0');  -- cidx (HW, init 0)
      v(107 downto 92)  := (others => '0');  -- pidx (HW, init 0)
      v(91 downto 90)   := ctxt.descSize;
      v(89 downto 32)   := ctxt.baddr;
      v(31 downto 28)   := ctxt.qsizeIdx;
      v(27)             := ctxt.color;
      v(24 downto 21)   := ctxt.timerIdx;
      v(124)            := ctxt.valid;  -- PG347 v3.4 Table 130: valid is [124], NOT [120]
      v(12 downto 5)    := ctxt.fncId;
      v(4 downto 2)     := ctxt.trigMode;
      v(1)              := ctxt.enInt;
      v(0)              := ctxt.enStatDesc;
      return v;
   end function toSlv256;

end package body QdmaCtxtPkg;
