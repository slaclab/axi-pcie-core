# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/core"
loadConstraints -path "$::DIR_PATH/xdc/BittWareXupVv8Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/BittWareXupVv8App.xdc"

# Check for valid FPGA part number
if { $::env(PRJ_PART) == "xcvu13p-figd2104-2-e" } {
   loadSource -lib axi_pcie_core -dir "$::DIR_PATH/core/VU13P"
   loadConstraints -path "$::DIR_PATH/xdc/BittWareXupVv8Vu13p.xdc"
} elseif { $::env(PRJ_PART) == "xcvu9p-fsgd2104-2-e" } {
   loadSource -lib axi_pcie_core -dir "$::DIR_PATH/core/VU9P"
   loadConstraints -path "$::DIR_PATH/xdc/BittWareXupVv8Vu9p.xdc"
} else {
   puts "\n\nERROR: PRJ_PART was not defined as xcvu13p-figd2104-2-e or xcvu9p-fsgd2104-2-e in the Makefile\n\n"; exit -1
}

# Load the PCIe core
loadRuckusTcl "$::DIR_PATH/pcie"

#######################################################################################
# Note: The hardware/BittWareXupVv8/ddr is not included in this ruckus.tcl.
#       You can use your user ruckus.tcl script to load
#       either of these "optional" modules into your firmware target
#######################################################################################
