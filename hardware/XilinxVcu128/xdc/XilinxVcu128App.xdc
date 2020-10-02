##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

###########
# QSFP[0] #
###########

set_property PACKAGE_PIN P42 [get_ports {qsfpRefClkP[0]} ] ;# Bank 135 - MGTREFCLK0P_135
set_property PACKAGE_PIN P43 [get_ports {qsfpRefClkN[0]} ] ;# Bank 135 - MGTREFCLK0N_135

set_property PACKAGE_PIN G48 [get_ports { qsfpTxP[0] } ] ;# Bank 135 - MGTYTXP0_135
set_property PACKAGE_PIN G49 [get_ports { qsfpTxN[0] } ] ;# Bank 135 - MGTYTXN0_135
set_property PACKAGE_PIN G53 [get_ports { qsfpRxP[0] } ] ;# Bank 135 - MGTYRXP0_135
set_property PACKAGE_PIN G54 [get_ports { qsfpRxN[0] } ] ;# Bank 135 - MGTYRXN0_135

set_property PACKAGE_PIN E48 [get_ports { qsfpTxP[1] } ] ;# Bank 135 - MGTYTXP1_135
set_property PACKAGE_PIN E49 [get_ports { qsfpTxN[1] } ] ;# Bank 135 - MGTYTXN1_135
set_property PACKAGE_PIN F51 [get_ports { qsfpRxP[1] } ] ;# Bank 135 - MGTYRXP1_135
set_property PACKAGE_PIN F52 [get_ports { qsfpRxN[1] } ] ;# Bank 135 - MGTYRXN1_135

set_property PACKAGE_PIN C48 [get_ports { qsfpTxP[2] } ] ;# Bank 135 - MGTYTXP2_135
set_property PACKAGE_PIN C49 [get_ports { qsfpTxN[2] } ] ;# Bank 135 - MGTYTXN2_135
set_property PACKAGE_PIN E53 [get_ports { qsfpRxP[2] } ] ;# Bank 135 - MGTYRXP2_135
set_property PACKAGE_PIN E54 [get_ports { qsfpRxN[2] } ] ;# Bank 135 - MGTYRXN2_135

set_property PACKAGE_PIN A49 [get_ports { qsfpTxP[3] } ] ;# Bank 135 - MGTYTXP3_135
set_property PACKAGE_PIN A50 [get_ports { qsfpTxN[3] } ] ;# Bank 135 - MGTYTXN3_135
set_property PACKAGE_PIN D51 [get_ports { qsfpRxP[3] } ] ;# Bank 135 - MGTYRXP3_135
set_property PACKAGE_PIN D52 [get_ports { qsfpRxN[3] } ] ;# Bank 135 - MGTYRXN3_135

###########
# QSFP[1] #
###########

set_property PACKAGE_PIN T42 [get_ports {qsfpRefClkP[1]} ] ;# Bank 134 - MGTREFCLK0P_134
set_property PACKAGE_PIN T43 [get_ports {qsfpRefClkN[1]} ] ;# Bank 134 - MGTREFCLK0N_134

set_property PACKAGE_PIN L48 [get_ports { qsfpTxP[4] } ] ;# Bank 134 - MGTYTXP0_134
set_property PACKAGE_PIN L49 [get_ports { qsfpTxN[4] } ] ;# Bank 134 - MGTYTXN0_134
set_property PACKAGE_PIN L53 [get_ports { qsfpRxP[4] } ] ;# Bank 134 - MGTYRXP0_134
set_property PACKAGE_PIN L54 [get_ports { qsfpRxN[4] } ] ;# Bank 134 - MGTYRXN0_134

set_property PACKAGE_PIN L44 [get_ports { qsfpTxP[5] } ] ;# Bank 134 - MGTYTXP1_134
set_property PACKAGE_PIN L45 [get_ports { qsfpTxN[5] } ] ;# Bank 134 - MGTYTXN1_134
set_property PACKAGE_PIN K51 [get_ports { qsfpRxP[5] } ] ;# Bank 134 - MGTYRXP1_134
set_property PACKAGE_PIN K52 [get_ports { qsfpRxN[5] } ] ;# Bank 134 - MGTYRXN1_134

set_property PACKAGE_PIN K46 [get_ports { qsfpTxP[6] } ] ;# Bank 134 - MGTYTXP2_134
set_property PACKAGE_PIN K47 [get_ports { qsfpTxN[6] } ] ;# Bank 134 - MGTYTXN2_134
set_property PACKAGE_PIN J53 [get_ports { qsfpRxP[6] } ] ;# Bank 134 - MGTYRXP2_134
set_property PACKAGE_PIN J54 [get_ports { qsfpRxN[6] } ] ;# Bank 134 - MGTYRXN2_134

set_property PACKAGE_PIN J48 [get_ports { qsfpTxP[7] } ] ;# Bank 134 - MGTYTXP3_134
set_property PACKAGE_PIN J49 [get_ports { qsfpTxN[7] } ] ;# Bank 134 - MGTYTXN3_134
set_property PACKAGE_PIN H51 [get_ports { qsfpRxP[7] } ] ;# Bank 134 - MGTYRXP3_134
set_property PACKAGE_PIN H52 [get_ports { qsfpRxN[7] } ] ;# Bank 134 - MGTYRXN3_134


###########
# QSFP[2] #
###########

set_property PACKAGE_PIN Y42 [get_ports {qsfpRefClkP[2]} ] ;# Bank 132 - MGTREFCLK0P_132
set_property PACKAGE_PIN Y43 [get_ports {qsfpRefClkN[2]} ] ;# Bank 132 - MGTREFCLK0N_132

