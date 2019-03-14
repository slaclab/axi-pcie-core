##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN F9  IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN F10 IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN G9  IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS33 } [get_ports { led[7] }]

set_property -dict { PACKAGE_PIN AB14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[0] }]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[1] }]
set_property -dict { PACKAGE_PIN AA15 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[2] }]
set_property -dict { PACKAGE_PIN Y15  IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[3] }]

set_property PACKAGE_PIN N5 [get_ports sfpTxP[0]]
set_property PACKAGE_PIN N4 [get_ports sfpTxN[0]]
set_property PACKAGE_PIN M2 [get_ports sfpRxP[0]]
set_property PACKAGE_PIN M1 [get_ports sfpRxN[0]]

set_property PACKAGE_PIN L5 [get_ports sfpTxP[1]]
set_property PACKAGE_PIN L4 [get_ports sfpTxN[1]]
set_property PACKAGE_PIN K2 [get_ports sfpRxP[1]]
set_property PACKAGE_PIN K1 [get_ports sfpRxN[1]]

set_property PACKAGE_PIN J5 [get_ports sfpTxP[2]]
set_property PACKAGE_PIN J4 [get_ports sfpTxN[2]]
set_property PACKAGE_PIN H2 [get_ports sfpRxP[2]]
set_property PACKAGE_PIN H1 [get_ports sfpRxN[2]]

set_property PACKAGE_PIN G5 [get_ports sfpTxP[3]]
set_property PACKAGE_PIN G4 [get_ports sfpTxN[3]]
set_property PACKAGE_PIN F2 [get_ports sfpRxP[3]]
set_property PACKAGE_PIN F1 [get_ports sfpRxN[3]]

set_property PACKAGE_PIN M7 [get_ports sfpClk156P]
set_property PACKAGE_PIN M6 [get_ports sfpClk156N]

##############################################################################

####################
# Timing Constraints
####################

create_clock -name sfpClk156P -period 6.400 [get_ports {sfpClk156P}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {sfpClk156P}]
