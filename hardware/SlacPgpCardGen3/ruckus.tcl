# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the target language for Verilog (removes warning messages in PCIe IP core)
set_property target_language Verilog [current_project]

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XC7A200TFFG1156-3" } {
   puts "\n\nERROR: PRJ_PART was not defined as XC7A200TFFG1156-3 in the Makefile\n\n"; exit -1
}

# Check for version 2018.2 of Vivado (or later)
if { [VersionCheck 2018.2] < 0 } {exit -1}

# Load shared source code
loadRuckusTcl "$::DIR_PATH/../../shared"

# Load local Source Code and Constraints
loadSource      -dir "$::DIR_PATH/rtl"
loadConstraints -dir "$::DIR_PATH/xdc"

# loadIpCore    -path "$::DIR_PATH/ip/AxiPgpCardG3PciePhy.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPgpCardG3PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/ip/AxiPgpCardG3PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}               [get_files {AxiPgpCardG3PciePhy.xdc}]
set_property SCOPED_TO_REF    {AxiPgpCardG3PciePhy} [get_files {AxiPgpCardG3PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                [get_files {AxiPgpCardG3PciePhy.xdc}]

# loadIpCore    -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"
loadSource      -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
loadConstraints -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xdc"

set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}] 
