# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"

# Load Simulation
#loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"
