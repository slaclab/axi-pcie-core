# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource      -dir "$::DIR_PATH/rtl"
loadIpCore      -dir "$::DIR_PATH/ip"
loadConstraints -dir "$::DIR_PATH/xdc"
