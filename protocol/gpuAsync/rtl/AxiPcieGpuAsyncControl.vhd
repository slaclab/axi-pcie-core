-------------------------------------------------------------------------------
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.AxiDmaPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

entity AxiPcieGpuAsyncControl is
   generic (
      TPD_G            : time                  := 1 ns;
      MAX_BUFFERS_G    : integer range 1 to 16 := 4;
      DMA_AXI_CONFIG_G : AxiConfigType);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- Internal connections (axiClk domain)
      axiClk : in sl;
      axiRst : in sl;

      -- Config
      awCache : out slv(3 downto 0);
      arCache : out slv(3 downto 0);

      --AxiePcieGpu Demux
      dynamicRouteMasks : out Slv8Array(1 downto 0);
      dynamicRouteDests : out Slv8Array(1 downto 0);
      -- DMA Write Engine
      dmaWrDescReq      : in  AxiWriteDmaDescReqType;
      dmaWrDescAck      : out AxiWriteDmaDescAckType;
      dmaWrDescRet      : in  AxiWriteDmaDescRetType;
      dmaWrDescRetAck   : out sl;

      -- DMA Read Engine
      dmaRdDescReq    : out AxiReadDmaDescReqType;
      dmaRdDescAck    : in  sl;
      dmaRdDescRet    : in  AxiReadDmaDescRetType;
      dmaRdDescRetAck : out sl);

end AxiPcieGpuAsyncControl;

