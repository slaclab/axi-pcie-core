# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2024.2 of Vivado (or later)
if { [VersionCheck 2024.2] < 0 } {exit -1}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "xcu55c-fsvh2892-2L-e" } {
   puts "\n\nERROR: PRJ_PART was not defined as xcu55c-fsvh2892-2L-e in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:au55c:part0:1.0 [current_project]

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core  -dir "$::DIR_PATH/misc"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoU55cCore.xdc"
loadConstraints               -path "$::DIR_PATH/xdc/XilinxAlveoU55cApp.xdc"

# Load the PCIe core
loadRuckusTcl "$::DIR_PATH/pcie-4x8"

# Adding the Si5345 configurations
add_files -norecurse "$::DIR_PATH/pll-config/Si5394A_GT_REFCLK_156MHz.mem"
add_files -norecurse "$::DIR_PATH/pll-config/Si5394A_GT_REFCLK_161MHz.mem"

# https://docs.amd.com/r/en-US/pg348-cms-subsystem/Network-Plug-in-Module-Management
loadSource -lib axi_pcie_core -path "$::DIR_PATH/bd/CmsBlockDesignWrapper.vhd"
loadBlockDesign -path "$::DIR_PATH/bd/CmsBlockDesign.bd"
# loadBlockDesign -path "$::DIR_PATH/bd/CmsBlockDesign.tcl"
