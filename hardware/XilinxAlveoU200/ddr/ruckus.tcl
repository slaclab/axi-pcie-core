# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource -lib axi_pcie_core           -dir "$::DIR_PATH/rtl"
loadIpCore                              -dir "$::DIR_PATH/ip"
loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"
loadConstraints                         -dir "$::DIR_PATH/xdc"

# Load the User port naming
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig0_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU200Mig0_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig0_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig0Core}  [get_files {XilinxAlveoU200Mig0_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig0_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig1_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU200Mig1_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig1_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig1Core}  [get_files {XilinxAlveoU200Mig1_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig1_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig2_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU200Mig2_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig2_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig2Core}  [get_files {XilinxAlveoU200Mig2_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig2_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig3_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU200Mig3_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig3_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig3Core}  [get_files {XilinxAlveoU200Mig3_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig3_user_mapping.xdc}]

# Load the User constraints
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig0_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU200Mig0_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig0_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig0Core}  [get_files {XilinxAlveoU200Mig0_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig0_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig1_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU200Mig1_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig1_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig1Core}  [get_files {XilinxAlveoU200Mig1_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig1_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig2_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU200Mig2_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig2_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig2Core}  [get_files {XilinxAlveoU200Mig2_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig2_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU200Mig3_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU200Mig3_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU200Mig3_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU200Mig3Core}  [get_files {XilinxAlveoU200Mig3_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU200Mig3_user.xdc}]

# Set the XilinxAlveoU200MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {XilinxAlveoU200MigTiming.xdc}]
