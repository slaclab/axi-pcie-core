# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

## Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.3.5} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.3.7} ] < 0 } {exit -1}

## Check for version 2016.4 of Vivado
if { [VersionCheck 2016.4] < 0 } {exit -1}

# Load ruckus files
loadRuckusTcl "$::DIR_PATH/core"
loadRuckusTcl "$::DIR_PATH/hardware"
