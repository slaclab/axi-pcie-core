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
use surf.AxiStreamPacketizer2Pkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

entity AxiPcieGpuAsyncCore is
   generic (
      TPD_G               : time                    := 1 ns;
      DEFAULT_DEMUX_SEL_G : sl                      := '1';  -- 1: GPU path, 0: CPU path
      BURST_BYTES_G       : integer range 1 to 4096 := 4096;
      DMA_AXIS_CONFIG_G   : AxiStreamConfigType);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- AXI Stream Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      sAxisMaster     : in  AxiStreamMasterType;
      sAxisSlave      : out AxiStreamSlaveType;
      mAxisMaster     : out AxiStreamMasterType;
      mAxisSlave      : in  AxiStreamSlaveType;
      -- AXI Stream Interface bypass (axisClk domain)
      bypassMaster    : out AxiStreamMasterType;
      bypassSlave     : in  AxiStreamSlaveType;
      -- AXI4 Interfaces (axiClk domain)
      axiClk          : in  sl;
      axiRst          : in  sl;
      axiWriteMaster  : out AxiWriteMasterType;
      axiWriteSlave   : in  AxiWriteSlaveType;
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType);

end AxiPcieGpuAsyncCore;

architecture mapping of AxiPcieGpuAsyncCore is

   constant PCIE_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => AXI_PCIE_CONFIG_C.DATA_BYTES_C,  -- Match the AXI and AXIS widths for M_AXI port
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 8,
      TKEEP_MODE_C  => TKEEP_COUNT_C,  -- AXI DMA V2 uses TKEEP_COUNT_C to help meet timing
      TUSER_BITS_C  => 8,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   signal monReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal monReadSlaves   : AxiLiteReadSlaveArray(1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal monWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal monWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal dmaWrDescReq    : AxiWriteDmaDescReqType;
   signal dmaWrDescAck    : AxiWriteDmaDescAckType;
   signal dmaWrDescRet    : AxiWriteDmaDescRetType;
   signal dmaWrDescRetAck : sl;

   signal dmaRdDescReq    : AxiReadDmaDescReqType;
   signal dmaRdDescAck    : sl;
   signal dmaRdDescRet    : AxiReadDmaDescRetType;
   signal dmaRdDescRetAck : sl;

   signal axisDeMuxSelect   : sl;
   signal dynamicRouteMasks : Slv8Array(1 downto 0);
   signal dynamicRouteDests : Slv8Array(1 downto 0);
   signal mAxisDemuxMasters : AxiStreamMasterArray(1 downto 0);
   signal mAxisDemuxSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal awCache : slv(3 downto 0);
   signal arCache : slv(3 downto 0);

   signal sAxisMasterInt : AxiStreamMasterType;
   signal sAxisSlaveInt  : AxiStreamSlaveType;
   signal mAxisMasterInt : AxiStreamMasterType;
   signal mAxisSlaveInt  : AxiStreamSlaveType;

   signal dataWriteMaster : AxiWriteMasterType;
   signal dataWriteSlave  : AxiWriteSlaveType;

   signal gpuTxAckMaster : AxiWriteMasterType;
   signal gpuTxAckSlave  : AxiWriteSlaveType;

begin

   -- direct connection to Pcie core from Demux
   bypassMaster        <= mAxisDemuxMasters(1);
   mAxisDemuxSlaves(1) <= bypassSlave;

   ------------------------------
   -- AXI-Lite Control/Monitoring
   ------------------------------
   U_AxiPcieGpuAsyncControl : entity axi_pcie_core.AxiPcieGpuAsyncControl
      generic map (
         TPD_G               => TPD_G,
         DEFAULT_DEMUX_SEL_G => DEFAULT_DEMUX_SEL_G,
         DMA_AXI_CONFIG_G    => AXI_PCIE_CONFIG_C)
      port map (
         -- AXI-Lite Interfaces (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- AXI Stream Monitors (axilClk domain)
         monWriteMasters => monWriteMasters,
         monWriteSlaves  => monWriteSlaves,
         monReadMasters  => monReadMasters,
         monReadSlaves   => monReadSlaves,
         -- AxiStreamDeMux  (axisClk domain)
         axisClk         => axisClk,
         axisRst         => axisRst,
         axisDeMuxSelect => axisDeMuxSelect,
         -- AXI4 Memory Config (axiClk domain)
         axiClk          => axiClk,
         axiRst          => axiRst,
         awCache         => awCache,
         arCache         => arCache,
         -- GPU TX Doorbell ACK (axiClk domain)
         gpuTxAckMaster  => gpuTxAckMaster,
         gpuTxAckSlave   => gpuTxAckSlave,
         -- DMA Write Engine (axiClk domain)
         dmaWrDescReq    => dmaWrDescReq,
         dmaWrDescAck    => dmaWrDescAck,
         dmaWrDescRet    => dmaWrDescRet,
         dmaWrDescRetAck => dmaWrDescRetAck,
         -- DMA Read Engine (axiClk domain)
         dmaRdDescReq    => dmaRdDescReq,
         dmaRdDescAck    => dmaRdDescAck,
         dmaRdDescRet    => dmaRdDescRet,
         dmaRdDescRetAck => dmaRdDescRetAck);

   ------------------------------
   -- AXI-Stream Demux
   ------------------------------
   U_AxiStreamDeMux : entity surf.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => 2,
         MODE_G        => "DYNAMIC")
      port map (
         axisClk           => axisClk,
         axisRst           => axisRst,
         dynamicRouteMasks => dynamicRouteMasks,
         dynamicRouteDests => dynamicRouteDests,
         sAxisMaster       => sAxisMaster,
         sAxisSlave        => sAxisSlave,
         mAxisMasters      => mAxisDemuxMasters,
         mAxisSlaves       => mAxisDemuxSlaves);

   process(axisDeMuxSelect)
   begin
      -- Check for GPU path
      if axisDeMuxSelect = '1' then
         dynamicRouteMasks(0) <= x"00";
         dynamicRouteMasks(1) <= x"FF";
         dynamicRouteDests(0) <= x"00";
         dynamicRouteDests(1) <= x"FF";

      -- Else using CPU path
      else
         dynamicRouteMasks(1) <= x"00";
         dynamicRouteMasks(0) <= x"FF";
         dynamicRouteDests(1) <= x"00";
         dynamicRouteDests(0) <= x"FF";
      end if;
   end process;

   ------------------------------------
   -- Stream receiver to GPU DMA
   ------------------------------------
   AxisRxFifo : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => PCIE_AXIS_CONFIG_C)
      port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => mAxisDemuxMasters(0),
         sAxisSlave  => mAxisDemuxSlaves(0),
         mAxisClk    => axiClk,
         mAxisRst    => axiRst,
         mAxisMaster => sAxisMasterInt,
         mAxisSlave  => sAxisSlaveInt);

   U_DmaWrite : entity surf.AxiStreamDmaV2Write
      generic map (
         TPD_G             => TPD_G,
         AXI_READY_EN_G    => true,
         AXIS_CONFIG_G     => PCIE_AXIS_CONFIG_C,
         AXI_CONFIG_G      => AXI_PCIE_CONFIG_C,
         BURST_BYTES_G     => BURST_BYTES_G,
         ACK_WAIT_BVALID_G => false)
      port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaWrDescReq    => dmaWrDescReq,
         dmaWrDescAck    => dmaWrDescAck,
         dmaWrDescRet    => dmaWrDescRet,
         dmaWrDescRetAck => dmaWrDescRetAck,
         axiCache        => awCache,
         axisMaster      => sAxisMasterInt,
         axisSlave       => sAxisSlaveInt,
         axiWriteMaster  => dataWriteMaster,
         axiWriteSlave   => dataWriteSlave);

   U_DmaWriteMux : entity surf.AxiStreamDmaV2WriteMux
      generic map (
         TPD_G             => TPD_G,
         AXI_CONFIG_G      => AXI_PCIE_CONFIG_C,
         AXI_READY_EN_G    => true,
         ACK_WAIT_BVALID_G => false)
      port map (
         -- Clock and reset
         axiClk          => axiClk,
         axiRst          => axiRst,
         -- DMA Data Write Path
         dataWriteMaster => dataWriteMaster,
         dataWriteSlave  => dataWriteSlave,
         -- DMA Descriptor Write Path
         descWriteMaster => gpuTxAckMaster,
         descWriteSlave  => gpuTxAckSlave,
         -- MUX Write Path
         mAxiWriteMaster => axiWriteMaster,
         mAxiWriteSlave  => axiWriteSlave,
         mAxiWriteCtrl   => AXI_CTRL_UNUSED_C);

   ------------------------------------
   -- Stream transmitter from GPU DMA
   ------------------------------------
   U_DmaRead : entity surf.AxiStreamDmaV2Read
      generic map (
         TPD_G           => TPD_G,
         AXIS_READY_EN_G => true,
         AXIS_CONFIG_G   => PCIE_AXIS_CONFIG_C,
         AXI_CONFIG_G    => AXI_PCIE_CONFIG_C,
         BURST_BYTES_G   => BURST_BYTES_G,
         PEND_THRESH_G   => 1024*AXI_PCIE_CONFIG_C.DATA_BYTES_C)  -- 1024 deep buffering (Master 512 deep + Slave 512 deep) in the AxiPcieCrossbar
      port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaRdDescReq    => dmaRdDescReq,
         dmaRdDescAck    => dmaRdDescAck,
         dmaRdDescRet    => dmaRdDescRet,
         dmaRdDescRetAck => dmaRdDescRetAck,
         axiCache        => arCache,
         axisMaster      => mAxisMasterInt,
         axisSlave       => mAxisSlaveInt,
         axisCtrl        => AXI_STREAM_CTRL_INIT_C,
         axiReadMaster   => axiReadMaster,
         axiReadSlave    => axiReadSlave);

   AxisTxFifo : entity surf.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         SLAVE_AXI_CONFIG_G  => PCIE_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         sAxisClk    => axiClk,
         sAxisRst    => axiRst,
         sAxisMaster => mAxisMasterInt,
         sAxisSlave  => mAxisSlaveInt,
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => mAxisMaster,
         mAxisSlave  => mAxisSlave);

   ---------------------------------
   -- Monitor the GPU Inbound Stream
   ---------------------------------
   U_GpuIbAxisMon : entity surf.AxiStreamMonAxiL
      generic map(
         TPD_G            => TPD_G,
         COMMON_CLK_G     => false,
         AXIS_CLK_FREQ_G  => DMA_CLK_FREQ_C,
         AXIS_NUM_SLOTS_G => 1,
         AXIS_CONFIG_G    => PCIE_AXIS_CONFIG_C)
      port map(
         -- AXIS Stream Interface
         axisClk          => axiClk,
         axisRst          => axiRst,
         axisMasters(0)   => sAxisMasterInt,
         axisSlaves(0)    => sAxisSlaveInt,
         -- AXI lite slave port for register access
         axilClk          => axilClk,
         axilRst          => axilRst,
         sAxilWriteMaster => monWriteMasters(0),
         sAxilWriteSlave  => monWriteSlaves(0),
         sAxilReadMaster  => monReadMasters(0),
         sAxilReadSlave   => monReadSlaves(0));

   ---------------------------------
   -- Monitor the GPU Inbound Stream
   ---------------------------------
   U_GpuObAxisMon : entity surf.AxiStreamMonAxiL
      generic map(
         TPD_G            => TPD_G,
         COMMON_CLK_G     => false,
         AXIS_CLK_FREQ_G  => DMA_CLK_FREQ_C,
         AXIS_NUM_SLOTS_G => 1,
         AXIS_CONFIG_G    => PCIE_AXIS_CONFIG_C)
      port map(
         -- AXIS Stream Interface
         axisClk          => axiClk,
         axisRst          => axiRst,
         axisMasters(0)   => mAxisMasterInt,
         axisSlaves(0)    => mAxisSlaveInt,
         -- AXI lite slave port for register access
         axilClk          => axilClk,
         axilRst          => axilRst,
         sAxilWriteMaster => monWriteMasters(1),
         sAxilWriteSlave  => monWriteSlaves(1),
         sAxilReadMaster  => monReadMasters(1),
         sAxilReadSlave   => monReadSlaves(1));

end mapping;
