##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_Core}]

set_operating_conditions -design_power_budget 63

##########
# System #
##########
 
set_property -dict { PACKAGE_PIN BJ42 IOSTANDARD LVCMOS18 } [get_ports { cmsUartRxd }]
set_property -dict { PACKAGE_PIN BH42 IOSTANDARD LVCMOS18 } [get_ports { cmsUartTxd }]

set_property -dict { PACKAGE_PIN BE46 IOSTANDARD LVCMOS18 } [get_ports { cmsGpio[0] }]
set_property -dict { PACKAGE_PIN BH46 IOSTANDARD LVCMOS18 } [get_ports { cmsGpio[1] }]
set_property -dict { PACKAGE_PIN BF45 IOSTANDARD LVCMOS18 } [get_ports { cmsGpio[2] }]
set_property -dict { PACKAGE_PIN BF46 IOSTANDARD LVCMOS18 } [get_ports { cmsGpio[3] }]

set_property -dict { PACKAGE_PIN BK10 IOSTANDARD LVDS } [get_ports { userClkP }]
set_property -dict { PACKAGE_PIN BL10 IOSTANDARD LVDS } [get_ports { userClkN }]

set_property -dict { PACKAGE_PIN BK43 IOSTANDARD LVDS } [get_ports { hbmRefClkP }]
set_property -dict { PACKAGE_PIN BK44 IOSTANDARD LVDS } [get_ports { hbmRefClkN }]

####################################################################################
# I2C_SI5394_SCLK    Master I2C clock connection from FPGA to Si5394B
# I2C_SI5394_SDA     Master I2C data connection from FPGA to Si5394B
# SI_INTRB           Active low interrupt output from Si5394B to FPGA input
# SI_PLL_LOCK        Active low PLL Loss of Lock output from Si5394B to FPGA input
# SI_IN_LOS          Active low PLL Loss of Signal output from Si5394B to FPGA input
# SI_RSTBB           Active low reset output from FPGA to Si5394B input
####################################################################################

set_property -dict { PACKAGE_PIN BM14 IOSTANDARD LVCMOS18 } [get_ports { si5394Scl }] ;# Bank  68 VCCO - VCC1V8   - IO_L5P_T0U_N8_AD14P_68
set_property -dict { PACKAGE_PIN BN14 IOSTANDARD LVCMOS18 } [get_ports { si5394Sda }] ;# Bank  68 VCCO - VCC1V8   - IO_L4N_T0U_N7_DBC_AD7N_68
set_property -dict { PACKAGE_PIN BM9  IOSTANDARD LVCMOS18 } [get_ports { si5394IrqL }] ;# Bank  68 VCCO - VCC1V8   - IO_L9P_T1L_N4_AD12P_68
set_property -dict { PACKAGE_PIN BN10 IOSTANDARD LVCMOS18 } [get_ports { si5394LolL }] ;# Bank  68 VCCO - VCC1V8   - IO_L8N_T1L_N3_AD5N_68
set_property -dict { PACKAGE_PIN BM10 IOSTANDARD LVCMOS18 } [get_ports { si5394LosL }] ;# Bank  68 VCCO - VCC1V8   - IO_L8P_T1L_N2_AD5P_68
set_property -dict { PACKAGE_PIN BM8  IOSTANDARD LVCMOS18 } [get_ports { si5394RstL }] ;# Bank  68 VCCO - VCC1V8   - IO_L10N_T1U_N7_QBC_AD4N_68

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN BC1  [get_ports {pciRxN[15]}] ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN BB3  [get_ports {pciRxN[14]}] ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN BA1  [get_ports {pciRxN[13]}] ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN BA5  [get_ports {pciRxN[12]}] ;# Bank 224 - MGTYRXN3_224

set_property PACKAGE_PIN BC2  [get_ports {pciRxP[15]}] ;# Bank 224 - MGTYRXP0_224
set_property PACKAGE_PIN BB4  [get_ports {pciRxP[14]}] ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN BA2  [get_ports {pciRxP[13]}] ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN BA6  [get_ports {pciRxP[12]}] ;# Bank 224 - MGTYRXP3_224

