# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadIpCore -dir  "$::DIR_PATH/ip"
loadSource -dir  "$::DIR_PATH/rtl"
loadSource -path "$::DIR_PATH/../rtl/AxiPciePkg.vhd"

if { [info exists ::env(RECONFIG_ENDPOINT)] != 1 || $::env(RECONFIG_ENDPOINT) == 0 } {
   set staticBuild 1
} else {
   # Set the top-level RTL
   set_property top {Application} [current_fileset]
}
