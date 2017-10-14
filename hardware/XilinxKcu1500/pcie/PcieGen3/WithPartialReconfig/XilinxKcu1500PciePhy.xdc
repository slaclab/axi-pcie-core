##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

##########
# Clocks #
##########

create_generated_clock -name sysClk   [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/O}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {userClkP0}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {userClkP1}]

set_property HIGH_PRIORITY true [get_nets {sysClk}]
