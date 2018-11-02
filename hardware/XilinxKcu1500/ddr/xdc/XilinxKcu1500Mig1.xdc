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
# DDR[1]: Constraints #
#######################

# # DDR[0].BYTE[7]
# set_property -dict { PACKAGE_PIN BA9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][56]  }]
# set_property -dict { PACKAGE_PIN BA8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][63]  }]
# set_property -dict { PACKAGE_PIN BB9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][57]  }]
# set_property -dict { PACKAGE_PIN BC9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][58]  }]
# set_property -dict { PACKAGE_PIN BA7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][7] }]
# set_property -dict { PACKAGE_PIN BB7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][7] }]
# set_property -dict { PACKAGE_PIN BC8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][60]  }]
# set_property -dict { PACKAGE_PIN BC7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][61]  }]
# set_property -dict { PACKAGE_PIN BB11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][59]  }]
# set_property -dict { PACKAGE_PIN BB10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][62]  }]
# set_property -dict { PACKAGE_PIN BC12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][7]   }]

# # DDR[0].BYTE[6]
# set_property -dict { PACKAGE_PIN BD9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][51]  }]
# set_property -dict { PACKAGE_PIN BD8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][50]  }]
# set_property -dict { PACKAGE_PIN BE12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][48]  }]
# set_property -dict { PACKAGE_PIN BF12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][52]  }]
# set_property -dict { PACKAGE_PIN BE11 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][6] }]
# set_property -dict { PACKAGE_PIN BE10 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][6] }]
# set_property -dict { PACKAGE_PIN BF10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][53]  }]
# set_property -dict { PACKAGE_PIN BF9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][49]  }]
# set_property -dict { PACKAGE_PIN BE8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][54]  }]
# set_property -dict { PACKAGE_PIN BF8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][55]  }]
# set_property -dict { PACKAGE_PIN BE7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][6]   }]

# # DDR[0].BYTE[5]
# set_property -dict { PACKAGE_PIN AY13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][47]  }]
# set_property -dict { PACKAGE_PIN BA13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][42]  }]
# set_property -dict { PACKAGE_PIN BA15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][44]  }]
# set_property -dict { PACKAGE_PIN BA14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][45]  }]
# set_property -dict { PACKAGE_PIN BB15 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][5] }]
# set_property -dict { PACKAGE_PIN BB14 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][5] }]
# set_property -dict { PACKAGE_PIN AY16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][46]  }]
# set_property -dict { PACKAGE_PIN AY15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][43]  }]
# set_property -dict { PACKAGE_PIN AY12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][40]  }]
# set_property -dict { PACKAGE_PIN AY11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][41]  }]
# set_property -dict { PACKAGE_PIN BA12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][5]   }]

# # DDR[0].BYTE[4]
# set_property -dict { PACKAGE_PIN BC14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][33]  }]
# set_property -dict { PACKAGE_PIN BC13 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][38]  }]
# set_property -dict { PACKAGE_PIN BD15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][37]  }]
# set_property -dict { PACKAGE_PIN BD14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][35]  }]
# set_property -dict { PACKAGE_PIN BD13 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][4] }]
# set_property -dict { PACKAGE_PIN BE13 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][4] }]
# set_property -dict { PACKAGE_PIN BD16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][34]  }]
# set_property -dict { PACKAGE_PIN BE16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][39]  }]
# set_property -dict { PACKAGE_PIN BE15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][36]  }]
# set_property -dict { PACKAGE_PIN BF15 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][32]  }]
# set_property -dict { PACKAGE_PIN BF14 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][4]   }]

# # DDR[0].BYTE[3]
# set_property -dict { PACKAGE_PIN AL20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][29]  }]
# set_property -dict { PACKAGE_PIN AM20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][31]  }]
# set_property -dict { PACKAGE_PIN AL19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][30]  }]
# set_property -dict { PACKAGE_PIN AM19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][28]  }]
# set_property -dict { PACKAGE_PIN AL17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][3] }]
# set_property -dict { PACKAGE_PIN AM17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][3] }]
# set_property -dict { PACKAGE_PIN AM16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][24]  }]
# set_property -dict { PACKAGE_PIN AN16 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][26]  }]
# set_property -dict { PACKAGE_PIN AN19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][27]  }]
# set_property -dict { PACKAGE_PIN AP19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][25]  }]
# set_property -dict { PACKAGE_PIN AN18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][3]   }]

# # DDR[0].BYTE[2]
# set_property -dict { PACKAGE_PIN AP20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][20]  }]
# set_property -dict { PACKAGE_PIN AR20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][17]  }]
# set_property -dict { PACKAGE_PIN AP18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][16]  }]
# set_property -dict { PACKAGE_PIN AR18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][21]  }]
# set_property -dict { PACKAGE_PIN AR17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][2] }]
# set_property -dict { PACKAGE_PIN AT17 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][2] }]
# set_property -dict { PACKAGE_PIN AT18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][19]  }]
# set_property -dict { PACKAGE_PIN AU17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][23]  }]
# set_property -dict { PACKAGE_PIN AT20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][18]  }]
# set_property -dict { PACKAGE_PIN AU20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][22]  }]
# set_property -dict { PACKAGE_PIN AT19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][2]   }]

