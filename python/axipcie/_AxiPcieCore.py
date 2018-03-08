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
import surf.axi 
import surf.devices.micron 
import surf.xilinx 

class AxiPcieCore(pr.Device):
    def __init__(self,       
                 description = 'Base components of the PCIe firmware core',
                 useBpi      = False,
                 useSpi      = False,
                 numDmaLanes = 8,
                 **kwargs):
        super().__init__(description=description, **kwargs)

        # PCI PHY status
        self.add(surf.xilinx.AxiPciePhy(            
            offset       = 0x10000, 
            expand       = False,
        ))
        
        # Standard AxiVersion Module
        self.add(surf.axi.AxiVersion(            
            offset       = 0x20000, 
            expand       = False,
        ))

        # Check if using BPI PROM
        if (useBpi):
            self.add(surf.devices.micron.AxiMicronP30(
                offset       =  0x30000,
                expand       =  False,                                    
                hidden       =  True,                                    
            ))         
        
        # Check if using SPI PROM
        if (useSpi):
            for i in range(2):
                self.add(surf.devices.micron.AxiMicronN25Q(
                    name         = f'AxiMicronN25Q[{i}]',
                    offset       =  0x40000 + (i * 0x10000),
                    expand       =  False,                                    
                    hidden       =  True,                                    
                ))
                
        # DMA AXI Stream Inbound Monitor        
        self.add(surf.axi.AxiStreamMonitoring(            
            name        = 'DmaIbAxisMon', 
            offset      = 0x60000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))        

        # DMA AXI Stream Outbound Monitor        
        self.add(surf.axi.AxiStreamMonitoring(            
            name        = 'DmaObAxisMon', 
            offset      = 0x70000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))
