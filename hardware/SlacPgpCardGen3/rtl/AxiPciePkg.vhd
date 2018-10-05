-------------------------------------------------------------------------------
-- File       : AxiPciePkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Package file for AXI PCIe Core
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
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

package AxiPciePkg is

   -- Application BAR0 address space
   constant BAR0_BASE_ADDR_C : slv(31 downto 0) := x"0008_0000";
   constant BAR0_HIGH_ADDR_C : slv(31 downto 0) := x"00FF_FFFF";

   -- System Clock Frequency
   constant DMA_CLK_FREQ_C : real := 125.0E+6;  -- units of Hz

   -- PCIE PHY AXI Configuration   
   constant PCIE_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 48,               -- 48-bit address interface
      DATA_BYTES_C => 16,               -- Match the AXIS stream
      ID_BITS_C    => 4,                -- Up to 32 DMA IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface      

end package AxiPciePkg;
