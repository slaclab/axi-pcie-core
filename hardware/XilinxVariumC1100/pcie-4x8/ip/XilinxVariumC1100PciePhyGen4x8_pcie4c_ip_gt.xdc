#------------------------------------------------------------------------------
#  (c) Copyright 2013-2018 Xilinx, Inc. All rights reserved.
#
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES.
#------------------------------------------------------------------------------


# UltraScale FPGAs Transceivers Wizard IP core-level XDC file
# ----------------------------------------------------------------------------------------------------------------------

# Commands for enabled transceiver GTYE4_CHANNEL_X1Y8
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y8 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[26].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AU1 [get_ports gtyrxn_in[0]]
#set_property package_pin AU2 [get_ports gtyrxp_in[0]]
#set_property package_pin AU10 [get_ports gtytxn_out[0]]
#set_property package_pin AU11 [get_ports gtytxp_out[0]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[0].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y9
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y9 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[26].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AT3 [get_ports gtyrxn_in[1]]
#set_property package_pin AT4 [get_ports gtyrxp_in[1]]
#set_property package_pin AT8 [get_ports gtytxn_out[1]]
#set_property package_pin AT9 [get_ports gtytxp_out[1]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[1].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y10
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y10 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[26].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AR1 [get_ports gtyrxn_in[2]]
#set_property package_pin AR2 [get_ports gtyrxp_in[2]]
#set_property package_pin AR6 [get_ports gtytxn_out[2]]
#set_property package_pin AR7 [get_ports gtytxp_out[2]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[2].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y11
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y11 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[26].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AP3 [get_ports gtyrxn_in[3]]
#set_property package_pin AP4 [get_ports gtyrxp_in[3]]
#set_property package_pin AR10 [get_ports gtytxn_out[3]]
#set_property package_pin AR11 [get_ports gtytxp_out[3]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[3].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y12
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y12 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[27].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AN1 [get_ports gtyrxn_in[4]]
#set_property package_pin AN2 [get_ports gtyrxp_in[4]]
#set_property package_pin AP8 [get_ports gtytxn_out[4]]
#set_property package_pin AP9 [get_ports gtytxp_out[4]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[4].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y13
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y13 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[27].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AN5 [get_ports gtyrxn_in[5]]
#set_property package_pin AN6 [get_ports gtyrxp_in[5]]
#set_property package_pin AN10 [get_ports gtytxn_out[5]]
#set_property package_pin AN11 [get_ports gtytxp_out[5]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[5].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y14
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y14 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[27].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AM3 [get_ports gtyrxn_in[6]]
#set_property package_pin AM4 [get_ports gtyrxp_in[6]]
#set_property package_pin AM8 [get_ports gtytxn_out[6]]
#set_property package_pin AM9 [get_ports gtytxp_out[6]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[6].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



# Commands for enabled transceiver GTYE4_CHANNEL_X1Y15
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X1Y15 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[27].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AL1 [get_ports gtyrxn_in[7]]
#set_property package_pin AL2 [get_ports gtyrxp_in[7]]
#set_property package_pin AL10 [get_ports gtytxn_out[7]]
#set_property package_pin AL11 [get_ports gtytxp_out[7]]
# CPLL calibration block constraints
create_clock -period 8.0 [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*bufg_gt_txoutclkmon_inst}]]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/testclk_cnt_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/freq_cnt_o_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -quiet
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/state_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[7].*U_TXOUTCLK_FREQ_COUNTER/testclk_en_dly1_reg*}] -quiet



create_waiver -internal -quiet -user gtwizard_ultrascale -tags 1025417 -type METHODOLOGY -id TIMING-3 -description "added waiver for CPLL CAL local BUFG_GT usecase"  -scope \
  -objects [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[*].*bufg_gt_*xoutclkmon_inst}]]
create_waiver -internal -quiet -type CDC -id {CDC-11} -user gtwizard_ultrascale -tags "1074717" -description "CDC-11 waiver for CPLL Calibration logic" -scope -from [get_pins -quiet -filter {REF_PIN_NAME=~*C} -of_objects [get_cells -hierarchical -filter {NAME =~*OUTCLK_FREQ_COUNTER/state_reg[0]}]]  -to [get_pins -quiet -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~*OUTCLK_FREQ_COUNTER/reset_synchronizer_testclk_rst_inst/rst_in_meta_reg*}]]
create_waiver -internal -quiet -type CDC -id {CDC-11} -user gtwizard_ultrascale -tags "1074717" -description "CDC-11 waiver for CPLL Calibration logic" -scope -from [get_pins -quiet -filter {REF_PIN_NAME=~*C} -of_objects [get_cells -hierarchical -filter {NAME =~*OUTCLK_FREQ_COUNTER/state_reg[0]}]]  -to [get_pins -quiet -filter {REF_PIN_NAME=~*D} -of_objects [get_cells -hierarchical -filter {NAME =~*OUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}]]

# False path constraints
# ----------------------------------------------------------------------------------------------------------------------

set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_synchronizer*inst/i_in_meta_reg}] -quiet

##set_false_path -to [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_*_reg}] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*D} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta*}]] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta*}]] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync1*}]] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync2*}]] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync3*}]] -quiet
set_false_path -to [get_pins -filter {REF_PIN_NAME=~*PRE} -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_out*}]] -quiet

