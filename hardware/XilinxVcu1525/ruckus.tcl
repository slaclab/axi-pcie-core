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

loadSource      -path "$::DIR_PATH/dynamic/rtl/MigXbar.vhd"
loadIpCore      -path "$::DIR_PATH/dynamic/ip/XilinxVcu1525MigXbar.xci"

# loadIpCore    -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadConstraints -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xdc"

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}] 
