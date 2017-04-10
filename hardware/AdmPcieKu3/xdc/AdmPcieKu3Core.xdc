##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

#############################
## Unmapped Application Ports
#############################

# H31    QSFP0_TX0_P       MGT
# H32    QSFP0_TX0_N       MGT
# G33    QSFP0_RX0_P       MGT
# G34    QSFP0_RX0_N       MGT
# G29    QSFP0_TX1_P       MGT
# G30    QSFP0_TX1_N       MGT
# F31    QSFP0_RX1_P       MGT
# F32    QSFP0_RX1_N       MGT
# D31    QSFP0_TX2_P       MGT
# D32    QSFP0_TX2_N       MGT
# E33    QSFP0_RX2_P       MGT
# E34    QSFP0_RX2_N       MGT
# B31    QSFP0_TX3_P       MGT
# B32    QSFP0_TX3_N       MGT
# C33    QSFP0_RX3_P       MGT
# C34    QSFP0_RX3_N       MGT
# AE13   QSFP0_INT_L       3.3
# AF13   QSFP0_LP_MODE     3.3
# AK13   QSFP0_MODPRS_L    3.3
# AL12   QSFP0_RESET_L     3.3
# AK11   QSFP0_SCL         3.3
# AL13   QSFP0_SDA         3.3
# K6     REFCLK156M25_0_P  MGT_REFCLK
# K5     REFCLK156M25_0_N  MGT_REFCLK

# F6     QSFP1_TX0_P       MGT
# F5     QSFP1_TX0_N       MGT
# E4     QSFP1_RX0_P       MGT
# E3     QSFP1_RX0_N       MGT
# D6     QSFP1_TX1_P       MGT
# D5     QSFP1_TX1_N       MGT
# D2     QSFP1_RX1_P       MGT
# D1     QSFP1_RX1_N       MGT
# C4     QSFP1_TX2_P       MGT
# C3     QSFP1_TX2_N       MGT
# B2     QSFP1_RX2_P       MGT
# B1     QSFP1_RX2_N       MGT
# B6     QSFP1_TX3_P       MGT
# B5     QSFP1_TX3_N       MGT
# A4     QSFP1_RX3_P       MGT
# A3     QSFP1_RX3_N       MGT
# AN11   QSFP1_INT_L       3.3
# AN13   QSFP1_LP_MODE     3.3
# AP10   QSFP1_MODPRS_L    3.3
# AP11   QSFP1_RESET_L     3.3
# AP13   QSFP1_SCL         3.3
# AM11   QSFP1_SDA         3.3
# L29    REFCLK156M25_1_P  MGT_REFCLK
# L30    REFCLK156M25_1_N  MGT_REFCLK

# T31   SATA_TX0_PIN_P  MGT
# T32   SATA_TX0_PIN_N  MGT
# R33   SATA_RX0_PIN_P  MGT
# R34   SATA_RX0_PIN_N  MGT
# P31   SATA_TX1_PIN_P  MGT
# P32   SATA_TX1_PIN_N  MGT
# N33   SATA_RX1_PIN_P  MGT
# N34   SATA_RX1_PIN_N  MGT
# R29   REFCLK150M_P    MGT_REFCLK
# R30   REFCLK150M_N    MGT_REFCLK

# AE12   LED_0   3.3
# AF12   LED_1   3.3
# AD11   LED_2   3.3
# AH12   USER_SW 3.3

# M5    REFCLK100M_4_PIN_N   MGT_REFCLK
# M6    REFCLK100M_4_PIN_P   MGT_REFCLK
# Y5    REFCLK100M_5_PIN_N   MGT_REFCLK
# Y6    REFCLK100M_5_PIN_P   MGT_REFCLK
# K20   REFCLK100M     1.8
# W24   REFCLK200M_N   1.8(LVDS requires DIFF_TERM)
# W23   REFCLK200M_P   1.8(LVDS requires DIFF_TERM)
# AA25  REFCLK250M_N   1.8(LVDS requires DIFF_TERM)
# AA24  REFCLK250M_P   1.8(LVDS requires DIFF_TERM)

# AG9   PMBUS_CLK_FPGA   3.3
# AE8   PMBUS_DATA_FPGA  3.3

# AE11   VPD_SCL   3.3
# AG12   VPD_SDA   3.3

# AG11   1PPS_BUF       3.3
# AF9    CABLE_PRSNT_L  3.3

# AK10   DDR3_SCL_3V3    3.3
# AL9    DDR3_SDA_3V3    3.3
# AN8    DDR3_0_EVENT_L  3.3
# AP8    DDR3_1_EVENT_L  3.3

# AN9    FUSION_AUX0   3.3
# AP9    FUSION_AUX1   3.3

# U22    FLASH_WAIT        1.8
# AB24   FPGA_FLASH_RST_L  1.8

# V7     INIT_B_1V8        1.8
# T7     PROGRAM_B_1V8     1.8
# R7     PUDC_B            1.8
# AA9    CCLK              1.8
# N7     DONE_1V8          1.8
# G27    RS1               1.8
# AC9    TCK               1.8
# V9     TDI               1.8
# U9     TDO               1.8
# W9     TMS               1.8

##########################
# SODIMM[0]: Constraints #
##########################

set_property PACKAGE_PIN C24 [get_ports {ddrA[0][0]}];  # C24   DDR3_0_A0       1.5
set_property PACKAGE_PIN B20 [get_ports {ddrA[0][1]}];  # B20   DDR3_0_A1       1.5
set_property PACKAGE_PIN F27 [get_ports {ddrA[0][2]}];  # F27   DDR3_0_A2       1.5
set_property PACKAGE_PIN B21 [get_ports {ddrA[0][3]}];  # B21   DDR3_0_A3       1.5
set_property PACKAGE_PIN E27 [get_ports {ddrA[0][4]}];  # E27   DDR3_0_A4       1.5
set_property PACKAGE_PIN A22 [get_ports {ddrA[0][5]}];  # A22   DDR3_0_A5       1.5
set_property PACKAGE_PIN E26 [get_ports {ddrA[0][6]}];  # E26   DDR3_0_A6       1.5
set_property PACKAGE_PIN E25 [get_ports {ddrA[0][7]}];  # E25   DDR3_0_A7       1.5
set_property PACKAGE_PIN A23 [get_ports {ddrA[0][8]}];  # A23   DDR3_0_A8       1.5
set_property PACKAGE_PIN E22 [get_ports {ddrA[0][9]}];  # E22   DDR3_0_A9       1.5
set_property PACKAGE_PIN A27 [get_ports {ddrA[0][10]}]; # A27   DDR3_0_A10      1.5
set_property PACKAGE_PIN D25 [get_ports {ddrA[0][11]}]; # D25   DDR3_0_A11      1.5
set_property PACKAGE_PIN A25 [get_ports {ddrA[0][12]}]; # A25   DDR3_0_A12      1.5
set_property PACKAGE_PIN A29 [get_ports {ddrA[0][13]}]; # A29   DDR3_0_A13      1.5
set_property PACKAGE_PIN D24 [get_ports {ddrA[0][14]}]; # D24   DDR3_0_A14      1.5
set_property PACKAGE_PIN E23 [get_ports {ddrA[0][15]}]; # E23   DDR3_0_A15      1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrA[0][*]}]

