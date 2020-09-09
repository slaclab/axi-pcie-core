##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

########
# QSFP #
########

set_property PACKAGE_PIN M38 [get_ports { qsfpRefClkP[0] }] ;# 156.25 MHz (???) (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN M39 [get_ports { qsfpRefClkN[0] }] ;# 156.25 MHz (???) (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN N36 [get_ports { qsfpRefClkP[1] }] ;# 156.25 MHz (???) (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN N37 [get_ports { qsfpRefClkN[1] }] ;# 156.25 MHz (???) (TODO: Need to double check this pin mapping)

set_property PACKAGE_PIN D42 [get_ports { qsfpTxP[0] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN D43 [get_ports { qsfpTxN[0] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN J45 [get_ports { qsfpRxP[0] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN J46 [get_ports { qsfpRxN[0] }]; # (TODO: Need to double check this pin mapping)

set_property PACKAGE_PIN C40 [get_ports { qsfpTxP[1] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN C41 [get_ports { qsfpTxN[1] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN G45 [get_ports { qsfpRxP[1] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN G46 [get_ports { qsfpRxN[1] }]; # (TODO: Need to double check this pin mapping)

set_property PACKAGE_PIN B42 [get_ports { qsfpTxP[2] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN B43 [get_ports { qsfpTxN[2] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN F43 [get_ports { qsfpRxP[2] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN F44 [get_ports { qsfpRxN[2] }]; # (TODO: Need to double check this pin mapping)

set_property PACKAGE_PIN A40 [get_ports { qsfpTxP[3] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN A41 [get_ports { qsfpTxN[3] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN E45 [get_ports { qsfpRxP[3] }]; # (TODO: Need to double check this pin mapping)
set_property PACKAGE_PIN E46 [get_ports { qsfpRxN[3] }]; # (TODO: Need to double check this pin mapping)

##########
# Clocks #
##########

create_clock -period 6.400 -name qsfpRefClkP0 [get_ports {qsfpRefClkP[0]}]; # (TODO: Need to double check this pin's frequency)
create_clock -period 6.400 -name qsfpRefClkP1 [get_ports {qsfpRefClkP[1]}]; # (TODO: Need to double check this pin's frequency)

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP1}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP0}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP1}]
