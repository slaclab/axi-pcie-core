# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadIpCore -dir  "$::DIR_PATH/ip"
loadSource -dir  "$::DIR_PATH/rtl"
loadSource -path "$::DIR_PATH/../rtl/AxiPciePkg.vhd"
