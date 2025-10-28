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
         AXI_00_ACLK         : in  std_logic;
         AXI_00_ARESET_N     : in  std_logic;
         AXI_00_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_00_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_00_ARID         : in  std_logic_vector(5 downto 0);
         AXI_00_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_00_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_00_ARVALID      : in  std_logic;
         AXI_00_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_00_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_00_AWID         : in  std_logic_vector(5 downto 0);
         AXI_00_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_00_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_00_AWVALID      : in  std_logic;
         AXI_00_RREADY       : in  std_logic;
         AXI_00_BREADY       : in  std_logic;
         AXI_00_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_00_WLAST        : in  std_logic;
         AXI_00_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_00_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_00_WVALID       : in  std_logic;
         AXI_16_ACLK         : in  std_logic;
         AXI_16_ARESET_N     : in  std_logic;
         AXI_16_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_16_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_16_ARID         : in  std_logic_vector(5 downto 0);
         AXI_16_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_16_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_16_ARVALID      : in  std_logic;
         AXI_16_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_16_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_16_AWID         : in  std_logic_vector(5 downto 0);
         AXI_16_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_16_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_16_AWVALID      : in  std_logic;
         AXI_16_RREADY       : in  std_logic;
         AXI_16_BREADY       : in  std_logic;
         AXI_16_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_16_WLAST        : in  std_logic;
         AXI_16_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_16_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_16_WVALID       : in  std_logic;
         APB_0_PCLK          : in  std_logic;
         APB_0_PRESET_N      : in  std_logic;
         APB_1_PCLK          : in  std_logic;
         APB_1_PRESET_N      : in  std_logic;
         AXI_00_ARREADY      : out std_logic;
         AXI_00_AWREADY      : out std_logic;
         AXI_00_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_00_RDATA        : out std_logic_vector(255 downto 0);
         AXI_00_RID          : out std_logic_vector(5 downto 0);
         AXI_00_RLAST        : out std_logic;
         AXI_00_RRESP        : out std_logic_vector(1 downto 0);
         AXI_00_RVALID       : out std_logic;
         AXI_00_WREADY       : out std_logic;
         AXI_00_BID          : out std_logic_vector(5 downto 0);
         AXI_00_BRESP        : out std_logic_vector(1 downto 0);
         AXI_00_BVALID       : out std_logic;
         AXI_16_ARREADY      : out std_logic;
         AXI_16_AWREADY      : out std_logic;
         AXI_16_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_16_RDATA        : out std_logic_vector(255 downto 0);
         AXI_16_RID          : out std_logic_vector(5 downto 0);
         AXI_16_RLAST        : out std_logic;
         AXI_16_RRESP        : out std_logic_vector(1 downto 0);
         AXI_16_RVALID       : out std_logic;
         AXI_16_WREADY       : out std_logic;
         AXI_16_BID          : out std_logic_vector(5 downto 0);
         AXI_16_BRESP        : out std_logic_vector(1 downto 0);
         AXI_16_BVALID       : out std_logic;
         apb_complete_0      : out std_logic;
         apb_complete_1      : out std_logic;
         DRAM_0_STAT_CATTRIP : out std_logic;
         DRAM_0_STAT_TEMP    : out std_logic_vector(6 downto 0);
         DRAM_1_STAT_CATTRIP : out std_logic;
         DRAM_1_STAT_TEMP    : out std_logic_vector(6 downto 0)
         );
   end component;

   component HbmDmaBufferV2Fifo
      port (
         INTERCONNECT_ACLK    : in  std_logic;
         INTERCONNECT_ARESETN : in  std_logic;
         -- SLAVE[0]
         S00_AXI_ARESET_OUT_N : out std_logic;
         S00_AXI_ACLK         : in  std_logic;
         S00_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S00_AXI_AWADDR       : in  std_logic_vector(32 downto 0);
         S00_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S00_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S00_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S00_AXI_AWLOCK       : in  std_logic;
         S00_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S00_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S00_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S00_AXI_AWVALID      : in  std_logic;
         S00_AXI_AWREADY      : out std_logic;
         S00_AXI_WDATA        : in  std_logic_vector(511 downto 0);
         S00_AXI_WSTRB        : in  std_logic_vector(63 downto 0);
         S00_AXI_WLAST        : in  std_logic;
         S00_AXI_WVALID       : in  std_logic;
         S00_AXI_WREADY       : out std_logic;
         S00_AXI_BID          : out std_logic_vector(0 downto 0);
         S00_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S00_AXI_BVALID       : out std_logic;
         S00_AXI_BREADY       : in  std_logic;
         S00_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S00_AXI_ARADDR       : in  std_logic_vector(32 downto 0);
         S00_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S00_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S00_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S00_AXI_ARLOCK       : in  std_logic;
         S00_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S00_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S00_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S00_AXI_ARVALID      : in  std_logic;
         S00_AXI_ARREADY      : out std_logic;
         S00_AXI_RID          : out std_logic_vector(0 downto 0);
         S00_AXI_RDATA        : out std_logic_vector(511 downto 0);
         S00_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S00_AXI_RLAST        : out std_logic;
         S00_AXI_RVALID       : out std_logic;
         S00_AXI_RREADY       : in  std_logic;
         -- MASTER
         M00_AXI_ARESET_OUT_N : out std_logic;
         M00_AXI_ACLK         : in  std_logic;
         M00_AXI_AWID         : out std_logic_vector(3 downto 0);
         M00_AXI_AWADDR       : out std_logic_vector(32 downto 0);
         M00_AXI_AWLEN        : out std_logic_vector(7 downto 0);
         M00_AXI_AWSIZE       : out std_logic_vector(2 downto 0);
         M00_AXI_AWBURST      : out std_logic_vector(1 downto 0);
         M00_AXI_AWLOCK       : out std_logic;
         M00_AXI_AWCACHE      : out std_logic_vector(3 downto 0);
         M00_AXI_AWPROT       : out std_logic_vector(2 downto 0);
         M00_AXI_AWQOS        : out std_logic_vector(3 downto 0);
         M00_AXI_AWVALID      : out std_logic;
         M00_AXI_AWREADY      : in  std_logic;
         M00_AXI_WDATA        : out std_logic_vector(255 downto 0);
         M00_AXI_WSTRB        : out std_logic_vector(31 downto 0);
         M00_AXI_WLAST        : out std_logic;
         M00_AXI_WVALID       : out std_logic;
         M00_AXI_WREADY       : in  std_logic;
         M00_AXI_BID          : in  std_logic_vector(3 downto 0);
         M00_AXI_BRESP        : in  std_logic_vector(1 downto 0);
         M00_AXI_BVALID       : in  std_logic;
         M00_AXI_BREADY       : out std_logic;
         M00_AXI_ARID         : out std_logic_vector(3 downto 0);
         M00_AXI_ARADDR       : out std_logic_vector(32 downto 0);
         M00_AXI_ARLEN        : out std_logic_vector(7 downto 0);
         M00_AXI_ARSIZE       : out std_logic_vector(2 downto 0);
         M00_AXI_ARBURST      : out std_logic_vector(1 downto 0);
         M00_AXI_ARLOCK       : out std_logic;
         M00_AXI_ARCACHE      : out std_logic_vector(3 downto 0);
         M00_AXI_ARPROT       : out std_logic_vector(2 downto 0);
         M00_AXI_ARQOS        : out std_logic_vector(3 downto 0);
         M00_AXI_ARVALID      : out std_logic;
         M00_AXI_ARREADY      : in  std_logic;
         M00_AXI_RID          : in  std_logic_vector(3 downto 0);
         M00_AXI_RDATA        : in  std_logic_vector(255 downto 0);
         M00_AXI_RRESP        : in  std_logic_vector(1 downto 0);
         M00_AXI_RLAST        : in  std_logic;
         M00_AXI_RVALID       : in  std_logic;
         M00_AXI_RREADY       : out std_logic);
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

   constant AXI_BUFFER_WIDTH_C : positive := AXI_CONFIG_C.ADDR_WIDTH_C-1;  -- 8 GB HBM shared between 2 DMA lanes
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

   signal hbmWriteMasters : AxiWriteMasterArray(1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal hbmWriteSlaves  : AxiWriteSlaveArray(1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal hbmReadMasters  : AxiReadMasterArray(1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal hbmReadSlaves   : AxiReadSlaveArray(1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal ibAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal ibAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal ibAxisCtrl    : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_STREAM_CTRL_INIT_C);

   signal obAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal obAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal axilReset : sl;

   signal axiClk    : sl;
   signal axiReset  : sl;
   signal axiRstVec : slv(1 downto 0);
   signal axiRst    : slv(1 downto 0);
   signal axiRstL   : slv(1 downto 0);
   signal axiReady  : slv(1 downto 0);

   signal hbmClk        : sl;
   signal hbmReset      : sl;
   signal hbmRstVec     : slv(1 downto 0);
   signal hbmRstL       : slv(1 downto 0);
   signal hbmCatTripVec : slv(1 downto 0);

   signal apbDoneVec : slv(1 downto 0);
   signal apbDone    : sl;
   signal apbRstL    : sl;

   signal wdataParity : Slv32Array(1 downto 0) := (others => (others => '0'));

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
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 10.0,     -- 100 MHz
         CLKFBOUT_MULT_G   => 13,       -- 1.3GHz = 13 x 100 MHz
         CLKOUT0_DIVIDE_G  => 3,        -- 433MHz = 1.3GHz/3
         CLKOUT1_DIVIDE_G  => 4)        -- 325MHz = 1.3GHz/4
      port map(
         -- Clock Input
         clkIn     => userClk,
         rstIn     => axilReset,
         -- Clock Outputs
         clkOut(0) => hbmClk,
         clkOut(1) => axiClk,
         -- Reset Outputs
         rstOut(0) => hbmReset,
         rstOut(1) => axiReset);

   hbmRstVec <= (others => hbmReset);
   axiRstVec <= (others => axiReset);

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
   U_axiRstL : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 2,
         INV_RST_G => true)             -- invert reset
      port map (
         clk    => axiClk,
         rstIn  => axiRstVec,           -- active HIGH
         rstOut => axiRstL);            -- active LOW

   -- Help with timing
   U_axiRst : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 2,
         INV_RST_G => false)
      port map (
         clk    => axiClk,
         rstIn  => axiRstVec,           -- active HIGH
         rstOut => axiRst);             -- active HIGH

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
            mAxisClk    => axiClk,
            mAxisRst    => axiRst(i),
            mAxisMaster => ibAxisMasters(i),
            mAxisSlave  => ibAxisSlaves(i));

      U_ObFifo : entity surf.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            FIFO_ADDR_WIDTH_G   => 9,
            SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
         port map (
            -- Inbound AXIS Stream
            sAxisClk    => axiClk,
            sAxisRst    => axiRst(i),
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
            clk     => axiClk,
            dataIn  => apbDone,
            dataOut => axiReady(i));

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
            BURST_BYTES_G      => 512,  -- HBM is 32B AXI3, 32B x 2^16 AXI3 burst length = 512B
            RD_PEND_THRESH_G   => 8*512)  -- Same as HbmDmaBuffer.vhd
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => axiClk,
            axiRst          => axiRst(i),
            axiReady        => axiReady(i),
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

      U_HbmAxiFifo : HbmDmaBufferV2Fifo
         port map (
            INTERCONNECT_ACLK    => axiClk,
            INTERCONNECT_ARESETN => axiRstL(i),
            -- SLAVE[0]
            S00_AXI_ARESET_OUT_N => open,
            S00_AXI_ACLK         => axiClk,
            S00_AXI_AWID(0)      => '0',
            S00_AXI_AWADDR       => axiWriteMasters(i).awaddr(32 downto 0),
            S00_AXI_AWLEN        => axiWriteMasters(i).awlen,
            S00_AXI_AWSIZE       => axiWriteMasters(i).awsize,
            S00_AXI_AWBURST      => axiWriteMasters(i).awburst,
            S00_AXI_AWLOCK       => axiWriteMasters(i).awlock(0),
            S00_AXI_AWCACHE      => axiWriteMasters(i).awcache,
            S00_AXI_AWPROT       => axiWriteMasters(i).awprot,
            S00_AXI_AWQOS        => axiWriteMasters(i).awqos,
            S00_AXI_AWVALID      => axiWriteMasters(i).awvalid,
            S00_AXI_AWREADY      => axiWriteSlaves(i).awready,
            S00_AXI_WDATA        => axiWriteMasters(i).wdata(511 downto 0),
            S00_AXI_WSTRB        => axiWriteMasters(i).wstrb(63 downto 0),
            S00_AXI_WLAST        => axiWriteMasters(i).wlast,
            S00_AXI_WVALID       => axiWriteMasters(i).wvalid,
            S00_AXI_WREADY       => axiWriteSlaves(i).wready,
            S00_AXI_BID          => axiWriteSlaves(i).bid(0 downto 0),
            S00_AXI_BRESP        => axiWriteSlaves(i).bresp,
            S00_AXI_BVALID       => axiWriteSlaves(i).bvalid,
            S00_AXI_BREADY       => axiWriteMasters(i).bready,
            S00_AXI_ARID(0)      => '0',
            S00_AXI_ARADDR       => axiReadMasters(i).araddr(32 downto 0),
            S00_AXI_ARLEN        => axiReadMasters(i).arlen,
            S00_AXI_ARSIZE       => axiReadMasters(i).arsize,
            S00_AXI_ARBURST      => axiReadMasters(i).arburst,
            S00_AXI_ARLOCK       => axiReadMasters(i).arlock(0),
            S00_AXI_ARCACHE      => axiReadMasters(i).arcache,
            S00_AXI_ARPROT       => axiReadMasters(i).arprot,
            S00_AXI_ARQOS        => axiReadMasters(i).arqos,
            S00_AXI_ARVALID      => axiReadMasters(i).arvalid,
            S00_AXI_ARREADY      => axiReadSlaves(i).arready,
            S00_AXI_RID          => axiReadSlaves(i).rid(0 downto 0),
            S00_AXI_RDATA        => axiReadSlaves(i).rdata(511 downto 0),
            S00_AXI_RRESP        => axiReadSlaves(i).rresp,
            S00_AXI_RLAST        => axiReadSlaves(i).rlast,
            S00_AXI_RVALID       => axiReadSlaves(i).rvalid,
            S00_AXI_RREADY       => axiReadMasters(i).rready,
            -- MASTER
            M00_AXI_ARESET_OUT_N => open,
            M00_AXI_ACLK         => hbmClk,
            M00_AXI_AWID         => hbmWriteMasters(i).awid(3 downto 0),
            M00_AXI_AWADDR       => hbmWriteMasters(i).awaddr(32 downto 0),
            M00_AXI_AWLEN        => hbmWriteMasters(i).awlen,
            M00_AXI_AWSIZE       => hbmWriteMasters(i).awsize,
            M00_AXI_AWBURST      => hbmWriteMasters(i).awburst,
            M00_AXI_AWLOCK       => hbmWriteMasters(i).awlock(0),
            M00_AXI_AWCACHE      => hbmWriteMasters(i).awcache,
            M00_AXI_AWPROT       => hbmWriteMasters(i).awprot,
            M00_AXI_AWQOS        => hbmWriteMasters(i).awqos,
            M00_AXI_AWVALID      => hbmWriteMasters(i).awvalid,
            M00_AXI_AWREADY      => hbmWriteSlaves(i).awready,
            M00_AXI_WDATA        => hbmWriteMasters(i).wdata(255 downto 0),
            M00_AXI_WSTRB        => hbmWriteMasters(i).wstrb(31 downto 0),
            M00_AXI_WLAST        => hbmWriteMasters(i).wlast,
            M00_AXI_WVALID       => hbmWriteMasters(i).wvalid,
            M00_AXI_WREADY       => hbmWriteSlaves(i).wready,
            M00_AXI_BID          => hbmWriteSlaves(i).bid(3 downto 0),
            M00_AXI_BRESP        => hbmWriteSlaves(i).bresp,
            M00_AXI_BVALID       => hbmWriteSlaves(i).bvalid,
            M00_AXI_BREADY       => hbmWriteMasters(i).bready,
            M00_AXI_ARID         => hbmReadMasters(i).arid(3 downto 0),
            M00_AXI_ARADDR       => hbmReadMasters(i).araddr(32 downto 0),
            M00_AXI_ARLEN        => hbmReadMasters(i).arlen,
            M00_AXI_ARSIZE       => hbmReadMasters(i).arsize,
            M00_AXI_ARBURST      => hbmReadMasters(i).arburst,
            M00_AXI_ARLOCK       => hbmReadMasters(i).arlock(0),
            M00_AXI_ARCACHE      => hbmReadMasters(i).arcache,
            M00_AXI_ARPROT       => hbmReadMasters(i).arprot,
            M00_AXI_ARQOS        => hbmReadMasters(i).arqos,
            M00_AXI_ARVALID      => hbmReadMasters(i).arvalid,
            M00_AXI_ARREADY      => hbmReadSlaves(i).arready,
            M00_AXI_RID          => hbmReadSlaves(i).rid(3 downto 0),
            M00_AXI_RDATA        => hbmReadSlaves(i).rdata(255 downto 0),
            M00_AXI_RRESP        => hbmReadSlaves(i).rresp,
            M00_AXI_RLAST        => hbmReadSlaves(i).rlast,
            M00_AXI_RVALID       => hbmReadSlaves(i).rvalid,
            M00_AXI_RREADY       => hbmReadMasters(i).rready);

   end generate;

   process(hbmWriteMasters)
   begin
      for i in DMA_SIZE_G-1 downto 0 loop
         for j in 31 downto 0 loop
            wdataParity(i)(j) <= oddParity(hbmWriteMasters(i).wdata(8*j+7 downto 8*j));
         end loop;
      end loop;
   end process;

   U_HBM : HbmDmaBufferV2IpCore
      port map (
         -- Reference Clocks
         HBM_REF_CLK_0       => hbmRefClk,
         HBM_REF_CLK_1       => hbmRefClk,
         -- AXI_00 Interface
         AXI_00_ACLK         => hbmClk,
         AXI_00_ARESET_N     => hbmRstL(0),
         AXI_00_ARADDR       => hbmReadMasters(0).araddr(32 downto 0),
         AXI_00_ARBURST      => hbmReadMasters(0).arburst,
         AXI_00_ARID         => hbmReadMasters(0).arid(5 downto 0),
         AXI_00_ARLEN        => hbmReadMasters(0).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_00_ARSIZE       => hbmReadMasters(0).arsize,
         AXI_00_ARVALID      => hbmReadMasters(0).arvalid,
         AXI_00_AWADDR       => hbmWriteMasters(0).awaddr(32 downto 0),
         AXI_00_AWBURST      => hbmWriteMasters(0).awburst,
         AXI_00_AWID         => hbmWriteMasters(0).awid(5 downto 0),
         AXI_00_AWLEN        => hbmWriteMasters(0).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_00_AWSIZE       => hbmWriteMasters(0).awsize,
         AXI_00_AWVALID      => hbmWriteMasters(0).awvalid,
         AXI_00_RREADY       => hbmReadMasters(0).rready,
         AXI_00_BREADY       => hbmWriteMasters(0).bready,
         AXI_00_WDATA        => hbmWriteMasters(0).wdata(255 downto 0),
         AXI_00_WLAST        => hbmWriteMasters(0).wlast,
         AXI_00_WSTRB        => hbmWriteMasters(0).wstrb(31 downto 0),
         AXI_00_WDATA_PARITY => wdataParity(0),
         AXI_00_WVALID       => hbmWriteMasters(0).wvalid,
         AXI_00_ARREADY      => hbmReadSlaves(0).arready,
         AXI_00_AWREADY      => hbmWriteSlaves(0).awready,
         AXI_00_RDATA_PARITY => open,
         AXI_00_RDATA        => hbmReadSlaves(0).rdata(255 downto 0),
         AXI_00_RID          => open,
         AXI_00_RLAST        => hbmReadSlaves(0).rlast,
         AXI_00_RRESP        => hbmReadSlaves(0).rresp,
         AXI_00_RVALID       => hbmReadSlaves(0).rvalid,
         AXI_00_WREADY       => hbmWriteSlaves(0).wready,
         AXI_00_BID          => open,
         AXI_00_BRESP        => hbmWriteSlaves(0).bresp,
         AXI_00_BVALID       => hbmWriteSlaves(0).bvalid,
         -- AXI_16 Interface
         AXI_16_ACLK         => hbmClk,
         AXI_16_ARESET_N     => hbmRstL(1),
         AXI_16_ARADDR       => hbmReadMasters(1).araddr(32 downto 0),
         AXI_16_ARBURST      => hbmReadMasters(1).arburst,
         AXI_16_ARID         => hbmReadMasters(1).arid(5 downto 0),
         AXI_16_ARLEN        => hbmReadMasters(1).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_16_ARSIZE       => hbmReadMasters(1).arsize,
         AXI_16_ARVALID      => hbmReadMasters(1).arvalid,
         AXI_16_AWADDR       => hbmWriteMasters(1).awaddr(32 downto 0),
         AXI_16_AWBURST      => hbmWriteMasters(1).awburst,
         AXI_16_AWID         => hbmWriteMasters(1).awid(5 downto 0),
         AXI_16_AWLEN        => hbmWriteMasters(1).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_16_AWSIZE       => hbmWriteMasters(1).awsize,
         AXI_16_AWVALID      => hbmWriteMasters(1).awvalid,
         AXI_16_RREADY       => hbmReadMasters(1).rready,
         AXI_16_BREADY       => hbmWriteMasters(1).bready,
         AXI_16_WDATA        => hbmWriteMasters(1).wdata(255 downto 0),
         AXI_16_WLAST        => hbmWriteMasters(1).wlast,
         AXI_16_WSTRB        => hbmWriteMasters(1).wstrb(31 downto 0),
         AXI_16_WDATA_PARITY => wdataParity(1),
         AXI_16_WVALID       => hbmWriteMasters(1).wvalid,
         AXI_16_ARREADY      => hbmReadSlaves(1).arready,
         AXI_16_AWREADY      => hbmWriteSlaves(1).awready,
         AXI_16_RDATA_PARITY => open,
         AXI_16_RDATA        => hbmReadSlaves(1).rdata(255 downto 0),
         AXI_16_RID          => open,
         AXI_16_RLAST        => hbmReadSlaves(1).rlast,
         AXI_16_RRESP        => hbmReadSlaves(1).rresp,
         AXI_16_RVALID       => hbmReadSlaves(1).rvalid,
         AXI_16_WREADY       => hbmWriteSlaves(1).wready,
         AXI_16_BID          => open,
         AXI_16_BRESP        => hbmWriteSlaves(1).bresp,
         AXI_16_BVALID       => hbmWriteSlaves(1).bvalid,
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
