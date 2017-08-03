# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

## Check for version 2017.2 of Vivado (or later)
if { [VersionCheck 2017.2] < 0 } {exit -1}

# Set the board part
set projBoardPart "xilinx.com:kcu1500:part0:1.0"
set_property board_part $projBoardPart [current_project]

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/core/"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500App.xdc"

# PCIe IP core
# loadSource -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.dcp"
loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"

# AXI XBAR IP core
# loadSource -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"

# Load the MIG Cores
loadSource -dir  "$::DIR_PATH/mig/"
loadIpCore -path "$::DIR_PATH/ip/Ddr4WithEcc.xci"
loadIpCore -path "$::DIR_PATH/ip/Ddr4WithoutEcc.xci"
loadIpCore -path "$::DIR_PATH/ip/DdrClkCross.xci"
loadIpCore -path "$::DIR_PATH/ip/DdrDataFifo.xci"

# # Place and Route strategies 
# set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# # Setup the project for partial reconfiguration
# set_property PR_FLOW 1 [current_project]

# # Create a partition in the application module
# create_partition_def   -name PR_APP      -module Application
# create_reconfig_module -name Application -partition_def [get_partition_defs PR_APP ]  -define_from Application


# # Update the filesets
# update_compile_order -fileset Application
# update_compile_order -fileset sources_1
