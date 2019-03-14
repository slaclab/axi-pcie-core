# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XC7K325TFFG900-2" } {
   puts "\n\nERROR: PRJ_PART was not defined as XC7K325TFFG900-2 in the Makefile\n\n"; exit -1
}

# Check for version 2018.2 of Vivado (or later)
if { [VersionCheck 2018.2] < 0 } {exit -1}

# Set the board part
set_property board_part xilinx.com:kc705:part0:1.5 [current_project]

#######################################################################################
# 7-Series PCIe IP core appear to not support 40-bit address (even with 64-bit enabled)
#######################################################################################
# loadRuckusTcl "$::DIR_PATH/../../shared"
loadSource -path "$::DIR_PATH/../../shared/rtl/AxiPcieDma.vhd"
loadSource -path "$::DIR_PATH/../../shared/rtl/AxiPcieReg.vhd"

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKc705Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKc705App.xdc"

# Load the primary PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"
