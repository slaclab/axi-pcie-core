##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_Mig/U_Mig0}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_FIFO[0].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_FIFO[1].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_XBAR[0].U_DdrSync}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_XBAR[0].U_XBAR}]

set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_Mig/GEN_MIG1.U_Mig1}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_FIFO[2].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_FIFO[3].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_XBAR[1].U_DdrSync}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells {U_MigDmaBuffer/GEN_XBAR[1].U_XBAR}]

set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_Mig/GEN_MIG1.U_Mig2}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_FIFO[4].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_FIFO[5].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_XBAR[2].U_DdrSync}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_XBAR[2].U_XBAR}]

set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_Mig/GEN_MIG1.U_Mig3}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_FIFO[6].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_FIFO[7].U_AxiFifo}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_XBAR[3].U_DdrSync}]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_MigDmaBuffer/GEN_XBAR[3].U_XBAR}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks {pciRefClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks {pciRefClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks {pciRefClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks {pciRefClkP}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks {userClkP}]
