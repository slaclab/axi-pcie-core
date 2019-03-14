##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

###########
# QSFP[0] #
###########

set_property PACKAGE_PIN L29 [get_ports { qsfp0RefClkP }]
set_property PACKAGE_PIN L30 [get_ports { qsfp0RefClkN }]

set_property PACKAGE_PIN B31 [get_ports { qsfp0TxP[3] }]
set_property PACKAGE_PIN B32 [get_ports { qsfp0TxN[3] }]
set_property PACKAGE_PIN C33 [get_ports { qsfp0RxP[3] }]
set_property PACKAGE_PIN C34 [get_ports { qsfp0RxN[3] }]

set_property PACKAGE_PIN D31 [get_ports { qsfp0TxP[2] }]
set_property PACKAGE_PIN D32 [get_ports { qsfp0TxN[2] }]
set_property PACKAGE_PIN E33 [get_ports { qsfp0RxP[2] }]
set_property PACKAGE_PIN E34 [get_ports { qsfp0RxN[2] }]

set_property PACKAGE_PIN G29 [get_ports { qsfp0TxP[1] }]
set_property PACKAGE_PIN G30 [get_ports { qsfp0TxN[1] }]
set_property PACKAGE_PIN F31 [get_ports { qsfp0RxP[1] }]
set_property PACKAGE_PIN F32 [get_ports { qsfp0RxN[1] }]

set_property PACKAGE_PIN H31 [get_ports { qsfp0TxP[0] }]
set_property PACKAGE_PIN H32 [get_ports { qsfp0TxN[0] }]
set_property PACKAGE_PIN G33 [get_ports { qsfp0RxP[0] }]
set_property PACKAGE_PIN G34 [get_ports { qsfp0RxN[0] }]

set_property -dict { PACKAGE_PIN AL12  IOSTANDARD LVCMOS18 } [get_ports { qsfp0RstL }];
set_property -dict { PACKAGE_PIN AF13  IOSTANDARD LVCMOS18 } [get_ports { qsfp0LpMode }];

###########
# QSFP[1] #
###########

set_property PACKAGE_PIN K6 [get_ports { qsfp1RefClkP }]
set_property PACKAGE_PIN K5 [get_ports { qsfp1RefClkN }]

set_property PACKAGE_PIN B6 [get_ports { qsfp1TxP[3] }]
set_property PACKAGE_PIN B5 [get_ports { qsfp1TxN[3] }]
set_property PACKAGE_PIN A4 [get_ports { qsfp1RxP[3] }]
set_property PACKAGE_PIN A3 [get_ports { qsfp1RxN[3] }]

set_property PACKAGE_PIN C4 [get_ports { qsfp1TxP[2] }]
set_property PACKAGE_PIN C3 [get_ports { qsfp1TxN[2] }]
set_property PACKAGE_PIN B2 [get_ports { qsfp1RxP[2] }]
set_property PACKAGE_PIN B1 [get_ports { qsfp1RxN[2] }]

set_property PACKAGE_PIN D6 [get_ports { qsfp1TxP[1] }]
set_property PACKAGE_PIN D5 [get_ports { qsfp1TxN[1] }]
set_property PACKAGE_PIN D2 [get_ports { qsfp1RxP[1] }]
set_property PACKAGE_PIN D1 [get_ports { qsfp1RxN[1] }]

set_property PACKAGE_PIN F6 [get_ports { qsfp1TxP[0] }]
set_property PACKAGE_PIN F5 [get_ports { qsfp1TxN[0] }]
set_property PACKAGE_PIN E4 [get_ports { qsfp1RxP[0] }]
set_property PACKAGE_PIN E3 [get_ports { qsfp1RxN[0] }]

set_property -dict { PACKAGE_PIN AP11  IOSTANDARD LVCMOS18 } [get_ports { qsfp1RstL }];
set_property -dict { PACKAGE_PIN AN13  IOSTANDARD LVCMOS18 } [get_ports { qsfp1LpMode }];

######################
# FLASH: Constraints #
######################

