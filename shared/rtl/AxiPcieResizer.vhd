-------------------------------------------------------------------------------
-- File       : AxiPcieCrossbar.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI Resizer
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

entity AxiPcieResizer is
   generic (
      TPD_G             : time := 1 ns;
      AXI_DMA_CONFIG_G  : AxiConfigType;
      AXI_PCIE_CONFIG_G : AxiConfigType);
   port (
      axiClk          : in  sl;
      axiRst          : in  sl;
      -- Slaves
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      sAxiReadMaster  : in  AxiReadMasterType;
      sAxiReadSlave   : out AxiReadSlaveType;
      -- Master
      mAxiWriteMaster : out AxiWriteMasterType;
      mAxiWriteSlave  : in  AxiWriteSlaveType;
      mAxiReadMaster  : out AxiReadMasterType;
      mAxiReadSlave   : in  AxiReadSlaveType);
end AxiPcieResizer;

architecture mapping of AxiPcieResizer is

begin

   RESIZE_16B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 16) generate
      U_AxiResize : entity work.AxiPcie16BResize
         generic map(
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => AXI_DMA_CONFIG_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G)
         port map(
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slave Port
            sAxiReadMaster  => sAxiReadMaster,
            sAxiReadSlave   => sAxiReadSlave,
            sAxiWriteMaster => sAxiWriteMaster,
            sAxiWriteSlave  => sAxiWriteSlave,
            -- Master Port
            mAxiReadMaster  => mAxiReadMaster,
            mAxiReadSlave   => mAxiReadSlave,
            mAxiWriteMaster => mAxiWriteMaster,
            mAxiWriteSlave  => mAxiWriteSlave);
   end generate;

   RESIZE_32B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 32) generate
      U_AxiResize : entity work.AxiPcie32BResize
         generic map(
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => AXI_DMA_CONFIG_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G)
         port map(
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slave Port
            sAxiReadMaster  => sAxiReadMaster,
            sAxiReadSlave   => sAxiReadSlave,
            sAxiWriteMaster => sAxiWriteMaster,
            sAxiWriteSlave  => sAxiWriteSlave,
            -- Master Port
            mAxiReadMaster  => mAxiReadMaster,
            mAxiReadSlave   => mAxiReadSlave,
            mAxiWriteMaster => mAxiWriteMaster,
            mAxiWriteSlave  => mAxiWriteSlave);
   end generate;

   RESIZE_64B : if (AXI_PCIE_CONFIG_G.DATA_BYTES_C = 64) generate
      U_AxiResize : entity work.AxiPcie64BResize
         generic map(
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => AXI_DMA_CONFIG_G,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G)
         port map(
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slave Port
            sAxiReadMaster  => sAxiReadMaster,
            sAxiReadSlave   => sAxiReadSlave,
            sAxiWriteMaster => sAxiWriteMaster,
            sAxiWriteSlave  => sAxiWriteSlave,
            -- Master Port
            mAxiReadMaster  => mAxiReadMaster,
            mAxiReadSlave   => mAxiReadSlave,
            mAxiWriteMaster => mAxiWriteMaster,
            mAxiWriteSlave  => mAxiWriteSlave);
   end generate;

end mapping;
