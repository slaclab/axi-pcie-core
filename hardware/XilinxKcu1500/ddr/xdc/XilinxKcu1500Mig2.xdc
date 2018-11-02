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
# DDR[2]: Constraints #
#######################

# # DDR[2].BYTE[8]
# set_property -dict { PACKAGE_PIN C38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][64]  }]
# set_property -dict { PACKAGE_PIN C39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][65]  }]
# set_property -dict { PACKAGE_PIN E38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][66]  }]
# set_property -dict { PACKAGE_PIN D38 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][67]  }]
# set_property -dict { PACKAGE_PIN B39 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][8] }]
# set_property -dict { PACKAGE_PIN A39 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][8] }]
# set_property -dict { PACKAGE_PIN B40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][68]  }]
# set_property -dict { PACKAGE_PIN A40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][69]  }]
# set_property -dict { PACKAGE_PIN E39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][70]  }]
# set_property -dict { PACKAGE_PIN D39 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][71]  }]
# set_property -dict { PACKAGE_PIN E40 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][8]   }]

# # DDR[2].BYTE[7]
# set_property -dict { PACKAGE_PIN B30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][56]  }]
# set_property -dict { PACKAGE_PIN A30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][63]  }]
# set_property -dict { PACKAGE_PIN B29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][57]  }]
# set_property -dict { PACKAGE_PIN A29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][58]  }]
# set_property -dict { PACKAGE_PIN A27 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][7] }]
# set_property -dict { PACKAGE_PIN A28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][7] }]
# set_property -dict { PACKAGE_PIN E30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][60]  }]
# set_property -dict { PACKAGE_PIN D30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][61]  }]
# set_property -dict { PACKAGE_PIN D29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][59]  }]
# set_property -dict { PACKAGE_PIN C29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][62]  }]
# set_property -dict { PACKAGE_PIN C27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][7]   }]

# # DDR[2].BYTE[6]
# set_property -dict { PACKAGE_PIN E28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][51]  }]
# set_property -dict { PACKAGE_PIN D28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][50]  }]
# set_property -dict { PACKAGE_PIN F27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][48]  }]
# set_property -dict { PACKAGE_PIN E27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][52]  }]
# set_property -dict { PACKAGE_PIN F28 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][6] }]
# set_property -dict { PACKAGE_PIN F29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][6] }]
# set_property -dict { PACKAGE_PIN H29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][53]  }]
# set_property -dict { PACKAGE_PIN G29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][49]  }]
# set_property -dict { PACKAGE_PIN G26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][54]  }]
# set_property -dict { PACKAGE_PIN G27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][55]  }]
# set_property -dict { PACKAGE_PIN J26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][6]   }]

# # DDR[2].BYTE[5]
# set_property -dict { PACKAGE_PIN J28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][47]  }]
# set_property -dict { PACKAGE_PIN J29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][42]  }]
# set_property -dict { PACKAGE_PIN H27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][44]  }]
# set_property -dict { PACKAGE_PIN H28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][45]  }]
# set_property -dict { PACKAGE_PIN K26 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][5] }]
# set_property -dict { PACKAGE_PIN K27 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][5] }]
# set_property -dict { PACKAGE_PIN M27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][46]  }]
# set_property -dict { PACKAGE_PIN L27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][43]  }]
# set_property -dict { PACKAGE_PIN L28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][40]  }]
# set_property -dict { PACKAGE_PIN K28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][41]  }]
# set_property -dict { PACKAGE_PIN M29 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][5]   }]

# # DDR[2].BYTE[4]
# set_property -dict { PACKAGE_PIN P26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][33]  }]
# set_property -dict { PACKAGE_PIN N26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][38]  }]
# set_property -dict { PACKAGE_PIN P28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][37]  }]
# set_property -dict { PACKAGE_PIN N28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][35]  }]
# set_property -dict { PACKAGE_PIN P29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][4] }]
# set_property -dict { PACKAGE_PIN N29 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][4] }]
# set_property -dict { PACKAGE_PIN T26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][34]  }]
# set_property -dict { PACKAGE_PIN R26 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][39]  }]
# set_property -dict { PACKAGE_PIN T27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][36]  }]
# set_property -dict { PACKAGE_PIN R27 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][32]  }]
# set_property -dict { PACKAGE_PIN T28 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][4]   }]

# # DDR[2].BYTE[3]
# set_property -dict { PACKAGE_PIN F33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][29]  }]
# set_property -dict { PACKAGE_PIN E33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][31]  }]
# set_property -dict { PACKAGE_PIN F32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][30]  }]
# set_property -dict { PACKAGE_PIN E32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][28]  }]
# set_property -dict { PACKAGE_PIN J33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][3] }]
# set_property -dict { PACKAGE_PIN H33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][3] }]
# set_property -dict { PACKAGE_PIN H32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][24]  }]
# set_property -dict { PACKAGE_PIN G32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][26]  }]
# set_property -dict { PACKAGE_PIN H31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][27]  }]
# set_property -dict { PACKAGE_PIN G31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][25]  }]
# set_property -dict { PACKAGE_PIN G30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][3]   }]

