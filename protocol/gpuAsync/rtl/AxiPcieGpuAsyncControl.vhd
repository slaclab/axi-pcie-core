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
      TPD_G               : time          := 1 ns;
      DEFAULT_DEMUX_SEL_G : sl            := '1';  -- 1: GPU path, 0: CPU path
      DMA_AXI_CONFIG_G    : AxiConfigType := AXI_PCIE_CONFIG_C);
   port (
      -- AXI-Lite Interfaces (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- AXI-Lite Interfaces (axilClk domain)
      monReadMasters  : out AxiLiteReadMasterArray(1 downto 0);
      monReadSlaves   : in  AxiLiteReadSlaveArray(1 downto 0);
      monWriteMasters : out AxiLiteWriteMasterArray(1 downto 0);
      monWriteSlaves  : in  AxiLiteWriteSlaveArray(1 downto 0);

      -- AxiStreamDeMux  (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      axisDeMuxSelect : out sl;

      -- AXI4 Memory Config (axiClk domain)
      axiClk  : in  sl;
      axiRst  : in  sl;
      awCache : out slv(3 downto 0);
      arCache : out slv(3 downto 0);

      -- DMA Write Engine (axiClk domain)
      dmaWrDescReq    : in  AxiWriteDmaDescReqType;
      dmaWrDescAck    : out AxiWriteDmaDescAckType;
      dmaWrDescRet    : in  AxiWriteDmaDescRetType;
      dmaWrDescRetAck : out sl;

      -- DMA Read Engine (axiClk domain)
      dmaRdDescReq    : out AxiReadDmaDescReqType;
      dmaRdDescAck    : in  sl;
      dmaRdDescRet    : in  AxiReadDmaDescRetType;
      dmaRdDescRetAck : out sl);
end AxiPcieGpuAsyncControl;

architecture rtl of AxiPcieGpuAsyncControl is

   constant MAX_BUFFERS_C : positive := 1024;

   constant BUFF_BIT_WIDTH_C : positive := bitSize(MAX_BUFFERS_C-1);

   constant AXIL_BASE_INDEX_C    : natural := 0;
   constant AXIL_WR_EN_INDEX_C   : natural := 1;
   constant AXIL_RD_EN_INDEX_C   : natural := 2;
   constant AXIL_RX_MON_INDEX_C  : natural := 3;
   constant AXIL_TX_MON_INDEX_C  : natural := 4;
   constant AXIL_WR_ADDR_INDEX_C : natural := 5;
   constant AXIL_RD_ADDR_INDEX_C : natural := 6;

   constant NUM_AXIL_MASTERS_C : positive := 7;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      AXIL_BASE_INDEX_C    => (
         baseAddr          => x"0002_8000",  -- 0x0002_8000:0x0002_8FFF: Base Control Registers
         addrBits          => 12,
         connectivity      => x"FFFF"),
      AXIL_WR_EN_INDEX_C   => (
         baseAddr          => x"0002_9000",  -- 0x0002_9000:0x0002_9FFF: 0x100/4B = 1k buffers
         addrBits          => 12,
         connectivity      => x"FFFF"),
      AXIL_RD_EN_INDEX_C   => (
         baseAddr          => x"0002_A000",  -- 0x0002_A000:0x0002_AFFF: 0x100/4B = 1k buffers
         addrBits          => 12,
         connectivity      => x"FFFF"),
      AXIL_RX_MON_INDEX_C  => (
         baseAddr          => x"0002_B000",  -- 0x0002_B000:0x0002_B0FF: GPU AXI Stream Inbound Monitor
         addrBits          => 8,
         connectivity      => x"FFFF"),
      AXIL_TX_MON_INDEX_C  => (
         baseAddr          => x"0002_B100",  -- 0x0002_B100:0x0002_B1FF: GPU AXI Stream Outbound Monitor
         addrBits          => 8,
         connectivity      => x"FFFF"),
      AXIL_WR_ADDR_INDEX_C => (
         baseAddr          => x"0002_C000",  -- 0x0002_C000:0x0002_DFFF: 0x200/8B = 1k buffers
         addrBits          => 13,
         connectivity      => x"FFFF"),
      AXIL_RD_ADDR_INDEX_C => (
         baseAddr          => x"0002_E000",  -- 0x0002_E000:0x0002_FFFF: 0x200/8B = 1k buffers
         addrBits          => 13,
         connectivity      => x"FFFF"));

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
      writeCount              : slv(BUFF_BIT_WIDTH_C-1 downto 0);
      nextWriteIdx            : slv(BUFF_BIT_WIDTH_C-1 downto 0);
      remoteWriteSize         : slv(31 downto 0);
      remoteWriteEn           : slv(MAX_BUFFERS_C-1 downto 0);
      -- Read/TX Signals
      txState                 : StateType;
      txFrameCnt              : slv(31 downto 0);
      axiReadErrorCnt         : slv(31 downto 0);
      axiReadErrorVal         : slv(2 downto 0);
      arcache                 : slv(3 downto 0);
      readEnable              : sl;
      readCount               : slv(BUFF_BIT_WIDTH_C-1 downto 0);
      nextReadIdx             : slv(BUFF_BIT_WIDTH_C-1 downto 0);
      remoteReadSize          : slv(31 downto 0);
      remoteReadEn            : slv(MAX_BUFFERS_C-1 downto 0);
      -- Latency Measurements
      totLatency              : slv(31 downto 0);
      totLatencyCnt           : slv(31 downto 0);
      totLatencyEn            : sl;
      gpuLatency              : slv(31 downto 0);
      gpuLatencyCnt           : slv(31 downto 0);
      gpuLatencyEn            : sl;
      wrLatency               : slv(31 downto 0);
      wrLatencyCnt            : slv(31 downto 0);
      wrLatencyEn             : sl;
      -- Buffer Measurements
      minWriteBuffer          : slv(BUFF_BIT_WIDTH_C downto 0);
      minReadBuffer           : slv(BUFF_BIT_WIDTH_C downto 0);
      -- wrBuffSizeVecA          : Slv11Array(31 downto 0);
      -- rdBuffSizeVecA          : Slv11Array(31 downto 0);
      -- wrBuffSizeVecB          : Slv11Array(15 downto 0);
      -- rdBuffSizeVecB          : Slv11Array(15 downto 0);
      -- wrBuffSizeVecC          : Slv11Array(7 downto 0);
      -- rdBuffSizeVecC          : Slv11Array(7 downto 0);
      -- wrBuffSizeVecD          : Slv11Array(3 downto 0);
      -- rdBuffSizeVecD          : Slv11Array(3 downto 0);
      -- wrBuffSizeVecE          : Slv11Array(1 downto 0);
      -- rdBuffSizeVecE          : Slv11Array(1 downto 0);
      wrMonIdx                : natural range 0 to MAX_BUFFERS_C-1;
      rdMonIdx                : natural range 0 to MAX_BUFFERS_C-1;
      wrMonCnt                : slv(BUFF_BIT_WIDTH_C downto 0);
      rdMonCnt                : slv(BUFF_BIT_WIDTH_C downto 0);
      wrBuffSize              : slv(BUFF_BIT_WIDTH_C downto 0);
      rdBuffSize              : slv(BUFF_BIT_WIDTH_C downto 0);
      -- DMA Control
      dmaWrDescAck            : AxiWriteDmaDescAckType;
      dmaWrDescRetAck         : sl;
      dmaRdDescReq            : AxiReadDmaDescReqType;
      dmaRdDescRetAck         : sl;
      -- AXI-Lite Control
      readSlaves              : AxiLiteReadSlaveArray(2 downto 0);
      writeSlaves             : AxiLiteWriteSlaveArray(2 downto 0);
      -- DEMUX Control
      axisDeMuxSelect         : sl;
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
      remoteWriteSize         => (others => '0'),
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
      remoteReadSize          => (others => '0'),
      remoteReadEn            => (others => '0'),
      -- Latency Measurements
      totLatency              => (others => '0'),
      totLatencyCnt           => (others => '0'),
      totLatencyEn            => '0',
      gpuLatency              => (others => '0'),
      gpuLatencyCnt           => (others => '0'),
      gpuLatencyEn            => '0',
      wrLatency               => (others => '0'),
      wrLatencyCnt            => (others => '0'),
      wrLatencyEn             => '0',
      -- Buffer Measurements
      minWriteBuffer          => (others => '0'),
      minReadBuffer           => (others => '0'),
      -- wrBuffSizeVecA          => (others => (others => '0')),
      -- rdBuffSizeVecA          => (others => (others => '0')),
      -- wrBuffSizeVecB          => (others => (others => '0')),
      -- rdBuffSizeVecB          => (others => (others => '0')),
      -- wrBuffSizeVecC          => (others => (others => '0')),
      -- rdBuffSizeVecC          => (others => (others => '0')),
      -- wrBuffSizeVecD          => (others => (others => '0')),
      -- rdBuffSizeVecD          => (others => (others => '0')),
      -- wrBuffSizeVecE          => (others => (others => '0')),
      -- rdBuffSizeVecE          => (others => (others => '0')),
      wrMonIdx                => 0,
      rdMonIdx                => 0,
      wrMonCnt                => (others => '0'),
      rdMonCnt                => (others => '0'),
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
      axisDeMuxSelect         => DEFAULT_DEMUX_SEL_G);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal writeMasters : AxiLiteWriteMasterArray(2 downto 0);
   signal writeSlaves  : AxiLiteWriteSlaveArray(2 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal readMasters  : AxiLiteReadMasterArray(2 downto 0);
   signal readSlaves   : AxiLiteReadSlaveArray(2 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal remoteWriteAddr : slv(63 downto 0);
   signal remoteReadAddr  : slv(63 downto 0);

begin

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   GEN_VEC :
   for i in 2 downto 0 generate
      U_AxiLiteAsync : entity surf.AxiLiteAsync
         generic map (
            TPD_G           => TPD_G,
            COMMON_CLK_G    => false,
            NUM_ADDR_BITS_G => 12)
         port map (
            -- Slave Interface
            sAxiClk         => axilClk,
            sAxiClkRst      => axilRst,
            sAxiReadMaster  => axilReadMasters(i),
            sAxiReadSlave   => axilReadSlaves(i),
            sAxiWriteMaster => axilWriteMasters(i),
            sAxiWriteSlave  => axilWriteSlaves(i),
            -- Master Interface
            mAxiClk         => axiClk,
            mAxiClkRst      => axiRst,
            mAxiReadMaster  => readMasters(i),
            mAxiReadSlave   => readSlaves(i),
            mAxiWriteMaster => writeMasters(i),
            mAxiWriteSlave  => writeSlaves(i));
   end generate GEN_VEC;

   -------------------------------------------
   -- remoteWriteAddr RAM for address decoding
   -------------------------------------------
   U_remoteWriteAddr : entity surf.AxiDualPortRam
      generic map (
         TPD_G          => TPD_G,
         COMMON_CLK_G   => false,
         SYNTH_MODE_G   => "xpm",
         MEMORY_TYPE_G  => "block",
         READ_LATENCY_G => 1,
         DATA_WIDTH_G   => 64,
         ADDR_WIDTH_G   => BUFF_BIT_WIDTH_C)
      port map (
         -- AXI-Lite Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(AXIL_WR_ADDR_INDEX_C),
         axiReadSlave   => axilReadSlaves(AXIL_WR_ADDR_INDEX_C),
         axiWriteMaster => axilWriteMasters(AXIL_WR_ADDR_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(AXIL_WR_ADDR_INDEX_C),
         -- Standard Port
         clk            => axiClk,
         addr           => r.nextWriteIdx,
         dout           => remoteWriteAddr);

   -------------------------------------------
   -- remoteReadAddr RAM for address decoding
   -------------------------------------------
   U_remoteReadAddr : entity surf.AxiDualPortRam
      generic map (
         TPD_G          => TPD_G,
         COMMON_CLK_G   => false,
         SYNTH_MODE_G   => "xpm",
         MEMORY_TYPE_G  => "block",
         READ_LATENCY_G => 1,
         DATA_WIDTH_G   => 64,
         ADDR_WIDTH_G   => BUFF_BIT_WIDTH_C)
      port map (
         -- AXI-Lite Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(AXIL_RD_ADDR_INDEX_C),
         axiReadSlave   => axilReadSlaves(AXIL_RD_ADDR_INDEX_C),
         axiWriteMaster => axilWriteMasters(AXIL_RD_ADDR_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(AXIL_RD_ADDR_INDEX_C),
         -- Standard Port
         clk            => axiClk,
         addr           => r.nextReadIdx,
         dout           => remoteReadAddr);

   ------------------------------------------
   -- GPU AXI Stream Inbound/Outbound Monitor
   ------------------------------------------

   monReadMasters(1 downto 0) <= axilReadMasters(AXIL_TX_MON_INDEX_C downto AXIL_RX_MON_INDEX_C);

   axilReadSlaves(AXIL_TX_MON_INDEX_C downto AXIL_RX_MON_INDEX_C) <= monReadSlaves(1 downto 0);

   monWriteMasters(1 downto 0) <= axilWriteMasters(AXIL_TX_MON_INDEX_C downto AXIL_RX_MON_INDEX_C);

   axilWriteSlaves(AXIL_TX_MON_INDEX_C downto AXIL_RX_MON_INDEX_C) <= monWriteSlaves(1 downto 0);

   comb : process (axiRst, dmaRdDescRet, dmaWrDescReq, dmaWrDescRet, r,
                   readMasters, remoteReadAddr, remoteWriteAddr, writeMasters) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointArray(2 downto 0);
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
      if (r.totLatencyEn = '1') and (r.totLatencyCnt /= x"FFFF_FFFF") then
         v.totLatencyCnt := r.totLatencyCnt + 1;
      end if;
      if (r.gpuLatencyEn = '1') and (r.gpuLatencyCnt /= x"FFFF_FFFF") then
         v.gpuLatencyCnt := r.gpuLatencyCnt + 1;
      end if;
      if (r.wrLatencyEn = '1') and (r.wrLatencyCnt /= x"FFFF_FFFF") then
         v.wrLatencyCnt := r.wrLatencyCnt + 1;
      end if;

      --------------------------------------------------------------------------------------------
      -- Base Control Registers: 0x0002_8000:0x0002_8FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(0), writeMasters(0), readMasters(0), v.writeSlaves(0), v.readSlaves(0));

      axiSlaveRegisterR(axilEp(0), x"00", 0, toSlv(MAX_BUFFERS_C, 16));

      axiSlaveRegister (axilEp(0), x"04", 0, v.arcache);
      axiSlaveRegister (axilEp(0), x"04", 8, v.awcache);
      axiSlaveRegisterR(axilEp(0), x"04", 16, toSlv(DMA_AXI_CONFIG_G.DATA_BYTES_C, 8));

      axiSlaveRegister (axilEp(0), x"08", 0, v.writeCount);
      axiSlaveRegister (axilEp(0), x"08", 15, v.writeEnable);
      axiSlaveRegister (axilEp(0), x"08", 16, v.readCount);
      axiSlaveRegister (axilEp(0), x"08", 31, v.readEnable);

      axiSlaveRegisterR(axilEp(0), x"10", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp(0), x"14", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp(0), x"18", 0, r.axiWriteErrorCnt);
      axiSlaveRegisterR(axilEp(0), x"1C", 0, r.axiReadErrorCnt);

      axiSlaveRegister (axilEp(0), x"20", 0, v.cntRst);
      axiSlaveRegisterR(axilEp(0), x"24", 0, r.axiWriteErrorVal);
      axiSlaveRegisterR(axilEp(0), x"28", 0, r.axiReadErrorVal);

      -- Offset 0x2C: Legacy dynamicRouteMasks/dynamicRouteDests

      axiSlaveRegisterR(axilEp(0), x"30", 0, toSlv(4, 8));  -- version number, >= 1 if gpu enabled
      axiSlaveRegisterR(axilEp(0), x"34", 0, r.axiWriteTimeoutErrorCnt);
      axiSlaveRegister (axilEp(0), x"38", 0, v.axisDeMuxSelect);  -- 1: GPU path, 0: CPU path

      axiSlaveRegisterR(axilEp(0), x"3C", 0, r.minWriteBuffer);
      axiSlaveRegisterR(axilEp(0), x"40", 0, r.minReadBuffer);

      axiSlaveRegisterR(axilEp(0), x"48", 0, r.totLatency);  -- Only measure for buffer[index=0]
      axiSlaveRegisterR(axilEp(0), x"50", 0, r.gpuLatency);  -- Only measure for buffer[index=0]
      axiSlaveRegisterR(axilEp(0), x"58", 0, r.wrLatency);  -- Only measure for buffer[index=0]

      axiSlaveRegister (axilEp(0), x"60", 0, v.remoteWriteSize);
      axiSlaveRegister (axilEp(0), x"64", 0, v.remoteReadSize);

      -- Closeout the transaction
      axiSlaveDefault(axilEp(0), v.writeSlaves(0), v.readSlaves(0), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- remoteWriteEn Write-Only: 0x0002_9000:0x0002_9FFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(1), writeMasters(1), readMasters(1), v.writeSlaves(1), v.readSlaves(1));

      for i in 0 to MAX_BUFFERS_C-1 loop
         axiWrDetect(axilEp(1), toSlv(i*4, 12), v.remoteWriteEn(i));
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp(1), v.writeSlaves(1), v.readSlaves(1), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- remoteReadEn Write-Only: 0x0002_A000:0x0002_AFFF
      --------------------------------------------------------------------------------------------

      -- Determine the transaction
      axiSlaveWaitTxn(axilEp(2), writeMasters(2), readMasters(2), v.writeSlaves(2), v.readSlaves(2));

      for i in 0 to MAX_BUFFERS_C-1 loop
         axiWrDetect(axilEp(2), toSlv(i*4, 12), v.remoteReadEn(i));
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp(2), v.writeSlaves(2), v.readSlaves(2), AXI_RESP_DECERR_C);

      --------------------------------------------------------------------------------------------
      -- Update the minimum available buffers diagnostic register
      --------------------------------------------------------------------------------------------

--      v.wrBuffSizeVecA := (others => (others => '0'));
--      v.rdBuffSizeVecA := (others => (others => '0'));
--
--      for i in 0 to 31 loop
--
--         if (32*i <= r.writeCount) then
--            if (32*i + 31 <= r.writeCount) then
--               -- Full 32-bit block valid
--               v.wrBuffSizeVecA(i) := toSlv(conv_integer(onesCount(r.remoteWriteEn(32*i+31 downto 32*i))), 11);
--            else
--               -- Partial block (last block)
--               v.wrBuffSizeVecA(i) := toSlv(conv_integer(onesCount(r.remoteWriteEn(conv_integer(r.writeCount) downto 32*i))), 11);
--            end if;
--         end if;
--
--         if (32*i <= r.readCount) then
--            if (32*i + 31 <= r.readCount) then
--               -- Full 32-bit block valid
--               v.rdBuffSizeVecA(i) := toSlv(conv_integer(onesCount(r.remoteReadEn(32*i+31 downto 32*i))), 11);
--            else
--               -- Partial block
--               v.rdBuffSizeVecA(i) := toSlv(conv_integer(onesCount(r.remoteReadEn(conv_integer(r.readCount) downto 32*i))), 11);
--            end if;
--         end if;
--
--      end loop;
--
--      for i in 0 to 15 loop
--         v.wrBuffSizeVecB(i) := r.wrBuffSizeVecA(i*2+0) + r.wrBuffSizeVecA(i*2+1);
--         v.rdBuffSizeVecB(i) := r.rdBuffSizeVecA(i*2+0) + r.rdBuffSizeVecA(i*2+1);
--      end loop;
--
--      for i in 0 to 7 loop
--         v.wrBuffSizeVecC(i) := r.wrBuffSizeVecB(i*2+0) + r.wrBuffSizeVecB(i*2+1);
--         v.rdBuffSizeVecC(i) := r.rdBuffSizeVecB(i*2+0) + r.rdBuffSizeVecB(i*2+1);
--      end loop;
--
--      for i in 0 to 3 loop
--         v.wrBuffSizeVecD(i) := r.wrBuffSizeVecC(i*2+0) + r.wrBuffSizeVecC(i*2+1);
--         v.rdBuffSizeVecD(i) := r.rdBuffSizeVecC(i*2+0) + r.rdBuffSizeVecC(i*2+1);
--      end loop;
--
--      for i in 0 to 1 loop
--         v.wrBuffSizeVecE(i) := r.wrBuffSizeVecD(i*2+0) + r.wrBuffSizeVecD(i*2+1);
--         v.rdBuffSizeVecE(i) := r.rdBuffSizeVecD(i*2+0) + r.rdBuffSizeVecD(i*2+1);
--      end loop;
--
--      v.wrBuffSize := r.wrBuffSizeVecE(0) + r.wrBuffSizeVecE(1);
--      v.rdBuffSize := r.rdBuffSizeVecE(0) + r.rdBuffSizeVecE(1);
-----------------------------------------------------------------------------------
-- Note to future self:
--    While the commented out code above is the most acurate way to calculate
--    the number of buffers, I was getting a crash in synthesis:
--    .../2025.2/Vivado/bin/rdiArgs.sh: line 57: 3371451 Killed "$RDI_PROG" "$@"
--    So I recoded it in the code below as a less acurate measurement but probably
--    "good enough" for debugging
-----------------------------------------------------------------------------------

      -- Check for 1st index
      if (r.wrMonIdx = 0) then
         -- Reset the counter
         v.wrMonCnt := (others => '0');
      end if;

      -- Check for a enable bit
      if (r.remoteWriteEn(r.wrMonIdx) = '1') then
         -- Increment the counter
         v.wrMonCnt := v.wrMonCnt + 1;  -- using variable (not register) for accumulation
      end if;

      -- Check for last index
      if (r.wrMonIdx = r.writeCount) then
         -- Reset the index
         v.wrMonIdx   := 0;
         -- Sample the counter's variable (not register) value
         v.wrBuffSize := v.wrMonCnt;
      else
         -- Increment the index
         v.wrMonIdx := r.wrMonIdx + 1;
      end if;

      -- Check for reset or new min. value condition
      if (r.cntRst = '1') or (r.wrBuffSize < r.minWriteBuffer) then
         -- Update the value
         v.minWriteBuffer := r.wrBuffSize;
      end if;

      --------------------------------------------------------------------------------------------

      -- Check for 1st index
      if (r.rdMonIdx = 0) then
         -- Reset the counter
         v.rdMonCnt := (others => '0');
      end if;

      -- Check for a enable bit
      if (r.remoteReadEn(r.rdMonIdx) = '1') then
         -- Increment the counter
         v.rdMonCnt := v.rdMonCnt + 1;  -- using variable (not register) for accumulation
      end if;

      -- Check for last index
      if (r.rdMonIdx = r.readCount) then
         -- Reset the index
         v.rdMonIdx   := 0;
         -- Sample the counter's variable (not register) value
         v.rdBuffSize := v.rdMonCnt;
      else
         -- Increment the index
         v.rdMonIdx := r.rdMonIdx + 1;
      end if;

      -- Check for reset or new min. value condition
      if (r.cntRst = '1') or (r.rdBuffSize < r.minReadBuffer) then
         -- Update the value
         v.minReadBuffer := r.rdBuffSize;
      end if;

      --------------------------------------------------------------------------------------------
      -- Write/RX State Machine
      --------------------------------------------------------------------------------------------
      case r.rxState is

         when IDLE_S =>

            if r.remoteWriteEn(0) = '0' then
               v.gpuLatencyEn := '0';
               v.gpuLatency   := r.gpuLatencyCnt;
            end if;

            if dmaWrDescReq.valid = '1' then
               v.dmaWrDescAck.dropEn     := not r.writeEnable;
               v.dmaWrDescAck.maxSize    := r.remoteWriteSize;
               v.dmaWrDescAck.contEn     := '0';
               v.dmaWrDescAck.metaEnable := '1';

               v.dmaWrDescAck.buffId(BUFF_BIT_WIDTH_C-1 downto 0) := r.nextWriteIdx;

               v.dmaWrDescAck.metaAddr := remoteWriteAddr;
               v.dmaWrDescAck.address  := remoteWriteAddr + DMA_AXI_CONFIG_G.DATA_BYTES_C;

               if r.remoteWriteEn(conv_integer(r.nextWriteIdx)) = '1' or r.writeEnable = '0' then
                  v.dmaWrDescAck.valid := '1';
                  v.rxState            := MOVE_S;

                  if r.writeEnable = '1' then
                     v.remoteWriteEn(conv_integer(r.nextWriteIdx)) := '0';

                     if (r.nextWriteIdx = 0) then
                        v.totLatencyEn  := '1';
                        v.totLatencyCnt := (others => '0');

                        v.gpuLatencyEn  := '0';
                        v.gpuLatencyCnt := (others => '0');

                        v.wrLatencyEn  := '1';
                        v.wrLatencyCnt := (others => '0');
                     end if;

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

               if dmaWrDescRet.buffId(BUFF_BIT_WIDTH_C-1 downto 0) = 0 then
                  v.wrLatencyEn  := '0';
                  v.wrLatency    := r.wrLatencyCnt;
                  v.gpuLatencyEn := '1';
               end if;

               if dmaWrDescRet.result /= "0000" then
                  v.axiWriteErrorVal := dmaWrDescRet.result;
                  if (r.axiWriteErrorCnt /= x"FFFF_FFFF") then
                     v.axiWriteErrorCnt := r.axiWriteErrorCnt + 1;
                  end if;
               end if;

               if dmaWrDescRet.result(3) = '1' then
                  if (r.axiWriteTimeoutErrorCnt /= x"FFFF_FFFF") then
                     v.axiWriteTimeoutErrorCnt := r.axiWriteTimeoutErrorCnt + 1;
                  end if;
               end if;

               v.rxFrameCnt := r.rxFrameCnt + 1;
               v.rxState    := IDLE_S;
            end if;
      end case;

      --------------------------------------------------------------------------------------------
      -- Read/TX State Machine
      --------------------------------------------------------------------------------------------
      case r.txState is

         when IDLE_S =>

            if r.readEnable = '1' and r.remoteReadEn(conv_integer(r.nextReadIdx)) = '1' then
               v.remoteReadEn(conv_integer(r.nextReadIdx)) := '0';


               if r.nextReadIdx >= r.readCount then
                  v.nextReadIdx := (others => '0');
               else
                  v.nextReadIdx := r.nextReadIdx + 1;
               end if;

               v.dmaRdDescReq.buffId(BUFF_BIT_WIDTH_C-1 downto 0) := r.nextReadIdx;

               v.dmaRdDescReq.valid     := '1';
               v.dmaRdDescReq.firstUser := x"02";
               v.dmaRdDescReq.lastUser  := (others => '0');
               v.dmaRdDescReq.size      := r.remoteReadSize;
               v.dmaRdDescReq.continue  := '0';
               v.dmaRdDescReq.id        := (others => '0');
               v.dmaRdDescReq.dest      := (others => '0');
               v.dmaRdDescReq.address   := remoteReadAddr;

               v.txState := MOVE_S;
            end if;

            if r.readEnable = '0' then
               v.nextReadIdx := (others => '0');
            end if;

         when MOVE_S =>

            if dmaRdDescRet.valid = '1' then
               v.dmaRdDescRetAck := '1';

               if dmaRdDescRet.buffId(BUFF_BIT_WIDTH_C-1 downto 0) = 0 then
                  v.totLatencyEn := '0';
                  v.totLatency   := r.totLatencyCnt;
               end if;

               if dmaRdDescRet.result /= "000" then
                  v.axiReadErrorVal := dmaRdDescRet.result;
                  if (r.axiReadErrorCnt /= x"FFFF_FFFF") then
                     v.axiReadErrorCnt := r.axiReadErrorCnt + 1;
                  end if;
               end if;

               v.txFrameCnt := r.txFrameCnt + 1;

               v.txState := IDLE_S;
            end if;

      end case;

      --------------------------------------------------------------------------------------------
      -- Outputs
      --------------------------------------------------------------------------------------------
      awCache         <= r.awCache;
      arCache         <= r.arCache;
      writeSlaves     <= r.writeSlaves;
      readSlaves      <= r.readSlaves;
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

   U_axisDeMuxSelect : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axisClk,
         -- Input
         dataIn  => r.axisDeMuxSelect,
         dataOut => axisDeMuxSelect);

end rtl;
