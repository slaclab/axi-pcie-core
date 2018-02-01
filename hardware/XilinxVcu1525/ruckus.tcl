# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2017.4 of Vivado (or later)
if { [VersionCheck 2017.4] < 0 } {exit -1}

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "xcvu9p-fsgd2104-2-i" } {
   puts "\n\nERROR: PRJ_PART was not defined as xcvu9p-fsgd2104-2-i in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part {xilinx.com:vcu1525:part0:1.0} [current_project]

# Load local Source Code and Constraints
loadIpCore      -dir  "$::DIR_PATH/ip"
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -dir  "$::DIR_PATH/xdc"
loadSource      -path "$::DIR_PATH/mig/rtl/Mig1.vhd"
loadSource      -path "$::DIR_PATH/mig/rtl/MigXbar.vhd"
loadIpCore      -path "$::DIR_PATH/mig/ip/XilinxVcu1525Mig1Core.xci"
loadIpCore      -path "$::DIR_PATH/mig/ip/XilinxVcu1525MigXbar.xci"
