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
from surf.devices.micron import *

class DataDev(pr.Device):
    def __init__(   self,       
            name        = "DataDev",
            description = "Container for data development registers",
            useBpi      = False,
            useSpi      = False,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        if (useBpi):
            self.add(_AxiMicronP30(
                offset       =  0x0000,
                expand       =  False,                                    
                hidden       =  True,                                    
            ))         
        
        if (useSpi):
            for i in range(2):
                self.add(AxiMicronN25Q(
                    name         = "AxiMicronN25Q[%i]" % (i),
                    offset       =  0x1000 + (i * 0x1000),
                    description  = "AxiMicronN25Q: %i" % (i),                                
                    expand       =  False,                                    
                    hidden       =  True,                                    
                ))        
        
        self.add(AxiVersion(            
            offset       = 0x30000, 
            expand       = False,
        ))
        