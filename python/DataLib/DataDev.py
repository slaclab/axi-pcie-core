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
import surf.axi as axi
import surf.devices.micron as micron
import surf.xilinx as xilinx

class DataDev(pr.Device):
    def __init__(   self,       
            name        = "DataDev",
            description = "Container for data device registers",
            useBpi      = False,
            useSpi      = False,
            numDmaLanes = 8,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        # PCI PHY status
        self.add(xilinx.AxiPciePhy(            
            offset       = 0x10000, 
            expand       = False,
        ))
        
        # Standard AxiVersion Module
        self.add(axi.AxiVersion(            
            offset       = 0x20000, 
            expand       = False,
        ))

        # Check if using BPI PROM
        if (useBpi):
            self.add(micron.AxiMicronP30(
                offset       =  0x30000,
                expand       =  False,                                    
                hidden       =  True,                                    
            ))         
        
        # Check if using SPI PROM
        if (useSpi):
            for i in range(2):
                self.add(micron.AxiMicronN25Q(
                    name         = "AxiMicronN25Q[%i]" % (i),
                    offset       =  0x40000 + (i * 0x10000),
                    description  = "AxiMicronN25Q: %i" % (i),                                
                    expand       =  False,                                    
                    hidden       =  True,                                    
                ))
                
        # DMA AXI Stream Inbound Monitor        
        self.add(axi.AxiStreamMonitoring(            
            name        = 'DmaIbAxisMon', 
            offset      = 0x60000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))        

        # DMA AXI Stream Outbound Monitor        
        self.add(axi.AxiStreamMonitoring(            
            name        = 'DmaObAxisMon', 
            offset      = 0x70000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))
        