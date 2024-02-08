# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource -lib axi_pcie_core           -dir "$::DIR_PATH/rtl"
loadSource -lib axi_pcie_core -sim_only -dir "$::DIR_PATH/tb"
loadConstraints                         -dir "$::DIR_PATH/xdc"

if { $::env(VIVADO_VERSION) <= 2018.3 } {
   loadIpCore -dir "$::DIR_PATH/ip/2018.3"
} elseif  { $::env(VIVADO_VERSION) <= 2022.1 } {
   loadIpCore -dir "$::DIR_PATH/ip/2019.1"
} else {
   loadIpCore -dir "$::DIR_PATH/ip/2022.2"
}

# Add MigClkConvt
loadIpCore -path "$::DIR_PATH/ip/MigClkConvt.xci"
loadSource -sim_only -lib axi_infrastructure_v1_1_0 -fileType {Verilog Header} -path "$::DIR_PATH/ip/axi_infrastructure_v1_1_0.vh"

# Load the User port naming
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0_user_mapping.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig0_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig0_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig0Core} [get_files {XilinxKcu1500Mig0_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig0_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1_user_mapping.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig1_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig1_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig1Core} [get_files {XilinxKcu1500Mig1_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig1_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2_user_mapping.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig2_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig2_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig2Core} [get_files {XilinxKcu1500Mig2_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig2_user_mapping.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3_user_mapping.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig3_user_mapping.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig3_user_mapping.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig3Core} [get_files {XilinxKcu1500Mig3_user_mapping.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig3_user_mapping.xdc}]

# Load the User constraints
loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0_user.xdc"
set_property USED_IN {synthesis implementation}       [get_files {XilinxKcu1500Mig0_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig0_user.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig0Core} [get_files {XilinxKcu1500Mig0_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig0_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1_user.xdc"
set_property USED_IN {synthesis implementation}       [get_files {XilinxKcu1500Mig1_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig1_user.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig1Core} [get_files {XilinxKcu1500Mig1_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig1_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2_user.xdc"
set_property USED_IN {synthesis implementation}       [get_files {XilinxKcu1500Mig2_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig2_user.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig2Core} [get_files {XilinxKcu1500Mig2_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig2_user.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3_user.xdc"
set_property USED_IN {synthesis implementation}       [get_files {XilinxKcu1500Mig3_user.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig3_user.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig3Core} [get_files {XilinxKcu1500Mig3_user.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig3_user.xdc}]

# Set the XilinxKcu1500MigTiming to the end of the process
set_property PROCESSING_ORDER LATE  [get_files {XilinxKcu1500MigTiming.xdc}]
