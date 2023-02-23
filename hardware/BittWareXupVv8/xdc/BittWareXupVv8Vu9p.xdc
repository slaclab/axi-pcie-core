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

resize_pblock [get_pblocks SLR0_GRP] -add {CLOCKREGION_X0Y0:CLOCKREGION_X5Y4}
resize_pblock [get_pblocks SLR1_GRP] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}
resize_pblock [get_pblocks SLR2_GRP] -add {CLOCKREGION_X0Y10:CLOCKREGION_X7Y14}

