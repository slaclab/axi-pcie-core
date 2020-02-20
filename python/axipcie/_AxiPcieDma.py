#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import rogue
from collections import defaultdict

def createAxiPcieMemMap(driverPath, host='localhost', port=8000):
    """Provides BAR0 access to AxiPcieCore"""
    if driverPath != 'sim':
        return rogue.hardware.axi.AxiMemMap(driverPath)
    else:
        return rogue.interfaces.memory.TcpClient(host, port)

def createAxiPcieDmaStreams(driverPath, streamMap, host='localhost', basePort=8000):
    """Provides DMA stream access for AxiPcieCore"""
    d = defaultdict(dict)
    for lane, dests in streamMap.items():
        for dest in dests:
            if driverPath != 'sim':
                d[lane][dest] = rogue.hardware.axi.AxiStreamDma(driverPath, (0x100*lane)|dest, True)
            else:
                d[lane][dest] = rogue.interfaces.stream.TcpClient(host, (basePort+2)+(512*lane)+2*dest)
    return d
