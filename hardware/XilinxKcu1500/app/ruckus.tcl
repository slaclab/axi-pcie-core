# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -dir "$::DIR_PATH/pgp2b"

# Check if lcls-timing-core submodule exists
if { [file exists $::env(MODULES)/lcls-timing-core] == 1 } {   
   loadSource      -dir  "$::DIR_PATH/evr"
}
