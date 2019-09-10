##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_Core}]

##########
# System #
##########

set_property -dict { PACKAGE_PIN AU19  IOSTANDARD DIFF_SSTL12 } [get_ports { userClkP }]; # 156.25 MHz
set_property -dict { PACKAGE_PIN AV19  IOSTANDARD DIFF_SSTL12 } [get_ports { userClkN }]; # 156.25 MHz

##########################################
# QSFP[0] ports located in the core area #
##########################################

set_property -dict { PACKAGE_PIN AT20 IOSTANDARD LVCMOS12 } [get_ports { qsfpFs[0][0] }];
set_property -dict { PACKAGE_PIN AU22 IOSTANDARD LVCMOS12 } [get_ports { qsfpFs[0][1] }];
set_property -dict { PACKAGE_PIN AT22 IOSTANDARD LVCMOS12 } [get_ports { qsfpRefClkRst[0] }];
set_property -dict { PACKAGE_PIN BE17 IOSTANDARD LVCMOS12 } [get_ports { qsfpRstL[0] }];
set_property -dict { PACKAGE_PIN BD18 IOSTANDARD LVCMOS12 } [get_ports { qsfpLpMode[0] }];
set_property -dict { PACKAGE_PIN BE20 IOSTANDARD LVCMOS12 } [get_ports { qsfpModPrsL[0] }];
set_property -dict { PACKAGE_PIN BE16 IOSTANDARD LVCMOS12 } [get_ports { qsfpModSelL[0] }];

##########################################
# QSFP[1] ports located in the core area #
##########################################

set_property -dict { PACKAGE_PIN AR22 IOSTANDARD LVCMOS12 } [get_ports { qsfpFs[1][0] }];
set_property -dict { PACKAGE_PIN AU20 IOSTANDARD LVCMOS12 } [get_ports { qsfpFs[1][1] }];
set_property -dict { PACKAGE_PIN AR21 IOSTANDARD LVCMOS12 } [get_ports { qsfpRefClkRst[1] }];
set_property -dict { PACKAGE_PIN BC18 IOSTANDARD LVCMOS12 } [get_ports { qsfpRstL[1] }];
set_property -dict { PACKAGE_PIN AV22 IOSTANDARD LVCMOS12 } [get_ports { qsfpLpMode[1] }];
set_property -dict { PACKAGE_PIN BC19 IOSTANDARD LVCMOS12 } [get_ports { qsfpModPrsL[1] }];
set_property -dict { PACKAGE_PIN AY20 IOSTANDARD LVCMOS12 } [get_ports { qsfpModSelL[1] }];

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN BC1 [get_ports {pciRxN[15]}]

set_property PACKAGE_PIN BA1 [get_ports {pciRxN[14]}]

set_property PACKAGE_PIN AW3 [get_ports {pciRxN[13]}]

set_property PACKAGE_PIN AV1 [get_ports {pciRxN[12]}]

set_property PACKAGE_PIN BC2 [get_ports {pciRxP[15]}]

set_property PACKAGE_PIN BA2 [get_ports {pciRxP[14]}]

set_property PACKAGE_PIN AW4 [get_ports {pciRxP[13]}]

set_property PACKAGE_PIN AV2 [get_ports {pciRxP[12]}]

set_property PACKAGE_PIN BF4 [get_ports {pciTxN[15]}]

set_property PACKAGE_PIN BD4 [get_ports {pciTxN[14]}]

set_property PACKAGE_PIN BB4 [get_ports {pciTxN[13]}]

set_property PACKAGE_PIN AV6 [get_ports {pciTxN[12]}]

set_property PACKAGE_PIN BF5 [get_ports {pciTxP[15]}]

set_property PACKAGE_PIN BD5 [get_ports {pciTxP[14]}]

set_property PACKAGE_PIN BB5 [get_ports {pciTxP[13]}]

set_property PACKAGE_PIN AV7 [get_ports {pciTxP[12]}]

set_property PACKAGE_PIN AU3 [get_ports {pciRxN[11]}]

set_property PACKAGE_PIN AT1 [get_ports {pciRxN[10]}]

set_property PACKAGE_PIN AR3 [get_ports {pciRxN[9]}]

set_property PACKAGE_PIN AP1 [get_ports {pciRxN[8]}]

set_property PACKAGE_PIN AU4 [get_ports {pciRxP[11]}]

set_property PACKAGE_PIN AT2 [get_ports {pciRxP[10]}]

set_property PACKAGE_PIN AR4 [get_ports {pciRxP[9]}]

set_property PACKAGE_PIN AP2 [get_ports {pciRxP[8]}]

