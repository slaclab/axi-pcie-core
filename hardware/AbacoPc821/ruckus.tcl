# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) == "XCKU085-FLVB1760-2-E" } {
   loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl/KU085"
} elseif { $::env(PRJ_PART) == "XCKU115-FLVB1760-2-E" } {
   loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl/KU115"
} else {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU085-FLVB1760-2-E or XCKU115-FLVB1760-2-E in the Makefile\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"
loadConstraints -path "$::DIR_PATH/xdc/AbacoPc821Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/AbacoPc821App.xdc"

# Load the primary PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"
