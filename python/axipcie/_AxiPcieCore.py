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
import surf.devices.micron  as micron
import surf.xilinx          as xil

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
        
class AxiPcieCore(pr.Device):
    def __init__(self,       
                 description = 'Base components of the PCIe firmware core',
                 useBpi      = False,
                 useSpi      = False,
                 numDmaLanes = 8,
                 **kwargs):
        super().__init__(description=description, **kwargs)

        # PCI PHY status
        self.add(xil.AxiPciePhy(            
            offset       = 0x10000, 
            expand       = False,
        ))
        
        # AxiVersion Module
        self.add(PcieAxiVersion(            
            offset       = 0x20000, 
            expand       = False,
        ))

        # Check if using BPI PROM
        if (useBpi):
            self.add(micron.AxiMicronP30(
                offset       =  0x30000,
                expand       =  False,                                    
                hidden       =  True,                                    
            ))         
        
        # Check if using SPI PROM
        if (useSpi):
            for i in range(2):
                self.add(micron.AxiMicronN25Q(
                    name         = f'AxiMicronN25Q[{i}]',
                    offset       =  0x40000 + (i * 0x10000),
                    expand       =  False,                                    
                    hidden       =  True,                                    
                ))
                
        # DMA AXI Stream Inbound Monitor        
        self.add(axi.AxiStreamMonitoring(            
            name        = 'DmaIbAxisMon', 
            offset      = 0x60000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))        

        # DMA AXI Stream Outbound Monitor        
        self.add(axi.AxiStreamMonitoring(            
            name        = 'DmaObAxisMon', 
            offset      = 0x70000, 
            numberLanes = numDmaLanes,
            expand      = False,
        ))
