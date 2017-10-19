#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AMC Carrier Cryo Demo Board Application
#-----------------------------------------------------------------------------
# File       : PgpLane.py
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

from surf.xilinx import *
from surf.protocols.pgp import *

class PgpLane(pr.Device):
    def __init__(   self,       
            name        = "PgpLane",
            description = "PgpLane",
            basicMode   = True,            
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        # Add GT interface
        self.add(Gtpe2Channel(            
            name         = 'GTP7', 
            offset       = 0x0000, 
            expand       = False,
            hidden       = basicMode,
        ))  

        # Add Lane Monitor
        self.add(Pgp2bAxi(            
            name         = 'Monitor', 
            offset       = 0x1000, 
            expand       = False,
        ))          
        
        regOffset = 0x2000    
        
        self.addRemoteVariables(  
            name         = "LutDropCnt",
            description  = "",
            offset       = (regOffset | 0x00),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            number       = 4,            
            stride       = 4,            
            pollInterval = 1
        )

        self.addRemoteVariables(  
            name         = "FifoErrorCnt",
            description  = "",
            offset       = (regOffset | 0x10),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            number       = 4,            
            stride       = 4,            
            pollInterval = 1
        )

        self.addRemoteVariables(  
            name         = "VcPauseCnt",
            description  = "",
            offset       = (regOffset | 0x20),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            number       = 4,            
            stride       = 4,            
            pollInterval = 1
        )

        self.addRemoteVariables(  
            name         = "VcOverflowCnt",
            description  = "",
            offset       = (regOffset | 0x30),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            number       = 4,            
            stride       = 4,            
            pollInterval = 1
        )  
        
        self.add(pr.RemoteVariable( 
            name         = "RunCode",
            description  = "Run OP-Code for triggering",
            offset       = (regOffset | 0x40),
            bitSize      = 8,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))  

        self.add(pr.RemoteVariable( 
            name         = "AcceptCode",
            description  = "Accept OP-Code for triggering",
            offset       = (regOffset | 0x44),
            bitSize      = 8,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))  

        self.add(pr.RemoteVariable( 
            name         = "EnHdrTrig",
            description  = "Enable Header Trigger Checking/filtering",
            offset       = (regOffset | 0x48),
            bitSize      = 4,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable( 
            name         = "RunDelay",
            description  = "Delay for the RUN trigger",
            offset       = (regOffset | 0x4C),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))  

        self.add(pr.RemoteVariable( 
            name         = "AcceptDelay",
            description  = "Delay for the ACCEPT trigger",
            offset       = (regOffset | 0x50),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))          

        self.add(pr.RemoteCommand(  
            name         = "AcceptCntRst",
            description  = "Reset for the AcceptCnt",
            offset       = (regOffset | 0x54),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            function     = pr.BaseCommand.createTouch(0x1)
        ))            
        
        self.add(pr.RemoteVariable( 
            name         = "EvrOpCodeMask",
            description  = "Mask off the EVR OP-Code triggering",
            offset       = (regOffset | 0x58),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        )) 

        self.add(pr.RemoteVariable( 
            name         = "EvrSyncSel",
            description  = "0x0 = ASYNC start/stop, 0x1 = SYNC start/stop with respect to evrSyncWord",
            offset       = (regOffset | 0x5C),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))  

        self.add(pr.RemoteVariable( 
            name         = "EvrSyncEn",
            description  = "EVR SYNC Enable",
            offset       = (regOffset | 0x60),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))   

        self.add(pr.RemoteVariable( 
            name         = "EvrSyncWord",
            description  = "EVR SYNC Word",
            offset       = (regOffset | 0x64),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        )) 

        self.add(pr.RemoteVariable( 
            name         = "GtDrpOverride",
            description  = "",
            offset       = (regOffset | 0x68),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        ))   

        self.add(pr.RemoteVariable( 
            name         = "TxDiffCtrl",
            description  = "",
            offset       = (regOffset | 0x6C),
            bitSize      = 4,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        ))  

        self.add(pr.RemoteVariable( 
            name         = "TxPreCursor",
            description  = "",
            offset       = (regOffset | 0x70),
            bitSize      = 5,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        ))     

        self.add(pr.RemoteVariable( 
            name         = "TxPostCursor",
            description  = "",
            offset       = (regOffset | 0x74),
            bitSize      = 5,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        ))     

        self.add(pr.RemoteVariable( 
            name         = "QPllRxSelect",
            description  = "",
            offset       = (regOffset | 0x78),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        )) 

        self.add(pr.RemoteVariable( 
            name         = "QPllTxSelect",
            description  = "",
            offset       = (regOffset | 0x7C),
            bitSize      = 2,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            hidden       = basicMode,
        ))         
        
        # self.add(pr.RemoteCommand(  
            # name         = "TxUserRst",
            # description  = "",
            # offset       = (regOffset | 0x80),
            # bitSize      = 1,
            # bitOffset    = 0,
            # base         = pr.UInt,
            # function     = pr.BaseCommand.createTouch(0x1)
        # )) 

        # self.add(pr.RemoteCommand(  
            # name         = "RxUserRst",
            # description  = "",
            # offset       = (regOffset | 0x84),
            # bitSize      = 1,
            # bitOffset    = 0,
            # base         = pr.UInt,
            # function     = pr.BaseCommand.createTouch(0x1)
        # ))         
        
        self.add(pr.RemoteVariable( 
            name         = "TxUserRst",
            description  = "",
            offset       = (regOffset | 0x80),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        )) 

        self.add(pr.RemoteVariable( 
            name         = "RxUserRst",
            description  = "",
            offset       = (regOffset | 0x84),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))         
        
        self.add(pr.RemoteVariable( 
            name         = "EnableTrig",
            description  = "Enable OP-Code Trigger",
            offset       = (regOffset | 0x88),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))         
        
        self.add(pr.RemoteVariable( 
            name         = "EvrSyncStatus",
            description  = "EVR SYNC Status",
            offset       = (regOffset | 0x90),
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
        ))       

        self.add(pr.RemoteVariable( 
            name         = "AcceptCnt",
            description  = "AcceptCnt",
            offset       = (regOffset | 0x94),
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
        ))               
        
        @self.command(description="Configures the TX for 1.25 Gbps",)
        def CofigTx1p250Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllTxSelect.set(0x0)
            self.GTP7.TX_CLK25_DIV.set(9) # TX_CLK25_DIV = 10
            self.GTP7.TXOUT_DIV.set(0x2)  # TXOUT_DIV = 4
            self.GtDrpOverride.set(0x0)
            self.TxUserRst.set(0x1)
            self.TxUserRst.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)            
            
        @self.command(description="Configures the RX for 1.25 Gbps",)
        def ConfigRx1p250Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllRxSelect.set(0x0)
            self.GTP7.RX_CLK25_DIV.set(9) # RX_CLK25_DIV = 10
            self.GTP7.RXOUT_DIV.set(0x2)  # RXOUT_DIV = 4
            self.GTP7.RX_OS_CFG.set(0x80)
            self.GTP7.RXCDR_CFG_WRD0.set(0x1010)
            self.GTP7.RXCDR_CFG_WRD1.set(0x0104)
            self.GTP7.RXCDR_CFG_WRD2.set(0x1060)
            self.GTP7.RXCDR_CFG_WRD3.set(0x07FE)
            self.GTP7.RXCDR_CFG_WRD4.set(0x0001)
            self.GTP7.RXCDR_CFG_WRD5.set(0x0)              
            self.GTP7.RXLPM_INCM_CFG.set(0x0)
            self.GTP7.RXLPM_IPCM_CFG.set(0x1)
            self.GtDrpOverride.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)

        @self.command(description="Configures the TX for 2.5 Gbps",)
        def CofigTx2p500Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllTxSelect.set(0x0)
            self.GTP7.TX_CLK25_DIV.set(9) # TX_CLK25_DIV = 10
            self.GTP7.TXOUT_DIV.set(0x1)  # TXOUT_DIV = 2
            self.GtDrpOverride.set(0x0)
            self.TxUserRst.set(0x1)
            self.TxUserRst.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)            
            
        @self.command(description="Configures the RX for 2.5 Gbps",)
        def CofigRx2p500Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllRxSelect.set(0x0)
            self.GTP7.RX_CLK25_DIV.set(9) # RX_CLK25_DIV = 10
            self.GTP7.RXOUT_DIV.set(0x1)  # RXOUT_DIV = 2
            self.GTP7.RX_OS_CFG.set(0x3F0)
            self.GTP7.RXCDR_CFG_WRD0.set(0x1010)
            self.GTP7.RXCDR_CFG_WRD1.set(0x0104)
            self.GTP7.RXCDR_CFG_WRD2.set(0x2060)
            self.GTP7.RXCDR_CFG_WRD3.set(0x07FE)
            self.GTP7.RXCDR_CFG_WRD4.set(0x0001)
            self.GTP7.RXCDR_CFG_WRD5.set(0x0)             
            self.GTP7.RXLPM_INCM_CFG.set(0x1)
            self.GTP7.RXLPM_IPCM_CFG.set(0x0)
            self.GtDrpOverride.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)
            
        @self.command(description="Configures the TX for 3.125 Gbps",)
        def CofigTx3p125Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllTxSelect.set(0x3)
            self.GTP7.TX_CLK25_DIV.set(12) # TX_CLK25_DIV = 13
            self.GTP7.TXOUT_DIV.set(0x1)  # TXOUT_DIV = 2
            self.GtDrpOverride.set(0x0)
            self.TxUserRst.set(0x1)
            self.TxUserRst.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)            
            
        @self.command(description="Configures the RX for 3.125 Gbps",)
        def CofigRx3p125Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllRxSelect.set(0x3)
            self.GTP7.RX_CLK25_DIV.set(12) # RX_CLK25_DIV = 13
            self.GTP7.RXOUT_DIV.set(0x1)  # RXOUT_DIV = 2
            self.GTP7.RX_OS_CFG.set(0x3F0)
            self.GTP7.RXCDR_CFG_WRD0.set(0x1010)
            self.GTP7.RXCDR_CFG_WRD1.set(0x0104)
            self.GTP7.RXCDR_CFG_WRD2.set(0x2060)
            self.GTP7.RXCDR_CFG_WRD3.set(0x07FE)
            self.GTP7.RXCDR_CFG_WRD4.set(0x0001)
            self.GTP7.RXCDR_CFG_WRD5.set(0x0)             
            self.GTP7.RXLPM_INCM_CFG.set(0x1)
            self.GTP7.RXLPM_IPCM_CFG.set(0x0)
            self.GtDrpOverride.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)
            
        @self.command(description="Configures the TX for 5.0 Gbps",)
        def CofigTx5p000Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllTxSelect.set(0x0)
            self.GTP7.TX_CLK25_DIV.set(9) # TX_CLK25_DIV = 10
            self.GTP7.TXOUT_DIV.set(0x0)  # TXOUT_DIV = 1
            self.GtDrpOverride.set(0x0)
            self.TxUserRst.set(0x1)
            self.TxUserRst.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)            
            
        @self.command(description="Configures the RX for 5.0 Gbps",)
        def CofigRx5p000Gbps():
            self.GtDrpOverride.set(0x1)
            self.QPllRxSelect.set(0x0)
            self.GTP7.RX_CLK25_DIV.set(9) # RX_CLK25_DIV = 10
            self.GTP7.RXOUT_DIV.set(0x0)  # RXOUT_DIV = 1
            self.GTP7.RX_OS_CFG.set(0x80)
            self.GTP7.RXCDR_CFG_WRD0.set(0x1010)
            self.GTP7.RXCDR_CFG_WRD1.set(0x2104)
            self.GTP7.RXCDR_CFG_WRD2.set(0x2060)
            self.GTP7.RXCDR_CFG_WRD3.set(0x07FE)
            self.GTP7.RXCDR_CFG_WRD4.set(0x0011)
            self.GTP7.RXCDR_CFG_WRD5.set(0x0)
            self.GTP7.RXLPM_INCM_CFG.set(0x1)
            self.GTP7.RXLPM_IPCM_CFG.set(0x0)
            self.GtDrpOverride.set(0x0)
            self.RxUserRst.set(0x1)
            self.RxUserRst.set(0x0)
                    