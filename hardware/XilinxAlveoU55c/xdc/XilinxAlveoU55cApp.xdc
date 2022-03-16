##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# HBM Catastrophic Over temperature Output signal to Satellite Controller: active HIGH indicator to Satellite controller to indicate the HBM has exceeds its maximum allowable temperature.
set_property -dict { PACKAGE_PIN BE45 IOSTANDARD LVCMOS18 PULLDOWN TRUE } [get_ports { hbmCatTrip }]

##########################################
# QSFP[0] - QSFP28 MGTY Interface QUAD 130
##########################################

set_property PACKAGE_PIN AD42 [get_ports { qsfp0RefClkP }]
set_property PACKAGE_PIN AD43 [get_ports { qsfp0RefClkN }]

set_property PACKAGE_PIN AD46 [get_ports { qsfp0TxP[0] }]
set_property PACKAGE_PIN AD47 [get_ports { qsfp0TxN[0] }]
set_property PACKAGE_PIN AD51 [get_ports { qsfp0RxP[0] }]
set_property PACKAGE_PIN AD52 [get_ports { qsfp0RxN[0] }]

set_property PACKAGE_PIN AC44 [get_ports { qsfp0TxP[1] }]
set_property PACKAGE_PIN AC45 [get_ports { qsfp0TxN[1] }]
set_property PACKAGE_PIN AC53 [get_ports { qsfp0RxP[1] }]
set_property PACKAGE_PIN AC54 [get_ports { qsfp0RxN[1] }]

set_property PACKAGE_PIN AB46 [get_ports { qsfp0TxP[2] }]
set_property PACKAGE_PIN AB47 [get_ports { qsfp0TxN[2] }]
set_property PACKAGE_PIN AC49 [get_ports { qsfp0RxP[2] }]
set_property PACKAGE_PIN AC50 [get_ports { qsfp0RxN[2] }]

set_property PACKAGE_PIN AA48 [get_ports { qsfp0TxP[3] }]
set_property PACKAGE_PIN AA49 [get_ports { qsfp0TxN[3] }]
set_property PACKAGE_PIN AB51 [get_ports { qsfp0RxP[3] }]
set_property PACKAGE_PIN AB52 [get_ports { qsfp0RxN[3] }]

##########################################
# QSFP[0] - QSFP28 MGTY Interface QUAD 131
##########################################

set_property PACKAGE_PIN AB42 [get_ports { qsfp1RefClkP }]
set_property PACKAGE_PIN AB43 [get_ports { qsfp1RefClkN }]

set_property PACKAGE_PIN AA44 [get_ports { qsfp1TxP[0] }]
set_property PACKAGE_PIN AA45 [get_ports { qsfp1TxN[0] }]
set_property PACKAGE_PIN AA53 [get_ports { qsfp1RxP[0] }]
set_property PACKAGE_PIN AA54 [get_ports { qsfp1RxN[0] }]

set_property PACKAGE_PIN Y46 [get_ports { qsfp1TxP[1] }]
set_property PACKAGE_PIN Y47 [get_ports { qsfp1TxN[1] }]
set_property PACKAGE_PIN Y51 [get_ports { qsfp1RxP[1] }]
set_property PACKAGE_PIN Y52 [get_ports { qsfp1RxN[1] }]

set_property PACKAGE_PIN W48 [get_ports { qsfp1TxP[2] }]
set_property PACKAGE_PIN W49 [get_ports { qsfp1TxN[2] }]
set_property PACKAGE_PIN W53 [get_ports { qsfp1RxP[2] }]
set_property PACKAGE_PIN W54 [get_ports { qsfp1RxN[2] }]

set_property PACKAGE_PIN W44 [get_ports { qsfp1TxP[3] }]
set_property PACKAGE_PIN W45 [get_ports { qsfp1TxN[3] }]
set_property PACKAGE_PIN V51 [get_ports { qsfp1RxP[3] }]
set_property PACKAGE_PIN V52 [get_ports { qsfp1RxN[3] }]


##########
# Clocks #
##########

create_clock -period 6.206 -name qsfp0RefClkP [get_ports {qsfp0RefClkP}] ;# 161.1328125 MHz
create_clock -period 6.206 -name qsfp1RefClkP [get_ports {qsfp1RefClkP}] ;# 161.1328125 MHz

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {qsfp0RefClkP}] \
   -group [get_clocks -include_generated_clocks {qsfp1RefClkP}] \
   -group [get_clocks -include_generated_clocks {pciRefClk0}] \
   -group [get_clocks -include_generated_clocks {pciRefClk1}] \
   -group [get_clocks -include_generated_clocks {userClkP}]
