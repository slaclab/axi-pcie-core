# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load source code
loadSource -lib axi_pcie_core           -dir "$::DIR_PATH/rtl"
loadIpCore                              -dir "$::DIR_PATH/ip"
loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"
loadConstraints                         -dir "$::DIR_PATH/xdc"

# Load the User port naming
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig0_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU250Mig0_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig0_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig0Core}  [get_files {XilinxAlveoU250Mig0_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig0_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig1_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU250Mig1_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig1_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig1Core}  [get_files {XilinxAlveoU250Mig1_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig1_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig2_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU250Mig2_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig2_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig2Core}  [get_files {XilinxAlveoU250Mig2_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig2_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig3_user_mapping.xdc"
set_property USED_IN {synthesis implementation board}    [get_files {XilinxAlveoU250Mig3_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig3_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig3Core}  [get_files {XilinxAlveoU250Mig3_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig3_user_mapping.xdc}]

# Load the User constraints
loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig0_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU250Mig0_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig0_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig0Core}  [get_files {XilinxAlveoU250Mig0_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig0_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig1_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU250Mig1_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig1_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig1Core}  [get_files {XilinxAlveoU250Mig1_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig1_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig2_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU250Mig2_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig2_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig2Core}  [get_files {XilinxAlveoU250Mig2_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig2_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxAlveoU250Mig3_user.xdc"
set_property USED_IN {synthesis implementation}          [get_files {XilinxAlveoU250Mig3_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                    [get_files {XilinxAlveoU250Mig3_user.xdc}]
set_property SCOPED_TO_REF    {XilinxAlveoU250Mig3Core}  [get_files {XilinxAlveoU250Mig3_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                     [get_files {XilinxAlveoU250Mig3_user.xdc}]

# Set the XilinxAlveoU250MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {XilinxAlveoU250MigTiming.xdc}]
