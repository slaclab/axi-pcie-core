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
import surf.axi             as axi

class PcieAxiVersion(axi.AxiVersion):
    def __init__(self,
            name             = 'AxiVersion',
            description      = 'AXI-Lite Version Module',
            numUserConstants = 0,
            **kwargs):
        super().__init__(
            name        = name,
            description = description,
            **kwargs
        )

        self.add(pr.RemoteVariable(
            name         = 'DMA_SIZE_G',
            offset       = 0x400+(4*0),
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'Reserved',
            offset       = 0x400+(4*1),
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DRIVER_TYPE_ID_G',
            offset       = 0x400+(4*2),
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'XIL_DEVICE_G',
            offset       = 0x400+(4*3),
            bitSize      = 32,
            mode         = 'RO',
            enum        = {
                0x0: 'ULTRASCALE',
                0x1: '7SERIES',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_CLK_FREQ_C',
            offset       = 0x400+(4*4),
            bitSize      = 32,
            mode         = 'RO',
            disp         = '{:d}',
            units        = 'Hz',
        ))

        self.add(pr.RemoteVariable(
            name         = 'BOOT_PROM_G',
            offset       = 0x400+(4*5),
            bitSize      = 32,
            mode         = 'RO',
            enum        = {
                0x0: 'BPI',
                0x1: 'SPIx8',
                0x2: 'SPIx4',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TDATA_BYTES_C',
            offset       = 0x400+(4*6),
            bitSize      = 8,
            bitOffset    = 24,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TDEST_BITS_C',
            offset       = 0x400+(4*6),
            bitSize      = 4,
            bitOffset    = 20,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TUSER_BITS_C',
            offset       = 0x400+(4*6),
            bitSize      = 4,
            bitOffset    = 16,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TID_BITS_C',
            offset       = 0x400+(4*6),
            bitSize      = 4,
            bitOffset    = 12,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TKEEP_MODE_C',
            offset       = 0x400+(4*6),
            bitSize      = 4,
            bitOffset    = 8,
            mode         = 'RO',
            enum        = {
                0x0: 'TKEEP_NORMAL_C',
                0x1: 'TKEEP_COMP_C',
                0x2: 'TKEEP_FIXED_C',
                0x3: 'TKEEP_COUNT_C',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TUSER_MODE_C',
            offset       = 0x400+(4*6),
            bitSize      = 4,
            bitOffset    = 4,
            mode         = 'RO',
            enum        = {
                0x0: 'TUSER_NORMAL_C',
                0x1: 'TUSER_FIRST_LAST_C',
                0x2: 'TUSER_LAST_C',
                0x3: 'TUSER_NONE_C',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'DMA_AXIS_CONFIG_G_TSTRB_EN_C',
            offset       = 0x400+(4*6),
            bitSize      = 1,
            bitOffset    = 1,
            mode         = 'RO',
            base         = pr.Bool,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AppReset',
            offset       = 0x400+(4*6),
            bitSize      = 1,
            bitOffset    = 0,
            mode         = 'RO',
            base         = pr.Bool,
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AXI_PCIE_CONFIG_C_ADDR_WIDTH_C',
            offset       = 0x400+(4*7),
            bitSize      = 8,
            bitOffset    = 24,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'AXI_PCIE_CONFIG_C_DATA_BYTES_C',
            offset       = 0x400+(4*7),
            bitSize      = 8,
            bitOffset    = 16,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'AXI_PCIE_CONFIG_C_ID_BITS_C',
            offset       = 0x400+(4*7),
            bitSize      = 8,
            bitOffset    = 8,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = 'AXI_PCIE_CONFIG_C_LEN_BITS_C',
            offset       = 0x400+(4*7),
            bitSize      = 8,
            bitOffset    = 0,
            mode         = 'RO',
            disp         = '{:d}',
        ))

        self.add(pr.RemoteVariable(
            name         = "AppClkFreq",
            description  = "Application Clock Frequency",
            offset       = 0x400+(4*8),
            units        = 'Hz',
            disp         = '{:d}',
            mode         = "RO",
            pollInterval = 1
        ))

        self.add(pr.RemoteVariable(
            name         = 'PCIE_HW_TYPE_G',
            offset       = 0x400+(4*9),
            bitSize      = 32,
            bitOffset    = 0,
            mode         = 'RO',
            enum        = {
                0x00_00_00_00: 'Undefined',
                0x00_00_00_01: 'AlphaDataKu3',
                0x00_00_00_02: 'BittWareXupVv8',
                0x00_00_00_03: 'SlacPgpCardG3',
                0x00_00_00_04: 'SlacPgpCardG4',
                0x00_00_00_05: 'XilinxAc701',
                0x00_00_00_06: 'XilinxAlveoU50',
                0x00_00_00_07: 'XilinxAlveoU200',
                0x00_00_00_08: 'XilinxAlveoU250',
                0x00_00_00_09: 'XilinxAlveoU280',
                0x00_00_00_0A: 'XilinxKc705',
                0x00_00_00_0B: 'XilinxKcu105',
                0x00_00_00_0C: 'XilinxKcu116',
                0x00_00_00_0D: 'XilinxKcu1500',
                0x00_00_00_0E: 'XilinxVcu128',
                0x00_00_00_0F: 'XilinxAlveoU55C',
            },
        ))
