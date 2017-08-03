##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

######################
# FLASH: Constraints #
######################
set_property LOC CONFIG_SITE_X0Y0 [get_cells {U_Core/U_STARTUPE3}]

set_property -dict { PACKAGE_PIN BF27 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]
set_property -dict { PACKAGE_PIN AM26 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }]
set_property -dict { PACKAGE_PIN AN26 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }]
set_property -dict { PACKAGE_PIN AM25 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]
set_property -dict { PACKAGE_PIN AL25 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]

#######################
# DDR[0]: Constraints #
#######################

# DDR[0].BYTE[8]
set_property -dict { PACKAGE_PIN BA35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][64]  }]
set_property -dict { PACKAGE_PIN BB35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][65]  }]
set_property -dict { PACKAGE_PIN BB36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][66]  }]
set_property -dict { PACKAGE_PIN BC36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][67]  }]
set_property -dict { PACKAGE_PIN BB37 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][8] }]
set_property -dict { PACKAGE_PIN BC37 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][8] }]
set_property -dict { PACKAGE_PIN BD36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][68]  }]
set_property -dict { PACKAGE_PIN BE36 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][69]  }]
set_property -dict { PACKAGE_PIN BD35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][70]  }]
set_property -dict { PACKAGE_PIN BE35 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][71]  }]
set_property -dict { PACKAGE_PIN BC34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][8]   }]

# DDR[0].BYTE[7]
set_property -dict { PACKAGE_PIN W33  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][56]  }]
set_property -dict { PACKAGE_PIN W34  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][63]  }]
set_property -dict { PACKAGE_PIN Y32  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][57]  }]
set_property -dict { PACKAGE_PIN Y33  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][58]  }]
set_property -dict { PACKAGE_PIN W31  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][7] }]
set_property -dict { PACKAGE_PIN Y31  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][7] }]
set_property -dict { PACKAGE_PIN W30  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][60]  }]
set_property -dict { PACKAGE_PIN Y30  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][61]  }]
set_property -dict { PACKAGE_PIN AA34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][59]  }]
set_property -dict { PACKAGE_PIN AB34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][62]  }]
set_property -dict { PACKAGE_PIN AA32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][7]   }]

# DDR[0].BYTE[6]
set_property -dict { PACKAGE_PIN AC34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][51]  }]
set_property -dict { PACKAGE_PIN AD34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][50]  }]
set_property -dict { PACKAGE_PIN AC32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][48]  }]
set_property -dict { PACKAGE_PIN AC33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][52]  }]
set_property -dict { PACKAGE_PIN AC31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][6] }]
set_property -dict { PACKAGE_PIN AD31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][6] }]
set_property -dict { PACKAGE_PIN AE30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][53]  }]
set_property -dict { PACKAGE_PIN AF30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][49]  }]
set_property -dict { PACKAGE_PIN AD33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][54]  }]
set_property -dict { PACKAGE_PIN AE33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][55]  }]
set_property -dict { PACKAGE_PIN AE31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][6]   }]

# DDR[0].BYTE[5]
set_property -dict { PACKAGE_PIN AF32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][47]  }]
set_property -dict { PACKAGE_PIN AF33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][42]  }]
set_property -dict { PACKAGE_PIN AG31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][44]  }]
set_property -dict { PACKAGE_PIN AG32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][45]  }]
set_property -dict { PACKAGE_PIN AH31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][5] }]
set_property -dict { PACKAGE_PIN AH32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][5] }]
set_property -dict { PACKAGE_PIN AF34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][46]  }]
set_property -dict { PACKAGE_PIN AG34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][43]  }]
set_property -dict { PACKAGE_PIN AH33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][40]  }]
set_property -dict { PACKAGE_PIN AJ33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][41]  }]
set_property -dict { PACKAGE_PIN AH34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][5]   }]


# DDR[0].BYTE[4]
set_property -dict { PACKAGE_PIN AJ31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][33]  }]
set_property -dict { PACKAGE_PIN AK31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][38]  }]
set_property -dict { PACKAGE_PIN AG29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][37]  }]
set_property -dict { PACKAGE_PIN AG30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][35]  }]
set_property -dict { PACKAGE_PIN AH28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][4] }]
set_property -dict { PACKAGE_PIN AH29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][4] }]
set_property -dict { PACKAGE_PIN AJ29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][34]  }]
set_property -dict { PACKAGE_PIN AJ30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][39]  }]
set_property -dict { PACKAGE_PIN AJ28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][36]  }]
set_property -dict { PACKAGE_PIN AK28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][32]  }]
set_property -dict { PACKAGE_PIN AJ27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][4]   }]

# DDR[0].BYTE[3]
set_property -dict { PACKAGE_PIN AL29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][29]  }]
set_property -dict { PACKAGE_PIN AL30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][31]  }]
set_property -dict { PACKAGE_PIN AM31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][30]  }]
set_property -dict { PACKAGE_PIN AN31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][28]  }]
set_property -dict { PACKAGE_PIN AM29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][3] }]
set_property -dict { PACKAGE_PIN AM30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][3] }]
set_property -dict { PACKAGE_PIN AN29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][24]  }]
set_property -dict { PACKAGE_PIN AP29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][26]  }]
set_property -dict { PACKAGE_PIN AP30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][27]  }]
set_property -dict { PACKAGE_PIN AR30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][25]  }]
set_property -dict { PACKAGE_PIN AP31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][3]   }]

