# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir  "$::DIR_PATH/rtl"
loadIpCore -path "$::DIR_PATH/ip/XilinxAlveoU200PciePhy.xci"