set_property PACKAGE_PIN E28 [get_ports {ddrBa[0][0]}]; # E28   DDR3_0_BA0      1.5
set_property PACKAGE_PIN D26 [get_ports {ddrBa[0][1]}]; # D26   DDR3_0_BA1      1.5
set_property PACKAGE_PIN B22 [get_ports {ddrBa[0][2]}]; # B22   DDR3_0_BA2      1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrBa[0][*]}]

set_property PACKAGE_PIN B24 [get_ports {ddrCkP[0][0]}]; # B24   DDR3_0_CK0_P    1.5
set_property PACKAGE_PIN A24 [get_ports {ddrCkN[0][0]}]; # A24   DDR3_0_CK0_N    1.5

set_property PACKAGE_PIN C21 [get_ports {ddrCkP[0][1]}]; # C21   DDR3_0_CK1_P    1.5
set_property PACKAGE_PIN C22 [get_ports {ddrCkN[0][1]}]; # C22   DDR3_0_CK1_N    1.5

set_property IOSTANDARD LVCMOS15   [get_ports {ddrCkP[0][*] ddrCkN[0][*]}]

set_property PACKAGE_PIN C26 [get_ports {ddrCke[0][0]}]; # C26   DDR3_0_CKE0     1.5
set_property PACKAGE_PIN B26 [get_ports {ddrCke[0][1]}]; # B26   DDR3_0_CKE1     1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrCke[0][*]}]

set_property PACKAGE_PIN B27 [get_ports {ddrCsL[0][0]}]; # B27   DDR3_0_CS0_L    1.5
set_property PACKAGE_PIN A28 [get_ports {ddrCsL[0][1]}]; # A28   DDR3_0_CS1_L    1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrCsL[0][*]}]

set_property PACKAGE_PIN C8  [get_ports {ddrDq[0][0]}];  # C8    DDR3_0_DQ0      1.5
set_property PACKAGE_PIN D8  [get_ports {ddrDq[0][1]}];  # D8    DDR3_0_DQ1      1.5
set_property PACKAGE_PIN A9  [get_ports {ddrDq[0][2]}];  # A9    DDR3_0_DQ2      1.5
set_property PACKAGE_PIN B9  [get_ports {ddrDq[0][3]}];  # B9    DDR3_0_DQ3      1.5
set_property PACKAGE_PIN D10 [get_ports {ddrDq[0][4]}];  # D10   DDR3_0_DQ4      1.5
set_property PACKAGE_PIN D9  [get_ports {ddrDq[0][5]}];  # D9    DDR3_0_DQ5      1.5
set_property PACKAGE_PIN E10 [get_ports {ddrDq[0][6]}];  # E10   DDR3_0_DQ6      1.5
set_property PACKAGE_PIN C9  [get_ports {ddrDq[0][7]}];  # C9    DDR3_0_DQ7      1.5
set_property PACKAGE_PIN J8  [get_ports {ddrDq[0][8]}];  # J8    DDR3_0_DQ8      1.5
set_property PACKAGE_PIN J9  [get_ports {ddrDq[0][9]}];  # J9    DDR3_0_DQ9      1.5
set_property PACKAGE_PIN F9  [get_ports {ddrDq[0][10]}]; # F9    DDR3_0_DQ10     1.5
set_property PACKAGE_PIN G10 [get_ports {ddrDq[0][11]}]; # G10   DDR3_0_DQ11     1.5
set_property PACKAGE_PIN H9  [get_ports {ddrDq[0][12]}]; # H9    DDR3_0_DQ12     1.5
set_property PACKAGE_PIN H8  [get_ports {ddrDq[0][13]}]; # H8    DDR3_0_DQ13     1.5
set_property PACKAGE_PIN F10 [get_ports {ddrDq[0][14]}]; # F10   DDR3_0_DQ14     1.5
set_property PACKAGE_PIN G9  [get_ports {ddrDq[0][15]}]; # G9    DDR3_0_DQ15     1.5
set_property PACKAGE_PIN F15 [get_ports {ddrDq[0][16]}]; # F15   DDR3_0_DQ16     1.5
set_property PACKAGE_PIN E16 [get_ports {ddrDq[0][17]}]; # E16   DDR3_0_DQ17     1.5
set_property PACKAGE_PIN F14 [get_ports {ddrDq[0][18]}]; # F14   DDR3_0_DQ18     1.5
set_property PACKAGE_PIN E15 [get_ports {ddrDq[0][19]}]; # E15   DDR3_0_DQ19     1.5
set_property PACKAGE_PIN D16 [get_ports {ddrDq[0][20]}]; # D16   DDR3_0_DQ20     1.5
set_property PACKAGE_PIN E17 [get_ports {ddrDq[0][21]}]; # E17   DDR3_0_DQ21     1.5
set_property PACKAGE_PIN E18 [get_ports {ddrDq[0][22]}]; # E18   DDR3_0_DQ22     1.5
set_property PACKAGE_PIN D15 [get_ports {ddrDq[0][23]}]; # D15   DDR3_0_DQ23     1.5
set_property PACKAGE_PIN D13 [get_ports {ddrDq[0][24]}]; # D13   DDR3_0_DQ24     1.5
set_property PACKAGE_PIN C11 [get_ports {ddrDq[0][25]}]; # C11   DDR3_0_DQ25     1.5
set_property PACKAGE_PIN C12 [get_ports {ddrDq[0][26]}]; # C12   DDR3_0_DQ26     1.5
set_property PACKAGE_PIN B11 [get_ports {ddrDq[0][27]}]; # B11   DDR3_0_DQ27     1.5
set_property PACKAGE_PIN A13 [get_ports {ddrDq[0][28]}]; # A13   DDR3_0_DQ28     1.5
set_property PACKAGE_PIN C13 [get_ports {ddrDq[0][29]}]; # C13   DDR3_0_DQ29     1.5
set_property PACKAGE_PIN A12 [get_ports {ddrDq[0][30]}]; # A12   DDR3_0_DQ30     1.5
set_property PACKAGE_PIN B12 [get_ports {ddrDq[0][31]}]; # B12   DDR3_0_DQ31     1.5
set_property PACKAGE_PIN F24 [get_ports {ddrDq[0][32]}]; # F24   DDR3_0_DQ32     1.5
set_property PACKAGE_PIN F22 [get_ports {ddrDq[0][33]}]; # F22   DDR3_0_DQ33     1.5
set_property PACKAGE_PIN E21 [get_ports {ddrDq[0][34]}]; # E21   DDR3_0_DQ34     1.5
set_property PACKAGE_PIN E20 [get_ports {ddrDq[0][35]}]; # E20   DDR3_0_DQ35     1.5
set_property PACKAGE_PIN G21 [get_ports {ddrDq[0][36]}]; # G21   DDR3_0_DQ36     1.5
set_property PACKAGE_PIN H21 [get_ports {ddrDq[0][37]}]; # H21   DDR3_0_DQ37     1.5
set_property PACKAGE_PIN F23 [get_ports {ddrDq[0][38]}]; # F23   DDR3_0_DQ38     1.5
set_property PACKAGE_PIN G22 [get_ports {ddrDq[0][39]}]; # G22   DDR3_0_DQ39     1.5
set_property PACKAGE_PIN H12 [get_ports {ddrDq[0][40]}]; # H12   DDR3_0_DQ40     1.5
set_property PACKAGE_PIN G12 [get_ports {ddrDq[0][41]}]; # G12   DDR3_0_DQ41     1.5
set_property PACKAGE_PIN H13 [get_ports {ddrDq[0][42]}]; # H13   DDR3_0_DQ42     1.5
set_property PACKAGE_PIN J11 [get_ports {ddrDq[0][43]}]; # J11   DDR3_0_DQ43     1.5
set_property PACKAGE_PIN J13 [get_ports {ddrDq[0][44]}]; # J13   DDR3_0_DQ44     1.5
set_property PACKAGE_PIN L12 [get_ports {ddrDq[0][45]}]; # L12   DDR3_0_DQ45     1.5
set_property PACKAGE_PIN K12 [get_ports {ddrDq[0][46]}]; # K12   DDR3_0_DQ46     1.5
set_property PACKAGE_PIN K11 [get_ports {ddrDq[0][47]}]; # K11   DDR3_0_DQ47     1.5
set_property PACKAGE_PIN H19 [get_ports {ddrDq[0][48]}]; # H19   DDR3_0_DQ48     1.5
set_property PACKAGE_PIN F18 [get_ports {ddrDq[0][49]}]; # F18   DDR3_0_DQ49     1.5
set_property PACKAGE_PIN H18 [get_ports {ddrDq[0][50]}]; # H18   DDR3_0_DQ50     1.5
set_property PACKAGE_PIN H17 [get_ports {ddrDq[0][51]}]; # H17   DDR3_0_DQ51     1.5
set_property PACKAGE_PIN G14 [get_ports {ddrDq[0][52]}]; # G14   DDR3_0_DQ52     1.5
set_property PACKAGE_PIN G15 [get_ports {ddrDq[0][53]}]; # G15   DDR3_0_DQ53     1.5
set_property PACKAGE_PIN H16 [get_ports {ddrDq[0][54]}]; # H16   DDR3_0_DQ54     1.5
set_property PACKAGE_PIN F17 [get_ports {ddrDq[0][55]}]; # F17   DDR3_0_DQ55     1.5
set_property PACKAGE_PIN L18 [get_ports {ddrDq[0][56]}]; # L18   DDR3_0_DQ56     1.5
set_property PACKAGE_PIN L15 [get_ports {ddrDq[0][57]}]; # L15   DDR3_0_DQ57     1.5
set_property PACKAGE_PIN L19 [get_ports {ddrDq[0][58]}]; # L19   DDR3_0_DQ58     1.5
set_property PACKAGE_PIN K16 [get_ports {ddrDq[0][59]}]; # K16   DDR3_0_DQ59     1.5
set_property PACKAGE_PIN K15 [get_ports {ddrDq[0][60]}]; # K15   DDR3_0_DQ60     1.5
set_property PACKAGE_PIN K17 [get_ports {ddrDq[0][61]}]; # K17   DDR3_0_DQ61     1.5
set_property PACKAGE_PIN K18 [get_ports {ddrDq[0][62]}]; # K18   DDR3_0_DQ62     1.5
set_property PACKAGE_PIN J16 [get_ports {ddrDq[0][63]}]; # J16   DDR3_0_DQ63     1.5
set_property PACKAGE_PIN B16 [get_ports {ddrDq[0][64]}]; # B16   DDR3_0_CB0      1.5
set_property PACKAGE_PIN B17 [get_ports {ddrDq[0][65]}]; # B17   DDR3_0_CB1      1.5
set_property PACKAGE_PIN A18 [get_ports {ddrDq[0][66]}]; # A18   DDR3_0_CB2      1.5
set_property PACKAGE_PIN C18 [get_ports {ddrDq[0][67]}]; # C18   DDR3_0_CB3      1.5
set_property PACKAGE_PIN C17 [get_ports {ddrDq[0][68]}]; # C17   DDR3_0_CB4      1.5
set_property PACKAGE_PIN B15 [get_ports {ddrDq[0][69]}]; # B15   DDR3_0_CB5      1.5
set_property PACKAGE_PIN A15 [get_ports {ddrDq[0][70]}]; # A15   DDR3_0_CB6      1.5
set_property PACKAGE_PIN A19 [get_ports {ddrDq[0][71]}]; # A19   DDR3_0_CB7      1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrDq[0][*]}]

