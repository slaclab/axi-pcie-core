##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# create_pblock SLR0_GRP
# create_pblock SLR1_GRP
# create_pblock SLR2_GRP
# create_pblock SLR3_GRP

# resize_pblock [get_pblocks SLR0_GRP] -add {CLOCKREGION_X0Y0:CLOCKREGION_X7Y3}
# resize_pblock [get_pblocks SLR1_GRP] -add {CLOCKREGION_X0Y4:CLOCKREGION_X7Y7}
# resize_pblock [get_pblocks SLR2_GRP] -add {CLOCKREGION_X0Y8:CLOCKREGION_X7Y11}
# resize_pblock [get_pblocks SLR3_GRP] -add {CLOCKREGION_X0Y12:CLOCKREGION_X7Y15}

######################
# Board Clocks/Reset #
######################

# Active Low Global Reset
set_property -dict { PACKAGE_PIN AL19 IOSTANDARD LVCMOS18 } [get_ports { sysRstL }]

# Ext Ref Clock
set_property -dict { PACKAGE_PIN AY21 IOSTANDARD LVCMOS18 } [get_ports { extRefClk }]

# Ext PPS
set_property -dict { PACKAGE_PIN AW21 IOSTANDARD LVCMOS18 } [get_ports { extPps }]

################################
# Board Clock: FPGA->SI5346A/B #
################################

# Fabric Out Clk 0 / SI5346A Input 2
set_property -dict { PACKAGE_PIN AT22 IOSTANDARD LVDS } [get_ports { fabClkOutP[0] }]
set_property -dict { PACKAGE_PIN AU22 IOSTANDARD LVDS } [get_ports { fabClkOutN[0] }]

# Fabric Out Clk 1 / SI5346B Input 2
set_property -dict { PACKAGE_PIN AT20 IOSTANDARD LVDS } [get_ports { fabClkOutP[1] }]
set_property -dict { PACKAGE_PIN AT19 IOSTANDARD LVDS } [get_ports { fabClkOutN[1] }]

# GTY Bank 120 Clk 1 / SI5346A Input 1
set_property -dict { PACKAGE_PIN AK34 IOSTANDARD LVDS } [get_ports { gtyClkOutP[0] }]
set_property -dict { PACKAGE_PIN AK35 IOSTANDARD LVDS } [get_ports { gtyClkOutN[0] }]

# GTY Bank 122 Clk 1 / SI5346B Input 1
set_property -dict { PACKAGE_PIN AF34 IOSTANDARD LVDS } [get_ports { gtyClkOutP[1] }]
set_property -dict { PACKAGE_PIN AF35 IOSTANDARD LVDS } [get_ports { gtyClkOutN[1] }]

##############
# UART I/F's #
##############

# AVR UART Rx Data
set_property -dict { PACKAGE_PIN AN22 IOSTANDARD LVCMOS18 } [get_ports { uartAvrRx }]

# AVR UART Tx Data
set_property -dict { PACKAGE_PIN AN21 IOSTANDARD LVCMOS18 } [get_ports { uartAvrTx }]

# FTDI UART Rx Data
set_property -dict { PACKAGE_PIN BD21 IOSTANDARD LVCMOS18 } [get_ports { uartFtdiRx }]

# FTDI UART Tx Data
set_property -dict { PACKAGE_PIN BD20 IOSTANDARD LVCMOS18 } [get_ports { uartFtdiTx }]

#############
# I2C I/F's #
#############

# I2C SDA 3 Expander
set_property -dict { PACKAGE_PIN AP19 IOSTANDARD LVCMOS18 } [get_ports { i2CSda }]

# I2C SCL 3 Expander
set_property -dict { PACKAGE_PIN AN19 IOSTANDARD LVCMOS18 } [get_ports { i2CScl }]

################
# Misc Signals #
################

# QSFP13 Loss of Lock A
set_property -dict { PACKAGE_PIN BB19 IOSTANDARD LVCMOS18 } [get_ports { qsfpLolL[0] }]

# QSFP13 Loss of Lock B
set_property -dict { PACKAGE_PIN BF17 IOSTANDARD LVCMOS18 } [get_ports { qsfpLolL[1] }]

# QSFP24 Loss of Lock A
set_property -dict { PACKAGE_PIN BE17 IOSTANDARD LVCMOS18 } [get_ports { qsfpLolL[2] }]

