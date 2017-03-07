# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Sonstraints
loadSource      -dir "$::DIR_PATH/rtl/"
loadConstraints -dir "$::DIR_PATH/xdc/"

# IP cores
loadSource -path "$::DIR_PATH/ip/AxiPciePgpCardG3IpCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AxiPciePgpCardG3IpCore.xci"
