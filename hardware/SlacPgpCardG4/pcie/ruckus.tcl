# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Placeholder for multiple FPGA type support in the future
set FpgaType "XCKU040"

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/ip/${FpgaType}/SlacPgpCardG4PciePhy.xci"
loadSource -lib axi_pcie_core   -path "$::DIR_PATH/ip/${FpgaType}/SlacPgpCardG4PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/${FpgaType}/SlacPgpCardG4PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                         [get_files {SlacPgpCardG4PciePhy.xdc}]
set_property SCOPED_TO_REF    {SlacPgpCardG4PciePhy_pcie3_ip} [get_files {SlacPgpCardG4PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {U0}                            [get_files {SlacPgpCardG4PciePhy.xdc}]
