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

use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.AxiPciePkg.all;
use surf.AxiDmaPkg.all;

entity AxiPcieGpuAsyncControl is
   generic (
      TPD_G            : time          := 1 ns;
      DMA_AXI_CONFIG_G : AxiConfigType);
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
      arCache           : out slv(3 downto 0);

      -- DMA Write Engine
      dmaWrDescReq      : in  AxiWriteDmaDescReqType;
      dmaWrDescAck      : out AxiWriteDmaDescAckType;
      dmaWrDescRet      : in  AxiWriteDmaDescRetType;
      dmaWrDescRetAck   : out sl;
   
      -- DMA Read Engine
      dmaRdDescReq      : out AxiReadDmaDescReqType;
      dmaRdDescAck      : in  sl;
      dmaRdDescRet      : in  AxiReadDmaDescRetType;
      dmaRdDescRetAck   : out sl);

end AxiPcieGpuAsyncControl;

architecture mapping of AxiPcieGpuAsyncControl is

   type StateType is ( IDLE_S, WRITE_S, READ_S);

   type RegType is record
      state             : StateType;
      rxFrameCnt        : slv(31 downto 0);
      txFrameCnt        : slv(31 downto 0);
      axiErrorCnt       : slv(31 downto 0);
      cntRst            : sl;
      awcache           : slv(3 downto 0);
      arcache           : slv(3 downto 0);
      enableWrite       : sl;
      remoteWriteAddr   : slv(31 downto 0);
      remoteWriteSize   : slv(31 downto 0);
      remoteWriteStart  : sl;
      remoteReadAddr    : slv(31 downto 0);
      remoteReadSize    : slv(31 downto 0);
      remoteReadStart   : sl;
      readSlave         : AxiLiteReadSlaveType;
      writeSlave        : AxiLiteWriteSlaveType;
      dmaWrDescAck      : AxiWriteDmaDescAckType;
      dmaWrDescRetAck   : sl;
      dmaRdDescReq      : AxiReadDmaDescReqType;
      dmaRdDescRetAck   : sl;
   end record;

   constant REG_INIT_C : RegType := (
      state             => IDLE_S,
      rxFrameCnt        => (others => '0'),
      txFrameCnt        => (others => '0'),
      axiErrorCnt       => (others => '0'),
      cntRst            => '0',
      awcache           => (others => '0'),
      arcache           => (others => '0'),
      enableWrite       => '0',
      remoteWriteAddr   => (others => '0'),
      remoteWriteSize   => (others => '0'),
      remoteWriteStart  => '0',
      remoteReadAddr    => (others => '0'),
      remoteReadSize    => (others => '0'),
      remoteReadStart   => '0',
      readSlave         => AXI_LITE_READ_SLAVE_INIT_C,
      writeSlave        => AXI_LITE_WRITE_SLAVE_INIT_C,
      dmaWrDescAck      => AXI_WRITE_DMA_DESC_ACK_INIT_C,
      dmaWrDescRetAck   => '0',
      dmaRdDescReq      => AXI_READ_DMA_DESC_REQ_INIT_C,
      dmaRdDescRetAck   => '0'
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal readMaster  : AxiLiteReadMasterType;
   signal readSlave   : AxiLiteReadSlaveType;
   signal writeMaster : AxiLiteWriteMasterType;
   signal writeSlave  : AxiLiteWriteSlaveType;

begin

   U_AxiLiteAsync : entity surf.AxiLiteAsync
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
   comb : process (axiRst, r, readMaster, writeMaster, dmaWrDescReq, dmaWrDescRet, dmaRdDescAck, dmaRdDescRet ) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.cntRst             := '0';
      v.dmaWrDescAck.valid := '0';
      v.dmaRdDescReq.valid := '0';
      v.dmaWrDescRetAck    := '0';
      v.dmaRdDescRetAck    := '0';

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

      axiSlaveRegister (axilEp, x"000", 0, v.remoteWriteAddr); 
      axiSlaveRegister (axilEp, x"004", 0, v.remoteWriteSize);
      axiWrDetect      (axilEp, x"00C",    v.remotewriteStart);

      axiSlaveRegister (axilEp, x"010", 0, v.remoteReadAddr); 
      axiSlaveRegister (axilEp, x"014", 0, v.remoteReadSize);
      axiWrDetect      (axilEp, x"014",    v.remoteReadStart);

      axiSlaveRegisterR(axilEp, x"0E0", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp, x"0E8", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp, x"0F0", 0, r.axiErrorCnt);

      axiSlaveRegister (axilEp, x"0F8", 0,  v.enableWrite);
      axiSlaveRegister (axilEp, x"0F8", 8,  v.arcache);
      axiSlaveRegister (axilEp, x"0F8", 16, v.awcache);
      axiSlaveRegisterR(axilEp, x"0F8", 24, toSlv(DMA_AXI_CONFIG_G.DATA_BYTES_C,8));

      axiSlaveRegister (axilEp, x"0FC", 0,  v.cntRst);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.writeSlave, v.readSlave, AXI_RESP_DECERR_C);
      --------------------------------------------------------------------------------------------

      -- State Machine
      case r.state is

         when IDLE_S =>

            if dmaWrDescReq.valid = '1' then
               v.dmaWrDescAck.dropEn     := not r.enableWrite;
               v.dmaWrDescAck.maxSize    := r.remoteWriteSize;
               v.dmaWrDescAck.contEn     := '0';
               v.dmaWrDescAck.buffId     := toSlv(0,32); -- Channel ID
               v.dmaWrDescAck.metaEnable := '1';

               v.dmaWrDescAck.metaAddr(31 downto 0) := r.remoteWriteAddr;
               v.dmaWrDescAck.address(31 downto 0)  := r.remoteWriteAddr + DMA_AXI_CONFIG_G.DATA_BYTES_C;

               if r.remoteWriteStart = '1' or r.enableWrite = '0' then
                  v.remoteWriteStart   := '0';
                  v.dmaWrDescAck.valid := '1';
                  v.state              := WRITE_S;
               end if;

            elsif r.remoteReadStart = '1' then
               v.remoteReadStart         := '0';
               v.dmaRdDescReq.valid      := '1';
               v.dmaRdDescReq.address    := r.remoteReadAddr;
               v.dmaRdDescReq.buffId     := toSlv(0,32);
               v.dmaRdDescReq.firstUser  := (others=>'0');
               v.dmaRdDescReq.lastUser   := (others=>'0');
               v.dmaRdDescReq.size       := r.remoteReadSize;
               v.dmaRdDescReq.continue   := '0';
               v.dmaRdDescReq.id         := (others=>'0');
               v.dmaRdDescReq.dest       := (others=>'0');
               v.state                   := READ_S;
            end if;

         when WRITE_S =>

            if dmaWrDescRet.valid = '1' then
               v.dmaWrDescRetAck := '1';

               -- act on buff id
               --dmaWrDescRet.buffId

               if dmaWrDescRet.result /= "000" then
                  v.axiErrorCnt := r.axiErrorCnt + 1;
               end if;

               v.rxFrameCnt := r.rxFrameCnt + 1;

               v.state := IDLE_S;
            end if;

         when READ_S =>

            if dmaRdDescRet.valid = '1' then
               v.dmaRdDescRetAck := '1';

               if dmaRdDescRet.result /= "000" then
                  v.axiErrorCnt := r.axiErrorCnt + 1;
               end if;

               v.txFrameCnt := r.txFrameCnt + 1;

               v.state := IDLE_S;
            end if;

      end case;

      -- Outputs
      awCache         <= r.awCache;
      arCache         <= r.awCache;
      writeSlave      <= r.writeSlave;
      readSlave       <= r.readSlave;
      dmaWrDescAck    <= r.dmaWrDescAck;
      dmaWrDescRetAck <= r.dmaWrDescRetAck;
      dmaRdDescReq    <= r.dmaRdDescReq;
      dmaRdDescRetAck <= r.dmaRdDescRetAck;

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

