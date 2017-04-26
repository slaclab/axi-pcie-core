# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check if required variables exist
if { [info exists ::env(PCIE_HW_TYPE)] != 1 } {
   puts "\n\nERROR: PCIE_HW_TYPE is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

# Load Hardware ruckus files
loadRuckusTcl "$::DIR_PATH/$::env(PCIE_HW_TYPE)"
