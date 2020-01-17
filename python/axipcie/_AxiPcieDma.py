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


            



        
