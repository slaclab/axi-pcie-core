import rogue

class AxiPcieDma(object):
    def __init__(self, driverPath, numLanes, destList):

        # Create PCIE memory mapped interface
        if (driverPath != 'sim'):
            # BAR0 access
            self.memMap = rogue.hardware.axi.AxiMemMap(driverPath)
            self.dmaStreams = [{dest:rogue.hardware.axi.AxiStreamDma(driverPath, (0x100*lane)|dest) for dest in destList} for lane in range(numLanes)]             
        else:
            # FW/SW co-simulation
            self.memMap = rogue.interfaces.memory.TcpClient('localhost',8000)
            self.dmaStreams = [{dest:rogue.interfaces.stream.TcpClient('localhost', 8002+(512*lane)+2*dest) for dest in destList} for lane in range(numLanes)]

            



        
