# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Select the AXI XBAR for the PCIe interface
if { $::env(PCIE_GEN_NUM)  == "GEN1" } {
   loadSource -path "$::DIR_PATH/AxiXbar128b/AxiPcieCrossbar.vhd"
} else { 
   loadSource -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbar.vhd"
   loadIpCore -path "$::DIR_PATH/AxiXbar256b/AxiPcieCrossbarIpCore.xci"
}   

# Select either GEN1 or GEN2 or GEN3 PCIe
if { $::env(PCIE_GEN_NUM)  == "GEN1" } {
   loadRuckusTcl "$::DIR_PATH/PcieGen1"
} elseif { $::env(PCIE_GEN_NUM)  == "GEN2" } {
   loadRuckusTcl "$::DIR_PATH/PcieGen2"
} elseif { $::env(PCIE_GEN_NUM)  == "GEN3" } {
   loadRuckusTcl "$::DIR_PATH/PcieGen3"
} else {
   puts "\n\nERROR: PCIE_GEN_NUM = $::env(PCIE_GEN_NUM) is not valid."
   puts "It must be either GEN1 or GEN2 or GEN3"
   puts "Please fix this in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}   
