##############################################################################
## This file is part of 'PGP PCIe APP DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'PGP PCIe APP DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_pblock SLR0_GRP
create_pblock SLR1_GRP
create_pblock SLR2_GRP
create_pblock SLR3_GRP

resize_pblock [get_pblocks SLR0_GRP] -add {CLOCKREGION_X0Y0:CLOCKREGION_X7Y3}
resize_pblock [get_pblocks SLR1_GRP] -add {CLOCKREGION_X0Y4:CLOCKREGION_X7Y7}
resize_pblock [get_pblocks SLR2_GRP] -add {CLOCKREGION_X0Y8:CLOCKREGION_X7Y11}
resize_pblock [get_pblocks SLR3_GRP] -add {CLOCKREGION_X0Y12:CLOCKREGION_X7Y15}


set_property USER_SLR_ASSIGNMENT SLR1 [get_cells {U_Core}]
