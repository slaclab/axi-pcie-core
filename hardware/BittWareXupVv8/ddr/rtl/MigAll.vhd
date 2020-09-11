-------------------------------------------------------------------------------
-- File       : MigAll.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for the MIG core
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;

library axi_pcie_core;
use axi_pcie_core.MigPkg.all;

entity MigAll is
   generic (
      TPD_G      : time                  := 1 ns;
      NUM_DIMM_G : positive range 1 to 4 := 4);
   port (
      extRst          : in    sl := '0';
      -- AXI MEM Interface
      axiClk          : out   slv(NUM_DIMM_G-1 downto 0);
      axiRst          : out   slv(NUM_DIMM_G-1 downto 0);
      axiReady        : out   slv(NUM_DIMM_G-1 downto 0);
      axiWriteMasters : in    AxiWriteMasterArray(NUM_DIMM_G-1 downto 0);
      axiWriteSlaves  : out   AxiWriteSlaveArray(NUM_DIMM_G-1 downto 0);
      axiReadMasters  : in    AxiReadMasterArray(NUM_DIMM_G-1 downto 0);
      axiReadSlaves   : out   AxiReadSlaveArray(NUM_DIMM_G-1 downto 0);
      -- DDR Ports
      ddrClkP         : in    slv(NUM_DIMM_G-1 downto 0);
      ddrClkN         : in    slv(NUM_DIMM_G-1 downto 0);
      ddrOut          : out   DdrOutArray(NUM_DIMM_G-1 downto 0);
      ddrInOut        : inout DdrInOutArray(NUM_DIMM_G-1 downto 0));
end MigAll;

architecture mapping of MigAll is

begin

   --------------
   -- MIG IP Core
   --------------
   GEN_VEC : for i in NUM_DIMM_G-1 downto 0 generate
      U_Mig : entity axi_pcie_core.Mig
         generic map (
            TPD_G => TPD_G)
         port map (
            extRst         => extRst,
            -- AXI MEM Interface
            axiClk         => axiClk(i),
            axiRst         => axiRst(i),
            axiReady       => axiReady(i),
            axiWriteMaster => axiWriteMasters(i),
            axiWriteSlave  => axiWriteSlaves(i),
            axiReadMaster  => axiReadMasters(i),
            axiReadSlave   => axiReadSlaves(i),
            -- DDR Ports
            ddrClkP        => ddrClkP(i),
            ddrClkN        => ddrClkN(i),
            ddrOut         => ddrOut(i),
            ddrInOut       => ddrInOut(i));
   end generate GEN_VEC;

end mapping;