# set_property PACKAGE_PIN F8  [get_ports {ddrDm[0][0]}]; # F8    DDR3_0_DM0      1.5
# set_property PACKAGE_PIN L8  [get_ports {ddrDm[0][1]}]; # L8    DDR3_0_DM1      1.5
# set_property PACKAGE_PIN D14 [get_ports {ddrDm[0][2]}]; # D14   DDR3_0_DM2      1.5
# set_property PACKAGE_PIN E11 [get_ports {ddrDm[0][3]}]; # E11   DDR3_0_DM3      1.5
# set_property PACKAGE_PIN G24 [get_ports {ddrDm[0][4]}]; # G24   DDR3_0_DM4      1.5
# set_property PACKAGE_PIN H11 [get_ports {ddrDm[0][5]}]; # H11   DDR3_0_DM5      1.5
# set_property PACKAGE_PIN G17 [get_ports {ddrDm[0][6]}]; # G17   DDR3_0_DM6      1.5
# set_property PACKAGE_PIN J15 [get_ports {ddrDm[0][7]}]; # J15   DDR3_0_DM7      1.5
# set_property PACKAGE_PIN B14 [get_ports {ddrDm[0][8]}]; # B14   DDR3_0_DM8      1.5
# set_property IOSTANDARD LVCMOS15        [get_ports {ddrDm[0][*]}]

set_property PACKAGE_PIN B10 [get_ports {ddrDqsP[0][0]}]; # B10   DDR3_0_DQS0_P   1.5
set_property PACKAGE_PIN A10 [get_ports {ddrDqsN[0][0]}]; # A10   DDR3_0_DQS0_N   1.5

set_property PACKAGE_PIN K10 [get_ports {ddrDqsP[0][1]}]; # K10   DDR3_0_DQS1_P   1.5
set_property PACKAGE_PIN J10 [get_ports {ddrDqsN[0][1]}]; # J10   DDR3_0_DQS1_N   1.5

set_property PACKAGE_PIN D19 [get_ports {ddrDqsP[0][2]}]; # D19   DDR3_0_DQS2_P   1.5
set_property PACKAGE_PIN D18 [get_ports {ddrDqsN[0][2]}]; # D18   DDR3_0_DQS2_N   1.5

set_property PACKAGE_PIN F13 [get_ports {ddrDqsP[0][3]}]; # F13   DDR3_0_DQS3_P   1.5
set_property PACKAGE_PIN E13 [get_ports {ddrDqsN[0][3]}]; # E13   DDR3_0_DQS3_N   1.5

