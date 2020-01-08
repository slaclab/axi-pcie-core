# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCKU040-FFVA1156-2-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU040-FFVA1156-2-E in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:kcu105:part0:1.3 [current_project]

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core      -dir  "$::DIR_PATH/rtl"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu105Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu105App.xdc"

# Load the primary PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"
