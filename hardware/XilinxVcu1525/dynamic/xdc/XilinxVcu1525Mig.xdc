##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

####################################################
# MIG[0], MIG[0], MIG[0] lives in the dynamic image
####################################################
 
# create_clock -period  3.333 -name ddrClkP0  [get_ports {ddrClkP[0]}]
# create_generated_clock   -name ddrIntClk00  [get_pins {U_Core/U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk10  [get_pins {U_Core/U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
# set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP0}] -group [get_clocks -include_generated_clocks {pciRefClkP}] 

# create_clock -period  3.333 -name ddrClkP2  [get_ports {ddrClkP[2]}]
# create_generated_clock   -name ddrIntClk02  [get_pins {U_Core/U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk12  [get_pins {U_Core/U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
# set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP2}] -group [get_clocks -include_generated_clocks {pciRefClkP}] 

# create_clock -period  3.333 -name ddrClkP3  [get_ports {ddrClkP[3]}]
# create_generated_clock   -name ddrIntClk03  [get_pins {U_Core/U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk13  [get_pins {U_Core/U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
# set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP3}] -group [get_clocks -include_generated_clocks {pciRefClkP}] 
