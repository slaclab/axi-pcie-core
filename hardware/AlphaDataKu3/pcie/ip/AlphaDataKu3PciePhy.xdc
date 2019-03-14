##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : Ultrascale FPGA Gen3 Integrated Block for PCI Express
## File       : AlphaDataKu3PciePhy_pcie3_ip-PCIE_X0Y0.xdc
## Version    : 4.2 
##-----------------------------------------------------------------------------
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
#
# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# Virtex-7 GT Transceiver User Guide (UG) for more information.
#
###############################################################################
#set_property LOC BUFG_GT_X1Y36 [get_cells gt_top_i/phy_clk_i/bufg_gt_pclk]
#set_property LOC BUFG_GT_X1Y37 [get_cells gt_top_i/phy_clk_i/bufg_gt_userclk]
#set_property LOC BUFG_GT_X1Y38 [get_cells gt_top_i/phy_clk_i/bufg_gt_coreclk]
###############################################################################
# Physical Constraints
###############################################################################
###############################################################################
#
# PCI Express Block placement. This constraint selects the PCI Express
# Block to be used.
#
###############################################################################
set_property LOC PCIE_3_1_X0Y0 [get_cells pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst]

###############################################################################
# Buffer (BRAM) Placement Constraints
###############################################################################

#Request Buffer RAMB Placement

set_property LOC RAMB18_X16Y2 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_req_inst/bram_req_8k_inst/RAMB18E2[0].ramb18e2_inst}]
set_property LOC RAMB18_X16Y3 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_req_inst/bram_req_8k_inst/RAMB18E2[1].ramb18e2_inst}]
set_property LOC RAMB18_X16Y4 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_req_inst/bram_req_8k_inst/RAMB18E2[2].ramb18e2_inst}]
set_property LOC RAMB18_X16Y5 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_req_inst/bram_req_8k_inst/RAMB18E2[3].ramb18e2_inst}]

# Completion Buffer RAMB Placement

# Extreme - 8
set_property LOC RAMB18_X16Y8 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[0].ramb18e2_inst}]
set_property LOC RAMB18_X16Y9 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[1].ramb18e2_inst}]
set_property LOC RAMB18_X16Y10 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[2].ramb18e2_inst}]
set_property LOC RAMB18_X16Y11 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[3].ramb18e2_inst}]
set_property LOC RAMB18_X16Y12 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[4].ramb18e2_inst}]
set_property LOC RAMB18_X16Y13 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[5].ramb18e2_inst}]
set_property LOC RAMB18_X16Y14 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[6].ramb18e2_inst}]
set_property LOC RAMB18_X16Y15 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_cpl_inst/CPL_FIFO_16KB.bram_16k_inst/RAMB18E2[7].ramb18e2_inst}]


# Replay Buffer RAMB Placement
set_property LOC RAMB36_X16Y9 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_rep_inst/bram_rep_8k_inst/RAMB36E2[0].ramb36e2_inst}]
set_property LOC RAMB36_X16Y10 [get_cells {pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/bram_inst/bram_rep_inst/bram_rep_8k_inst/RAMB36E2[1].ramb36e2_inst}]

###############################################################################
# Timing Constraints
###############################################################################

# TXOUTCLKSEL switches during reset. Set the tool to analyze timing with TXOUTCLKSEL set to 'b101.
set_case_analysis 1 [get_nets gt_top_i/PHY_TXOUTCLKSEL[2]] 
set_case_analysis 0 [get_nets gt_top_i/PHY_TXOUTCLKSEL[1]]  
set_case_analysis 1 [get_nets gt_top_i/PHY_TXOUTCLKSEL[0]]


set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXRATE[0]}]
set_case_analysis 0 [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXRATE[0]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXRATE[1]}]
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXRATE[1]}]
#
#
#
# Set Divide By 2
set_case_analysis 1 [get_pins gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[0]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[1]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_userclk/DIV[2]]
# Set Divide By 2
set_case_analysis 1 [get_pins gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[0]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[1]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_pclk/DIV[2]]
# Set Divide By 4
set_case_analysis 1 [get_pins gt_top_i/bufg_mcap_clk/DIV[0]]
set_case_analysis 1 [get_pins gt_top_i/bufg_mcap_clk/DIV[1]]
set_case_analysis 0 [get_pins gt_top_i/bufg_mcap_clk/DIV[2]]
# Set Divide By 1
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[0]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[1]]
set_case_analysis 0 [get_pins gt_top_i/phy_clk_i/bufg_gt_coreclk/DIV[2]]
#
 
#

#------------------------------------------------------------------------------
# CDC Registers
#------------------------------------------------------------------------------
# This path is crossing clock domains between pipe_clk and sys_clk
set_false_path -from [get_pins {gt_top_i/phy_rst_i/prst_n_r_reg_reg/C}] -to [get_pins {gt_top_i/phy_rst_i/sync_prst_n/sync_vec[0].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins {gt_top_i/phy_rst_i/idle_reg/C}] -to [get_pins {pcie3_uscale_top_inst/init_ctrl_inst/reg_phy_rdy_reg[0]/D}]
# These paths are crossing clock domains between sys_clk and user_clk
set_false_path -from [get_pins {gt_top_i/gt_wizard.gtwizard_top_i/AlphaDataKu3PciePhy_pcie3_ip_gt_i/inst/gen_gtwizard_gthe3_top.AlphaDataKu3PciePhy_pcie3_ip_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins {gt_top_i/phy_rst_i/sync_phystatus/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins {gt_top_i/gt_wizard.gtwizard_top_i/AlphaDataKu3PciePhy_pcie3_ip_gt_i/inst/gen_gtwizard_gthe3_top.AlphaDataKu3PciePhy_pcie3_ip_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/RXUSRCLK2}] -to [get_pins {gt_top_i/phy_rst_i/sync_rxresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
set_false_path -from [get_pins {gt_top_i/gt_wizard.gtwizard_top_i/AlphaDataKu3PciePhy_pcie3_ip_gt_i/inst/gen_gtwizard_gthe3_top.AlphaDataKu3PciePhy_pcie3_ip_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[*].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[*].GTHE3_CHANNEL_PRIM_INST/TXUSRCLK2}] -to [get_pins {gt_top_i/phy_rst_i/sync_txresetdone/sync_vec[*].sync_cell_i/sync_reg[0]/D}]
 
# Async reset registers
set_false_path -to [get_pins user_lnk_up_reg/CLR]
set_false_path -to [get_pins user_reset_reg/PRE]
#
 
#------------------------------------------------------------------------------
# Asynchronous Pins
#------------------------------------------------------------------------------
# These pins are not associated with any clock domain
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXELECIDLE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/PCIEPERST0B}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/PCIERATEGEN3}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXPRGDIVRESETDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/TXPRGDIVRESETDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/PCIESYNCTXSYNCDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/GTPOWERGOOD}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/CPLLLOCK}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/QPLL1LOCK}]
 
 
 

## Set the clock root on the PCIe clocks to limit skew to the PCIe Hardblock pins.
#set_property USER_CLOCK_ROOT X4Y0 [get_nets -of_objects [get_pins gt_top_i/phy_clk_i/bufg_gt_pclk/O]]
#set_property USER_CLOCK_ROOT X4Y0 [get_nets -of_objects [get_pins gt_top_i/phy_clk_i/bufg_gt_userclk/O]]
#set_property USER_CLOCK_ROOT X4Y0 [get_nets -of_objects [get_pins gt_top_i/phy_clk_i/bufg_gt_coreclk/O]]
#
