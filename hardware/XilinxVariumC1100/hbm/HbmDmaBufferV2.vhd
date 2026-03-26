-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: HBM DMA buffer - optimized for 100Gb/s per DMA lane
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library axi_pcie_core;

entity HbmDmaBufferV2 is
   generic (
      TPD_G             : time                  := 1 ns;
      DMA_SIZE_G        : positive range 1 to 2 := 2;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      AXIL_BASE_ADDR_G  : slv(31 downto 0));
   port (
      -- Card Management Solution (CMS) Interface
      cmsHbmCatTrip    : out sl;
      cmsHbmTemp       : out Slv7Array(1 downto 0);
      -- HBM Interface
      userClk          : in  sl;
      hbmRefClk        : in  sl;
      hbmCatTrip       : out sl;
      -- AXI-Lite Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Trigger Event streams (eventClk domain)
      eventClk         : in  slv(DMA_SIZE_G-1 downto 0);
      eventTrigMsgCtrl : out AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);
      -- Inbound AXIS Interface (sAxisClk domain)
      sAxisClk         : in  slv(DMA_SIZE_G-1 downto 0);
      sAxisRst         : in  slv(DMA_SIZE_G-1 downto 0);
      sAxisMasters     : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- Outbound AXIS Interface (mAxisClk domain)
      mAxisClk         : in  slv(DMA_SIZE_G-1 downto 0);
      mAxisRst         : in  slv(DMA_SIZE_G-1 downto 0);
      mAxisMasters     : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      mAxisSlaves      : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0));
end HbmDmaBufferV2;