set_property PACKAGE_PIN G20 [get_ports {ddrDqsP[0][4]}]; # G20   DDR3_0_DQS4_P   1.5
set_property PACKAGE_PIN F20 [get_ports {ddrDqsN[0][4]}]; # F20   DDR3_0_DQS4_N   1.5

set_property PACKAGE_PIN L13 [get_ports {ddrDqsP[0][5]}]; # L13   DDR3_0_DQS5_P   1.5
set_property PACKAGE_PIN K13 [get_ports {ddrDqsN[0][5]}]; # K13   DDR3_0_DQS5_N   1.5

set_property PACKAGE_PIN G19 [get_ports {ddrDqsP[0][6]}]; # G19   DDR3_0_DQS6_P   1.5
set_property PACKAGE_PIN F19 [get_ports {ddrDqsN[0][6]}]; # F19   DDR3_0_DQS6_N   1.5

set_property PACKAGE_PIN J19 [get_ports {ddrDqsP[0][7]}]; # J19   DDR3_0_DQS7_P   1.5
set_property PACKAGE_PIN J18 [get_ports {ddrDqsN[0][7]}]; # J18   DDR3_0_DQS7_N   1.5

set_property PACKAGE_PIN C19 [get_ports {ddrDqsP[0][8]}]; # C19   DDR3_0_DQS8_P   1.5
set_property PACKAGE_PIN B19 [get_ports {ddrDqsN[0][8]}]; # B19   DDR3_0_DQS8_N   1.5

set_property IOSTANDARD LVCMOS15   [get_ports {ddrDqsP[0][*] ddrDqsN[0][*]}]

set_property PACKAGE_PIN C28 [get_ports {ddrOdt[0][0]}]; # C28   DDR3_0_ODT0     1.5
set_property PACKAGE_PIN B29 [get_ports {ddrOdt[0][1]}]; # B29   DDR3_0_ODT1     1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrOdt[0][*]}]

set_property -dict { PACKAGE_PIN C27 IOSTANDARD LVCMOS15 } [get_ports {ddrCasL[0]}]; # C27   DDR3_0_CAS_L    1.5
set_property -dict { PACKAGE_PIN D28 IOSTANDARD LVCMOS15 } [get_ports {ddrRasL[0]}]; # D28   DDR3_0_RAS_L    1.5
set_property -dict { PACKAGE_PIN D29 IOSTANDARD LVCMOS15 } [get_ports {ddrWeL[0]}];  # D29   DDR3_0_WE_L     1.5
set_property -dict { PACKAGE_PIN B25 IOSTANDARD LVCMOS15 } [get_ports {ddrRstL[0]}]; # B25   DDR3_0_RESET_L  1.5

set_property PACKAGE_PIN D23          [get_ports {ddrClkP[0]}]; # D23   REFCLK400M_HSTL_0_P   1.5 (HSTL externally terminated)
set_property PACKAGE_PIN C23          [get_ports {ddrClkN[0]}]; # C23   REFCLK400M_HSTL_0_N   1.5 (HSTL externally terminated)
set_property IOSTANDARD   LVCMOS15 [get_ports {ddrClkP[0] ddrClkN[0]}]

##########################
# SODIMM[1]: Constraints #
##########################

set_property PACKAGE_PIN AL15 [get_ports {ddrA[1][0]}];  # AL15   DDR3_1_A0      1.5
set_property PACKAGE_PIN AP15 [get_ports {ddrA[1][1]}];  # AP15   DDR3_1_A1      1.5
set_property PACKAGE_PIN AG17 [get_ports {ddrA[1][2]}];  # AG17   DDR3_1_A2      1.5
set_property PACKAGE_PIN AM16 [get_ports {ddrA[1][3]}];  # AM16   DDR3_1_A3      1.5
set_property PACKAGE_PIN AK18 [get_ports {ddrA[1][4]}];  # AK18   DDR3_1_A4      1.5
set_property PACKAGE_PIN AM15 [get_ports {ddrA[1][5]}];  # AM15   DDR3_1_A5      1.5
set_property PACKAGE_PIN AG19 [get_ports {ddrA[1][6]}];  # AG19   DDR3_1_A6      1.5
set_property PACKAGE_PIN AJ19 [get_ports {ddrA[1][7]}];  # AJ19   DDR3_1_A7      1.5
set_property PACKAGE_PIN AN16 [get_ports {ddrA[1][8]}];  # AN16   DDR3_1_A8      1.5
set_property PACKAGE_PIN AK17 [get_ports {ddrA[1][9]}];  # AK17   DDR3_1_A9      1.5
set_property PACKAGE_PIN AN14 [get_ports {ddrA[1][10]}]; # AN14   DDR3_1_A10     1.5
set_property PACKAGE_PIN AJ18 [get_ports {ddrA[1][11]}]; # AJ18   DDR3_1_A11     1.5
set_property PACKAGE_PIN AM17 [get_ports {ddrA[1][12]}]; # AM17   DDR3_1_A12     1.5
set_property PACKAGE_PIN AH14 [get_ports {ddrA[1][13]}]; # AH14   DDR3_1_A13     1.5
set_property PACKAGE_PIN AL19 [get_ports {ddrA[1][14]}]; # AL19   DDR3_1_A14     1.5
set_property PACKAGE_PIN AM19 [get_ports {ddrA[1][15]}]; # AM19   DDR3_1_A15     1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrA[1][*]}]

set_property PACKAGE_PIN AK16 [get_ports {ddrBa[1][0]}]; # AK16   DDR3_1_BA0     1.5
set_property PACKAGE_PIN AH16 [get_ports {ddrBa[1][1]}]; # AH16   DDR3_1_BA1     1.5
set_property PACKAGE_PIN AP16 [get_ports {ddrBa[1][2]}]; # AP16   DDR3_1_BA2     1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrBa[1][*]}]

set_property PACKAGE_PIN AL18 [get_ports {ddrCkP[1][0]}]; # AL18   DDR3_1_CK0_P   1.5
set_property PACKAGE_PIN AL17 [get_ports {ddrCkN[1][0]}]; # AL17   DDR3_1_CK0_N   1.5

set_property PACKAGE_PIN AJ15 [get_ports {ddrCkP[1][1]}]; # AJ15   DDR3_1_CK1_P   1.5
set_property PACKAGE_PIN AJ14 [get_ports {ddrCkN[1][1]}]; # AJ14   DDR3_1_CK1_N   1.5

set_property IOSTANDARD LVCMOS15   [get_ports {ddrCkP[1][*] ddrCkN[1][*]}]

set_property PACKAGE_PIN AN17 [get_ports {ddrCke[1][0]}]; # AN17   DDR3_1_CKE0    1.5
set_property PACKAGE_PIN AP14 [get_ports {ddrCke[1][1]}]; # AP14   DDR3_1_CKE1    1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrCke[1][*]}]

set_property PACKAGE_PIN AK15 [get_ports {ddrCsL[1][0]}]; # AK15   DDR3_1_CS0_L   1.5
set_property PACKAGE_PIN AJ16 [get_ports {ddrCsL[1][1]}]; # AJ16   DDR3_1_CS1_L   1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrCsL[1][*]}]

