# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core      -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"
loadSource -lib axi_pcie_core   -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                         [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500PciePhy_pcie3_ip} [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {XilinxKcu1500PciePhy.xdc}]
