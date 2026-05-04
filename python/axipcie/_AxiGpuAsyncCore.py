#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr
import surf.axi as axi

class AxiGpuAsyncBuffer(pr.Device):
    def __init__(self, index=0, **kwargs):
        super().__init__(**kwargs)

        #-----------------------------------------------------------------------------
        # There are lots of RemoteVariables in this device that are "read only"
        # But if you look at the firmware, you will noticed that they are "read/write"
        # The reason why they are "read only in this code is because it is the
        # Linux kernel driver that is intended to write and update this remote variables
        # and NOT the userspace
        #-----------------------------------------------------------------------------
        kernelVarMode = 'RO'

        self.add(pr.RemoteVariable(
            name         = 'RemoteReadSize',
            offset       = (0x0002_B000-0x0002_8000) + index*4,
            bitSize      = 32,
            mode         = kernelVarMode,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RemoteWriteAddress',
            offset       = (0x0002_C000-0x0002_8000) + index*8,
            bitSize      = 64,
            mode         = kernelVarMode,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RemoteReadAddress',
            offset       = (0x0002_E000-0x0002_8000) + index*8,
            bitSize      = 64,
            mode         = kernelVarMode,
        ))

class AxiGpuAsyncCore(pr.Device):
    def __init__(self, showBuffers=False, showErrorCnt=False,
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
            name         = 'MaxBuffers',
            offset       = 0x00,
            bitSize      = 11,
            bitOffset    = 0,
            disp         = '{}',
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxiReadCache',
            offset       = 0x04,
            bitSize      = 4,
            bitOffset    = 0,
            mode         = kernelVarMode,
            hidden       = True,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxiWriteCache',
            offset       = 0x04,
            bitSize      = 4,
            bitOffset    = 8,
            mode         = kernelVarMode,
            hidden       = True,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxiBusWidth',
            offset       = 0x04,
            bitSize      = 8,
            bitOffset    = 16,
            disp         = '{}',
            mode         = 'RO',
            units        = 'Bytes',
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteCount',
            description  = 'Nubmer of configured write buffers to use (zero inclusive)',
            offset       = 0x08,
            bitSize      = 10,
            bitOffset    = 0,
            disp         = '{}',
            mode         = kernelVarMode,
            pollInterval = 1 if kernelVarMode != 'RW' else 0,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteEnable',
            offset       = 0x08,
            bitSize      = 1,
            bitOffset    = 15,
            mode         = kernelVarMode,
            base         = pr.Bool,
            pollInterval = 1 if kernelVarMode != 'RW' else 0,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadCount',
            description  = 'Nubmer of configured read buffers to use (zero inclusive)',
            offset       = 0x08,
            bitSize      = 10,
            bitOffset    = 16,
            disp         = '{}',
            mode         = kernelVarMode,
           pollInterval  = 1 if kernelVarMode != 'RW' else 0,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadEnable',
            offset       = 0x08,
            bitSize      = 1,
            bitOffset    = 31,
            base         = pr.Bool,
            mode         = kernelVarMode,
            pollInterval = 1 if kernelVarMode != 'RW' else 0,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RxFrameCnt',
            offset       = 0x10,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'TxFrameCnt',
            offset       = 0x14,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteAxiErrorCnt',
            offset       = 0x18,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
            hidden       = not showErrorCnt,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadAxiErrorCnt',
            offset       = 0x1C,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
            hidden       = not showErrorCnt,
        ))

        self.add(pr.RemoteCommand(
            name         = 'CountReset',
            description  = 'Status counter reset',
            offset       = 0x20,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne
        ))

        self.add(pr.RemoteVariable(
            name         = 'WriteAxiErrorVal',
            offset       = 0x24,
            bitSize      = 4,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
            hidden       = not showErrorCnt,
        ))

        self.add(pr.RemoteVariable(
            name         = 'ReadAxiErrorVal',
            offset       = 0x28,
            bitSize      = 3,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
            hidden       = not showErrorCnt,
        ))

        self.add(pr.RemoteVariable(
            name         = 'VersionNumber',
            offset       = 0x30,
            bitSize      = 8,
            mode         = 'RO',
            disp         = '{}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxiWriteTimeoutErrorCnt',
            offset       = 0x34,
            bitSize      = 32,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
            hidden       = not showErrorCnt,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AxisDeMuxSelect',
            description  = 'Selects where the AXIS stream is sent/received from the CPU (debug) or the GPU (normal operation)',
            offset       = 0x38,
            bitSize      = 1,
            mode         = 'RW', # Exposed to userspace as read/write for debugging
            enum         = {
                0x0: 'CPU_path',
                0x1: 'GPU_path',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'MinWriteFreeList',
            description  = 'Minimum number of write buffers availible since CountReset()',
            offset       = 0x3C,
            bitSize      = 11,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'MaxReadQueueList',
            description  = 'Maximum number of read buffers being worked on since CountReset()',
            offset       = 0x40,
            bitSize      = 11,
            disp         = '{}',
            mode         = 'RO',
            pollInterval = 1,
        ))


        self.add(pr.RemoteVariable(
            name         = 'RemoteWriteMaxSize',
            description  = 'Configured maximum write buffer size to use (zero exclusive)',
            offset       = 0x60,
            bitSize      = 32,
            units        = 'Bytes',
            mode         = kernelVarMode,
            pollInterval = 1 if kernelVarMode != 'RW' else 0,
        ))


        # Define latency measurements with their base offsets and descriptions
        latency_metrics = [
            ('TotLatency',   0xC0, 'Measures time between start of DMA write to DMA read completed'),
            ('GpuLatency',   0xD0, 'Measures time between DMA write completion to GPU returning the free list buffer'),
            ('WrDmaLatency', 0xE0, 'Measures time between start of DMA write to DMA write completed'),
            ('RdDmaLatency', 0xF0, 'Measures time between start of DMA read to DMA read completed'),
        ]

        for name, base_offset, description in latency_metrics:
            # Current value
            self.add(pr.RemoteVariable(
                name         = name,
                description  = description,
                offset       = base_offset,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                units        = 'axiClk cycles',
                pollInterval = 1,
            ))

            # Max value
            self.add(pr.RemoteVariable(
                name         = f'{name}Max',
                description  = f'Maximum {name} measured after counter reset, counter reset clear this register to zero bits',
                offset       = base_offset + 0x4,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                units        = 'axiClk cycles',
                pollInterval = 1,
            ))

            # Min value
            self.add(pr.RemoteVariable(
                name         = f'{name}Min',
                description  = f'Minimum {name} measured after counter reset, counter reset clear this register to zero bits',
                offset       = base_offset + 0x8,
                bitSize      = 32,
                disp         = '{}',
                mode         = 'RO',
                units        = 'axiClk cycles',
                pollInterval = 1,
            ))

        # GPU AXI Stream Inbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'GpuIbAxisMon',
            offset      = (0x0002_8100-0x0002_8000),
            numberLanes = 1,
            expand      = True,
        ))

        # GPU AXI Stream Outbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'GpuObAxisMon',
            offset      = (0x0002_8200-0x0002_8000),
            numberLanes = 1,
            expand      = True,
        ))

        if showBuffers:
            for i in range(1024):
                self.add(AxiGpuAsyncBuffer(
                    name   = f'Buffer[{i}]',
                    offset = 0x0,
                    index  = i,
                ))

    def countReset(self):
        self.CountReset()
        self.GpuIbAxisMon.CntRst()
        self.GpuObAxisMon.CntRst()