# # DDR[2].BYTE[2]
# set_property -dict { PACKAGE_PIN L33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][20]  }]
# set_property -dict { PACKAGE_PIN K33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][17]  }]
# set_property -dict { PACKAGE_PIN K31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][16]  }]
# set_property -dict { PACKAGE_PIN J31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][21]  }]
# set_property -dict { PACKAGE_PIN K30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][2] }]
# set_property -dict { PACKAGE_PIN J30 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][2] }]
# set_property -dict { PACKAGE_PIN M30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][19]  }]
# set_property -dict { PACKAGE_PIN L30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][23]  }]
# set_property -dict { PACKAGE_PIN L32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][18]  }]
# set_property -dict { PACKAGE_PIN K32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][22]  }]
# set_property -dict { PACKAGE_PIN M31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][2]   }]

# # DDR[2].BYTE[1]
# set_property -dict { PACKAGE_PIN N32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][14]  }]
# set_property -dict { PACKAGE_PIN N33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][9]   }]
# set_property -dict { PACKAGE_PIN P31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][11]  }]
# set_property -dict { PACKAGE_PIN N31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][12]  }]
# set_property -dict { PACKAGE_PIN M34 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][1] }]
# set_property -dict { PACKAGE_PIN L34 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][1] }]
# set_property -dict { PACKAGE_PIN P34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][10]  }]
# set_property -dict { PACKAGE_PIN N34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][8]   }]
# set_property -dict { PACKAGE_PIN R31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][15]  }]
# set_property -dict { PACKAGE_PIN R32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][13]  }]
# set_property -dict { PACKAGE_PIN R30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][1]   }]

# # DDR[2].BYTE[0]
# set_property -dict { PACKAGE_PIN U30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][7]   }]
# set_property -dict { PACKAGE_PIN T30 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][4]   }]
# set_property -dict { PACKAGE_PIN V31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][5]   }]
# set_property -dict { PACKAGE_PIN U31 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][3]   }]
# set_property -dict { PACKAGE_PIN V32 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsT][0] }]
# set_property -dict { PACKAGE_PIN V33 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[2][dqsC][0] }]
# set_property -dict { PACKAGE_PIN U32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][6]   }]
# set_property -dict { PACKAGE_PIN T32 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][1]   }]
# set_property -dict { PACKAGE_PIN T33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][2]   }]
# set_property -dict { PACKAGE_PIN R33 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dq][0]   }]
# set_property -dict { PACKAGE_PIN U34 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[2][dm][0]   }]

# # DDR[2].ADDR
# set_property -dict { PACKAGE_PIN D31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][14] }]; # WE_B
# set_property -dict { PACKAGE_PIN C31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][0]  }]
# set_property -dict { PACKAGE_PIN B31 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][2]  }]
# set_property -dict { PACKAGE_PIN C32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][8]  }]
# set_property -dict { PACKAGE_PIN B32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][10] }]
# set_property -dict { PACKAGE_PIN A32 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][16] }]; # RAS_B
# set_property -dict { PACKAGE_PIN A33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][11] }]
# set_property -dict { PACKAGE_PIN D33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][15] }]; # CAS_B
# set_property -dict { PACKAGE_PIN C33 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][13] }]
# set_property -dict { PACKAGE_PIN D34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][9]  }]
# set_property -dict { PACKAGE_PIN C34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][3]  }]
# set_property -dict { PACKAGE_PIN B34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][12] }]
# set_property -dict { PACKAGE_PIN A34 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][7]  }]
# set_property -dict { PACKAGE_PIN E35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][4]  }]
# set_property -dict { PACKAGE_PIN D35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][1]  }]
# set_property -dict { PACKAGE_PIN B35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][6]  }]
# set_property -dict { PACKAGE_PIN A35 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[2][addr][5]  }]

# # DDR[2].CTRL
# set_property -dict { PACKAGE_PIN C36 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP[2]         }]
# set_property -dict { PACKAGE_PIN C37 IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN[2]         }]
# set_property -dict { PACKAGE_PIN B36 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[2][ckT][0] }]
# set_property -dict { PACKAGE_PIN B37 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[2][ckC][0] }]
# set_property -dict { PACKAGE_PIN A37 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][bg][0]  }]
# set_property -dict { PACKAGE_PIN A38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][actL]   }]
# set_property -dict { PACKAGE_PIN E36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][ba][0]  }]
# set_property -dict { PACKAGE_PIN D36 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][ba][1]  }]
# set_property -dict { PACKAGE_PIN F38 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][cke][0] }]
# set_property -dict { PACKAGE_PIN D40 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][odt][0] }]
# set_property -dict { PACKAGE_PIN F34 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][csL][0] }]; # TOP
# set_property -dict { PACKAGE_PIN F35 IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[2][csL][1] }]; # BOT
# set_property -dict { PACKAGE_PIN L29 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports { ddrOut[2][rstL]   }]

##########
# Clocks #
##########

create_clock -period  3.333 -name ddrClkP2  [get_ports {ddrClkP[2]}]
# create_generated_clock   -name ddrIntClk02  [get_pins {U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
# create_generated_clock   -name ddrIntClk12  [get_pins {U_Mig2/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
