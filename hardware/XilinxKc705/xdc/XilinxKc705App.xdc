##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS18 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 4 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN AA8 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 4 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN AC9 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 4 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN AB9 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 4 } [get_ports { led[3] }];

set_property -dict { PACKAGE_PIN AE26 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 4 } [get_ports { led[4] }];
set_property -dict { PACKAGE_PIN G19  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 4 } [get_ports { led[5] }];
set_property -dict { PACKAGE_PIN E18  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 4 } [get_ports { led[6] }];
set_property -dict { PACKAGE_PIN F16  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 4 } [get_ports { led[7] }];

set_property PACKAGE_PIN H2 [get_ports sfpTxP]
set_property PACKAGE_PIN H1 [get_ports sfpTxN]
set_property PACKAGE_PIN G4 [get_ports sfpRxP]
set_property PACKAGE_PIN G3 [get_ports sfpRxN]

set_property PACKAGE_PIN G8 [get_ports sfpClk125P]
set_property PACKAGE_PIN G7 [get_ports sfpClk125N]

##############################################################################

set_property PACKAGE_PIN C25 [get_ports { fmcHpcLaP[0] }]
set_property PACKAGE_PIN B25 [get_ports { fmcHpcLaN[0] }]
set_property PACKAGE_PIN D26 [get_ports { fmcHpcLaP[1] }]
set_property PACKAGE_PIN C26 [get_ports { fmcHpcLaN[1] }]
set_property PACKAGE_PIN H24 [get_ports { fmcHpcLaP[2] }]
set_property PACKAGE_PIN H25 [get_ports { fmcHpcLaN[2] }]
set_property PACKAGE_PIN H26 [get_ports { fmcHpcLaP[3] }]
set_property PACKAGE_PIN H27 [get_ports { fmcHpcLaN[3] }]
set_property PACKAGE_PIN G28 [get_ports { fmcHpcLaP[4] }]
set_property PACKAGE_PIN F28 [get_ports { fmcHpcLaN[4] }]
set_property PACKAGE_PIN G29 [get_ports { fmcHpcLaP[5] }]
set_property PACKAGE_PIN F30 [get_ports { fmcHpcLaN[5] }]
set_property PACKAGE_PIN H30 [get_ports { fmcHpcLaP[6] }]
set_property PACKAGE_PIN G30 [get_ports { fmcHpcLaN[6] }]
set_property PACKAGE_PIN E28 [get_ports { fmcHpcLaP[7] }]
set_property PACKAGE_PIN D28 [get_ports { fmcHpcLaN[7] }]
set_property PACKAGE_PIN E29 [get_ports { fmcHpcLaP[8] }]
set_property PACKAGE_PIN E30 [get_ports { fmcHpcLaN[8] }]
set_property PACKAGE_PIN B30 [get_ports { fmcHpcLaP[9] }]
set_property PACKAGE_PIN A30 [get_ports { fmcHpcLaN[9] }]
set_property PACKAGE_PIN D29 [get_ports { fmcHpcLaP[10] }]
set_property PACKAGE_PIN C30 [get_ports { fmcHpcLaN[10] }]
set_property PACKAGE_PIN G27 [get_ports { fmcHpcLaP[11] }]
set_property PACKAGE_PIN F27 [get_ports { fmcHpcLaN[11] }]
set_property PACKAGE_PIN C29 [get_ports { fmcHpcLaP[12] }]
set_property PACKAGE_PIN B29 [get_ports { fmcHpcLaN[12] }]
set_property PACKAGE_PIN A25 [get_ports { fmcHpcLaP[13] }]
set_property PACKAGE_PIN A26 [get_ports { fmcHpcLaN[13] }]
set_property PACKAGE_PIN B28 [get_ports { fmcHpcLaP[14] }]
set_property PACKAGE_PIN A28 [get_ports { fmcHpcLaN[14] }]
set_property PACKAGE_PIN C24 [get_ports { fmcHpcLaP[15] }]
set_property PACKAGE_PIN B24 [get_ports { fmcHpcLaN[15] }]
set_property PACKAGE_PIN B27 [get_ports { fmcHpcLaP[16] }]
set_property PACKAGE_PIN A27 [get_ports { fmcHpcLaN[16] }]
set_property PACKAGE_PIN F20 [get_ports { fmcHpcLaP[17] }]
set_property PACKAGE_PIN E20 [get_ports { fmcHpcLaN[17] }]
set_property PACKAGE_PIN F21 [get_ports { fmcHpcLaP[18] }]
set_property PACKAGE_PIN E21 [get_ports { fmcHpcLaN[18] }]
set_property PACKAGE_PIN G18 [get_ports { fmcHpcLaP[19] }]
set_property PACKAGE_PIN F18 [get_ports { fmcHpcLaN[19] }]
set_property PACKAGE_PIN E19 [get_ports { fmcHpcLaP[20] }]
set_property PACKAGE_PIN D19 [get_ports { fmcHpcLaN[20] }]
set_property PACKAGE_PIN A20 [get_ports { fmcHpcLaP[21] }]
set_property PACKAGE_PIN A21 [get_ports { fmcHpcLaN[21] }]
set_property PACKAGE_PIN C20 [get_ports { fmcHpcLaP[22] }]
set_property PACKAGE_PIN B20 [get_ports { fmcHpcLaN[22] }]
set_property PACKAGE_PIN B22 [get_ports { fmcHpcLaP[23] }]
set_property PACKAGE_PIN A22 [get_ports { fmcHpcLaN[23] }]
set_property PACKAGE_PIN A16 [get_ports { fmcHpcLaP[24] }]
set_property PACKAGE_PIN A17 [get_ports { fmcHpcLaN[24] }]
set_property PACKAGE_PIN G17 [get_ports { fmcHpcLaP[25] }]
set_property PACKAGE_PIN F17 [get_ports { fmcHpcLaN[25] }]
set_property PACKAGE_PIN B18 [get_ports { fmcHpcLaP[26] }]
set_property PACKAGE_PIN A18 [get_ports { fmcHpcLaN[26] }]
set_property PACKAGE_PIN C19 [get_ports { fmcHpcLaP[27] }]
set_property PACKAGE_PIN B19 [get_ports { fmcHpcLaN[27] }]
set_property PACKAGE_PIN D16 [get_ports { fmcHpcLaP[28] }]
set_property PACKAGE_PIN C16 [get_ports { fmcHpcLaN[28] }]
set_property PACKAGE_PIN C17 [get_ports { fmcHpcLaP[29] }]
set_property PACKAGE_PIN B17 [get_ports { fmcHpcLaN[29] }]
set_property PACKAGE_PIN D22 [get_ports { fmcHpcLaP[30] }]
set_property PACKAGE_PIN C22 [get_ports { fmcHpcLaN[30] }]
set_property PACKAGE_PIN G22 [get_ports { fmcHpcLaP[31] }]
set_property PACKAGE_PIN F22 [get_ports { fmcHpcLaN[31] }]
set_property PACKAGE_PIN D21 [get_ports { fmcHpcLaP[32] }]
set_property PACKAGE_PIN C21 [get_ports { fmcHpcLaN[32] }]
set_property PACKAGE_PIN H21 [get_ports { fmcHpcLaP[33] }]
set_property PACKAGE_PIN H22 [get_ports { fmcHpcLaN[33] }]

