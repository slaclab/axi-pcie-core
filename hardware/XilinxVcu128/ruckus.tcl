# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCVU37P-FSVH2892-2L-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCVU37P-FSVH2892-2L-E in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:vcu128:part0:1.0 [current_project]

# Check which type of PCIe build to generate
if { [info exists ::env(BUILD_PCIE_GEN4)] != 1 || $::env(BUILD_PCIE_GEN4) == 0 } {
   set pcieType "pcie-3x16"
} else {
   set pcieType "pcie-gen4x8x2"
   puts "\n\nERROR: PCIe GEN4 is not supported in the Xilinx AXI PCIe bridge IP core yet\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core      -dir "$::DIR_PATH/misc"
loadConstraints                   -path "$::DIR_PATH/xdc/XilinxVcu128Core.xdc"
loadConstraints                   -path "$::DIR_PATH/xdc/XilinxVcu128App.xdc"

# Load the PCIe core
loadRuckusTcl "$::DIR_PATH/${pcieType}"

#######################################################################################
# Note: The hardware/XilinxVcu128/ddr is not included in this ruckus.tcl.
#       You can use your user ruckus.tcl script to load
#       either of these "optional" modules into your firmware target
#######################################################################################
