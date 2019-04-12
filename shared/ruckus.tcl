# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {1.7.6} ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {1.9.9} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in axi-pcie-core/ruckus.tcl"
   puts "*********************************************************\n\n"
}   

# Load Source Code
loadSource -dir "$::DIR_PATH/rtl"

# loadIpCore -dir "$::DIR_PATH/ip"
loadSource -dir "$::DIR_PATH/ip"

# Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
