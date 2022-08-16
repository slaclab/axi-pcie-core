#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

class TerminateQsfp(pr.Device):
    def __init__(self,numRefClk=4,**kwargs):
        super().__init__(**kwargs)

        self.addRemoteVariables(
            name         = 'RefClkFreq',
            offset       = 0x0,
            bitSize      = 32,
            mode         = 'RO',
            number       = numRefClk,
            stride       = 4,
            disp         = '{:d}',
            units        = 'Hz',
            pollInterval = 1,
        )
