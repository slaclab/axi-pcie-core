-------------------------------------------------------------------------------
-- File       : AxiPcieCrossbarIpCoreWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI DMA Crossbar IP Core Wrapper
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

entity AxiPcieCrossbarIpCoreWrapper is
   generic (
      TPD_G             : time := 1 ns;
      AXI_PCIE_CONFIG_G : AxiConfigType;
      DMA_SIZE_G        : positive range 1 to 8 := 1); 
   port (
      -- Clock and reset
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- Slaves
      sAxiWriteMasters : in  AxiWriteMasterArray(9 downto 0);
      sAxiWriteSlaves  : out AxiWriteSlaveArray(9 downto 0);
      sAxiReadMasters  : in  AxiReadMasterArray(9 downto 0);
      sAxiReadSlaves   : out AxiReadSlaveArray(9 downto 0);
      -- Master
      mAxiWriteMaster  : out AxiWriteMasterType;
      mAxiWriteSlave   : in  AxiWriteSlaveType;
      mAxiReadMaster   : out AxiReadMasterType;
      mAxiReadSlave    : in  AxiReadSlaveType);
end AxiPcieCrossbarIpCoreWrapper;

architecture mapping of AxiPcieCrossbarIpCoreWrapper is

begin

   XBAR_16B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 16) generate
      U_AxiXbar : entity axi_pcie_core.AxiPcie16BCrossbarIpCoreWrapper
         generic map(
            TPD_G             => TPD_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G,
            DMA_SIZE_G        => DMA_SIZE_G)
         port map(
            -- Clock and reset
            axiClk           => axiClk,
            axiRst           => axiRst,
            -- Slaves
            sAxiWriteMasters => sAxiWriteMasters,
            sAxiWriteSlaves  => sAxiWriteSlaves,
            sAxiReadMasters  => sAxiReadMasters,
            sAxiReadSlaves   => sAxiReadSlaves,
            -- Master
            mAxiWriteMaster  => mAxiWriteMaster,
            mAxiWriteSlave   => mAxiWriteSlave,
            mAxiReadMaster   => mAxiReadMaster,
            mAxiReadSlave    => mAxiReadSlave);
   end generate;

   XBAR_32B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 32) generate
      U_AxiXbar : entity axi_pcie_core.AxiPcie32BCrossbarIpCoreWrapper
         generic map(
            TPD_G             => TPD_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G,
            DMA_SIZE_G        => DMA_SIZE_G)
         port map(
            -- Clock and reset
            axiClk           => axiClk,
            axiRst           => axiRst,
            -- Slaves
            sAxiWriteMasters => sAxiWriteMasters,
            sAxiWriteSlaves  => sAxiWriteSlaves,
            sAxiReadMasters  => sAxiReadMasters,
            sAxiReadSlaves   => sAxiReadSlaves,
            -- Master
            mAxiWriteMaster  => mAxiWriteMaster,
            mAxiWriteSlave   => mAxiWriteSlave,
            mAxiReadMaster   => mAxiReadMaster,
            mAxiReadSlave    => mAxiReadSlave);
   end generate;

   XBAR_64B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 64) generate
      U_AxiXbar : entity axi_pcie_core.AxiPcie64BCrossbarIpCoreWrapper
         generic map(
            TPD_G             => TPD_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G,
            DMA_SIZE_G        => DMA_SIZE_G)
         port map(
            -- Clock and reset
            axiClk           => axiClk,
            axiRst           => axiRst,
            -- Slaves
            sAxiWriteMasters => sAxiWriteMasters,
            sAxiWriteSlaves  => sAxiWriteSlaves,
            sAxiReadMasters  => sAxiReadMasters,
            sAxiReadSlaves   => sAxiReadSlaves,
            -- Master
            mAxiWriteMaster  => mAxiWriteMaster,
            mAxiWriteSlave   => mAxiWriteSlave,
            mAxiReadMaster   => mAxiReadMaster,
            mAxiReadSlave    => mAxiReadSlave);
   end generate;

end mapping;