set_property PACKAGE_PIN AF20 [get_ports {ddrDq[1][0]}];  # AF20   DDR3_1_DQ0     1.5
set_property PACKAGE_PIN AD20 [get_ports {ddrDq[1][1]}];  # AD20   DDR3_1_DQ1     1.5
set_property PACKAGE_PIN AG20 [get_ports {ddrDq[1][2]}];  # AG20   DDR3_1_DQ2     1.5
set_property PACKAGE_PIN AG22 [get_ports {ddrDq[1][3]}];  # AG22   DDR3_1_DQ3     1.5
set_property PACKAGE_PIN AE23 [get_ports {ddrDq[1][4]}];  # AE23   DDR3_1_DQ4     1.5
set_property PACKAGE_PIN AE22 [get_ports {ddrDq[1][5]}];  # AE22   DDR3_1_DQ5     1.5
set_property PACKAGE_PIN AE20 [get_ports {ddrDq[1][6]}];  # AE20   DDR3_1_DQ6     1.5
set_property PACKAGE_PIN AF22 [get_ports {ddrDq[1][7]}];  # AF22   DDR3_1_DQ7     1.5
set_property PACKAGE_PIN AF23 [get_ports {ddrDq[1][8]}];  # AF23   DDR3_1_DQ8     1.5
set_property PACKAGE_PIN AF24 [get_ports {ddrDq[1][9]}];  # AF24   DDR3_1_DQ9     1.5
set_property PACKAGE_PIN AG25 [get_ports {ddrDq[1][10]}]; # AG25   DDR3_1_DQ10    1.5
set_property PACKAGE_PIN AG24 [get_ports {ddrDq[1][11]}]; # AG24   DDR3_1_DQ11    1.5
set_property PACKAGE_PIN AH23 [get_ports {ddrDq[1][12]}]; # AH23   DDR3_1_DQ12    1.5
set_property PACKAGE_PIN AJ23 [get_ports {ddrDq[1][13]}]; # AJ23   DDR3_1_DQ13    1.5
set_property PACKAGE_PIN AH22 [get_ports {ddrDq[1][14]}]; # AH22   DDR3_1_DQ14    1.5
set_property PACKAGE_PIN AJ24 [get_ports {ddrDq[1][15]}]; # AJ24   DDR3_1_DQ15    1.5
set_property PACKAGE_PIN AL25 [get_ports {ddrDq[1][16]}]; # AL25   DDR3_1_DQ16    1.5
set_property PACKAGE_PIN AK22 [get_ports {ddrDq[1][17]}]; # AK22   DDR3_1_DQ17    1.5
set_property PACKAGE_PIN AL20 [get_ports {ddrDq[1][18]}]; # AL20   DDR3_1_DQ18    1.5
set_property PACKAGE_PIN AM20 [get_ports {ddrDq[1][19]}]; # AM20   DDR3_1_DQ19    1.5
set_property PACKAGE_PIN AL22 [get_ports {ddrDq[1][20]}]; # AL22   DDR3_1_DQ20    1.5
set_property PACKAGE_PIN AK23 [get_ports {ddrDq[1][21]}]; # AK23   DDR3_1_DQ21    1.5
set_property PACKAGE_PIN AL23 [get_ports {ddrDq[1][22]}]; # AL23   DDR3_1_DQ22    1.5
set_property PACKAGE_PIN AL24 [get_ports {ddrDq[1][23]}]; # AL24   DDR3_1_DQ23    1.5
set_property PACKAGE_PIN AN28 [get_ports {ddrDq[1][24]}]; # AN28   DDR3_1_DQ24    1.5
set_property PACKAGE_PIN AP29 [get_ports {ddrDq[1][25]}]; # AP29   DDR3_1_DQ25    1.5
set_property PACKAGE_PIN AL30 [get_ports {ddrDq[1][26]}]; # AL30   DDR3_1_DQ26    1.5
set_property PACKAGE_PIN AL29 [get_ports {ddrDq[1][27]}]; # AL29   DDR3_1_DQ27    1.5
set_property PACKAGE_PIN AN27 [get_ports {ddrDq[1][28]}]; # AN27   DDR3_1_DQ28    1.5
set_property PACKAGE_PIN AP28 [get_ports {ddrDq[1][29]}]; # AP28   DDR3_1_DQ29    1.5
set_property PACKAGE_PIN AM30 [get_ports {ddrDq[1][30]}]; # AM30   DDR3_1_DQ30    1.5
set_property PACKAGE_PIN AM29 [get_ports {ddrDq[1][31]}]; # AM29   DDR3_1_DQ31    1.5
set_property PACKAGE_PIN AM26 [get_ports {ddrDq[1][32]}]; # AM26   DDR3_1_DQ32    1.5
set_property PACKAGE_PIN AM27 [get_ports {ddrDq[1][33]}]; # AM27   DDR3_1_DQ33    1.5
set_property PACKAGE_PIN AK26 [get_ports {ddrDq[1][34]}]; # AK26   DDR3_1_DQ34    1.5
set_property PACKAGE_PIN AJ28 [get_ports {ddrDq[1][35]}]; # AJ28   DDR3_1_DQ35    1.5
set_property PACKAGE_PIN AK27 [get_ports {ddrDq[1][36]}]; # AK27   DDR3_1_DQ36    1.5
set_property PACKAGE_PIN AK28 [get_ports {ddrDq[1][37]}]; # AK28   DDR3_1_DQ37    1.5
set_property PACKAGE_PIN AH28 [get_ports {ddrDq[1][38]}]; # AH28   DDR3_1_DQ38    1.5
set_property PACKAGE_PIN AH27 [get_ports {ddrDq[1][39]}]; # AH27   DDR3_1_DQ39    1.5
set_property PACKAGE_PIN AN23 [get_ports {ddrDq[1][40]}]; # AN23   DDR3_1_DQ40    1.5
set_property PACKAGE_PIN AP24 [get_ports {ddrDq[1][41]}]; # AP24   DDR3_1_DQ41    1.5
set_property PACKAGE_PIN AN24 [get_ports {ddrDq[1][42]}]; # AN24   DDR3_1_DQ42    1.5
set_property PACKAGE_PIN AM24 [get_ports {ddrDq[1][43]}]; # AM24   DDR3_1_DQ43    1.5
set_property PACKAGE_PIN AN22 [get_ports {ddrDq[1][44]}]; # AN22   DDR3_1_DQ44    1.5
set_property PACKAGE_PIN AM22 [get_ports {ddrDq[1][45]}]; # AM22   DDR3_1_DQ45    1.5
set_property PACKAGE_PIN AP23 [get_ports {ddrDq[1][46]}]; # AP23   DDR3_1_DQ46    1.5
set_property PACKAGE_PIN AP25 [get_ports {ddrDq[1][47]}]; # AP25   DDR3_1_DQ47    1.5
set_property PACKAGE_PIN AK32 [get_ports {ddrDq[1][48]}]; # AK32   DDR3_1_DQ48    1.5
set_property PACKAGE_PIN AK31 [get_ports {ddrDq[1][49]}]; # AK31   DDR3_1_DQ49    1.5
set_property PACKAGE_PIN AJ30 [get_ports {ddrDq[1][50]}]; # AJ30   DDR3_1_DQ50    1.5
set_property PACKAGE_PIN AJ34 [get_ports {ddrDq[1][51]}]; # AJ34   DDR3_1_DQ51    1.5
set_property PACKAGE_PIN AH32 [get_ports {ddrDq[1][52]}]; # AH32   DDR3_1_DQ52    1.5
set_property PACKAGE_PIN AJ31 [get_ports {ddrDq[1][53]}]; # AJ31   DDR3_1_DQ53    1.5
set_property PACKAGE_PIN AH31 [get_ports {ddrDq[1][54]}]; # AH31   DDR3_1_DQ54    1.5
set_property PACKAGE_PIN AH34 [get_ports {ddrDq[1][55]}]; # AH34   DDR3_1_DQ55    1.5
set_property PACKAGE_PIN AM32 [get_ports {ddrDq[1][56]}]; # AM32   DDR3_1_DQ56    1.5
set_property PACKAGE_PIN AN32 [get_ports {ddrDq[1][57]}]; # AN32   DDR3_1_DQ57    1.5
set_property PACKAGE_PIN AP33 [get_ports {ddrDq[1][58]}]; # AP33   DDR3_1_DQ58    1.5
set_property PACKAGE_PIN AL34 [get_ports {ddrDq[1][59]}]; # AL34   DDR3_1_DQ59    1.5
set_property PACKAGE_PIN AP31 [get_ports {ddrDq[1][60]}]; # AP31   DDR3_1_DQ60    1.5
set_property PACKAGE_PIN AN31 [get_ports {ddrDq[1][61]}]; # AN31   DDR3_1_DQ61    1.5
set_property PACKAGE_PIN AM34 [get_ports {ddrDq[1][62]}]; # AM34   DDR3_1_DQ62    1.5
set_property PACKAGE_PIN AN33 [get_ports {ddrDq[1][63]}]; # AN33   DDR3_1_DQ63    1.5
set_property PACKAGE_PIN AF14 [get_ports {ddrDq[1][64]}]; # AF14   DDR3_1_CB0     1.5
set_property PACKAGE_PIN AF15 [get_ports {ddrDq[1][65]}]; # AF15   DDR3_1_CB1     1.5
set_property PACKAGE_PIN AD16 [get_ports {ddrDq[1][66]}]; # AD16   DDR3_1_CB2     1.5
set_property PACKAGE_PIN AD15 [get_ports {ddrDq[1][67]}]; # AD15   DDR3_1_CB3     1.5
set_property PACKAGE_PIN AE17 [get_ports {ddrDq[1][68]}]; # AE17   DDR3_1_CB4     1.5
set_property PACKAGE_PIN AF17 [get_ports {ddrDq[1][69]}]; # AF17   DDR3_1_CB5     1.5
set_property PACKAGE_PIN AE18 [get_ports {ddrDq[1][70]}]; # AE18   DDR3_1_CB6     1.5
set_property PACKAGE_PIN AF18 [get_ports {ddrDq[1][71]}]; # AF18   DDR3_1_CB7     1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrDq[1][*]}]

