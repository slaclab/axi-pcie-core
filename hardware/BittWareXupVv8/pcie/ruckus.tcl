# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/BittWareXupVv8PciePhy.xci"

loadSource -lib axi_pcie_core -path "$::DIR_PATH/ip/BittWareXupVv8PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/ip_pcie4_uscale_plus_x0y1.xdc"
set_property PROCESSING_ORDER {EARLY}                          [get_files {ip_pcie4_uscale_plus_x0y1.xdc}]
set_property SCOPED_TO_REF    {BittWareXupVv8PciePhy_pcie4_ip} [get_files {ip_pcie4_uscale_plus_x0y1.xdc}]
set_property SCOPED_TO_CELLS  {inst}                           [get_files {ip_pcie4_uscale_plus_x0y1.xdc}]


loadConstraints -path "$::DIR_PATH/ip/BittWareXupVv8PciePhy_pcie4_ip_gt.xdc"
set_property PROCESSING_ORDER {EARLY}                             [get_files {BittWareXupVv8PciePhy_pcie4_ip_gt.xdc}]
set_property SCOPED_TO_REF    {BittWareXupVv8PciePhy_pcie4_ip_gt} [get_files {BittWareXupVv8PciePhy_pcie4_ip_gt.xdc}]
set_property SCOPED_TO_CELLS  {inst}                              [get_files {BittWareXupVv8PciePhy_pcie4_ip_gt.xdc}]

loadConstraints -path "$::DIR_PATH/ip/BittWareXupVv8PciePhy_pcie4_ip_late.xdc"
set_property PROCESSING_ORDER {LATE}                           [get_files {BittWareXupVv8PciePhy_pcie4_ip_late.xdc}]
set_property SCOPED_TO_REF    {BittWareXupVv8PciePhy_pcie4_ip} [get_files {BittWareXupVv8PciePhy_pcie4_ip_late.xdc}]
set_property SCOPED_TO_CELLS  {inst}                           [get_files {BittWareXupVv8PciePhy_pcie4_ip_late.xdc}]
