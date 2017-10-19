import pyrogue as pr

LINK_SPEED_TABLE = {
    '3.125' : {
        'CPLL_CFG0'      : 0x21F8,
        'CPLL_CFG2'      : 0x0004,
        'CPLL_FBDIV'     : 5,
        'PMA_RSV1'       : 0xE000,
        'RXCDR_CFG2'     : 0x0756,
        'RXOUT_DIV'      : 2,
        'TXOUT_DIV'      : 2,
        'TX_PROGDIV_CFG' : 57762, #20.0        
    }
    '2.5' : {
        'CPLL_CFG0'      : 0x67F8,
        'CPLL_CFG2'      : 0x0007,
        'CPLL_FBDIV'     : 4,
        'PMA_RSV1'       : 0xF000,
        'RXCDR_CFG2'	 : 0x0756,
        'RXOUT_DIV'      : 2,
        'TXOUT_DIV'      : 2,
        'TX_PROGDIV_CFG' : 57762, #20.0
    }
    '1.25' : {
        'CPLL_CFG0'      : 0x67F8 ,
        'CPLL_CFG2'      : 0x0007 ,
        'CPLL_FBDIV'     : 4,
        'PMA_RSV1'       : 0xF000,
        'RXCDR_CFG2'	 : 0x0746,
        'RXOUT_DIV'      : 4,
        'TXOUT_DIV'      : 4,
        'TX_PROGDIV_CFG' : 57766, #40.0        
    }
    '5.0' : {
        'CPLL_CFG0'      : 0x67F8 ,
        'CPLL_CFG2'      : 0x0007 ,,
        'CPLL_FBDIV'     : 4,
        'PMA_RSV1'       : 0xF000,
        'RXCDR_CFG2'	 : 0x0766,
        'RXOUT_DIV'      : 1
        'TXOUT_DIV'      : 1
        'TX_PROGDIV_CFG' : 57760, #10.0
    }
    '6.125' : {
        'CPLL_CFG0'      : 0x21F8,
        'CPLL_CFG2'      : 0x0004,
        'CPLL_FBDIV'     : 5,
        'PMA_RSV1'       : 0xe000,
         'RXCDR_CFG2'	 : 0x0766,
        'RXOUT_DIV'      : 1
        'TXOUT_DIV'      : 1
        'TX_PROGDIV_CFG' : 57760, #10.0
    }
}

class AppPgp2bLane(pr.Device):
    def __init__(self, *,
                 name='AppPgp2bLane',
                 description=''
                 **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        self.add(surf.pgp.Pgp2bAxi(offset=0x000))
        self.add(surf.xilinx.Gthe3Channel(offset=0x800))

        self.add(pr.LinkVariable(
            name='LinkRate',
            disp=list(LINK_SPEED_TABLE.keys())
            linkedSet=self.setTxLinkRate))

    def setLinkRate(value):
        params = LINK_SPEED_TABLE[value]
        for k,v in params.items():
            self.Gthe3Channel.node(k).set(v)
        # Need to reset when done

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