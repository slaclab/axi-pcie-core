# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2025.1 of Vivado (or later)
if { [VersionCheck 2025.1] < 0 } {exit -1}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "xcv80-lsva4737-2MHP-e-S" } {
   puts "\n\nERROR: PRJ_PART was not defined as xcv80-lsva4737-2MHP-e-S in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:v80:part0:1.0 [current_project]

loadBlockDesign -path "$::DIR_PATH/bd/XilinxAlveoV80PcieBlockDesign.bd"
# loadBlockDesign -path "$::DIR_PATH/bd/XilinxAlveoV80PcieBlockDesign.tcl"

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core  -dir "$::DIR_PATH/core"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoV80Core.xdc"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoV80App.xdc"
