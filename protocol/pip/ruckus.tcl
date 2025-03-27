# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Load Source Code
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"

# Load Simulation
loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"
