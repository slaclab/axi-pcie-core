# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "xcvu9p-fsgd2104-2L-e" } {
   puts "\n\nERROR: PRJ_PART was not defined as xcvu9p-fsgd2104-2L-e in the Makefile\n\n"; exit -1
}

# Check for version 2018.2 of Vivado (or later)
if { [VersionCheck 2018.2] < 0 } {exit -1}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the board part
set_property board_part {xilinx.com:vcu1525:part0:1.1} [current_project]

# Load local Source Code and Constraints
loadIpCore      -dir  "$::DIR_PATH/ip"
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -dir  "$::DIR_PATH/xdc"