# DDR[0].BYTE[2]
set_property -dict { PACKAGE_PIN AT29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][20]  }]
set_property -dict { PACKAGE_PIN AT30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][17]  }]
set_property -dict { PACKAGE_PIN AU30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][16]  }]
set_property -dict { PACKAGE_PIN AU31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][21]  }]
set_property -dict { PACKAGE_PIN AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][2] }]
set_property -dict { PACKAGE_PIN AV29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][2] }]
set_property -dict { PACKAGE_PIN AU32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][19]  }]
set_property -dict { PACKAGE_PIN AV32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][23]  }]
set_property -dict { PACKAGE_PIN AV31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][18]  }]
set_property -dict { PACKAGE_PIN AW31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][22]  }]
set_property -dict { PACKAGE_PIN AW29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][2]   }]

# DDR[0].BYTE[1]
set_property -dict { PACKAGE_PIN AY31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][14]  }]
set_property -dict { PACKAGE_PIN AY32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][9]   }]
set_property -dict { PACKAGE_PIN AY30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][11]  }]
set_property -dict { PACKAGE_PIN BA30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][12]  }]
set_property -dict { PACKAGE_PIN BA32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][1] }]
set_property -dict { PACKAGE_PIN BB32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][1] }]
set_property -dict { PACKAGE_PIN BA29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][10]  }]
set_property -dict { PACKAGE_PIN BB29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][8]   }]
set_property -dict { PACKAGE_PIN BB30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][15]  }]
set_property -dict { PACKAGE_PIN BB31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][13]  }]
set_property -dict { PACKAGE_PIN BC31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][1]   }]

# DDR[0].BYTE[0]
set_property -dict { PACKAGE_PIN BC29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][7]   }]
set_property -dict { PACKAGE_PIN BD29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][4]   }]
set_property -dict { PACKAGE_PIN BD33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][5]   }]
set_property -dict { PACKAGE_PIN BE33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][3]   }]
set_property -dict { PACKAGE_PIN BD30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsT][0] }]
set_property -dict { PACKAGE_PIN BD31 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[0][dqsC][0] }]
set_property -dict { PACKAGE_PIN BE30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][6]   }]
set_property -dict { PACKAGE_PIN BF30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][1]   }]
set_property -dict { PACKAGE_PIN BE31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][2]   }]
set_property -dict { PACKAGE_PIN BE32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dq][0]   }]
set_property -dict { PACKAGE_PIN BF32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[0][dm][0]   }]

# DDR[0].ADDR
set_property -dict { PACKAGE_PIN AL34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][14] }]; # WE_B
set_property -dict { PACKAGE_PIN AM34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][0]  }]
set_property -dict { PACKAGE_PIN AL33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][2]  }]
set_property -dict { PACKAGE_PIN AL32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][8]  }]
set_property -dict { PACKAGE_PIN AM32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][10] }]
set_property -dict { PACKAGE_PIN AN32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][16] }]; # RAS_B
set_property -dict { PACKAGE_PIN AN33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][11] }]
set_property -dict { PACKAGE_PIN AN34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][15] }]; # CAS_B
set_property -dict { PACKAGE_PIN AP34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][13] }]
set_property -dict { PACKAGE_PIN AP33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][9]  }]
set_property -dict { PACKAGE_PIN AR33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][3]  }]
set_property -dict { PACKAGE_PIN AT33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][12] }]
set_property -dict { PACKAGE_PIN AT34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][7]  }]
set_property -dict { PACKAGE_PIN AV33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][4]  }]
set_property -dict { PACKAGE_PIN AW33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][1]  }]
set_property -dict { PACKAGE_PIN AV34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][6]  }]
set_property -dict { PACKAGE_PIN AW34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[0][addr][5]  }]

# DDR[0].CTRL
set_property -dict { PACKAGE_PIN BA34 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[0]         }]
set_property -dict { PACKAGE_PIN BB34 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[0]         }]
set_property -dict { PACKAGE_PIN AW35 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[0][ckT][0] }]
set_property -dict { PACKAGE_PIN AW36 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[0][ckC][0] }]
set_property -dict { PACKAGE_PIN AY33 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][bg][0]  }]
set_property -dict { PACKAGE_PIN BA33 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][actL]   }]
set_property -dict { PACKAGE_PIN AY35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][ba][0]  }]
set_property -dict { PACKAGE_PIN AY36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][ba][1]  }]
set_property -dict { PACKAGE_PIN BF35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][cke][0] }]
set_property -dict { PACKAGE_PIN BD34 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][odt][0] }]
set_property -dict { PACKAGE_PIN BB38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][csL][0] }]; # TOP
set_property -dict { PACKAGE_PIN BC38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[0][csL][1] }]; # BOT
set_property -dict { PACKAGE_PIN AJ34 IOSTANDARD LVCMOS12         } [get_ports { ddrOut[0][rstL]   }]

#######################
# DDR[1]: Constraints #
#######################

# DDR[0].BYTE[8] (Note: NON-ECC DDR does not have BYTE[8])
set_property -dict { PACKAGE_PIN AP16 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][64]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AN17 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][65]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AU21 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][66]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN BA17 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][67]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN BF17 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dqsT][8] }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN BD11 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dqsC][8] }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN BC11 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][68]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AB32 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][69]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AA33 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][70]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AD30 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dq][71]  }]; # Mapped to unused I/O
set_property -dict { PACKAGE_PIN AK32 IOSTANDARD LVCMOS12 DRIVE 2 PULLTYPE PULLUP } [get_ports { ddrInOut[1][dm][8]   }]; # Mapped to unused I/O

