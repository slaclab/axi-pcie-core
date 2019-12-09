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
        
class AxiGpuAsyncCore(pr.Device):
    def __init__(self,       
                 numChan     = 1,
                 description = 'Container for the GPUAsync core registers',
                 **kwargs):
        super().__init__(description=description, **kwargs)

        for i in range(numChan):
            
            self.add(pr.RemoteVariable(
                name         = f'RemoteDmaAddress[{i}]',
                offset       = 0x000+8*i,
                bitSize      = 32,
                mode         = 'RW',
                pollInterval = 1,
            )) 
            
            self.add(pr.RemoteVariable(
                name         = f'RmoteDmaSize[{i}]',
                offset       = 0x080+4*i,
                bitSize      = 32,
                mode         = 'RW',
                pollInterval = 1,
            ))        
        
        self.add(pr.RemoteVariable(
            name         = 'RxFrameCnt',
            offset       = 0x0E0,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))     

        self.add(pr.RemoteVariable(
            name         = 'TxFrameCnt',
            offset       = 0x0E8,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))     

        self.add(pr.RemoteVariable(
            name         = 'TxAxiErrorCnt',
            offset       = 0x0F0,
            bitSize      = 32,
            mode         = 'RO',
            pollInterval = 1,
        ))        

        self.add(pr.RemoteVariable(
            name         = 'NumChan',
            offset       = 0x0F4,
            bitSize      = 5,
            mode         = 'RO',
        ))
        
        self.add(pr.RemoteVariable(
            name         = 'EnableTx',
            offset       = 0x0F8,
            bitSize      = 1,
            bitOffset    = 0,
            mode         = 'RW',
        ))  

        self.add(pr.RemoteVariable(
            name         = 'EnableTx',
            offset       = 0x0F8,
            bitSize      = 1,
            bitOffset    = 1,
            mode         = 'RW',
        ))  

        self.add(pr.RemoteVariable(
            name         = 'AxiWriteCache',
            offset       = 0x0F8,
            bitSize      = 4,
            bitOffset    = 16,
            mode         = 'RW',
        ))          
        
        self.add(pr.RemoteCommand(   
            name         = 'CountReset',
            description  = 'Status counter reset',
            offset       = 0x0FC,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne
        ))        
        
    def countReset(self):
        self.CountReset()        

