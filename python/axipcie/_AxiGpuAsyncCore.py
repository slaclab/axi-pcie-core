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
                 maxBuffers  = 4,
                 description = 'Container for the GPUAsync core registers',
                 **kwargs):
        super().__init__(description=description, **kwargs)

        self.add(pr.RemoteVariable(
            name         = 'AxiReadCache',
            offset       = 0x004,
            bitSize      = 4,
            bitOffset    = 0,
            mode         = 'RO',
        ))          

        self.add(pr.RemoteVariable(
            name         = 'AxiWriteCache',
            offset       = 0x004,
            bitSize      = 4,
            bitOffset    = 8,
            mode         = 'RO',
        ))          

        self.add(pr.RemoteVariable(
            name         = 'BusWidth',
            offset       = 0x004,
            bitSize      = 8,
            bitOffset    = 16,
            disp         = '{}',
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'MaxBuffers',
            offset       = 0x004,
            bitSize      = 5,
            bitOffset    = 24,
            disp         = '{}',
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'BufferCount',
            offset       = 0x008,
            bitSize      = 8,
            bitOffset    = 0,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'BufferEnable',
            offset       = 0x008,
            bitSize      = 1,
            bitOffset    = 8,
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RxFrameCnt',
            offset       = 0x010,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'TxFrameCnt',
            offset       = 0x014,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteAxiErrorCnt',
            offset       = 0x018,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadAxiErrorCnt',
            offset       = 0x01C,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteCommand(   
            name         = 'CountReset',
            description  = 'Status counter reset',
            offset       = 0x020,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne
        ))


        for i in range(maxBuffers):

            self.add(pr.RemoteVariable(
                name         = f'RemoteWriteAddress[{i}]',
                offset       = 0x100 + i*16,
                bitSize      = 32,
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'RemoteWriteSize[{i}]',
                offset       = 0x108 + i*16,
                bitSize      = 32,
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'RemoteReadAddress[{i}]',
                offset       = 0x200 + i*16,
                bitSize      = 32,
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'RemoteReadSize[{i}]',
                offset       = 0x400 + i*4,
                bitSize      = 32,
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'TotLatency[{i}]',
                offset       = 0x500 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'GpuLatency[{i}]',
                offset       = 0x504 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'WrLatency[{i}]',
                offset       = 0x508 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            )) 

            self.add(pr.RemoteVariable(
                name         = f'RdLatency[{i}]',
                offset       = 0x50C + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            )) 

    def countReset(self):
        self.CountReset()        