# DDR[1].BYTE[7]
set_property -dict { PACKAGE_PIN BA9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][56]  }]
set_property -dict { PACKAGE_PIN BA8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][63]  }]
set_property -dict { PACKAGE_PIN BB9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][57]  }]
set_property -dict { PACKAGE_PIN BC9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][58]  }]
set_property -dict { PACKAGE_PIN BA7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][7] }]
set_property -dict { PACKAGE_PIN BB7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][7] }]
set_property -dict { PACKAGE_PIN BC8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][60]  }]
set_property -dict { PACKAGE_PIN BC7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][61]  }]
set_property -dict { PACKAGE_PIN BB11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][59]  }]
set_property -dict { PACKAGE_PIN BB10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][62]  }]
set_property -dict { PACKAGE_PIN BC12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][7]   }]

# DDR[1].BYTE[6]
set_property -dict { PACKAGE_PIN BD9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][51]  }]
set_property -dict { PACKAGE_PIN BD8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][50]  }]
set_property -dict { PACKAGE_PIN BE12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][48]  }]
set_property -dict { PACKAGE_PIN BF12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][52]  }]
set_property -dict { PACKAGE_PIN BE11 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][6] }]
set_property -dict { PACKAGE_PIN BE10 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][6] }]
set_property -dict { PACKAGE_PIN BF10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][53]  }]
set_property -dict { PACKAGE_PIN BF9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][49]  }]
set_property -dict { PACKAGE_PIN BE8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][54]  }]
set_property -dict { PACKAGE_PIN BF8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][55]  }]
set_property -dict { PACKAGE_PIN BE7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][6]   }]

# DDR[1].BYTE[5]
set_property -dict { PACKAGE_PIN AY13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][47]  }]
set_property -dict { PACKAGE_PIN BA13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][42]  }]
set_property -dict { PACKAGE_PIN BA15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][44]  }]
set_property -dict { PACKAGE_PIN BA14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][45]  }]
set_property -dict { PACKAGE_PIN BB15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][5] }]
set_property -dict { PACKAGE_PIN BB14 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][5] }]
set_property -dict { PACKAGE_PIN AY16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][46]  }]
set_property -dict { PACKAGE_PIN AY15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][43]  }]
set_property -dict { PACKAGE_PIN AY12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][40]  }]
set_property -dict { PACKAGE_PIN AY11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][41]  }]
set_property -dict { PACKAGE_PIN BA12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][5]   }]

# DDR[1].BYTE[4]
set_property -dict { PACKAGE_PIN BC14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][33]  }]
set_property -dict { PACKAGE_PIN BC13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][38]  }]
set_property -dict { PACKAGE_PIN BD15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][37]  }]
set_property -dict { PACKAGE_PIN BD14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][35]  }]
set_property -dict { PACKAGE_PIN BD13 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][4] }]
set_property -dict { PACKAGE_PIN BE13 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][4] }]
set_property -dict { PACKAGE_PIN BD16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][34]  }]
set_property -dict { PACKAGE_PIN BE16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][39]  }]
set_property -dict { PACKAGE_PIN BE15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][36]  }]
set_property -dict { PACKAGE_PIN BF15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][32]  }]
set_property -dict { PACKAGE_PIN BF14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][4]   }]

# DDR[1].BYTE[3]
set_property -dict { PACKAGE_PIN AL20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][29]  }]
set_property -dict { PACKAGE_PIN AM20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][31]  }]
set_property -dict { PACKAGE_PIN AL19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][30]  }]
set_property -dict { PACKAGE_PIN AM19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][28]  }]
set_property -dict { PACKAGE_PIN AL17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][3] }]
set_property -dict { PACKAGE_PIN AM17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][3] }]
set_property -dict { PACKAGE_PIN AM16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][24]  }]
set_property -dict { PACKAGE_PIN AN16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][26]  }]
set_property -dict { PACKAGE_PIN AN19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][27]  }]
set_property -dict { PACKAGE_PIN AP19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][25]  }]
set_property -dict { PACKAGE_PIN AN18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][3]   }]

# DDR[1].BYTE[2]
set_property -dict { PACKAGE_PIN AP20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][20]  }]
set_property -dict { PACKAGE_PIN AR20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][17]  }]
set_property -dict { PACKAGE_PIN AP18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][16]  }]
set_property -dict { PACKAGE_PIN AR18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][21]  }]
set_property -dict { PACKAGE_PIN AR17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][2] }]
set_property -dict { PACKAGE_PIN AT17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][2] }]
set_property -dict { PACKAGE_PIN AT18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][19]  }]
set_property -dict { PACKAGE_PIN AU17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][23]  }]
set_property -dict { PACKAGE_PIN AT20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][18]  }]
set_property -dict { PACKAGE_PIN AU20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][22]  }]
set_property -dict { PACKAGE_PIN AT19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][2]   }]

# DDR[1].BYTE[1]
set_property -dict { PACKAGE_PIN AV19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][14]  }]
set_property -dict { PACKAGE_PIN AW19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][9]   }]
set_property -dict { PACKAGE_PIN AV18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][11]  }]
set_property -dict { PACKAGE_PIN AW18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][12]  }]
set_property -dict { PACKAGE_PIN AV21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][1] }]
set_property -dict { PACKAGE_PIN AW21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][1] }]
set_property -dict { PACKAGE_PIN AW20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][10]  }]
set_property -dict { PACKAGE_PIN AY20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][8]   }]
set_property -dict { PACKAGE_PIN AY18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][15]  }]
set_property -dict { PACKAGE_PIN BA18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][13]  }]
set_property -dict { PACKAGE_PIN AY17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][1]   }]

