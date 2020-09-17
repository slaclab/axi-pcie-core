##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'axi-pcie-core', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property USER_SLR_ASSIGNMENT SLR1 [get_cells -hier -filter {NAME =~ *GEN_VEC[0].U_Mig}]
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells -hier -filter {NAME =~ *GEN_VEC[1].U_Mig}]
set_property USER_SLR_ASSIGNMENT SLR2 [get_cells -hier -filter {NAME =~ *GEN_VEC[2].U_Mig}]
set_property USER_SLR_ASSIGNMENT SLR3 [get_cells -hier -filter {NAME =~ *GEN_VEC[3].U_Mig}]