set_property PACKAGE_PIN BC6  [get_ports {pciTxN[15]}] ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN BC10 [get_ports {pciTxN[14]}] ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN BB8  [get_ports {pciTxN[13]}] ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN BA10 [get_ports {pciTxN[12]}] ;# Bank 224 - MGTYTXN3_224

set_property PACKAGE_PIN BC7  [get_ports {pciTxP[15]}] ;# Bank 224 - MGTYTXP0_224
set_property PACKAGE_PIN BC11 [get_ports {pciTxP[14]}] ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN BB9  [get_ports {pciTxP[13]}] ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN BA11 [get_ports {pciTxP[12]}] ;# Bank 224 - MGTYTXP3_224

set_property PACKAGE_PIN AY3  [get_ports {pciRxN[11]}] ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN AW1  [get_ports {pciRxN[10]}] ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN AW5  [get_ports {pciRxN[9]}]  ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN AV3  [get_ports {pciRxN[8]}]  ;# Bank 225 - MGTYRXN3_225

set_property PACKAGE_PIN AY4  [get_ports {pciRxP[11]}] ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN AW2  [get_ports {pciRxP[10]}] ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN AW6  [get_ports {pciRxP[9]}]  ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN AV4  [get_ports {pciRxP[8]}]  ;# Bank 225 - MGTYRXP3_225

set_property PACKAGE_PIN AY8  [get_ports {pciTxN[11]}] ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN AW10 [get_ports {pciTxN[10]}] ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN AV8  [get_ports {pciTxN[9]}]  ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN AU6  [get_ports {pciTxN[8]}]  ;# Bank 225 - MGTYTXN3_225

set_property PACKAGE_PIN AY9  [get_ports {pciTxP[11]}] ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN AW11 [get_ports {pciTxP[10]}] ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN AV9  [get_ports {pciTxP[9]}]  ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN AU7  [get_ports {pciTxP[8]}]  ;# Bank 225 - MGTYTXP3_225

set_property PACKAGE_PIN AU1  [get_ports {pciRxN[7]}] ;# Bank 226 - MGTYRXN0_226
set_property PACKAGE_PIN AT3  [get_ports {pciRxN[6]}] ;# Bank 226 - MGTYRXN1_226
set_property PACKAGE_PIN AR1  [get_ports {pciRxN[5]}] ;# Bank 226 - MGTYRXN2_226
set_property PACKAGE_PIN AP3  [get_ports {pciRxN[4]}] ;# Bank 226 - MGTYRXN3_226

set_property PACKAGE_PIN AU2  [get_ports {pciRxP[7]}] ;# Bank 226 - MGTYRXP0_226
set_property PACKAGE_PIN AT4  [get_ports {pciRxP[6]}] ;# Bank 226 - MGTYRXP1_226
set_property PACKAGE_PIN AR2  [get_ports {pciRxP[5]}] ;# Bank 226 - MGTYRXP2_226
set_property PACKAGE_PIN AP4  [get_ports {pciRxP[4]}] ;# Bank 226 - MGTYRXP3_226

set_property PACKAGE_PIN AU10 [get_ports {pciTxN[7]}] ;# Bank 226 - MGTYTXN0_226
set_property PACKAGE_PIN AT8  [get_ports {pciTxN[6]}] ;# Bank 226 - MGTYTXN1_226
set_property PACKAGE_PIN AR6  [get_ports {pciTxN[5]}] ;# Bank 226 - MGTYTXN2_226
set_property PACKAGE_PIN AR10 [get_ports {pciTxN[4]}] ;# Bank 226 - MGTYTXN3_226

set_property PACKAGE_PIN AU11 [get_ports {pciTxP[7]}] ;# Bank 226 - MGTYTXP0_226
set_property PACKAGE_PIN AT9  [get_ports {pciTxP[6]}] ;# Bank 226 - MGTYTXP1_226
set_property PACKAGE_PIN AR7  [get_ports {pciTxP[5]}] ;# Bank 226 - MGTYTXP2_226
set_property PACKAGE_PIN AR11 [get_ports {pciTxP[4]}] ;# Bank 226 - MGTYTXP3_226