# DDR[1].BYTE[0]
set_property -dict { PACKAGE_PIN BB19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][7]   }]
set_property -dict { PACKAGE_PIN BC18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][4]   }]
set_property -dict { PACKAGE_PIN BB17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][5]   }]
set_property -dict { PACKAGE_PIN BC17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][3]   }]
set_property -dict { PACKAGE_PIN BC19 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][0] }]
set_property -dict { PACKAGE_PIN BD19 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][0] }]
set_property -dict { PACKAGE_PIN BD18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][6]   }]
set_property -dict { PACKAGE_PIN BE18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][1]   }]
set_property -dict { PACKAGE_PIN BF19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][2]   }]
set_property -dict { PACKAGE_PIN BF18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][0]   }]
set_property -dict { PACKAGE_PIN BE17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][0]   }]

# DDR[1].ADDR
set_property -dict { PACKAGE_PIN AL14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][14] }]; # WE_B
set_property -dict { PACKAGE_PIN AM14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][0]  }]
set_property -dict { PACKAGE_PIN AT13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][2]  }]
set_property -dict { PACKAGE_PIN AL15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][8]  }]
set_property -dict { PACKAGE_PIN AM15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][10] }]
set_property -dict { PACKAGE_PIN AP13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][16] }]; # RAS_B
set_property -dict { PACKAGE_PIN AR13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][11] }]
set_property -dict { PACKAGE_PIN AN14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][15] }]; # CAS_B
set_property -dict { PACKAGE_PIN AN13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][13] }]
set_property -dict { PACKAGE_PIN AP15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][9]  }]
set_property -dict { PACKAGE_PIN AP14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][3]  }]
set_property -dict { PACKAGE_PIN AR16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][12] }]
set_property -dict { PACKAGE_PIN AR15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][7]  }]
set_property -dict { PACKAGE_PIN AU16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][4]  }]
set_property -dict { PACKAGE_PIN AV16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][1]  }]
set_property -dict { PACKAGE_PIN AT15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][6]  }]
set_property -dict { PACKAGE_PIN AU15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][5]  }]

# DDR[1].CTRL
set_property -dict { PACKAGE_PIN AW14 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[1]         }]
set_property -dict { PACKAGE_PIN AW13 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[1]         }]
set_property -dict { PACKAGE_PIN AU14 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[1][ckT][0] }]
set_property -dict { PACKAGE_PIN AV14 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[1][ckC][0] }]
set_property -dict { PACKAGE_PIN AU13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][bg][0]  }]
set_property -dict { PACKAGE_PIN AV13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][actL]   }]
set_property -dict { PACKAGE_PIN AW16 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][ba][0]  }]
set_property -dict { PACKAGE_PIN AW15 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][ba][1]  }]
set_property -dict { PACKAGE_PIN AT14 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][cke][0] }]
set_property -dict { PACKAGE_PIN BB16 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][odt][0] }]
set_property -dict { PACKAGE_PIN BB12 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][csL][0] }]; # TOP
set_property -dict { PACKAGE_PIN BF13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][csL][1] }]; # BOT
set_property -dict { PACKAGE_PIN AU19 IOSTANDARD LVCMOS12         } [get_ports { ddrOut[1][rstL]   }]

#######################
# DDR[2]: Constraints #
#######################

# DDR[2].BYTE[8]
set_property -dict { PACKAGE_PIN C38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][64]  }]
set_property -dict { PACKAGE_PIN C39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][65]  }]
set_property -dict { PACKAGE_PIN E38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][66]  }]
set_property -dict { PACKAGE_PIN D38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][67]  }]
set_property -dict { PACKAGE_PIN B39 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][8] }]
set_property -dict { PACKAGE_PIN A39 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][8] }]
set_property -dict { PACKAGE_PIN B40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][68]  }]
set_property -dict { PACKAGE_PIN A40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][69]  }]
set_property -dict { PACKAGE_PIN E39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][70]  }]
set_property -dict { PACKAGE_PIN D39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][71]  }]
set_property -dict { PACKAGE_PIN E40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][8]   }]

# DDR[2].BYTE[7]
set_property -dict { PACKAGE_PIN B30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][56]  }]
set_property -dict { PACKAGE_PIN A30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][63]  }]
set_property -dict { PACKAGE_PIN B29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][57]  }]
set_property -dict { PACKAGE_PIN A29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][58]  }]
set_property -dict { PACKAGE_PIN A27 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][7] }]
set_property -dict { PACKAGE_PIN A28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][7] }]
set_property -dict { PACKAGE_PIN E30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][60]  }]
set_property -dict { PACKAGE_PIN D30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][61]  }]
set_property -dict { PACKAGE_PIN D29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][59]  }]
set_property -dict { PACKAGE_PIN C29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][62]  }]
set_property -dict { PACKAGE_PIN C27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][7]   }]

# DDR[2].BYTE[6]
set_property -dict { PACKAGE_PIN E28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][51]  }]
set_property -dict { PACKAGE_PIN D28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][50]  }]
set_property -dict { PACKAGE_PIN F27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][48]  }]
set_property -dict { PACKAGE_PIN E27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][52]  }]
set_property -dict { PACKAGE_PIN F28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][6] }]
set_property -dict { PACKAGE_PIN F29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][6] }]
set_property -dict { PACKAGE_PIN H29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][53]  }]
set_property -dict { PACKAGE_PIN G29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][49]  }]
set_property -dict { PACKAGE_PIN G26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][54]  }]
set_property -dict { PACKAGE_PIN G27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][55]  }]
set_property -dict { PACKAGE_PIN J26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][6]   }]

