##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_Extended}]

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN AN9 [get_ports {pciExtTxP[7]}]
set_property PACKAGE_PIN AN8 [get_ports {pciExtTxN[7]}]
set_property PACKAGE_PIN AN4 [get_ports {pciExtRxP[7]}]
set_property PACKAGE_PIN AN3 [get_ports {pciExtRxN[7]}]

set_property PACKAGE_PIN AM7 [get_ports {pciExtTxP[6]}]
set_property PACKAGE_PIN AM6 [get_ports {pciExtTxN[6]}]
set_property PACKAGE_PIN AM2 [get_ports {pciExtRxP[6]}]
set_property PACKAGE_PIN AM1 [get_ports {pciExtRxN[6]}]

set_property PACKAGE_PIN AL9 [get_ports {pciExtTxP[5]}]
set_property PACKAGE_PIN AL8 [get_ports {pciExtTxN[5]}]
set_property PACKAGE_PIN AL4 [get_ports {pciExtRxP[5]}]
set_property PACKAGE_PIN AL3 [get_ports {pciExtRxN[5]}]

set_property PACKAGE_PIN AK7 [get_ports {pciExtTxP[4]}]
set_property PACKAGE_PIN AK6 [get_ports {pciExtTxN[4]}]
set_property PACKAGE_PIN AK2 [get_ports {pciExtRxP[4]}]
set_property PACKAGE_PIN AK1 [get_ports {pciExtRxN[4]}]

set_property PACKAGE_PIN AJ9 [get_ports {pciExtTxP[3]}]
set_property PACKAGE_PIN AJ8 [get_ports {pciExtTxN[3]}]
set_property PACKAGE_PIN AJ4 [get_ports {pciExtRxP[3]}]
set_property PACKAGE_PIN AJ3 [get_ports {pciExtRxN[3]}]

set_property PACKAGE_PIN AH7 [get_ports {pciExtTxP[2]}]
set_property PACKAGE_PIN AH6 [get_ports {pciExtTxN[2]}]
set_property PACKAGE_PIN AH2 [get_ports {pciExtRxP[2]}]
set_property PACKAGE_PIN AH1 [get_ports {pciExtRxN[2]}]

set_property PACKAGE_PIN AG9 [get_ports {pciExtTxP[1]}]
set_property PACKAGE_PIN AG8 [get_ports {pciExtTxN[1]}]
set_property PACKAGE_PIN AG4 [get_ports {pciExtRxP[1]}]
set_property PACKAGE_PIN AG3 [get_ports {pciExtRxN[1]}]

set_property PACKAGE_PIN AF7 [get_ports {pciExtTxP[0]}]
set_property PACKAGE_PIN AF6 [get_ports {pciExtTxN[0]}]
set_property PACKAGE_PIN AF2 [get_ports {pciExtRxP[0]}]
set_property PACKAGE_PIN AF1 [get_ports {pciExtRxN[0]}]

set_property PACKAGE_PIN AM11 [get_ports {pciExtRefClkP}]; # 100 MHz
set_property PACKAGE_PIN AM10 [get_ports {pciExtRefClkN}]; # 100 MHz

##########
# Clocks #
##########

create_clock -period 10.000 -name pciExtRefClkP [get_ports {pciExtRefClkP}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciExtRefClkP}] -group [get_clocks -include_generated_clocks {pciRefClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciExtRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}] -group [get_clocks -include_generated_clocks {emcClk}]
