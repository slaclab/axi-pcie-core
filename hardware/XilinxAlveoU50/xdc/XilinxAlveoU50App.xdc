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
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS18 PULLDOWN TRUE } [get_ports { hbmCatTrip }]

########
# QSFP #
########

set_property PACKAGE_PIN M38 [get_ports { qsfpRefClkP[0] }] ;# 322.265625MHz
set_property PACKAGE_PIN M39 [get_ports { qsfpRefClkN[0] }] ;# 322.265625MHz
set_property PACKAGE_PIN N36 [get_ports { qsfpRefClkP[1] }] ;# 161.1328125Mhz
set_property PACKAGE_PIN N37 [get_ports { qsfpRefClkN[1] }] ;# 161.1328125Mhz

set_property PACKAGE_PIN D42 [get_ports { qsfpTxP[0] }]
set_property PACKAGE_PIN D43 [get_ports { qsfpTxN[0] }]
set_property PACKAGE_PIN J45 [get_ports { qsfpRxP[0] }]
set_property PACKAGE_PIN J46 [get_ports { qsfpRxN[0] }]

set_property PACKAGE_PIN C40 [get_ports { qsfpTxP[1] }]
set_property PACKAGE_PIN C41 [get_ports { qsfpTxN[1] }]
set_property PACKAGE_PIN G45 [get_ports { qsfpRxP[1] }]
set_property PACKAGE_PIN G46 [get_ports { qsfpRxN[1] }]

set_property PACKAGE_PIN B42 [get_ports { qsfpTxP[2] }]
set_property PACKAGE_PIN B43 [get_ports { qsfpTxN[2] }]
set_property PACKAGE_PIN F43 [get_ports { qsfpRxP[2] }]
set_property PACKAGE_PIN F44 [get_ports { qsfpRxN[2] }]

set_property PACKAGE_PIN A40 [get_ports { qsfpTxP[3] }]
set_property PACKAGE_PIN A41 [get_ports { qsfpTxN[3] }]
set_property PACKAGE_PIN E45 [get_ports { qsfpRxP[3] }]
set_property PACKAGE_PIN E46 [get_ports { qsfpRxN[3] }]

##########
# Clocks #
##########

create_clock -period 3.103 -name qsfpRefClkP0 [get_ports {qsfpRefClkP[0]}]; # 322.265625MHz
create_clock -period 6.206 -name qsfpRefClkP1 [get_ports {qsfpRefClkP[1]}]; # 161.1328125Mhz

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfpRefClkP1}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP0}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP1}]
