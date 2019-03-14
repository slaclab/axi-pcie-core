##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property DCI_CASCADE {32 34} [get_iobanks 33]

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

set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { bootCsL }];
set_property -dict { PACKAGE_PIN P24 IOSTANDARD LVCMOS33 } [get_ports { bootMosi }];
set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVCMOS33 } [get_ports { bootMiso }];

set_property -dict { PACKAGE_PIN R24 IOSTANDARD LVCMOS33 } [get_ports { emcClk }]

####################
# PCIe Constraints #
####################

# Kintex-7 can support 4 lanes of GEN2 and 8 lanes of GEN1
# But cannot support 8 lanes of GEN2 (not an option in the IP core)

# set_property PACKAGE_PIN Y2  [get_ports pciTxP[7]]
# set_property PACKAGE_PIN Y1  [get_ports pciTxN[7]]
# set_property PACKAGE_PIN AA4 [get_ports pciRxP[7]]
# set_property PACKAGE_PIN AA3 [get_ports pciRxN[7]]

# set_property PACKAGE_PIN V2 [get_ports pciTxP[6]]
# set_property PACKAGE_PIN V1 [get_ports pciTxN[6]]
# set_property PACKAGE_PIN Y6 [get_ports pciRxP[6]]
# set_property PACKAGE_PIN Y5 [get_ports pciRxN[6]]

# set_property PACKAGE_PIN U4 [get_ports pciTxP[5]]
# set_property PACKAGE_PIN U3 [get_ports pciTxN[5]]
# set_property PACKAGE_PIN W4 [get_ports pciRxP[5]]
# set_property PACKAGE_PIN W3 [get_ports pciRxN[5]]

# set_property PACKAGE_PIN T2 [get_ports pciTxP[4]]
# set_property PACKAGE_PIN T1 [get_ports pciTxN[4]]
# set_property PACKAGE_PIN V6 [get_ports pciRxP[4]]
# set_property PACKAGE_PIN V5 [get_ports pciRxN[4]]

set_property PACKAGE_PIN P2 [get_ports pciTxP[3]]
set_property PACKAGE_PIN P1 [get_ports pciTxN[3]]
set_property PACKAGE_PIN T6 [get_ports pciRxP[3]]
set_property PACKAGE_PIN T5 [get_ports pciRxN[3]]

set_property PACKAGE_PIN N4 [get_ports pciTxP[2]]
set_property PACKAGE_PIN N3 [get_ports pciTxN[2]]
set_property PACKAGE_PIN R4 [get_ports pciRxP[2]]
set_property PACKAGE_PIN R3 [get_ports pciRxN[2]]

set_property PACKAGE_PIN M2 [get_ports pciTxP[1]]
set_property PACKAGE_PIN M1 [get_ports pciTxN[1]]
set_property PACKAGE_PIN P6 [get_ports pciRxP[1]]
set_property PACKAGE_PIN P5 [get_ports pciRxN[1]]

set_property PACKAGE_PIN L4 [get_ports pciTxP[0]]
set_property PACKAGE_PIN L3 [get_ports pciTxN[0]]
set_property PACKAGE_PIN M6 [get_ports pciRxP[0]]
set_property PACKAGE_PIN M5 [get_ports pciRxN[0]]

set_property PACKAGE_PIN U8  [get_ports pciRefClkP]
set_property PACKAGE_PIN U7  [get_ports pciRefClkN]

set_property -dict { PACKAGE_PIN G25 IOSTANDARD LVCMOS25 PULLUP true } [get_ports { pciRstL }]
set_false_path -from [get_ports pciRstL]

######################
# Timing Constraints #
######################

create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_generated_clock -name dmaClk   [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3}]
create_generated_clock -name dnaClk   [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_generated_clock -name dnaClkL  [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]
create_generated_clock -name iprogClk [get_pins {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_7SERIES.Iprog7Series_Inst/DIVCLK_GEN.BUFR_ICPAPE2/O}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkL}]
set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks {iprogClk}]
