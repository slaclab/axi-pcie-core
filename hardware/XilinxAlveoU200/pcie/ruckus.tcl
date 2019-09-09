# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/XilinxAlveoU200PciePhy.xci"

loadSource -path "$::DIR_PATH/ip/XilinxAlveoU200PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/ip_pcie4_uscale_plus_x1y2.xdc"
set_property PROCESSING_ORDER {EARLY}                           [get_files {ip_pcie4_uscale_plus_x1y2.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200PciePhy_pcie4_ip} [get_files {ip_pcie4_uscale_plus_x1y2.xdc}]
set_property SCOPED_TO_CELLS  {inst}                            [get_files {ip_pcie4_uscale_plus_x1y2.xdc}]


loadConstraints -path "$::DIR_PATH/ip/XilinxAlveoU200PciePhy_pcie4_ip_gt.xdc"
set_property PROCESSING_ORDER {EARLY}                              [get_files {XilinxAlveoU200PciePhy_pcie4_ip_gt.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200PciePhy_pcie4_ip_gt} [get_files {XilinxAlveoU200PciePhy_pcie4_ip_gt.xdc}]
set_property SCOPED_TO_CELLS  {inst}                               [get_files {XilinxAlveoU200PciePhy_pcie4_ip_gt.xdc}]

loadConstraints -path "$::DIR_PATH/ip/XilinxAlveoU200PciePhy_pcie4_ip_late.xdc"
set_property PROCESSING_ORDER {LATE}                            [get_files {XilinxAlveoU200PciePhy_pcie4_ip_late.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200PciePhy_pcie4_ip} [get_files {XilinxAlveoU200PciePhy_pcie4_ip_late.xdc}]
set_property SCOPED_TO_CELLS  {inst}                            [get_files {XilinxAlveoU200PciePhy_pcie4_ip_late.xdc}]
