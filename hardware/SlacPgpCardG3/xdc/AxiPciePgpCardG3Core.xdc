##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

######################################
# BITSTREAM: .bit file Configuration #
######################################

set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]   
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type2 [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]

#############
# User LEDs #
#############

set_property -dict { PACKAGE_PIN Y31 IOSTANDARD LVCMOS25 } [get_ports { ledDbg }]

set_property -dict { PACKAGE_PIN H29 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[0]   }]
set_property -dict { PACKAGE_PIN K30 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[0]  }]
set_property -dict { PACKAGE_PIN J30 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[0] }]

set_property -dict { PACKAGE_PIN G29 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[1]   }]
set_property -dict { PACKAGE_PIN G30 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[1]  }]
set_property -dict { PACKAGE_PIN K31 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[1] }]

set_property -dict { PACKAGE_PIN G32 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[2]   }]
set_property -dict { PACKAGE_PIN K33 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[2]  }]
set_property -dict { PACKAGE_PIN J34 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[2] }]

set_property -dict { PACKAGE_PIN H33 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[3]   }]
set_property -dict { PACKAGE_PIN G34 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[3]  }]
set_property -dict { PACKAGE_PIN L32 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[3] }]

set_property -dict { PACKAGE_PIN J31 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[4]   }]
set_property -dict { PACKAGE_PIN H31 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[4]  }]
set_property -dict { PACKAGE_PIN G31 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[4] }]

set_property -dict { PACKAGE_PIN L29 IOSTANDARD LVCMOS33 } [get_ports { ledRedL[5]   }]
set_property -dict { PACKAGE_PIN L30 IOSTANDARD LVCMOS33 } [get_ports { ledBlueL[5]  }]
set_property -dict { PACKAGE_PIN H32 IOSTANDARD LVCMOS33 } [get_ports { ledGreenL[5] }]

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[0] }]
set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[1] }]
set_property -dict { PACKAGE_PIN AA25 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[2] }]
set_property -dict { PACKAGE_PIN AA24 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[3] }]
set_property -dict { PACKAGE_PIN AB29 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[4] }]
set_property -dict { PACKAGE_PIN AA29 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[5] }]
set_property -dict { PACKAGE_PIN AB27 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[6] }]
set_property -dict { PACKAGE_PIN AA28 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[7] }]
set_property -dict { PACKAGE_PIN AA27 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[8] }]
set_property -dict { PACKAGE_PIN AC29 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[9] }]
set_property -dict { PACKAGE_PIN AC28 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[10] }]
set_property -dict { PACKAGE_PIN AB34 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[11] }]
set_property -dict { PACKAGE_PIN AA34 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[12] }]
set_property -dict { PACKAGE_PIN AC32 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[13] }]
set_property -dict { PACKAGE_PIN AC31 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[14] }]
set_property -dict { PACKAGE_PIN AA33 IOSTANDARD LVCMOS25 } [get_ports { flashAddr[15] }]
set_property -dict { PACKAGE_PIN M34  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[16] }]
set_property -dict { PACKAGE_PIN N34  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[17] }]
set_property -dict { PACKAGE_PIN R33  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[18] }]
set_property -dict { PACKAGE_PIN N33  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[19] }]
set_property -dict { PACKAGE_PIN N32  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[20] }]
set_property -dict { PACKAGE_PIN R32  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[21] }]
set_property -dict { PACKAGE_PIN T32  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[22] }]
set_property -dict { PACKAGE_PIN U32  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[23] }]
set_property -dict { PACKAGE_PIN U31  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[24] }]
set_property -dict { PACKAGE_PIN M32  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[25] }]
set_property -dict { PACKAGE_PIN N31  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[26] }]
set_property -dict { PACKAGE_PIN P31  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[27] }]
set_property -dict { PACKAGE_PIN R31  IOSTANDARD LVCMOS25 } [get_ports { flashAddr[28] }]

