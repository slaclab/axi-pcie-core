# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

loadSource -dir "$::DIR_PATH/rtl"

# loadIpCore    -path "$::DIR_PATH/ip/XilinxAc701PciePhy.xci"
loadSource      -path "$::DIR_PATH/ip/XilinxAc701PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/XilinxAc701PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxAc701PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxAc701PciePhy} [get_files {XilinxAc701PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxAc701PciePhy.xdc}]

# loadIpCore    -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadConstraints -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xdc"

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}] 
