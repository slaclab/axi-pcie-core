##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

#######################
# DDR[3]: Constraints #
#######################

# # DDR[3].BYTE[8]
# set_property -dict { PACKAGE_PIN J20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][64]  }]
# set_property -dict { PACKAGE_PIN J19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][65]  }]
# set_property -dict { PACKAGE_PIN K18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][66]  }]
# set_property -dict { PACKAGE_PIN J18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][67]  }]
# set_property -dict { PACKAGE_PIN J21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][8] }]
# set_property -dict { PACKAGE_PIN H21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][8] }]
# set_property -dict { PACKAGE_PIN L20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][68]  }]
# set_property -dict { PACKAGE_PIN K20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][69]  }]
# set_property -dict { PACKAGE_PIN L19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][70]  }]
# set_property -dict { PACKAGE_PIN L18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][71]  }]
# set_property -dict { PACKAGE_PIN L17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][8]   }]

# # DDR[3].BYTE[7]
# set_property -dict { PACKAGE_PIN B25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][56]  }]
# set_property -dict { PACKAGE_PIN A25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][63]  }]
# set_property -dict { PACKAGE_PIN B24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][57]  }]
# set_property -dict { PACKAGE_PIN A24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][58]  }]
# set_property -dict { PACKAGE_PIN A23 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][7] }]
# set_property -dict { PACKAGE_PIN A22 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][7] }]
# set_property -dict { PACKAGE_PIN C26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][60]  }]
# set_property -dict { PACKAGE_PIN B26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][61]  }]
# set_property -dict { PACKAGE_PIN C24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][59]  }]
# set_property -dict { PACKAGE_PIN C23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][62]  }]
# set_property -dict { PACKAGE_PIN C22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][7]   }]

# # DDR[3].BYTE[6]
# set_property -dict { PACKAGE_PIN E25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][51]  }]
# set_property -dict { PACKAGE_PIN D25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][50]  }]
# set_property -dict { PACKAGE_PIN D24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][48]  }]
# set_property -dict { PACKAGE_PIN D23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][52]  }]
# set_property -dict { PACKAGE_PIN E23 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][6] }]
# set_property -dict { PACKAGE_PIN E22 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][6] }]
# set_property -dict { PACKAGE_PIN G22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][53]  }]
# set_property -dict { PACKAGE_PIN F22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][49]  }]
# set_property -dict { PACKAGE_PIN F24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][54]  }]
# set_property -dict { PACKAGE_PIN F23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][55]  }]
# set_property -dict { PACKAGE_PIN G25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][6]   }]

# # DDR[3].BYTE[5]
# set_property -dict { PACKAGE_PIN J24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][47]  }]
# set_property -dict { PACKAGE_PIN H24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][42]  }]
# set_property -dict { PACKAGE_PIN J23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][44]  }]
# set_property -dict { PACKAGE_PIN H23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][45]  }]
# set_property -dict { PACKAGE_PIN K25 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][5] }]
# set_property -dict { PACKAGE_PIN J25 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][5] }]
# set_property -dict { PACKAGE_PIN L23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][46]  }]
# set_property -dict { PACKAGE_PIN K23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][43]  }]
# set_property -dict { PACKAGE_PIN L22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][40]  }]
# set_property -dict { PACKAGE_PIN K22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][41]  }]
# set_property -dict { PACKAGE_PIN L25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][5]   }]

# # DDR[3].BYTE[4]
# set_property -dict { PACKAGE_PIN R25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][33]  }]
# set_property -dict { PACKAGE_PIN P25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][38]  }]
# set_property -dict { PACKAGE_PIN M25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][37]  }]
# set_property -dict { PACKAGE_PIN M24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][35]  }]
# set_property -dict { PACKAGE_PIN P24 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][4] }]
# set_property -dict { PACKAGE_PIN N24 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][4] }]
# set_property -dict { PACKAGE_PIN P23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][34]  }]
# set_property -dict { PACKAGE_PIN N23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][39]  }]
# set_property -dict { PACKAGE_PIN N22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][36]  }]
# set_property -dict { PACKAGE_PIN M22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][32]  }]
# set_property -dict { PACKAGE_PIN R21 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][4]   }]

# # DDR[3].BYTE[3]
# set_property -dict { PACKAGE_PIN B17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][29]  }]
# set_property -dict { PACKAGE_PIN A17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][31]  }]
# set_property -dict { PACKAGE_PIN C16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][30]  }]
# set_property -dict { PACKAGE_PIN B16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][28]  }]
# set_property -dict { PACKAGE_PIN B15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][3] }]
# set_property -dict { PACKAGE_PIN A15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][3] }]
# set_property -dict { PACKAGE_PIN A14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][24]  }]
# set_property -dict { PACKAGE_PIN A13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][26]  }]
# set_property -dict { PACKAGE_PIN C14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][27]  }]
# set_property -dict { PACKAGE_PIN B14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][25]  }]
# set_property -dict { PACKAGE_PIN D13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][3]   }]

