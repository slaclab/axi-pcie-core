#!/usr/bin/env python
##############################################################################
## This file is part of 'camera-link-gen1'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'camera-link-gen1', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

import pyrogue as pr

from LclsTimingCore.TimingFrameRx import *
from LclsTimingCore.GthRxAlignCheck import *
from surf.xilinx import *

class TimingCore(pr.Device):
    def __init__(   self,       
            name        = "TimingCore",
            description = "TimingCore",
            basicMode   = True,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self.add(TimingFrameRx(
            name   = 'EvrCore', 
            offset = 0x00000000,
            expand = False,
        ))          
             
        regOffset = 0x00010000        
        
        self.add(pr.RemoteCommand(  
            name         = "MmcmRst",
            description  = "MmcmRst",
            offset       = (regOffset | 0x00),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            function     = pr.BaseCommand.createTouch(0x1)
        ))          
        
        self.add(pr.RemoteVariable( 
            name         = "MmcmLocked",
            description  = "MmcmLocked",
            offset       = (regOffset | 0x04),
            bitSize      = 3,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1            
        ))   

        self.add(pr.RemoteVariable( 
            name         = "RefRstStatus",
            description  = "RefRstStatus",
            offset       = (regOffset | 0x08),
            bitSize      = 3,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1            
        ))           

        self.add(pr.RemoteVariable( 
            name         = "GtLoopback",
            description  = "GtLoopback",
            offset       = (regOffset | 0x10),
            bitSize      = 3,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            # hidden       = basicMode,
        ))    
        
        self.add(pr.RemoteCommand(  
            name         = "RxUserRst",
            description  = "RxUserRst",
            offset       = (regOffset | 0x14),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            function     = pr.BaseCommand.createTouch(0x1)
        ))   
        
        self.add(pr.RemoteCommand(  
            name         = "TxUserRst",
            description  = "TxUserRst",
            offset       = (regOffset | 0x18),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            function     = pr.BaseCommand.createTouch(0x1)
        ))           

        self.add(pr.RemoteVariable( 
            name         = "TxDiffCtrl",
            description  = "TxDiffCtrl",
            offset       = (regOffset | 0x1C),
            bitSize      = 4,
            bitOffset    = 0,
            base         = pr.UInt,
            hidden       = True,            
            mode         = "RW",
        ))         
        
        self.add(pr.RemoteVariable( 
            name         = "TxPreCursor",
            description  = "TxPreCursor",
            offset       = (regOffset | 0x20),
            bitSize      = 5,
            bitOffset    = 0,
            base         = pr.UInt,
            hidden       = True,            
            mode         = "RW",
        ))    

        self.add(pr.RemoteVariable( 
            name         = "TxPostCursor",
            description  = "TxPostCursor",
            offset       = (regOffset | 0x24),
            bitSize      = 5,
            bitOffset    = 0,
            base         = pr.UInt,
            hidden       = True,            
            mode         = "RW",
        ))                
        
        self.add(pr.RemoteVariable( 
            name         = "TxRstStatus",
            description  = "TxRstStatus",
            offset       = (regOffset | 0x40),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1            
        )) 
        
        self.add(pr.RemoteVariable( 
            name         = "TxClkFreq",
            description  = "TxClkFreq",
            offset       = (regOffset | 0x44),
            bitSize      = 32,
            bitOffset    = 0,
            units        = 'Hz',
            base         = pr.UInt,
            disp         = '{:d}',
            mode         = "RO",
            pollInterval = 1
        )) 

        self.add(pr.RemoteVariable( 
            name         = "RxRstStatus",
            description  = "RxRstStatus",
            offset       = (regOffset | 0x48),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1            
        )) 
        
        self.add(pr.RemoteVariable( 
            name         = "RxClkFreq",
            description  = "RxClkFreq",
            offset       = (regOffset | 0x4C),
            bitSize      = 32,
            bitOffset    = 0,
            units        = 'Hz',
            base         = pr.UInt,
            disp         = '{:d}',
            mode         = "RO",
            pollInterval = 1
        ))  

        self.add(pr.RemoteVariable( 
            name         = "RefClk156Freq",
            description  = "RefClk156Freq",
            offset       = (regOffset | 0x50),
            bitSize      = 32,
            bitOffset    = 0,
            units        = 'Hz',
            base         = pr.UInt,
            disp         = '{:d}',
            mode         = "RO",
            pollInterval = 1
        ))         
        
        self.addRemoteVariables(   
            name         = "EvrRefClkFreq",
            description  = "EvrRefClkFreq",
            offset       =  (regOffset | 0x60),
            bitSize      = 32,
            bitOffset    = 0,
            units        = 'Hz',
            base         = pr.UInt,
            disp         = '{:d}',
            mode         = "RO",
            pollInterval = 1,
            number       = 3,
            stride       = 4,
            hidden       = basicMode, 
        )          
        
        @self.command(description="Configure for LCLS-I Timing (119 MHz based)",)
        def ConfigLclsTimingV1():
            print ( 'ConfigLclsTimingV1()' ) 
            self.EvrCore.RxPllReset.set(1)
            time.sleep(1.0)
            self.EvrCore.RxPllReset.set(0)
            self.EvrCore.ClkSel.set(0x0)
            self.EvrCore.RxReset.set(1)
            self.EvrCore.RxReset.set(0)
            
        @self.command(description="Configure for LCLS-II Timing (186 MHz based)",)
        def ConfigLclsTimingV2():
            print ( 'ConfigLclsTimingV2()' ) 
            self.EvrCore.RxPllReset.set(1)
            time.sleep(1.0)
            self.EvrCore.RxPllReset.set(0)
            self.EvrCore.ClkSel.set(0x1)
            self.EvrCore.RxReset.set(1)
            self.EvrCore.RxReset.set(0)        