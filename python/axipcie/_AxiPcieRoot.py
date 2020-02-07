#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'axi-pcie-core', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import axipcie as pcie

import pyrogue as pr
import rogue

class AxiPcieRoot(pr.Root):
    def __init__(self, dev, **kwargs):
        super().__init__(**kwargs)

        memMap = rogue.hardware.axi.AxiMemMap(dev)

        self.add(pcie.AxiPcieCore(
            memBase = memMap,
            useBpi = True,
            useSpi = True))