# set_property PACKAGE_PIN AD21 [get_ports {ddrDm[1][0]}]; # AD21   DDR3_1_DM0     1.5
# set_property PACKAGE_PIN AE25 [get_ports {ddrDm[1][1]}]; # AE25   DDR3_1_DM1     1.5
# set_property PACKAGE_PIN AJ21 [get_ports {ddrDm[1][2]}]; # AJ21   DDR3_1_DM2     1.5
# set_property PACKAGE_PIN AN26 [get_ports {ddrDm[1][3]}]; # AN26   DDR3_1_DM3     1.5
# set_property PACKAGE_PIN AH26 [get_ports {ddrDm[1][4]}]; # AH26   DDR3_1_DM4     1.5
# set_property PACKAGE_PIN AM21 [get_ports {ddrDm[1][5]}]; # AM21   DDR3_1_DM5     1.5
# set_property PACKAGE_PIN AJ29 [get_ports {ddrDm[1][6]}]; # AJ29   DDR3_1_DM6     1.5
# set_property PACKAGE_PIN AL32 [get_ports {ddrDm[1][7]}]; # AL32   DDR3_1_DM7     1.5
# set_property PACKAGE_PIN AD19 [get_ports {ddrDm[1][8]}]; # AD19   DDR3_1_DM8     1.5
# set_property IOSTANDARD LVCMOS15        [get_ports {ddrDm[1][*]}]

set_property PACKAGE_PIN AG21 [get_ports {ddrDqsP[1][0]}]; # AG21   DDR3_1_DQS0_P  1.5
set_property PACKAGE_PIN AH21 [get_ports {ddrDqsN[1][0]}]; # AH21   DDR3_1_DQS0_N  1.5

set_property PACKAGE_PIN AH24 [get_ports {ddrDqsP[1][1]}]; # AH24   DDR3_1_DQS1_P  1.5
set_property PACKAGE_PIN AJ25 [get_ports {ddrDqsN[1][1]}]; # AJ25   DDR3_1_DQS1_N  1.5

set_property PACKAGE_PIN AJ20 [get_ports {ddrDqsP[1][2]}]; # AJ20   DDR3_1_DQS2_P  1.5
set_property PACKAGE_PIN AK20 [get_ports {ddrDqsN[1][2]}]; # AK20   DDR3_1_DQS2_N  1.5

set_property PACKAGE_PIN AN29 [get_ports {ddrDqsP[1][3]}]; # AN29   DDR3_1_DQS3_P  1.5
set_property PACKAGE_PIN AP30 [get_ports {ddrDqsN[1][3]}]; # AP30   DDR3_1_DQS3_N  1.5

set_property PACKAGE_PIN AL27 [get_ports {ddrDqsP[1][4]}]; # AL27   DDR3_1_DQS4_P  1.5
set_property PACKAGE_PIN AL28 [get_ports {ddrDqsN[1][4]}]; # AL28   DDR3_1_DQS4_N  1.5

set_property PACKAGE_PIN AP20 [get_ports {ddrDqsP[1][5]}]; # AP20   DDR3_1_DQS5_P  1.5
set_property PACKAGE_PIN AP21 [get_ports {ddrDqsN[1][5]}]; # AP21   DDR3_1_DQS5_N  1.5

set_property PACKAGE_PIN AH33 [get_ports {ddrDqsP[1][6]}]; # AH33   DDR3_1_DQS6_P  1.5
set_property PACKAGE_PIN AJ33 [get_ports {ddrDqsN[1][6]}]; # AJ33   DDR3_1_DQS6_N  1.5

set_property PACKAGE_PIN AN34 [get_ports {ddrDqsP[1][7]}]; # AN34   DDR3_1_DQS7_P  1.5
set_property PACKAGE_PIN AP34 [get_ports {ddrDqsN[1][7]}]; # AP34   DDR3_1_DQS7_N  1.5

set_property PACKAGE_PIN AE16 [get_ports {ddrDqsP[1][8]}]; # AE16   DDR3_1_DQS8_P  1.5
set_property PACKAGE_PIN AE15 [get_ports {ddrDqsN[1][8]}]; # AE15   DDR3_1_DQS8_N  1.5

set_property IOSTANDARD LVCMOS15   [get_ports {ddrDqsP[1][*] ddrDqsN[1][*]}]

