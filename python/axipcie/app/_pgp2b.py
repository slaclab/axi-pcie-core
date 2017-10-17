import pyrogue as pr

class AppPgp2bLane(pr.Device):
    def __init__(self, *,
                 name='AppPgp2bLane',
                 description=''
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        self.add(surf.pgp.Pgp2bAxi(offset=0x000))
        self.add(surf.xilinx.Gthe3Channel(offset=0x800))

class AppPgp2bQuad(pr.Device):
    def __init__(self, *,
                 name='AppPgp2bLane',
                 description='',
                 numLinks=4,
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        self.addNodes(
            nodeClass=AppPgp2bLane,
            number=numLinks,
            offset=0x000,
            stride=0x1000)
