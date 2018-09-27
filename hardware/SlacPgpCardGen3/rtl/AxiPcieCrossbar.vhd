-------------------------------------------------------------------------------
-- File       : AxiPcieCrossbar.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-02-14
-- Last update: 2016-02-14
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
      TPD_G : time := 1 ns;
      DMA_SIZE_G       : positive range 1 to 16 := 1);
   port (
      -- Clock and Reset
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- Slaves
      sAxiWriteMasters : in  AxiWriteMasterArray(16 downto 0);
      sAxiWriteSlaves  : out AxiWriteSlaveArray(16 downto 0);
      sAxiReadMasters  : in  AxiReadMasterArray(16 downto 0);
      sAxiReadSlaves   : out AxiReadSlaveArray(16 downto 0);
      -- Master
      mAxiWriteMaster  : out AxiWriteMasterType;
      mAxiWriteSlave   : in  AxiWriteSlaveType;
      mAxiReadMaster   : out AxiReadMasterType;
      mAxiReadSlave    : in  AxiReadSlaveType);      
end AxiPcieCrossbar;

architecture mapping of AxiPcieCrossbar is

begin

   TERM_UNUSED : if (DMA_SIZE_G /= 16) generate
      GEN_VEC : for i in 16 downto DMA_SIZE_G+1 generate
         sAxiWriteSlaves(i) <= AXI_WRITE_SLAVE_FORCE_C;
         sAxiReadSlaves(i)  <= AXI_READ_SLAVE_FORCE_C;
      end generate;
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
         sAxiReadMasters => sAxiReadMasters(DMA_SIZE_G downto 0),
         sAxiReadSlaves  => sAxiReadSlaves(DMA_SIZE_G downto 0),
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
         sAxiWriteMasters => sAxiWriteMasters(DMA_SIZE_G downto 0),
         sAxiWriteSlaves  => sAxiWriteSlaves(DMA_SIZE_G downto 0),
         -- Master
         mAxiWriteMaster  => mAxiWriteMaster,
         mAxiWriteSlave   => mAxiWriteSlave);

end mapping;
