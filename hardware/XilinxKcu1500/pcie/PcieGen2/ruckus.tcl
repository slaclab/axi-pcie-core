# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir "$::DIR_PATH/rtl"

# Check for partial reconfiguration
if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {
   loadSource      -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhyWrapper.vhd"
   loadConstraints -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhy.xdc"
   # loadIpCore    -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhy.xci"
   loadSource      -path "$::DIR_PATH/WithPartialReconfig/XilinxKcu1500PciePhy.dcp"
} else {
   loadSource      -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhyWrapper.vhd"
   loadConstraints -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhy.xdc"
   # loadIpCore    -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhy.xci"
   loadSource      -path "$::DIR_PATH/WithoutPartialReconfig/XilinxKcu1500PciePhy.dcp"
}

set_property PROCESSING_ORDER {EARLY}                         [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500PciePhy_pcie3_ip} [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {XilinxKcu1500PciePhy.xdc}]