# QSFP24 Loss of Lock B
set_property -dict { PACKAGE_PIN BE16 IOSTANDARD LVCMOS18 } [get_ports { qsfpLolL[3] }]

# QSFP Interrupt
set_property -dict { PACKAGE_PIN AW19 IOSTANDARD LVCMOS18 } [get_ports { qsfpIntL }]

# Interrupt from avr to fpga
set_property -dict { PACKAGE_PIN AM21 IOSTANDARD LVCMOS18 } [get_ports { irqTofpga }]

# Interrupt to avr from fpga
set_property -dict { PACKAGE_PIN AM20 IOSTANDARD LVCMOS18 } [get_ports { irqToAvr }]

################
# Oculink GPIO #
################

set_property -dict { PACKAGE_PIN BC18 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][0] }]; # Oculink 1 GPIO 0
set_property -dict { PACKAGE_PIN AY20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][1] }]; # Oculink 1 GPIO 1
set_property -dict { PACKAGE_PIN BA20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][2] }]; # Oculink 1 GPIO 2
set_property -dict { PACKAGE_PIN BB21 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][3] }]; # Oculink 1 GPIO 3
set_property -dict { PACKAGE_PIN BC21 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][4] }]; # Oculink 1 GPIO 4
set_property -dict { PACKAGE_PIN BA19 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][5] }]; # Oculink 1 GPIO 5
set_property -dict { PACKAGE_PIN AR20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][6] }]; # Oculink 1 GPIO 6/Oculink i2c scl
set_property -dict { PACKAGE_PIN AU21 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[0][7] }]; # Oculink 1 GPIO 7/Oculink i2c sda

set_property -dict { PACKAGE_PIN BF20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][0] }]; # Oculink 2 GPIO 0
set_property -dict { PACKAGE_PIN BF19 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][1] }]; # Oculink 2 GPIO 1
set_property -dict { PACKAGE_PIN BD19 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][2] }]; # Oculink 2 GPIO 2
set_property -dict { PACKAGE_PIN BD18 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][3] }]; # Oculink 2 GPIO 3
set_property -dict { PACKAGE_PIN BE21 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][4] }]; # Oculink 2 GPIO 4
set_property -dict { PACKAGE_PIN BE20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][5] }]; # Oculink 2 GPIO 5
set_property -dict { PACKAGE_PIN AU20 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][6] }]; # Oculink 2 GPIO 6/Oculink i2c scl
set_property -dict { PACKAGE_PIN AR22 IOSTANDARD LVCMOS18 } [get_ports { ocuLinkVio[1][7] }]; # Oculink 2 GPIO 7/Oculink i2c sda

########
# LEDs #
########

set_property -dict { PACKAGE_PIN AL21 IOSTANDARD LVCMOS18 } [get_ports { ledL[0] }]
set_property -dict { PACKAGE_PIN AL20 IOSTANDARD LVCMOS18 } [get_ports { ledL[1] }]
set_property -dict { PACKAGE_PIN AP21 IOSTANDARD LVCMOS18 } [get_ports { ledL[2] }]
set_property -dict { PACKAGE_PIN AP20 IOSTANDARD LVCMOS18 } [get_ports { ledL[3] }]

#############################
# GTY QSFP Reference Clocks #
#############################

# GTY Bank 120 Refclk 0 / SI5346A CLK 3
set_property PACKAGE_PIN AL36 [get_ports qsfpRefClkP[0]]
set_property PACKAGE_PIN AL37 [get_ports qsfpRefClkN[0]]

# GTY Bank 121 Refclk 0 / SI5346A CLK 2
set_property PACKAGE_PIN AJ36 [get_ports qsfpRefClkP[1]]
set_property PACKAGE_PIN AJ37 [get_ports qsfpRefClkN[1]]

# GTY Bank 122 Refclk 0 / SI5346B CLK 3
set_property PACKAGE_PIN AG36 [get_ports qsfpRefClkP[2]]
set_property PACKAGE_PIN AG37 [get_ports qsfpRefClkN[2]]

# GTY Bank 123 Refclk 0 / SI5346B CLK 2
set_property PACKAGE_PIN AE36 [get_ports qsfpRefClkP[3]]
set_property PACKAGE_PIN AE37 [get_ports qsfpRefClkN[3]]

