# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadIpCore -dir  "$::DIR_PATH/ip"
loadSource -dir  "$::DIR_PATH/rtl"
loadSource -path "$::DIR_PATH/../rtl/AxiPciePkg.vhd"

# set_property STEPS.PHYS_OPT_DESIGN.TCL.PRE  "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
# set_property STEPS.PHYS_OPT_DESIGN.TCL.POST "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1] 

# set_property STEPS.PLACE_DESIGN.TCL.PRE  "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
# set_property STEPS.PLACE_DESIGN.TCL.POST "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1]    