set_property -dict { PACKAGE_PIN V28 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[0] }]
set_property -dict { PACKAGE_PIN V29 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[1] }]
set_property -dict { PACKAGE_PIN V26 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[2] }]
set_property -dict { PACKAGE_PIN V27 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[3] }]
set_property -dict { PACKAGE_PIN W28 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[4] }]
set_property -dict { PACKAGE_PIN W29 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[5] }]
set_property -dict { PACKAGE_PIN W25 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[6] }]
set_property -dict { PACKAGE_PIN Y25 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[7] }]
set_property -dict { PACKAGE_PIN Y28 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[8] }]
set_property -dict { PACKAGE_PIN V31 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[9] }]
set_property -dict { PACKAGE_PIN V32 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[10] }]
set_property -dict { PACKAGE_PIN W33 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[11] }]
set_property -dict { PACKAGE_PIN W34 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[12] }]
set_property -dict { PACKAGE_PIN V34 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[13] }]
set_property -dict { PACKAGE_PIN Y32 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[14] }]
set_property -dict { PACKAGE_PIN Y33 IOSTANDARD LVCMOS25 PULLUP true} [get_ports { flashData[15] }]

set_property -dict { PACKAGE_PIN M31 IOSTANDARD LVCMOS25 } [get_ports { flashAdv }]
set_property -dict { PACKAGE_PIN Y27 IOSTANDARD LVCMOS25 } [get_ports { flashCeL }]
set_property -dict { PACKAGE_PIN U34 IOSTANDARD LVCMOS25 } [get_ports { flashOeL }]
set_property -dict { PACKAGE_PIN T34 IOSTANDARD LVCMOS25 } [get_ports { flashWeL }]

####################
# PCIe Constraints #
####################

set_property PACKAGE_PIN B23 [get_ports pciTxP[3]]
set_property PACKAGE_PIN A23 [get_ports pciTxN[3]]
set_property PACKAGE_PIN F21 [get_ports pciRxP[3]]
set_property PACKAGE_PIN E21 [get_ports pciRxN[3]]

set_property PACKAGE_PIN D22 [get_ports pciTxP[2]]
set_property PACKAGE_PIN C22 [get_ports pciTxN[2]]
set_property PACKAGE_PIN D20 [get_ports pciRxP[2]]
set_property PACKAGE_PIN C20 [get_ports pciRxN[2]]

set_property PACKAGE_PIN B21 [get_ports pciTxP[1]]
set_property PACKAGE_PIN A21 [get_ports pciTxN[1]]
set_property PACKAGE_PIN F19 [get_ports pciRxP[1]]
set_property PACKAGE_PIN E19 [get_ports pciRxN[1]]

set_property PACKAGE_PIN B19 [get_ports pciTxP[0]]
set_property PACKAGE_PIN A19 [get_ports pciTxN[0]]
set_property PACKAGE_PIN D18 [get_ports pciRxP[0]]
set_property PACKAGE_PIN C18 [get_ports pciRxN[0]]

set_property PACKAGE_PIN H18  [get_ports pciRefClkP]
set_property PACKAGE_PIN G18  [get_ports pciRefClkN]
create_clock -name pciRefClkP -period 10 [get_ports pciRefClkP]

set_property -dict { PACKAGE_PIN L23 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { pciRstL }]
set_false_path -from [get_ports pciRstL]

######################
# Timing Constraints #
######################

create_generated_clock -name sysClk   [get_pins {U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3}]
create_generated_clock -name dnaClk   [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
create_generated_clock -name dnaClkL  [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}]
create_generated_clock -name iprogClk [get_pins {U_Core/U_REG/U_Version/GEN_ICAP.Iprog_1/GEN_7SERIES.Iprog7Series_Inst/DIVCLK_GEN.BUFR_ICPAPE2/O}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkL}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {iprogClk}]

######################
# Area Constraint    #
######################
create_pblock PCIE_GRP
add_cells_to_pblock [get_pblocks PCIE_GRP] [get_cells U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i]
add_cells_to_pblock [get_pblocks PCIE_GRP] [get_cells U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/axi_enhanced_top/tx_inst/tx_arbiter]
add_cells_to_pblock [get_pblocks PCIE_GRP] [get_cells U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_pcie_mm_s/comp_slave_bridge/comp_slave_read_req_tlp]
add_cells_to_pblock [get_pblocks PCIE_GRP] [get_cells U_Core/REAL_PCIE.U_AxiPciePhy/U_AxiPcie/inst/comp_axi_pcie_mm_s/comp_slave_bridge/comp_slave_read_cpl_tlp]
resize_pblock [get_pblocks PCIE_GRP] -add {CLOCKREGION_X0Y4:CLOCKREGION_X0Y4}

