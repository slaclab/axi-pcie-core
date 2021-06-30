##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##########
# System #
##########

set_property -dict { PACKAGE_PIN AL9  IOSTANDARD LVCMOS33 } [get_ports { ledRedL[0]   }]
set_property -dict { PACKAGE_PIN AN9  IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[0]  }]
set_property -dict { PACKAGE_PIN AP9  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[0] }]

set_property -dict { PACKAGE_PIN AL10 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[1]   }]
set_property -dict { PACKAGE_PIN AM10 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[1]  }]
set_property -dict { PACKAGE_PIN AH9  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[1] }]

set_property -dict { PACKAGE_PIN AH8  IOSTANDARD LVCMOS33 } [get_ports { ledRedL[2]   }]
set_property -dict { PACKAGE_PIN AD9  IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[2]  }]
set_property -dict { PACKAGE_PIN AD8  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[2] }]

set_property -dict { PACKAGE_PIN AD10 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[3]   }]
set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[3]  }]
set_property -dict { PACKAGE_PIN AE8  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[3] }]

set_property -dict { PACKAGE_PIN AF8  IOSTANDARD LVCMOS33 } [get_ports { ledRedL[4]   }]
set_property -dict { PACKAGE_PIN AF9  IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[4]  }]
set_property -dict { PACKAGE_PIN AG9  IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[4] }]

set_property -dict { PACKAGE_PIN AJ10 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[5]   }]
set_property -dict { PACKAGE_PIN AF10 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[5]  }]
set_property -dict { PACKAGE_PIN AG10 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[5] }]

#######
# SFP #
#######

set_property PACKAGE_PIN K6 [get_ports { sfpRefClkP[0] }] ;# 238 MHz
set_property PACKAGE_PIN K5 [get_ports { sfpRefClkN[0] }] ;# 238 MHz

set_property PACKAGE_PIN H6 [get_ports { sfpRefClkP[1] }] ;# 371.428571 MHz
set_property PACKAGE_PIN H5 [get_ports { sfpRefClkN[1] }] ;# 371.428571 MHz

set_property PACKAGE_PIN F6 [get_ports { sfpTxP }]
set_property PACKAGE_PIN F5 [get_ports { sfpTxN }]
set_property PACKAGE_PIN E4 [get_ports { sfpRxP }]
set_property PACKAGE_PIN E3 [get_ports { sfpRxN }]

#############
# QSFP[1:0] #
#############

set_property -dict { PACKAGE_PIN AJ8  IOSTANDARD LVCMOS33 } [get_ports { qsfpScl[0] }]
set_property -dict { PACKAGE_PIN AN8  IOSTANDARD LVCMOS33 } [get_ports { qsfpSda[0] }]

set_property -dict { PACKAGE_PIN AP8  IOSTANDARD LVCMOS33 } [get_ports { qsfpScl[1] }]
set_property -dict { PACKAGE_PIN AK10 IOSTANDARD LVCMOS33 } [get_ports { qsfpSda[1] }]

set_property -dict { PACKAGE_PIN AE11 IOSTANDARD LVCMOS33 } [get_ports { qsfpRstL[0]    }]; # QSFP0_0
set_property -dict { PACKAGE_PIN AE12 IOSTANDARD LVCMOS33 } [get_ports { qsfpModSelL[0] }]; # QSFP0_1
set_property -dict { PACKAGE_PIN AF12 IOSTANDARD LVCMOS33 } [get_ports { qsfpModIntL[0] }]; # QSFP0_2
set_property -dict { PACKAGE_PIN AH13 IOSTANDARD LVCMOS33 } [get_ports { qsfpModPrsL[0] }]; # QSFP0_3
set_property -dict { PACKAGE_PIN AJ13 IOSTANDARD LVCMOS33 } [get_ports { qsfpLpMode[0]  }]; # QSFP0_4

