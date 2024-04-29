# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core  -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/AbacoPc821PciePhy.xci"
loadSource -lib axi_pcie_core -path "$::DIR_PATH/ip/AbacoPc821PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/AbacoPc821PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                      [get_files {AbacoPc821PciePhy.xdc}]
set_property SCOPED_TO_REF    {AbacoPc821PciePhy_pcie3_ip} [get_files {AbacoPc821PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                       [get_files {AbacoPc821PciePhy.xdc}]
