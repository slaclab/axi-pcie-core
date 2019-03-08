##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]  ; # QSPI1_CS_B
set_property -dict { PACKAGE_PIN N23 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }] ; # QSPI1_IO[0]
set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }] ; # QSPI1_IO[1]
set_property -dict { PACKAGE_PIN R20 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]   ; # QSPI1_IO[2]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]; # QSPI1_IO[3]

set_property -dict { PACKAGE_PIN N21 IOSTANDARD LVCMOS18 } [get_ports { emcClk }]

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN AF7 [get_ports {pciTxP[7]}]
set_property PACKAGE_PIN AF6 [get_ports {pciTxN[7]}]
set_property PACKAGE_PIN AF2 [get_ports {pciRxP[7]}]
set_property PACKAGE_PIN AF1 [get_ports {pciRxN[7]}]

set_property PACKAGE_PIN AE9 [get_ports {pciTxP[6]}]
set_property PACKAGE_PIN AE8 [get_ports {pciTxN[6]}]
set_property PACKAGE_PIN AE4 [get_ports {pciRxP[6]}]
set_property PACKAGE_PIN AE3 [get_ports {pciRxN[6]}]

set_property PACKAGE_PIN AD7 [get_ports {pciTxP[5]}]
set_property PACKAGE_PIN AD6 [get_ports {pciTxN[5]}]
set_property PACKAGE_PIN AD2 [get_ports {pciRxP[5]}]
set_property PACKAGE_PIN AD1 [get_ports {pciRxN[5]}]

set_property PACKAGE_PIN AC5 [get_ports {pciTxP[4]}]
set_property PACKAGE_PIN AC4 [get_ports {pciTxN[4]}]
set_property PACKAGE_PIN AB2 [get_ports {pciRxP[4]}]
set_property PACKAGE_PIN AB1 [get_ports {pciRxN[4]}]

set_property PACKAGE_PIN AA5 [get_ports {pciTxP[3]}]
set_property PACKAGE_PIN AA4 [get_ports {pciTxN[3]}]
set_property PACKAGE_PIN Y2  [get_ports {pciRxP[3]}]
set_property PACKAGE_PIN Y1  [get_ports {pciRxN[3]}]

set_property PACKAGE_PIN W5 [get_ports {pciTxP[2]}]
set_property PACKAGE_PIN W4 [get_ports {pciTxN[2]}]
set_property PACKAGE_PIN V2 [get_ports {pciRxP[2]}]
set_property PACKAGE_PIN V1 [get_ports {pciRxN[2]}]

set_property PACKAGE_PIN U5 [get_ports {pciTxP[1]}]
set_property PACKAGE_PIN U4 [get_ports {pciTxN[1]}]
set_property PACKAGE_PIN T2 [get_ports {pciRxP[1]}]
set_property PACKAGE_PIN T1 [get_ports {pciRxN[1]}]

set_property PACKAGE_PIN R5 [get_ports {pciTxP[0]}]
set_property PACKAGE_PIN R4 [get_ports {pciTxN[0]}]
set_property PACKAGE_PIN P2 [get_ports {pciRxP[0]}]
set_property PACKAGE_PIN P1 [get_ports {pciRxN[0]}]

set_property PACKAGE_PIN V7 [get_ports {pciRefClkP}]; # 100 MHz
set_property PACKAGE_PIN V6 [get_ports {pciRefClkN}]; # 100 MHz

set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

create_generated_clock -name dmaClk [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O}]

set_clock_groups -asynchronous -group [get_clocks {dnaClk}]   -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_clock_groups -asynchronous -group [get_clocks {iprogClk}] -group [get_clocks -of_objects [get_pins U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_clock_groups -asynchronous -group [get_clocks pciRefClkP] -group [get_clocks U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]
set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O}]

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
