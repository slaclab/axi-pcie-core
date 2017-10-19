# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check if lcls-timing-core submodule exists
if { [file exists $::env(MODULES)/lcls-timing-core] == 1 } {

   loadSource      -dir  "$::DIR_PATH/pgp2b"
   loadConstraints -dir  "$::DIR_PATH/pgp2b"
   loadIpCore      -path "$::DIR_PATH/pgp2b/Pgp2bGtp7Drp.xci"
   
   loadSource      -dir  "$::DIR_PATH/evr"
   loadConstraints -dir  "$::DIR_PATH/evr"
   
}
