# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCKU060-FFVA1156-2-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU060-FFVA1156-2-E in the Makefile\n\n"; exit -1
}

# Place and Route strategy 
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Load local Source Code and Constraints
loadSource      -path "$::DIR_PATH/core/AdmPcieKu3Core.vhd"
loadConstraints -path "$::DIR_PATH/xdc/AdmPcieKu3Core.xdc"

# Load the common source code
loadRuckusTcl "$::DIR_PATH/pcie"
