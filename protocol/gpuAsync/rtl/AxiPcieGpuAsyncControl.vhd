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
      TPD_G               : time                   := 1 ns;
      DEFAULT_DEMUX_SEL_G : sl                     := '1';  -- 1: GPU path, 0: CPU path
      -- MAX_BUFFERS_G       : integer range 1 to 256 := 4;
      MAX_BUFFERS_G       : integer range 1 to 128 := 4;  -- TODO: resolve the timing closure issues when MAX_BUFFERS_G=256
      DMA_AXI_CONFIG_G    : AxiConfigType);
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
      -- Misc. Signals
      cntRst                  : sl;
      -- Write/RX Signals
      rxState                 : StateType;
      rxFrameCnt              : slv(31 downto 0);
      axiWriteErrorCnt        : slv(31 downto 0);
      axiWriteTimeoutErrorCnt : slv(31 downto 0);
      axiWriteErrorVal        : slv(3 downto 0);
      awcache                 : slv(3 downto 0);
      writeEnable             : sl;
      writeCount              : slv(7 downto 0);
      nextWriteIdx            : slv(7 downto 0);
      remoteWriteAddrL        : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteAddrH        : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteSize         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteWriteEn           : slv(255 downto 0);
      -- Read/TX Signals
      txState                 : StateType;
      txFrameCnt              : slv(31 downto 0);
      axiReadErrorCnt         : slv(31 downto 0);
      axiReadErrorVal         : slv(2 downto 0);
      arcache                 : slv(3 downto 0);
      readEnable              : sl;
      readCount               : slv(7 downto 0);
      nextReadIdx             : slv(7 downto 0);
      remoteReadAddrL         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadAddrH         : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadSize          : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      remoteReadEn            : slv(255 downto 0);
      -- Latency Measurements
      totLatency              : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      totLatencyEn            : slv(MAX_BUFFERS_G-1 downto 0);
      gpuLatency              : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      gpuLatencyEn            : slv(MAX_BUFFERS_G-1 downto 0);
      wrLatency               : Slv32Array(MAX_BUFFERS_G-1 downto 0);
      wrLatencyEn             : slv(MAX_BUFFERS_G-1 downto 0);
      -- Buffer Measurements
      minWriteBuffer          : slv(8 downto 0);
      minReadBuffer           : slv(8 downto 0);
      wrBuffSizeVec           : Slv9Array(7 downto 0);
      rdBuffSizeVec           : Slv9Array(7 downto 0);
      wrBuffSize              : slv(8 downto 0);
      rdBuffSize              : slv(8 downto 0);
      -- DMA Control
      dmaWrDescAck            : AxiWriteDmaDescAckType;
      dmaWrDescRetAck         : sl;
      dmaRdDescReq            : AxiReadDmaDescReqType;
      dmaRdDescRetAck         : sl;
      -- AXI-Lite Control
      readSlaves              : AxiLiteReadSlaveArray(3 downto 0);
      writeSlaves             : AxiLiteWriteSlaveArray(3 downto 0);
      -- DEMUX Control
      axisDeMuxSelect         : sl;
      dynamicRouteMasks       : Slv8Array(1 downto 0);
      dynamicRouteDests       : Slv8Array(1 downto 0);
   end record;

   constant REG_INIT_C : RegType := (
      -- Misc. Signals
      cntRst                  => '0',
      -- Write/RX Signals
      rxState                 => IDLE_S,
      rxFrameCnt              => (others => '0'),
      axiWriteErrorCnt        => (others => '0'),
      axiWriteTimeoutErrorCnt => (others => '0'),
      axiWriteErrorVal        => (others => '0'),
      awcache                 => (others => '0'),
      writeEnable             => '0',
      writeCount              => (others => '0'),
      nextWriteIdx            => (others => '0'),
      remoteWriteAddrL        => (others => (others => '0')),
      remoteWriteAddrH        => (others => (others => '0')),
      remoteWriteSize         => (others => (others => '0')),
      remoteWriteEn           => (others => '0'),
      -- Read/TX Signals
      txState                 => IDLE_S,
      txFrameCnt              => (others => '0'),
      axiReadErrorCnt         => (others => '0'),
      axiReadErrorVal         => (others => '0'),
      arcache                 => (others => '0'),
      readEnable              => '0',
      readCount               => (others => '0'),
      nextReadIdx             => (others => '0'),
      remoteReadAddrL         => (others => (others => '0')),
      remoteReadAddrH         => (others => (others => '0')),
      remoteReadSize          => (others => (others => '0')),
      remoteReadEn            => (others => '0'),
      -- Latency Measurements
      totLatency              => (others => (others => '0')),
      totLatencyEn            => (others => '0'),
      gpuLatency              => (others => (others => '0')),
      gpuLatencyEn            => (others => '0'),
      wrLatency               => (others => (others => '0')),
      wrLatencyEn             => (others => '0'),
      -- Buffer Measurements
      minWriteBuffer          => (others => '0'),
      minReadBuffer           => (others => '0'),
      wrBuffSizeVec           => (others => (others => '0')),
      rdBuffSizeVec           => (others => (others => '0')),
      wrBuffSize              => (others => '0'),
      rdBuffSize              => (others => '0'),
      -- DMA Control
      dmaWrDescAck            => AXI_WRITE_DMA_DESC_ACK_INIT_C,
      dmaWrDescRetAck         => '0',
      dmaRdDescReq            => AXI_READ_DMA_DESC_REQ_INIT_C,
      dmaRdDescRetAck         => '0',
      -- AXI-Lite Control
      readSlaves              => (others => AXI_LITE_READ_SLAVE_INIT_C),
      writeSlaves             => (others => AXI_LITE_WRITE_SLAVE_INIT_C),
      -- DEMUX Control
      axisDeMuxSelect         => DEFAULT_DEMUX_SEL_G,
      dynamicRouteMasks       => (0 => x"00", 1 => x"FF"),
      dynamicRouteDests       => (0 => x"00", 1 => x"FF"));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(3 downto 0) := genAxiLiteConfig(4, x"0000_0000", 15, 12);

   signal writeMaster : AxiLiteWriteMasterType;
   signal writeSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C;
   signal readMaster  : AxiLiteReadMasterType;
   signal readSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C;

   signal writeMasters : AxiLiteWriteMasterArray(3 downto 0);
   signal writeSlaves  : AxiLiteWriteSlaveArray(3 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal readMasters  : AxiLiteReadMasterArray(3 downto 0);
   signal readSlaves   : AxiLiteReadSlaveArray(3 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

begin

   -------------------------------------------------------
   -- Mask off the address mask outside of 15 bit range
   -- so we can use hex values in axiSlaveRegister()
   -------------------------------------------------------
   --      GPU_INDEX_C     => (
   --      baseAddr     => x"0002_8000",
   --      addrBits     => 15,
   --      connectivity => x"FFFF"),
   -------------------------------------------------------
   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 15)
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

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 4,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         sAxiWriteMasters(0) => writeMaster,
         sAxiWriteSlaves(0)  => writeSlave,
         sAxiReadMasters(0)  => readMaster,
         sAxiReadSlaves(0)   => readSlave,
         mAxiWriteMasters    => writeMasters,
         mAxiWriteSlaves     => writeSlaves,
         mAxiReadMasters     => readMasters,
         mAxiReadSlaves      => readSlaves,
         axiClk              => axiClk,
         axiClkRst           => axiRst);

   ---------------------
   -- State Machine
   ---------------------
   comb : process (axiRst, dmaRdDescRet, dmaWrDescReq, dmaWrDescRet, r,
                   readMasters, writeMasters) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointArray(3 downto 0);
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
      -- Axi-Lite Memory Range: 0x0000:0x0FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(0), writeMasters(0), readMasters(0), v.writeSlaves(0), v.readSlaves(0));

      axiSlaveRegister (axilEp(0), x"004", 0, v.arcache);
      axiSlaveRegister (axilEp(0), x"004", 8, v.awcache);
      axiSlaveRegisterR(axilEp(0), x"004", 16, toSlv(DMA_AXI_CONFIG_G.DATA_BYTES_C, 8));
      axiSlaveRegisterR(axilEp(0), x"004", 24, toSlv(MAX_BUFFERS_G, 8));

      axiSlaveRegister (axilEp(0), x"008", 0, v.writeCount);
      axiSlaveRegister (axilEp(0), x"008", 8, v.writeEnable);
      axiSlaveRegister (axilEp(0), x"008", 16, v.readCount);
      axiSlaveRegister (axilEp(0), x"008", 24, v.readEnable);

      axiSlaveRegisterR(axilEp(0), x"010", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp(0), x"014", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp(0), x"018", 0, r.axiWriteErrorCnt);
      axiSlaveRegisterR(axilEp(0), x"01C", 0, r.axiReadErrorCnt);

      axiSlaveRegister (axilEp(0), x"020", 0, v.cntRst);
      axiSlaveRegisterR(axilEp(0), x"024", 0, r.axiWriteErrorVal);
      axiSlaveRegisterR(axilEp(0), x"028", 0, r.axiReadErrorVal);

      axiSlaveRegisterR(axilEp(0), x"02C", 0, r.dynamicRouteMasks(0));
      axiSlaveRegisterR(axilEp(0), x"02C", 8, r.dynamicRouteDests(0));
      axiSlaveRegisterR(axilEp(0), x"02C", 16, r.dynamicRouteMasks(1));
      axiSlaveRegisterR(axilEp(0), x"02C", 24, r.dynamicRouteDests(1));
      axiSlaveRegisterR(axilEp(0), x"030", 0, toSlv(4, 8));  -- version number, >= 1 if gpu enabled
      axiSlaveRegisterR(axilEp(0), x"034", 0, r.axiWriteTimeoutErrorCnt);
      axiSlaveRegister (axilEp(0), x"038", 0, v.axisDeMuxSelect);  -- 1: GPU path, 0: CPU path

      axiSlaveRegisterR(axilEp(0), x"03C", 0, r.minWriteBuffer);
      axiSlaveRegisterR(axilEp(0), x"040", 0, r.minReadBuffer);

      -- Closeout the transaction
      axiSlaveDefault(axilEp(0), v.writeSlaves(0), v.readSlaves(0), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- Axi-Lite Memory Range: 0x1000:0x1FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(1), writeMasters(1), readMasters(1), v.writeSlaves(1), v.readSlaves(1));

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegister (axilEp(1), toSlv(i*16+0, 12), 0, v.remoteWriteAddrL(i));  -- 0x1XX0
         axiSlaveRegister (axilEp(1), toSlv(i*16+4, 12), 0, v.remoteWriteAddrH(i));  -- 0x1XX4
         axiSlaveRegister (axilEp(1), toSlv(i*16+8, 12), 0, v.remoteWriteSize(i));  -- 0x1XX8
         axiWrDetect (axilEp(1), toSlv(i*16+12, 12), v.remoteWriteEn(i));  -- 0x1XXC
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp(1), v.writeSlaves(1), v.readSlaves(1), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- Axi-Lite Memory Range: 0x2000:0x2FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(2), writeMasters(2), readMasters(2), v.writeSlaves(2), v.readSlaves(2));

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegister (axilEp(2), toSlv(i*16+0, 12), 0, v.remoteReadAddrL(i));  -- 0x2XX0
         axiSlaveRegister (axilEp(2), toSlv(i*16+4, 12), 0, v.remoteReadAddrH(i));  -- 0x2XX4
         axiSlaveRegister (axilEp(2), toSlv(i*16+8, 12), 0, v.remoteReadSize(i));  -- 0x2XX8
         axiWrDetect (axilEp(2), toSlv(i*16+12, 12), v.remoteReadEn(i));  -- 0x2XXC
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp(2), v.writeSlaves(2), v.readSlaves(2), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- Axi-Lite Memory Range: 0x3000:0x3FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(3), writeMasters(3), readMasters(3), v.writeSlaves(3), v.readSlaves(3));

      for i in 0 to MAX_BUFFERS_G-1 loop
         axiSlaveRegisterR(axilEp(3), toSlv(i*16+0, 12), 0, r.totLatency(i));  -- 0x3XX0
         axiSlaveRegisterR(axilEp(3), toSlv(i*16+4, 12), 0, r.gpuLatency(i));  -- 0x3XX4
         axiSlaveRegisterR(axilEp(3), toSlv(i*16+8, 12), 0, r.wrLatency(i));  -- 0x3XX8
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp(3), v.writeSlaves(3), v.readSlaves(3), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- Update the minimum available buffers diagnostic register
      --------------------------------------------------------------------------------------------

      -- Pipeline the calculation to help with making timing
      v.wrBuffSize := (others => '0');
      v.rdBuffSize := (others => '0');
      for i in 0 to 7 loop
         v.wrBuffSizeVec(i) := toSlv(conv_integer(onesCount(r.remoteWriteEn(32*i+31 downto 32*i))), 9);
         v.wrBuffSize       := v.wrBuffSize + r.wrBuffSizeVec(i);
         v.rdBuffSizeVec(i) := toSlv(conv_integer(onesCount(r.remoteReadEn(32*i+31 downto 32*i))), 9);
         v.rdBuffSize       := v.rdBuffSize + r.rdBuffSizeVec(i);
      end loop;

      if (r.cntRst = '1') or (r.wrBuffSize < r.minWriteBuffer) then
         v.minWriteBuffer := r.wrBuffSize;
      end if;

      if (r.cntRst = '1') or (r.rdBuffSize < r.minReadBuffer) then
         v.minReadBuffer := r.rdBuffSize;
      end if;

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

               v.dmaWrDescAck.buffId(7 downto 0) := r.nextWriteIdx;

               v.dmaWrDescAck.metaAddr(31 downto 0)  := r.remoteWriteAddrL(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.metaAddr(63 downto 32) := r.remoteWriteAddrH(conv_integer(r.nextWriteIdx));
               v.dmaWrDescAck.address(31 downto 0)   := r.remoteWriteAddrL(conv_integer(r.nextWriteIdx)) + DMA_AXI_CONFIG_G.DATA_BYTES_C;
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

               v.wrLatencyEn(conv_integer(dmaWrDescRet.buffId(7 downto 0)))  := '0';
               v.gpuLatencyEn(conv_integer(dmaWrDescRet.buffId(7 downto 0))) := '1';

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
               v.dmaRdDescReq.buffId(7 downto 0) := r.nextReadIdx;

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

               v.totLatencyEn(conv_integer(dmaRdDescRet.buffId(7 downto 0))) := '0';

               if dmaRdDescRet.result /= "000" then
                  v.axiReadErrorCnt := r.axiReadErrorCnt + 1;
                  v.axiReadErrorVal := dmaRdDescRet.result;
               end if;

               v.txFrameCnt := r.txFrameCnt + 1;

               v.txState := IDLE_S;
            end if;

      end case;

      -- Check for GPU path
      if r.axisDeMuxSelect = '1' then
         v.dynamicRouteMasks(0) := x"00";
         v.dynamicRouteMasks(1) := x"FF";
         v.dynamicRouteDests(0) := x"00";
         v.dynamicRouteDests(1) := x"FF";

      -- Else using CPU path
      else
         v.dynamicRouteMasks(1) := x"00";
         v.dynamicRouteMasks(0) := x"FF";
         v.dynamicRouteDests(1) := x"00";
         v.dynamicRouteDests(0) := x"FF";

      end if;

      --------------------------------------------------------------------------------------------
      -- Outputs
      awCache           <= r.awCache;
      arCache           <= r.arCache;
      writeSlaves       <= r.writeSlaves;
      readSlaves        <= r.readSlaves;
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

