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

        # PCA9555 Input/Output port byte registers are each mapped to their own
        # AXI-Lite word (low byte significant). Per the XUP-VV8 schematic, each
        # nibble carries one QSFP slot:
        #   Port 0 (IP @ 0x00, OP @ 0x08) bits [3:0]=slot 0, bits [7:4]=slot 1
        #   Port 1 (IP @ 0x04, OP @ 0x0C) bits [3:0]=slot 2, bits [7:4]=slot 3
        # Within each nibble: bit0=PRSNT_L, bit1=INT_L, bit2=LP, bit3=RST_L.
        # Each 4-bit RemoteVariable below composes [slot0, slot1, slot2, slot3].

        self.add(pr.RemoteVariable(
            name        = 'QSFP_PRSNT_L',
            description = 'Per-slot QSFP module presence (0=present, 1=absent), bit[i]=slot[i]',
            offset      = [0x00, 0x00, 0x04, 0x04],
            bitOffset   = [0, 4, 0, 4],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'QSFP_INT_L',
            description = 'Per-slot QSFP interrupt (0=active, 1=inactive), bit[i]=slot[i]',
            offset      = [0x00, 0x00, 0x04, 0x04],
            bitOffset   = [1, 5, 1, 5],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'QSFP_LP',
            description = 'Per-slot QSFP low-power mode (1=low-power, 0=normal), bit[i]=slot[i]',
            offset      = [0x08, 0x08, 0x0C, 0x0C],
            bitOffset   = [2, 6, 2, 6],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'QSFP_RST_L',
            description = 'Per-slot QSFP reset (0=reset asserted, 1=de-asserted), bit[i]=slot[i]',
            offset      = [0x08, 0x08, 0x0C, 0x0C],
            bitOffset   = [3, 7, 3, 7],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
        ))

        # PCA9555 Polarity Inversion (regs 0x04/0x05 @ AXI 0x10/0x14).
        # Expected value: 0 for all bits (no inversion).
        self.add(pr.RemoteVariable(
            name        = 'POL_QSFP_PRSNT_L',
            description = 'Polarity inversion for PRSNT_L (expect 0), bit[i]=slot[i]',
            offset      = [0x10, 0x10, 0x14, 0x14],
            bitOffset   = [0, 4, 0, 4],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'POL_QSFP_INT_L',
            description = 'Polarity inversion for INT_L (expect 0), bit[i]=slot[i]',
            offset      = [0x10, 0x10, 0x14, 0x14],
            bitOffset   = [1, 5, 1, 5],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'POL_QSFP_LP',
            description = 'Polarity inversion for LP (expect 0), bit[i]=slot[i]',
            offset      = [0x10, 0x10, 0x14, 0x14],
            bitOffset   = [2, 6, 2, 6],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'POL_QSFP_RST_L',
            description = 'Polarity inversion for RST_L (expect 0), bit[i]=slot[i]',
            offset      = [0x10, 0x10, 0x14, 0x14],
            bitOffset   = [3, 7, 3, 7],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        # PCA9555 I/O Configuration (regs 0x06/0x07 @ AXI 0x18/0x1C).
        # 1=input, 0=output. Expected: PRSNT_L/INT_L=1 (input), LP/RST_L=0 (output).
        self.add(pr.RemoteVariable(
            name        = 'CFG_QSFP_PRSNT_L',
            description = 'Direction config for PRSNT_L (1=input, expect 1), bit[i]=slot[i]',
            offset      = [0x18, 0x18, 0x1C, 0x1C],
            bitOffset   = [0, 4, 0, 4],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'CFG_QSFP_INT_L',
            description = 'Direction config for INT_L (1=input, expect 1), bit[i]=slot[i]',
            offset      = [0x18, 0x18, 0x1C, 0x1C],
            bitOffset   = [1, 5, 1, 5],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'CFG_QSFP_LP',
            description = 'Direction config for LP (0=output, expect 0), bit[i]=slot[i]',
            offset      = [0x18, 0x18, 0x1C, 0x1C],
            bitOffset   = [2, 6, 2, 6],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'CFG_QSFP_RST_L',
            description = 'Direction config for RST_L (0=output, expect 0), bit[i]=slot[i]',
            offset      = [0x18, 0x18, 0x1C, 0x1C],
            bitOffset   = [3, 7, 3, 7],
            bitSize     = [1, 1, 1, 1],
            mode        = 'RW',
            hidden      = True,
        ))
