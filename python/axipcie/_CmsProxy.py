#-----------------------------------------------------------------------------
# https://docs.amd.com/r/en-US/pg348-cms-subsystem
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

# https://docs.amd.com/r/en-US/pg348-cms-subsystem/Using-the-Mailbox
class _Mailbox(pr.Device):
    def __init__(self, pollPeriod=0.0, **kwargs):
        super().__init__(**kwargs)

        self._pollPeriod = pollPeriod

        self._queue = queue.Queue()
        self._pollThread = threading.Thread(target=self._pollWorker)
        self._pollThread.start()

        groups = ['NoStream','NoState','NoConfig']

        self.add(pr.RemoteVariable(
            name      = 'HbmTempMonEnable',
            mode      = 'RW',
            offset    = 0x28018,
            bitSize   = 1,
            bitOffset = 27,
        ))

        self.add(pr.RemoteVariable(
            name      = 'QsfpGpioEnable',
            mode      = 'RW',
            offset    = 0x28018,
            bitSize   = 1,
            bitOffset = 26,
        ))

        self.add(pr.RemoteVariable(
            name      = 'RebootMicroBlaze',
            mode      = 'WO',
            offset    = 0x28018,
            bitSize   = 1,
            bitOffset = 6,
        ))


        self.add(pr.RemoteVariable(
            name      = 'CONTROL_REG[5]',
            mode      = 'RW',
            offset    = 0x28018,
            groups    = groups,
            bitSize   = 1,
            bitOffset = 5,
        ))

        self.add(pr.RemoteVariable(
            name      = 'ResetErrors',
            mode      = 'WO',
            offset    = 0x28018,
            bitSize   = 1,
            bitOffset = 1,
        ))

        self.add(pr.RemoteVariable(
            name      = 'ResetSensors',
            mode      = 'WO',
            offset    = 0x28018,
            bitSize   = 1,
            bitOffset = 0,
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
                    dataBa = bytearray(4)
                    transaction.getData(dataBa, 0)
                    data = int.from_bytes(dataBa, 'little', signed=False)

                #######################################################################################
                # 1. The host checks the availability of the mailbox by confirming CONTROL_REG[5] is 0.
                #######################################################################################

                while self.CONTROL_REG[5].get(read=True) != 0:
                    time.sleep(self._pollPeriod)

                ######################################################
                # 2. The host writes a request message to the mailbox.
                ######################################################

                opcode  = (transaction.address() >>24)&0x7F # BIT30:BIT24
                cageSel = (transaction.address() >>20)&0xF  # BIT23:BIT20
                pageSel = (transaction.address() >>12)&0xFF # BIT19:BIT12
                wordSel = (transaction.address() >>2)&0x3FF # BIT11:BIT2

                CMS_OP_CARD_INFO_REQ = 0x04
                CMS_OP_READ_MODULE_LOW_SPEED_IO = 0x0D
                CMS_OP_BYTE_READ_MODULE_I2C = 0x0F

                ###########################################################
                if opcode == CMS_OP_CARD_INFO_REQ:
                    if transaction.type() == rogue.interfaces.memory.Write:
                        transaction.error('CMS_OP_CARD_INFO_REQ are read only registers')
                        continue
                    self.MAILBOX.set(index=0, value=0x04000000, write=True)
                ###########################################################
                elif opcode == CMS_OP_READ_MODULE_LOW_SPEED_IO:
                    if transaction.type() == rogue.interfaces.memory.Write: # CMS_OP_WRITE_MODULE_LOW_SPEED_IO
                        self.MAILBOX.set(index=0, value=0x0E000000, write=True)
                        self.MAILBOX.set(index=1, value=cageSel,    write=True)
                        self.MAILBOX.set(index=2, value=data,       write=True)
                    else: # CMS_OP_READ_MODULE_LOW_SPEED_IO
                        self.MAILBOX.set(index=0, value=0x0D000000, write=True)
                        self.MAILBOX.set(index=1, value=cageSel,    write=True)
                ###########################################################
                elif opcode == CMS_OP_BYTE_READ_MODULE_I2C:
                    if transaction.type() == rogue.interfaces.memory.Write: # CMS_OP_WRITE_READ_MODULE_I2C
                        self.MAILBOX.set(index=0, value=0x10000000, write=True)
                        self.MAILBOX.set(index=1, value=cageSel,    write=True)
                        self.MAILBOX.set(index=2, value=pageSel,    write=True)
                        self.MAILBOX.set(index=3, value=0,          write=True)
                        self.MAILBOX.set(index=4, value=wordSel,    write=True)
                        self.MAILBOX.set(index=5, value=data,       write=True)
                    else: # CMS_OP_BYTE_READ_MODULE_I2C
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

                # print(f'CONTROL_REG[5] {self.CONTROL_REG[5].get(read=True):x}')
                # print(f'Address {transaction.address():x}')
                # print(f'opcode {opcode:x}')
                # print(f'cageSel {cageSel:x}')
                # print(f'pageSel {pageSel:x}')
                # print(f'wordSel {wordSel:x}')

                ######################################################################################################
                # 3. The host sets CONTROL_REG[5] to 1 to indicate a new request message is available to CMS firmware.
                ######################################################################################################

                self.CONTROL_REG[5].set(value=0x1, write=True)

                #######################################################################################################################
                # 4. The host polls CONTROL_REG[5] until CMS firmware sets to 0, indicating the CMS response message is in the mailbox.
                #######################################################################################################################

                while self.CONTROL_REG[5].get(read=True) != 0:
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
                if transaction.type() == rogue.interfaces.memory.Write:
                    transaction.done()
                ###########################################################
                elif opcode == CMS_OP_CARD_INFO_REQ:
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

    def __init__(self, mailbox):
        super().__init__(4,4)
        self._mailbox = mailbox

    def _doTransaction(self, transaction):
        self._mailbox.proxyTransaction(transaction)

class Status(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name        = 'REG_MAP_ID_REG',
            description = 'Register Map ID. (0x74736574)',
            mode        = 'RO',
            offset      = 0x0000,
        ))

        self.add(pr.RemoteVariable(
            name        = 'FW_VERSION_REG',
            description = 'Firmware Version',
            mode        = 'RO',
            offset      = 0x0004,
        ))

        self.add(pr.RemoteVariable(
            name        = 'STATUS_REG',
            description = 'CMS Status Register',
            mode        = 'RO',
            offset      = 0x0008,
        ))

        self.add(pr.RemoteVariable(
            name        = 'ERROR_REG',
            description = 'CMS Error Register',
            mode        = 'RO',
            offset      = 0x000C,
        ))

        self.add(pr.RemoteVariable(
            name        = 'PROFILE_NAME_REG',
            description = 'Software profile',
            mode        = 'RO',
            offset      = 0x0014,
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_PEX_MAX_REG',
            mode        = 'RO',
            offset      = 0x0020,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_PEX_AVG_REG',
            mode        = 'RO',
            offset      = 0x0024,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_PEX_INS_REG',
            mode        = 'RO',
            offset      = 0x0028,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_PEX_MAX_REG',
            mode        = 'RO',
            offset      = 0x002C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_PEX_AVG_REG',
            mode        = 'RO',
            offset      = 0x0030,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_PEX_INS_REG',
            mode        = 'RO',
            offset      = 0x0034,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_AUX_MAX_REG',
            mode        = 'RO',
            offset      = 0x0038,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_AUX_AVG_REG',
            mode        = 'RO',
            offset      = 0x003C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3_AUX_INS_REG',
            mode        = 'RO',
            offset      = 0x0040,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_MAX_REG',
            mode        = 'RO',
            offset      = 0x0044,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_AVG_REG',
            mode        = 'RO',
            offset      = 0x0048,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_INS_REG',
            mode        = 'RO',
            offset      = 0x004C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_BTM_MAX_REG',
            mode        = 'RO',
            offset      = 0x0050,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_BTM_AVG_REG',
            mode        = 'RO',
            offset      = 0x0054,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_BTM_INS_REG',
            mode        = 'RO',
            offset      = 0x0058,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'SYS_5V5_MAX_REG',
            mode        = 'RO',
            offset      = 0x005C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'SYS_5V5_AVG_REG',
            mode        = 'RO',
            offset      = 0x0060,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'SYS_5V5_INS_REG',
            mode        = 'RO',
            offset      = 0x0064,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_TOP_MAX_REG',
            mode        = 'RO',
            offset      = 0x0068,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_TOP_AVG_REG',
            mode        = 'RO',
            offset      = 0x006C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_TOP_INS_REG',
            mode        = 'RO',
            offset      = 0x0070,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V8_MAX_REG',
            mode        = 'RO',
            offset      = 0x0074,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V8_AVG_REG',
            mode        = 'RO',
            offset      = 0x0078,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V8_INS_REG',
            mode        = 'RO',
            offset      = 0x007C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC0V85_MAX_REG',
            mode        = 'RO',
            offset      = 0x0080,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC0V85_AVG_REG',
            mode        = 'RO',
            offset      = 0x0084,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC0V85_INS_REG',
            mode        = 'RO',
            offset      = 0x0088,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_TOP_MAX_REG',
            mode        = 'RO',
            offset      = 0x008C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_TOP_AVG_REG',
            mode        = 'RO',
            offset      = 0x0090,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DDR4_VPP_TOP_INS_REG',
            mode        = 'RO',
            offset      = 0x0094,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGT0V9AVCC_MAX_REG',
            mode        = 'RO',
            offset      = 0x0098,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGT0V9AVCC_AVG_REG',
            mode        = 'RO',
            offset      = 0x009C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGT0V9AVCC_INS_REG',
            mode        = 'RO',
            offset      = 0x00A0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_SW_MAX_REG',
            mode        = 'RO',
            offset      = 0x00A4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_SW_AVG_REG',
            mode        = 'RO',
            offset      = 0x00A8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_SW_INS_REG',
            mode        = 'RO',
            offset      = 0x00AC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGTAVTT_MAX_REG',
            mode        = 'RO',
            offset      = 0x00B0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGTAVTT_AVG_REG',
            mode        = 'RO',
            offset      = 0x00B4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'MGTAVTT_INS_REG',
            mode        = 'RO',
            offset      = 0x00B8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_BTM_MAX_REG',
            mode        = 'RO',
            offset      = 0x00BC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_BTM_AVG_REG',
            mode        = 'RO',
            offset      = 0x00C0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_BTM_INS_REG',
            mode        = 'RO',
            offset      = 0x00C4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12VPEX_I_IN_MAX_REG',
            mode        = 'RO',
            offset      = 0x00C8,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '12VPEX_I_IN_AVG_REG',
            mode        = 'RO',
            offset      = 0x00CC,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '12VPEX_I_IN_INS_REG',
            mode        = 'RO',
            offset      = 0x00D0,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_I_IN_MAX_REG',
            mode        = 'RO',
            offset      = 0x00D4,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_I_IN_AVG_REG',
            mode        = 'RO',
            offset      = 0x00D8,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX_I_IN_INS_REG',
            mode        = 'RO',
            offset      = 0x00DC,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_MAX_REG',
            mode        = 'RO',
            offset      = 0x00E0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_AVG_REG',
            mode        = 'RO',
            offset      = 0x00E4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_INS_REG',
            mode        = 'RO',
            offset      = 0x00E8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x00EC,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x00F0,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_I_INS_REG',
            mode        = 'RO',
            offset      = 0x00F4,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FPGA_TEMP_MAX_REG',
            mode        = 'RO',
            offset      = 0x00F8,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FPGA_TEMP_AVG_REG',
            mode        = 'RO',
            offset      = 0x00FC,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FPGA_TEMP_INS_REG',
            mode        = 'RO',
            offset      = 0x0100,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_TEMP_MAX_REG',
            mode        = 'RO',
            offset      = 0x0104,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_TEMP_AVG_REG',
            mode        = 'RO',
            offset      = 0x0108,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_TEMP_INS_REG',
            mode        = 'RO',
            offset      = 0x010C,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        for i in range(4):
            self.add(pr.RemoteVariable(
                name        = f'DIMM_TEMP{i}_MAX_REG',
                mode        = 'RO',
                offset      = 0x0110+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'DIMM_TEMP{i}_AVG_REG',
                mode        = 'RO',
                offset      = 0x0114+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'DIMM_TEMP{i}_INS_REG',
                mode        = 'RO',
                offset      = 0x0118+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

        for i in range(3):
            self.add(pr.RemoteVariable(
                name        = f'SE98_TEMP{i}_MAX_REG',
                mode        = 'RO',
                offset      = 0x0140+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'SE98_TEMP{i}_AVG_REG',
                mode        = 'RO',
                offset      = 0x0144+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'SE98_TEMP{i}_INS_REG',
                mode        = 'RO',
                offset      = 0x0148+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_SPEED_MAX_REG',
            mode        = 'RO',
            offset      = 0x0164,
            disp        = '{:,d}',
            units       = 'RPM',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_SPEED_AVG_REG',
            mode        = 'RO',
            offset      = 0x0168,
            disp        = '{:,d}',
            units       = 'RPM',
        ))

        self.add(pr.RemoteVariable(
            name        = 'FAN_SPEED_INS_REG',
            mode        = 'RO',
            offset      = 0x016C,
            disp        = '{:,d}',
            units       = 'RPM',
        ))

        for i in range(4):
            self.add(pr.RemoteVariable(
                name        = f'CAGE_TEMP{i}_MAX_REG',
                mode        = 'RO',
                offset      = 0x0170+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'CAGE_TEMP{i}_AVG_REG',
                mode        = 'RO',
                offset      = 0x0174+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

            self.add(pr.RemoteVariable(
                name        = f'CAGE_TEMP{i}_INS_REG',
                mode        = 'RO',
                offset      = 0x0178+i*0xC,
                disp        = '{:,d}',
                units       = 'degC',
            ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP1_MAX_REG',
            mode        = 'RO',
            offset      = 0x0260,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP1_AVG_REG',
            mode        = 'RO',
            offset      = 0x0264,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP1_INS_REG',
            mode        = 'RO',
            offset      = 0x0268,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC3V3_MAX_REG',
            mode        = 'RO',
            offset      = 0x026C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC3V3_AVG_REG',
            mode        = 'RO',
            offset      = 0x0270,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC3V3_INS_REG',
            mode        = 'RO',
            offset      = 0x0274,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3PEX_I_IN_MAX_REG',
            mode        = 'RO',
            offset      = 0x0278,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3PEX_I_IN_AVG_REG',
            mode        = 'RO',
            offset      = 0x027C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = '3V3PEX_I_IN_INS_REG',
            mode        = 'RO',
            offset      = 0x0280,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0284,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0288,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_I_INS_REG',
            mode        = 'RO',
            offset      = 0x028C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1V2_MAX_REG',
            mode        = 'RO',
            offset      = 0x0290,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1V2_AVG_REG',
            mode        = 'RO',
            offset      = 0x0294,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1V2_INS_REG',
            mode        = 'RO',
            offset      = 0x0298,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VPP2V5_MAX_REG',
            mode        = 'RO',
            offset      = 0x029C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VPP2V5_AVG_REG',
            mode        = 'RO',
            offset      = 0x02A0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VPP2V5_INS_REG',
            mode        = 'RO',
            offset      = 0x02A4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_MAX_REG',
            mode        = 'RO',
            offset      = 0x02A8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_AVG_REG',
            mode        = 'RO',
            offset      = 0x02AC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_IO_INS_REG',
            mode        = 'RO',
            offset      = 0x02B0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP2_MAX_REG',
            mode        = 'RO',
            offset      = 0x02B4,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP2_AVG_REG',
            mode        = 'RO',
            offset      = 0x02B8,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_TEMP2_INS_REG',
            mode        = 'RO',
            offset      = 0x02BC,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX1_MAX_REG',
            mode        = 'RO',
            offset      = 0x02C0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX1_AVG_REG',
            mode        = 'RO',
            offset      = 0x02C4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '12V_AUX1_INS_REG',
            mode        = 'RO',
            offset      = 0x02C8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_TEMP_MAX_REG',
            mode        = 'RO',
            offset      = 0x02CC,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_TEMP_AVG_REG',
            mode        = 'RO',
            offset      = 0x02D0,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_TEMP_INS_REG',
            mode        = 'RO',
            offset      = 0x02D4,
            disp        = '{:,d}',
            units       = 'degC',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_12V_POWER_MAX_REG',
            mode        = 'RO',
            offset      = 0x02D8,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_12V_POWER_AVG_REG',
            mode        = 'RO',
            offset      = 0x02DC,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_12V_POWER_INS_REG',
            mode        = 'RO',
            offset      = 0x02E0,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_3V3_POWER_MAX_REG',
            mode        = 'RO',
            offset      = 0x02E4,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_3V3_POWER_AVG_REG',
            mode        = 'RO',
            offset      = 0x02E8,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'PEX_3V3_POWER_INS_REG',
            mode        = 'RO',
            offset      = 0x02EC,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'AUX_3V3_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x02F0,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'AUX_3V3_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x02F4,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'AUX_3V3_I_INS_REG',
            mode        = 'RO',
            offset      = 0x02F8,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HOST_MSG_OFFSET_REG',
            mode        = 'RO',
            offset      = 0x0300,
        ))

        self.add(pr.RemoteVariable(
            name        = 'HOST_STATUS2_REG',
            mode        = 'RO',
            offset      = 0x030C,
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0314,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0318,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC1V2_I_INS_REG',
            mode        = 'RO',
            offset      = 0x031C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0320,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0324,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_I_INS_REG',
            mode        = 'RO',
            offset      = 0x0328,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX0_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x032C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX0_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0330,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX0_I_INS_REG',
            mode        = 'RO',
            offset      = 0x0334,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX1_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0338,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX1_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x033C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'V12_IN_AUX1_I_INS_REG',
            mode        = 'RO',
            offset      = 0x0340,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_MAX_REG',
            mode        = 'RO',
            offset      = 0x0344,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_AVG_REG',
            mode        = 'RO',
            offset      = 0x0348,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_INS_REG',
            mode        = 'RO',
            offset      = 0x034C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_PMC_MAX_REG',
            mode        = 'RO',
            offset      = 0x0350,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_PMC_AVG_REG',
            mode        = 'RO',
            offset      = 0x0354,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCAUX_PMC_INS_REG',
            mode        = 'RO',
            offset      = 0x0358,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCRAM_MAX_REG',
            mode        = 'RO',
            offset      = 0x035C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCRAM_AVG_REG',
            mode        = 'RO',
            offset      = 0x0360,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCRAM_INS_REG',
            mode        = 'RO',
            offset      = 0x0364,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'POWER_GOOD_INS_REG',
            mode        = 'RO',
            offset      = 0x0370,
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_POWER_MAX_REG',
            mode        = 'RO',
            offset      = 0x0374,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_POWER_AVG_REG',
            mode        = 'RO',
            offset      = 0x0378,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_POWER_INS_REG',
            mode        = 'RO',
            offset      = 0x037C,
            disp        = '{:,d}',
            units       = 'mW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_VCU_0V9_MAX_REG',
            mode        = 'RO',
            offset      = 0x0380,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_VCU_0V9_AVG_REG',
            mode        = 'RO',
            offset      = 0x0384,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCINT_VCU_0V9_INS_REG',
            mode        = 'RO',
            offset      = 0x0388,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '1V2_VCCIO_MAX_REG',
            mode        = 'RO',
            offset      = 0x038C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '1V2_VCCIO_AVG_REG',
            mode        = 'RO',
            offset      = 0x0390,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '1V2_VCCIO_INS_REG',
            mode        = 'RO',
            offset      = 0x0394,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTAVCC_MAX_REG',
            mode        = 'RO',
            offset      = 0x0398,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTAVCC_AVG_REG',
            mode        = 'RO',
            offset      = 0x039C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTAVCC_INS_REG',
            mode        = 'RO',
            offset      = 0x03A0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCSOC_MAX_REG',
            mode        = 'RO',
            offset      = 0x03B0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCSOC_AVG_REG',
            mode        = 'RO',
            offset      = 0x03B4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCCSOC_INS_REG',
            mode        = 'RO',
            offset      = 0x03B8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC_5V0_MAX_REG',
            mode        = 'RO',
            offset      = 0x03BC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC_5V0_AVG_REG',
            mode        = 'RO',
            offset      = 0x03C0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'VCC_5V0_INS_REG',
            mode        = 'RO',
            offset      = 0x03C4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '2V5_VPP23_MAX_REG',
            mode        = 'RO',
            offset      = 0x03C8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '2V5_VPP23_AVG_REG',
            mode        = 'RO',
            offset      = 0x03CC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = '2V5_VPP23_INS_REG',
            mode        = 'RO',
            offset      = 0x03D0,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTVCC_AUX_MAX_REG',
            mode        = 'RO',
            offset      = 0x03D4,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTVCC_AUX_AVG_REG',
            mode        = 'RO',
            offset      = 0x03D8,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'GTVCC_AUX_INS_REG',
            mode        = 'RO',
            offset      = 0x03DC,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1v2_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0410,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1v2_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0414,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HBM_1v2_I_INS_REG',
            mode        = 'RO',
            offset      = 0x0418,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_VCC1V5_MAX_REG',
            mode        = 'RO',
            offset      = 0x041C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_VCC1V5_AVG_REG',
            mode        = 'RO',
            offset      = 0x0420,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_VCC1V5_INS_REG',
            mode        = 'RO',
            offset      = 0x0424,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_MAX_REG',
            mode        = 'RO',
            offset      = 0x0428,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_AVG_REG',
            mode        = 'RO',
            offset      = 0x042C,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_INS_REG',
            mode        = 'RO',
            offset      = 0x0430,
            disp        = '{:,d}',
            units       = 'mV',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVTT_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0434,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVTT_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0438,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVTT_I_INS_REG',
            mode        = 'RO',
            offset      = 0x043C,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_I_MAX_REG',
            mode        = 'RO',
            offset      = 0x0440,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_I_AVG_REG',
            mode        = 'RO',
            offset      = 0x0444,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CMC_MGTAVCC_I_INS_REG',
            mode        = 'RO',
            offset      = 0x0448,
            disp        = '{:,d}',
            units       = 'mA',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CORE_BUILD_VERSION_REG',
            mode        = 'RO',
            offset      = 0x0C4C,
        ))

        self.add(pr.RemoteVariable(
            name        = 'OEM_ID_REG',
            mode        = 'RO',
            offset      = 0x0C50,
        ))

# https://docs.amd.com/r/en-US/pg348-cms-subsystem/CMS_OP_WRITE_MODULE_LOW_SPEED_IO-0x0E
# https://docs.amd.com/r/en-US/pg348-cms-subsystem/CMS_OP_READ_MODULE_LOW_SPEED_IO-0x0D
class CmsLowSpeedIo(pr.Device):
    def __init__(self, moduleType=None, **kwargs):
        super().__init__(**kwargs)

        if moduleType=='QSFP':

            self.add(pr.RemoteVariable(
                name        = 'QSFP_INT_L',
                description = '(0: Interrupt Set, 1: Interrupt Clear)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 4,
                enum        = {
                    0: 'Interrupt Set',
                    1: 'Interrupt Clear',
                },
                hidden = True,
            ))

            self.add(pr.RemoteVariable(
                name        = 'QSFP_MODPRS_L',
                description = '(0: Module Present, 1: Module not Present)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 3,
                enum        = {
                    0: 'Module Present',
                    1: 'Module not Present',
                },
            ))

            self.add(pr.RemoteVariable(
                name        = 'QSFP_MODSEL_L',
                description = '(0: Module Selected, 1: Module not Selected)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 2,
                enum        = {
                    0: 'Module Selected',
                    1: 'Module not Selected',
                },
            ))

            self.add(pr.RemoteVariable(
                name        = 'QSFP_LPMODE',
                description = '(0: High Power Mode, 1: Low Power Mode)',
                mode      = 'RW',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 1,
                enum        = {
                    0: 'High Power Mode',
                    1: 'Low Power Mode',
                },
            ))

            self.add(pr.RemoteCommand(
                name        = 'QSFP_RESET_L',
                description = '(0: Reset Active, 1: Reset Clear)',
                offset       = 0x0,
                bitSize      = 1,
                bitOffset    = 0,
                function     = lambda cmd: cmd.post(0),
            ))

        elif moduleType=='DSFP':

            self.add(pr.RemoteVariable(
                name        = 'DSFP_INT',
                description = '(0: Interrupt Clear, 1: Interrupt Set)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 4,
                enum        = {
                    0: 'Interrupt Clear',
                    1: 'Interrupt Set',
                },
                hidden = True,
            ))


            self.add(pr.RemoteVariable(
                name        = 'DSFP_PRS',
                description = '(0: Module not Present, 1: Module Present)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 3,
                enum        = {
                    0: 'Module not Present',
                    1: 'Module Present',
                },
            ))

            self.add(pr.RemoteVariable(
                name        = 'DSFP_LPW',
                description = '(0: High Power Mode, 1: Low Power Mode)',
                mode      = 'RW',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 1,
                enum        = {
                    0: 'High Power Mode',
                    1: 'Low Power Mode',
                },
            ))

            self.add(pr.RemoteVariable(
                name        = 'DSFP_RST',
                description = '(0: Reset Clear, 1: Reset Active)',
                mode      = 'RW',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 0,
                enum        = {
                    0: 'Reset Clear',
                    1: 'Reset Active',
                },
            ))

        elif moduleType=='SFP':

            self.add(pr.RemoteVariable(
                name        = 'SFP_PRS',
                description = '(0: Module not Present, 1: Module Present)',
                mode      = 'RO',
                offset    = 0x0,
                bitSize   = 1,
                bitOffset = 3,
                enum        = {
                    0: 'Module not Present',
                    1: 'Module Present',
                },
            ))

        else:
            raise ValueError(f"Unsupported moduleType '{moduleType}'. Must be one of: 'QSFP', 'DSFP', 'SFP' ")

class CmsSubsystem(pr.Device):
    def __init__(self, pollPeriod=0.0, moduleType=None, numCages=1, **kwargs):
        super().__init__(**kwargs)

        self.moduleType = moduleType
        self.numCages = numCages

        self.add(pr.RemoteVariable(
            name        = 'MB_RESETN_REG',
            description = 'MicroBlaze reset register. Active-Low. Default 0x0 (reset active)',
            mode        = 'RW',
            offset      = 0x20000,
            verify      = False,
            hidden      = True,
        ))

        self.add(Status(
            name    = 'Status',
            memBase = self,
            offset  = 0x28000,
        ))

        self.add(_Mailbox(
            name    = 'Mailbox',
            memBase = self,
            offset  = 0x0000,
            hidden  = True,
            pollPeriod = pollPeriod,
        ))
        self.proxy = _ProxySlave(self.Mailbox)

        if self.moduleType is not None:
            for i in range(self.numCages):
                self.add(CmsLowSpeedIo(
                    name       = f'{self.moduleType.capitalize()}LowSpeedIo[{i}]',
                    memBase    = self.proxy,
                    moduleType = self.moduleType,
                    offset     = 0x0D_00_0000+(i*0x00_10_0000),
                ))

    def add(self, node):
        pr.Node.add(self, node)

        if isinstance(node, pr.Device):
            if node._memBase is None:
                node._setSlave(self.proxy)

    def _start(self):
        # Perform a reset cycle (active LOW)
        self.MB_RESETN_REG.set(value=0x0, write=True)
        self.MB_RESETN_REG.set(value=0x1, write=True)

        # Wait for the Mailbox to be ready (with 5-second timeout)
        start_time = time.time()
        while (self.Status.HOST_STATUS2_REG.get(read=True) & 0x1) != 1:
            if time.time() - start_time > 5:
                raise TimeoutError("Timed out waiting for Mailbox to be ready. Double check if you have the latest firmware loaded.  Requires firmware to be built with submodules/axi-pcie-core@v5.5.0 (or later)")
            time.sleep(0.001)

        # Check for the correct Register Map ID
        regMapId = self.Status.REG_MAP_ID_REG.get(read=True)
        if (regMapId != 0x74736574):
            raise ValueError(f"Unexpected REG_MAP_ID_REG value: {hex(regMapId)} (expected 0x74736574)")

        # Check if we need to enable the QSFP GPIO registers
        if self.moduleType is not None:
            self.Mailbox.QsfpGpioEnable.get(read=True) # Token read to update the shadow variable caching
            self.Mailbox.QsfpGpioEnable.set(value=0x1, write=True)

        # Proceed with the rest of the pyrogue.device._start() routine
        super()._start()
