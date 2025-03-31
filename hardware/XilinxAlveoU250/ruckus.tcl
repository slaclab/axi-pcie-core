# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCU250-FIGD2104-2L-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCU250-FIGD2104-2L-E in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:au250:part0:1.3 [current_project]

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core  -dir "$::DIR_PATH/core"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoU250Core.xdc"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoU250App.xdc"

# Load the PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"

#######################################################################################
# Note: The hardware/XilinxAlveoU250/ddr is not included in this ruckus.tcl.
#       You can use your user ruckus.tcl script to load
#       either of these "optional" modules into your firmware target
#######################################################################################
