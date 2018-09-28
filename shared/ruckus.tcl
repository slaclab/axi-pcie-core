# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.6.11} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.8.9}  ] < 0 } {exit -1}

# Load Source Code
loadSource -dir  "$::DIR_PATH/rtl"

# Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
