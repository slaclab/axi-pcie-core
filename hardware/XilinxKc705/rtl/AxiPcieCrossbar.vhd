-------------------------------------------------------------------------------
-- File       : AxiPcieCrossbar.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI DMA Crossbar
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;

entity AxiPcieCrossbar is
   generic (
      TPD_G             : time                  := 1 ns;
      AXI_DESC_CONFIG_G : AxiConfigType;
      AXI_DMA_CONFIG_G  : AxiConfigType;
      AXI_PCIE_CONFIG_G : AxiConfigType;
      DMA_SIZE_G        : positive range 1 to 8 := 1);
   port (
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- Slaves
      sAxiWriteMasters : in  AxiWriteMasterArray(DMA_SIZE_G downto 0);
      sAxiWriteSlaves  : out AxiWriteSlaveArray(DMA_SIZE_G downto 0);
      sAxiReadMasters  : in  AxiReadMasterArray(DMA_SIZE_G downto 0);
      sAxiReadSlaves   : out AxiReadSlaveArray(DMA_SIZE_G downto 0);
      -- Master
      mAxiWriteMaster  : out AxiWriteMasterType;
      mAxiWriteSlave   : in  AxiWriteSlaveType;
      mAxiReadMaster   : out AxiReadMasterType;
      mAxiReadSlave    : in  AxiReadSlaveType);
end AxiPcieCrossbar;

architecture mapping of AxiPcieCrossbar is

   signal axiWriteMasters : AxiWriteMasterArray(8 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(8 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal axiReadMasters  : AxiReadMasterArray(8 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(8 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

begin

   GEN_VEC : for i in DMA_SIZE_G downto 0 generate
      axiWriteMasters(i) <= sAxiWriteMasters(i);
      sAxiWriteSlaves(i) <= axiWriteSlaves(i);
      axiReadMasters(i)  <= sAxiReadMasters(i);
      sAxiReadSlaves(i)  <= axiReadSlaves(i);
   end generate;

   -------------------
   -- AXI XBAR IP Core
   -------------------
   U_AxiXbar : entity work.AxiPcieCrossbarIpCoreWrapper
      generic map(
         TPD_G             => TPD_G,
         AXI_DESC_CONFIG_G => AXI_DESC_CONFIG_G,
         AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_G)
      port map(
         -- Clock and reset
         axiClk           => axiClk,
         axiRst           => axiRst,
         -- Slaves
         sAxiWriteMasters => axiWriteMasters,
         sAxiWriteSlaves  => axiWriteSlaves,
         sAxiReadMasters  => axiReadMasters,
         sAxiReadSlaves   => axiReadSlaves,
         -- Master
         mAxiWriteMaster  => mAxiWriteMaster,
         mAxiWriteSlave   => mAxiWriteSlave,
         mAxiReadMaster   => mAxiReadMaster,
         mAxiReadSlave    => mAxiReadSlave);

end mapping;
