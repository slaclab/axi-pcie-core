##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##########################################
# QSFP[3:0] GT Interfaces
##########################################

set_property PACKAGE_PIN AR51 [get_ports { qsfp0RefClkP }] ;# Bank 209 " GTM_REFCLKP0_209 "qsfp0_322mhz_clk_p"
create_clock -period 3.103 -name qsfp0RefClkP [get_ports {qsfp0RefClkP}]

set_property PACKAGE_PIN AE67 [get_ports { qsfp0RxP[0] }] ;# Bank 209 " GTM_RXP0_209
set_property PACKAGE_PIN AE64 [get_ports { qsfp0RxP[1] }] ;# Bank 209 " GTM_RXP1_209
set_property PACKAGE_PIN AC67 [get_ports { qsfp0RxP[2] }] ;# Bank 209 " GTM_RXP2_209
set_property PACKAGE_PIN AC64 [get_ports { qsfp0RxP[3] }] ;# Bank 209 " GTM_RXP3_209

set_property PACKAGE_PIN AG61 [get_ports { qsfp0TxP[0] }] ;# Bank 209 " GTM_TXP0_209
set_property PACKAGE_PIN AG58 [get_ports { qsfp0TxP[1] }] ;# Bank 209 " GTM_TXP1_209
set_property PACKAGE_PIN AE61 [get_ports { qsfp0TxP[2] }] ;# Bank 209 " GTM_TXP2_209
set_property PACKAGE_PIN AE58 [get_ports { qsfp0TxP[3] }] ;# Bank 209 " GTM_TXP3_209

set_property PACKAGE_PIN AA67 [get_ports { qsfp1RxP[0] }] ;# Bank 210 " GTM_RXP0_210
set_property PACKAGE_PIN AA64 [get_ports { qsfp1RxP[1] }] ;# Bank 210 " GTM_RXP1_210
set_property PACKAGE_PIN W67  [get_ports { qsfp1RxP[2] }] ;# Bank 210 " GTM_RXP2_210
set_property PACKAGE_PIN W64  [get_ports { qsfp1RxP[3] }] ;# Bank 210 " GTM_RXP3_210

set_property PACKAGE_PIN AC61 [get_ports { qsfp1TxP[0] }] ;# Bank 210 " GTM_TXP0_210
set_property PACKAGE_PIN AC58 [get_ports { qsfp1TxP[1] }] ;# Bank 210 " GTM_TXP1_210
set_property PACKAGE_PIN AA61 [get_ports { qsfp1TxP[2] }] ;# Bank 210 " GTM_TXP2_210
set_property PACKAGE_PIN AA58 [get_ports { qsfp1TxP[3] }] ;# Bank 210 " GTM_TXP3_210

set_property PACKAGE_PIN AL17 [get_ports { qsfp2RefClkP }] ;# Bank 111 " GTM_REFCLKP0_111 "qsfp2_322mhz_clk_p"
create_clock -period 3.103 -name qsfp2RefClkP [get_ports {qsfp2RefClkP}]

set_property PACKAGE_PIN U3   [get_ports { qsfp2RxP[0] }] ;# Bank 112 " GTM_RXP0_112
set_property PACKAGE_PIN U6   [get_ports { qsfp2RxP[1] }] ;# Bank 112 " GTM_RXP1_112
set_property PACKAGE_PIN R3   [get_ports { qsfp2RxP[2] }] ;# Bank 112 " GTM_RXP2_112
set_property PACKAGE_PIN R6   [get_ports { qsfp2RxP[3] }] ;# Bank 112 " GTM_RXP3_112

set_property PACKAGE_PIN U9   [get_ports { qsfp2TxP[0] }] ;# Bank 112 " GTM_TXP0_112
set_property PACKAGE_PIN U12  [get_ports { qsfp2TxP[1] }] ;# Bank 112 " GTM_TXP1_112
set_property PACKAGE_PIN R9   [get_ports { qsfp2TxP[2] }] ;# Bank 112 " GTM_TXP2_112
set_property PACKAGE_PIN R12  [get_ports { qsfp2TxP[3] }] ;# Bank 112 " GTM_TXP3_112

