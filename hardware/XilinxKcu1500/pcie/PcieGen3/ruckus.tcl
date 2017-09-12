# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir "$::DIR_PATH/rtl"

# Check for partial reconfiguration
if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {
   loadSource -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhyWrapper.vhd"
   loadIpCore -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhy.xci"
} else {
   loadSource -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhyWrapper.vhd"
   loadIpCore -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhy.xci"
}

# Check for TIG
if { [info exists ::env(TIG)] != 1 || $::env(TIG) == 0 } {
   loadConstraints -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhy.xdc"
} else {
   loadConstraints -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhy.xdc"
}