# GTY Bank 128 Refclk 0 / SI5346A CLK 1
set_property PACKAGE_PIN AC36 [get_ports qsfpRefClkP[4]]
set_property PACKAGE_PIN AC37 [get_ports qsfpRefClkN[4]]

# GTY Bank 129 Refclk 0 / SI5346A CLK 0
set_property PACKAGE_PIN AA36 [get_ports qsfpRefClkP[5]]
set_property PACKAGE_PIN AA37 [get_ports qsfpRefClkN[5]]

# GTY Bank 131 Refclk 0 / SI5346B CLK 1
set_property PACKAGE_PIN U36 [get_ports qsfpRefClkP[6]]
set_property PACKAGE_PIN U37 [get_ports qsfpRefClkN[6]]

# GTY Bank 133 Refclk 0 / SI5346B CLK 0
set_property PACKAGE_PIN R36 [get_ports qsfpRefClkP[7]]
set_property PACKAGE_PIN R37 [get_ports qsfpRefClkN[7]]

##################
# GTY QSFP[31:0] #
##################

# GTY Bank 120 QSFPDD-1 3:0
set_property package_pin BC46 [get_ports qsfpRxN[0]]; # QSFP1_RX_N_0 QSFP Port 0 Input Pin 0
set_property package_pin BC45 [get_ports qsfpRxP[0]]; # QSFP1_RX_P_0 QSFP Port 0 Input Pin 0
set_property package_pin BA46 [get_ports qsfpRxN[1]]; # QSFP1_RX_N_1 QSFP Port 0 Input Pin 1
set_property package_pin BA45 [get_ports qsfpRxP[1]]; # QSFP1_RX_P_1 QSFP Port 0 Input Pin 1
set_property package_pin AW46 [get_ports qsfpRxN[2]]; # QSFP1_RX_N_2 QSFP Port 0 Input Pin 2
set_property package_pin AW45 [get_ports qsfpRxP[2]]; # QSFP1_RX_P_2 QSFP Port 0 Input Pin 2
set_property package_pin AV44 [get_ports qsfpRxN[3]]; # QSFP1_RX_N_3 QSFP Port 0 Input Pin 3
set_property package_pin AV43 [get_ports qsfpRxP[3]]; # QSFP1_RX_P_3 QSFP Port 0 Input Pin 3
set_property package_pin BD43 [get_ports qsfpTxN[0]]; # QSFP1_TX_N_0 QSFP Port 0 Output Pin 0
set_property package_pin BD42 [get_ports qsfpTxP[0]]; # QSFP1_TX_P_0 QSFP Port 0 Output Pin 0
set_property package_pin BB43 [get_ports qsfpTxN[1]]; # QSFP1_TX_N_1 QSFP Port 0 Output Pin 1
set_property package_pin BB42 [get_ports qsfpTxP[1]]; # QSFP1_TX_P_1 QSFP Port 0 Output Pin 1
set_property package_pin AY43 [get_ports qsfpTxN[2]]; # QSFP1_TX_N_2 QSFP Port 0 Output Pin 2
set_property package_pin AY42 [get_ports qsfpTxP[2]]; # QSFP1_TX_P_2 QSFP Port 0 Output Pin 2
set_property package_pin AW41 [get_ports qsfpTxN[3]]; # QSFP1_TX_N_3 QSFP Port 0 Output Pin 3
set_property package_pin AW40 [get_ports qsfpTxP[3]]; # QSFP1_TX_P_3 QSFP Port 0 Output Pin 3