set_property PACKAGE_PIN AA3  [get_ports { qsfp3RxP[0] }] ;# Bank 111 " GTM_RXP0_111
set_property PACKAGE_PIN AA6  [get_ports { qsfp3RxP[1] }] ;# Bank 111 " GTM_RXP1_111
set_property PACKAGE_PIN W3   [get_ports { qsfp3RxP[2] }] ;# Bank 111 " GTM_RXP2_111
set_property PACKAGE_PIN W6   [get_ports { qsfp3RxP[3] }] ;# Bank 111 " GTM_RXP3_111

set_property PACKAGE_PIN AA9  [get_ports { qsfp3TxP[0] }] ;# Bank 111 " GTM_TXP0_111
set_property PACKAGE_PIN AA12 [get_ports { qsfp3TxP[1] }] ;# Bank 111 " GTM_TXP1_111
set_property PACKAGE_PIN W9   [get_ports { qsfp3TxP[2] }] ;# Bank 111 " GTM_TXP2_111
set_property PACKAGE_PIN W12  [get_ports { qsfp3TxP[3] }] ;# Bank 111 " GTM_TXP3_111

##########################################
# MCIO[3:0] GT Interfaces
##########################################

set_property PACKAGE_PIN BP53 [get_ports { mcio0RefClkP }] ;# Bank 200 " GTYP_REFCLKP0_200 "mcio0_100mhz_clk_p"
create_clock -period 10.000 -name mcio0RefClkP [get_ports {mcio0RefClkP}]

set_property PACKAGE_PIN BP66 [get_ports { mcio0RxP[0] }] ;# Bank 200 " GTYP_RXP0_200
set_property PACKAGE_PIN BP62 [get_ports { mcio0RxP[1] }] ;# Bank 200 " GTYP_RXP1_200
set_property PACKAGE_PIN BN68 [get_ports { mcio0RxP[2] }] ;# Bank 200 " GTYP_RXP2_200
set_property PACKAGE_PIN BN64 [get_ports { mcio0RxP[3] }] ;# Bank 200 " GTYP_RXP3_200

set_property PACKAGE_PIN BR59 [get_ports { mcio0TxP[0] }] ;# Bank 200 " GTYP_TXP0_200
set_property PACKAGE_PIN BR55 [get_ports { mcio0TxP[1] }] ;# Bank 200 " GTYP_TXP1_200
set_property PACKAGE_PIN BP57 [get_ports { mcio0TxP[2] }] ;# Bank 200 " GTYP_TXP2_200
set_property PACKAGE_PIN BN59 [get_ports { mcio0TxP[3] }] ;# Bank 200 " GTYP_TXP3_200

set_property PACKAGE_PIN AG55 [get_ports { mcio1RefClkP }] ;# Bank 213 " GTYP_REFCLKP0_213 "mcio1_100mhz_clk_p"
create_clock -period 10.000 -name mcio1RefClkP [get_ports {mcio1RefClkP}]

set_property PACKAGE_PIN D66 [get_ports { mcio1aRxP[0] }] ;# Bank 213 " GTYP_RXP0_213
set_property PACKAGE_PIN B65 [get_ports { mcio1aRxP[1] }] ;# Bank 213 " GTYP_RXP1_213
set_property PACKAGE_PIN D64 [get_ports { mcio1aRxP[2] }] ;# Bank 213 " GTYP_RXP2_213
set_property PACKAGE_PIN B63 [get_ports { mcio1aRxP[3] }] ;# Bank 213 " GTYP_RXP3_213

set_property PACKAGE_PIN G69 [get_ports { mcio1aTxP[0] }] ;# Bank 213 " GTYP_TXP0_213
set_property PACKAGE_PIN E68 [get_ports { mcio1aTxP[1] }] ;# Bank 213 " GTYP_TXP1_213
set_property PACKAGE_PIN G67 [get_ports { mcio1aTxP[2] }] ;# Bank 213 " GTYP_TXP2_213
set_property PACKAGE_PIN G65 [get_ports { mcio1aTxP[3] }] ;# Bank 213 " GTYP_TXP3_213

