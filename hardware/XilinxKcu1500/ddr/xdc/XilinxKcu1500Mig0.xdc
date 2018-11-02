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
# DDR[0]: Constraints #
#######################

# # DDR[0].BYTE[8]
# set_property -dict { PACKAGE_PIN BA35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][64]  }]
# set_property -dict { PACKAGE_PIN BB35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][65]  }]
# set_property -dict { PACKAGE_PIN BB36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][66]  }]
# set_property -dict { PACKAGE_PIN BC36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][67]  }]
# set_property -dict { PACKAGE_PIN BB37 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][8] }]
# set_property -dict { PACKAGE_PIN BC37 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][8] }]
# set_property -dict { PACKAGE_PIN BD36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][68]  }]
# set_property -dict { PACKAGE_PIN BE36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][69]  }]
# set_property -dict { PACKAGE_PIN BD35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][70]  }]
# set_property -dict { PACKAGE_PIN BE35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][71]  }]
# set_property -dict { PACKAGE_PIN BC34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][8]   }]

# # DDR[0].BYTE[7]
# set_property -dict { PACKAGE_PIN W33  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][56]  }]
# set_property -dict { PACKAGE_PIN W34  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][63]  }]
# set_property -dict { PACKAGE_PIN Y32  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][57]  }]
# set_property -dict { PACKAGE_PIN Y33  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][58]  }]
# set_property -dict { PACKAGE_PIN W31  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][7] }]
# set_property -dict { PACKAGE_PIN Y31  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][7] }]
# set_property -dict { PACKAGE_PIN W30  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][60]  }]
# set_property -dict { PACKAGE_PIN Y30  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][61]  }]
# set_property -dict { PACKAGE_PIN AA34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][59]  }]
# set_property -dict { PACKAGE_PIN AB34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][62]  }]
# set_property -dict { PACKAGE_PIN AA32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][7]   }]

# # DDR[0].BYTE[6]
# set_property -dict { PACKAGE_PIN AC34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][51]  }]
# set_property -dict { PACKAGE_PIN AD34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][50]  }]
# set_property -dict { PACKAGE_PIN AC32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][48]  }]
# set_property -dict { PACKAGE_PIN AC33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][52]  }]
# set_property -dict { PACKAGE_PIN AC31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][6] }]
# set_property -dict { PACKAGE_PIN AD31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][6] }]
# set_property -dict { PACKAGE_PIN AE30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][53]  }]
# set_property -dict { PACKAGE_PIN AF30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][49]  }]
# set_property -dict { PACKAGE_PIN AD33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][54]  }]
# set_property -dict { PACKAGE_PIN AE33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][55]  }]
# set_property -dict { PACKAGE_PIN AE31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][6]   }]

# # DDR[0].BYTE[5]
# set_property -dict { PACKAGE_PIN AF32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][47]  }]
# set_property -dict { PACKAGE_PIN AF33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][42]  }]
# set_property -dict { PACKAGE_PIN AG31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][44]  }]
# set_property -dict { PACKAGE_PIN AG32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][45]  }]
# set_property -dict { PACKAGE_PIN AH31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][5] }]
# set_property -dict { PACKAGE_PIN AH32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][5] }]
# set_property -dict { PACKAGE_PIN AF34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][46]  }]
# set_property -dict { PACKAGE_PIN AG34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][43]  }]
# set_property -dict { PACKAGE_PIN AH33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][40]  }]
# set_property -dict { PACKAGE_PIN AJ33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][41]  }]
# set_property -dict { PACKAGE_PIN AH34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][5]   }]


# # DDR[0].BYTE[4]
# set_property -dict { PACKAGE_PIN AJ31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][33]  }]
# set_property -dict { PACKAGE_PIN AK31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][38]  }]
# set_property -dict { PACKAGE_PIN AG29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][37]  }]
# set_property -dict { PACKAGE_PIN AG30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][35]  }]
# set_property -dict { PACKAGE_PIN AH28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][4] }]
# set_property -dict { PACKAGE_PIN AH29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][4] }]
# set_property -dict { PACKAGE_PIN AJ29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][34]  }]
# set_property -dict { PACKAGE_PIN AJ30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][39]  }]
# set_property -dict { PACKAGE_PIN AJ28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][36]  }]
# set_property -dict { PACKAGE_PIN AK28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][32]  }]
# set_property -dict { PACKAGE_PIN AJ27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][4]   }]

# # DDR[0].BYTE[3]
# set_property -dict { PACKAGE_PIN AL29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][29]  }]
# set_property -dict { PACKAGE_PIN AL30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][31]  }]
# set_property -dict { PACKAGE_PIN AM31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][30]  }]
# set_property -dict { PACKAGE_PIN AN31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][28]  }]
# set_property -dict { PACKAGE_PIN AM29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][3] }]
# set_property -dict { PACKAGE_PIN AM30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][3] }]
# set_property -dict { PACKAGE_PIN AN29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][24]  }]
# set_property -dict { PACKAGE_PIN AP29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][26]  }]
# set_property -dict { PACKAGE_PIN AP30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][27]  }]
# set_property -dict { PACKAGE_PIN AR30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][25]  }]
# set_property -dict { PACKAGE_PIN AP31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][3]   }]

