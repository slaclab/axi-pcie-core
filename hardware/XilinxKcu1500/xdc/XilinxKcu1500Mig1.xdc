##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

#######################
# DDR[1]: Constraints #
#######################

# Using the pin out constraints that are auto-generated in the Ddr4WithoutEcc.xci

#########################
# Placement Constraints #
#########################

# create_pblock MIG_XBAR1_GRP; 
# add_cells_to_pblock [get_pblocks MIG_XBAR1_GRP] [get_cells [list U_Core/U_Mig1/U_Xbar]]
# resize_pblock [get_pblocks MIG_XBAR1_GRP] -add {CLOCKREGION_X4Y2:CLOCKREGION_X5Y6}

##########
# Clocks #
##########

create_clock -period  3.333 -name ddrClkP1     [get_ports {ddrClkP[1]}]
create_generated_clock   -name ddrIntClk01  [get_pins {U_Core/U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
create_generated_clock   -name ddrIntClk11  [get_pins {U_Core/U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP1}] -group [get_clocks {sysClk}] 