set_property PACKAGE_PIN D62 [get_ports { mcio1bRxP[0] }] ;# Bank 214 " GTYP_RXP0_214
set_property PACKAGE_PIN B61 [get_ports { mcio1bRxP[1] }] ;# Bank 214 " GTYP_RXP1_214
set_property PACKAGE_PIN D60 [get_ports { mcio1bRxP[2] }] ;# Bank 214 " GTYP_RXP2_214
set_property PACKAGE_PIN B59 [get_ports { mcio1bRxP[3] }] ;# Bank 214 " GTYP_RXP3_214

set_property PACKAGE_PIN G63 [get_ports { mcio1bTxP[0] }] ;# Bank 214 " GTYP_TXP0_214
set_property PACKAGE_PIN G61 [get_ports { mcio1bTxP[1] }] ;# Bank 214 " GTYP_TXP1_214
set_property PACKAGE_PIN J60 [get_ports { mcio1bTxP[2] }] ;# Bank 214 " GTYP_TXP2_214
set_property PACKAGE_PIN G59 [get_ports { mcio1bTxP[3] }] ;# Bank 214 " GTYP_TXP3_214

# set_property PACKAGE_PIN AB53 [get_ports { mcio2RefClkP }] ;# Bank 218 " GTYP_REFCLKP0_218 "mcio2_100mhz_clk_p"
# create_clock -period 10.000 -name mcio2RefClkP [get_ports {mcio2RefClkP}]

# Using this GT clock for a precision clock reference for the application space
set_property PACKAGE_PIN AB53 [get_ports { userClkP }] ;# Bank 218 " GTYP_REFCLKP0_218 "mcio2_100mhz_clk_p"
create_clock -period 10.000 -name userClkP [get_ports {userClkP}]

set_property PACKAGE_PIN D46 [get_ports { mcio2RxP[0] }] ;# Bank 218 " GTYP_RXP0_218
set_property PACKAGE_PIN B45 [get_ports { mcio2RxP[1] }] ;# Bank 218 " GTYP_RXP1_218
set_property PACKAGE_PIN D44 [get_ports { mcio2RxP[2] }] ;# Bank 218 " GTYP_RXP2_218
set_property PACKAGE_PIN B43 [get_ports { mcio2RxP[3] }] ;# Bank 218 " GTYP_RXP3_218

set_property PACKAGE_PIN J46 [get_ports { mcio2TxP[0] }] ;# Bank 218 " GTYP_TXP0_218
set_property PACKAGE_PIN G45 [get_ports { mcio2TxP[1] }] ;# Bank 218 " GTYP_TXP1_218
set_property PACKAGE_PIN J44 [get_ports { mcio2TxP[2] }] ;# Bank 218 " GTYP_TXP2_218
set_property PACKAGE_PIN G43 [get_ports { mcio2TxP[3] }] ;# Bank 218 " GTYP_TXP3_218

##########################################
# 32 GB DDR4 DIMM Interfaces
##########################################

