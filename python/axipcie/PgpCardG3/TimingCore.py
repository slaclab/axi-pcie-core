#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AMC Carrier Cryo Demo Board Application
#-----------------------------------------------------------------------------
# File       : TimingCore.py
# Created    : 2017-04-03
#-----------------------------------------------------------------------------
# Description:
# PyRogue AMC Carrier Cryo Demo Board Application
#-----------------------------------------------------------------------------
# This file is part of the rogue software platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue software platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

from LclsTimingCore.TimingFrameRx import *
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
        
        self.add(pr.RemoteVariable( 
            name         = "EvrMuxSel",
            description  = "Controls the SY58023UMG 2:2 crossbar",
            offset       = (regOffset | 0x00),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))      

        self.add(pr.RemoteVariable( 
            name         = "EvrQPllRxSel",
            description  = "0x0 = LCLS-I, 0x3 = LCLS-II",
            offset       = (regOffset | 0x04),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            hidden       = basicMode,            
            mode         = "RW",
        ))   

        self.add(pr.RemoteVariable( 
            name         = "EvrQPllTxSel",
            description  = "0x0 = LCLS-I, 0x3 = LCLS-II",
            offset       = (regOffset | 0x08),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            hidden       = basicMode,            
            mode         = "RW",
        ))           
        
        self.add(pr.RemoteCommand(  
            name         = "EvrQPllRst",
            description  = "Resets the EVR QPLL",
            offset       =  (regOffset | 0x0C),
            bitSize      =  2,
            bitOffset    =  0,
            base         = pr.UInt,
            function     = pr.BaseCommand.createTouch(0x3)
        ))      
        
        self.add(pr.RemoteVariable( 
            name         = "GtLoopback",
            description  = "GtLoopback",
            offset       = (regOffset | 0x10),
            bitSize      = 3,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
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

        # self.add(pr.RemoteVariable( 
            # name         = "RefClkFreq[0]",
            # description  = "RefClkFreq[0]",
            # offset       = (regOffset | 0x50),
            # bitSize      = 32,
            # bitOffset    = 0,
            # units        = 'Hz',
            # base         = pr.UInt,
            # disp         = '{:d}',
            # mode         = "RO",
            # pollInterval = 1
        # ))  

        # self.add(pr.RemoteVariable( 
            # name         = "RefClkFreq[1]",
            # description  = "RefClkFreq[1]",
            # offset       = (regOffset | 0x54),
            # bitSize      = 32,
            # bitOffset    = 0,
            # units        = 'Hz',
            # base         = pr.UInt,
            # disp         = '{:d}',
            # mode         = "RO",
            # pollInterval = 1
        # ))          
        
        self.add(pr.RemoteVariable( 
            name         = "QPllLock",
            description  = "QPllLock",
            offset       = (regOffset | 0x58),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1            
        ))         
        
        @self.command(description="Configure for LCLS-I Timing (119 MHz based)",)
        def ConfigLclsTimingV1():
            print ( 'ConfigLclsTimingV1()' ) 
            self.EvrCore.ClkSel.set(0x0)
            self.EvrQPllRxSel.set(0x0)
            self.EvrQPllTxSel.set(0x0)            
            self.RxUserRst()
            self.TxUserRst()
            self.EvrQPllRst()
            self.EvrCore.C_RxReset()
            
        @self.command(description="Configure for LCLS-II Timing (186 MHz based)",)
        def ConfigLclsTimingV2():
            print ( 'ConfigLclsTimingV2()' ) 
            self.EvrCore.ClkSel.set(0x1)
            self.EvrQPllRxSel.set(0x3)
            self.EvrQPllTxSel.set(0x3)            
            self.RxUserRst()
            self.TxUserRst()
            self.EvrQPllRst()
            self.EvrCore.C_RxReset()             