# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu105PciePhy.xci"
loadSource   -path "$::DIR_PATH/ip/XilinxKcu105PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxKcu105PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                        [get_files {XilinxKcu105PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu105PciePhy_pcie3_ip} [get_files {XilinxKcu105PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                         [get_files {XilinxKcu105PciePhy.xdc}]
