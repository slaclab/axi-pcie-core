# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "xcku115-flvb2104-2-e" } {
   puts "\n\nERROR: PRJ_PART was not defined as xcku115-flvb2104-2-e in the Makefile\n\n"; exit -1
}

if { [info exists ::env(PCIE_GEN_NUM)] != 1 } {
   puts "\n\nERROR: PCIE_GEN_SEL is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

# Check for version 2018.2 of Vivado (or later)
if { [VersionCheck 2018.2] < 0 } {exit -1}

# Set the board part
set_property board_part {xilinx.com:kcu1500:part0:1.1} [current_project]

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -dir  "$::DIR_PATH/xdc"

# Load the primary PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"

#######################################################################################
# Note: The hardware/XilinxKcu1500/pcie-extended and hardware/XilinxKcu1500/ddr are not
#       including in this ruckus.tcl.  You can use your user ruckus.tcl script to load
#       either of these "optional" modules into your firmware target
#######################################################################################
