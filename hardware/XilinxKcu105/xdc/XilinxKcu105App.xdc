##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { PACKAGE_PIN AN8 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN AP8 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN H23 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN P20 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN P21 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN N22 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN M22 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN R23 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN P23 } [get_ports { led[7] }]

set_property PACKAGE_PIN W4 [get_ports sfpTxP[1]]
set_property PACKAGE_PIN W3 [get_ports sfpTxN[1]]
set_property PACKAGE_PIN V2 [get_ports sfpRxP[1]]
set_property PACKAGE_PIN V1 [get_ports sfpRxN[1]]

set_property PACKAGE_PIN U4 [get_ports sfpTxP[0]]
set_property PACKAGE_PIN U3 [get_ports sfpTxN[0]]
set_property PACKAGE_PIN T2 [get_ports sfpRxP[0]]
set_property PACKAGE_PIN T1 [get_ports sfpRxN[0]]

set_property PACKAGE_PIN P6 [get_ports sfpClk156P]
set_property PACKAGE_PIN P5 [get_ports sfpClk156N]

set_property -dict { PACKAGE_PIN J24 } [get_ports { fmcScl }]
set_property -dict { PACKAGE_PIN J25 } [get_ports { fmcSda }]

set_property -dict { PACKAGE_PIN AK17 IOSTANDARD DIFF_SSTL12_DCI ODT RTT_48 } [get_ports { sysClk300P }]
set_property -dict { PACKAGE_PIN AK16 IOSTANDARD DIFF_SSTL12_DCI ODT RTT_48 } [get_ports { sysClk300N }]

set_property PACKAGE_PIN R4 [get_ports { smaMgtTxP }]
set_property PACKAGE_PIN R3 [get_ports { smaMgtTxN }]

set_property PACKAGE_PIN P2 [get_ports { smaMgtRxP }]
set_property PACKAGE_PIN P1 [get_ports { smaMgtRxN }]

set_property PACKAGE_PIN V6 [get_ports { smaMgtClkP }]
set_property PACKAGE_PIN V5 [get_ports { smaMgtClkN }]

set_property PACKAGE_PIN D23 [get_ports { smaUserClkP }]
set_property PACKAGE_PIN C23 [get_ports { smaUserClkN }]

set_property PACKAGE_PIN H27 [get_ports { smaUserGpioP }]
set_property PACKAGE_PIN G27 [get_ports { smaUserGpioN }]

##############################################################################