# # DDR[0].BYTE[2]
# set_property -dict { PACKAGE_PIN AT29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][20]  }]
# set_property -dict { PACKAGE_PIN AT30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][17]  }]
# set_property -dict { PACKAGE_PIN AU30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][16]  }]
# set_property -dict { PACKAGE_PIN AU31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][21]  }]
# set_property -dict { PACKAGE_PIN AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][2] }]
# set_property -dict { PACKAGE_PIN AV29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][2] }]
# set_property -dict { PACKAGE_PIN AU32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][19]  }]
# set_property -dict { PACKAGE_PIN AV32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][23]  }]
# set_property -dict { PACKAGE_PIN AV31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][18]  }]
# set_property -dict { PACKAGE_PIN AW31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][22]  }]
# set_property -dict { PACKAGE_PIN AW29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][2]   }]

# # DDR[0].BYTE[1]
# set_property -dict { PACKAGE_PIN AY31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][14]  }]
# set_property -dict { PACKAGE_PIN AY32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][9]   }]
# set_property -dict { PACKAGE_PIN AY30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][11]  }]
# set_property -dict { PACKAGE_PIN BA30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][12]  }]
# set_property -dict { PACKAGE_PIN BA32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][1] }]
# set_property -dict { PACKAGE_PIN BB32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][1] }]
# set_property -dict { PACKAGE_PIN BA29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][10]  }]
# set_property -dict { PACKAGE_PIN BB29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][8]   }]
# set_property -dict { PACKAGE_PIN BB30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][15]  }]
# set_property -dict { PACKAGE_PIN BB31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][13]  }]
# set_property -dict { PACKAGE_PIN BC31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][1]   }]

# # DDR[0].BYTE[0]
# set_property -dict { PACKAGE_PIN BC29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][7]   }]
# set_property -dict { PACKAGE_PIN BD29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][4]   }]
# set_property -dict { PACKAGE_PIN BD33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][5]   }]
# set_property -dict { PACKAGE_PIN BE33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][3]   }]
# set_property -dict { PACKAGE_PIN BD30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][0] }]
# set_property -dict { PACKAGE_PIN BD31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][0] }]
# set_property -dict { PACKAGE_PIN BE30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][6]   }]
# set_property -dict { PACKAGE_PIN BF30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][1]   }]
# set_property -dict { PACKAGE_PIN BE31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][2]   }]
# set_property -dict { PACKAGE_PIN BE32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][0]   }]
# set_property -dict { PACKAGE_PIN BF32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][0]   }]

# # DDR[0].ADDR
# set_property -dict { PACKAGE_PIN AL34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][14] }]; # WE_B
# set_property -dict { PACKAGE_PIN AM34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][0]  }]
# set_property -dict { PACKAGE_PIN AL33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][2]  }]
# set_property -dict { PACKAGE_PIN AL32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][8]  }]
# set_property -dict { PACKAGE_PIN AM32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][10] }]
# set_property -dict { PACKAGE_PIN AN32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][16] }]; # RAS_B
# set_property -dict { PACKAGE_PIN AN33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][11] }]
# set_property -dict { PACKAGE_PIN AN34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][15] }]; # CAS_B
# set_property -dict { PACKAGE_PIN AP34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][13] }]
# set_property -dict { PACKAGE_PIN AP33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][9]  }]
# set_property -dict { PACKAGE_PIN AR33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][3]  }]
# set_property -dict { PACKAGE_PIN AT33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][12] }]
# set_property -dict { PACKAGE_PIN AT34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][7]  }]
# set_property -dict { PACKAGE_PIN AV33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][4]  }]
# set_property -dict { PACKAGE_PIN AW33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][1]  }]
# set_property -dict { PACKAGE_PIN AV34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][6]  }]
# set_property -dict { PACKAGE_PIN AW34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][5]  }]

# # DDR[0].CTRL
# set_property -dict { PACKAGE_PIN BA34 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[0]         }]
# set_property -dict { PACKAGE_PIN BB34 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[0]         }]
# set_property -dict { PACKAGE_PIN AW35 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[0][ckT][0] }]
# set_property -dict { PACKAGE_PIN AW36 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[0][ckC][0] }]
# set_property -dict { PACKAGE_PIN AY33 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][bg][0]  }]
# set_property -dict { PACKAGE_PIN BA33 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][actL]   }]
# set_property -dict { PACKAGE_PIN AY35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][ba][0]  }]
# set_property -dict { PACKAGE_PIN AY36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][ba][1]  }]
# set_property -dict { PACKAGE_PIN BF35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][cke][0] }]
# set_property -dict { PACKAGE_PIN BD34 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][odt][0] }]
# set_property -dict { PACKAGE_PIN BB38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][csL][0] }]; # TOP
# set_property -dict { PACKAGE_PIN BC38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][csL][1] }]; # BOT
# set_property -dict { PACKAGE_PIN AJ34 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports { ddrOut[0][rstL]   }]

##########
# Clocks #
##########

create_clock -period  3.333 -name ddrClkP0  [get_ports {ddrClkP[0]}]
# create_generated_clock   -name ddrIntClk00  [get_pins {U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk10  [get_pins {U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