set_property -dict { IOSTANDARD LVCMOS25 } [get_ports { fmcHpcLaP[*] }]
set_property -dict { IOSTANDARD LVCMOS25 } [get_ports { fmcHpcLaN[*] }]

##############################################################################

set_property PACKAGE_PIN AD23 [get_ports { fmcLpcLaP[0] }]
set_property PACKAGE_PIN AE24 [get_ports { fmcLpcLaN[0] }]
set_property PACKAGE_PIN AE23 [get_ports { fmcLpcLaP[1] }]
set_property PACKAGE_PIN AF23 [get_ports { fmcLpcLaN[1] }]
set_property PACKAGE_PIN AF20 [get_ports { fmcLpcLaP[2] }]
set_property PACKAGE_PIN AF21 [get_ports { fmcLpcLaN[2] }]
set_property PACKAGE_PIN AG20 [get_ports { fmcLpcLaP[3] }]
set_property PACKAGE_PIN AH20 [get_ports { fmcLpcLaN[3] }]
set_property PACKAGE_PIN AH21 [get_ports { fmcLpcLaP[4] }]
set_property PACKAGE_PIN AJ21 [get_ports { fmcLpcLaN[4] }]
set_property PACKAGE_PIN AG22 [get_ports { fmcLpcLaP[5] }]
set_property PACKAGE_PIN AH22 [get_ports { fmcLpcLaN[5] }]
set_property PACKAGE_PIN AK20 [get_ports { fmcLpcLaP[6] }]
set_property PACKAGE_PIN AK21 [get_ports { fmcLpcLaN[6] }]
set_property PACKAGE_PIN AG25 [get_ports { fmcLpcLaP[7] }]
set_property PACKAGE_PIN AH25 [get_ports { fmcLpcLaN[7] }]
set_property PACKAGE_PIN AJ22 [get_ports { fmcLpcLaP[8] }]
set_property PACKAGE_PIN AJ23 [get_ports { fmcLpcLaN[8] }]
set_property PACKAGE_PIN AK23 [get_ports { fmcLpcLaP[9] }]
set_property PACKAGE_PIN AK24 [get_ports { fmcLpcLaN[9] }]
set_property PACKAGE_PIN AJ24 [get_ports { fmcLpcLaP[10] }]
set_property PACKAGE_PIN AK25 [get_ports { fmcLpcLaN[10] }]
set_property PACKAGE_PIN AE25 [get_ports { fmcLpcLaP[11] }]
set_property PACKAGE_PIN AF25 [get_ports { fmcLpcLaN[11] }]
set_property PACKAGE_PIN AA20 [get_ports { fmcLpcLaP[12] }]
set_property PACKAGE_PIN AB20 [get_ports { fmcLpcLaN[12] }]
set_property PACKAGE_PIN AB24 [get_ports { fmcLpcLaP[13] }]
set_property PACKAGE_PIN AC25 [get_ports { fmcLpcLaN[13] }]
set_property PACKAGE_PIN AD21 [get_ports { fmcLpcLaP[14] }]
set_property PACKAGE_PIN AE21 [get_ports { fmcLpcLaN[14] }]
set_property PACKAGE_PIN AC24 [get_ports { fmcLpcLaP[15] }]
set_property PACKAGE_PIN AD24 [get_ports { fmcLpcLaN[15] }]
set_property PACKAGE_PIN AC22 [get_ports { fmcLpcLaP[16] }]
set_property PACKAGE_PIN AD22 [get_ports { fmcLpcLaN[16] }]
set_property PACKAGE_PIN AB27 [get_ports { fmcLpcLaP[17] }]
set_property PACKAGE_PIN AC27 [get_ports { fmcLpcLaN[17] }]
set_property PACKAGE_PIN AD27 [get_ports { fmcLpcLaP[18] }]
set_property PACKAGE_PIN AD28 [get_ports { fmcLpcLaN[18] }]
set_property PACKAGE_PIN AJ26 [get_ports { fmcLpcLaP[19] }]
set_property PACKAGE_PIN AK26 [get_ports { fmcLpcLaN[19] }]
set_property PACKAGE_PIN AF26 [get_ports { fmcLpcLaP[20] }]
set_property PACKAGE_PIN AF27 [get_ports { fmcLpcLaN[20] }]
set_property PACKAGE_PIN AG27 [get_ports { fmcLpcLaP[21] }]
set_property PACKAGE_PIN AG28 [get_ports { fmcLpcLaN[21] }]
set_property PACKAGE_PIN AJ27 [get_ports { fmcLpcLaP[22] }]
set_property PACKAGE_PIN AK28 [get_ports { fmcLpcLaN[22] }]
set_property PACKAGE_PIN AH26 [get_ports { fmcLpcLaP[23] }]
set_property PACKAGE_PIN AH27 [get_ports { fmcLpcLaN[23] }]
set_property PACKAGE_PIN AG30 [get_ports { fmcLpcLaP[24] }]
set_property PACKAGE_PIN AH30 [get_ports { fmcLpcLaN[24] }]
set_property PACKAGE_PIN AC26 [get_ports { fmcLpcLaP[25] }]
set_property PACKAGE_PIN AD26 [get_ports { fmcLpcLaN[25] }]
set_property PACKAGE_PIN AK29 [get_ports { fmcLpcLaP[26] }]
set_property PACKAGE_PIN AK30 [get_ports { fmcLpcLaN[26] }]
set_property PACKAGE_PIN AJ28 [get_ports { fmcLpcLaP[27] }]
set_property PACKAGE_PIN AJ29 [get_ports { fmcLpcLaN[27] }]
set_property PACKAGE_PIN AE30 [get_ports { fmcLpcLaP[28] }]
set_property PACKAGE_PIN AF30 [get_ports { fmcLpcLaN[28] }]
set_property PACKAGE_PIN AE28 [get_ports { fmcLpcLaP[29] }]
set_property PACKAGE_PIN AF28 [get_ports { fmcLpcLaN[29] }]
set_property PACKAGE_PIN AB29 [get_ports { fmcLpcLaP[30] }]
set_property PACKAGE_PIN AB30 [get_ports { fmcLpcLaN[30] }]
set_property PACKAGE_PIN AD29 [get_ports { fmcLpcLaP[31] }]
set_property PACKAGE_PIN AE29 [get_ports { fmcLpcLaN[31] }]
set_property PACKAGE_PIN Y30  [get_ports { fmcLpcLaP[32] }]
set_property PACKAGE_PIN AA30 [get_ports { fmcLpcLaN[32] }]
set_property PACKAGE_PIN AC29 [get_ports { fmcLpcLaP[33] }]
set_property PACKAGE_PIN AC30 [get_ports { fmcLpcLaN[33] }]

set_property -dict { IOSTANDARD LVCMOS25 } [get_ports { fmcLpcLaP[*] }]
set_property -dict { IOSTANDARD LVCMOS25 } [get_ports { fmcLpcLaN[*] }]

##############################################################################

####################
# Timing Constraints
####################

create_clock -name sfpClk125P -period 8.000 [get_ports {sfpClk125P}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {sfpClk125P}]
