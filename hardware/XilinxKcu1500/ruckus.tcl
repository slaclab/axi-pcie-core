# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/core/"
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Core.xdc"

# PCIe IP core
loadSource -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.dcp"
# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"

# AXI XBAR IP core
loadSource -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"

# Check for version 2017.1 of Vivado (or later
if { [expr { $::env(VIVADO_VERSION) >= 2017.1 }] } {
   set projBoardPart "xilinx.com:kcu1500:part0:1.0"
   set_property board_part $projBoardPart [current_project]
}