architecture mapping of HbmDmaBufferV2 is

   component HbmDmaBufferV2IpCore
      port (
         HBM_REF_CLK_0       : in  std_logic;
         HBM_REF_CLK_1       : in  std_logic;
         AXI_07_ACLK         : in  std_logic;
         AXI_07_ARESET_N     : in  std_logic;
         AXI_07_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_07_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_07_ARID         : in  std_logic_vector(5 downto 0);
         AXI_07_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_07_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_07_ARVALID      : in  std_logic;
         AXI_07_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_07_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_07_AWID         : in  std_logic_vector(5 downto 0);
         AXI_07_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_07_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_07_AWVALID      : in  std_logic;
         AXI_07_RREADY       : in  std_logic;
         AXI_07_BREADY       : in  std_logic;
         AXI_07_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_07_WLAST        : in  std_logic;
         AXI_07_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_07_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_07_WVALID       : in  std_logic;
         AXI_08_ACLK         : in  std_logic;
         AXI_08_ARESET_N     : in  std_logic;
         AXI_08_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_08_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_08_ARID         : in  std_logic_vector(5 downto 0);
         AXI_08_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_08_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_08_ARVALID      : in  std_logic;
         AXI_08_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_08_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_08_AWID         : in  std_logic_vector(5 downto 0);
         AXI_08_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_08_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_08_AWVALID      : in  std_logic;
         AXI_08_RREADY       : in  std_logic;
         AXI_08_BREADY       : in  std_logic;
         AXI_08_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_08_WLAST        : in  std_logic;
         AXI_08_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_08_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_08_WVALID       : in  std_logic;
         AXI_23_ACLK         : in  std_logic;
         AXI_23_ARESET_N     : in  std_logic;
         AXI_23_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_23_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_23_ARID         : in  std_logic_vector(5 downto 0);
         AXI_23_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_23_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_23_ARVALID      : in  std_logic;
         AXI_23_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_23_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_23_AWID         : in  std_logic_vector(5 downto 0);
         AXI_23_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_23_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_23_AWVALID      : in  std_logic;
         AXI_23_RREADY       : in  std_logic;
         AXI_23_BREADY       : in  std_logic;
         AXI_23_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_23_WLAST        : in  std_logic;
         AXI_23_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_23_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_23_WVALID       : in  std_logic;
         AXI_24_ACLK         : in  std_logic;
         AXI_24_ARESET_N     : in  std_logic;
         AXI_24_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_24_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_24_ARID         : in  std_logic_vector(5 downto 0);
         AXI_24_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_24_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_24_ARVALID      : in  std_logic;
         AXI_24_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_24_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_24_AWID         : in  std_logic_vector(5 downto 0);
         AXI_24_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_24_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_24_AWVALID      : in  std_logic;
         AXI_24_RREADY       : in  std_logic;
         AXI_24_BREADY       : in  std_logic;
         AXI_24_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_24_WLAST        : in  std_logic;
         AXI_24_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_24_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_24_WVALID       : in  std_logic;
         APB_0_PCLK          : in  std_logic;
         APB_0_PRESET_N      : in  std_logic;
         APB_1_PCLK          : in  std_logic;
         APB_1_PRESET_N      : in  std_logic;
         AXI_07_ARREADY      : out std_logic;
         AXI_07_AWREADY      : out std_logic;
         AXI_07_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_07_RDATA        : out std_logic_vector(255 downto 0);
         AXI_07_RID          : out std_logic_vector(5 downto 0);
         AXI_07_RLAST        : out std_logic;
         AXI_07_RRESP        : out std_logic_vector(1 downto 0);
         AXI_07_RVALID       : out std_logic;
         AXI_07_WREADY       : out std_logic;
         AXI_07_BID          : out std_logic_vector(5 downto 0);
         AXI_07_BRESP        : out std_logic_vector(1 downto 0);
         AXI_07_BVALID       : out std_logic;
         AXI_08_ARREADY      : out std_logic;
         AXI_08_AWREADY      : out std_logic;
         AXI_08_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_08_RDATA        : out std_logic_vector(255 downto 0);
         AXI_08_RID          : out std_logic_vector(5 downto 0);
         AXI_08_RLAST        : out std_logic;
         AXI_08_RRESP        : out std_logic_vector(1 downto 0);
         AXI_08_RVALID       : out std_logic;
         AXI_08_WREADY       : out std_logic;
         AXI_08_BID          : out std_logic_vector(5 downto 0);
         AXI_08_BRESP        : out std_logic_vector(1 downto 0);
         AXI_08_BVALID       : out std_logic;
         AXI_23_ARREADY      : out std_logic;
         AXI_23_AWREADY      : out std_logic;
         AXI_23_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_23_RDATA        : out std_logic_vector(255 downto 0);
         AXI_23_RID          : out std_logic_vector(5 downto 0);
         AXI_23_RLAST        : out std_logic;
         AXI_23_RRESP        : out std_logic_vector(1 downto 0);
         AXI_23_RVALID       : out std_logic;
         AXI_23_WREADY       : out std_logic;
         AXI_23_BID          : out std_logic_vector(5 downto 0);
         AXI_23_BRESP        : out std_logic_vector(1 downto 0);
         AXI_23_BVALID       : out std_logic;
         AXI_24_ARREADY      : out std_logic;
         AXI_24_AWREADY      : out std_logic;
         AXI_24_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_24_RDATA        : out std_logic_vector(255 downto 0);
         AXI_24_RID          : out std_logic_vector(5 downto 0);
         AXI_24_RLAST        : out std_logic;
         AXI_24_RRESP        : out std_logic_vector(1 downto 0);
         AXI_24_RVALID       : out std_logic;
         AXI_24_WREADY       : out std_logic;
         AXI_24_BID          : out std_logic_vector(5 downto 0);
         AXI_24_BRESP        : out std_logic_vector(1 downto 0);
         AXI_24_BVALID       : out std_logic;
         apb_complete_0      : out std_logic;
         apb_complete_1      : out std_logic;
         DRAM_0_STAT_CATTRIP : out std_logic;
         DRAM_0_STAT_TEMP    : out std_logic_vector(6 downto 0);
         DRAM_1_STAT_CATTRIP : out std_logic;
         DRAM_1_STAT_TEMP    : out std_logic_vector(6 downto 0)
         );
   end component;

   constant AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => (512/8),         -- 512-bit interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 3,
      TKEEP_MODE_C  => TKEEP_COUNT_C,  -- AXI DMA V2 uses TKEEP_COUNT_C to help meet timing
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   constant AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 33,               -- 8GB HBM
      DATA_BYTES_C => AXIS_CONFIG_C.TDATA_BYTES_C,  -- Matches the AXIS stream because you ***CANNOT*** resize an interleaved AXI stream
      ID_BITS_C    => 6,                -- Up to 64 IDS
      LEN_BITS_C   => 4);               -- 4-bit awlen/arlen interface

   constant AXI_BUFFER_WIDTH_C : positive := AXI_CONFIG_C.ADDR_WIDTH_C-2;  -- 8 GB HBM shared between 4 HBM AXI interfaces
   constant AXI_BASE_ADDR_C : Slv64Array(1 downto 0) := (
      0 => x"0000_0000_0000_0000",
      1 => x"0000_0001_0000_0000");     -- 4GB partitions

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(DMA_SIZE_G-1 downto 0) := genAxiLiteConfig(DMA_SIZE_G, AXIL_BASE_ADDR_G, 12, 8);

   signal axilWriteMasters : AxiLiteWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal axiWriteMasters : AxiWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal axiReadMasters  : AxiReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal axiReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal hbmWriteMasters : AxiWriteMasterArray(3 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal hbmWriteSlaves  : AxiWriteSlaveArray(3 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal hbmReadMasters  : AxiReadMasterArray(3 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal hbmReadSlaves   : AxiReadSlaveArray(3 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal ibAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal ibAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal ibAxisCtrl    : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_STREAM_CTRL_INIT_C);

   signal obAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal obAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal axilReset : sl;

   signal hbmClk        : sl;
   signal hbmReset      : sl;
   signal hbmRstVec     : slv(1 downto 0);
   signal hbmRstL       : slv(1 downto 0);
   signal hbmRst        : slv(1 downto 0);
   signal hbmCatTripVec : slv(1 downto 0);
   signal hbmReady      : slv(1 downto 0);

   signal apbDoneVec : slv(1 downto 0);
   signal apbDone    : sl;
   signal apbRstL    : sl;

begin

   -- Help with timing
   U_axilReset : entity surf.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => false)
      port map (
         clk    => axilClk,
         rstIn  => axilRst,
         rstOut => axilReset);

   -- Generate the HBM and AXI clocks/resets
   U_hbmClk : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         CLKIN_PERIOD_G     => 10.0,    -- 100MHz
         CLKFBOUT_MULT_F_G  => 13.5,    -- 1.35GHz = 13.5 x 100MHz
         CLKOUT0_DIVIDE_F_G => 4.5)     -- 300MHz = 1.35GHz/4.5
      port map(
         -- Clock Input
         clkIn     => userClk,
         rstIn     => axilReset,
         -- Clock Outputs
         clkOut(0) => hbmClk,
         -- Reset Outputs
         rstOut(0) => hbmReset);

   hbmRstVec <= (others => hbmReset);

   -- Help with timing
   U_hbmRstL : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 2,
         INV_RST_G => true)             -- invert reset
      port map (
         clk    => hbmClk,
         rstIn  => hbmRstVec,           -- active HIGH
         rstOut => hbmRstL);            -- active LOW

   -- Help with timing
   U_hbmRst : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 2,
         INV_RST_G => false)
      port map (
         clk    => hbmClk,
         rstIn  => hbmRstVec,           -- active HIGH
         rstOut => hbmRst);             -- active HIGH

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => DMA_SIZE_G,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilReset,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   GEN_FIFO : for i in DMA_SIZE_G-1 downto 0 generate

      U_pause : entity surf.Synchronizer
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => eventClk(i),
            dataIn  => ibAxisCtrl(i).pause,
            dataOut => eventTrigMsgCtrl(i).pause);

      U_IbFifo : entity surf.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            FIFO_ADDR_WIDTH_G   => 9,
            VALID_BURST_MODE_G  => true,
            VALID_THOLD_G       => (512/64),  -- 512B bursting
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => AXIS_CONFIG_C)
         port map (
            -- Inbound AXIS Stream
            sAxisClk    => sAxisClk(i),
            sAxisRst    => sAxisRst(i),
            sAxisMaster => sAxisMasters(i),
            sAxisSlave  => sAxisSlaves(i),
            -- Outbound AXIS Stream
            mAxisClk    => hbmClk,
            mAxisRst    => hbmRst(i),
            mAxisMaster => ibAxisMasters(i),
            mAxisSlave  => ibAxisSlaves(i));

      U_ObFifo : entity surf.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            FIFO_ADDR_WIDTH_G   => 9,
            VALID_BURST_MODE_G  => true,
            VALID_THOLD_G       => (4096/64),  -- 4kB bursting
            SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
         port map (
            -- Inbound AXIS Stream
            sAxisClk    => hbmClk,
            sAxisRst    => hbmRst(i),
            sAxisMaster => obAxisMasters(i),
            sAxisSlave  => obAxisSlaves(i),
            -- Outbound AXIS Stream
            mAxisClk    => mAxisClk(i),
            mAxisRst    => mAxisRst(i),
            mAxisMaster => mAxisMasters(i),
            mAxisSlave  => mAxisSlaves(i));

      U_axiReady : entity surf.Synchronizer
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => hbmClk,
            dataIn  => apbDone,
            dataOut => hbmReady(i));

      U_AxiFifo : entity surf.AxiStreamDmaV2Fifo
         generic map (
            TPD_G              => TPD_G,
            REVERSE_INDEX_G    => true,  -- true if using a reserve bit ordering of indexes (helpful if load balancing on HBM memory)
            -- FIFO Configuration
            BUFF_FRAME_WIDTH_G => AXI_BUFFER_WIDTH_C-12,  -- Optimized to fix into 1 URAM (12-bit address) for free list
            AXI_BUFFER_WIDTH_G => AXI_BUFFER_WIDTH_C,
            SYNTH_MODE_G       => "xpm",
            MEMORY_TYPE_G      => "ultra",
            -- AXI Stream Configurations
            AXIS_CONFIG_G      => AXIS_CONFIG_C,
            -- AXI4 Configurations
            AXI_BASE_ADDR_G    => AXI_BASE_ADDR_C(i),
            AXI_CONFIG_G       => AXI_CONFIG_C,
--          BURST_BYTES_G      => 512,  -- HBM is 32B AXI3, 32B x 2^16 AXI3 burst length = 512B
            BURST_BYTES_G      => 1024,  -- AXI is 64B AXI3, 64B x 2^16 AXI3 burst length = 1024B
--          RD_PEND_THRESH_G   => 8*512)  -- Same as HbmDmaBuffer.vhd
            RD_PEND_THRESH_G   => 8*1024)  -- Same as HbmDmaBuffer.vhd
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => hbmClk,
            axiRst          => hbmRst(i),
            axiReady        => hbmReady(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i),
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            -- AXI Stream Interface (axiClk domain)
            sAxisMaster     => ibAxisMasters(i),
            sAxisSlave      => ibAxisSlaves(i),
            sAxisCtrl       => ibAxisCtrl(i),
            mAxisMaster     => obAxisMasters(i),
            mAxisSlave      => obAxisSlaves(i),
            -- Optional: AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilReset,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_AxiSplit : entity axi_pcie_core.HbmDmaBufferV2AxiSplit
         generic map (
            TPD_G      => TPD_G,
            CH_INDEX_G => i)
         port map (
            -- AXI-Lite Interface (axilClk domain)
            clk             => hbmClk,
            rst             => hbmRst(i),
            -- DMA 512b AXI Interface
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i),
            -- HBM 256b AXI Interface
            hbmWriteMasters => hbmWriteMasters(2*i+1 downto 2*i),
            hbmWriteSlaves  => hbmWriteSlaves(2*i+1 downto 2*i),
            hbmReadMasters  => hbmReadMasters(2*i+1 downto 2*i),
            hbmReadSlaves   => hbmReadSlaves(2*i+1 downto 2*i));

   end generate;

   U_HBM : HbmDmaBufferV2IpCore
      port map (
         -- Reference Clocks
         HBM_REF_CLK_0       => hbmRefClk,
         HBM_REF_CLK_1       => hbmRefClk,
         -- AXI_07 Interface
         AXI_07_ACLK         => hbmClk,
         AXI_07_ARESET_N     => hbmRstL(0),
         AXI_07_ARADDR       => hbmReadMasters(0).araddr(32 downto 0),
         AXI_07_ARBURST      => hbmReadMasters(0).arburst,
         AXI_07_ARID         => hbmReadMasters(0).arid(5 downto 0),
         AXI_07_ARLEN        => hbmReadMasters(0).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_07_ARSIZE       => hbmReadMasters(0).arsize,
         AXI_07_ARVALID      => hbmReadMasters(0).arvalid,
         AXI_07_AWADDR       => hbmWriteMasters(0).awaddr(32 downto 0),
         AXI_07_AWBURST      => hbmWriteMasters(0).awburst,
         AXI_07_AWID         => hbmWriteMasters(0).awid(5 downto 0),
         AXI_07_AWLEN        => hbmWriteMasters(0).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_07_AWSIZE       => hbmWriteMasters(0).awsize,
         AXI_07_AWVALID      => hbmWriteMasters(0).awvalid,
         AXI_07_RREADY       => hbmReadMasters(0).rready,
         AXI_07_BREADY       => hbmWriteMasters(0).bready,
         AXI_07_WDATA        => hbmWriteMasters(0).wdata(255 downto 0),
         AXI_07_WLAST        => hbmWriteMasters(0).wlast,
         AXI_07_WSTRB        => hbmWriteMasters(0).wstrb(31 downto 0),
         AXI_07_WDATA_PARITY => (others => '0'),
         AXI_07_WVALID       => hbmWriteMasters(0).wvalid,
         AXI_07_ARREADY      => hbmReadSlaves(0).arready,
         AXI_07_AWREADY      => hbmWriteSlaves(0).awready,
         AXI_07_RDATA_PARITY => open,
         AXI_07_RDATA        => hbmReadSlaves(0).rdata(255 downto 0),
         AXI_07_RID          => open,
         AXI_07_RLAST        => hbmReadSlaves(0).rlast,
         AXI_07_RRESP        => hbmReadSlaves(0).rresp,
         AXI_07_RVALID       => hbmReadSlaves(0).rvalid,
         AXI_07_WREADY       => hbmWriteSlaves(0).wready,
         AXI_07_BID          => open,
         AXI_07_BRESP        => hbmWriteSlaves(0).bresp,
         AXI_07_BVALID       => hbmWriteSlaves(0).bvalid,
         -- AXI_08 Interface
         AXI_08_ACLK         => hbmClk,
         AXI_08_ARESET_N     => hbmRstL(0),
         AXI_08_ARADDR       => hbmReadMasters(1).araddr(32 downto 0),
         AXI_08_ARBURST      => hbmReadMasters(1).arburst,
         AXI_08_ARID         => hbmReadMasters(1).arid(5 downto 0),
         AXI_08_ARLEN        => hbmReadMasters(1).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_08_ARSIZE       => hbmReadMasters(1).arsize,
         AXI_08_ARVALID      => hbmReadMasters(1).arvalid,
         AXI_08_AWADDR       => hbmWriteMasters(1).awaddr(32 downto 0),
         AXI_08_AWBURST      => hbmWriteMasters(1).awburst,
         AXI_08_AWID         => hbmWriteMasters(1).awid(5 downto 0),
         AXI_08_AWLEN        => hbmWriteMasters(1).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_08_AWSIZE       => hbmWriteMasters(1).awsize,
         AXI_08_AWVALID      => hbmWriteMasters(1).awvalid,
         AXI_08_RREADY       => hbmReadMasters(1).rready,
         AXI_08_BREADY       => hbmWriteMasters(1).bready,
         AXI_08_WDATA        => hbmWriteMasters(1).wdata(255 downto 0),
         AXI_08_WLAST        => hbmWriteMasters(1).wlast,
         AXI_08_WSTRB        => hbmWriteMasters(1).wstrb(31 downto 0),
         AXI_08_WDATA_PARITY => (others => '0'),
         AXI_08_WVALID       => hbmWriteMasters(1).wvalid,
         AXI_08_ARREADY      => hbmReadSlaves(1).arready,
         AXI_08_AWREADY      => hbmWriteSlaves(1).awready,
         AXI_08_RDATA_PARITY => open,
         AXI_08_RDATA        => hbmReadSlaves(1).rdata(255 downto 0),
         AXI_08_RID          => open,
         AXI_08_RLAST        => hbmReadSlaves(1).rlast,
         AXI_08_RRESP        => hbmReadSlaves(1).rresp,
         AXI_08_RVALID       => hbmReadSlaves(1).rvalid,
         AXI_08_WREADY       => hbmWriteSlaves(1).wready,
         AXI_08_BID          => open,
         AXI_08_BRESP        => hbmWriteSlaves(1).bresp,
         AXI_08_BVALID       => hbmWriteSlaves(1).bvalid,
         -- AXI_23 Interface
         AXI_23_ACLK         => hbmClk,
         AXI_23_ARESET_N     => hbmRstL(1),
         AXI_23_ARADDR       => hbmReadMasters(2).araddr(32 downto 0),
         AXI_23_ARBURST      => hbmReadMasters(2).arburst,
         AXI_23_ARID         => hbmReadMasters(2).arid(5 downto 0),
         AXI_23_ARLEN        => hbmReadMasters(2).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_23_ARSIZE       => hbmReadMasters(2).arsize,
         AXI_23_ARVALID      => hbmReadMasters(2).arvalid,
         AXI_23_AWADDR       => hbmWriteMasters(2).awaddr(32 downto 0),
         AXI_23_AWBURST      => hbmWriteMasters(2).awburst,
         AXI_23_AWID         => hbmWriteMasters(2).awid(5 downto 0),
         AXI_23_AWLEN        => hbmWriteMasters(2).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_23_AWSIZE       => hbmWriteMasters(2).awsize,
         AXI_23_AWVALID      => hbmWriteMasters(2).awvalid,
         AXI_23_RREADY       => hbmReadMasters(2).rready,
         AXI_23_BREADY       => hbmWriteMasters(2).bready,
         AXI_23_WDATA        => hbmWriteMasters(2).wdata(255 downto 0),
         AXI_23_WLAST        => hbmWriteMasters(2).wlast,
         AXI_23_WSTRB        => hbmWriteMasters(2).wstrb(31 downto 0),
         AXI_23_WDATA_PARITY => (others => '0'),
         AXI_23_WVALID       => hbmWriteMasters(2).wvalid,
         AXI_23_ARREADY      => hbmReadSlaves(2).arready,
         AXI_23_AWREADY      => hbmWriteSlaves(2).awready,
         AXI_23_RDATA_PARITY => open,
         AXI_23_RDATA        => hbmReadSlaves(2).rdata(255 downto 0),
         AXI_23_RID          => open,
         AXI_23_RLAST        => hbmReadSlaves(2).rlast,
         AXI_23_RRESP        => hbmReadSlaves(2).rresp,
         AXI_23_RVALID       => hbmReadSlaves(2).rvalid,
         AXI_23_WREADY       => hbmWriteSlaves(2).wready,
         AXI_23_BID          => open,
         AXI_23_BRESP        => hbmWriteSlaves(2).bresp,
         AXI_23_BVALID       => hbmWriteSlaves(2).bvalid,
         -- AXI_24 Interface
         AXI_24_ACLK         => hbmClk,
         AXI_24_ARESET_N     => hbmRstL(1),
         AXI_24_ARADDR       => hbmReadMasters(3).araddr(32 downto 0),
         AXI_24_ARBURST      => hbmReadMasters(3).arburst,
         AXI_24_ARID         => hbmReadMasters(3).arid(5 downto 0),
         AXI_24_ARLEN        => hbmReadMasters(3).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_24_ARSIZE       => hbmReadMasters(3).arsize,
         AXI_24_ARVALID      => hbmReadMasters(3).arvalid,
         AXI_24_AWADDR       => hbmWriteMasters(3).awaddr(32 downto 0),
         AXI_24_AWBURST      => hbmWriteMasters(3).awburst,
         AXI_24_AWID         => hbmWriteMasters(3).awid(5 downto 0),
         AXI_24_AWLEN        => hbmWriteMasters(3).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_24_AWSIZE       => hbmWriteMasters(3).awsize,
         AXI_24_AWVALID      => hbmWriteMasters(3).awvalid,
         AXI_24_RREADY       => hbmReadMasters(3).rready,
         AXI_24_BREADY       => hbmWriteMasters(3).bready,
         AXI_24_WDATA        => hbmWriteMasters(3).wdata(255 downto 0),
         AXI_24_WLAST        => hbmWriteMasters(3).wlast,
         AXI_24_WSTRB        => hbmWriteMasters(3).wstrb(31 downto 0),
         AXI_24_WDATA_PARITY => (others => '0'),
         AXI_24_WVALID       => hbmWriteMasters(3).wvalid,
         AXI_24_ARREADY      => hbmReadSlaves(3).arready,
         AXI_24_AWREADY      => hbmWriteSlaves(3).awready,
         AXI_24_RDATA_PARITY => open,
         AXI_24_RDATA        => hbmReadSlaves(3).rdata(255 downto 0),
         AXI_24_RID          => open,
         AXI_24_RLAST        => hbmReadSlaves(3).rlast,
         AXI_24_RRESP        => hbmReadSlaves(3).rresp,
         AXI_24_RVALID       => hbmReadSlaves(3).rvalid,
         AXI_24_WREADY       => hbmWriteSlaves(3).wready,
         AXI_24_BID          => open,
         AXI_24_BRESP        => hbmWriteSlaves(3).bresp,
         AXI_24_BVALID       => hbmWriteSlaves(3).bvalid,
         -- APB Interface
         APB_0_PCLK          => hbmRefClk,
         APB_1_PCLK          => hbmRefClk,
         APB_0_PRESET_N      => apbRstL,
         APB_1_PRESET_N      => apbRstL,
         apb_complete_0      => apbDoneVec(0),
         apb_complete_1      => apbDoneVec(1),
         DRAM_0_STAT_CATTRIP => hbmCatTripVec(0),
         DRAM_1_STAT_CATTRIP => hbmCatTripVec(1),
         DRAM_0_STAT_TEMP    => cmsHbmTemp(0),
         DRAM_1_STAT_TEMP    => cmsHbmTemp(1));

   cmsHbmCatTrip <= uOr(hbmCatTripVec);
   hbmCatTrip    <= uOr(hbmCatTripVec);
   apbDone       <= uAnd(apbDoneVec);

   U_apbRstL : entity surf.RstSync
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0')         -- active LOW
      port map (
         clk      => hbmRefClk,
         asyncRst => hbmReset,
         syncRst  => apbRstL);

end mapping;