# GTY Bank 121 QSFPDD-1 7:4
set_property package_pin AU46 [get_ports qsfpRxN[4]]; # QSFP1_RX_N_4 QSFP Port 0 Input Pin 4
set_property package_pin AU45 [get_ports qsfpRxP[4]]; # QSFP1_RX_P_4 QSFP Port 0 Input Pin 4
set_property package_pin AT44 [get_ports qsfpRxN[5]]; # QSFP1_RX_N_5 QSFP Port 0 Input Pin 5
set_property package_pin AT43 [get_ports qsfpRxP[5]]; # QSFP1_RX_P_5 QSFP Port 0 Input Pin 5
set_property package_pin AR46 [get_ports qsfpRxN[6]]; # QSFP1_RX_N_6 QSFP Port 0 Input Pin 6
set_property package_pin AR45 [get_ports qsfpRxP[6]]; # QSFP1_RX_P_6 QSFP Port 0 Input Pin 6
set_property package_pin AP44 [get_ports qsfpRxN[7]]; # QSFP1_RX_N_7 QSFP Port 0 Input Pin 7
set_property package_pin AP43 [get_ports qsfpRxP[7]]; # QSFP1_RX_P_7 QSFP Port 0 Input Pin 7
set_property package_pin AU41 [get_ports qsfpTxN[4]]; # QSFP1_TX_N_4 QSFP Port 0 Output Pin 4
set_property package_pin AU40 [get_ports qsfpTxP[4]]; # QSFP1_TX_P_4 QSFP Port 0 Output Pin 4
set_property package_pin AT39 [get_ports qsfpTxN[5]]; # QSFP1_TX_N_5 QSFP Port 0 Output Pin 5
set_property package_pin AT38 [get_ports qsfpTxP[5]]; # QSFP1_TX_P_5 QSFP Port 0 Output Pin 5
set_property package_pin AR41 [get_ports qsfpTxN[6]]; # QSFP1_TX_N_6 QSFP Port 0 Output Pin 6
set_property package_pin AR40 [get_ports qsfpTxP[6]]; # QSFP1_TX_P_6 QSFP Port 0 Output Pin 6
set_property package_pin AP39 [get_ports qsfpTxN[7]]; # QSFP1_TX_N_7 QSFP Port 0 Output Pin 7
set_property package_pin AP38 [get_ports qsfpTxP[7]]; # QSFP1_TX_P_7 QSFP Port 0 Output Pin 7

# GTY Bank 122 QSFPDD-2 3:0
set_property package_pin AN46 [get_ports qsfpRxN[8]];  # QSFP2_RX_N_0 QSFP Port 1 Input Pin 0
set_property package_pin AN45 [get_ports qsfpRxP[8]];  # QSFP2_RX_P_0 QSFP Port 1 Input Pin 0
set_property package_pin AM44 [get_ports qsfpRxN[9]];  # QSFP2_RX_N_1 QSFP Port 1 Input Pin 1
set_property package_pin AM43 [get_ports qsfpRxP[9]];  # QSFP2_RX_P_1 QSFP Port 1 Input Pin 1
set_property package_pin AL46 [get_ports qsfpRxN[10]]; # QSFP2_RX_N_2 QSFP Port 1 Input Pin 2
set_property package_pin AL45 [get_ports qsfpRxP[10]]; # QSFP2_RX_P_2 QSFP Port 1 Input Pin 2
set_property package_pin AK44 [get_ports qsfpRxN[11]]; # QSFP2_RX_N_3 QSFP Port 1 Input Pin 3
set_property package_pin AK43 [get_ports qsfpRxP[11]]; # QSFP2_RX_P_3 QSFP Port 1 Input Pin 3
set_property package_pin AN41 [get_ports qsfpTxN[8]];  # QSFP2_TX_N_0 QSFP Port 1 Output Pin 0
set_property package_pin AN40 [get_ports qsfpTxP[8]];  # QSFP2_TX_P_0 QSFP Port 1 Output Pin 0
set_property package_pin AM39 [get_ports qsfpTxN[9]];  # QSFP2_TX_N_1 QSFP Port 1 Output Pin 1
set_property package_pin AM38 [get_ports qsfpTxP[9]];  # QSFP2_TX_P_1 QSFP Port 1 Output Pin 1
set_property package_pin AL41 [get_ports qsfpTxN[10]]; # QSFP2_TX_N_2 QSFP Port 1 Output Pin 2
set_property package_pin AL40 [get_ports qsfpTxP[10]]; # QSFP2_TX_P_2 QSFP Port 1 Output Pin 2
set_property package_pin AK39 [get_ports qsfpTxN[11]]; # QSFP2_TX_N_3 QSFP Port 1 Output Pin 3
set_property package_pin AK38 [get_ports qsfpTxP[11]]; # QSFP2_TX_P_3 QSFP Port 1 Output Pin 3

