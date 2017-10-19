# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl
set ddrIpDir  "Config$::env(DDR_SPEED)Mbps"

# Check if building any MIG core
if { $::env(NUM_MIG_CORES)  != 0 } {
   loadSource -path "$::DIR_PATH/mig/MigXbar.vhd"
   loadIpCore -path "$::DIR_PATH/ip/DdrXbar.xci"
   loadIpCore -path "$::DIR_PATH/ip/${ddrIpDir}/Ddr4WithEcc.xci"
   loadIpCore -path "$::DIR_PATH/ip/${ddrIpDir}/Ddr4WithoutEcc.xci"
}

# Load MIG configuration based on Makefile constraints
if { $::env(NUM_MIG_CORES)  == 0 } {

   loadSource      -path "$::DIR_PATH/mig/Mig0Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig1Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig2Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig3Empty.vhd"

   # Check for  partial reconfiguration
   if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {    
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3Empty.xdc"
   }

} elseif { $::env(NUM_MIG_CORES)  == 1 } {

   loadSource      -path "$::DIR_PATH/mig/Mig0Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig1Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig2Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig3.vhd"

   # Check for  partial reconfiguration
   if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {   
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2Empty.xdc"
   }
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3.xdc"

} elseif { $::env(NUM_MIG_CORES)  == 2 } {

   loadSource      -path "$::DIR_PATH/mig/Mig0Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig1Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig2.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig3.vhd"
   
   # Check for  partial reconfiguration
   if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {  
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0Empty.xdc"
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1Empty.xdc"
   }
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3.xdc"

} elseif { $::env(NUM_MIG_CORES)  == 3 } {

   loadSource      -path "$::DIR_PATH/mig/Mig0Empty.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig1.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig2.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig3.vhd"

   # Check for  partial reconfiguration
   if { [info exists ::env(BYPASS_RECONFIG)] != 1 || $::env(BYPASS_RECONFIG) == 0 } {     
      loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0Empty.xdc"  
   }
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3.xdc"

} elseif { $::env(NUM_MIG_CORES)  == 4 } {

   loadSource      -path "$::DIR_PATH/mig/Mig0.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig1.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig2.vhd"
   loadSource      -path "$::DIR_PATH/mig/Mig3.vhd"

   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig0.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig1.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig2.xdc"
   loadConstraints -path "$::DIR_PATH/xdc/XilinxKcu1500Mig3.xdc"

} else {
   puts "\n\nERROR: NUM_MIG_CORES = $::env(NUM_MIG_CORES) is not valid."
   puts "It must be between 0 to 4"
   puts "Please fix this in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}
