-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Transaction engine for the Versal CPM5 QDMA management
-- (dma1_mgmt) interface on the Xilinx Alveo V80.
--
-- Converts a simple REQ/ACK request (QdmaMgmtReqType / QdmaMgmtAckType) into
-- the CPM5 dma1_mgmt req/cpl handshake (PG347 v3.4 Table 184), so that higher-
-- level logic (QdmaCtxtInit) can issue QDMA register reads/writes without
-- knowing the wire protocol -- the same separation surf.AxiLiteMaster gives for
-- AXI-Lite. This replaces the AXI-Lite transaction back-end originally assumed
-- for QDMA config access (the CPM5 PL config path is mgmt req/cpl, NOT
-- AXI-Lite).
--
-- Protocol (PG347 Table 184):
--   * Drive req_adr/req_dat/req_cmd/req_fnc and pulse req_vld for one cycle
--     while req_rdy is high (command 00=read, 01=write).
--   * Every transaction returns a completion: cpl_vld pulses for one cycle
--     while we hold cpl_rdy; cpl_sts[0]=error, cpl_sts[1]=1 write-resp/0
--     read-resp; cpl_dat holds read data.
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

entity QdmaMgmtMaster is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      clk        : in  sl;
      rstL       : in  sl;              -- active LOW reset
      -- REQ/ACK request interface (to QdmaCtxtInit)
      req        : in  QdmaMgmtReqType;
      ack        : out QdmaMgmtAckType;
      -- Flattened dma1_mgmt wires (to CIPS)
      mgmtMaster : out QdmaMgmtReqMasterType;
      mgmtSlave  : in  QdmaMgmtReqSlaveType);
end QdmaMgmtMaster;

architecture rtl of QdmaMgmtMaster is

   type StateType is (
      IDLE_S,
      REQ_S,
      CPL_S,
      DONE_S);

   type RegType is record
      state : StateType;
      master : QdmaMgmtReqMasterType;
      ack    : QdmaMgmtAckType;
   end record RegType;

   constant MASTER_INIT_C : QdmaMgmtReqMasterType := (
      reqAdr => (others => '0'),
      reqDat => (others => '0'),
      reqCmd => (others => '0'),
      reqFnc => (others => '0'),
      reqMsc => (others => '0'),
      reqVld => '0',
      cplRdy => '0');

   constant REG_INIT_C : RegType := (
      state  => IDLE_S,
      master => MASTER_INIT_C,
      ack    => QDMA_MGMT_ACK_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (mgmtSlave, r, req, rstL) is
      variable v : RegType;
   begin
      v := r;

      -- Defaults (ack.done is a 1-cycle pulse)
      v.ack.done := '0';

      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            v.master        := MASTER_INIT_C;
            if (req.request = '1') then
               v.master.reqAdr := req.address;
               v.master.reqDat := req.wrData;
               v.master.reqFnc := req.func;
               if (req.rnw = '1') then
                  v.master.reqCmd := MGMT_CMD_RD_C;
               else
                  v.master.reqCmd := MGMT_CMD_WR_C;
               end if;
               v.master.reqVld := '1';
               v.state         := REQ_S;
            end if;
         ----------------------------------------------------------------------
         when REQ_S =>
            -- Hold req until accepted (vld & rdy), then wait for completion.
            if (mgmtSlave.reqRdy = '1') then
               v.master.reqVld := '0';
               v.master.cplRdy := '1';   -- ready to accept the completion
               v.state         := CPL_S;
            end if;
         ----------------------------------------------------------------------
         when CPL_S =>
            if (mgmtSlave.cplVld = '1') then
               v.master.cplRdy  := '0';
               v.ack.rdData     := mgmtSlave.cplDat;
               v.ack.error      := mgmtSlave.cplSts(0);
               v.ack.done       := '1';
               v.state          := DONE_S;
            end if;
         ----------------------------------------------------------------------
         when DONE_S =>
            -- One idle cycle so the consumer sees done and drops request.
            if (req.request = '0') then
               v.state := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Outputs
      mgmtMaster <= r.master;
      ack        <= r.ack;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
