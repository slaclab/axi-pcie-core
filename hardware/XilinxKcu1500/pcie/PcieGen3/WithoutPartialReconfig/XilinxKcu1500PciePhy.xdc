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

create_clock -period  4.000 -name pciTxClk [get_pins  {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/gt_wizard.gtwizard_top_i/XilinxKcu1500PciePhy_pcie3_ip_gt_i/inst/gen_gtwizard_gthe3_top.XilinxKcu1500PciePhy_pcie3_ip_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[25].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}] 
create_clock -period  4.000 -name sysClk   [get_pins  {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/O}]
create_generated_clock -name coreClk [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/U0/gt_top_i/phy_clk_i/bufg_gt_coreclk/O}]
create_generated_clock -name pipeClk [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/U0/gt_top_i/phy_clk_i/bufg_gt_pclk/O}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {userClkP0}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {userClkP1}]

set_property HIGH_PRIORITY true [get_nets {sysClk}]