# DDR[2].BYTE[5]
set_property -dict { PACKAGE_PIN J28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][47]  }]
set_property -dict { PACKAGE_PIN J29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][42]  }]
set_property -dict { PACKAGE_PIN H27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][44]  }]
set_property -dict { PACKAGE_PIN H28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][45]  }]
set_property -dict { PACKAGE_PIN K26 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][5] }]
set_property -dict { PACKAGE_PIN K27 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][5] }]
set_property -dict { PACKAGE_PIN M27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][46]  }]
set_property -dict { PACKAGE_PIN L27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][43]  }]
set_property -dict { PACKAGE_PIN L28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][40]  }]
set_property -dict { PACKAGE_PIN K28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][41]  }]
set_property -dict { PACKAGE_PIN M29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][5]   }]

# DDR[2].BYTE[4]
set_property -dict { PACKAGE_PIN P26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][33]  }]
set_property -dict { PACKAGE_PIN N26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][38]  }]
set_property -dict { PACKAGE_PIN P28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][37]  }]
set_property -dict { PACKAGE_PIN N28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][35]  }]
set_property -dict { PACKAGE_PIN P29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][4] }]
set_property -dict { PACKAGE_PIN N29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][4] }]
set_property -dict { PACKAGE_PIN T26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][34]  }]
set_property -dict { PACKAGE_PIN R26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][39]  }]
set_property -dict { PACKAGE_PIN T27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][36]  }]
set_property -dict { PACKAGE_PIN R27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][32]  }]
set_property -dict { PACKAGE_PIN T28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][4]   }]

# DDR[2].BYTE[3]
set_property -dict { PACKAGE_PIN F33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][29]  }]
set_property -dict { PACKAGE_PIN E33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][31]  }]
set_property -dict { PACKAGE_PIN F32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][30]  }]
set_property -dict { PACKAGE_PIN E32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][28]  }]
set_property -dict { PACKAGE_PIN J33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][3] }]
set_property -dict { PACKAGE_PIN H33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][3] }]
set_property -dict { PACKAGE_PIN H32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][24]  }]
set_property -dict { PACKAGE_PIN G32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][26]  }]
set_property -dict { PACKAGE_PIN H31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][27]  }]
set_property -dict { PACKAGE_PIN G31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][25]  }]
set_property -dict { PACKAGE_PIN G30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][3]   }]

# DDR[2].BYTE[2]
set_property -dict { PACKAGE_PIN L33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][20]  }]
set_property -dict { PACKAGE_PIN K33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][17]  }]
set_property -dict { PACKAGE_PIN K31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][16]  }]
set_property -dict { PACKAGE_PIN J31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][21]  }]
set_property -dict { PACKAGE_PIN K30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][2] }]
set_property -dict { PACKAGE_PIN J30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][2] }]
set_property -dict { PACKAGE_PIN M30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][19]  }]
set_property -dict { PACKAGE_PIN L30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][23]  }]
set_property -dict { PACKAGE_PIN L32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][18]  }]
set_property -dict { PACKAGE_PIN K32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][22]  }]
set_property -dict { PACKAGE_PIN M31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][2]   }]

# DDR[2].BYTE[1]
set_property -dict { PACKAGE_PIN N32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][14]  }]
set_property -dict { PACKAGE_PIN N33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][9]   }]
set_property -dict { PACKAGE_PIN P31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][11]  }]
set_property -dict { PACKAGE_PIN N31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][12]  }]
set_property -dict { PACKAGE_PIN M34 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][1] }]
set_property -dict { PACKAGE_PIN L34 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][1] }]
set_property -dict { PACKAGE_PIN P34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][10]  }]
set_property -dict { PACKAGE_PIN N34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][8]   }]
set_property -dict { PACKAGE_PIN R31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][15]  }]
set_property -dict { PACKAGE_PIN R32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][13]  }]
set_property -dict { PACKAGE_PIN R30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][1]   }]

# DDR[2].BYTE[0]
set_property -dict { PACKAGE_PIN U30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][7]   }]
set_property -dict { PACKAGE_PIN T30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][4]   }]
set_property -dict { PACKAGE_PIN V31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][5]   }]
set_property -dict { PACKAGE_PIN U31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][3]   }]
set_property -dict { PACKAGE_PIN V32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][0] }]
set_property -dict { PACKAGE_PIN V33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][0] }]
set_property -dict { PACKAGE_PIN U32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][6]   }]
set_property -dict { PACKAGE_PIN T32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][1]   }]
set_property -dict { PACKAGE_PIN T33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][2]   }]
set_property -dict { PACKAGE_PIN R33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][0]   }]
set_property -dict { PACKAGE_PIN U34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][0]   }]

