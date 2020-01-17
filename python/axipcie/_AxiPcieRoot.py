import axipcie as pcie

import pyrogue as pr
import rogue

class AxiPcieRoot(pr.Root):
    def __init__(self, dev, **kwargs):
        super().__init__(**kwargs)

        memMap = rogue.hardware.axi.AxiMemMap(dev)

        self.add(pcie.AxiPcieCore(
            memBase = memMap,
            useBpi = True,
            useSpi = True))