set_property PACKAGE_PIN H11 [get_ports { fmcHpcLaP[0] }]
set_property PACKAGE_PIN G11 [get_ports { fmcHpcLaN[0] }]
set_property PACKAGE_PIN G9  [get_ports { fmcHpcLaP[1] }]
set_property PACKAGE_PIN F9  [get_ports { fmcHpcLaN[1] }]
set_property PACKAGE_PIN K10 [get_ports { fmcHpcLaP[2] }]
set_property PACKAGE_PIN J10 [get_ports { fmcHpcLaN[2] }]
set_property PACKAGE_PIN A13 [get_ports { fmcHpcLaP[3] }]
set_property PACKAGE_PIN A12 [get_ports { fmcHpcLaN[3] }]
set_property PACKAGE_PIN L12 [get_ports { fmcHpcLaP[4] }]
set_property PACKAGE_PIN K12 [get_ports { fmcHpcLaN[4] }]
set_property PACKAGE_PIN L13 [get_ports { fmcHpcLaP[5] }]
set_property PACKAGE_PIN K13 [get_ports { fmcHpcLaN[5] }]
set_property PACKAGE_PIN D13 [get_ports { fmcHpcLaP[6] }]
set_property PACKAGE_PIN C13 [get_ports { fmcHpcLaN[6] }]
set_property PACKAGE_PIN F8  [get_ports { fmcHpcLaP[7] }]
set_property PACKAGE_PIN E8  [get_ports { fmcHpcLaN[7] }]
set_property PACKAGE_PIN J8  [get_ports { fmcHpcLaP[8] }]
set_property PACKAGE_PIN H8  [get_ports { fmcHpcLaN[8] }]
set_property PACKAGE_PIN J9  [get_ports { fmcHpcLaP[9] }]
set_property PACKAGE_PIN H9  [get_ports { fmcHpcLaN[9] }]
set_property PACKAGE_PIN L8  [get_ports { fmcHpcLaP[10] }]
set_property PACKAGE_PIN K8  [get_ports { fmcHpcLaN[10] }]
set_property PACKAGE_PIN K11 [get_ports { fmcHpcLaP[11] }]
set_property PACKAGE_PIN J11 [get_ports { fmcHpcLaN[11] }]
set_property PACKAGE_PIN E10 [get_ports { fmcHpcLaP[12] }]
set_property PACKAGE_PIN D10 [get_ports { fmcHpcLaN[12] }]
set_property PACKAGE_PIN D9  [get_ports { fmcHpcLaP[13] }]
set_property PACKAGE_PIN C9  [get_ports { fmcHpcLaN[13] }]
set_property PACKAGE_PIN B10 [get_ports { fmcHpcLaP[14] }]
set_property PACKAGE_PIN A10 [get_ports { fmcHpcLaN[14] }]
set_property PACKAGE_PIN D8  [get_ports { fmcHpcLaP[15] }]
set_property PACKAGE_PIN C8  [get_ports { fmcHpcLaN[15] }]
set_property PACKAGE_PIN B9  [get_ports { fmcHpcLaP[16] }]
set_property PACKAGE_PIN A9  [get_ports { fmcHpcLaN[16] }]
set_property PACKAGE_PIN D24 [get_ports { fmcHpcLaP[17] }]
set_property PACKAGE_PIN C24 [get_ports { fmcHpcLaN[17] }]
set_property PACKAGE_PIN E22 [get_ports { fmcHpcLaP[18] }]
set_property PACKAGE_PIN E23 [get_ports { fmcHpcLaN[18] }]
set_property PACKAGE_PIN C21 [get_ports { fmcHpcLaP[19] }]
set_property PACKAGE_PIN C22 [get_ports { fmcHpcLaN[19] }]
set_property PACKAGE_PIN B24 [get_ports { fmcHpcLaP[20] }]
set_property PACKAGE_PIN A24 [get_ports { fmcHpcLaN[20] }]
set_property PACKAGE_PIN F23 [get_ports { fmcHpcLaP[21] }]
set_property PACKAGE_PIN F24 [get_ports { fmcHpcLaN[21] }]
set_property PACKAGE_PIN G24 [get_ports { fmcHpcLaP[22] }]
set_property PACKAGE_PIN F25 [get_ports { fmcHpcLaN[22] }]
set_property PACKAGE_PIN G22 [get_ports { fmcHpcLaP[23] }]
set_property PACKAGE_PIN F22 [get_ports { fmcHpcLaN[23] }]
set_property PACKAGE_PIN E20 [get_ports { fmcHpcLaP[24] }]
set_property PACKAGE_PIN E21 [get_ports { fmcHpcLaN[24] }]
set_property PACKAGE_PIN D20 [get_ports { fmcHpcLaP[25] }]
set_property PACKAGE_PIN D21 [get_ports { fmcHpcLaN[25] }]
set_property PACKAGE_PIN G20 [get_ports { fmcHpcLaP[26] }]
set_property PACKAGE_PIN F20 [get_ports { fmcHpcLaN[26] }]
set_property PACKAGE_PIN H21 [get_ports { fmcHpcLaP[27] }]
set_property PACKAGE_PIN G21 [get_ports { fmcHpcLaN[27] }]
set_property PACKAGE_PIN B21 [get_ports { fmcHpcLaP[28] }]
set_property PACKAGE_PIN B22 [get_ports { fmcHpcLaN[28] }]
set_property PACKAGE_PIN B20 [get_ports { fmcHpcLaP[29] }]
set_property PACKAGE_PIN A20 [get_ports { fmcHpcLaN[29] }]
set_property PACKAGE_PIN C26 [get_ports { fmcHpcLaP[30] }]
set_property PACKAGE_PIN B26 [get_ports { fmcHpcLaN[30] }]
set_property PACKAGE_PIN B25 [get_ports { fmcHpcLaP[31] }]
set_property PACKAGE_PIN A25 [get_ports { fmcHpcLaN[31] }]
set_property PACKAGE_PIN E26 [get_ports { fmcHpcLaP[32] }]
set_property PACKAGE_PIN D26 [get_ports { fmcHpcLaN[32] }]
set_property PACKAGE_PIN A27 [get_ports { fmcHpcLaP[33] }]
set_property PACKAGE_PIN A28 [get_ports { fmcHpcLaN[33] }]