set_property PACKAGE_PIN AN1  [get_ports {pciRxN[3]}] ;# Bank 227 - MGTYRXN0_227
set_property PACKAGE_PIN AN5  [get_ports {pciRxN[2]}] ;# Bank 227 - MGTYRXN1_227
set_property PACKAGE_PIN AM3  [get_ports {pciRxN[1]}] ;# Bank 227 - MGTYRXN2_227
set_property PACKAGE_PIN AL1  [get_ports {pciRxN[0]}] ;# Bank 227 - MGTYRXN3_227

set_property PACKAGE_PIN AN2  [get_ports {pciRxP[3]}] ;# Bank 227 - MGTYRXP0_227
set_property PACKAGE_PIN AN6  [get_ports {pciRxP[2]}] ;# Bank 227 - MGTYRXP1_227
set_property PACKAGE_PIN AM4  [get_ports {pciRxP[1]}] ;# Bank 227 - MGTYRXP2_227
set_property PACKAGE_PIN AL2  [get_ports {pciRxP[0]}] ;# Bank 227 - MGTYRXP3_227

set_property PACKAGE_PIN AP8  [get_ports {pciTxN[3]}] ;# Bank 227 - MGTYTXN0_227
set_property PACKAGE_PIN AN10 [get_ports {pciTxN[2]}] ;# Bank 227 - MGTYTXN1_227
set_property PACKAGE_PIN AM8  [get_ports {pciTxN[1]}] ;# Bank 227 - MGTYTXN2_227
set_property PACKAGE_PIN AL10 [get_ports {pciTxN[0]}] ;# Bank 227 - MGTYTXN3_227

set_property PACKAGE_PIN AP9  [get_ports {pciTxP[3]}] ;# Bank 227 - MGTYTXP0_227
set_property PACKAGE_PIN AN11 [get_ports {pciTxP[2]}] ;# Bank 227 - MGTYTXP1_227
set_property PACKAGE_PIN AM9  [get_ports {pciTxP[1]}] ;# Bank 227 - MGTYTXP2_227
set_property PACKAGE_PIN AL11 [get_ports {pciTxP[0]}] ;# Bank 227 - MGTYTXP3_227

set_property PACKAGE_PIN AL15 [get_ports {pciRefClkP[1]}]
set_property PACKAGE_PIN AL14 [get_ports {pciRefClkN[1]}]

set_property PACKAGE_PIN AR15 [get_ports {pciRefClkP[0]}]
set_property PACKAGE_PIN AR14 [get_ports {pciRefClkN[0]}]

set_property -dict { PACKAGE_PIN BF41 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]
set_false_path -from [get_ports pciRstL]
set_property PULLUP true [get_ports pciRstL]

##########
# Clocks #
##########

create_clock -period 10.000 -name pciRefClk0 [get_ports {pciRefClkP[0]}]
create_clock -period 10.000 -name pciRefClk1 [get_ports {pciRefClkP[1]}]
create_clock -period 10.000 -name userClkP   [get_ports {userClkP}]
create_clock -period 10.000 -name hbmRefClkP [get_ports {hbmRefClkP}]
create_clock -period 16.000 -name dnaClk     [get_pins  {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 16.000 -name iprogClk   [get_pins  {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_clock -period 20.000 -name cmsClk     [get_pins  {U_Core/REAL_PCIE.U_CMS/U_Bufg/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk0}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk0}] -group [get_clocks -include_generated_clocks {cmsClk}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClk1}] -group [get_clocks -include_generated_clocks {userClkP}]

set_false_path -to [get_pins -hier *sync_reg[0]/D]

set_false_path -from [get_ports {pciRstL}]

set_property HIGH_PRIORITY true [get_nets {U_Core/REAL_PCIE.U_AxiPciePhy/axiClk}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable    [current_design] ;# Golden image is the fall back image if  new bitstream is corrupted.
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup         [current_design] ;# Choices are pullnone, pulldown, and pullup.
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes       [current_design]
