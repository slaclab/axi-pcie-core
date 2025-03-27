# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load source code
loadSource -lib axi_pcie_core           -dir "$::DIR_PATH/rtl"
loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"

# Determine the DDR speed type
if { [info exists ::env(DDR_SPEED)] != 1 } {
   set DDR_SPEED "2400-MTPS"
} else {
   set DDR_SPEED "$::env(DDR_SPEED)-MTPS"
}

loadIpCore      -dir "$::DIR_PATH/ip/${DDR_SPEED}"
loadConstraints -dir "$::DIR_PATH/ip"
loadConstraints -dir "$::DIR_PATH/xdc"

# Set the XilinxAlveoU200MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {BittWareXupVv8MigTiming.xdc}]

# Bug fix for using MIG cores in Vivado 2017.3 (or later)
# https://forums.xilinx.com/t5/Synthesis/Vivado-2016-4-Linux-crash-during-Phase-7-Resynthesis/td-p/794884
# https://forums.xilinx.com/t5/Welcome-Join/Abnormal-program-termination-11-in-place-design-vivado-2016-1/td-p/802908
set_property STEPS.PHYS_OPT_DESIGN.TCL.PRE  "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.TCL.POST "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.TCL.PRE     "$::DIR_PATH/vivado/pthread_pre.tcl"  [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.TCL.POST    "$::DIR_PATH/vivado/pthread_post.tcl" [get_runs impl_1]
