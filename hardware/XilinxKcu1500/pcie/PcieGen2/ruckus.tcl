# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir "$::DIR_PATH/rtl"

# Check for partial reconfiguration
if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {
   loadSource      -dir "$::DIR_PATH/WithPartialReconfig"
   loadIpCore      -dir "$::DIR_PATH/WithPartialReconfig"
} else {
   loadSource      -dir "$::DIR_PATH/WithoutPartialReconfig"
   loadIpCore      -dir "$::DIR_PATH/WithoutPartialReconfig"
}

# Check for TIG
if { [info exists ::env(TIG)] != 1 || $::env(TIG) == 0 } {
   loadConstraints -dir "$::DIR_PATH/WithPartialReconfig"
} else {
   loadConstraints -dir "$::DIR_PATH/WithoutPartialReconfig"
}