# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XC7A200TFFG1156-3" } {
   puts "\n\nERROR: PRJ_PART was not defined as XC7A200TFFG1156-3 in the Makefile\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource      -dir "$::DIR_PATH/rtl/"
loadConstraints -dir "$::DIR_PATH/xdc/"

# IP cores
loadSource -path "$::DIR_PATH/ip/AxiPgpCardG3PciePhy.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AxiPgpCardG3PciePhy.xci"
