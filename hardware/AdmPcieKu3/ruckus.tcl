# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

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
loadSource -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.xci"

# AXI XBAR IP core
loadSource -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AxiPcieCrossbarIpCore.xci"

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

# Check if either DDR memory interface is used
if { $::env(BUILD_DDR0_MIG)  == 1  || 
     $::env(BUILD_DDR1_MIG)  == 1 } {
   
   # MIG IP core
   loadSource -path "$::DIR_PATH/ip/AdmPcieKu3MigPhy.dcp"
   # loadIpCore -path "$::DIR_PATH/ip/AdmPcieKu3MigPhy.xci"
   
   # Check if application does not have Microblaze build
   if { [expr [info exists ::env(SDK_SRC_PATH)]] == 0 } {
      ## Add the Microblaze Calibration Code
      add_files $::DIR_PATH/ip/AdmPcieKu3MigPhyMicroblazeCalibration.elf
      set_property SCOPED_TO_REF   {AdmPcieKu3MigPhy} [get_files AdmPcieKu3MigPhyMicroblazeCalibration.elf]
      set_property SCOPED_TO_CELLS {inst/u_ddr3_mem_intfc/u_ddr_cal_riu/mcs0/microblaze_I} [get_files AdmPcieKu3MigPhyMicroblazeCalibration.elf]

      add_files $::DIR_PATH/ip/AdmPcieKu3MigPhyMicroblazeCalibration.bmm
      set_property SCOPED_TO_REF   {AdmPcieKu3MigPhy} [get_files AdmPcieKu3MigPhyMicroblazeCalibration.bmm]
      set_property SCOPED_TO_CELLS {inst/u_ddr3_mem_intfc/u_ddr_cal_riu/mcs0} [get_files AdmPcieKu3MigPhyMicroblazeCalibration.bmm]
   }
   
}
