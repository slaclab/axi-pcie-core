# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Select either GEN1 or GEN2 or GEN3 PCIe
if { $::env(PCIE_GEN_NUM)  == "GEN1" } {
   set pciePath "$::DIR_PATH/PcieGen1"
} elseif { $::env(PCIE_GEN_NUM)  == "GEN2" } {
   set pciePath "$::DIR_PATH/PcieGen2"
} elseif { $::env(PCIE_GEN_NUM)  == "GEN3" } {
   set pciePath "$::DIR_PATH/PcieGen3"
} else {
   puts "\n\nERROR: PCIE_GEN_NUM = $::env(PCIE_GEN_NUM) is not valid."
   puts "It must be either GEN1 or GEN2 or GEN3"
   puts "Please fix this in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}   

# Load local Source Code and Constraints
loadSource      -dir  "$::DIR_PATH/rtl"
loadConstraints -dir  "$::DIR_PATH/xdc"
loadSource      -path "${pciePath}/XilinxKcu1500ExtendedPciePhyWrapper.vhd"

# Load IP core
loadSource      -path "${pciePath}/XilinxKcu1500ExtendedPciePhy.dcp"
# loadIpCore    -path "${pciePath}/XilinxKcu1500ExtendedPciePhy.xci"

loadConstraints -path "${pciePath}/XilinxKcu1500ExtendedPciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                                 [get_files {XilinxKcu1500ExtendedPciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500ExtendedPciePhy_pcie3_ip} [get_files {XilinxKcu1500ExtendedPciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                                  [get_files {XilinxKcu1500ExtendedPciePhy.xdc}]
