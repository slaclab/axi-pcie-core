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

set_property -dict { PACKAGE_PIN G26 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]  ; # QSPI1_CS_B
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }] ; # QSPI1_IO[0]
set_property -dict { PACKAGE_PIN L20 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }] ; # QSPI1_IO[1]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]   ; # QSPI1_IO[2]
set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]; # QSPI1_IO[3]

set_property -dict { PACKAGE_PIN K20 IOSTANDARD LVCMOS18 } [get_ports { emcClk }]

####################
# PCIe Constraints #
####################

# set_property PACKAGE_PIN AN4 [get_ports {pciRxP[7]}]
# set_property PACKAGE_PIN AN3 [get_ports {pciRxN[7]}]
# set_property PACKAGE_PIN AP2 [get_ports {pciTxP[7]}]
# set_property PACKAGE_PIN AP1 [get_ports {pciTxN[7]}]
# set_property PACKAGE_PIN AM6 [get_ports {pciRxP[6]}]
# set_property PACKAGE_PIN AM5 [get_ports {pciRxN[6]}]
# set_property PACKAGE_PIN AM2 [get_ports {pciTxP[6]}]
# set_property PACKAGE_PIN AM1 [get_ports {pciTxN[6]}]
# set_property PACKAGE_PIN AL4 [get_ports {pciRxP[5]}]
# set_property PACKAGE_PIN AL3 [get_ports {pciRxN[5]}]
# set_property PACKAGE_PIN AK2 [get_ports {pciTxP[5]}]
# set_property PACKAGE_PIN AK1 [get_ports {pciTxN[5]}]
# set_property PACKAGE_PIN AK6 [get_ports {pciRxP[4]}]
# set_property PACKAGE_PIN AK5 [get_ports {pciRxN[4]}]
# set_property PACKAGE_PIN AJ4 [get_ports {pciTxP[4]}]
# set_property PACKAGE_PIN AJ3 [get_ports {pciTxN[4]}]

# set_property PACKAGE_PIN AH6 [get_ports {pciRxP[3]}]
# set_property PACKAGE_PIN AH5 [get_ports {pciRxN[3]}]
# set_property PACKAGE_PIN AH2 [get_ports {pciTxP[3]}]
# set_property PACKAGE_PIN AH1 [get_ports {pciTxN[3]}]
# set_property PACKAGE_PIN AG4 [get_ports {pciRxP[2]}]
# set_property PACKAGE_PIN AG3 [get_ports {pciRxN[2]}]
# set_property PACKAGE_PIN AF2 [get_ports {pciTxP[2]}]
# set_property PACKAGE_PIN AF1 [get_ports {pciTxN[2]}]
# set_property PACKAGE_PIN AE4 [get_ports {pciRxP[1]}]
# set_property PACKAGE_PIN AE3 [get_ports {pciRxN[1]}]
# set_property PACKAGE_PIN AD2 [get_ports {pciTxP[1]}]
# set_property PACKAGE_PIN AD1 [get_ports {pciTxN[1]}]
# set_property PACKAGE_PIN AC4 [get_ports {pciRxP[0]}]
# set_property PACKAGE_PIN AC3 [get_ports {pciRxN[0]}]
# set_property PACKAGE_PIN AB2 [get_ports {pciTxP[0]}]
# set_property PACKAGE_PIN AB1 [get_ports {pciTxN[0]}]

set_property PACKAGE_PIN AB6 [get_ports {pciRefClkP}]; # 100 MHz
set_property PACKAGE_PIN AB5 [get_ports {pciRefClkN}]; # 100 MHz

set_property -dict { PACKAGE_PIN K22 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

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