set_property PACKAGE_PIN AN18 [get_ports {ddrOdt[1][0]}]; # AN18   DDR3_1_ODT0    1.5
set_property PACKAGE_PIN AP18 [get_ports {ddrOdt[1][1]}]; # AP18   DDR3_1_ODT1    1.5
set_property IOSTANDARD LVCMOS15        [get_ports {ddrOdt[1][*]}]

set_property -dict { PACKAGE_PIN AM14 IOSTANDARD LVCMOS15 } [get_ports {ddrCasL[1]}]; # AM14   DDR3_1_CAS_L   1.5
set_property -dict { PACKAGE_PIN AG16 IOSTANDARD LVCMOS15 } [get_ports {ddrRasL[1]}]; # AG16   DDR3_1_RAS_L   1.5
set_property -dict { PACKAGE_PIN AL14 IOSTANDARD LVCMOS15 } [get_ports {ddrWeL[1]}];  # AL14   DDR3_1_WE_L    1.5
set_property -dict { PACKAGE_PIN AN19 IOSTANDARD LVCMOS15 } [get_ports {ddrRstL[1]}]; # AN19   DDR3_1_RESET_L 1.5

set_property PACKAGE_PIN AH18         [get_ports {ddrClkP[1]}]; # AH18   REFCLK400M_HSTL_1_P   1.5 (HSTL externally terminated)
set_property PACKAGE_PIN AH17         [get_ports {ddrClkN[1]}]; # AH17   REFCLK400M_HSTL_1_N   1.5 (HSTL externally terminated)
set_property IOSTANDARD   LVCMOS15 [get_ports {ddrClkP[1] ddrClkN[1]}]

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[0]  }]; # T24   FLASH_A0   1.8
set_property -dict { PACKAGE_PIN T25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[1]  }]; # T25   FLASH_A1   1.8
set_property -dict { PACKAGE_PIN T27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[2]  }]; # T27   FLASH_A2   1.8
set_property -dict { PACKAGE_PIN R27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[3]  }]; # R27   FLASH_A3   1.8
set_property -dict { PACKAGE_PIN P24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[4]  }]; # P24   FLASH_A4   1.8
set_property -dict { PACKAGE_PIN P25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[5]  }]; # P25   FLASH_A5   1.8
set_property -dict { PACKAGE_PIN P26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[6]  }]; # P26   FLASH_A6   1.8
set_property -dict { PACKAGE_PIN N26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[7]  }]; # N26   FLASH_A7   1.8
set_property -dict { PACKAGE_PIN N24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[8]  }]; # N24   FLASH_A8   1.8
set_property -dict { PACKAGE_PIN M24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[9]  }]; # M24   FLASH_A9   1.8
set_property -dict { PACKAGE_PIN M25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[10] }]; # M25   FLASH_A10   1.8
set_property -dict { PACKAGE_PIN M26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[11] }]; # M26   FLASH_A11   1.8
set_property -dict { PACKAGE_PIN L22 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[12] }]; # L22   FLASH_A12   1.8
set_property -dict { PACKAGE_PIN K23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[13] }]; # K23   FLASH_A13   1.8
set_property -dict { PACKAGE_PIN L25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[14] }]; # L25   FLASH_A14   1.8
set_property -dict { PACKAGE_PIN K25 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[15] }]; # K25   FLASH_A15   1.8
set_property -dict { PACKAGE_PIN L23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[16] }]; # L23   FLASH_A16   1.8
set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[17] }]; # L24   FLASH_A17   1.8
set_property -dict { PACKAGE_PIN M27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[18] }]; # M27   FLASH_A18   1.8
set_property -dict { PACKAGE_PIN L27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[19] }]; # L27   FLASH_A19   1.8
set_property -dict { PACKAGE_PIN J23 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[20] }]; # J23   FLASH_A20   1.8
set_property -dict { PACKAGE_PIN H24 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[21] }]; # H24   FLASH_A21   1.8
set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[22] }]; # J26   FLASH_A22   1.8
set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[23] }]; # H26   FLASH_A23   1.8
set_property -dict { PACKAGE_PIN H27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[24] }]; # H27   FLASH_A24   1.8
set_property -dict { PACKAGE_PIN G27 IOSTANDARD LVCMOS18 } [get_ports { flashAddr[25] }]; # G27   FLASH_A25   1.8

# set_property -dict { PACKAGE_PIN AC7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[0]  }]; # AC7   FLASH_DQ0   1.8
# set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[1]  }]; # AB7   FLASH_DQ1   1.8
# set_property -dict { PACKAGE_PIN AA7 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[2]  }]; # AA7   FLASH_DQ2   1.8
# set_property -dict { PACKAGE_PIN Y7  IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[3]  }]; # Y7    FLASH_DQ3   1.8
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[4]  }]; # M20   FLASH_DQ4   1.8
set_property -dict { PACKAGE_PIN L20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[5]  }]; # L20   FLASH_DQ5   1.8
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[6]  }]; # R21   FLASH_DQ6   1.8
set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[7]  }]; # R22   FLASH_DQ7   1.8
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[8]  }]; # P20   FLASH_DQ8   1.8
set_property -dict { PACKAGE_PIN P21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[9]  }]; # P21   FLASH_DQ9   1.8
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[10] }]; # N22   FLASH_DQ10   1.8
set_property -dict { PACKAGE_PIN M22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[11] }]; # M22   FLASH_DQ11   1.8
set_property -dict { PACKAGE_PIN R23 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[12] }]; # R23   FLASH_DQ12   1.8
set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[13] }]; # P23   FLASH_DQ13   1.8
set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[14] }]; # R25   FLASH_DQ14   1.8
set_property -dict { PACKAGE_PIN R26 IOSTANDARD LVCMOS18 PULLUP true} [get_ports { flashData[15] }]; # R26   FLASH_DQ15   1.8

# set_property -dict { PACKAGE_PIN U7  IOSTANDARD LVCMOS18 } [get_ports { flashCeL }]; # U7    FLASH_CE_L   1.8
set_property -dict { PACKAGE_PIN G25 IOSTANDARD LVCMOS18 } [get_ports { flashOeL }]; # G25   FLASH_OE_L   1.8
set_property -dict { PACKAGE_PIN G26 IOSTANDARD LVCMOS18 } [get_ports { flashWeL }]; # G26   FLASH_WE_L   1.8
set_property -dict { PACKAGE_PIN N27 IOSTANDARD LVCMOS18 } [get_ports { flashAdv }]; # N27   FLASH_ADV_L  1.8

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN AC4 [get_ports pciTxP[0]]; # AC4   PCIE_TX0_PIN_P    MGT
set_property PACKAGE_PIN AC3 [get_ports pciTxN[0]]; # AC3   PCIE_TX0_PIN_N    MGT
set_property PACKAGE_PIN AB2 [get_ports pciRxP[0]]; # AB2   PCIE_RX0_P        MGT
set_property PACKAGE_PIN AB1 [get_ports pciRxN[0]]; # AB1   PCIE_RX0_N        MGT