# DDR[2].ADDR
set_property -dict { PACKAGE_PIN D31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][14] }]; # WE_B
set_property -dict { PACKAGE_PIN C31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][0]  }]
set_property -dict { PACKAGE_PIN B31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][2]  }]
set_property -dict { PACKAGE_PIN C32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][8]  }]
set_property -dict { PACKAGE_PIN B32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][10] }]
set_property -dict { PACKAGE_PIN A32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][16] }]; # RAS_B
set_property -dict { PACKAGE_PIN A33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][11] }]
set_property -dict { PACKAGE_PIN D33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][15] }]; # CAS_B
set_property -dict { PACKAGE_PIN C33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][13] }]
set_property -dict { PACKAGE_PIN D34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][9]  }]
set_property -dict { PACKAGE_PIN C34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][3]  }]
set_property -dict { PACKAGE_PIN B34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][12] }]
set_property -dict { PACKAGE_PIN A34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][7]  }]
set_property -dict { PACKAGE_PIN E35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][4]  }]
set_property -dict { PACKAGE_PIN D35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][1]  }]
set_property -dict { PACKAGE_PIN B35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][6]  }]
set_property -dict { PACKAGE_PIN A35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][5]  }]

# DDR[2].CTRL
set_property -dict { PACKAGE_PIN C36 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[2]         }]
set_property -dict { PACKAGE_PIN C37 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[2]         }]
set_property -dict { PACKAGE_PIN B36 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[2][ckT][0] }]
set_property -dict { PACKAGE_PIN B37 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[2][ckC][0] }]
set_property -dict { PACKAGE_PIN A37 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][bg][0]  }]
set_property -dict { PACKAGE_PIN A38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][actL]   }]
set_property -dict { PACKAGE_PIN E36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][ba][0]  }]
set_property -dict { PACKAGE_PIN D36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][ba][1]  }]
set_property -dict { PACKAGE_PIN F38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][cke][0] }]
set_property -dict { PACKAGE_PIN D40 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][odt][0] }]
set_property -dict { PACKAGE_PIN F34 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][csL][0] }]; # TOP
set_property -dict { PACKAGE_PIN F35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][csL][1] }]; # BOT
set_property -dict { PACKAGE_PIN L29 IOSTANDARD LVCMOS12         } [get_ports { ddrOut[2][rstL]   }]

#######################
# DDR[3]: Constraints #
#######################

# DDR[3].BYTE[8]
set_property -dict { PACKAGE_PIN J20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][64]  }]
set_property -dict { PACKAGE_PIN J19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][65]  }]
set_property -dict { PACKAGE_PIN K18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][66]  }]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][67]  }]
set_property -dict { PACKAGE_PIN J21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][8] }]
set_property -dict { PACKAGE_PIN H21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][8] }]
set_property -dict { PACKAGE_PIN L20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][68]  }]
set_property -dict { PACKAGE_PIN K20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][69]  }]
set_property -dict { PACKAGE_PIN L19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][70]  }]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][71]  }]
set_property -dict { PACKAGE_PIN L17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][8]   }]

# DDR[3].BYTE[7]
set_property -dict { PACKAGE_PIN B25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][56]  }]
set_property -dict { PACKAGE_PIN A25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][63]  }]
set_property -dict { PACKAGE_PIN B24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][57]  }]
set_property -dict { PACKAGE_PIN A24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][58]  }]
set_property -dict { PACKAGE_PIN A23 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][7] }]
set_property -dict { PACKAGE_PIN A22 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][7] }]
set_property -dict { PACKAGE_PIN C26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][60]  }]
set_property -dict { PACKAGE_PIN B26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][61]  }]
set_property -dict { PACKAGE_PIN C24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][59]  }]
set_property -dict { PACKAGE_PIN C23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][62]  }]
set_property -dict { PACKAGE_PIN C22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][7]   }]

# DDR[3].BYTE[6]
set_property -dict { PACKAGE_PIN E25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][51]  }]
set_property -dict { PACKAGE_PIN D25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][50]  }]
set_property -dict { PACKAGE_PIN D24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][48]  }]
set_property -dict { PACKAGE_PIN D23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][52]  }]
set_property -dict { PACKAGE_PIN E23 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][6] }]
set_property -dict { PACKAGE_PIN E22 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][6] }]
set_property -dict { PACKAGE_PIN G22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][53]  }]
set_property -dict { PACKAGE_PIN F22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][49]  }]
set_property -dict { PACKAGE_PIN F24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][54]  }]
set_property -dict { PACKAGE_PIN F23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][55]  }]
set_property -dict { PACKAGE_PIN G25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][6]   }]

# DDR[3].BYTE[5]
set_property -dict { PACKAGE_PIN J24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][47]  }]
set_property -dict { PACKAGE_PIN H24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][42]  }]
set_property -dict { PACKAGE_PIN J23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][44]  }]
set_property -dict { PACKAGE_PIN H23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][45]  }]
set_property -dict { PACKAGE_PIN K25 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][5] }]
set_property -dict { PACKAGE_PIN J25 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][5] }]
set_property -dict { PACKAGE_PIN L23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][46]  }]
set_property -dict { PACKAGE_PIN K23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][43]  }]
set_property -dict { PACKAGE_PIN L22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][40]  }]
set_property -dict { PACKAGE_PIN K22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][41]  }]
set_property -dict { PACKAGE_PIN L25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][5]   }]

# DDR[3].BYTE[4]
set_property -dict { PACKAGE_PIN R25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][33]  }]
set_property -dict { PACKAGE_PIN P25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][38]  }]
set_property -dict { PACKAGE_PIN M25 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][37]  }]
set_property -dict { PACKAGE_PIN M24 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][35]  }]
set_property -dict { PACKAGE_PIN P24 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][4] }]
set_property -dict { PACKAGE_PIN N24 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][4] }]
set_property -dict { PACKAGE_PIN P23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][34]  }]
set_property -dict { PACKAGE_PIN N23 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][39]  }]
set_property -dict { PACKAGE_PIN N22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][36]  }]
set_property -dict { PACKAGE_PIN M22 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][32]  }]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][4]   }]

