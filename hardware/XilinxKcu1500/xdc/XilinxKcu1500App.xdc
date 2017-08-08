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

set_property -dict { PACKAGE_PIN AM21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0RstL }];
set_property -dict { PACKAGE_PIN AM22  IOSTANDARD LVCMOS18 } [get_ports { qsfp0LpMode }];
set_property -dict { PACKAGE_PIN AP21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0ModPrsL }];
set_property -dict { PACKAGE_PIN AL21  IOSTANDARD LVCMOS18 } [get_ports { qsfp0ModSelL }];

###########
# QSFP[1] #
###########

set_property -dict { PACKAGE_PIN AU24  IOSTANDARD LVCMOS18 } [get_ports { qsfp1RstL }];
set_property -dict { PACKAGE_PIN AR22  IOSTANDARD LVCMOS18 } [get_ports { qsfp1LpMode }];
set_property -dict { PACKAGE_PIN AR23  IOSTANDARD LVCMOS18 } [get_ports { qsfp1ModPrsL }];
set_property -dict { PACKAGE_PIN AT24  IOSTANDARD LVCMOS18 } [get_ports { qsfp1ModSelL }];

##########
# Clocks #
##########

create_clock -period 6.400 -name qsfp0RefClkP0 [get_ports {qsfp0RefClkP[0]}]
create_clock -period 8.000 -name qsfp0RefClkP1 [get_ports {qsfp0RefClkP[1]}]
create_clock -period 6.400 -name qsfp1RefClkP0 [get_ports {qsfp1RefClkP[0]}]
create_clock -period 8.000 -name qsfp1RefClkP1 [get_ports {qsfp1RefClkP[1]}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP1}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP1}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP1}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP1}]

###########################
# Partial Reconfiguration #
###########################

set_property HD.RECONFIGURABLE 1 [get_cells {U_App}]
create_pblock {PB_APP}
add_cells_to_pblock [get_pblocks {PB_APP}]  [get_cells [list U_App]]
resize_pblock {PB_APP} -add CLOCKREGION_X0Y0:CLOCKREGION_X1Y9
resize_pblock {PB_APP} -add CLOCKREGION_X2Y4:CLOCKREGION_X3Y6
set_property SNAPPING_MODE ON [get_pblocks {PB_APP}]
