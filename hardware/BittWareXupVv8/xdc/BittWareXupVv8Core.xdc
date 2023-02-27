##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

#set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_Core}]

###################
# FPGA I2C Master #
###################

# 0 = FPGA has control of I2C chains shared with the BMC.
# 1 = BMC  has control of I2C chains shared with the FPGA (default)
set_property -dict { PACKAGE_PIN AM19 IOSTANDARD LVCMOS18 } [get_ports { fpgaI2cMasterL }]

######################
# Board Clocks/Reset #
######################

# SI5341B_P/N_5 (default: 100 MHz)
set_property -dict { PACKAGE_PIN AV22 IOSTANDARD DIFF_SSTL18_I } [get_ports { userClkP }]
set_property -dict { PACKAGE_PIN AV21 IOSTANDARD DIFF_SSTL18_I } [get_ports { userClkN }]

####################
# PCIe Constraints #
####################

# GTH BANK 224 PCIE Lanes 15:12
set_property package_pin BC1 [get_ports pciRxN[15]]; # PCIE_RX_N_15
set_property package_pin BC2 [get_ports pciRxP[15]]; # PCIE_RX_P_15
set_property package_pin BA1 [get_ports pciRxN[14]]; # PCIE_RX_N_14
set_property package_pin BA2 [get_ports pciRxP[14]]; # PCIE_RX_P_14
set_property package_pin AW3 [get_ports pciRxN[13]]; # PCIE_RX_N_13
set_property package_pin AW4 [get_ports pciRxP[13]]; # PCIE_RX_P_13
set_property package_pin AV1 [get_ports pciRxN[12]]; # PCIE_RX_N_12
set_property package_pin AV2 [get_ports pciRxP[12]]; # PCIE_RX_P_12
set_property package_pin BF4 [get_ports pciTxN[15]]; # PCIE_TX_N_15
set_property package_pin BF5 [get_ports pciTxP[15]]; # PCIE_TX_P_15
set_property package_pin BD4 [get_ports pciTxN[14]]; # PCIE_TX_N_14
set_property package_pin BD5 [get_ports pciTxP[14]]; # PCIE_TX_P_14
set_property package_pin BB4 [get_ports pciTxN[13]]; # PCIE_TX_N_13
set_property package_pin BB5 [get_ports pciTxP[13]]; # PCIE_TX_P_13
set_property package_pin AV6 [get_ports pciTxN[12]]; # PCIE_TX_N_12
set_property package_pin AV7 [get_ports pciTxP[12]]; # PCIE_TX_P_12

# GTH BANK 225 PCIE Lanes 11:8
set_property package_pin AU3 [get_ports pciRxN[11]]; # PCIE_RX_N_11
set_property package_pin AU4 [get_ports pciRxP[11]]; # PCIE_RX_P_11
set_property package_pin AT1 [get_ports pciRxN[10]]; # PCIE_RX_N_10
set_property package_pin AT2 [get_ports pciRxP[10]]; # PCIE_RX_P_10
set_property package_pin AR3 [get_ports pciRxN[9]];  # PCIE_RX_N_9
set_property package_pin AR4 [get_ports pciRxP[9]];  # PCIE_RX_P_9
set_property package_pin AP1 [get_ports pciRxN[8]];  # PCIE_RX_N_8
set_property package_pin AP2 [get_ports pciRxP[8]];  # PCIE_RX_P_8
set_property package_pin AU8 [get_ports pciTxN[11]]; # PCIE_TX_N_11
set_property package_pin AU9 [get_ports pciTxP[11]]; # PCIE_TX_P_11
set_property package_pin AT6 [get_ports pciTxN[10]]; # PCIE_TX_N_10
set_property package_pin AT7 [get_ports pciTxP[10]]; # PCIE_TX_P_10
set_property package_pin AR8 [get_ports pciTxN[9]];  # PCIE_TX_N_9
set_property package_pin AR9 [get_ports pciTxP[9]];  # PCIE_TX_P_9
set_property package_pin AP6 [get_ports pciTxN[8]];  # PCIE_TX_N_8
set_property package_pin AP7 [get_ports pciTxP[8]];  # PCIE_TX_P_8

