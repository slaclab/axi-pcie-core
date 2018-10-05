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
      TPD_G               : time                  := 1 ns;
      SLAVE_AXI_CONFIG_G  : AxiConfigType;
      MASTER_AXI_CONFIG_G : AxiConfigType;
      DMA_SIZE_G          : positive range 1 to 8 := 1);
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

   signal axiWriteMasters : AxiWriteMasterArray(DMA_SIZE_G downto 0);
   signal axiWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G downto 0);
   signal axiReadMasters  : AxiReadMasterArray(DMA_SIZE_G downto 0);
   signal axiReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G downto 0);

begin

   -- AxiStreamDmaV2Desc.vhd does burst transfers only (64-bit or wider)
   axiReadMasters(0)  <= sAxiReadMasters(0);
   sAxiReadSlaves(0)  <= axiReadSlaves(0);
   axiWriteMasters(0) <= sAxiWriteMasters(0);
   sAxiWriteSlaves(0) <= axiWriteSlaves(0);   

   GEN_VEC : for i in DMA_SIZE_G downto 1 generate
      U_AxiResize : entity work.AxiResize
         generic map(
            TPD_G               => TPD_G,
            SLAVE_AXI_CONFIG_G  => SLAVE_AXI_CONFIG_G,
            MASTER_AXI_CONFIG_G => MASTER_AXI_CONFIG_G)
         port map(
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slave Port
            sAxiReadMaster  => sAxiReadMasters(i),
            sAxiReadSlave   => sAxiReadSlaves(i),
            sAxiWriteMaster => sAxiWriteMasters(i),
            sAxiWriteSlave  => sAxiWriteSlaves(i),
            -- Master Port
            mAxiReadMaster  => axiReadMasters(i),
            mAxiReadSlave   => axiReadSlaves(i),
            mAxiWriteMaster => axiWriteMasters(i),
            mAxiWriteSlave  => axiWriteSlaves(i));
   end generate;

   --------------------
   -- AXI Read Path MUX
   --------------------
   U_AxiReadPathMux : entity work.AxiReadPathMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => (DMA_SIZE_G+1))
      port map (
         -- Clock and reset
         axiClk          => axiClk,
         axiRst          => axiRst,
         -- Slaves
         sAxiReadMasters => axiReadMasters,
         sAxiReadSlaves  => axiReadSlaves,
         -- Master
         mAxiReadMaster  => mAxiReadMaster,
         mAxiReadSlave   => mAxiReadSlave);

   -----------------------
   -- AXI Write Path DEMUX
   -----------------------
   U_AxiWritePathMux : entity work.AxiWritePathMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => (DMA_SIZE_G+1))
      port map (
         -- Clock and reset
         axiClk           => axiClk,
         axiRst           => axiRst,
         -- Slaves
         sAxiWriteMasters => axiWriteMasters,
         sAxiWriteSlaves  => axiWriteSlaves,
         -- Master
         mAxiWriteMaster  => mAxiWriteMaster,
         mAxiWriteSlave   => mAxiWriteSlave);

end mapping;
