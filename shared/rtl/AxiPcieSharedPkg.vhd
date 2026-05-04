-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Shared Package file for AXI PCIe Core
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;

package AxiPcieSharedPkg is

   -- List of PCIe Hardware Types
   constant HW_TYPE_UNDEFINED_C              : slv(31 downto 0) := x"00_00_00_00";
   constant HW_TYPE_ALPHADATA_KU3_C          : slv(31 downto 0) := x"00_00_00_01";
   constant HW_TYPE_BITTWARE_XUP_VV8_VU13P_C : slv(31 downto 0) := x"00_00_00_02";
   constant HW_TYPE_SLAC_PGP_GEN3_C          : slv(31 downto 0) := x"00_00_00_03";
   constant HW_TYPE_SLAC_PGP_GEN4_C          : slv(31 downto 0) := x"00_00_00_04";
   constant HW_TYPE_XILINX_AC701_C           : slv(31 downto 0) := x"00_00_00_05";
   constant HW_TYPE_XILINX_U50_C             : slv(31 downto 0) := x"00_00_00_06";
   constant HW_TYPE_XILINX_U200_C            : slv(31 downto 0) := x"00_00_00_07";
   constant HW_TYPE_XILINX_U250_C            : slv(31 downto 0) := x"00_00_00_08";
   constant HW_TYPE_XILINX_U280_C            : slv(31 downto 0) := x"00_00_00_09";
   constant HW_TYPE_XILINX_KC705_C           : slv(31 downto 0) := x"00_00_00_0A";
   constant HW_TYPE_XILINX_KCU105_C          : slv(31 downto 0) := x"00_00_00_0B";
   constant HW_TYPE_XILINX_KCU116_C          : slv(31 downto 0) := x"00_00_00_0C";
   constant HW_TYPE_XILINX_KCU1500_C         : slv(31 downto 0) := x"00_00_00_0D";
   constant HW_TYPE_XILINX_KCU1500_EXT_C     : slv(31 downto 0) := x"00_00_10_0D";
   constant HW_TYPE_XILINX_VCU128_C          : slv(31 downto 0) := x"00_00_00_0E";
   constant HW_TYPE_XILINX_U55C_C            : slv(31 downto 0) := x"00_00_00_0F";
   constant HW_TYPE_XILINX_C1100_C           : slv(31 downto 0) := x"00_00_00_10";
   constant HW_TYPE_XILINX_C1100_EXT_C       : slv(31 downto 0) := x"00_00_10_10";
   constant HW_TYPE_ABACO_PC821_KU085_C      : slv(31 downto 0) := x"00_00_00_11";
   constant HW_TYPE_ABACO_PC821_KU115_C      : slv(31 downto 0) := x"00_00_00_12";
   constant HW_TYPE_BITTWARE_XUP_VV8_VU9P_C  : slv(31 downto 0) := x"00_00_00_13";

end package AxiPcieSharedPkg;
