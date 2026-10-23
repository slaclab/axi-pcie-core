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

class AxiPcieRegRespMon(pr.Device):
    """Error responses on the non-proxy I2C path, which BAR0 reports as OK."""
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        respEnum = {0: 'OK', 1: 'EXOK', 2: 'SLVERR', 3: 'DECERR'}

        self.add(pr.RemoteVariable(
            name         = 'RdErrCnt',
            description  = 'Reads that responded with an error',
            offset       = 0x00,
            bitSize      = 32,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WrErrCnt',
            description  = 'Writes that responded with an error',
            offset       = 0x04,
            bitSize      = 32,
            mode         = 'RO',
            disp         = '{:d}',
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RdErrAddr',
            description  = 'BAR0 address of the last failing read',
            offset       = 0x08,
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'WrErrAddr',
            description  = 'BAR0 address of the last failing write',
            offset       = 0x0C,
            bitSize      = 32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'RdErrResp',
            description  = 'Response code of the last failing read',
            offset       = 0x10,
            bitOffset    = 0,
            bitSize      = 2,
            mode         = 'RO',
            enum         = respEnum,
        ))

        self.add(pr.RemoteVariable(
            name         = 'WrErrResp',
            description  = 'Response code of the last failing write',
            offset       = 0x10,
            bitOffset    = 8,
            bitSize      = 2,
            mode         = 'RO',
            enum         = respEnum,
        ))

        self.add(pr.RemoteCommand(
            name         = 'CntRst',
            description  = 'Clears the counters and the last-error record',
            offset       = 0x14,
            bitSize      = 1,
            function     = pr.BaseCommand.touchOne,
        ))

    def countReset(self):
        self.CntRst()
