# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource      -dir "$::DIR_PATH/rtl"
loadIpCore      -dir "$::DIR_PATH/ip"
loadConstraints -dir "$::DIR_PATH/xdc"

# Bug fix for using MIG cores in Vivado 2017.3 (or later)
# https://forums.xilinx.com/t5/Synthesis/Vivado-2016-4-Linux-crash-during-Phase-7-Resynthesis/td-p/794884
# https://forums.xilinx.com/t5/Welcome-Join/Abnormal-program-termination-11-in-place-design-vivado-2016-1/td-p/802908
set_property STEPS.PHYS_OPT_DESIGN.TCL.PRE  "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.TCL.POST "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1] 
set_property STEPS.PLACE_DESIGN.TCL.PRE     "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.TCL.POST    "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1] 
