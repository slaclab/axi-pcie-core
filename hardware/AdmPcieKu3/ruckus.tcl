# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource      -dir "$::DIR_PATH/rtl/"
loadConstraints -dir "$::DIR_PATH/xdc/"

# PCIe IP core
loadSource -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.dcp"
# loadIpCore -path "$::DIR_PATH/ip/AdmPcieKu3PciePhy.xci"

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
