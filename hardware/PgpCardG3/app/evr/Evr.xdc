##############################################################################
## This file is part of 'SLAC PGP Gen3 Card'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC PGP Gen3 Card', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

#######
# EVR #
#######

set_property PACKAGE_PIN B13  [get_ports evrTxP]
set_property PACKAGE_PIN A13  [get_ports evrTxN]
set_property PACKAGE_PIN F13  [get_ports evrRxP]
set_property PACKAGE_PIN E13  [get_ports evrRxN]

set_property PACKAGE_PIN H16  [get_ports evrRefClkP[0]]
set_property PACKAGE_PIN G16  [get_ports evrRefClkN[0]]
create_clock -name evrRefClk0 -period  4.201 [get_ports {evrRefClkP[0]}]

set_property PACKAGE_PIN H14  [get_ports evrRefClkP[1]]
set_property PACKAGE_PIN G14  [get_ports evrRefClkN[1]]
create_clock -name evrRefClk1 -period  2.691 [get_ports {evrRefClkP[1]}]

set_property -dict { PACKAGE_PIN V24 IOSTANDARD LVCMOS25 } [get_ports { evrMuxSel[0] }]
set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS25 } [get_ports { evrMuxSel[1] }]
