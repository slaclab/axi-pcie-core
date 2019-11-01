# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource           -dir "$::DIR_PATH/rtl"
loadIpCore           -dir "$::DIR_PATH/ip"
loadSource -sim_only -dir "$::DIR_PATH/tb"
loadConstraints      -dir "$::DIR_PATH/xdc"

# Load the User port naming
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU280Mig0_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU280Mig0_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU280Mig0_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU280Mig0Core}  [get_files {XilinxAlveoU280Mig0_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU280Mig0_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU280Mig1_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU280Mig1_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU280Mig1_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU280Mig1Core}  [get_files {XilinxAlveoU280Mig1_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU280Mig1_user_mapping.xdc}]

# Load the User constraints
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU280Mig0_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU280Mig0_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU280Mig0_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU280Mig0Core}  [get_files {XilinxAlveoU280Mig0_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU280Mig0_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU280Mig1_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU280Mig1_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU280Mig1_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU280Mig1Core}  [get_files {XilinxAlveoU280Mig1_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU280Mig1_user.xdc}]

# Set the XilinxAlveoU280MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {XilinxAlveoU280MigTiming.xdc}]
