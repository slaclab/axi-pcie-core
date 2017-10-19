##############################################################################
## This file is part of 'SLAC PGP Gen3 Card'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC PGP Gen3 Card', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

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
