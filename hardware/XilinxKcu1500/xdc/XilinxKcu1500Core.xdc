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

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN BF27 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]
set_property -dict { PACKAGE_PIN AM26 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }]
set_property -dict { PACKAGE_PIN AN26 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }]
set_property -dict { PACKAGE_PIN AM25 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]
set_property -dict { PACKAGE_PIN AL25 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]

set_property -dict { PACKAGE_PIN AL27 IOSTANDARD LVCMOS18 } [get_ports { emcClk }]
set_property LOC CONFIG_SITE_X0Y0        [get_cells {U_Core/U_STARTUPE3}]

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN BC2 [get_ports {pciRxP[7]}]
set_property PACKAGE_PIN BC1 [get_ports {pciRxN[7]}]
set_property PACKAGE_PIN BF5 [get_ports {pciTxP[7]}]
set_property PACKAGE_PIN BF4 [get_ports {pciTxN[7]}]
set_property PACKAGE_PIN BA2 [get_ports {pciRxP[6]}]
set_property PACKAGE_PIN BA1 [get_ports {pciRxN[6]}]
set_property PACKAGE_PIN BD5 [get_ports {pciTxP[6]}]
set_property PACKAGE_PIN BD4 [get_ports {pciTxN[6]}]
set_property PACKAGE_PIN AW4 [get_ports {pciRxP[5]}]
set_property PACKAGE_PIN AW3 [get_ports {pciRxN[5]}]
set_property PACKAGE_PIN BB5 [get_ports {pciTxP[5]}]
set_property PACKAGE_PIN BB4 [get_ports {pciTxN[5]}]
set_property PACKAGE_PIN AV2 [get_ports {pciRxP[4]}]
set_property PACKAGE_PIN AV1 [get_ports {pciRxN[4]}]
set_property PACKAGE_PIN AV7 [get_ports {pciTxP[4]}]
set_property PACKAGE_PIN AV6 [get_ports {pciTxN[4]}]
set_property PACKAGE_PIN AU4 [get_ports {pciRxP[3]}]
set_property PACKAGE_PIN AU3 [get_ports {pciRxN[3]}]
set_property PACKAGE_PIN AU9 [get_ports {pciTxP[3]}]
set_property PACKAGE_PIN AU8 [get_ports {pciTxN[3]}]
set_property PACKAGE_PIN AT2 [get_ports {pciRxP[2]}]
set_property PACKAGE_PIN AT1 [get_ports {pciRxN[2]}]
set_property PACKAGE_PIN AT7 [get_ports {pciTxP[2]}]
set_property PACKAGE_PIN AT6 [get_ports {pciTxN[2]}]
set_property PACKAGE_PIN AR4 [get_ports {pciRxP[1]}]
set_property PACKAGE_PIN AR3 [get_ports {pciRxN[1]}]
set_property PACKAGE_PIN AR9 [get_ports {pciTxP[1]}]
set_property PACKAGE_PIN AR8 [get_ports {pciTxN[1]}]
set_property PACKAGE_PIN AP2 [get_ports {pciRxP[0]}]
set_property PACKAGE_PIN AP1 [get_ports {pciRxN[0]}]
set_property PACKAGE_PIN AP7 [get_ports {pciTxP[0]}]
set_property PACKAGE_PIN AP6 [get_ports {pciTxN[0]}]

set_property PACKAGE_PIN AT11 [get_ports {pciRefClkP}]; # 100 MHz
set_property PACKAGE_PIN AT10 [get_ports {pciRefClkN}]; # 100 MHz

set_property -dict { PACKAGE_PIN AR26 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]

##########
# System #
##########

set_property -dict { PACKAGE_PIN AV24  IOSTANDARD LVDS_25 } [get_ports { userClkP }]; # 156.25 MHz
set_property -dict { PACKAGE_PIN AW24  IOSTANDARD LVDS_25 } [get_ports { userClkN }]; # 156.25 MHz

##########################################
# QSFP[0] ports located in the core area #
##########################################

set_property -dict { PACKAGE_PIN AM21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0RstL }];
set_property -dict { PACKAGE_PIN AM22  IOSTANDARD LVCMOS18 } [get_ports { qsfp0LpMode }];
set_property -dict { PACKAGE_PIN AP21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0ModPrsL }];
set_property -dict { PACKAGE_PIN AL21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0ModSelL }];

##########################################
# QSFP[1] ports located in the core area #
##########################################

set_property -dict { PACKAGE_PIN AU24  IOSTANDARD LVCMOS18 } [get_ports { qsfp1RstL }];
set_property -dict { PACKAGE_PIN AR22  IOSTANDARD LVCMOS18 } [get_ports { qsfp1LpMode }];
set_property -dict { PACKAGE_PIN AR23  IOSTANDARD LVCMOS18 } [get_ports { qsfp1ModPrsL }];
set_property -dict { PACKAGE_PIN AT24  IOSTANDARD LVCMOS18 } [get_ports { qsfp1ModSelL }];

##########
# Clocks #
##########

create_clock -period  6.400 -name userClkP   [get_ports {userClkP}]
create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks {dnaClk}] -group [get_clocks {iprogClk}]

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/CLK_USERCLK}]

######################################
# BITSTREAM: .bit file Configuration #
######################################
set_property CONFIG_VOLTAGE 1.8                      [current_design]
set_property CFGBVS GND                              [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE         [current_design]
set_property CONFIG_MODE SPIx8                       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8         [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup       [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes     [current_design]
set_property BITSTREAM.STARTUP.LCK_CYCLE NoWait      [current_design]
set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait    [current_design]
