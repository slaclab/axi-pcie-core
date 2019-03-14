##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN AC4 [get_ports pciTxP[0]]; # AC4   PCIE_TX0_PIN_P    MGT
set_property PACKAGE_PIN AC3 [get_ports pciTxN[0]]; # AC3   PCIE_TX0_PIN_N    MGT
set_property PACKAGE_PIN AB2 [get_ports pciRxP[0]]; # AB2   PCIE_RX0_P        MGT
set_property PACKAGE_PIN AB1 [get_ports pciRxN[0]]; # AB1   PCIE_RX0_N        MGT

set_property PACKAGE_PIN AE4 [get_ports pciTxP[1]]; # AE4   PCIE_TX1_PIN_P    MGT
set_property PACKAGE_PIN AE3 [get_ports pciTxN[1]]; # AE3   PCIE_TX1_PIN_N    MGT
set_property PACKAGE_PIN AD2 [get_ports pciRxP[1]]; # AD2   PCIE_RX1_P        MGT
set_property PACKAGE_PIN AD1 [get_ports pciRxN[1]]; # AD1   PCIE_RX1_N        MGT

set_property PACKAGE_PIN AG4 [get_ports pciTxP[2]]; # AG4   PCIE_TX2_PIN_P    MGT
set_property PACKAGE_PIN AG3 [get_ports pciTxN[2]]; # AG3   PCIE_TX2_PIN_N    MGT
set_property PACKAGE_PIN AF2 [get_ports pciRxP[2]]; # AF2   PCIE_RX2_P        MGT
set_property PACKAGE_PIN AF1 [get_ports pciRxN[2]]; # AF1   PCIE_RX2_N        MGT

set_property PACKAGE_PIN AH6 [get_ports pciTxP[3]]; # AH6   PCIE_TX3_PIN_P    MGT
set_property PACKAGE_PIN AH5 [get_ports pciTxN[3]]; # AH5   PCIE_TX3_PIN_N    MGT
set_property PACKAGE_PIN AH2 [get_ports pciRxP[3]]; # AH2   PCIE_RX3_P        MGT
set_property PACKAGE_PIN AH1 [get_ports pciRxN[3]]; # AH1   PCIE_RX3_N        MGT

set_property PACKAGE_PIN AK6 [get_ports pciTxP[4]]; # AK6   PCIE_TX4_PIN_P    MGT
set_property PACKAGE_PIN AK5 [get_ports pciTxN[4]]; # AK5   PCIE_TX4_PIN_N    MGT
set_property PACKAGE_PIN AJ4 [get_ports pciRxP[4]]; # AJ4   PCIE_RX4_P        MGT
set_property PACKAGE_PIN AJ3 [get_ports pciRxN[4]]; # AJ3   PCIE_RX4_N        MGT

set_property PACKAGE_PIN AL4 [get_ports pciTxP[5]]; # AL4   PCIE_TX5_PIN_P    MGT
set_property PACKAGE_PIN AL3 [get_ports pciTxN[5]]; # AL3   PCIE_TX5_PIN_N    MGT
set_property PACKAGE_PIN AK2 [get_ports pciRxP[5]]; # AK2   PCIE_RX5_P        MGT
set_property PACKAGE_PIN AK1 [get_ports pciRxN[5]]; # AK1   PCIE_RX5_N        MGT

set_property PACKAGE_PIN AM6 [get_ports pciTxP[6]]; # AM6   PCIE_TX6_PIN_P    MGT
set_property PACKAGE_PIN AM5 [get_ports pciTxN[6]]; # AM5   PCIE_TX6_PIN_N    MGT
set_property PACKAGE_PIN AM2 [get_ports pciRxP[6]]; # AM2   PCIE_RX6_P        MGT
set_property PACKAGE_PIN AM1 [get_ports pciRxN[6]]; # AM1   PCIE_RX6_N        MGT

set_property PACKAGE_PIN AN4 [get_ports pciTxP[7]]; # AN4   PCIE_TX7_PIN_P    MGT
set_property PACKAGE_PIN AN3 [get_ports pciTxN[7]]; # AN3   PCIE_TX7_PIN_N    MGT
set_property PACKAGE_PIN AP2 [get_ports pciRxP[7]]; # AP2   PCIE_RX7_P        MGT
set_property PACKAGE_PIN AP1 [get_ports pciRxN[7]]; # AP1   PCIE_RX7_N        MGT

# G4   PCIE_TX8_PIN_P      MGT
# G3   PCIE_TX8_PIN_N      MGT
# F2   PCIE_RX8_P          MGT
# F1   PCIE_RX8_N          MGT

# J4   PCIE_TX9_PIN_P      MGT
# J3   PCIE_TX9_PIN_N      MGT
# H2   PCIE_RX9_P          MGT
# H1   PCIE_RX9_N          MGT

# L4   PCIE_TX10_PIN_P     MGT
# L3   PCIE_TX10_PIN_N     MGT
# K2   PCIE_RX10_P         MGT
# K1   PCIE_RX10_N         MGT

# N4   PCIE_TX11_PIN_P     MGT
# N3   PCIE_TX11_PIN_N     MGT
# M2   PCIE_RX11_P         MGT
# M1   PCIE_RX11_N         MGT

# R4   PCIE_TX12_PIN_P     MGT
# R3   PCIE_TX12_PIN_N     MGT
# P2   PCIE_RX12_P         MGT
# P1   PCIE_RX12_N         MGT

# U4   PCIE_TX13_PIN_P     MGT
# U3   PCIE_TX13_PIN_N     MGT
# T2   PCIE_RX13_P         MGT
# T1   PCIE_RX13_N         MGT

# W4   PCIE_TX14_PIN_P     MGT
# W3   PCIE_TX14_PIN_N     MGT
# V2   PCIE_RX14_P         MGT
# V1   PCIE_RX14_N         MGT

# AA4  PCIE_TX15_PIN_P     MGT
# AA3  PCIE_TX15_PIN_N     MGT
# Y2   PCIE_RX15_P         MGT
# Y1   PCIE_RX15_N         MGT

set_property PACKAGE_PIN AB6  [get_ports pciRefClkP];  # AB6   PCIE_REFCLK1_PIN_P   MGT_REFCLK
set_property PACKAGE_PIN AB5  [get_ports pciRefClkN];  # AB5   PCIE_REFCLK1_PIN_N   MGT_REFCLK
# set_property PACKAGE_PIN P6  [get_ports pciRefClkP]; # P6   PCIE_REFCLK0_PIN_P   MGT_REFCLK
# set_property PACKAGE_PIN P5  [get_ports pciRefClkN]; # P5   PCIE_REFCLK0_PIN_N   MGT_REFCLK

set_property -dict { PACKAGE_PIN K22 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}];   # K22   PERST1_L             1.8
# set_property -dict { PACKAGE_PIN N23 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]; # N23   PERST0_L             1.8


##########
# Clocks #
##########

create_clock -name pciRefClkP -period 10.000 [get_ports {pciRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks {dnaClk}] -group [get_clocks {iprogClk}]

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

set_property BITSTREAM.GENERAL.COMPRESS {TRUE} [ current_design ]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE {TYPE1} [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN {Pullnone} [current_design]
set_property CONFIG_MODE {BPI16} [current_design]
set_property CFGBVS GND [ current_design ]
set_property CONFIG_VOLTAGE 1.8 [ current_design ]
