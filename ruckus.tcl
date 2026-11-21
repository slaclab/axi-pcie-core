# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# GHDL regression manifest (see tests/README.md)
# Lists only the sources that simulate without vendor IP, plus their simulation models
# Vivado projects load hardware/<board>/ruckus.tcl instead of this file
if { $::env(VIVADO_VERSION) > 0.0 } {
   puts "\n\nERROR: axi-pcie-core/ruckus.tcl is the GHDL regression manifest: load axi-pcie-core/hardware/<board> instead\n\n"
   exit -1
}

# Load the surf library
loadRuckusTcl "$::env(MODULES)/surf"

# XilinxVariumC1100: HBM DMA Buffer Version 2
loadSource -lib axi_pcie_core           -path "$::DIR_PATH/hardware/XilinxVariumC1100/hbm/HbmDmaBufferV2.vhd"
loadSource -lib axi_pcie_core           -path "$::DIR_PATH/hardware/XilinxVariumC1100/hbm/HbmDmaBufferV2AxiSplit.vhd"
loadSource -lib axi_pcie_core -sim_only -path "$::DIR_PATH/hardware/XilinxVariumC1100/tb/HbmDmaBufferV2IpCore.vhd"
loadSource -lib axi_pcie_core -sim_only -path "$::DIR_PATH/hardware/XilinxVariumC1100/tb/HbmDmaBufferV2Tb.vhd"
loadSource -lib surf          -sim_only -path "$::DIR_PATH/hardware/XilinxVariumC1100/tb/ClockManagerUltraScaleSim.vhd"
