##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

######################################
# BITSTREAM: .bit file Configuration #
######################################

# for Quad SPI
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Sets the EMCCLK in the FPGA to divide by 1
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-4 [current_design]

# Shrinks the bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Improves the speed of SPI loading
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.SPI_OPCODE 0x6B [current_design]

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { bootCsL }];
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports { bootMosi }];
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { bootMiso }];

set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { emcClk }]

####################
# PCIe Constraints #
####################

# set_property PACKAGE_PIN B7  [get_ports pciTxP[3]]
# set_property PACKAGE_PIN A7  [get_ports pciTxN[3]]
# set_property PACKAGE_PIN B11 [get_ports pciRxP[3]]
# set_property PACKAGE_PIN A11 [get_ports pciRxN[3]]

# set_property PACKAGE_PIN D8  [get_ports pciTxP[2]]
# set_property PACKAGE_PIN C8  [get_ports pciTxN[2]]
# set_property PACKAGE_PIN D14 [get_ports pciRxP[2]]
# set_property PACKAGE_PIN C14 [get_ports pciRxN[2]]

# set_property PACKAGE_PIN B9  [get_ports pciTxP[1]]
# set_property PACKAGE_PIN A9  [get_ports pciTxN[1]]
# set_property PACKAGE_PIN B13 [get_ports pciRxP[1]]
# set_property PACKAGE_PIN A13 [get_ports pciRxN[1]]

set_property PACKAGE_PIN D10 [get_ports pciTxP[0]]
set_property PACKAGE_PIN C10 [get_ports pciTxN[0]]
set_property PACKAGE_PIN D12 [get_ports pciRxP[0]]
set_property PACKAGE_PIN C12 [get_ports pciRxN[0]]

set_property PACKAGE_PIN F11  [get_ports pciRefClkP]
set_property PACKAGE_PIN E11  [get_ports pciRefClkN]

set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { pciRstL }]
set_false_path -from [get_ports pciRstL]

######################
# Timing Constraints #
######################

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_generated_clock -name dmaClk   [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT2}]
create_clock -name dnaClk   -period 32 [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_clock -name dnaClkL  -period 32 [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]
create_clock -name iprogClk -period 32 [get_pins {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_7SERIES.Iprog7Series_Inst/DIVCLK_GEN.BUFR_ICPAPE2/O}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkL}] -group [get_clocks {iprogClk}]
set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkL}] -group [get_clocks {iprogClk}]
