#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : 
#-----------------------------------------------------------------------------
# File       : DataDev.py
# Created    : 2017-04-03
#-----------------------------------------------------------------------------
# Description:
# 
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr
from surf.axi import *

class DataDev(pr.Device):
    def __init__(   self,       
            name        = "DataDev",
            description = "Container for data development registers",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        # Axi Version
        self.add(AxiVersion(            
            offset       = 0x30000, 
            expand       = False,
        ))        