# # DDR[3].BYTE[2]
# set_property -dict { PACKAGE_PIN E16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][20]  }]
# set_property -dict { PACKAGE_PIN D16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][17]  }]
# set_property -dict { PACKAGE_PIN E15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][16]  }]
# set_property -dict { PACKAGE_PIN D15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][21]  }]
# set_property -dict { PACKAGE_PIN G17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][2] }]
# set_property -dict { PACKAGE_PIN G16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][2] }]
# set_property -dict { PACKAGE_PIN F13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][19]  }]
# set_property -dict { PACKAGE_PIN E13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][23]  }]
# set_property -dict { PACKAGE_PIN G15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][18]  }]
# set_property -dict { PACKAGE_PIN F15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][22]  }]
# set_property -dict { PACKAGE_PIN G14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][2]   }]

# # DDR[3].BYTE[1]
# set_property -dict { PACKAGE_PIN J16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][14]  }]
# set_property -dict { PACKAGE_PIN J15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][9]   }]
# set_property -dict { PACKAGE_PIN J14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][11]  }]
# set_property -dict { PACKAGE_PIN H14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][12]  }]
# set_property -dict { PACKAGE_PIN H17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][1] }]
# set_property -dict { PACKAGE_PIN H16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][1] }]
# set_property -dict { PACKAGE_PIN J13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][10]  }]
# set_property -dict { PACKAGE_PIN H13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][8]   }]
# set_property -dict { PACKAGE_PIN K16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][15]  }]
# set_property -dict { PACKAGE_PIN K15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][13]  }]
# set_property -dict { PACKAGE_PIN L13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][1]   }]

# # DDR[3].BYTE[0]
# set_property -dict { PACKAGE_PIN N16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][7]   }]
# set_property -dict { PACKAGE_PIN M16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][4]   }]
# set_property -dict { PACKAGE_PIN M14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][5]   }]
# set_property -dict { PACKAGE_PIN L14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][3]   }]
# set_property -dict { PACKAGE_PIN R16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][0] }]
# set_property -dict { PACKAGE_PIN P16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][0] }]
# set_property -dict { PACKAGE_PIN R15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][6]   }]
# set_property -dict { PACKAGE_PIN P15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][1]   }]
# set_property -dict { PACKAGE_PIN P14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][2]   }]
# set_property -dict { PACKAGE_PIN N14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][0]   }]
# set_property -dict { PACKAGE_PIN P13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][0]   }]

# # DDR[3].ADDR
# set_property -dict { PACKAGE_PIN B20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][14] }]; # WE_B
# set_property -dict { PACKAGE_PIN A20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][0]  }]
# set_property -dict { PACKAGE_PIN A18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][2]  }]
# set_property -dict { PACKAGE_PIN B19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][8]  }]
# set_property -dict { PACKAGE_PIN A19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][10] }]
# set_property -dict { PACKAGE_PIN D18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][16] }]; # RAS_B
# set_property -dict { PACKAGE_PIN C18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][11] }]
# set_property -dict { PACKAGE_PIN C21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][15] }]; # CAS_B
# set_property -dict { PACKAGE_PIN B21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][13] }]
# set_property -dict { PACKAGE_PIN D21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][9]  }]
# set_property -dict { PACKAGE_PIN D20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][3]  }]
# set_property -dict { PACKAGE_PIN D19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][12] }]
# set_property -dict { PACKAGE_PIN C19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][7]  }]
# set_property -dict { PACKAGE_PIN F18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][4]  }]
# set_property -dict { PACKAGE_PIN F17 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][1]  }]
# set_property -dict { PACKAGE_PIN E21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][6]  }]
# set_property -dict { PACKAGE_PIN E20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][5]  }]

# # DDR[3].CTRL
# set_property -dict { PACKAGE_PIN H19 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[3]         }]
# set_property -dict { PACKAGE_PIN H18 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[3]         }]
# set_property -dict { PACKAGE_PIN E18 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[3][ckT][0] }]
# set_property -dict { PACKAGE_PIN E17 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[3][ckC][0] }]
# set_property -dict { PACKAGE_PIN F20 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][bg][0]  }]
# set_property -dict { PACKAGE_PIN F19 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][actL]   }]
# set_property -dict { PACKAGE_PIN G20 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][ba][0]  }]
# set_property -dict { PACKAGE_PIN G19 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][ba][1]  }]
# set_property -dict { PACKAGE_PIN K21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][cke][0] }]
# set_property -dict { PACKAGE_PIN K17 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][odt][0] }]
# set_property -dict { PACKAGE_PIN N21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][csL][0] }]; # TOP
# set_property -dict { PACKAGE_PIN M21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][csL][1] }]; # BOT
# set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports { ddrOut[3][rstL]   }]

##########
# Clocks #
##########

create_clock -period  3.333 -name ddrClkP3  [get_ports {ddrClkP[3]}]
# create_generated_clock   -name ddrIntClk03  [get_pins {U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk13  [get_pins {U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
