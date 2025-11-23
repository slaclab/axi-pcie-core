# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2024.2 of Vivado (or later)
if { [VersionCheck 2024.2] < 0 } {exit -1}

####################################################################################
# https://docs.amd.com/r/en-US/pg348-cms-subsystem/Network-Plug-in-Module-Management
####################################################################################
loadSource -lib axi_pcie_core -path "$::DIR_PATH/rtl/CmsBlockDesignWrapper.vhd"

# Load the block design
if  { $::env(VIVADO_VERSION) >= 2024.2 } {
   set bdVer "2024.2"
} else {
   set bdVer "2024.2"
}

loadBlockDesign -path "$::DIR_PATH/${bdVer}/CmsBlockDesign.bd"
# loadBlockDesign -path "$::DIR_PATH/${bdVer}/CmsBlockDesign.tcl"

######################################################
# Do not include the CmsBlockDesign in the simulations
######################################################
set_property USED_IN_SIMULATION 0 [get_files CmsBlockDesign.bd]
