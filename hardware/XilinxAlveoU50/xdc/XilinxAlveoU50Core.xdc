##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_Core}]

##########
# System #
##########

set_property -dict { PACKAGE_PIN BB18 IOSTANDARD LVDS } [get_ports { userClkP }]; # 156.25 MHz  (TODO: Need to double check this pin mapping)
set_property -dict { PACKAGE_PIN BC18 IOSTANDARD LVDS } [get_ports { userClkN }]; # 156.25 MHz  (TODO: Need to double check this pin mapping)

#######################################
# QSFP ports located in the core area #
#######################################

# set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS12 } [get_ports { qsfpRstL[0] }];
# set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS12 } [get_ports { qsfpLpMode[0] }];
# set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS12 } [get_ports { qsfpModPrsL[0] }];
# set_property -dict { PACKAGE_PIN XXX IOSTANDARD LVCMOS12 } [get_ports { qsfpModSelL[0] }];

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN BE5 [get_ports {pciRxN[15]}]
set_property PACKAGE_PIN BD3 [get_ports {pciRxN[14]}]
set_property PACKAGE_PIN BB3 [get_ports {pciRxN[13]}]
set_property PACKAGE_PIN AY3 [get_ports {pciRxN[12]}]

set_property PACKAGE_PIN BE6 [get_ports {pciRxP[15]}]
set_property PACKAGE_PIN BD4 [get_ports {pciRxP[14]}]
set_property PACKAGE_PIN BB4 [get_ports {pciRxP[13]}]
set_property PACKAGE_PIN AY4 [get_ports {pciRxP[12]}]

set_property PACKAGE_PIN AT8 [get_ports {pciTxN[15]}]
set_property PACKAGE_PIN AR6 [get_ports {pciTxN[14]}]
set_property PACKAGE_PIN AP8 [get_ports {pciTxN[13]}]
set_property PACKAGE_PIN AN6 [get_ports {pciTxN[12]}]

set_property PACKAGE_PIN AT9 [get_ports {pciTxP[15]}]
set_property PACKAGE_PIN AR7 [get_ports {pciTxP[14]}]
set_property PACKAGE_PIN AP9 [get_ports {pciTxP[13]}]
set_property PACKAGE_PIN AN7 [get_ports {pciTxP[12]}]

set_property PACKAGE_PIN BC1 [get_ports {pciRxN[11]}]
set_property PACKAGE_PIN BA1 [get_ports {pciRxN[10]}]
set_property PACKAGE_PIN AW1 [get_ports {pciRxN[9]}]
set_property PACKAGE_PIN AV3 [get_ports {pciRxN[8]}]

set_property PACKAGE_PIN BC2 [get_ports {pciRxP[11]}]
set_property PACKAGE_PIN BA2 [get_ports {pciRxP[10]}]
set_property PACKAGE_PIN AW2 [get_ports {pciRxP[9]}]
set_property PACKAGE_PIN AV4 [get_ports {pciRxP[8]}]

set_property PACKAGE_PIN AM8 [get_ports {pciTxN[11]}]
set_property PACKAGE_PIN AL6 [get_ports {pciTxN[10]}]
set_property PACKAGE_PIN AJ6 [get_ports {pciTxN[9]}]
set_property PACKAGE_PIN AG6 [get_ports {pciTxN[8]}]

set_property PACKAGE_PIN AM9 [get_ports {pciTxP[11]}]
set_property PACKAGE_PIN AL7 [get_ports {pciTxP[10]}]
set_property PACKAGE_PIN AJ7 [get_ports {pciTxP[9]}]
set_property PACKAGE_PIN AG7 [get_ports {pciTxP[8]}]

set_property PACKAGE_PIN AU1 [get_ports {pciRxN[7]}]
set_property PACKAGE_PIN AT3 [get_ports {pciRxN[6]}]
set_property PACKAGE_PIN AR1 [get_ports {pciRxN[5]}]
set_property PACKAGE_PIN AP3 [get_ports {pciRxN[4]}]

