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

import axipcie
import click

class AxiPcieCore(pr.Device):
    """This class maps to axi-pcie-core/shared/rtl/AxiPcieReg.vhd"""
    def __init__(self,
                 description = 'Base components of the PCIe firmware core',
                 useBpi      = False,
                 useSpi      = False,
                 numDmaLanes = 1,
                 **kwargs):
        super().__init__(description=description, **kwargs)

        self.numDmaLanes = numDmaLanes
        self.startArmed  = True

        # PCI PHY status
        self.add(xil.AxiPciePhy(
            offset       = 0x10000,
            expand       = False,
        ))

        # AxiVersion Module
        self.add(axipcie.PcieAxiVersion(
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
                    addrMode     =  True, # True = 32-bit Address Mode
                    hidden       =  True,
                ))

        # DMA AXI Stream Inbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'DmaIbAxisMon',
            offset      = 0x60000,
            numberLanes = self.numDmaLanes,
            expand      = False,
        ))

        # DMA AXI Stream Outbound Monitor
        self.add(axi.AxiStreamMonAxiL(
            name        = 'DmaObAxisMon',
            offset      = 0x70000,
            numberLanes = self.numDmaLanes,
            expand      = False,
        ))

    def _start(self):
        super()._start()
        DMA_SIZE_G = self.AxiVersion.DMA_SIZE_G.get()
        if ( self.numDmaLanes is not DMA_SIZE_G ) and (self.startArmed):
            self.startArmed = False
            click.secho(f'WARNING: {self.path}.numDmaLanes = {self.numDmaLanes} != {self.path}.AxiVersion.DMA_SIZE_G = {DMA_SIZE_G}', bg='cyan')
