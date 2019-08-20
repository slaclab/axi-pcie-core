# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource           -dir "$::DIR_PATH/rtl"
loadIpCore           -dir "$::DIR_PATH/ip"
loadSource           -dir "$::DIR_PATH/ip/misc"
loadSource -sim_only -dir "$::DIR_PATH/tb"
loadConstraints      -dir "$::DIR_PATH/xdc"

# Set the XilinxAlveoU200MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {XilinxAlveoU200MigTiming.xdc}]
