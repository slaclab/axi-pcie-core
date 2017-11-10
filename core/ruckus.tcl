# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir  "$::DIR_PATH/rtl/"

# Place and Route strategies 
#set_property strategy Performance_Explore [get_runs impl_1]
#set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

# Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