# # DDR[0].BYTE[1]
# set_property -dict { PACKAGE_PIN AV19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][14]  }]
# set_property -dict { PACKAGE_PIN AW19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][9]   }]
# set_property -dict { PACKAGE_PIN AV18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][11]  }]
# set_property -dict { PACKAGE_PIN AW18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][12]  }]
# set_property -dict { PACKAGE_PIN AV21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][1] }]
# set_property -dict { PACKAGE_PIN AW21 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][1] }]
# set_property -dict { PACKAGE_PIN AW20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][10]  }]
# set_property -dict { PACKAGE_PIN AY20 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][8]   }]
# set_property -dict { PACKAGE_PIN AY18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][15]  }]
# set_property -dict { PACKAGE_PIN BA18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][13]  }]
# set_property -dict { PACKAGE_PIN AY17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][1]   }]

# # DDR[0].BYTE[0]
# set_property -dict { PACKAGE_PIN BB19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][7]   }]
# set_property -dict { PACKAGE_PIN BC18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][4]   }]
# set_property -dict { PACKAGE_PIN BB17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][5]   }]
# set_property -dict { PACKAGE_PIN BC17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][3]   }]
# set_property -dict { PACKAGE_PIN BC19 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsT][0] }]
# set_property -dict { PACKAGE_PIN BD19 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[1][dqsC][0] }]
# set_property -dict { PACKAGE_PIN BD18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][6]   }]
# set_property -dict { PACKAGE_PIN BE18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][1]   }]
# set_property -dict { PACKAGE_PIN BF19 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][2]   }]
# set_property -dict { PACKAGE_PIN BF18 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dq][0]   }]
# set_property -dict { PACKAGE_PIN BE17 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[1][dm][0]   }]

# # DDR[0].ADDR
# set_property -dict { PACKAGE_PIN AL14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][14] }]; # WE_B
# set_property -dict { PACKAGE_PIN AM14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][0]  }]
# set_property -dict { PACKAGE_PIN AT13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][2]  }]
# set_property -dict { PACKAGE_PIN AL15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][8]  }]
# set_property -dict { PACKAGE_PIN AM15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][10] }]
# set_property -dict { PACKAGE_PIN AP13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][16] }]; # RAS_B
# set_property -dict { PACKAGE_PIN AR13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][11] }]
# set_property -dict { PACKAGE_PIN AN14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][15] }]; # CAS_B
# set_property -dict { PACKAGE_PIN AN13 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][13] }]
# set_property -dict { PACKAGE_PIN AP15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][9]  }]
# set_property -dict { PACKAGE_PIN AP14 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][3]  }]
# set_property -dict { PACKAGE_PIN AR16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][12] }]
# set_property -dict { PACKAGE_PIN AR15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][7]  }]
# set_property -dict { PACKAGE_PIN AU16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][4]  }]
# set_property -dict { PACKAGE_PIN AV16 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][1]  }]
# set_property -dict { PACKAGE_PIN AT15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][6]  }]
# set_property -dict { PACKAGE_PIN AU15 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[1][addr][5]  }]

# # DDR[0].CTRL
# set_property -dict { PACKAGE_PIN AW14 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[1]         }]
# set_property -dict { PACKAGE_PIN AW13 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[1]         }]
# set_property -dict { PACKAGE_PIN AU14 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[1][ckT][0] }]
# set_property -dict { PACKAGE_PIN AV14 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[1][ckC][0] }]
# set_property -dict { PACKAGE_PIN AU13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][bg][0]  }]
# set_property -dict { PACKAGE_PIN AV13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][actL]   }]
# set_property -dict { PACKAGE_PIN AW16 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][ba][0]  }]
# set_property -dict { PACKAGE_PIN AW15 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][ba][1]  }]
# set_property -dict { PACKAGE_PIN BB16 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][cke][0] }]
# set_property -dict { PACKAGE_PIN BB12 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][odt][0] }]
# set_property -dict { PACKAGE_PIN BF13 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][csL][0] }]; # TOP
# set_property -dict { PACKAGE_PIN AT14 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[1][csL][1] }]; # BOT
# set_property -dict { PACKAGE_PIN AU19 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports { ddrOut[1][rstL]   }]

##########
# Clocks #
##########

create_clock -period  3.333 -name ddrClkP1  [get_ports {ddrClkP[1]}]
# create_generated_clock   -name ddrIntClk01  [get_pins {U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk11  [get_pins {U_Mig1/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