set_property -dict { PACKAGE_PIN CG22    IOSTANDARD SSTL12                            } [get_ports "plDdrActN[0]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_ACT_B0 - IO_L9N_GC_XCC_N3P1_M1P73_704
set_property -dict { PACKAGE_PIN CH20    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A0 - IO_L3P_XCC_N1P0_M1P60_704
set_property -dict { PACKAGE_PIN CG23    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[1]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A1 - IO_L8N_N2P5_M1P71_704
set_property -dict { PACKAGE_PIN CH23    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[2]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A2 - IO_L11P_N3P4_M1P76_704
set_property -dict { PACKAGE_PIN BV20    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[3]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A3 - IO_L14N_N4P5_M1P83_704
set_property -dict { PACKAGE_PIN BU19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[4]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A4 - IO_L14P_N4P4_M1P82_704
set_property -dict { PACKAGE_PIN CB18    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[5]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A5 - IO_L17P_N5P4_M1P88_704
set_property -dict { PACKAGE_PIN CC18    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[6]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A6 - IO_L17N_N5P5_M1P89_704
set_property -dict { PACKAGE_PIN CC19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[7]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A7 - IO_L24P_GC_XCC_N8P0_M1P102_704
set_property -dict { PACKAGE_PIN CH18    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[8]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A8 - IO_L5N_N1P5_M1P65_704
set_property -dict { PACKAGE_PIN CF23    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[9]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A9 - IO_L8P_N2P4_M1P70_704
set_property -dict { PACKAGE_PIN CD20    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[10]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A10 - IO_L25N_N8P3_M1P105_704
set_property -dict { PACKAGE_PIN BV18    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[11]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A11 - IO_L13N_N4P3_M1P81_704
set_property -dict { PACKAGE_PIN CD21    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[12]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A12 - IO_L26P_N8P4_M1P106_704
set_property -dict { PACKAGE_PIN CE19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[13]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A13 - IO_L1P_N0P2_M1P56_704
set_property -dict { PACKAGE_PIN BY19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[14]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A14 - IO_L15N_XCC_N5P1_M1P85_704
set_property -dict { PACKAGE_PIN BT19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[15]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A15 - IO_L12P_GC_XCC_N4P0_M1P78_704
set_property -dict { PACKAGE_PIN CJ19    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[16]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A16 - IO_L4N_N1P3_M1P63_704
set_property -dict { PACKAGE_PIN CG18    IOSTANDARD SSTL12                            } [get_ports "plDdrAdr[17]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_A17 - IO_L5P_N1P4_M1P64_704
set_property -dict { PACKAGE_PIN CD15    IOSTANDARD POD12                             } [get_ports "plDdrAlertN[0]"]    ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_ALERT_B - IO_L25N_N8P3_M1P51_703
set_property -dict { PACKAGE_PIN CD19    IOSTANDARD SSTL12                            } [get_ports "plDdrBa[0]"]        ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_BA0 - IO_L24N_GC_XCC_N8P1_M1P103_704
set_property -dict { PACKAGE_PIN CF19    IOSTANDARD SSTL12                            } [get_ports "plDdrBa[1]"]        ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_BA1 - IO_L1N_N0P3_M1P57_704
set_property -dict { PACKAGE_PIN CE21    IOSTANDARD SSTL12                            } [get_ports "plDdrBg[0]"]        ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_BG0 - IO_L26N_N8P5_M1P107_704
set_property -dict { PACKAGE_PIN CG21    IOSTANDARD SSTL12                            } [get_ports "plDdrBg[1]"]        ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_BG1 - IO_L9P_GC_XCC_N3P0_M1P72_704
set_property -dict { PACKAGE_PIN CF21    IOSTANDARD SSTL12                            } [get_ports "plDdrCkT[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_CK_T0 - IO_L7N_N2P3_M1P69_704
set_property -dict { PACKAGE_PIN CE22    IOSTANDARD SSTL12                            } [get_ports "plDdrCkC[0]"]       ;# TODO why standard not diff ? # Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_CK_C0 - IO_L7P_N2P2_M1P68_704
set_property -dict { PACKAGE_PIN CJ22    IOSTANDARD SSTL12                            } [get_ports "plDdrCke[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_CKE0 - IO_L11N_N3P5_M1P77_704
set_property -dict { PACKAGE_PIN CH19    IOSTANDARD SSTL12                            } [get_ports "plDdrCsN[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_CS_B0 - IO_L4P_N1P2_M1P62_704
set_property -dict { PACKAGE_PIN BV17    IOSTANDARD POD12                             } [get_ports "plDdrDq[0]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ0 - IO_L20N_N6P5_M1P41_703
set_property -dict { PACKAGE_PIN BT17    IOSTANDARD POD12                             } [get_ports "plDdrDq[1]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ1 - IO_L19N_N6P3_M1P39_703
set_property -dict { PACKAGE_PIN BT16    IOSTANDARD POD12                             } [get_ports "plDdrDq[2]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ2 - IO_L19P_N6P2_M1P38_703
set_property -dict { PACKAGE_PIN BU16    IOSTANDARD POD12                             } [get_ports "plDdrDq[3]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ3 - IO_L20P_N6P4_M1P40_703
set_property -dict { PACKAGE_PIN BV15    IOSTANDARD POD12                             } [get_ports "plDdrDq[4]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ4 - IO_L22P_N7P2_M1P44_703
set_property -dict { PACKAGE_PIN BW15    IOSTANDARD POD12                             } [get_ports "plDdrDq[5]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ5 - IO_L22N_N7P3_M1P45_703
set_property -dict { PACKAGE_PIN BW14    IOSTANDARD POD12                             } [get_ports "plDdrDq[6]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ6 - IO_L23N_N7P5_M1P47_703
set_property -dict { PACKAGE_PIN BV14    IOSTANDARD POD12                             } [get_ports "plDdrDq[7]"]        ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ7 - IO_L23P_N7P4_M1P46_703
set_property -dict { PACKAGE_PIN BU24    IOSTANDARD POD12                             } [get_ports "plDdrDq[8]"]        ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ8 - IO_L19P_N6P2_M1P146_705
set_property -dict { PACKAGE_PIN BU25    IOSTANDARD POD12                             } [get_ports "plDdrDq[9]"]        ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ9 - IO_L20P_N6P4_M1P148_705
set_property -dict { PACKAGE_PIN BV24    IOSTANDARD POD12                             } [get_ports "plDdrDq[10]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ10 - IO_L19N_N6P3_M1P147_705
set_property -dict { PACKAGE_PIN BV26    IOSTANDARD POD12                             } [get_ports "plDdrDq[11]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ11 - IO_L20N_N6P5_M1P149_705
set_property -dict { PACKAGE_PIN BV29    IOSTANDARD POD12                             } [get_ports "plDdrDq[12]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ12 - IO_L22N_N7P3_M1P153_705
set_property -dict { PACKAGE_PIN BW29    IOSTANDARD POD12                             } [get_ports "plDdrDq[13]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ13 - IO_L23N_N7P5_M1P155_705
set_property -dict { PACKAGE_PIN BW28    IOSTANDARD POD12                             } [get_ports "plDdrDq[14]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ14 - IO_L23P_N7P4_M1P154_705
set_property -dict { PACKAGE_PIN BU28    IOSTANDARD POD12                             } [get_ports "plDdrDq[15]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ15 - IO_L22P_N7P2_M1P152_705
set_property -dict { PACKAGE_PIN CF26    IOSTANDARD POD12                             } [get_ports "plDdrDq[16]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ16 - IO_L8N_N2P5_M1P125_705
set_property -dict { PACKAGE_PIN CE26    IOSTANDARD POD12                             } [get_ports "plDdrDq[17]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ17 - IO_L8P_N2P4_M1P124_705
set_property -dict { PACKAGE_PIN CF25    IOSTANDARD POD12                             } [get_ports "plDdrDq[18]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ18 - IO_L7N_N2P3_M1P123_705
set_property -dict { PACKAGE_PIN CE24    IOSTANDARD POD12                             } [get_ports "plDdrDq[19]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ19 - IO_L7P_N2P2_M1P122_705
set_property -dict { PACKAGE_PIN CE29    IOSTANDARD POD12                             } [get_ports "plDdrDq[20]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ20 - IO_L10P_N3P2_M1P128_705
set_property -dict { PACKAGE_PIN CF29    IOSTANDARD POD12                             } [get_ports "plDdrDq[21]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ21 - IO_L10N_N3P3_M1P129_705
set_property -dict { PACKAGE_PIN CG28    IOSTANDARD POD12                             } [get_ports "plDdrDq[22]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ22 - IO_L11P_N3P4_M1P130_705
set_property -dict { PACKAGE_PIN CH28    IOSTANDARD POD12                             } [get_ports "plDdrDq[23]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ23 - IO_L11N_N3P5_M1P131_705
set_property -dict { PACKAGE_PIN CB23    IOSTANDARD POD12                             } [get_ports "plDdrDq[24]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ24 - IO_L14P_N4P4_M1P136_705
set_property -dict { PACKAGE_PIN BY25    IOSTANDARD POD12                             } [get_ports "plDdrDq[25]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ25 - IO_L13P_N4P2_M1P134_705
set_property -dict { PACKAGE_PIN CC23    IOSTANDARD POD12                             } [get_ports "plDdrDq[26]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ26 - IO_L14N_N4P5_M1P137_705
set_property -dict { PACKAGE_PIN CA26    IOSTANDARD POD12                             } [get_ports "plDdrDq[27]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ27 - IO_L13N_N4P3_M1P135_705
set_property -dict { PACKAGE_PIN CB28    IOSTANDARD POD12                             } [get_ports "plDdrDq[28]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ28 - IO_L16N_N5P3_M1P141_705
set_property -dict { PACKAGE_PIN CA29    IOSTANDARD POD12                             } [get_ports "plDdrDq[29]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ29 - IO_L16P_N5P2_M1P140_705
set_property -dict { PACKAGE_PIN CC28    IOSTANDARD POD12                             } [get_ports "plDdrDq[30]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ30 - IO_L17P_N5P4_M1P142_705
set_property -dict { PACKAGE_PIN CC29    IOSTANDARD POD12                             } [get_ports "plDdrDq[31]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ31 - IO_L17N_N5P5_M1P143_705
set_property -dict { PACKAGE_PIN CF14    IOSTANDARD POD12                             } [get_ports "plDdrDq[32]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ32 - IO_L7N_N2P3_M1P15_703
set_property -dict { PACKAGE_PIN CF13    IOSTANDARD POD12                             } [get_ports "plDdrDq[33]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ33 - IO_L7P_N2P2_M1P14_703
set_property -dict { PACKAGE_PIN CG15    IOSTANDARD POD12                             } [get_ports "plDdrDq[34]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ34 - IO_L8N_N2P5_M1P17_703
set_property -dict { PACKAGE_PIN CF15    IOSTANDARD POD12                             } [get_ports "plDdrDq[35]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ35 - IO_L8P_N2P4_M1P16_703
set_property -dict { PACKAGE_PIN CG17    IOSTANDARD POD12                             } [get_ports "plDdrDq[36]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ36 - IO_L11N_N3P5_M1P23_703
set_property -dict { PACKAGE_PIN CF16    IOSTANDARD POD12                             } [get_ports "plDdrDq[37]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ37 - IO_L10N_N3P3_M1P21_703
set_property -dict { PACKAGE_PIN CE17    IOSTANDARD POD12                             } [get_ports "plDdrDq[38]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ38 - IO_L10P_N3P2_M1P20_703
set_property -dict { PACKAGE_PIN CG16    IOSTANDARD POD12                             } [get_ports "plDdrDq[39]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ39 - IO_L11P_N3P4_M1P22_703
set_property -dict { PACKAGE_PIN CJ14    IOSTANDARD POD12                             } [get_ports "plDdrDq[40]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ40 - IO_L2N_N0P5_M1P5_703
set_property -dict { PACKAGE_PIN CH13    IOSTANDARD POD12                             } [get_ports "plDdrDq[41]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ41 - IO_L2P_N0P4_M1P4_703
set_property -dict { PACKAGE_PIN CJ12    IOSTANDARD POD12                             } [get_ports "plDdrDq[42]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ42 - IO_L1N_N0P3_M1P3_703
set_property -dict { PACKAGE_PIN CH12    IOSTANDARD POD12                             } [get_ports "plDdrDq[43]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ43 - IO_L1P_N0P2_M1P2_703
set_property -dict { PACKAGE_PIN CH15    IOSTANDARD POD12                             } [get_ports "plDdrDq[44]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ44 - IO_L4P_N1P2_M1P8_703
set_property -dict { PACKAGE_PIN CJ16    IOSTANDARD POD12                             } [get_ports "plDdrDq[45]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ45 - IO_L4N_N1P3_M1P9_703
set_property -dict { PACKAGE_PIN CH17    IOSTANDARD POD12                             } [get_ports "plDdrDq[46]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ46 - IO_L5P_N1P4_M1P10_703
set_property -dict { PACKAGE_PIN CJ17    IOSTANDARD POD12                             } [get_ports "plDdrDq[47]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ47 - IO_L5N_N1P5_M1P11_703
set_property -dict { PACKAGE_PIN BV21    IOSTANDARD POD12                             } [get_ports "plDdrDq[48]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ48 - IO_L19P_N6P2_M1P92_704
set_property -dict { PACKAGE_PIN BY21    IOSTANDARD POD12                             } [get_ports "plDdrDq[49]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ49 - IO_L20N_N6P5_M1P95_704
set_property -dict { PACKAGE_PIN BW20    IOSTANDARD POD12                             } [get_ports "plDdrDq[50]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ50 - IO_L20P_N6P4_M1P94_704
set_property -dict { PACKAGE_PIN BW22    IOSTANDARD POD12                             } [get_ports "plDdrDq[51]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ51 - IO_L19N_N6P3_M1P93_704
set_property -dict { PACKAGE_PIN CB20    IOSTANDARD POD12                             } [get_ports "plDdrDq[52]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ52 - IO_L22N_N7P3_M1P99_704
set_property -dict { PACKAGE_PIN CA20    IOSTANDARD POD12                             } [get_ports "plDdrDq[53]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ53 - IO_L22P_N7P2_M1P98_704
set_property -dict { PACKAGE_PIN CB21    IOSTANDARD POD12                             } [get_ports "plDdrDq[54]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ54 - IO_L23P_N7P4_M1P100_704
set_property -dict { PACKAGE_PIN CB22    IOSTANDARD POD12                             } [get_ports "plDdrDq[55]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ55 - IO_L23N_N7P5_M1P101_704
set_property -dict { PACKAGE_PIN CH25    IOSTANDARD POD12                             } [get_ports "plDdrDq[56]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ56 - IO_L1N_N0P3_M1P111_705
set_property -dict { PACKAGE_PIN CJ25    IOSTANDARD POD12                             } [get_ports "plDdrDq[57]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ57 - IO_L2P_N0P4_M1P112_705
set_property -dict { PACKAGE_PIN CG25    IOSTANDARD POD12                             } [get_ports "plDdrDq[58]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ58 - IO_L1P_N0P2_M1P110_705
set_property -dict { PACKAGE_PIN CJ26    IOSTANDARD POD12                             } [get_ports "plDdrDq[59]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ59 - IO_L2N_N0P5_M1P113_705
set_property -dict { PACKAGE_PIN CJ29    IOSTANDARD POD12                             } [get_ports "plDdrDq[60]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ60 - IO_L5N_N1P5_M1P119_705
set_property -dict { PACKAGE_PIN CH29    IOSTANDARD POD12                             } [get_ports "plDdrDq[61]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ61 - IO_L5P_N1P4_M1P118_705
set_property -dict { PACKAGE_PIN CH27    IOSTANDARD POD12                             } [get_ports "plDdrDq[62]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ62 - IO_L4P_N1P2_M1P116_705
set_property -dict { PACKAGE_PIN CJ27    IOSTANDARD POD12                             } [get_ports "plDdrDq[63]"]       ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ63 - IO_L4N_N1P3_M1P117_705
set_property -dict { PACKAGE_PIN CA15    IOSTANDARD POD12                             } [get_ports "plDdrDq[64]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ64 - IO_L13N_N4P3_M1P27_703
set_property -dict { PACKAGE_PIN BY16    IOSTANDARD POD12                             } [get_ports "plDdrDq[65]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ65 - IO_L13P_N4P2_M1P26_703
set_property -dict { PACKAGE_PIN CC17    IOSTANDARD POD12                             } [get_ports "plDdrDq[66]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ66 - IO_L14P_N4P4_M1P28_703
set_property -dict { PACKAGE_PIN CD17    IOSTANDARD POD12                             } [get_ports "plDdrDq[67]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ67 - IO_L14N_N4P5_M1P29_703
set_property -dict { PACKAGE_PIN CC14    IOSTANDARD POD12                             } [get_ports "plDdrDq[68]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ68 - IO_L16N_N5P3_M1P33_703
set_property -dict { PACKAGE_PIN CC13    IOSTANDARD POD12                             } [get_ports "plDdrDq[69]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ69 - IO_L16P_N5P2_M1P32_703
set_property -dict { PACKAGE_PIN CD12    IOSTANDARD POD12                             } [get_ports "plDdrDq[70]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ70 - IO_L17N_N5P5_M1P35_703
set_property -dict { PACKAGE_PIN CC12    IOSTANDARD POD12                             } [get_ports "plDdrDq[71]"]       ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQ71 - IO_L17P_N5P4_M1P34_703
set_property -dict { PACKAGE_PIN BT14    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[0]"]      ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T0 - IO_L18P_XCC_N6P0_M1P36_703
set_property -dict { PACKAGE_PIN BV23    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[1]"]      ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T1 - IO_L18P_XCC_N6P0_M1P144_705
set_property -dict { PACKAGE_PIN CE23    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[2]"]      ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T2 - IO_L6P_GC_XCC_N2P0_M1P120_705
set_property -dict { PACKAGE_PIN BW25    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[3]"]      ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T3 - IO_L12P_GC_XCC_N4P0_M1P132_705
set_property -dict { PACKAGE_PIN CE12    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[4]"]      ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T4 - IO_L6P_GC_XCC_N2P0_M1P12_703
set_property -dict { PACKAGE_PIN CG12    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[5]"]      ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T5 - IO_L0P_XCC_N0P0_M1P0_703
set_property -dict { PACKAGE_PIN BU21    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[6]"]      ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T6 - IO_L18P_XCC_N6P0_M1P90_704
set_property -dict { PACKAGE_PIN CH24    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[7]"]      ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T7 - IO_L0P_XCC_N0P0_M1P108_705
set_property -dict { PACKAGE_PIN BY14    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[8]"]      ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T8 - IO_L12P_GC_XCC_N4P0_M1P24_703
set_property -dict { PACKAGE_PIN BW16    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[9]"]      ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T9 - IO_L21P_XCC_N7P0_M1P42_703
set_property -dict { PACKAGE_PIN BU27    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[10]"]     ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T10 - IO_L21P_XCC_N7P0_M1P150_705
set_property -dict { PACKAGE_PIN CE28    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[11]"]     ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T11 - IO_L9P_GC_XCC_N3P0_M1P126_705
set_property -dict { PACKAGE_PIN CB25    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[12]"]     ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T12 - IO_L15P_XCC_N5P0_M1P138_705
set_property -dict { PACKAGE_PIN CD16    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[13]"]     ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T13 - IO_L9P_GC_XCC_N3P0_M1P18_703
set_property -dict { PACKAGE_PIN CH14    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[14]"]     ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T14 - IO_L3P_XCC_N1P0_M1P6_703
set_property -dict { PACKAGE_PIN BY22    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[15]"]     ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T15 - IO_L21P_XCC_N7P0_M1P96_704
set_property -dict { PACKAGE_PIN CG26    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[16]"]     ;# Bank 705 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T16 - IO_L3P_XCC_N1P0_M1P114_705
set_property -dict { PACKAGE_PIN CA17    IOSTANDARD DIFF_POD12                        } [get_ports "plDdrDqsT[17]"]     ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_DQS_T17 - IO_L15P_XCC_N5P0_M1P30_703
set_property -dict { PACKAGE_PIN BY18    IOSTANDARD SSTL12                            } [get_ports "plDdrOdt[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_ODT0 - IO_L16P_N5P2_M1P86_704
set_property -dict { PACKAGE_PIN CJ20    IOSTANDARD SSTL12                            } [get_ports "plDdrPar[0]"]       ;# Bank 704 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_PAR0 - IO_L3N_XCC_N1P1_M1P61_704
set_property -dict { PACKAGE_PIN CC15    IOSTANDARD LVCMOS12                          } [get_ports "plDdrResetN[0]"]    ;# Bank 703 VCCO  - VR_1V2_VCCO_DIMM -Net CH0_DDR4_0_1_RESET_B - IO_L25P_N8P2_M1P50_703

set_property -dict { PACKAGE_PIN CB15    IOSTANDARD LVDS15                            } [get_ports "plDdrClkP"]         ;# Bank 703 VCCO - VR_1V2_VCCO_DIMM                       - IO_L24P_GC_XCC_N8P0_M1P48_703

##########################################
# 32 GB HBM Interfaces
##########################################

set_property -dict { PACKAGE_PIN N18                                                  } [get_ports "hbmRefClkP[0]"]   ;# Bank 800 " C4CCIO_PAD1_0_800
set_property -dict { PACKAGE_PIN N19                                                  } [get_ports "hbmRefClkN[0]"]   ;# Bank 800 " C4CCIO_PAD1_0_800
set_property -dict { PACKAGE_PIN N38                                                  } [get_ports "hbmRefClkP[0]"]   ;# Bank 801 " C4CCIO_PAD1_1_801
set_property -dict { PACKAGE_PIN N37                                                  } [get_ports "hbmRefClkN[0]"]   ;# Bank 801 " C4CCIO_PAD1_1_801
