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
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;

library axi_pcie_core;
use axi_pcie_core.MigPkg.all;

library unisim;
use unisim.vcomponents.all;

entity MigAll is
   generic (
      TPD_G      : time                  := 1 ns;
      NUM_LANE_G : positive range 1 to 4 := 4);
   port (
      extRst          : in    sl := '0';
      -- AXI MEM Interface
      axiClk          : out   slv(NUM_LANE_G-1 downto 0);
      axiRst          : out   slv(NUM_LANE_G-1 downto 0);
      axiReady        : out   slv(NUM_LANE_G-1 downto 0);
      axiWriteMasters : in    AxiWriteMasterArray(NUM_LANE_G-1 downto 0);
      axiWriteSlaves  : out   AxiWriteSlaveArray(NUM_LANE_G-1 downto 0);
      axiReadMasters  : in    AxiReadMasterArray(NUM_LANE_G-1 downto 0);
      axiReadSlaves   : out   AxiReadSlaveArray(NUM_LANE_G-1 downto 0);
      -- DDR Ports
      ddrClkP         : in    slv(NUM_LANE_G-1 downto 0);
      ddrClkN         : in    slv(NUM_LANE_G-1 downto 0);
      ddrOut          : out   DdrOutArray(NUM_LANE_G-1 downto 0);
      ddrInOut        : inout DdrInOutArray(NUM_LANE_G-1 downto 0));
end MigAll;

architecture mapping of MigAll is

begin

   -----------------
   -- MIG[0] IP Core
   -----------------
   U_Mig0 : entity axi_pcie_core.Mig0
      generic map (
         TPD_G => TPD_G)
      port map (
         extRst         => extRst,
         -- AXI MEM Interface
         axiClk         => axiClk(0),
         axiRst         => axiRst(0),
         axiReady       => axiReady(0),
         axiWriteMaster => axiWriteMasters(0),
         axiWriteSlave  => axiWriteSlaves(0),
         axiReadMaster  => axiReadMasters(0),
         axiReadSlave   => axiReadSlaves(0),
         -- DDR Ports
         ddrClkP        => ddrClkP(0),
         ddrClkN        => ddrClkN(0),
         ddrOut         => ddrOut(0),
         ddrInOut       => ddrInOut(0));

   -----------------
   -- MIG[1] IP Core
   -----------------
   GEN_MIG1 : if (NUM_LANE_G >= 2) generate
      U_Mig1 : entity axi_pcie_core.Mig1
         generic map (
            TPD_G => TPD_G)
         port map (
            extRst         => extRst,
            -- AXI MEM Interface
            axiClk         => axiClk(1),
            axiRst         => axiRst(1),
            axiReady       => axiReady(1),
            axiWriteMaster => axiWriteMasters(1),
            axiWriteSlave  => axiWriteSlaves(1),
            axiReadMaster  => axiReadMasters(1),
            axiReadSlave   => axiReadSlaves(1),
            -- DDR Ports
            ddrClkP        => ddrClkP(1),
            ddrClkN        => ddrClkN(1),
            ddrOut         => ddrOut(1),
            ddrInOut       => ddrInOut(1));
   end generate;

   -----------------
   -- MIG[2] IP Core
   -----------------
   GEN_MIG2 : if (NUM_LANE_G >= 3) generate
      U_Mig2 : entity axi_pcie_core.Mig2
         generic map (
            TPD_G => TPD_G)
         port map (
            extRst         => extRst,
            -- AXI MEM Interface
            axiClk         => axiClk(2),
            axiRst         => axiRst(2),
            axiReady       => axiReady(2),
            axiWriteMaster => axiWriteMasters(2),
            axiWriteSlave  => axiWriteSlaves(2),
            axiReadMaster  => axiReadMasters(2),
            axiReadSlave   => axiReadSlaves(2),
            -- DDR Ports
            ddrClkP        => ddrClkP(2),
            ddrClkN        => ddrClkN(2),
            ddrOut         => ddrOut(2),
            ddrInOut       => ddrInOut(2));
   end generate;

   -----------------
   -- MIG[3] IP Core
   -----------------
   GEN_MIG3 : if (NUM_LANE_G >= 4) generate
      U_Mig3 : entity axi_pcie_core.Mig3
         generic map (
            TPD_G => TPD_G)
         port map (
            extRst         => extRst,
            -- AXI MEM Interface
            axiClk         => axiClk(3),
            axiRst         => axiRst(3),
            axiReady       => axiReady(3),
            axiWriteMaster => axiWriteMasters(3),
            axiWriteSlave  => axiWriteSlaves(3),
            axiReadMaster  => axiReadMasters(3),
            axiReadSlave   => axiReadSlaves(3),
            -- DDR Ports
            ddrClkP        => ddrClkP(3),
            ddrClkN        => ddrClkN(3),
            ddrOut         => ddrOut(3),
            ddrInOut       => ddrInOut(3));
   end generate;

end mapping;