set_property PACKAGE_PIN AE4 [get_ports pciTxP[1]]; # AE4   PCIE_TX1_PIN_P    MGT
set_property PACKAGE_PIN AE3 [get_ports pciTxN[1]]; # AE3   PCIE_TX1_PIN_N    MGT
set_property PACKAGE_PIN AD2 [get_ports pciRxP[1]]; # AD2   PCIE_RX1_P        MGT
set_property PACKAGE_PIN AD1 [get_ports pciRxN[1]]; # AD1   PCIE_RX1_N        MGT

set_property PACKAGE_PIN AG4 [get_ports pciTxP[2]]; # AG4   PCIE_TX2_PIN_P    MGT
set_property PACKAGE_PIN AG3 [get_ports pciTxN[2]]; # AG3   PCIE_TX2_PIN_N    MGT
set_property PACKAGE_PIN AF2 [get_ports pciRxP[2]]; # AF2   PCIE_RX2_P        MGT
set_property PACKAGE_PIN AF1 [get_ports pciRxN[2]]; # AF1   PCIE_RX2_N        MGT

set_property PACKAGE_PIN AH6 [get_ports pciTxP[3]]; # AH6   PCIE_TX3_PIN_P    MGT
set_property PACKAGE_PIN AH5 [get_ports pciTxN[3]]; # AH5   PCIE_TX3_PIN_N    MGT
set_property PACKAGE_PIN AH2 [get_ports pciRxP[3]]; # AH2   PCIE_RX3_P        MGT
set_property PACKAGE_PIN AH1 [get_ports pciRxN[3]]; # AH1   PCIE_RX3_N        MGT

set_property PACKAGE_PIN AK6 [get_ports pciTxP[4]]; # AK6   PCIE_TX4_PIN_P    MGT
set_property PACKAGE_PIN AK5 [get_ports pciTxN[4]]; # AK5   PCIE_TX4_PIN_N    MGT
set_property PACKAGE_PIN AJ4 [get_ports pciRxP[4]]; # AJ4   PCIE_RX4_P        MGT
set_property PACKAGE_PIN AJ3 [get_ports pciRxN[4]]; # AJ3   PCIE_RX4_N        MGT

set_property PACKAGE_PIN AL4 [get_ports pciTxP[5]]; # AL4   PCIE_TX5_PIN_P    MGT
set_property PACKAGE_PIN AL3 [get_ports pciTxN[5]]; # AL3   PCIE_TX5_PIN_N    MGT
set_property PACKAGE_PIN AK2 [get_ports pciRxP[5]]; # AK2   PCIE_RX5_P        MGT
set_property PACKAGE_PIN AK1 [get_ports pciRxN[5]]; # AK1   PCIE_RX5_N        MGT

set_property PACKAGE_PIN AM6 [get_ports pciTxP[6]]; # AM6   PCIE_TX6_PIN_P    MGT
set_property PACKAGE_PIN AM5 [get_ports pciTxN[6]]; # AM5   PCIE_TX6_PIN_N    MGT
set_property PACKAGE_PIN AM2 [get_ports pciRxP[6]]; # AM2   PCIE_RX6_P        MGT
set_property PACKAGE_PIN AM1 [get_ports pciRxN[6]]; # AM1   PCIE_RX6_N        MGT

set_property PACKAGE_PIN AN4 [get_ports pciTxP[7]]; # AN4   PCIE_TX7_PIN_P    MGT
set_property PACKAGE_PIN AN3 [get_ports pciTxN[7]]; # AN3   PCIE_TX7_PIN_N    MGT
set_property PACKAGE_PIN AP2 [get_ports pciRxP[7]]; # AP2   PCIE_RX7_P        MGT
set_property PACKAGE_PIN AP1 [get_ports pciRxN[7]]; # AP1   PCIE_RX7_N        MGT

# G4   PCIE_TX8_PIN_P      MGT
# G3   PCIE_TX8_PIN_N      MGT
# F2   PCIE_RX8_P          MGT
# F1   PCIE_RX8_N          MGT

# J4   PCIE_TX9_PIN_P      MGT
# J3   PCIE_TX9_PIN_N      MGT
# H2   PCIE_RX9_P          MGT
# H1   PCIE_RX9_N          MGT

# L4   PCIE_TX10_PIN_P     MGT
# L3   PCIE_TX10_PIN_N     MGT
# K2   PCIE_RX10_P         MGT
# K1   PCIE_RX10_N         MGT

# N4   PCIE_TX11_PIN_P     MGT
# N3   PCIE_TX11_PIN_N     MGT
# M2   PCIE_RX11_P         MGT
# M1   PCIE_RX11_N         MGT

# R4   PCIE_TX12_PIN_P     MGT
# R3   PCIE_TX12_PIN_N     MGT
# P2   PCIE_RX12_P         MGT
# P1   PCIE_RX12_N         MGT

# U4   PCIE_TX13_PIN_P     MGT
# U3   PCIE_TX13_PIN_N     MGT
# T2   PCIE_RX13_P         MGT
# T1   PCIE_RX13_N         MGT

# W4   PCIE_TX14_PIN_P     MGT
# W3   PCIE_TX14_PIN_N     MGT
# V2   PCIE_RX14_P         MGT
# V1   PCIE_RX14_N         MGT

# AA4  PCIE_TX15_PIN_P     MGT
# AA3  PCIE_TX15_PIN_N     MGT
# Y2   PCIE_RX15_P         MGT
# Y1   PCIE_RX15_N         MGT

set_property PACKAGE_PIN AB6  [get_ports pciRefClkP];  # AB6   PCIE_REFCLK1_PIN_P   MGT_REFCLK
set_property PACKAGE_PIN AB5  [get_ports pciRefClkN];  # AB5   PCIE_REFCLK1_PIN_N   MGT_REFCLK
# set_property PACKAGE_PIN P6  [get_ports pciRefClkP]; # P6   PCIE_REFCLK0_PIN_P   MGT_REFCLK
# set_property PACKAGE_PIN P5  [get_ports pciRefClkN]; # P5   PCIE_REFCLK0_PIN_N   MGT_REFCLK

set_property -dict { PACKAGE_PIN K22 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}];   # K22   PERST1_L             1.8
# set_property -dict { PACKAGE_PIN N23 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]; # N23   PERST0_L             1.8

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst/CFGMAX*}]
set_false_path -through [get_nets {U_Core/U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

create_clock -name pciRefClkP -period 10.000 [get_ports {pciRefClkP}]
create_clock -name ddrClkP0   -period  2.500 [get_ports {ddrClkP[0]}]
create_clock -name ddrClkP1   -period  2.500 [get_ports {ddrClkP[1]}]

create_generated_clock -name dnaClk  [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_generated_clock -name sysClk  [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/bufg_gt_userclk/O}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {ddrClkP0}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {ddrClkP1}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP0}]   -group [get_clocks -include_generated_clocks {ddrClkP1}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]

######################################
# BITSTREAM: .bit file Configuration #
######################################

# set_property BITSTREAM.GENERAL.COMPRESS {TRUE} [ current_design ]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE {TYPE1} [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN {Pullnone} [current_design]
set_property CONFIG_MODE {BPI16} [current_design]
set_property CFGBVS GND [ current_design ]
set_property CONFIG_VOLTAGE 1.8 [ current_design ]