# GTY Bank 123 QSFPDD-2 7:4
set_property package_pin AJ46 [get_ports qsfpRxN[12]]; # QSFP2_RX_N_4 QSFP Port 1 Input Pin 4
set_property package_pin AJ45 [get_ports qsfpRxP[12]]; # QSFP2_RX_P_4 QSFP Port 1 Input Pin 4
set_property package_pin AH44 [get_ports qsfpRxN[13]]; # QSFP2_RX_N_5 QSFP Port 1 Input Pin 5
set_property package_pin AH43 [get_ports qsfpRxP[13]]; # QSFP2_RX_P_5 QSFP Port 1 Input Pin 5
set_property package_pin AG46 [get_ports qsfpRxN[14]]; # QSFP2_RX_N_6 QSFP Port 1 Input Pin 6
set_property package_pin AG45 [get_ports qsfpRxP[14]]; # QSFP2_RX_P_6 QSFP Port 1 Input Pin 6
set_property package_pin AF44 [get_ports qsfpRxN[15]]; # QSFP2_RX_N_7 QSFP Port 1 Input Pin 7
set_property package_pin AF43 [get_ports qsfpRxP[15]]; # QSFP2_RX_P_7 QSFP Port 1 Input Pin 7
set_property package_pin AJ41 [get_ports qsfpTxN[12]]; # QSFP2_TX_N_4 QSFP Port 1 Output Pin 4
set_property package_pin AJ40 [get_ports qsfpTxP[12]]; # QSFP2_TX_P_4 QSFP Port 1 Output Pin 4
set_property package_pin AH39 [get_ports qsfpTxN[13]]; # QSFP2_TX_N_5 QSFP Port 1 Output Pin 5
set_property package_pin AH38 [get_ports qsfpTxP[13]]; # QSFP2_TX_P_5 QSFP Port 1 Output Pin 5
set_property package_pin AG41 [get_ports qsfpTxN[14]]; # QSFP2_TX_N_6 QSFP Port 1 Output Pin 6
set_property package_pin AG40 [get_ports qsfpTxP[14]]; # QSFP2_TX_P_6 QSFP Port 1 Output Pin 6
set_property package_pin AF39 [get_ports qsfpTxN[15]]; # QSFP2_TX_N_7 QSFP Port 1 Output Pin 7
set_property package_pin AF38 [get_ports qsfpTxP[15]]; # QSFP2_TX_P_7 QSFP Port 1 Output Pin 7

# GTY Bank 128 QSFPDD-3 3:0
set_property package_pin AE46 [get_ports qsfpRxN[16]]; # QSFP3_RX_N_0 QSFP Port 2 Input Pin 0
set_property package_pin AE45 [get_ports qsfpRxP[16]]; # QSFP3_RX_P_0 QSFP Port 2 Input Pin 0
set_property package_pin AD44 [get_ports qsfpRxN[17]]; # QSFP3_RX_N_1 QSFP Port 2 Input Pin 1
set_property package_pin AD43 [get_ports qsfpRxP[17]]; # QSFP3_RX_P_1 QSFP Port 2 Input Pin 1
set_property package_pin AC46 [get_ports qsfpRxN[18]]; # QSFP3_RX_N_2 QSFP Port 2 Input Pin 2
set_property package_pin AC45 [get_ports qsfpRxP[18]]; # QSFP3_RX_P_2 QSFP Port 2 Input Pin 2
set_property package_pin AB44 [get_ports qsfpRxN[19]]; # QSFP3_RX_N_3 QSFP Port 2 Input Pin 3
set_property package_pin AB43 [get_ports qsfpRxP[19]]; # QSFP3_RX_P_3 QSFP Port 2 Input Pin 3
set_property package_pin AE41 [get_ports qsfpTxN[16]]; # QSFP3_TX_N_0 QSFP Port 2 Output Pin 0
set_property package_pin AE40 [get_ports qsfpTxP[16]]; # QSFP3_TX_P_0 QSFP Port 2 Output Pin 0
set_property package_pin AD39 [get_ports qsfpTxN[17]]; # QSFP3_TX_N_1 QSFP Port 2 Output Pin 1
set_property package_pin AD38 [get_ports qsfpTxP[17]]; # QSFP3_TX_P_1 QSFP Port 2 Output Pin 1
set_property package_pin AC41 [get_ports qsfpTxN[18]]; # QSFP3_TX_N_2 QSFP Port 2 Output Pin 2
set_property package_pin AC40 [get_ports qsfpTxP[18]]; # QSFP3_TX_P_2 QSFP Port 2 Output Pin 2
set_property package_pin AB39 [get_ports qsfpTxN[19]]; # QSFP3_TX_N_3 QSFP Port 2 Output Pin 3
set_property package_pin AB38 [get_ports qsfpTxP[19]]; # QSFP3_TX_P_3 QSFP Port 2 Output Pin 3

