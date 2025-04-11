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
import rogue

import threading
import time
import queue

class _Regs(pr.Device):
    def __init__(self, pollPeriod=0.0, **kwargs):
        super().__init__(**kwargs)

        self._pollPeriod = pollPeriod

        self._queue = queue.Queue()
        self._pollThread = threading.Thread(target=self._pollWorker)
        self._pollThread.start()

        groups = ['NoStream','NoState','NoConfig']

        self.add(pr.RemoteVariable(
            name      = 'CONTROL_REG',
            mode      = 'RW',
            offset    = 0x28018,
            groups    = groups,
            bitSize   = 32,
            bitOffset = 0,
        ))

        self.add(pr.RemoteVariable(
            name      = 'HOST_MSG_OFFSET_REG',
            mode      = 'RW',
            offset    = 0x28300,
            groups    = groups,
            bitSize   = 32,
            bitOffset = 0,
            value     = 0x1000,
        ))

        self.add(pr.RemoteVariable(
            name      = 'HOST_MSG_ERR_REG',
            mode      = 'RO',
            offset    = 0x28304,
            groups    = groups,
            bitSize   = 32,
            bitOffset = 0,
        ))

        self.add(pr.RemoteVariable(
            name        = 'MAILBOX',
            offset      = 0x29000,
            mode        = 'RW',
            numValues   = 256,
            valueBits   = 32,
            valueStride = 32,
            verify      = False,
        ))

    def proxyTransaction(self, transaction):
        self._queue.put(transaction)

    def _pollWorker(self):
        while True:
            transaction = self._queue.get()
            if transaction is None:
                return
            with self._memLock, transaction.lock():

                if transaction.type() == rogue.interfaces.memory.Write:
                    transaction.error('AXIL Write tranactions are not supported')
                    continue

                #######################################################################################
                # 1. The host checks the availability of the mailbox by confirming CONTROL_REG[5] is 0.
                #######################################################################################

                while (self.CONTROL_REG.get(read=True)&0x20) != 0:
                    time.sleep(self._pollPeriod)

                ######################################################
                # 2. The host writes a request message to the mailbox.
                ######################################################

                opcode  = (transaction.address() >>24)&0x7F # BIT30:BIT24
                cageSel = (transaction.address() >>20)&0xF  # BIT23:BIT20
                pageSel = (transaction.address() >>12)&0xFF # BIT19:BIT12
                wordSel = (transaction.address() >>2)&0x3FF # BIT11:BIT2

                # print(f'CONTROL_REG {self.CONTROL_REG.get(read=True):x}')
                # print(f'HOST_MSG_OFFSET_REG {self.HOST_MSG_OFFSET_REG.get(read=True):x}')
                # print(f'Address {transaction.address():x}')
                # print(f'opcode {opcode:x}')
                # print(f'cageSel {cageSel:x}')
                # print(f'pageSel {pageSel:x}')
                # print(f'wordSel {wordSel:x}')

                CMS_OP_CARD_INFO_REQ = 0x04
                CMS_OP_READ_MODULE_LOW_SPEED_IO = 0x0D
                CMS_OP_BYTE_READ_MODULE_I2C = 0x0F

                ###########################################################
                if opcode == CMS_OP_CARD_INFO_REQ:
                    self.MAILBOX.set(index=0, value=0x04000000, write=True)
                ###########################################################
                elif opcode == CMS_OP_READ_MODULE_LOW_SPEED_IO:
                    self.MAILBOX.set(index=0, value=0x0D000000, write=True)
                    self.MAILBOX.set(index=1, value=cageSel,    write=True)
                ###########################################################
                elif opcode == CMS_OP_BYTE_READ_MODULE_I2C:
                    self.MAILBOX.set(index=0, value=0x0F000000, write=True)
                    self.MAILBOX.set(index=1, value=cageSel,    write=True)
                    self.MAILBOX.set(index=2, value=pageSel,    write=True)
                    self.MAILBOX.set(index=3, value=0,          write=True)
                    self.MAILBOX.set(index=4, value=wordSel,    write=True)
                ###########################################################
                else:
                    transaction.error('Unknown operation')
                    continue
                ###########################################################

                ######################################################################################################
                # 3. The host sets CONTROL_REG[5] to 1 to indicate a new request message is available to CMS firmware.
                ######################################################################################################

                # self.CONTROL_REG.set(value=0x20, write=True)

                #######################################################################################################################
                # 4. The host polls CONTROL_REG[5] until CMS firmware sets to 0, indicating the CMS response message is in the mailbox.
                #######################################################################################################################

                while (self.CONTROL_REG.get(read=True)&0x20) != 0:
                    time.sleep(self._pollPeriod)

                ################################################################################
                # 5. The host reads HOST_MSG_ERROR_REG to confirm no message errors are present.
                ################################################################################

                resp = self.HOST_MSG_ERR_REG.get(read=True)
                if resp != 0:
                    transaction.error(f'AXIL tranaction failed with RESP: {resp}')
                    continue

                #####################################################################################
                # 6. If no errors are reported, the host reads the response message from the mailbox.
                #####################################################################################

                ###########################################################
                if opcode == CMS_OP_CARD_INFO_REQ:
                    data = self.MAILBOX.get(index=(1+wordSel), read=True)
                ###########################################################
                elif opcode == CMS_OP_READ_MODULE_LOW_SPEED_IO:
                    data = self.MAILBOX.get(index=(0x8//4), read=True)
                ###########################################################
                elif opcode == CMS_OP_BYTE_READ_MODULE_I2C:
                    data = self.MAILBOX.get(index=(0x14//4), read=True)
                ###########################################################
                else:
                    transaction.error('Unknown operation')
                    continue
                ###########################################################

                # Close out the read transaction
                dataBa = bytearray(data.to_bytes(4, 'little', signed=False))
                transaction.setData(dataBa, 0)
                transaction.done()

    def _stop(self):
        self._queue.put(None)
        self._pollThread.join()

class _ProxySlave(rogue.interfaces.memory.Slave):

    def __init__(self, regs):
        super().__init__(4,4)
        self._regs = regs

    def _doTransaction(self, transaction):
        #print('_ProxySlave._doTransaction')
        self._regs.proxyTransaction(transaction)

class CmsProxy(pr.Device):

    def __init__(self, hidden=True, pollPeriod=0.0, **kwargs):
        super().__init__(hidden=hidden, **kwargs)

        self.add(_Regs(
            name    = 'Regs',
            memBase = self,
            offset  = 0x0000,
            hidden  = hidden,
            pollPeriod = pollPeriod,
        ))
        self.proxy = _ProxySlave(self.Regs)

    def add(self, node):
        pr.Node.add(self, node)

        if isinstance(node, pr.Device):
            if node._memBase is None:
                node._setSlave(self.proxy)
