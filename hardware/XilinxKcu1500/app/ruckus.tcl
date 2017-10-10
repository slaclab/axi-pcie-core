# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl/"

# Check for  partial reconfiguration
if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Reconfig.xdc"
}
