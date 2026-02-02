####################################################################################
# https://docs.amd.com/r/en-US/pg348-cms-subsystem/Network-Plug-in-Module-Management
####################################################################################

# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Check for version 2024.2 of Vivado (or later)
if { [VersionCheck 2024.2] < 0 } {exit -1}

# Load the block design
if  { $::env(VIVADO_VERSION) >= 2024.2 } {
   set bdVer "2024.2"
} else {
   set bdVer "2024.2"
}

# Check if using CmsBlockDesign.bd
if { [expr [info exists ::env(CMS_BLOCK_DESIGN_BD_FILE)]] != 0 } {

   loadSource -lib axi_pcie_core -path "$::DIR_PATH/${bdVer}/CmsBlockDesignWrapper.vhd"

   loadBlockDesign -path "$::DIR_PATH/${bdVer}/CmsBlockDesign.bd"
   # loadBlockDesign -path "$::DIR_PATH/${bdVer}/CmsBlockDesign.tcl"

   ######################################################
   # Do not include the CmsBlockDesign in the simulations
   ######################################################
   set_property USED_IN_SIMULATION 0 [get_files CmsBlockDesign.bd]

# Else using CmsBlockDesign_wrapper.dcp
} else {

   loadSource -lib axi_pcie_core -path "$::DIR_PATH/dcp/CmsBlockDesignWrapper.vhd"

   # DCP generated from https://github.com/slaclab/pgp-pcie-apps/tree/main/firmware/targets/XilinxAlveoU55c/CmsBlockDesign_wrapper
   loadSource -lib axi_pcie_core -path "$::DIR_PATH/dcp/CmsBlockDesign_wrapper.dcp"

   # .elf file copied from targets/XilinxAlveoU55c/CmsBlockDesign_wrapper project
   add_files -norecurse "$::DIR_PATH/dcp/cms_xcu55.elf"
   set_property SCOPED_TO_CELLS {inst/microblaze_cmc}              [get_files -all -of_objects [get_fileset sources_1] {cms_xcu55.elf}]
   set_property SCOPED_TO_REF   {CmsBlockDesign_cms_subsystem_0_0} [get_files -all -of_objects [get_fileset sources_1] {cms_xcu55.elf}]

   # .bmm file copied from targets/XilinxAlveoU55c/CmsBlockDesign_wrapper project
   add_files -norecurse "$::DIR_PATH/dcp/bd_a6d7.bmm"
   set_property SCOPED_TO_CELLS {}        [get_files -all -of_objects [get_fileset sources_1] {bd_a6d7.bmm}]
   set_property SCOPED_TO_REF   {bd_a6d7} [get_files -all -of_objects [get_fileset sources_1] {bd_a6d7.bmm}]

}
