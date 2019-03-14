# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

loadSource -dir "$::DIR_PATH/rtl"

# loadIpCore    -path "$::DIR_PATH/ip/XilinxKc705PciePhy.xci"
loadSource      -path "$::DIR_PATH/ip/XilinxKc705PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxKc705PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxKc705PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKc705PciePhy} [get_files {XilinxKc705PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxKc705PciePhy.xdc}]

# loadIpCore    -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadConstraints -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xdc"

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}] 
