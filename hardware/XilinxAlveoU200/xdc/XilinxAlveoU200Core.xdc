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