set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS33 } [get_ports { qsfpRstL[1]    }]; # QSFP1_0
set_property -dict { PACKAGE_PIN AF13 IOSTANDARD LVCMOS33 } [get_ports { qsfpModSelL[1] }]; # QSFP1_1
set_property -dict { PACKAGE_PIN AK13 IOSTANDARD LVCMOS33 } [get_ports { qsfpModIntL[1] }]; # QSFP1_2
set_property -dict { PACKAGE_PIN AL13 IOSTANDARD LVCMOS33 } [get_ports { qsfpModPrsL[1] }]; # QSFP1_3
set_property -dict { PACKAGE_PIN AK12 IOSTANDARD LVCMOS33 } [get_ports { qsfpLpMode[1]  }]; # QSFP1_4

set_property PACKAGE_PIN P6 [get_ports { qsfpRefClkP }] ;# 156.25 MHz
set_property PACKAGE_PIN P5 [get_ports { qsfpRefClkN }] ;# 156.25 MHz

set_property PACKAGE_PIN N4 [get_ports { qsfp0TxP[0] }]
set_property PACKAGE_PIN N3 [get_ports { qsfp0TxN[0] }]
set_property PACKAGE_PIN M2 [get_ports { qsfp0RxP[0] }]
set_property PACKAGE_PIN M1 [get_ports { qsfp0RxN[0] }]

set_property PACKAGE_PIN L4 [get_ports { qsfp0TxP[1] }]
set_property PACKAGE_PIN L3 [get_ports { qsfp0TxN[1] }]
set_property PACKAGE_PIN K2 [get_ports { qsfp0RxP[1] }]
set_property PACKAGE_PIN K1 [get_ports { qsfp0RxN[1] }]

set_property PACKAGE_PIN J4 [get_ports { qsfp0TxP[2] }]
set_property PACKAGE_PIN J3 [get_ports { qsfp0TxN[2] }]
set_property PACKAGE_PIN H2 [get_ports { qsfp0RxP[2] }]
set_property PACKAGE_PIN H1 [get_ports { qsfp0RxN[2] }]

set_property PACKAGE_PIN G4 [get_ports { qsfp0TxP[3] }]
set_property PACKAGE_PIN G3 [get_ports { qsfp0TxN[3] }]
set_property PACKAGE_PIN F2 [get_ports { qsfp0RxP[3] }]
set_property PACKAGE_PIN F1 [get_ports { qsfp0RxN[3] }]

set_property PACKAGE_PIN AA4 [get_ports { qsfp1TxP[0] }]
set_property PACKAGE_PIN AA3 [get_ports { qsfp1TxN[0] }]
set_property PACKAGE_PIN Y2  [get_ports { qsfp1RxP[0] }]
set_property PACKAGE_PIN Y1  [get_ports { qsfp1RxN[0] }]

set_property PACKAGE_PIN W4 [get_ports { qsfp1TxP[1] }]
set_property PACKAGE_PIN W3 [get_ports { qsfp1TxN[1] }]
set_property PACKAGE_PIN V2 [get_ports { qsfp1RxP[1] }]
set_property PACKAGE_PIN V1 [get_ports { qsfp1RxN[1] }]

set_property PACKAGE_PIN U4 [get_ports { qsfp1TxP[2] }]
set_property PACKAGE_PIN U3 [get_ports { qsfp1TxN[2] }]
set_property PACKAGE_PIN T2 [get_ports { qsfp1RxP[2] }]
set_property PACKAGE_PIN T1 [get_ports { qsfp1RxN[2] }]

set_property PACKAGE_PIN R4 [get_ports { qsfp1TxP[3] }]
set_property PACKAGE_PIN R3 [get_ports { qsfp1TxN[3] }]
set_property PACKAGE_PIN P2 [get_ports { qsfp1RxP[3] }]
set_property PACKAGE_PIN P1 [get_ports { qsfp1RxN[3] }]

##########
# Clocks #
##########

create_clock -period 4.201 -name sfpRefClkP0 [get_ports {sfpRefClkP[0]}]
create_clock -period 2.691 -name sfpRefClkP1 [get_ports {sfpRefClkP[1]}]
create_clock -period 6.400 -name qsfpRefClkP [get_ports {qsfpRefClkP}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {pciRefClkP}] \
   -group [get_clocks -include_generated_clocks {sfpRefClkP0}] \
   -group [get_clocks -include_generated_clocks {sfpRefClkP1}] \
   -group [get_clocks -include_generated_clocks {qsfpRefClkP}]