set_property PACKAGE_PIN AU8 [get_ports {pciTxN[11]}]

set_property PACKAGE_PIN AT6 [get_ports {pciTxN[10]}]

set_property PACKAGE_PIN AR8 [get_ports {pciTxN[9]}]

set_property PACKAGE_PIN AP6 [get_ports {pciTxN[8]}]

set_property PACKAGE_PIN AU9 [get_ports {pciTxP[11]}]

set_property PACKAGE_PIN AT7 [get_ports {pciTxP[10]}]

set_property PACKAGE_PIN AR9 [get_ports {pciTxP[9]}]

set_property PACKAGE_PIN AP7 [get_ports {pciTxP[8]}]

set_property PACKAGE_PIN AN3 [get_ports {pciRxN[7]}]

set_property PACKAGE_PIN AM1 [get_ports {pciRxN[6]}]

set_property PACKAGE_PIN AL3 [get_ports {pciRxN[5]}]

set_property PACKAGE_PIN AK1 [get_ports {pciRxN[4]}]

set_property PACKAGE_PIN AN4 [get_ports {pciRxP[7]}]

set_property PACKAGE_PIN AM2 [get_ports {pciRxP[6]}]

set_property PACKAGE_PIN AL4 [get_ports {pciRxP[5]}]

set_property PACKAGE_PIN AK2 [get_ports {pciRxP[4]}]

set_property PACKAGE_PIN AN8 [get_ports {pciTxN[7]}]

set_property PACKAGE_PIN AM6 [get_ports {pciTxN[6]}]

set_property PACKAGE_PIN AL8 [get_ports {pciTxN[5]}]

set_property PACKAGE_PIN AK6 [get_ports {pciTxN[4]}]

set_property PACKAGE_PIN AN9 [get_ports {pciTxP[7]}]

set_property PACKAGE_PIN AM7 [get_ports {pciTxP[6]}]

set_property PACKAGE_PIN AL9 [get_ports {pciTxP[5]}]

set_property PACKAGE_PIN AK7 [get_ports {pciTxP[4]}]

set_property PACKAGE_PIN AJ3 [get_ports {pciRxN[3]}]

set_property PACKAGE_PIN AH1 [get_ports {pciRxN[2]}]

set_property PACKAGE_PIN AG3 [get_ports {pciRxN[1]}]

set_property PACKAGE_PIN AF1 [get_ports {pciRxN[0]}]

set_property PACKAGE_PIN AJ4 [get_ports {pciRxP[3]}]

set_property PACKAGE_PIN AH2 [get_ports {pciRxP[2]}]

set_property PACKAGE_PIN AG4 [get_ports {pciRxP[1]}]

set_property PACKAGE_PIN AF2 [get_ports {pciRxP[0]}]

set_property PACKAGE_PIN AJ8 [get_ports {pciTxN[3]}]

set_property PACKAGE_PIN AH6 [get_ports {pciTxN[2]}]

set_property PACKAGE_PIN AG8 [get_ports {pciTxN[1]}]

set_property PACKAGE_PIN AF6 [get_ports {pciTxN[0]}]

set_property PACKAGE_PIN AJ9 [get_ports {pciTxP[3]}]

set_property PACKAGE_PIN AH7 [get_ports {pciTxP[2]}]

set_property PACKAGE_PIN AG9 [get_ports {pciTxP[1]}]

set_property PACKAGE_PIN AF7 [get_ports {pciTxP[0]}]

set_property PACKAGE_PIN AM11 [get_ports {pciRefClkP}]; # 100 MHz
set_property PACKAGE_PIN AM10 [get_ports {pciRefClkN}]; # 100 MHz

set_property -dict { PACKAGE_PIN BD21 IOSTANDARD POD12 } [get_ports {pciRstL}]
set_false_path -from [get_ports pciRstL]
set_property PULLUP true [get_ports pciRstL]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period  6.400 -name userClkP   [get_ports {userClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous -group [get_clocks dnaClk] -group [get_clocks iprogClk] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/XilinxAlveoU200PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.XilinxAlveoU200PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O}]]

set_false_path -to [get_pins -hier *sync_reg[0]/D]

set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/axiClk}]

set_property CLOCK_DEDICATED_ROUTE FALSE    [get_nets {U_Core/userClk156}]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets {U_Core/userClk156}]

######################################
# BITSTREAM: .bit file Configuration #
######################################
set_property CONFIG_VOLTAGE 1.8                        [current_design]
# set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable  [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes       [current_design]
set_property BITSTREAM.STARTUP.LCK_CYCLE NoWait        [current_design]
set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait      [current_design]
