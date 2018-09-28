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

   constant TPD_C : time := 1 ns;

   -- Application BAR0 address space   
   constant BAR0_BASE_ADDR_C  : slv(31 downto 0) := x"0080_0000";
   constant BAR0_HIGH_ADDR_C  : slv(31 downto 0) := x"00FF_FFFF";
   constant BAR0_ERROR_RESP_C : slv(1 downto 0)  := AXI_RESP_OK_C;  -- Always return OK to a MMAP() 

   -- System Clock Frequency
   constant SYS_CLK_FREQ_C : real := 250.0E+6;  -- units of Hz

   -- DMA AXI Stream Configuration
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 16,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   -- DMA AXI Configuration   
   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 48,               -- 48-bit address interface
      DATA_BYTES_C => DMA_AXIS_CONFIG_C.TDATA_BYTES_C,  -- 128-bit data interface (matches the AXIS stream)
      ID_BITS_C    => 4,                -- Up to 16 DMA IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface         

   -- PCIE PHY AXI Configuration   
   constant PCIE_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 48,               -- 48-bit address interface
      DATA_BYTES_C => 64,               -- 512-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 DMA IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface      

   -- DDR MEM AXI Configuration
   constant MEM_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 34,               -- 16GB per MIG interface (16GB total)
      DATA_BYTES_C => 64,               -- 512-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface  

   -- APP MEM AXI Configuration
   constant APP_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 34,               -- 16GB per MIG interface (16GB total)
      DATA_BYTES_C => 16,               -- 128-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface        

   -- DDR Port Types
   type DdrOutType is record
      addr   : slv(16 downto 0);
      ba     : slv(1 downto 0);
      cke    : slv(0 downto 0);
      csL    : slv(0 downto 0);
      odt    : slv(0 downto 0);
      bg     : slv(1 downto 0);
      rstL   : sl;
      actL   : sl;
      parity : sl;
      ckC    : slv(0 downto 0);
      ckT    : slv(0 downto 0);
   end record DdrOutType;
   type DdrOutArray is array (natural range<>) of DdrOutType;

   type DdrInOutType is record
      dq   : slv(71 downto 0);
      dqsC : slv(17 downto 0);
      dqsT : slv(17 downto 0);
   end record DdrInOutType;
   type DdrInOutArray is array (natural range<>) of DdrInOutType;

end package AxiPciePkg;