#######
# PGP #
#######

set_property PACKAGE_PIN AN19 [get_ports pgpTxP[0]]
set_property PACKAGE_PIN AP19 [get_ports pgpTxN[0]]
set_property PACKAGE_PIN AL18 [get_ports pgpRxP[0]]
set_property PACKAGE_PIN AM18 [get_ports pgpRxN[0]]

set_property PACKAGE_PIN AN21 [get_ports pgpTxP[1]]
set_property PACKAGE_PIN AP21 [get_ports pgpTxN[1]]
set_property PACKAGE_PIN AJ19 [get_ports pgpRxP[1]]
set_property PACKAGE_PIN AK19 [get_ports pgpRxN[1]]

set_property PACKAGE_PIN AL22 [get_ports pgpTxP[2]]
set_property PACKAGE_PIN AM22 [get_ports pgpTxN[2]]
set_property PACKAGE_PIN AL20 [get_ports pgpRxP[2]]
set_property PACKAGE_PIN AM20 [get_ports pgpRxN[2]]

set_property PACKAGE_PIN AN23 [get_ports pgpTxP[3]]
set_property PACKAGE_PIN AP23 [get_ports pgpTxN[3]]
set_property PACKAGE_PIN AJ21 [get_ports pgpRxP[3]]
set_property PACKAGE_PIN AK21 [get_ports pgpRxN[3]]

set_property PACKAGE_PIN AN17 [get_ports pgpTxP[4]]
set_property PACKAGE_PIN AP17 [get_ports pgpTxN[4]]
set_property PACKAGE_PIN AJ17 [get_ports pgpRxP[4]]
set_property PACKAGE_PIN AK17 [get_ports pgpRxN[4]]

set_property PACKAGE_PIN AN15 [get_ports pgpTxP[5]]
set_property PACKAGE_PIN AP15 [get_ports pgpTxN[5]]
set_property PACKAGE_PIN AL16 [get_ports pgpRxP[5]]
set_property PACKAGE_PIN AM16 [get_ports pgpRxN[5]]

set_property PACKAGE_PIN AL14 [get_ports pgpTxP[6]]
set_property PACKAGE_PIN AM14 [get_ports pgpTxN[6]]
set_property PACKAGE_PIN AJ15 [get_ports pgpRxP[6]]
set_property PACKAGE_PIN AK15 [get_ports pgpRxN[6]]

set_property PACKAGE_PIN AN13 [get_ports pgpTxP[7]]
set_property PACKAGE_PIN AP13 [get_ports pgpTxN[7]]
set_property PACKAGE_PIN AJ13 [get_ports pgpRxP[7]]
set_property PACKAGE_PIN AK13 [get_ports pgpRxN[7]]

set_property PACKAGE_PIN AG18  [get_ports pgpRefClkP]
set_property PACKAGE_PIN AH18  [get_ports pgpRefClkN]
create_clock -name pgpRefClk  -period  4.00 [get_ports pgpRefClkP]

#######
# EVR #
#######

set_property PACKAGE_PIN B13  [get_ports evrTxP]
set_property PACKAGE_PIN A13  [get_ports evrTxN]
set_property PACKAGE_PIN F13  [get_ports evrRxP]
set_property PACKAGE_PIN E13  [get_ports evrRxN]

set_property PACKAGE_PIN H16  [get_ports evrRefClkP[0]]
set_property PACKAGE_PIN G16  [get_ports evrRefClkN[0]]
create_clock -name evrRefClk0 -period  4.201 [get_ports {evrRefClkP[0]}]

set_property PACKAGE_PIN H14  [get_ports evrRefClkP[1]]
set_property PACKAGE_PIN G14  [get_ports evrRefClkN[1]]
create_clock -name evrRefClk1 -period  2.691 [get_ports {evrRefClkP[1]}]

set_property -dict { PACKAGE_PIN V24 IOSTANDARD LVCMOS25 } [get_ports { evrMuxSel[0] }]
set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVCMOS25 } [get_ports { evrMuxSel[1] }]