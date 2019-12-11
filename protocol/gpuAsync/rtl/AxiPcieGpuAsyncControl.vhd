-------------------------------------------------------------------------------
-- File       : AxiPcieGpuAsyncControl.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Support for GpuDirectAsync like data transport to/from a GPU
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'axi-pcie-core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AxiPciePkg.all;
use work.AxiDmaPkg.all;

entity AxiPcieGpuAsyncControl is
   generic (
      TPD_G      : time                   := 1 ns;
      NUM_CHAN_G : positive range 1 to 4  := 1);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk           : in  sl;
      axilRst           : in  sl;
      axilReadMaster    : in  AxiLiteReadMasterType;
      axilReadSlave     : out AxiLiteReadSlaveType;
      axilWriteMaster   : in  AxiLiteWriteMasterType;
      axilWriteSlave    : out AxiLiteWriteSlaveType;

      -- Internal connections (axiClk domain)
      axiClk            : in  sl;
      axiRst            : in  sl;

      -- Config
      awCache           : out slv(3 downto 0);

      -- DMA Write Engine
      dmaWrDescReq      : in  AxiWriteDmaDescReqType;
      dmaWrDescAck      : out AxiWriteDmaDescAckType;
      dmaWrDescRet      : in  AxiWriteDmaDescRetType;
      dmaWrDescRetAck   : out sl);

end AxiPcieGpuAsyncControl;

architecture mapping of AxiPcieGpuAsyncControl is

   type StateType is ( IDLE_S, MOVE_S);

   type RegType is record
      state             : StateType;
      rxFrameCnt        : slv(31 downto 0);
      txFrameCnt        : slv(31 downto 0);
      axiErrorCnt       : slv(31 downto 0);
      completedSize     : slv(31 downto 0);
      completedMeta     : slv(31 downto 0);
      cntRst            : sl;
      enableTx          : sl;
      enableRx          : sl;
      awcache           : slv(3 downto 0);
      remoteDmaAddr     : Slv32Array(NUM_CHAN_G-1 downto 0);
      remoteDmaSize     : Slv32Array(NUM_CHAN_G-1 downto 0);
      readSlave         : AxiLiteReadSlaveType;
      writeSlave        : AxiLiteWriteSlaveType;
      dmaWrDescAck      : AxiWriteDmaDescAckType;
      dmaWrDescRetAck   : sl;
   end record;

   constant REG_INIT_C : RegType := (
      state             => IDLE_S,
      rxFrameCnt        => (others => '0'),
      txFrameCnt        => (others => '0'),
      axiErrorCnt       => (others => '0'),
      completedSize     => (others => '0'),
      completedMeta     => (others => '0'),
      cntRst            => '0',
      enableTx          => '0',
      enableRx          => '0',
      awcache           => (others => '0'),
      remoteDmaAddr     => (others => (others => '0')),
      remoteDmaSize     => (others => (others => '0')),
      readSlave         => AXI_LITE_READ_SLAVE_INIT_C,
      writeSlave        => AXI_LITE_WRITE_SLAVE_INIT_C,
      dmaWrDescAck      => AXI_WRITE_DMA_DESC_ACK_INIT_C,
      dmaWrDescRetAck   => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal readMaster  : AxiLiteReadMasterType;
   signal readSlave   : AxiLiteReadSlaveType;
   signal writeMaster : AxiLiteWriteMasterType;
   signal writeSlave  : AxiLiteWriteSlaveType;

begin

   U_AxiLiteAsync : entity work.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 12)
      port map (
         -- Slave Interface
         sAxiClk         => axilClk,
         sAxiClkRst      => axilRst,
         sAxiReadMaster  => axilReadMaster,
         sAxiReadSlave   => axilReadSlave,
         sAxiWriteMaster => axilWriteMaster,
         sAxiWriteSlave  => axilWriteSlave,
         -- Master Interface
         mAxiClk         => axiClk,
         mAxiClkRst      => axiRst,
         mAxiReadMaster  => readMaster,
         mAxiReadSlave   => readSlave,
         mAxiWriteMaster => writeMaster,
         mAxiWriteSlave  => writeSlave);


   --------------------- 
   -- State Machine
   --------------------- 
   comb : process (axiRst, r, readMaster, writeMaster, dmaWrDescReq, dmaWrDescRet ) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.cntRst             := '0';
      v.dmaWrDescAck.valid := '0';
      v.dmaWrDescRetAck    := '0';

      -- Reset counters
      if (r.cntRst = '1') then
         v.rxFrameCnt  := (others => '0');
         v.txFrameCnt  := (others => '0');
         v.axiErrorCnt := (others => '0');
      end if;

      --------------------------------------------------------------------------------------------
      -- Determine the transaction type
      --------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, writeMaster, readMaster, v.writeSlave, v.readSlave);

      axiSlaveRegister (axilEp, x"000", 0, v.remoteDmaAddr(0)); 
      axiSlaveRegister (axilEp, x"004", 0, v.remoteDmaSize(0));

      axiSlaveRegister (axilEp, x"010", 0, v.completedSize(0));
      axiSlaveRegister (axilEp, x"014", 0, v.completedMeta(0));

      axiSlaveRegisterR(axilEp, x"0E0", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp, x"0E8", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp, x"0F0", 0, r.axiErrorCnt);

      axiSlaveRegisterR(axilEp, x"0F4", 0, toSlv(NUM_CHAN_G, 5));
      axiSlaveRegister (axilEp, x"0F8", 0, v.enableTx);
      axiSlaveRegister (axilEp, x"0F8", 1, v.enableRx);
      axiSlaveRegister (axilEp, x"0F8", 16, v.awcache);
      axiSlaveRegister (axilEp, x"0FC", 0, v.cntRst);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.writeSlave, v.readSlave, AXI_RESP_DECERR_C);
      --------------------------------------------------------------------------------------------

      -- State Machine
      case r.state is

         when IDLE_S =>

            if dmaWrDescReq.valid = '1' then
               v.state := MOVE_S;

               v.dmaWrDescAck.valid      := '1';
               v.dmaWrDescAck.dropEn     := not r.enableRx;
               v.dmaWrDescAck.maxSize    := r.remoteDmaSize(0);
               v.dmaWrDescAck.contEn     := '0';
               v.dmaWrDescAck.buffId     := toSlv(0,32); -- Channel ID

               v.dmaWrDescAck.address(31 downto 0)  := remoteDmaAddr(0);

            end if;

         when MOVE_S =>

            if dmaWrDescRet.valid = '1' then
               v.dmaWrDescRetAck := '1';

               v.completedSize := r.dmaWrDescRet.size;

               v.completedMeta(31 downto 24) := r.dmaWrDescRet.firstUser;
               v.completedMeta(23 downto 16) := r.dmaWrDescRet.lastUser;
               v.completedMeta(15 downto 4)  := (others => '0');
               v.completedMeta(3)            := r.dmaWrDescRet.continue;
               v.completedMeta(2 downto 0)   := r.dmaWrDescRet.result;

               -- act on buff id
               --dmaWrDescRet.buffId

               if dmaWrDescRet.result /= "000" then
                  v.axiErrorCnt := r.axiErrorCnt + 1;
               end if;

               v.rxFrameCnt := r.rxFrameCnt + 1;

               v.state := IDLE_S;
            end if;
      end case;

      -- Outputs
      awCache         <= r.awCache;
      writeSlave      <= r.writeSlave;
      readSlave       <= r.readSlave;
      dmaWrDescAck    <= r.dmaWrDescAck;
      dmaWrDescRetAck <= r.dmaWrDescRetAck;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;

