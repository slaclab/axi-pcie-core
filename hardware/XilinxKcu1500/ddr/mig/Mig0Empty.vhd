-------------------------------------------------------------------------------
-- File       : Mig0.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-08-10
-- Last update: 2017-08-10
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiPciePkg.all;

entity Mig0 is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- System Clock and reset
      sysClk          : in    sl;
      sysRst          : in    sl;
      -- AXI MEM Interface (sysClk domain)
      axiReady        : out   sl;
      axiWriteMasters : in    AxiWriteMasterArray(3 downto 0);
      axiWriteSlaves  : out   AxiWriteSlaveArray(3 downto 0);
      axiReadMasters  : in    AxiReadMasterArray(3 downto 0);
      axiReadSlaves   : out   AxiReadSlaveArray(3 downto 0);
      -- DDR Ports
      ddrClkP         : in    sl;
      ddrClkN         : in    sl;
      ddrOut          : out   DdrOutType;
      ddrInOut        : inout DdrInOutType);
end Mig0;

architecture mapping of Mig0 is

begin

   axiReady       <= '0';
   axiWriteSlaves <= (others => AXI_WRITE_SLAVE_FORCE_C);
   axiReadSlaves  <= (others => AXI_READ_SLAVE_FORCE_C);
   ddrOut         <= DDR_OUT_INIT_C;

end mapping;
