##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

#############################
# Flash programming interface
#############################

# NOTE: the STARTUPE3 primitive is used to connect D0 to D3 and FLASH_nCE
# Flash data 11 downto 0 connects to physical pins 15 downto 4

set_property -dict { PACKAGE_PIN AV21 IOSTANDARD LVCMOS18 } [get_ports flashOeL]
set_property -dict { PACKAGE_PIN AV22 IOSTANDARD LVCMOS18 } [get_ports flashWeL]

set_property -dict { PACKAGE_PIN BA25 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[0]}]
set_property -dict { PACKAGE_PIN BB25 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[1]}]
set_property -dict { PACKAGE_PIN AY28 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[2]}]
set_property -dict { PACKAGE_PIN BA28 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[3]}]
set_property -dict { PACKAGE_PIN AY25 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[4]}]
set_property -dict { PACKAGE_PIN AY26 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[5]}]
set_property -dict { PACKAGE_PIN AW26 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[6]}]
set_property -dict { PACKAGE_PIN AY27 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[7]}]
set_property -dict { PACKAGE_PIN AW23 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[8]}]
set_property -dict { PACKAGE_PIN AY23 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[9]}]
set_property -dict { PACKAGE_PIN AW24 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[10]}]
set_property -dict { PACKAGE_PIN AW25 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[11]}]
set_property -dict { PACKAGE_PIN BB21 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[12]}]
set_property -dict { PACKAGE_PIN BB22 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[13]}]
set_property -dict { PACKAGE_PIN BA23 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[14]}]
set_property -dict { PACKAGE_PIN BA24 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[15]}]
set_property -dict { PACKAGE_PIN AW21 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[16]}]
set_property -dict { PACKAGE_PIN AY21 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[17]}]
set_property -dict { PACKAGE_PIN AY22 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[18]}]
set_property -dict { PACKAGE_PIN BA22 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[19]}]
set_property -dict { PACKAGE_PIN AT22 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[20]}]
set_property -dict { PACKAGE_PIN AT23 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[21]}]
set_property -dict { PACKAGE_PIN AR25 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[22]}]
set_property -dict { PACKAGE_PIN AR26 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[23]}]
set_property -dict { PACKAGE_PIN AU22 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[24]}]
# Flash 25 goes through CPLD for factory save image loading
set_property -dict { PACKAGE_PIN AV23 IOSTANDARD LVCMOS18 } [get_ports {flashAddr[25]}]

set_property -dict { PACKAGE_PIN AV26 IOSTANDARD LVCMOS18 } [get_ports {flashData[4]}]
set_property -dict { PACKAGE_PIN AV27 IOSTANDARD LVCMOS18 } [get_ports {flashData[5]}]
set_property -dict { PACKAGE_PIN AU29 IOSTANDARD LVCMOS18 } [get_ports {flashData[6]}]
set_property -dict { PACKAGE_PIN AV29 IOSTANDARD LVCMOS18 } [get_ports {flashData[7]}]
set_property -dict { PACKAGE_PIN AU25 IOSTANDARD LVCMOS18 } [get_ports {flashData[8]}]
set_property -dict { PACKAGE_PIN AU26 IOSTANDARD LVCMOS18 } [get_ports {flashData[9]}]
set_property -dict { PACKAGE_PIN AU27 IOSTANDARD LVCMOS18 } [get_ports {flashData[10]}]
set_property -dict { PACKAGE_PIN AV28 IOSTANDARD LVCMOS18 } [get_ports {flashData[11]}]
set_property -dict { PACKAGE_PIN BB26 IOSTANDARD LVCMOS18 } [get_ports {flashData[12]}]
set_property -dict { PACKAGE_PIN BB27 IOSTANDARD LVCMOS18 } [get_ports {flashData[13]}]
set_property -dict { PACKAGE_PIN AW28 IOSTANDARD LVCMOS18 } [get_ports {flashData[14]}]
set_property -dict { PACKAGE_PIN AW29 IOSTANDARD LVCMOS18 } [get_ports {flashData[15]}]

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN BB3 [get_ports {pciRxN[7]}]
set_property PACKAGE_PIN BB4 [get_ports {pciRxP[7]}]
set_property PACKAGE_PIN BB7 [get_ports {pciTxN[7]}]
set_property PACKAGE_PIN BB8 [get_ports {pciTxP[7]}]

set_property PACKAGE_PIN BA1 [get_ports {pciRxN[6]}]
set_property PACKAGE_PIN BA2 [get_ports {pciRxP[6]}]
set_property PACKAGE_PIN BA5 [get_ports {pciTxN[6]}]
set_property PACKAGE_PIN BA6 [get_ports {pciTxP[6]}]

set_property PACKAGE_PIN AY3 [get_ports {pciRxN[5]}]
set_property PACKAGE_PIN AY4 [get_ports {pciRxP[5]}]
set_property PACKAGE_PIN AY7 [get_ports {pciTxN[5]}]
set_property PACKAGE_PIN AY8 [get_ports {pciTxP[5]}]

set_property PACKAGE_PIN AW1 [get_ports {pciRxN[4]}]
set_property PACKAGE_PIN AW2 [get_ports {pciRxP[4]}]
set_property PACKAGE_PIN AW5 [get_ports {pciTxN[4]}]
set_property PACKAGE_PIN AW6 [get_ports {pciTxP[4]}]

set_property PACKAGE_PIN AV3 [get_ports {pciRxN[3]}]
set_property PACKAGE_PIN AV4 [get_ports {pciRxP[3]}]
set_property PACKAGE_PIN AV7 [get_ports {pciTxN[3]}]
set_property PACKAGE_PIN AV8 [get_ports {pciTxP[3]}]

set_property PACKAGE_PIN AU1 [get_ports {pciRxN[2]}]
set_property PACKAGE_PIN AU2 [get_ports {pciRxP[2]}]
set_property PACKAGE_PIN AU5 [get_ports {pciTxN[2]}]
set_property PACKAGE_PIN AU6 [get_ports {pciTxP[2]}]

set_property PACKAGE_PIN AT3 [get_ports {pciRxN[1]}]
set_property PACKAGE_PIN AT4 [get_ports {pciRxP[1]}]
set_property PACKAGE_PIN AT7 [get_ports {pciTxN[1]}]
set_property PACKAGE_PIN AT8 [get_ports {pciTxP[1]}]

set_property PACKAGE_PIN AR1 [get_ports {pciRxN[0]}]
set_property PACKAGE_PIN AR2 [get_ports {pciRxP[0]}]
set_property PACKAGE_PIN AR5 [get_ports {pciTxN[0]}]
set_property PACKAGE_PIN AR6 [get_ports {pciTxP[0]}]

set_property PACKAGE_PIN AR9  [get_ports pciRefClkN]; # 100 MHz
set_property PACKAGE_PIN AR10 [get_ports pciRefClkP]; # 100 MHz

set_property -dict { PACKAGE_PIN AP28 IOSTANDARD LVCMOS18 PULLUP true } [get_ports {pciRstL}]

##########
# Clocks #
##########

create_clock -name pciRefClkP -period 10.000 [get_ports {pciRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks {dnaClk}] -group [get_clocks {iprogClk}]

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/CLK_USERCLK}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property BITSTREAM.CONFIG.BPI_PAGE_SIZE 8 [current_design]
set_property BITSTREAM.CONFIG.BPI_1ST_READ_CYCLE 3 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 3 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-2 [current_design]

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE BPI16 [current_design]