set_property PACKAGE_PIN V46 [get_ports { qsfpTxP[8] } ] ;# Bank 132 - MGTYTXP0_132
set_property PACKAGE_PIN V47 [get_ports { qsfpTxN[8] } ] ;# Bank 132 - MGTYTXN0_132
set_property PACKAGE_PIN U53 [get_ports { qsfpRxP[8] } ] ;# Bank 132 - MGTYRXP0_132
set_property PACKAGE_PIN U54 [get_ports { qsfpRxN[8] } ] ;# Bank 132 - MGTYRXN0_132

set_property PACKAGE_PIN U44 [get_ports { qsfpTxP[9] } ] ;# Bank 132 - MGTYTXP1_132
set_property PACKAGE_PIN U45 [get_ports { qsfpTxN[9] } ] ;# Bank 132 - MGTYTXN1_132
set_property PACKAGE_PIN U49 [get_ports { qsfpRxP[9] } ] ;# Bank 132 - MGTYRXP1_132
set_property PACKAGE_PIN U50 [get_ports { qsfpRxN[9] } ] ;# Bank 132 - MGTYRXN1_132

set_property PACKAGE_PIN T46 [get_ports { qsfpTxP[10] } ] ;# Bank 132 - MGTYTXP2_132
set_property PACKAGE_PIN T47 [get_ports { qsfpTxN[10] } ] ;# Bank 132 - MGTYTXN2_132
set_property PACKAGE_PIN T51 [get_ports { qsfpRxP[10] } ] ;# Bank 132 - MGTYRXP2_132
set_property PACKAGE_PIN T52 [get_ports { qsfpRxN[10] } ] ;# Bank 132 - MGTYRXN2_132

set_property PACKAGE_PIN R44 [get_ports { qsfpTxP[11] } ] ;# Bank 132 - MGTYTXP3_132
set_property PACKAGE_PIN R45 [get_ports { qsfpTxN[11] } ] ;# Bank 132 - MGTYTXN3_132
set_property PACKAGE_PIN R53 [get_ports { qsfpRxP[11] } ] ;# Bank 132 - MGTYRXP3_132
set_property PACKAGE_PIN R54 [get_ports { qsfpRxN[11] } ] ;# Bank 132 - MGTYRXN3_132

###########
# QSFP[3] #
###########

set_property PACKAGE_PIN AB42 [get_ports {qsfpRefClkP[3]} ] ;# Bank 131 - MGTREFCLK0P_131
set_property PACKAGE_PIN AB43 [get_ports {qsfpRefClkN[3]} ] ;# Bank 131 - MGTREFCLK0N_131

set_property PACKAGE_PIN AA44 [get_ports { qsfpTxP[12] } ] ;# Bank 131 - MGTYTXP0_131
set_property PACKAGE_PIN AA45 [get_ports { qsfpTxN[12] } ] ;# Bank 131 - MGTYTXN0_131
set_property PACKAGE_PIN AA53 [get_ports { qsfpRxP[12] } ] ;# Bank 131 - MGTYRXP0_131
set_property PACKAGE_PIN AA54 [get_ports { qsfpRxN[12] } ] ;# Bank 131 - MGTYRXN0_131

set_property PACKAGE_PIN Y46  [get_ports { qsfpTxP[13] } ] ;# Bank 131 - MGTYTXP1_131
set_property PACKAGE_PIN Y47  [get_ports { qsfpTxN[13] } ] ;# Bank 131 - MGTYTXN1_131
set_property PACKAGE_PIN Y51  [get_ports { qsfpRxP[13] } ] ;# Bank 131 - MGTYRXP1_131
set_property PACKAGE_PIN Y52  [get_ports { qsfpRxN[13] } ] ;# Bank 131 - MGTYRXN1_131

set_property PACKAGE_PIN W48  [get_ports { qsfpTxP[14] } ] ;# Bank 131 - MGTYTXP2_131
set_property PACKAGE_PIN W49  [get_ports { qsfpTxN[14] } ] ;# Bank 131 - MGTYTXN2_131
set_property PACKAGE_PIN W53  [get_ports { qsfpRxP[14] } ] ;# Bank 131 - MGTYRXP2_131
set_property PACKAGE_PIN W54  [get_ports { qsfpRxN[14] } ] ;# Bank 131 - MGTYRXN2_131

set_property PACKAGE_PIN W44  [get_ports { qsfpTxP[15] } ] ;# Bank 131 - MGTYTXP3_131
set_property PACKAGE_PIN W45  [get_ports { qsfpTxN[15] } ] ;# Bank 131 - MGTYTXN3_131
set_property PACKAGE_PIN V51  [get_ports { qsfpRxP[15] } ] ;# Bank 131 - MGTYRXP3_131
set_property PACKAGE_PIN V52  [get_ports { qsfpRxN[15] } ] ;# Bank 131 - MGTYRXN3_131

##########
# Clocks #
##########

create_clock -period 6.400 -name qsfpRefClkP0 [get_ports {qsfpRefClkP[0]}]
create_clock -period 6.400 -name qsfpRefClkP1 [get_ports {qsfpRefClkP[1]}]
create_clock -period 6.400 -name qsfpRefClkP2 [get_ports {qsfpRefClkP[2]}]
create_clock -period 6.400 -name qsfpRefClkP3 [get_ports {qsfpRefClkP[3]}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP1}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP2}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP3}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP0}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP1}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP2}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP3}]
