# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir  "$::DIR_PATH/rtl"

loadConstraints -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.xdc"
# loadIpCore    -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.xci"
loadSource      -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.dcp"

set_property PROCESSING_ORDER {EARLY}                      [get_files {AdmPcieKu3PciePhy.xdc}]
set_property SCOPED_TO_REF    {AdmPcieKu3PciePhy_pcie3_ip} [get_files {AdmPcieKu3PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                       [get_files {AdmPcieKu3PciePhy.xdc}]