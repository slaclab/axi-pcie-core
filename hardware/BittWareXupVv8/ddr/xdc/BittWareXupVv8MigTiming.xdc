##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -period 10.000 -name {ddrClkP[0]} [get_ports {ddrClkP[0]}]
create_clock -period 10.000 -name {ddrClkP[1]} [get_ports {ddrClkP[1]}]
create_clock -period 10.000 -name {ddrClkP[2]} [get_ports {ddrClkP[2]}]
create_clock -period 10.000 -name {ddrClkP[3]} [get_ports {ddrClkP[3]}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks pciRefClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks userClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks dmaClk]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks pciRefClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks userClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks dmaClk]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks pciRefClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks userClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks dmaClk]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks pciRefClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks userClkP]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks dmaClk]
