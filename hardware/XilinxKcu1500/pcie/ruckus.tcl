# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Select the AXI XBAR for the PCIe interface
if { $::env(PCIE_GEN_NUM)  == "GEN1" } {
   loadSource -path "$::DIR_PATH/AxiXbar128b/AxiPcieCrossbar.vhd"
} else { 
   loadSource      -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbar.vhd"

   # loadIpCore    -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarResize.xci"
   loadSource      -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarResize.dcp"
   
   # loadIpCore    -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarIpCore.xci"
   loadSource      -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarIpCore.dcp"
   loadConstraints -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarIpCore.xdc"
   
   set_property PROCESSING_ORDER {LATE}                  [get_files {AxiPcieCrossbarIpCore.xdc}]
   set_property SCOPED_TO_REF    {AxiPcieCrossbarIpCore} [get_files {AxiPcieCrossbarIpCore.xdc}]
   set_property SCOPED_TO_CELLS  {inst}                  [get_files {AxiPcieCrossbarIpCore.xdc}]   
}   

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
loadSource      -path "${pciePath}/AxiPciePkg.vhd"
loadSource      -path "${pciePath}/XilinxKcu1500PciePhyWrapper.vhd"

# Load IP core
# loadIpCore    -path "${pciePath}/XilinxKcu1500PciePhy.xci"
loadSource      -path "${pciePath}/XilinxKcu1500PciePhy.dcp"

loadConstraints -path "${pciePath}/XilinxKcu1500PciePhy.xdc"
set_property PROCESSING_ORDER {EARLY}                         [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500PciePhy_pcie3_ip} [get_files {XilinxKcu1500PciePhy.xdc}]
set_property SCOPED_TO_CELLS  {inst}                          [get_files {XilinxKcu1500PciePhy.xdc}]