# DDR[3].BYTE[3]
set_property -dict { PACKAGE_PIN B17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][29]  }]
set_property -dict { PACKAGE_PIN A17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][31]  }]
set_property -dict { PACKAGE_PIN C16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][30]  }]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][28]  }]
set_property -dict { PACKAGE_PIN B15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][3] }]
set_property -dict { PACKAGE_PIN A15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][3] }]
set_property -dict { PACKAGE_PIN A14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][24]  }]
set_property -dict { PACKAGE_PIN A13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][26]  }]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][27]  }]
set_property -dict { PACKAGE_PIN B14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][25]  }]
set_property -dict { PACKAGE_PIN D13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][3]   }]

# DDR[3].BYTE[2]
set_property -dict { PACKAGE_PIN E16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][20]  }]
set_property -dict { PACKAGE_PIN D16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][17]  }]
set_property -dict { PACKAGE_PIN E15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][16]  }]
set_property -dict { PACKAGE_PIN D15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][21]  }]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][2] }]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][2] }]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][19]  }]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][23]  }]
set_property -dict { PACKAGE_PIN G15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][18]  }]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][22]  }]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][2]   }]

# DDR[3].BYTE[1]
set_property -dict { PACKAGE_PIN J16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][14]  }]
set_property -dict { PACKAGE_PIN J15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][9]   }]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][11]  }]
set_property -dict { PACKAGE_PIN H14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][12]  }]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][1] }]
set_property -dict { PACKAGE_PIN H16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][1] }]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][10]  }]
set_property -dict { PACKAGE_PIN H13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][8]   }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][15]  }]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][13]  }]
set_property -dict { PACKAGE_PIN L13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][1]   }]

# DDR[3].BYTE[0]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][7]   }]
set_property -dict { PACKAGE_PIN M16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][4]   }]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][5]   }]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][3]   }]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsT][0] }]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[3][dqsC][0] }]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][6]   }]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][1]   }]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][2]   }]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dq][0]   }]
set_property -dict { PACKAGE_PIN P13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[3][dm][0]   }]

# DDR[3].ADDR
set_property -dict { PACKAGE_PIN B20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][14] }]; # WE_B
set_property -dict { PACKAGE_PIN A20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][0]  }]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][2]  }]
set_property -dict { PACKAGE_PIN B19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][8]  }]
set_property -dict { PACKAGE_PIN A19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][10] }]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][16] }]; # RAS_B
set_property -dict { PACKAGE_PIN C18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][11] }]
set_property -dict { PACKAGE_PIN C21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][15] }]; # CAS_B
set_property -dict { PACKAGE_PIN B21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][13] }]
set_property -dict { PACKAGE_PIN D21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][9]  }]
set_property -dict { PACKAGE_PIN D20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][3]  }]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][12] }]
set_property -dict { PACKAGE_PIN C19 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][7]  }]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][4]  }]
set_property -dict { PACKAGE_PIN F17 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][1]  }]
set_property -dict { PACKAGE_PIN E21 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][6]  }]
set_property -dict { PACKAGE_PIN E20 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[3][addr][5]  }]

# DDR[3].CTRL
set_property -dict { PACKAGE_PIN H19 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[3]         }]
set_property -dict { PACKAGE_PIN H18 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[3]         }]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[3][ckT][0] }]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[3][ckC][0] }]
set_property -dict { PACKAGE_PIN F20 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][bg][0]  }]
set_property -dict { PACKAGE_PIN F19 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][actL]   }]
set_property -dict { PACKAGE_PIN G20 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][ba][0]  }]
set_property -dict { PACKAGE_PIN G19 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][ba][1]  }]
set_property -dict { PACKAGE_PIN K21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][cke][0] }]
set_property -dict { PACKAGE_PIN K17 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][odt][0] }]
set_property -dict { PACKAGE_PIN N21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][csL][0] }]; # TOP
set_property -dict { PACKAGE_PIN M21 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[3][csL][1] }]; # BOT
set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVCMOS12         } [get_ports { ddrOut[3][rstL]   }]

####################
# PCIe Constraints #
####################

set_property LOC PCIE_3_1_X0Y0   [get_cells {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst}]

