# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -dir  "$::DIR_PATH/xdc"

# loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarResize.xci"
loadSource   -path "$::DIR_PATH/ip/AxiPcieCrossbarResize.dcp"

# loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource   -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"

# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"
loadSource   -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.dcp"

set_property PROCESSING_ORDER {EARLY}                         [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500PciePhy_pcie3_ip} [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {XilinxKcu1500PciePhy.xdc}]

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}]   
