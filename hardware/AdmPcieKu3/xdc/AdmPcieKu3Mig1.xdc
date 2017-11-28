##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

##########################
# SODIMM[1]: Constraints #
##########################

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrA[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrA[1][*]}]
set_property SLEW FAST                    [get_ports {ddrA[1][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrBa[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrBa[1][*]}]
set_property SLEW FAST                    [get_ports {ddrBa[1][*]}]

set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrCkP[1][*] ddrCkN[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCkP[1][*] ddrCkN[1][*]}]
set_property SLEW FAST                    [get_ports {ddrCkP[1][*] ddrCkN[1][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCke[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCke[1][*]}]
set_property SLEW FAST                    [get_ports {ddrCke[1][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCsL[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCsL[1][*]}]
set_property SLEW FAST                    [get_ports {ddrCsL[1][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDq[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDq[1][*]}]
set_property SLEW          FAST           [get_ports {ddrDq[1][*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDq[1][*]}]
set_property ODT           RTT_40         [get_ports {ddrDq[1][*]}]

# set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDm[1][*]}]
# set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDm[1][*]}]
# set_property SLEW FAST                    [get_ports {ddrDm[1][*]}]

set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]
set_property SLEW          FAST           [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]
set_property ODT           RTT_40         [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrOdt[1][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrOdt[1][*]}]
set_property SLEW FAST                    [get_ports {ddrOdt[1][*]}]

set_property -dict { PACKAGE_PIN AM14  IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrCasL[1]}]; # AM14   DDR3_1_CAS_L   1.5
set_property -dict { PACKAGE_PIN AG16  IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrRasL[1]}]; # AG16   DDR3_1_RAS_L   1.5
set_property -dict { PACKAGE_PIN AL14  IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrWeL[1]}];  # AL14   DDR3_1_WE_L    1.5
set_property -dict { PACKAGE_PIN AN19  IOSTANDARD SSTL15     OUTPUT_IMPEDANCE RDRV_48_48 SLEW SLOW } [get_ports {ddrRstL[1]}]; # AN19   DDR3_1_RESET_L 1.5

set_property IOSTANDARD   DIFF_HSTL_I [get_ports {ddrClkP[1] ddrClkN[1]}]
set_property IBUF_LOW_PWR FALSE       [get_ports {ddrClkP[1] ddrClkN[1]}]
set_property PULLTYPE     KEEPER      [get_ports {ddrClkP[1] ddrClkN[1]}]