set_property PACKAGE_PIN BC2 [get_ports {pciRxP[7]}]
set_property PACKAGE_PIN BC1 [get_ports {pciRxN[7]}]
set_property PACKAGE_PIN BF5 [get_ports {pciTxP[7]}]
set_property PACKAGE_PIN BF4 [get_ports {pciTxN[7]}]
set_property PACKAGE_PIN BA2 [get_ports {pciRxP[6]}]
set_property PACKAGE_PIN BA1 [get_ports {pciRxN[6]}]
set_property PACKAGE_PIN BD5 [get_ports {pciTxP[6]}]
set_property PACKAGE_PIN BD4 [get_ports {pciTxN[6]}]
set_property PACKAGE_PIN AW4 [get_ports {pciRxP[5]}]
set_property PACKAGE_PIN AW3 [get_ports {pciRxN[5]}]
set_property PACKAGE_PIN BB5 [get_ports {pciTxP[5]}]
set_property PACKAGE_PIN BB4 [get_ports {pciTxN[5]}]
set_property PACKAGE_PIN AV2 [get_ports {pciRxP[4]}]
set_property PACKAGE_PIN AV1 [get_ports {pciRxN[4]}]
set_property PACKAGE_PIN AV7 [get_ports {pciTxP[4]}]
set_property PACKAGE_PIN AV6 [get_ports {pciTxN[4]}]
set_property PACKAGE_PIN AU4 [get_ports {pciRxP[3]}]
set_property PACKAGE_PIN AU3 [get_ports {pciRxN[3]}]
set_property PACKAGE_PIN AU9 [get_ports {pciTxP[3]}]
set_property PACKAGE_PIN AU8 [get_ports {pciTxN[3]}]
set_property PACKAGE_PIN AT2 [get_ports {pciRxP[2]}]
set_property PACKAGE_PIN AT1 [get_ports {pciRxN[2]}]
set_property PACKAGE_PIN AT7 [get_ports {pciTxP[2]}]
set_property PACKAGE_PIN AT6 [get_ports {pciTxN[2]}]
set_property PACKAGE_PIN AR4 [get_ports {pciRxP[1]}]
set_property PACKAGE_PIN AR3 [get_ports {pciRxN[1]}]
set_property PACKAGE_PIN AR9 [get_ports {pciTxP[1]}]
set_property PACKAGE_PIN AR8 [get_ports {pciTxN[1]}]
set_property PACKAGE_PIN AP2 [get_ports {pciRxP[0]}]
set_property PACKAGE_PIN AP1 [get_ports {pciRxN[0]}]
set_property PACKAGE_PIN AP7 [get_ports {pciTxP[0]}]
set_property PACKAGE_PIN AP6 [get_ports {pciTxN[0]}]

set_property PACKAGE_PIN AT11    [get_ports {pciRefClkP}]
set_property PACKAGE_PIN AT10    [get_ports {pciRefClkN}]

set_property -dict { PACKAGE_PIN AR26 IOSTANDARD LVCMOS18 } [get_ports {pciRstL}]

##########
# Clocks #
##########
create_clock -period 10.000 -name pciRefClkP [get_ports {pciRefClkP}]
create_clock -period  3.333 -name ddrClkP0   [get_ports {ddrClkP[0]}]
create_clock -period  3.333 -name ddrClkP1   [get_ports {ddrClkP[1]}]
create_clock -period  3.333 -name ddrClkP2   [get_ports {ddrClkP[2]}]
create_clock -period  3.333 -name ddrClkP3   [get_ports {ddrClkP[3]}]

create_generated_clock -name dnaClk  [get_pins {U_Core/U_REG/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
create_generated_clock -name sysClk  [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/U0/gt_top_i/phy_clk_i/bufg_gt_userclk/O}]

create_generated_clock -name ddrIntClk00  [get_pins {U_Core/U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
create_generated_clock -name ddrIntClk01  [get_pins {U_Core/U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
create_generated_clock -name ddrIntClk02  [get_pins {U_Core/U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
create_generated_clock -name ddrIntClk03  [get_pins {U_Core/U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]

create_generated_clock -name ddrIntClk10  [get_pins {U_Core/U_Mig0/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
create_generated_clock -name ddrIntClk11  [get_pins {U_Core/U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
create_generated_clock -name ddrIntClk12  [get_pins {U_Core/U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
create_generated_clock -name ddrIntClk13  [get_pins {U_Core/U_Mig3/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {ddrClkP0}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {ddrClkP1}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {ddrClkP2}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks -include_generated_clocks {ddrClkP3}]

set_false_path -from [get_ports {pciRstL}]
set_false_path -through [get_pins {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/U0/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst/CFGMAX*}]
set_false_path -through [get_nets {U_Core/U_AxiPciePhy/U_AxiPcie/inst/inst/cfg_max*}]

set_property HIGH_PRIORITY true [get_nets {U_Core/U_AxiPciePhy/U_AxiPcie/inst/pcie3_ip_i/inst/gt_top_i/phy_clk_i/CLK_USERCLK}]

######################################
# BITSTREAM: .bit file Configuration #
######################################
set_property CONFIG_VOLTAGE 1.8                      [current_design]
set_property CFGBVS GND                              [current_design]
# set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable  [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE         [current_design]
set_property CONFIG_MODE SPIx8                       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8         [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup       [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes     [current_design]

########################
# Physical Constraints #
########################

# create_pblock DDR_MEM0_GRP
# add_cells_to_pblock [get_pblocks DDR_MEM0_GRP] [get_cells {U_Core/U_Mig0/U_MIG}]
# resize_pblock [get_pblocks DDR_MEM0_GRP] -add {CLOCKREGION_X2Y0:CLOCKREGION_X2Y3}

# create_pblock DDR_MEM1_GRP
# add_cells_to_pblock [get_pblocks DDR_MEM1_GRP] [get_cells {U_Core/U_Mig1/U_MIG}]
# resize_pblock [get_pblocks DDR_MEM1_GRP] -add {CLOCKREGION_X4Y2:CLOCKREGION_X4Y4}

# create_pblock DDR_MEM2_GRP
# add_cells_to_pblock [get_pblocks DDR_MEM2_GRP] [get_cells {U_Core/U_Mig2/U_MIG}]
# resize_pblock [get_pblocks DDR_MEM2_GRP] -add {CLOCKREGION_X2Y6:CLOCKREGION_X2Y9}

# create_pblock DDR_MEM3_GRP
# add_cells_to_pblock [get_pblocks DDR_MEM3_GRP] [get_cells {U_Core/U_Mig2/U_MIG}]
# resize_pblock [get_pblocks DDR_MEM3_GRP] -add {CLOCKREGION_X4Y6:CLOCKREGION_X4Y9}