# GTY Bank 129 QSFPDD-3 7:4
set_property package_pin AA46 [get_ports qsfpRxN[20]]; # QSFP3_RX_N_4 QSFP Port 2 Input Pin 4
set_property package_pin AA45 [get_ports qsfpRxP[20]]; # QSFP3_RX_P_4 QSFP Port 2 Input Pin 4
set_property package_pin Y44  [get_ports qsfpRxN[21]]; # QSFP3_RX_N_5 QSFP Port 2 Input Pin 5
set_property package_pin Y43  [get_ports qsfpRxP[21]]; # QSFP3_RX_P_5 QSFP Port 2 Input Pin 5
set_property package_pin W46  [get_ports qsfpRxN[22]]; # QSFP3_RX_N_6 QSFP Port 2 Input Pin 6
set_property package_pin W45  [get_ports qsfpRxP[22]]; # QSFP3_RX_P_6 QSFP Port 2 Input Pin 6
set_property package_pin V44  [get_ports qsfpRxN[23]]; # QSFP3_RX_N_7 QSFP Port 2 Input Pin 7
set_property package_pin V43  [get_ports qsfpRxP[23]]; # QSFP3_RX_P_7 QSFP Port 2 Input Pin 7
set_property package_pin AA41 [get_ports qsfpTxN[20]]; # QSFP3_TX_N_4 QSFP Port 2 Output Pin 4
set_property package_pin AA40 [get_ports qsfpTxP[20]]; # QSFP3_TX_P_4 QSFP Port 2 Output Pin 4
set_property package_pin Y39  [get_ports qsfpTxN[21]]; # QSFP3_TX_N_5 QSFP Port 2 Output Pin 5
set_property package_pin Y38  [get_ports qsfpTxP[21]]; # QSFP3_TX_P_5 QSFP Port 2 Output Pin 5
set_property package_pin W41  [get_ports qsfpTxN[22]]; # QSFP3_TX_N_6 QSFP Port 2 Output Pin 6
set_property package_pin W40  [get_ports qsfpTxP[22]]; # QSFP3_TX_P_6 QSFP Port 2 Output Pin 6
set_property package_pin V39  [get_ports qsfpTxN[23]]; # QSFP3_TX_N_7 QSFP Port 2 Output Pin 7
set_property package_pin V38  [get_ports qsfpTxP[23]]; # QSFP3_TX_P_7 QSFP Port 2 Output Pin 7

# GTY Bank 131 QSFPDD-4 3:0
set_property package_pin N46 [get_ports qsfpRxN[24]]; # QSFP4_RX_N_0 QSFP Port 3 Input Pin 0
set_property package_pin N45 [get_ports qsfpRxP[24]]; # QSFP4_RX_P_0 QSFP Port 3 Input Pin 0
set_property package_pin M44 [get_ports qsfpRxN[25]]; # QSFP4_RX_N_1 QSFP Port 3 Input Pin 1
set_property package_pin M43 [get_ports qsfpRxP[25]]; # QSFP4_RX_P_1 QSFP Port 3 Input Pin 1
set_property package_pin L46 [get_ports qsfpRxN[26]]; # QSFP4_RX_N_2 QSFP Port 3 Input Pin 2
set_property package_pin L45 [get_ports qsfpRxP[26]]; # QSFP4_RX_P_2 QSFP Port 3 Input Pin 2
set_property package_pin K44 [get_ports qsfpRxN[27]]; # QSFP4_RX_N_3 QSFP Port 3 Input Pin 3
set_property package_pin K43 [get_ports qsfpRxP[27]]; # QSFP4_RX_P_3 QSFP Port 3 Input Pin 3
set_property package_pin N41 [get_ports qsfpTxN[24]]; # QSFP4_TX_N_0 QSFP Port 3 Output Pin 0
set_property package_pin N40 [get_ports qsfpTxP[24]]; # QSFP4_TX_P_0 QSFP Port 3 Output Pin 0
set_property package_pin M39 [get_ports qsfpTxN[25]]; # QSFP4_TX_N_1 QSFP Port 3 Output Pin 1
set_property package_pin M38 [get_ports qsfpTxP[25]]; # QSFP4_TX_P_1 QSFP Port 3 Output Pin 1
set_property package_pin L41 [get_ports qsfpTxN[26]]; # QSFP4_TX_N_2 QSFP Port 3 Output Pin 2
set_property package_pin L40 [get_ports qsfpTxP[26]]; # QSFP4_TX_P_2 QSFP Port 3 Output Pin 2
set_property package_pin J41 [get_ports qsfpTxN[27]]; # QSFP4_TX_N_3 QSFP Port 3 Output Pin 3
set_property package_pin J40 [get_ports qsfpTxP[27]]; # QSFP4_TX_P_3 QSFP Port 3 Output Pin 3