set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpcLaP[*] }]
set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpcLaN[*] }]

##############################################################################

set_property PACKAGE_PIN W23  [get_ports { fmcLpcLaP[0] }]
set_property PACKAGE_PIN W24  [get_ports { fmcLpcLaN[0] }]
set_property PACKAGE_PIN W25  [get_ports { fmcLpcLaP[1] }]
set_property PACKAGE_PIN Y25  [get_ports { fmcLpcLaN[1] }]
set_property PACKAGE_PIN AA22 [get_ports { fmcLpcLaP[2] }]
set_property PACKAGE_PIN AB22 [get_ports { fmcLpcLaN[2] }]
set_property PACKAGE_PIN W28  [get_ports { fmcLpcLaP[3] }]
set_property PACKAGE_PIN Y28  [get_ports { fmcLpcLaN[3] }]
set_property PACKAGE_PIN U26  [get_ports { fmcLpcLaP[4] }]
set_property PACKAGE_PIN U27  [get_ports { fmcLpcLaN[4] }]
set_property PACKAGE_PIN V27  [get_ports { fmcLpcLaP[5] }]
set_property PACKAGE_PIN V28  [get_ports { fmcLpcLaN[5] }]
set_property PACKAGE_PIN V29  [get_ports { fmcLpcLaP[6] }]
set_property PACKAGE_PIN W29  [get_ports { fmcLpcLaN[6] }]
set_property PACKAGE_PIN V22  [get_ports { fmcLpcLaP[7] }]
set_property PACKAGE_PIN V23  [get_ports { fmcLpcLaN[7] }]
set_property PACKAGE_PIN U24  [get_ports { fmcLpcLaP[8] }]
set_property PACKAGE_PIN U25  [get_ports { fmcLpcLaN[8] }]
set_property PACKAGE_PIN V26  [get_ports { fmcLpcLaP[9] }]
set_property PACKAGE_PIN W26  [get_ports { fmcLpcLaN[9] }]
set_property PACKAGE_PIN T22  [get_ports { fmcLpcLaP[10] }]
set_property PACKAGE_PIN T23  [get_ports { fmcLpcLaN[10] }]
set_property PACKAGE_PIN V21  [get_ports { fmcLpcLaP[11] }]
set_property PACKAGE_PIN W21  [get_ports { fmcLpcLaN[11] }]
set_property PACKAGE_PIN AC22 [get_ports { fmcLpcLaP[12] }]
set_property PACKAGE_PIN AC23 [get_ports { fmcLpcLaN[12] }]
set_property PACKAGE_PIN AA20 [get_ports { fmcLpcLaP[13] }]
set_property PACKAGE_PIN AB20 [get_ports { fmcLpcLaN[13] }]
set_property PACKAGE_PIN U21  [get_ports { fmcLpcLaP[14] }]
set_property PACKAGE_PIN U22  [get_ports { fmcLpcLaN[14] }]
set_property PACKAGE_PIN AB25 [get_ports { fmcLpcLaP[15] }]
set_property PACKAGE_PIN AB26 [get_ports { fmcLpcLaN[15] }]
set_property PACKAGE_PIN AB21 [get_ports { fmcLpcLaP[16] }]
set_property PACKAGE_PIN AC21 [get_ports { fmcLpcLaN[16] }]
set_property PACKAGE_PIN AA32 [get_ports { fmcLpcLaP[17] }]
set_property PACKAGE_PIN AB32 [get_ports { fmcLpcLaN[17] }]
set_property PACKAGE_PIN AB30 [get_ports { fmcLpcLaP[18] }]
set_property PACKAGE_PIN AB31 [get_ports { fmcLpcLaN[18] }]
set_property PACKAGE_PIN AA29 [get_ports { fmcLpcLaP[19] }]
set_property PACKAGE_PIN AB29 [get_ports { fmcLpcLaN[19] }]
set_property PACKAGE_PIN AA34 [get_ports { fmcLpcLaP[20] }]
set_property PACKAGE_PIN AB34 [get_ports { fmcLpcLaN[20] }]
set_property PACKAGE_PIN AC33 [get_ports { fmcLpcLaP[21] }]
set_property PACKAGE_PIN AD33 [get_ports { fmcLpcLaN[21] }]
set_property PACKAGE_PIN AC34 [get_ports { fmcLpcLaP[22] }]
set_property PACKAGE_PIN AD34 [get_ports { fmcLpcLaN[22] }]
set_property PACKAGE_PIN AD30 [get_ports { fmcLpcLaP[23] }]
set_property PACKAGE_PIN AD31 [get_ports { fmcLpcLaN[23] }]
set_property PACKAGE_PIN AE32 [get_ports { fmcLpcLaP[24] }]
set_property PACKAGE_PIN AF32 [get_ports { fmcLpcLaN[24] }]
set_property PACKAGE_PIN AE33 [get_ports { fmcLpcLaP[25] }]
set_property PACKAGE_PIN AF34 [get_ports { fmcLpcLaN[25] }]
set_property PACKAGE_PIN AF33 [get_ports { fmcLpcLaP[26] }]
set_property PACKAGE_PIN AG34 [get_ports { fmcLpcLaN[26] }]
set_property PACKAGE_PIN AG31 [get_ports { fmcLpcLaP[27] }]
set_property PACKAGE_PIN AG32 [get_ports { fmcLpcLaN[27] }]
set_property PACKAGE_PIN V31  [get_ports { fmcLpcLaP[28] }]
set_property PACKAGE_PIN W31  [get_ports { fmcLpcLaN[28] }]
set_property PACKAGE_PIN U34  [get_ports { fmcLpcLaP[29] }]
set_property PACKAGE_PIN V34  [get_ports { fmcLpcLaN[29] }]
set_property PACKAGE_PIN Y31  [get_ports { fmcLpcLaP[30] }]
set_property PACKAGE_PIN Y32  [get_ports { fmcLpcLaN[30] }]
set_property PACKAGE_PIN V33  [get_ports { fmcLpcLaP[31] }]
set_property PACKAGE_PIN W34  [get_ports { fmcLpcLaN[31] }]
set_property PACKAGE_PIN W30  [get_ports { fmcLpcLaP[32] }]
set_property PACKAGE_PIN Y30  [get_ports { fmcLpcLaN[32] }]
set_property PACKAGE_PIN W33  [get_ports { fmcLpcLaP[33] }]
set_property PACKAGE_PIN Y33  [get_ports { fmcLpcLaN[33] }]

set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcLpcLaP[*] }]
set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcLpcLaN[*] }]

##############################################################################

####################
# Timing Constraints
####################

create_clock -name sfpClk156P -period 6.400 [get_ports {sfpClk156P}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {sfpClk156P}]
