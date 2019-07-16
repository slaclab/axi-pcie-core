#!/usr/bin/env python
#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'axi-pcie-core', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue              as pr
        
class AxiPipCore(pr.Device):
    def __init__(self,       
                 numLane     = 1,
                 description = 'Container for the PIP core registers',
                 **kwargs):
        super().__init__(description=description, **kwargs)

        for i in range(numLane):
            
            self.add(pr.RemoteVariable(
                name         = f'REMOTE_BAR0_BASE_ADDRESS[{i}]',
                offset       = 0x00+8*i,
                bitSize      = 32,
                mode         = 'RW',
            )) 
            
            self.add(pr.RemoteVariable(
                name         = f'DepackEofeCnt[{i}]',
                offset       = 0xF0,
                bitSize      = 32,
                mode         = 'RO',
                pollInterval = 1,
            ))        
        
        self.add(pr.RemoteVariable(
            name         = 'RxFrameCnt',
            offset       = 0xE0,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))     

        self.add(pr.RemoteVariable(
            name         = 'RxDropFrameCnt',
            offset       = 0xE4,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        )) 

        self.add(pr.RemoteVariable(
            name         = 'TxFrameCnt',
            offset       = 0xE8,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))     

        self.add(pr.RemoteVariable(
            name         = 'TxDropFrameCnt',
            offset       = 0xEC,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'TxAxiErrorCnt',
            offset       = 0xF0,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))        

        self.add(pr.RemoteVariable(
            name         = 'NUM_AXIS_G',
            offset       = 0xF4,
            bitSize      = 5,
            mode         = 'RO',
        ))
        
        self.add(pr.RemoteVariable(
            name         = 'EnableTx',
            offset       = 0xF8,
            bitSize      = numLane,
            mode         = 'RW',
        ))  
        
        self.add(pr.RemoteVariable(
            name         = 'AxiWriteCache',
            offset       = 0xF8,
            bitSize      = 4,
            bitOffset    = 16,
            mode         = 'RW',
        ))          
        
        self.add(pr.RemoteCommand(   
            name         = 'CountReset',
            description  = 'Status counter reset',
            offset       = 0xFC,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne
        ))        
        
    def countReset(self):
        self.CountReset()        