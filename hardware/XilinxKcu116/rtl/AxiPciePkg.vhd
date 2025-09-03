-------------------------------------------------------------------------------
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiPkg.all;

package AxiPciePkg is

   -- System Clock Frequency
   constant DMA_CLK_FREQ_C : real := 250.0E+6;  -- units of Hz

   -- PCIE PHY AXI Configuration
   constant AXI_PCIE_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 64,               -- 64-bit address interface
      DATA_BYTES_C => 32,               -- 256-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 DMA IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface

end package AxiPciePkg;