set_property PACKAGE_PIN AU2 [get_ports {pciRxP[7]}]
set_property PACKAGE_PIN AT4 [get_ports {pciRxP[6]}]
set_property PACKAGE_PIN AR2 [get_ports {pciRxP[5]}]
set_property PACKAGE_PIN AP4 [get_ports {pciRxP[4]}]

set_property PACKAGE_PIN AH4 [get_ports {pciTxN[7]}]
set_property PACKAGE_PIN AE6 [get_ports {pciTxN[6]}]
set_property PACKAGE_PIN AF4 [get_ports {pciTxN[5]}]
set_property PACKAGE_PIN AD4 [get_ports {pciTxN[4]}]

set_property PACKAGE_PIN AH5 [get_ports {pciTxP[7]}]
set_property PACKAGE_PIN AE7 [get_ports {pciTxP[6]}]
set_property PACKAGE_PIN AF5 [get_ports {pciTxP[5]}]
set_property PACKAGE_PIN AD5 [get_ports {pciTxP[4]}]

set_property PACKAGE_PIN AN1 [get_ports {pciRxN[3]}]
set_property PACKAGE_PIN AK3 [get_ports {pciRxN[2]}]
set_property PACKAGE_PIN AM3 [get_ports {pciRxN[1]}]
set_property PACKAGE_PIN AL1 [get_ports {pciRxN[0]}]

set_property PACKAGE_PIN AN2 [get_ports {pciRxP[3]}]
set_property PACKAGE_PIN AK4 [get_ports {pciRxP[2]}]
set_property PACKAGE_PIN AM4 [get_ports {pciRxP[1]}]
set_property PACKAGE_PIN AL2 [get_ports {pciRxP[0]}]

set_property PACKAGE_PIN AC6 [get_ports {pciTxN[3]}]
set_property PACKAGE_PIN AB4 [get_ports {pciTxN[2]}]
set_property PACKAGE_PIN AA6 [get_ports {pciTxN[1]}]
set_property PACKAGE_PIN Y4  [get_ports {pciTxN[0]}]

set_property PACKAGE_PIN AC7 [get_ports {pciTxP[3]}]
set_property PACKAGE_PIN AB5 [get_ports {pciTxP[2]}]
set_property PACKAGE_PIN AA7 [get_ports {pciTxP[1]}]
set_property PACKAGE_PIN Y5  [get_ports {pciTxP[0]}]

set_property PACKAGE_PIN AF9 [get_ports {pciRefClkP[0]}]; # 100 MHz
set_property PACKAGE_PIN AF8 [get_ports {pciRefClkN[0]}]; # 100 MHz

set_property PACKAGE_PIN AB9 [get_ports {pciRefClkP[1]}]; # 100 MHz (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN AB8 [get_ports {pciRefClkN[1]}]; # 100 MHz (TODO: Need to double check this pin mapping)

set_property -dict { PACKAGE_PIN AW27 IOSTANDARD POD12 } [get_ports {pciRstL}]
set_false_path -from [get_ports pciRstL]
set_property PULLUP true [get_ports pciRstL]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClk0 [get_ports {pciRefClkP[0]}]
create_clock -period 10.000 -name pciRefClk1 [get_ports {pciRefClkP[1]}]
create_clock -period  6.400 -name userClkP   [get_ports {userClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk0}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk1}] -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks dnaClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks iprogClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks -of_objects [get_pins U_axilClk/PllGen.U_Pll/CLKOUT0]]

set_false_path -to [get_pins -hier *sync_reg[0]/D]

set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/axiClk}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

# ------------------------------------------------------------------------
# https://www.xilinx.com/Attachment/u200_bitstream_constraints.xdc
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable    [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes       [current_design]
# ------------------------------------------------------------------------
