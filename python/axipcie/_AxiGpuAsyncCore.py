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

        #-----------------------------------------------------------------------------
        # There are lots of RemoteVariables in this device that are "read only"
        # But if you look at the firmware, you will noticed that they are "read/write"
        # The reason why they are "read only in this code is because it is the
        # Linux kernel driver that is intended to write and update this remote variables
        # and NOT the userspace
        #-----------------------------------------------------------------------------
        kernelVarMode = 'RO'

        self.add(pr.RemoteVariable(
            name         = 'AxiReadCache',
            offset       = 0x0004,
            bitSize      = 4,
            bitOffset    = 0,
            mode         = kernelVarMode,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxiWriteCache',
            offset       = 0x0004,
            bitSize      = 4,
            bitOffset    = 8,
            mode         = kernelVarMode,
        ))

        self.add(pr.RemoteVariable(
            name         = 'BusWidth',
            offset       = 0x0004,
            bitSize      = 8,
            bitOffset    = 16,
            disp         = '{}',
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'MaxBuffers',
            offset       = 0x0004,
            bitSize      = 8,
            bitOffset    = 24,
            disp         = '{}',
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteCount',
            offset       = 0x0008,
            bitSize      = 8,
            bitOffset    = 0,
            disp         = '{}',
            mode         = kernelVarMode,
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteEnable',
            offset       = 0x0008,
            bitSize      = 1,
            bitOffset    = 8,
            mode         = kernelVarMode,
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadCount',
            offset       = 0x0008,
            bitSize      = 8,
            bitOffset    = 16,
            disp         = '{}',
            mode         = kernelVarMode,
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadEnable',
            offset       = 0x0008,
            bitSize      = 1,
            bitOffset    = 24,
            mode         = kernelVarMode,
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RxFrameCnt',
            offset       = 0x0010,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'TxFrameCnt',
            offset       = 0x0014,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteAxiErrorCnt',
            offset       = 0x0018,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadAxiErrorCnt',
            offset       = 0x001C,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteCommand(
            name         = 'CountReset',
            description  = 'Status counter reset',
            offset       = 0x0020,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteAxiErrorVal',
            offset       = 0x0024,
            bitSize      = 4,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadAxiErrorVal',
            offset       = 0x0028,
            bitSize      = 3,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        for i in range(2):
            self.add(pr.RemoteVariable(
                name         = f'DynamicRouteMasks[{i}]',
                offset       = 0x002C,
                bitSize      = 8,
                bitOffset    = 16*i+0,
                mode         = 'RO',
                pollInterval = 1,
                hidden       = True,
            ))

            self.add(pr.RemoteVariable(
                name         = f'DynamicRouteDests[{i}]',
                offset       = 0x002C,
                bitSize      = 8,
                bitOffset    = 16*i+8,
                mode         = 'RO',
                pollInterval = 1,
                hidden       = True,
            ))

        self.add(pr.RemoteVariable(
            name         = 'VersionNumber',
            offset       = 0x0030,
            bitSize      = 8,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'axiWriteTimeoutErrorCnt',
            offset       = 0x0034,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name    = 'AxisDeMuxSelect',
            offset  = 0x0038,
            bitSize = 1,
            mode    = 'RW', # Exposed to userspace as read/write
            enum    = {
                0x0: 'CPU_path',
                0x1: 'GPU_path',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'minWriteBuffer',
            description  = 'Minimum number of write buffers availible since CountReset()',
            offset       = 0x003C,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'minReadBuffer',
            description  = 'Minimum number of read buffers availible since CountReset()',
            offset       = 0x0040,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        for i in range(maxBuffers):

            self.add(pr.RemoteVariable(
                name         = f'RemoteWriteAddressL[{i}]',
                offset       = 0x1000 + i*16,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'RemoteWriteAddressH[{i}]',
                offset       = 0x1004 + i*16,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'RemoteWriteSize[{i}]',
                offset       = 0x1008 + i*16,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'RemoteReadAddressL[{i}]',
                offset       = 0x2000 + i*16,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'RemoteReadAddressH[{i}]',
                offset       = 0x2004 + i*16,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'RemoteReadSize[{i}]',
                offset       = 0x2008 + i*4,
                bitSize      = 32,
                mode         = kernelVarMode,
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'TotLatency[{i}]',
                offset       = 0x3000 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'GpuLatency[{i}]',
                offset       = 0x3004 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            ))

            self.add(pr.RemoteVariable(
                name         = f'WrLatency[{i}]',
                offset       = 0x3008 + i*16,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                pollInterval = 1,
            ))

    def countReset(self):
        self.CountReset()
