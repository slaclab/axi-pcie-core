# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"
loadConstraints               -dir "$::DIR_PATH/xdc"

# loadIpCore -path "$::DIR_PATH/ip/XilinxVariumC1100PciePhyGen3x16.xci"
loadSource -lib axi_pcie_core -path "$::DIR_PATH/ip/XilinxVariumC1100PciePhyGen3x16.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_gt.xdc"
set_property PROCESSING_ORDER {EARLY}                                        [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_gt.xdc}]
set_property SCOPED_TO_REF    {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_gt} [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_gt.xdc}]
set_property SCOPED_TO_CELLS  {inst}                                         [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_gt.xdc}]

loadConstraints -path "$::DIR_PATH/ip/ip_pcie4c_uscale_plus_impl_x1y1.xdc"
set_property PROCESSING_ORDER {EARLY}                                     [get_files {ip_pcie4c_uscale_plus_impl_x1y1.xdc}]
set_property SCOPED_TO_REF    {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip} [get_files {ip_pcie4c_uscale_plus_impl_x1y1.xdc}]
set_property SCOPED_TO_CELLS  {inst}                                      [get_files {ip_pcie4c_uscale_plus_impl_x1y1.xdc}]

loadConstraints -path "$::DIR_PATH/ip/ip_pcie4c_uscale_plus_x1y1.xdc"
set_property PROCESSING_ORDER {EARLY}                                     [get_files {ip_pcie4c_uscale_plus_x1y1.xdc}]
set_property SCOPED_TO_REF    {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip} [get_files {ip_pcie4c_uscale_plus_x1y1.xdc}]
set_property SCOPED_TO_CELLS  {inst}                                      [get_files {ip_pcie4c_uscale_plus_x1y1.xdc}]

loadConstraints -path "$::DIR_PATH/ip/XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_late.xdc"
set_property PROCESSING_ORDER {LATE}                                      [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_late.xdc}]
set_property SCOPED_TO_REF    {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip} [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_late.xdc}]
set_property SCOPED_TO_CELLS  {inst}                                      [get_files {XilinxVariumC1100PciePhyGen3x16_pcie4c_ip_late.xdc}]
