# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core      -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu116PciePhy.xci"
loadSource -lib axi_pcie_core   -path "$::DIR_PATH/ip/XilinxKcu116PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxKcu116PciePhyGt.xdc"
set_property PROCESSING_ORDER {EARLY}                           [get_files {XilinxKcu116PciePhyGt.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu116PciePhy_pcie4_ip_gt} [get_files {XilinxKcu116PciePhyGt.xdc}]
set_property SCOPED_TO_CELLS  {inst}                            [get_files {XilinxKcu116PciePhyGt.xdc}]

loadConstraints -path "$::DIR_PATH/ip/XilinxKcu116PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                        [get_files {XilinxKcu116PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu116PciePhy_pcie4_ip} [get_files {XilinxKcu116PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                         [get_files {XilinxKcu116PciePhy.xdc}]
