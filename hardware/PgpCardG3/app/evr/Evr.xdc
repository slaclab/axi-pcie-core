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

create_clock -name evrRxClk -period 5.384 [get_pins {U_App/U_Evr/U_GTP/Gtp7Core_Inst/gtpe2_i/RXOUTCLK}]
create_clock -name evrTxClk -period 5.384 [get_pins {U_App/U_Evr/U_GTP/Gtp7Core_Inst/gtpe2_i/TXOUTCLK}]

######################
# Timing Constraints #
######################

set_clock_groups -asynchronous -group [get_clocks {evrTxClk}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]

set_clock_groups -asynchronous -group [get_clocks {pgpRxClk0}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk1}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk2}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk3}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk4}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk5}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk6}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpRxClk7}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]

set_clock_groups -asynchronous -group [get_clocks {pgpTxClk0}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk1}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk2}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk3}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk4}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk5}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk6}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]
set_clock_groups -asynchronous -group [get_clocks {pgpTxClk7}] -group [get_clocks {evrRxClk}] -group [get_clocks {sysClk}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {evrRefClk0}] -group [get_clocks {sysClk}]   
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {evrRefClk1}] -group [get_clocks {sysClk}]

# ######################
# # Area Constraint    #
# ######################
# create_pblock EVR_GRP
# add_cells_to_pblock [get_pblocks EVR_GRP] [get_cells U_App/U_Evr]
# resize_pblock [get_pblocks EVR_GRP] -add {CLOCKREGION_X1Y3:CLOCKREGION_X1Y4}
