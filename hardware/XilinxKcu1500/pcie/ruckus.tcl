# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xci"
loadSource   -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxKcu1500PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                         [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500PciePhy_pcie3_ip} [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {XilinxKcu1500PciePhy.xdc}]

# loadIpCore    -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadConstraints -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xdc"

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}] 

# loadIpCore -path "$::DIR_PATH/ip/AxiPcieResize4BCore.xci"
# loadIpCore -path "$::DIR_PATH/ip/AxiPcieResize8BCore.xci"
# loadIpCore -path "$::DIR_PATH/ip/AxiPcieResize16BCore.xci"

loadSource -path "$::DIR_PATH/ip/AxiPcieResize4BCore.dcp"
loadSource -path "$::DIR_PATH/ip/AxiPcieResize8BCore.dcp"
loadSource -path "$::DIR_PATH/ip/AxiPcieResize16BCore.dcp"
