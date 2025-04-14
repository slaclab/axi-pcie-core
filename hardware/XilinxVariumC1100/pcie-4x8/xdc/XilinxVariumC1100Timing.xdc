##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -period 10.000 -name pciRefClk0 [get_ports {pciRefClkP[0]}]
create_clock -period 10.000 -name pciRefClk1 [get_ports {pciRefClkP[1]}]
create_clock -period 10.000 -name userClkP   [get_ports {userClkP}]
create_clock -period 10.000 -name hbmRefClkP [get_ports {hbmRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 20.000 -name cmsClk     [get_pins  {U_Core/REAL_PCIE.U_CMS/U_Bufg/O}]

create_clock -period 6.4 -name qsfp0RefClkP [get_ports {qsfp0RefClkP}] ;# SI5394_INIT_FILE_G="Si5394A_GT_REFCLK_156MHz.mem"
create_clock -period 6.4 -name qsfp1RefClkP [get_ports {qsfp1RefClkP}] ;# SI5394_INIT_FILE_G="Si5394A_GT_REFCLK_156MHz.mem"

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk0}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk0}] -group [get_clocks -include_generated_clocks {cmsClk}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk1}] -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous -group [get_clocks pciRefClk0] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk2/O]]
set_clock_groups -asynchronous -group [get_clocks pciRefClk1] -group [get_clocks -of_objects [get_pins U_ExtendedCore/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100ExtendedPciePhy_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk2/O]]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {qsfp0RefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfp1RefClkP}] \
   -group [get_clocks -include_generated_clocks {pciRefClk0}] \
   -group [get_clocks -include_generated_clocks {pciRefClk1}] \
   -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous  -group [get_clocks hbmRefClkP] -group [get_clocks -include_generated_clocks {pciRefClk0}]
set_clock_groups -asynchronous  -group [get_clocks hbmRefClkP] -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks dnaClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks iprogClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks -of_objects [get_pins U_axilClk/PllGen.U_Pll/CLKOUT0]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks dnaClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks iprogClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/XilinxVariumC1100PciePhyGen4x8_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks -of_objects [get_pins U_axilClk/PllGen.U_Pll/CLKOUT0]

set_false_path -to [get_pins -hier *sync_reg[0]/D]

set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/axiClk}]

connect_debug_port dbg_hub/clk [get_nets {hbmRefClk}]
