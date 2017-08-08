# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

## Check for version 2017.2 of Vivado (or later)
if { [VersionCheck 2017.2] < 0 } {exit -1}

# Set the board part
set projBoardPart "xilinx.com:kcu1500:part0:1.0"
set_property board_part $projBoardPart [current_project]

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/core/"
loadSource      -dir  "$::DIR_PATH/mig/"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Core.xdc"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500App.xdc"

# Load IP Cores
loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"
loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadIpCore -path "$::DIR_PATH/ip/Ddr4WithEcc.xci"
loadIpCore -path "$::DIR_PATH/ip/Ddr4WithoutEcc.xci"
loadIpCore -path "$::DIR_PATH/ip/DdrXbar.xci"
