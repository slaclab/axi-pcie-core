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
set_property LOC CONFIG_SITE_X0Y0 [get_cells {U_Core/U_STARTUPE3}]

set_property -dict { PACKAGE_PIN AL27 IOSTANDARD LVCMOS18 } [get_ports { emcClk }]
set_property -dict { PACKAGE_PIN BF27 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]
set_property -dict { PACKAGE_PIN AM26 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }]
set_property -dict { PACKAGE_PIN AN26 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }]
set_property -dict { PACKAGE_PIN AM25 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]
set_property -dict { PACKAGE_PIN AL25 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]

####################
# PCIe Constraints #
####################

set_property LOC PCIE_3_1_X0Y0   [get_cells {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst}]
set_property PACKAGE_PIN AT11    [get_ports {pciRefClkP}]
set_property PACKAGE_PIN AT10    [get_ports {pciRefClkN}]
set_property -dict { PACKAGE_PIN AR26 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}];

##########
# Clocks #
##########
create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period 11.111 -name emcClk     [get_ports {emcClk}]

create_generated_clock -name dnaClk  [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_generated_clock -name sysClk  [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/O}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst/CFGMAX*}]
set_false_path -through [get_nets {U_Core/U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

set_property HIGH_PRIORITY true [get_nets {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/CLK_USERCLK}]

######################################
# BITSTREAM: .bit file Configuration #
######################################
set_property CONFIG_VOLTAGE 1.8                      [current_design]
set_property CFGBVS GND                              [current_design]
# set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable  [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE         [current_design]
set_property CONFIG_MODE SPIx8                       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8         [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup       [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes     [current_design]