# GTY Bank 133 QSFPDD-4 7:4
set_property package_pin J46 [get_ports qsfpRxN[28]]; # QSFP4_RX_N_4 QSFP Port 3 Input Pin 4
set_property package_pin J45 [get_ports qsfpRxP[28]]; # QSFP4_RX_P_4 QSFP Port 3 Input Pin 4
set_property package_pin H44 [get_ports qsfpRxN[29]]; # QSFP4_RX_N_5 QSFP Port 3 Input Pin 5
set_property package_pin H43 [get_ports qsfpRxP[29]]; # QSFP4_RX_P_5 QSFP Port 3 Input Pin 5
set_property package_pin F46 [get_ports qsfpRxN[30]]; # QSFP4_RX_N_6 QSFP Port 3 Input Pin 6
set_property package_pin F45 [get_ports qsfpRxP[30]]; # QSFP4_RX_P_6 QSFP Port 3 Input Pin 6
set_property package_pin D46 [get_ports qsfpRxN[31]]; # QSFP4_RX_N_7 QSFP Port 3 Input Pin 7
set_property package_pin D45 [get_ports qsfpRxP[31]]; # QSFP4_RX_P_7 QSFP Port 3 Input Pin 7
set_property package_pin G41 [get_ports qsfpTxN[28]]; # QSFP4_TX_N_4 QSFP Port 3 Output Pin 4
set_property package_pin G40 [get_ports qsfpTxP[28]]; # QSFP4_TX_P_4 QSFP Port 3 Output Pin 4
set_property package_pin E43 [get_ports qsfpTxN[29]]; # QSFP4_TX_N_5 QSFP Port 3 Output Pin 5
set_property package_pin E42 [get_ports qsfpTxP[29]]; # QSFP4_TX_P_5 QSFP Port 3 Output Pin 5
set_property package_pin C43 [get_ports qsfpTxN[30]]; # QSFP4_TX_N_6 QSFP Port 3 Output Pin 6
set_property package_pin C42 [get_ports qsfpTxP[30]]; # QSFP4_TX_P_6 QSFP Port 3 Output Pin 6
set_property package_pin A43 [get_ports qsfpTxN[31]]; # QSFP4_TX_N_7 QSFP Port 3 Output Pin 7
set_property package_pin A42 [get_ports qsfpTxP[31]]; # QSFP4_TX_P_7 QSFP Port 3 Output Pin 7

################################
# GTY Oculink Reference Clocks #
################################

# GTY Bank 231 OCU 1 OSC 0
set_property PACKAGE_PIN M11 [get_ports ocuLinkRefClkP[0]]
set_property PACKAGE_PIN M10 [get_ports ocuLinkRefClkN[0]]

# GTY Bank 232 OCU 2 CLK 0
set_property PACKAGE_PIN H11 [get_ports ocuLinkRefClkP[1]]
set_property PACKAGE_PIN H10 [get_ports ocuLinkRefClkN[1]]

####################
# GTY Oculink[7:0] #
####################

