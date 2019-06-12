# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load source code
loadSource           -dir "$::DIR_PATH/rtl"
loadSource -sim_only -dir "$::DIR_PATH/tb"
loadIpCore           -dir "$::DIR_PATH/ip"

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxKcu1500Mig0.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig0}  [get_files {XilinxKcu1500Mig0.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxKcu1500Mig0.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxKcu1500Mig1.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig1}  [get_files {XilinxKcu1500Mig1.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxKcu1500Mig1.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxKcu1500Mig2.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig2}  [get_files {XilinxKcu1500Mig2.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxKcu1500Mig2.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3.xdc"
set_property PROCESSING_ORDER {EARLY}              [get_files {XilinxKcu1500Mig3.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig3}  [get_files {XilinxKcu1500Mig3.xdc}]
set_property SCOPED_TO_CELLS  {inst}               [get_files {XilinxKcu1500Mig3.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0_board.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig0_board.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig0_board.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig0}     [get_files {XilinxKcu1500Mig0_board.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig0_board.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1_board.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig1_board.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig1_board.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig1}     [get_files {XilinxKcu1500Mig1_board.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig1_board.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2_board.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig2_board.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig2_board.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig2}     [get_files {XilinxKcu1500Mig2_board.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig2_board.xdc}]

loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3_board.xdc"
set_property USED_IN {synthesis implementation board} [get_files {XilinxKcu1500Mig3_board.xdc}]
set_property PROCESSING_ORDER {EARLY}                 [get_files {XilinxKcu1500Mig3_board.xdc}]
set_property SCOPED_TO_REF    {XilinxKcu1500Mig3}     [get_files {XilinxKcu1500Mig3_board.xdc}]
set_property SCOPED_TO_CELLS  {inst}                  [get_files {XilinxKcu1500Mig3_board.xdc}]
