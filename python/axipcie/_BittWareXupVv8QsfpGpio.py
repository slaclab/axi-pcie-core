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

class BittWareXupVv8QsfpGpio(pr.Device):
    def __init__(self,**kwargs):
        super().__init__(**kwargs)

        # Map QSFP signals
        nameList = [
            'QSFP_PRSNT_L[0]', # IO0_0
            'QSFP_INT_L[0]',   # IO0_1
            'QSFP_LP[0]',      # IO0_2
            'QSFP_RST_L[0]',   # IO0_3
            'QSFP_PRSNT_L[1]', # IO0_4
            'QSFP_INT_L[1]',   # IO0_5
            'QSFP_LP[1]',      # IO0_6
            'QSFP_RST_L[1]',   # IO0_7
            'QSFP_PRSNT_L[2]', # IO1_0
            'QSFP_INT_L[2]',   # IO1_1
            'QSFP_LP[2]',      # IO1_2
            'QSFP_RST_L[2]',   # IO1_3
            'QSFP_PRSNT_L[3]', # IO1_4
            'QSFP_INT_L[3]',   # IO1_5
            'QSFP_LP[3]',      # IO1_6
            'QSFP_RST_L[3]',   # IO1_7
        ]

        # The PCA9555 has two 8-bit ports (Port 0 and Port 1)
        for i in range(2):  # Port 0 and Port 1
            for j in range(8):  # Each has 8 bits
                idx = 8*i + j

                # Input Port registers (read-only)
                self.add(pr.RemoteVariable(
                    name        = f'IP_{nameList[idx]}',
                    description = 'Input Port registers',
                    offset      = (0x00 + i) << 2,
                    bitOffset   = j,
                    bitSize     = 1,
                    mode        = 'RO',
                ))

        # The PCA9555 has two 8-bit ports (Port 0 and Port 1)
        for i in range(2):  # Port 0 and Port 1
            for j in range(8):  # Each has 8 bits
                idx = 8*i + j
                # Output Port registers (read/write)
                self.add(pr.RemoteVariable(
                    name        = f'OP_{nameList[idx]}',
                    description = 'Output Port registers',
                    offset      = (0x02 + i) << 2,
                    bitOffset   = j,
                    bitSize     = 1,
                    mode        = 'RW',
                ))

        # The PCA9555 has two 8-bit ports (Port 0 and Port 1)
        for i in range(2):  # Port 0 and Port 1
            for j in range(8):  # Each has 8 bits
                idx = 8*i + j
                # Polarity Inversion registers (read/write)
                self.add(pr.RemoteVariable(
                    name        = f'POL_{nameList[idx]}',
                    description = 'Polarity Inversion registers',
                    offset      = (0x04 + i) << 2,
                    bitOffset   = j,
                    bitSize     = 1,
                    mode        = 'RW',
                ))

        # The PCA9555 has two 8-bit ports (Port 0 and Port 1)
        for i in range(2):  # Port 0 and Port 1
            for j in range(8):  # Each has 8 bits
                idx = 8*i + j
                # Configuration registers (read/write)
                self.add(pr.RemoteVariable(
                    name        = f'CFG_{nameList[idx]}',
                    description = 'I/O Configuration registers',
                    offset      = (0x06 + i) << 2,
                    bitOffset   = j,
                    bitSize     = 1,
                    mode        = 'RW',
                ))
