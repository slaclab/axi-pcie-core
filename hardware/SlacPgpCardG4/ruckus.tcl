# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCKU040-FFVA1156-2-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU040-FFVA1156-2-E in the Makefile\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir  "$::DIR_PATH/rtl"
loadConstraints -path "$::DIR_PATH/xdc/SlacPgpCardGen4Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/SlacPgpCardGen4App.xdc"

# Load the primary PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"
