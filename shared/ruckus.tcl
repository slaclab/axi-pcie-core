# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {4.17.0} ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {2.51.0} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in axi-pcie-core/ruckus.tcl"
   puts "*********************************************************\n\n"
}

# Check for version 2023.1 of Vivado (or later)
if { [VersionCheck 2023.1] < 0 } {exit -1}

# Load Source Code
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip"
loadRuckusTcl "$::DIR_PATH/../protocol/pip"
loadRuckusTcl "$::DIR_PATH/../protocol/gpuAsync"

# loadIpCore -dir "$::DIR_PATH/ip/AxiPcie16BCrossbarIpCore"
# loadIpCore -dir "$::DIR_PATH/ip/AxiPcie32BCrossbarIpCore"
# loadIpCore -dir "$::DIR_PATH/ip/AxiPcie64BCrossbarIpCore"
# loadIpCore -dir "$::DIR_PATH/ip/AxiPcieResize"
# loadIpCore -dir "$::DIR_PATH/ip/SystemManagementCore"

loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip/AxiPcie16BCrossbarIpCore"
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip/AxiPcie32BCrossbarIpCore"
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip/AxiPcie64BCrossbarIpCore"
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip/AxiPcieResize"
loadSource -lib axi_pcie_core -dir "$::DIR_PATH/ip/SystemManagementCore"

# Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