# GTH BANK 226 PCIE 7:4
set_property package_pin AN3 [get_ports pciRxN[7]]; # PCIE_RX_N_7
set_property package_pin AN4 [get_ports pciRxP[7]]; # PCIE_RX_P_7
set_property package_pin AM1 [get_ports pciRxN[6]]; # PCIE_RX_N_6
set_property package_pin AM2 [get_ports pciRxP[6]]; # PCIE_RX_P_6
set_property package_pin AL3 [get_ports pciRxN[5]]; # PCIE_RX_N_5
set_property package_pin AL4 [get_ports pciRxP[5]]; # PCIE_RX_P_5
set_property package_pin AK1 [get_ports pciRxN[4]]; # PCIE_RX_N_4
set_property package_pin AK2 [get_ports pciRxP[4]]; # PCIE_RX_P_4
set_property package_pin AN8 [get_ports pciTxN[7]]; # PCIE_TX_N_7
set_property package_pin AN9 [get_ports pciTxP[7]]; # PCIE_TX_P_7
set_property package_pin AM6 [get_ports pciTxN[6]]; # PCIE_TX_N_6
set_property package_pin AM7 [get_ports pciTxP[6]]; # PCIE_TX_P_6
set_property package_pin AL8 [get_ports pciTxN[5]]; # PCIE_TX_N_5
set_property package_pin AL9 [get_ports pciTxP[5]]; # PCIE_TX_P_5
set_property package_pin AK6 [get_ports pciTxN[4]]; # PCIE_TX_N_4
set_property package_pin AK7 [get_ports pciTxP[4]]; # PCIE_TX_P_4

# GTH BANK 227 PCIE 3:0
set_property package_pin AJ3 [get_ports pciRxN[3]]; # PCIE_RX_N_3
set_property package_pin AJ4 [get_ports pciRxP[3]]; # PCIE_RX_P_3
set_property package_pin AH1 [get_ports pciRxN[2]]; # PCIE_RX_N_2
set_property package_pin AH2 [get_ports pciRxP[2]]; # PCIE_RX_P_2
set_property package_pin AG3 [get_ports pciRxN[1]]; # PCIE_RX_N_1
set_property package_pin AG4 [get_ports pciRxP[1]]; # PCIE_RX_P_1
set_property package_pin AF1 [get_ports pciRxN[0]]; # PCIE_RX_N_0
set_property package_pin AF2 [get_ports pciRxP[0]]; # PCIE_RX_P_0
set_property package_pin AJ8 [get_ports pciTxN[3]]; # PCIE_TX_N_3
set_property package_pin AJ9 [get_ports pciTxP[3]]; # PCIE_TX_P_3
set_property package_pin AH6 [get_ports pciTxN[2]]; # PCIE_TX_N_2
set_property package_pin AH7 [get_ports pciTxP[2]]; # PCIE_TX_P_2
set_property package_pin AG8 [get_ports pciTxN[1]]; # PCIE_TX_N_1
set_property package_pin AG9 [get_ports pciTxP[1]]; # PCIE_TX_P_1
set_property package_pin AF6 [get_ports pciTxN[0]]; # PCIE_TX_N_0
set_property package_pin AF7 [get_ports pciTxP[0]]; # PCIE_TX_P_0

set_property PACKAGE_PIN AT11 [get_ports {pciRefClkP}]; # 100 MHz
set_property PACKAGE_PIN AT10 [get_ports {pciRefClkN}]; # 100 MHz

set_property -dict { PACKAGE_PIN BB20 IOSTANDARD LVCMOS18 PULLUP true } [get_ports {pciRstL}]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period 10.000 -name userClkP   [get_ports {userClkP}]
create_generated_clock -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_generated_clock -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

create_generated_clock -name dmaClk [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O}]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks {pciRefClkP}] \
    -group [get_clocks -include_generated_clocks {userClkP}]

set_clock_groups -asynchronous \
    -group [get_clocks dnaClk] \
    -group [get_clocks iprogClk] \
    -group [get_clocks dmaClk]



## Commenting out for now as these clock path crossings don't seem to exist.
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[29].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[30].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
# set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/BittWareXupVv8PciePhy_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.BittWareXupVv8PciePhy_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks -of_objects [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O}]]

set_false_path -to [get_pins -hier *sync_reg[0]/D]

set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/axiClk}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx4  [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]; # Bitstream configuration settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design];  # Must set to "NO" if loading from backup flash partition
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
