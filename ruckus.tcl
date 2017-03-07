# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

## Check for version 2016.4 of Vivado
if { [VersionCheck 2016.4] < 0 } {
   close_project
   exit -1
}

# Check if required variables exist
if { [info exists ::env(PCIE_HW_TYPE)] != 1 } {
   puts "\n\nERROR: PCIE_HW_TYPE is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

# Load ruckus files
loadRuckusTcl "$::DIR_PATH/core"
loadRuckusTcl "$::DIR_PATH/hardware"
