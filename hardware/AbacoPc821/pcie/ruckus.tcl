# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for valid FPGA part number
if { $::env(PRJ_PART) == "XCKU085-FLVB1760-2-E" } {
   set ipDir "XCKU085"
} elseif { $::env(PRJ_PART) == "XCKU115-FLVB1760-2-E" } {
   set ipDir "XCKU115"
} else {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU085-FLVB1760-2-E or XCKU115-FLVB1760-2-E in the Makefile\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource -lib axi_pcie_core  -dir  "$::DIR_PATH/rtl"

# loadIpCore -path "$::DIR_PATH/${ipDir}/AbacoPc821PciePhy.xci"

loadSource -lib axi_pcie_core -path "$::DIR_PATH/${ipDir}/AbacoPc821PciePhy.dcp"

loadConstraints -path "$::DIR_PATH/${ipDir}/AbacoPc821PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                      [get_files {AbacoPc821PciePhy.xdc}]
set_property SCOPED_TO_REF    {AbacoPc821PciePhy_pcie3_ip} [get_files {AbacoPc821PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                       [get_files {AbacoPc821PciePhy.xdc}]
