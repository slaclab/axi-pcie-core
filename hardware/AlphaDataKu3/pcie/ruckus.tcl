# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/AlphaDataKu3PciePhy.xci"
loadSource   -path "$::DIR_PATH/ip/AlphaDataKu3PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/AlphaDataKu3PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                         [get_files {AlphaDataKu3PciePhy.xdc}]
set_property SCOPED_TO_REF    {AlphaDataKu3PciePhy_pcie3_ip} [get_files {AlphaDataKu3PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {AlphaDataKu3PciePhy.xdc}]
