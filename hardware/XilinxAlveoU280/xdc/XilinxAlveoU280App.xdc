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

set_property PACKAGE_PIN R40 [get_ports { qsfp0RefClkP[0] }] ;# 156.25 MHz
set_property PACKAGE_PIN R41 [get_ports { qsfp0RefClkN[0] }] ;# 156.25 MHz
set_property PACKAGE_PIN T42 [get_ports { qsfp0RefClkP[1] }] ;# 156.25 MHz
set_property PACKAGE_PIN T43 [get_ports { qsfp0RefClkN[1] }] ;# 156.25 MHz

set_property PACKAGE_PIN L48 [get_ports { qsfp0TxP[0] }]
set_property PACKAGE_PIN L49 [get_ports { qsfp0TxN[0] }]
set_property PACKAGE_PIN L53 [get_ports { qsfp0RxP[0] }]
set_property PACKAGE_PIN L54 [get_ports { qsfp0RxN[0] }]

set_property PACKAGE_PIN L44 [get_ports { qsfp0TxP[1] }]
set_property PACKAGE_PIN L45 [get_ports { qsfp0TxN[1] }]
set_property PACKAGE_PIN K51 [get_ports { qsfp0RxP[1] }]
set_property PACKAGE_PIN K52 [get_ports { qsfp0RxN[1] }]

set_property PACKAGE_PIN K46 [get_ports { qsfp0TxP[2] }]
set_property PACKAGE_PIN K47 [get_ports { qsfp0TxN[2] }]
set_property PACKAGE_PIN J53 [get_ports { qsfp0RxP[2] }]
set_property PACKAGE_PIN J54 [get_ports { qsfp0RxN[2] }]

set_property PACKAGE_PIN J48 [get_ports { qsfp0TxP[3] }]
set_property PACKAGE_PIN J49 [get_ports { qsfp0TxN[3] }]
set_property PACKAGE_PIN H51 [get_ports { qsfp0RxP[3] }]
set_property PACKAGE_PIN H52 [get_ports { qsfp0RxN[3] }]

###########
# QSFP[1] #
###########

set_property PACKAGE_PIN M42 [get_ports { qsfp1RefClkP[0] }] ;# 156.25 MHz
set_property PACKAGE_PIN M43 [get_ports { qsfp1RefClkN[0] }] ;# 156.25 MHz
set_property PACKAGE_PIN P42 [get_ports { qsfp1RefClkP[1] }] ;# 156.25 MHz
set_property PACKAGE_PIN P43 [get_ports { qsfp1RefClkN[1] }] ;# 156.25 MHz

set_property PACKAGE_PIN G48 [get_ports { qsfp1TxP[0] }]
set_property PACKAGE_PIN G49 [get_ports { qsfp1TxN[0] }]
set_property PACKAGE_PIN G53 [get_ports { qsfp1RxP[0] }]
set_property PACKAGE_PIN G54 [get_ports { qsfp1RxN[0] }]

set_property PACKAGE_PIN E48 [get_ports { qsfp1TxP[1] }]
set_property PACKAGE_PIN E49 [get_ports { qsfp1TxN[1] }]
set_property PACKAGE_PIN F51 [get_ports { qsfp1RxP[1] }]
set_property PACKAGE_PIN F52 [get_ports { qsfp1RxN[1] }]

set_property PACKAGE_PIN C48 [get_ports { qsfp1TxP[2] }]
set_property PACKAGE_PIN C49 [get_ports { qsfp1TxN[2] }]
set_property PACKAGE_PIN E53 [get_ports { qsfp1RxP[2] }]
set_property PACKAGE_PIN E54 [get_ports { qsfp1RxN[2] }]

set_property PACKAGE_PIN A49 [get_ports { qsfp1TxP[3] }]
set_property PACKAGE_PIN A50 [get_ports { qsfp1TxN[3] }]
set_property PACKAGE_PIN D51 [get_ports { qsfp1RxP[3] }]
set_property PACKAGE_PIN D52 [get_ports { qsfp1RxN[3] }]

##########
# Clocks #
##########

create_clock -period 6.400 -name qsfp0RefClkP0 [get_ports {qsfp0RefClkP[0]}]
create_clock -period 6.400 -name qsfp0RefClkP1 [get_ports {qsfp0RefClkP[1]}]

create_clock -period 6.400 -name qsfp1RefClkP0 [get_ports {qsfp1RefClkP[0]}]
create_clock -period 6.400 -name qsfp1RefClkP1 [get_ports {qsfp1RefClkP[1]}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP1}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP1}]

set_clock_groups -asynchronous \ 
   -group [get_clocks -include_generated_clocks {qsfp0RefClkP0}] \
   -group [get_clocks -include_generated_clocks {qsfp0RefClkP1}] \
   -group [get_clocks -include_generated_clocks {qsfp1RefClkP0}] \
   -group [get_clocks -include_generated_clocks {qsfp1RefClkP1}]