# GTY BANK 231 OCU 1 3:0
set_property package_pin N3 [get_ports ocuLinkRxN[0]]; # OCU1_RXN_0 Oculink 1 Input Pin 0
set_property package_pin N4 [get_ports ocuLinkRxP[0]]; # OCU1_RXP_0
set_property package_pin M1 [get_ports ocuLinkRxN[1]]; # OCU1_RXN_1 Oculink 1 Input Pin 1
set_property package_pin M2 [get_ports ocuLinkRxP[1]]; # OCU1_RXP_1
set_property package_pin L3 [get_ports ocuLinkRxN[2]]; # OCU1_RXN_2 Oculink 1 Input Pin 2
set_property package_pin L4 [get_ports ocuLinkRxP[2]]; # OCU1_RXP_2
set_property package_pin K1 [get_ports ocuLinkRxN[3]]; # OCU1_RXN_3 Oculink 1 Input Pin 3
set_property package_pin K2 [get_ports ocuLinkRxP[3]]; # OCU1_RXP_3
set_property package_pin N8 [get_ports ocuLinkTxN[0]]; # OCU1_TXN_0 Oculink 1 Output Pin 0
set_property package_pin N9 [get_ports ocuLinkTxP[0]]; # OCU1_TXP_0
set_property package_pin M6 [get_ports ocuLinkTxN[1]]; # OCU1_TXN_1 Oculink 1 Output Pin 1
set_property package_pin M7 [get_ports ocuLinkTxP[1]]; # OCU1_TXP_1
set_property package_pin L8 [get_ports ocuLinkTxN[2]]; # OCU1_TXN_2 Oculink 1 Output Pin 2
set_property package_pin L9 [get_ports ocuLinkTxP[2]]; # OCU1_TXP_2
set_property package_pin K6 [get_ports ocuLinkTxN[3]]; # OCU1_TXN_3 Oculink 1 Output Pin 3
set_property package_pin K7 [get_ports ocuLinkTxP[3]]; # OCU1_TXP_3

# GTY BANK 232 OCU 2 3:0
set_property package_pin J3 [get_ports ocuLinkRxN[4]]; # OCU2_RXN_0 Oculink 2 Input Pin 0
set_property package_pin J4 [get_ports ocuLinkRxP[4]]; # OCU2_RXP_0
set_property package_pin H1 [get_ports ocuLinkRxN[5]]; # OCU2_RXN_1 Oculink 2 Input Pin 1
set_property package_pin H2 [get_ports ocuLinkRxP[5]]; # OCU2_RXP_1
set_property package_pin G3 [get_ports ocuLinkRxN[6]]; # OCU2_RXN_2 Oculink 2 Input Pin 2
set_property package_pin G4 [get_ports ocuLinkRxP[6]]; # OCU2_RXP_2
set_property package_pin F1 [get_ports ocuLinkRxN[7]]; # OCU2_RXN_3 Oculink 2 Input Pin 3
set_property package_pin F2 [get_ports ocuLinkRxP[7]]; # OCU2_RXP_3
set_property package_pin J8 [get_ports ocuLinkTxN[4]]; # OCU2_TXN_0 Oculink 2 Output Pin 0
set_property package_pin J9 [get_ports ocuLinkTxP[4]]; # OCU2_TXP_0
set_property package_pin H6 [get_ports ocuLinkTxN[5]]; # OCU2_TXN_1 Oculink 2 Output Pin 1
set_property package_pin H7 [get_ports ocuLinkTxP[5]]; # OCU2_TXP_1
set_property package_pin G8 [get_ports ocuLinkTxN[6]]; # OCU2_TXN_2 Oculink 2 Output Pin 2
set_property package_pin G9 [get_ports ocuLinkTxP[6]]; # OCU2_TXP_2
set_property package_pin F6 [get_ports ocuLinkTxN[7]]; # OCU2_TXN_3 Oculink 2 Output Pin 3
set_property package_pin F7 [get_ports ocuLinkTxP[7]]; # OCU2_TXP_3

##########
# Clocks #
##########

create_clock -period 100.0 -name extRefClk   [get_ports {extRefClk}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets extRefClk_IBUF_inst/O]

create_clock -period 10.00 -name ocuLinkRefClk0 [get_ports {ocuLinkRefClkP[0]}]
create_clock -period 10.00 -name ocuLinkRefClk1 [get_ports {ocuLinkRefClkP[1]}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {extRefClk}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {ocuLinkRefClk0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {ocuLinkRefClk1}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {extRefClk}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {ocuLinkRefClk0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {ocuLinkRefClk1}]
