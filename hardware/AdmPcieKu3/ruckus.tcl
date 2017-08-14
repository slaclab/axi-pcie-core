# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA part number
if { $::env(PRJ_PART) != "XCKU060-FFVA1156-2-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCKU060-FFVA1156-2-E in the Makefile\n\n"; exit -1
}

# Check if required variables exist
if { [info exists ::env(BUILD_DDR0_MIG)] != 1 } {
   puts "\n\nERROR: BUILD_DDR0_MIG is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(BUILD_DDR1_MIG)] != 1 } {
   puts "\n\nERROR: BUILD_DDR1_MIG is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/core/"
loadConstraints -path "$::DIR_PATH/xdc/AdmPcieKu3Core.xdc"

# PCIe IP core
loadIpCore -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.xci"

# AXI XBAR IP core
loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"

# MIG IP core
loadIpCore -path "$::DIR_PATH/ip/AdmPcieKu3MigPhy.xci"

# Check if building DDR[0] memory interface
if {  $::env(BUILD_DDR0_MIG)  == 1 } {
   loadSource      -path "$::DIR_PATH/mig/AdmPcieKu3Mig0.vhd"
   loadConstraints -path "$::DIR_PATH/xdc/AdmPcieKu3Mig0.xdc"
} else {
   loadSource      -path "$::DIR_PATH/mig/AdmPcieKu3Mig0Empty.vhd"
}

# Check if building DDR[1] memory interface
if {  $::env(BUILD_DDR1_MIG)  == 1 } {
   loadSource      -path "$::DIR_PATH/mig/AdmPcieKu3Mig1.vhd"
   loadConstraints -path "$::DIR_PATH/xdc/AdmPcieKu3Mig1.xdc"
} else {
   loadSource      -path "$::DIR_PATH/mig/AdmPcieKu3Mig1Empty.vhd"
}