architecture mapping of AxiPcieGpuAsyncControl is

   type StateType is (IDLE_S, MOVE_S);

   type RegType is record
      rxState                 : StateType;
      txState                 : StateType;
      rxFrameCnt              : slv(31 downto 0);
      txFrameCnt              : slv(31 downto 0);
      axiWriteErrorCnt        : slv(31 downto 0);
      axiWriteTimeoutErrorCnt : slv(31 downto 0);
      axiWriteErrorVal        : slv(3 downto 0);
      axiReadErrorCnt         : slv(31 downto 0);
      axiReadErrorVal         : slv(2 downto 0);
      cntRst                  : sl;
      awcache                 : slv(3 downto 0);
      arcache                 : slv(3 downto 0);
      writeEnable             : sl;
      writeCount              : slv(3 downto 0);
      readEnable              : sl;
      readCount               : slv(3 downto 0);
      nextWriteIdx            : slv(3 downto 0);
      nextReadIdx             : slv(3 downto 0);
      remoteWriteAddrL        : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteAddrH        : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteSize         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteEn           : slv(MAX_BUFFERS_G-1 downto 0);
      remoteReadAddrL         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadAddrH         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadSize          : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadEn            : slv(MAX_BUFFERS_G-1 downto 0);
      totLatency              : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      totLatencyEn            : slv(MAX_BUFFERS_G-1 downto 0);
      gpuLatency              : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      gpuLatencyEn            : slv(MAX_BUFFERS_G-1 downto 0);
      wrLatency               : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      wrLatencyEn             : slv(MAX_BUFFERS_G-1 downto 0);
      readSlave               : AxiLiteReadSlaveType;
      writeSlave              : AxiLiteWriteSlaveType;
      dmaWrDescAck            : AxiWriteDmaDescAckType;
      dmaWrDescRetAck         : sl;
      dmaRdDescReq            : AxiReadDmaDescReqType;
      dmaRdDescRetAck         : sl;
      dynamicRouteMasks       : Slv8Array(1 downto 0);
      dynamicRouteDests       : Slv8Array(1 downto 0);
   end record;

   constant REG_INIT_C : RegType := (
      rxState                 => IDLE_S,
      txState                 => IDLE_S,
      rxFrameCnt              => (others => '0'),
      txFrameCnt              => (others => '0'),
      axiWriteErrorCnt        => (others => '0'),
      axiWriteTimeoutErrorCnt => (others => '0'),
      axiWriteErrorVal        => (others => '0'),
      axiReadErrorCnt         => (others => '0'),
      axiReadErrorVal         => (others => '0'),
      cntRst                  => '0',
      awcache                 => (others => '0'),
      arcache                 => (others => '0'),
      writeEnable             => '0',
      writeCount              => (others => '0'),
      readEnable              => '0',
      readCount               => (others => '0'),
      nextWriteIdx            => (others => '0'),
      nextReadIdx             => (others => '0'),
      remoteWriteAddrL        => (others => (others => '0')),
      remoteWriteAddrH        => (others => (others => '0')),
      remoteWriteSize         => (others => (others => '0')),
      remoteWriteEn           => (others => '0'),
      remoteReadAddrL         => (others => (others => '0')),
      remoteReadAddrH         => (others => (others => '0')),
      remoteReadSize          => (others => (others => '0')),
      remoteReadEn            => (others => '0'),
      totLatency              => (others => (others => '0')),
      totLatencyEn            => (others => '0'),
      gpuLatency              => (others => (others => '0')),
      gpuLatencyEn            => (others => '0'),
      wrLatency               => (others => (others => '0')),
      wrLatencyEn             => (others => '0'),
      readSlave               => AXI_LITE_READ_SLAVE_INIT_C,
      writeSlave              => AXI_LITE_WRITE_SLAVE_INIT_C,
      dmaWrDescAck            => AXI_WRITE_DMA_DESC_ACK_INIT_C,
      dmaWrDescRetAck         => '0',
      dmaRdDescReq            => AXI_READ_DMA_DESC_REQ_INIT_C,
      dmaRdDescRetAck         => '0',
      dynamicRouteMasks       => (0 => x"00", 1 => x"FF"),
      dynamicRouteDests       => (0 => x"00", 1 => x"FF"));

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
   comb : process (axiRst, dmaRdDescRet, dmaWrDescReq, dmaWrDescRet, r,
                   readMaster, writeMaster) is
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
         v.rxFrameCnt              := (others => '0');
         v.txFrameCnt              := (others => '0');
         v.axiWriteErrorCnt        := (others => '0');
         v.axiWriteTimeoutErrorCnt := (others => '0');
         v.axiWriteErrorVal        := (others => '0');
         v.axiReadErrorCnt         := (others => '0');
         v.axiReadErrorVal         := (others => '0');
      end if;

      -- Latency Counters
      for i in 0 to MAX_BUFFERS_G-1 loop
         if r.totLatencyEn(i) = '1' then
            v.totLatency(i) := r.totLatency(i) + 1;
         end if;
         if r.gpuLatencyEn(i) = '1' then
            v.gpuLatency(i) := r.gpuLatency(i) + 1;
         end if;
         if r.wrLatencyEn(i) = '1' then
            v.wrLatency(i) := r.wrLatency(i) + 1;
         end if;
      end loop;

      --------------------------------------------------------------------------------------------
      -- Determine the transaction type
      --------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, writeMaster, readMaster, v.writeSlave, v.readSlave);

      axiSlaveRegister (axilEp, x"004", 0, v.arcache);
      axiSlaveRegister (axilEp, x"004", 8, v.awcache);
      axiSlaveRegisterR(axilEp, x"004", 16, toSlv(DMA_AXI_CONFIG_G.DATA_BYTES_C, 8));
      axiSlaveRegisterR(axilEp, x"004", 24, toSlv(MAX_BUFFERS_G, 5));

      axiSlaveRegister (axilEp, x"008", 0, v.writeCount);
      axiSlaveRegister (axilEp, x"008", 8, v.writeEnable);
      axiSlaveRegister (axilEp, x"008", 16, v.readCount);
      axiSlaveRegister (axilEp, x"008", 24, v.readEnable);

      axiSlaveRegisterR(axilEp, x"010", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp, x"014", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp, x"018", 0, r.axiWriteErrorCnt);
      axiSlaveRegisterR(axilEp, x"01C", 0, r.axiReadErrorCnt);

      axiSlaveRegister (axilEp, x"020", 0, v.cntRst);
      axiSlaveRegisterR(axilEp, x"024", 0, r.axiWriteErrorVal);
      axiSlaveRegisterR(axilEp, x"028", 0, r.axiReadErrorVal);

      axiSlaveRegister (axilEp, x"02C", 0, v.dynamicRouteMasks(0));
      axiSlaveRegister (axilEp, x"02C", 8, v.dynamicRouteDests(0));
      axiSlaveRegister (axilEp, x"02C", 16, v.dynamicRouteMasks(1));
      axiSlaveRegister (axilEp, x"02C", 24, v.dynamicRouteDests(1));
      axiSlaveRegisterR(axilEp, x"030", 0, toSlv(1, 8));  -- version number, 1 if gpu enabled
      axiSlaveRegisterR(axilEp, x"034", 0, r.axiWriteTimeoutErrorCnt);

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegister (axilEp, toSlv(256+i*16+0, 12), 0, v.remoteWriteAddrL(i));  -- 0x1x0 (x = 0,1,2,3....)
         axiSlaveRegister (axilEp, toSlv(256+i*16+4, 12), 0, v.remoteWriteAddrH(i));  -- 0x1x4 (x = 0,1,2,3....)
         axiSlaveRegister (axilEp, toSlv(256+i*16+8, 12), 0, v.remoteWriteSize(i));  -- 0x1x8 (x = 0,1,2,3....)
      end loop;

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegister (axilEp, toSlv(512+i*16+0, 12), 0, v.remoteReadAddrL(i));  -- 0x2x0 (x = 0,1,2,3....)
         axiSlaveRegister (axilEp, toSlv(512+i*16+4, 12), 0, v.remoteReadAddrH(i));  -- 0x2x4 (x = 0,1,2,3....)
      end loop;

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiWrDetect (axilEp, toSlv(768+i*4, 12), v.remoteWriteEn(i));  -- 0x30x (x = 0,4,8,C....)
      end loop;

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegister (axilEp, toSlv(1024+i*4, 12), 0, v.remoteReadSize(i));  -- 0x40x (x = 0,4,8,C....)
         axiWrDetect (axilEp, toSlv(1024+i*4, 12), v.remoteReadEn(i));  -- 0x40x (x = 0,4,8,C....)
      end loop;

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegisterR(axilEp, toSlv(1280+i*16+0, 12), 0, r.totLatency(i));  -- 0x5x0 (x = 0,4,8,C....)
         axiSlaveRegisterR(axilEp, toSlv(1280+i*16+4, 12), 0, r.gpuLatency(i));  -- 0x5x4 (x = 0,4,8,C....)
         axiSlaveRegisterR(axilEp, toSlv(1280+i*16+8, 12), 0, r.wrLatency(i));  -- 0x5x8 (x = 0,4,8,C....)
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.writeSlave, v.readSlave, AXI_RESP_DECERR_C);
      --------------------------------------------------------------------------------------------

      -- rx State Machine
      case r.rxState is

         when IDLE_S =>

            if r.remoteWriteEn(conv_integer(r.nextWriteIdx)) = '0' then
               v.gpuLatencyEn(conv_integer(r.nextWriteIdx)) := '0';
            end if;
            if dmaWrDescReq.valid = '1' then
               v.dmaWrDescAck.dropEn     := not r.writeEnable;
               v.dmaWrDescAck.maxSize    := r.remoteWriteSize(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.contEn     := '0';
               v.dmaWrDescAck.metaEnable := '1';

               v.dmaWrDescAck.buffId(3 downto 0) := r.nextWriteIdx;

               v.dmaWrDescAck.metaAddr(31 downto 0)  := r.remoteWriteAddrL(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.metaAddr(63 downto 32) := r.remoteWriteAddrH(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.address(31 downto 0)   := r.remoteWriteAddrL(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.address(63 downto 32)  := r.remoteWriteAddrH(conv_integer(r.nextWriteIdx));

               if r.remoteWriteEn(conv_integer(r.nextWriteIdx)) = '1' or r.writeEnable = '0' then
                  v.dmaWrDescAck.valid := '1';
                  v.rxState            := MOVE_S;

                  if r.writeEnable = '1' then
                     v.remoteWriteEn(conv_integer(r.nextWriteIdx)) := '0';

                     v.totLatencyEn(conv_integer(r.nextWriteIdx)) := '1';
                     v.totLatency(conv_integer(r.nextWriteIdx))   := (others => '0');

                     v.gpuLatencyEn(conv_integer(r.nextWriteIdx)) := '0';
                     v.gpuLatency(conv_integer(r.nextWriteIdx))   := (others => '0');

                     v.wrLatencyEn(conv_integer(r.nextWriteIdx)) := '1';
                     v.wrLatency(conv_integer(r.nextWriteIdx))   := (others => '0');

                     if r.nextWriteIdx >= r.writeCount then
                        v.nextWriteIdx := (others => '0');
                     else
                        v.nextWriteIdx := r.nextWriteIdx + 1;
                     end if;
                  end if;

               end if;
            end if;

            if r.writeEnable = '0' then
               v.nextWriteIdx := (others => '0');
            end if;

         when MOVE_S =>

            if dmaWrDescRet.valid = '1' then
               v.dmaWrDescRetAck := '1';

               v.wrLatencyEn(conv_integer(dmaWrDescRet.buffId(3 downto 0)))  := '0';
               v.gpuLatencyEn(conv_integer(dmaWrDescRet.buffId(3 downto 0))) := '1';

               if dmaWrDescRet.result /= "0000" then
                  v.axiWriteErrorCnt := r.axiWriteErrorCnt + 1;
                  v.axiWriteErrorVal := dmaWrDescRet.result;
               end if;

               if dmaWrDescRet.result(3) = '1' then
                  v.axiWriteTimeoutErrorCnt := r.axiWriteTimeoutErrorCnt + 1;
               end if;

               v.rxFrameCnt := r.rxFrameCnt + 1;
               v.rxState    := IDLE_S;
            end if;
      end case;

      --------------------------------------------------------------------------------------------

      -- tx State Machine
      case r.txState is

         when IDLE_S =>

            if r.readEnable = '1' and r.remoteReadEn(conv_integer(r.nextReadIdx)) = '1' then
               v.remoteReadEn(conv_integer(r.nextReadIdx)) := '0';


               if r.nextReadIdx >= r.readCount then
                  v.nextReadIdx := (others => '0');
               else
                  v.nextReadIdx := r.nextReadIdx + 1;
               end if;

               v.dmaRdDescReq.valid              := '1';
               v.dmaRdDescReq.buffId(3 downto 0) := r.nextReadIdx;

               v.dmaRdDescReq.firstUser := x"02";
               v.dmaRdDescReq.lastUser  := (others => '0');
               v.dmaRdDescReq.size      := r.remoteReadSize(conv_integer(r.nextReadIdx));
               v.dmaRdDescReq.continue  := '0';
               v.dmaRdDescReq.id        := (others => '0');
               v.dmaRdDescReq.dest      := (others => '0');

               v.dmaRdDescReq.address(31 downto 0)  := r.remoteReadAddrL(conv_integer(r.nextReadIdx));
               v.dmaRdDescReq.address(63 downto 32) := r.remoteReadAddrH(conv_integer(r.nextReadIdx));

               v.txState := MOVE_S;
            end if;

            if r.readEnable = '0' then
               v.nextReadIdx := (others => '0');
            end if;

         when MOVE_S =>

            if dmaRdDescRet.valid = '1' then
               v.dmaRdDescRetAck := '1';

               v.totLatencyEn(conv_integer(dmaRdDescRet.buffId(3 downto 0))) := '0';

               if dmaRdDescRet.result /= "000" then
                  v.axiReadErrorCnt := r.axiReadErrorCnt + 1;
                  v.axiReadErrorVal := dmaRdDescRet.result;
               end if;

               v.txFrameCnt := r.txFrameCnt + 1;

               v.txState := IDLE_S;
            end if;

      end case;

      --------------------------------------------------------------------------------------------
      -- Outputs
      awCache           <= r.awCache;
      arCache           <= r.arCache;
      writeSlave        <= r.writeSlave;
      readSlave         <= r.readSlave;
      dmaWrDescAck      <= r.dmaWrDescAck;
      dmaWrDescRetAck   <= r.dmaWrDescRetAck;
      dmaRdDescReq      <= r.dmaRdDescReq;
      dmaRdDescRetAck   <= r.dmaRdDescRetAck;
      dynamicRouteMasks <= r.dynamicRouteMasks;
      dynamicRouteDests <= r.dynamicRouteDests;

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