# set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[0]  }]; # T24   FLASH_A0   1.8
# set_property -dict { PACKAGE_PIN T25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[1]  }]; # T25   FLASH_A1   1.8
# set_property -dict { PACKAGE_PIN T27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[2]  }]; # T27   FLASH_A2   1.8
# set_property -dict { PACKAGE_PIN R27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[3]  }]; # R27   FLASH_A3   1.8
# set_property -dict { PACKAGE_PIN P24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[4]  }]; # P24   FLASH_A4   1.8
# set_property -dict { PACKAGE_PIN P25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[5]  }]; # P25   FLASH_A5   1.8
# set_property -dict { PACKAGE_PIN P26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[6]  }]; # P26   FLASH_A6   1.8
# set_property -dict { PACKAGE_PIN N26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[7]  }]; # N26   FLASH_A7   1.8
# set_property -dict { PACKAGE_PIN N24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[8]  }]; # N24   FLASH_A8   1.8
# set_property -dict { PACKAGE_PIN M24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[9]  }]; # M24   FLASH_A9   1.8
# set_property -dict { PACKAGE_PIN M25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[10] }]; # M25   FLASH_A10   1.8
# set_property -dict { PACKAGE_PIN M26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[11] }]; # M26   FLASH_A11   1.8
# set_property -dict { PACKAGE_PIN L22 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[12] }]; # L22   FLASH_A12   1.8
# set_property -dict { PACKAGE_PIN K23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[13] }]; # K23   FLASH_A13   1.8
# set_property -dict { PACKAGE_PIN L25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[14] }]; # L25   FLASH_A14   1.8
# set_property -dict { PACKAGE_PIN K25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[15] }]; # K25   FLASH_A15   1.8
# set_property -dict { PACKAGE_PIN L23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[16] }]; # L23   FLASH_A16   1.8
# set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[17] }]; # L24   FLASH_A17   1.8
# set_property -dict { PACKAGE_PIN M27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[18] }]; # M27   FLASH_A18   1.8
# set_property -dict { PACKAGE_PIN L27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[19] }]; # L27   FLASH_A19   1.8
# set_property -dict { PACKAGE_PIN J23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[20] }]; # J23   FLASH_A20   1.8
# set_property -dict { PACKAGE_PIN H24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[21] }]; # H24   FLASH_A21   1.8
# set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[22] }]; # J26   FLASH_A22   1.8
# set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[23] }]; # H26   FLASH_A23   1.8
# # set_property -dict { PACKAGE_PIN H27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[24] }]; # H27   FLASH_A24   1.8
# # set_property -dict { PACKAGE_PIN G27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[25] }]; # G27   FLASH_A25   1.8

# # set_property -dict { PACKAGE_PIN AC7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[0]  }]; # AC7   FLASH_DQ0   1.8
# # set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[1]  }]; # AB7   FLASH_DQ1   1.8
# # set_property -dict { PACKAGE_PIN AA7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[2]  }]; # AA7   FLASH_DQ2   1.8
# # set_property -dict { PACKAGE_PIN Y7  IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[3]  }]; # Y7    FLASH_DQ3   1.8
# set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[4]  }]; # M20   FLASH_DQ4   1.8
# set_property -dict { PACKAGE_PIN L20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[5]  }]; # L20   FLASH_DQ5   1.8
# set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[6]  }]; # R21   FLASH_DQ6   1.8
# set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[7]  }]; # R22   FLASH_DQ7   1.8
# set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[8]  }]; # P20   FLASH_DQ8   1.8
# set_property -dict { PACKAGE_PIN P21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[9]  }]; # P21   FLASH_DQ9   1.8
# set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[10] }]; # N22   FLASH_DQ10   1.8
# set_property -dict { PACKAGE_PIN M22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[11] }]; # M22   FLASH_DQ11   1.8
# set_property -dict { PACKAGE_PIN R23 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[12] }]; # R23   FLASH_DQ12   1.8
# set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[13] }]; # P23   FLASH_DQ13   1.8
# set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[14] }]; # R25   FLASH_DQ14   1.8
# set_property -dict { PACKAGE_PIN R26 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[15] }]; # R26   FLASH_DQ15   1.8

# # set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS18 } [get_ports { flashCeL }];  # U7   FLASH_CE_L       1.8
# set_property -dict { PACKAGE_PIN G25  IOSTANDARD LVCMOS18 } [get_ports { flashOeL }];  # G25  FLASH_OE_L       1.8
# set_property -dict { PACKAGE_PIN G26  IOSTANDARD LVCMOS18 } [get_ports { flashWeL }];  # G26  FLASH_WE_L       1.8
# set_property -dict { PACKAGE_PIN N27  IOSTANDARD LVCMOS18 } [get_ports { flashAdv }];  # N27  FLASH_ADV_L      1.8
# set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVCMOS18 } [get_ports { flashRstL }]; # AB24 FPGA_FLASH_RST_L 1.8

##########
# Clocks #
##########

create_clock -period 6.400 -name qsfp0RefClkP [get_ports {qsfp0RefClkP}]
create_clock -period 6.400 -name qsfp1RefClkP [get_ports {qsfp1RefClkP}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {qsfp0RefClkP}]
set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {qsfp1RefClkP}]
