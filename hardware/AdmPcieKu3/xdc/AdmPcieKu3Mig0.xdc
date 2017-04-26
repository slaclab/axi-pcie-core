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
# SODIMM[0]: Constraints #
##########################

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrA[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrA[0][*]}]
set_property SLEW FAST                    [get_ports {ddrA[0][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrBa[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrBa[0][*]}]
set_property SLEW FAST                    [get_ports {ddrBa[0][*]}]

set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrCkP[0][*] ddrCkN[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCkP[0][*] ddrCkN[0][*]}]
set_property SLEW FAST                    [get_ports {ddrCkP[0][*] ddrCkN[0][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCke[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCke[0][*]}]
set_property SLEW FAST                    [get_ports {ddrCke[0][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCsL[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCsL[0][*]}]
set_property SLEW FAST                    [get_ports {ddrCsL[0][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDq[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDq[0][*]}]
set_property SLEW          FAST           [get_ports {ddrDq[0][*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDq[0][*]}]
set_property ODT           RTT_40         [get_ports {ddrDq[0][*]}]

# set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDm[0][*]}]
# set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDm[0][*]}]
# set_property SLEW FAST                    [get_ports {ddrDm[0][*]}]

set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]
set_property SLEW          FAST           [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]
set_property ODT           RTT_40         [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]

set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrOdt[0][*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrOdt[0][*]}]
set_property SLEW FAST                    [get_ports {ddrOdt[0][*]}]

set_property -dict { PACKAGE_PIN C27 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrCasL[0]}]; # C27   DDR3_0_CAS_L    1.5
set_property -dict { PACKAGE_PIN D28 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrRasL[0]}]; # D28   DDR3_0_RAS_L    1.5
set_property -dict { PACKAGE_PIN D29 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrWeL[0]}];  # D29   DDR3_0_WE_L     1.5
set_property -dict { PACKAGE_PIN B25 IOSTANDARD SSTL15     OUTPUT_IMPEDANCE RDRV_48_48 SLEW SLOW } [get_ports {ddrRstL[0]}]; # B25   DDR3_0_RESET_L  1.5

set_property IOSTANDARD   DIFF_HSTL_I [get_ports {ddrClkP[0] ddrClkN[0]}]
set_property IBUF_LOW_PWR FALSE       [get_ports {ddrClkP[0] ddrClkN[0]}]
set_property PULLTYPE     KEEPER      [get_ports {ddrClkP[0] ddrClkN[0]}]
