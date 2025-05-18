-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: HBM DMA buffer
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

entity HbmDmaBuffer is
   generic (
      TPD_G             : time                  := 1 ns;
      DMA_SIZE_G        : positive range 1 to 8 := 8;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      RD_PEND_THRESH_G  : positive              := 4096;  -- In units of bytes
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
      -- AXI Stream Interface (axisClk domain)
      axisClk          : in  slv(DMA_SIZE_G-1 downto 0);
      axisRst          : in  slv(DMA_SIZE_G-1 downto 0);
      sAxisMasters     : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      mAxisMasters     : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      mAxisSlaves      : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0));
end HbmDmaBuffer;

architecture mapping of HbmDmaBuffer is

   component HbmDmaBufferIpCore
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
         AXI_04_ACLK         : in  std_logic;
         AXI_04_ARESET_N     : in  std_logic;
         AXI_04_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_04_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_04_ARID         : in  std_logic_vector(5 downto 0);
         AXI_04_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_04_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_04_ARVALID      : in  std_logic;
         AXI_04_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_04_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_04_AWID         : in  std_logic_vector(5 downto 0);
         AXI_04_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_04_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_04_AWVALID      : in  std_logic;
         AXI_04_RREADY       : in  std_logic;
         AXI_04_BREADY       : in  std_logic;
         AXI_04_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_04_WLAST        : in  std_logic;
         AXI_04_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_04_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_04_WVALID       : in  std_logic;
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
         AXI_12_ACLK         : in  std_logic;
         AXI_12_ARESET_N     : in  std_logic;
         AXI_12_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_12_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_12_ARID         : in  std_logic_vector(5 downto 0);
         AXI_12_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_12_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_12_ARVALID      : in  std_logic;
         AXI_12_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_12_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_12_AWID         : in  std_logic_vector(5 downto 0);
         AXI_12_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_12_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_12_AWVALID      : in  std_logic;
         AXI_12_RREADY       : in  std_logic;
         AXI_12_BREADY       : in  std_logic;
         AXI_12_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_12_WLAST        : in  std_logic;
         AXI_12_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_12_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_12_WVALID       : in  std_logic;
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
         AXI_20_ACLK         : in  std_logic;
         AXI_20_ARESET_N     : in  std_logic;
         AXI_20_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_20_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_20_ARID         : in  std_logic_vector(5 downto 0);
         AXI_20_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_20_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_20_ARVALID      : in  std_logic;
         AXI_20_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_20_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_20_AWID         : in  std_logic_vector(5 downto 0);
         AXI_20_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_20_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_20_AWVALID      : in  std_logic;
         AXI_20_RREADY       : in  std_logic;
         AXI_20_BREADY       : in  std_logic;
         AXI_20_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_20_WLAST        : in  std_logic;
         AXI_20_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_20_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_20_WVALID       : in  std_logic;
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
         AXI_28_ACLK         : in  std_logic;
         AXI_28_ARESET_N     : in  std_logic;
         AXI_28_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_28_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_28_ARID         : in  std_logic_vector(5 downto 0);
         AXI_28_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_28_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_28_ARVALID      : in  std_logic;
         AXI_28_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_28_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_28_AWID         : in  std_logic_vector(5 downto 0);
         AXI_28_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_28_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_28_AWVALID      : in  std_logic;
         AXI_28_RREADY       : in  std_logic;
         AXI_28_BREADY       : in  std_logic;
         AXI_28_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_28_WLAST        : in  std_logic;
         AXI_28_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_28_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_28_WVALID       : in  std_logic;
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
         AXI_04_ARREADY      : out std_logic;
         AXI_04_AWREADY      : out std_logic;
         AXI_04_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_04_RDATA        : out std_logic_vector(255 downto 0);
         AXI_04_RID          : out std_logic_vector(5 downto 0);
         AXI_04_RLAST        : out std_logic;
         AXI_04_RRESP        : out std_logic_vector(1 downto 0);
         AXI_04_RVALID       : out std_logic;
         AXI_04_WREADY       : out std_logic;
         AXI_04_BID          : out std_logic_vector(5 downto 0);
         AXI_04_BRESP        : out std_logic_vector(1 downto 0);
         AXI_04_BVALID       : out std_logic;
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
         AXI_12_ARREADY      : out std_logic;
         AXI_12_AWREADY      : out std_logic;
         AXI_12_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_12_RDATA        : out std_logic_vector(255 downto 0);
         AXI_12_RID          : out std_logic_vector(5 downto 0);
         AXI_12_RLAST        : out std_logic;
         AXI_12_RRESP        : out std_logic_vector(1 downto 0);
         AXI_12_RVALID       : out std_logic;
         AXI_12_WREADY       : out std_logic;
         AXI_12_BID          : out std_logic_vector(5 downto 0);
         AXI_12_BRESP        : out std_logic_vector(1 downto 0);
         AXI_12_BVALID       : out std_logic;
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
         AXI_20_ARREADY      : out std_logic;
         AXI_20_AWREADY      : out std_logic;
         AXI_20_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_20_RDATA        : out std_logic_vector(255 downto 0);
         AXI_20_RID          : out std_logic_vector(5 downto 0);
         AXI_20_RLAST        : out std_logic;
         AXI_20_RRESP        : out std_logic_vector(1 downto 0);
         AXI_20_RVALID       : out std_logic;
         AXI_20_WREADY       : out std_logic;
         AXI_20_BID          : out std_logic_vector(5 downto 0);
         AXI_20_BRESP        : out std_logic_vector(1 downto 0);
         AXI_20_BVALID       : out std_logic;
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
         AXI_28_ARREADY      : out std_logic;
         AXI_28_AWREADY      : out std_logic;
         AXI_28_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_28_RDATA        : out std_logic_vector(255 downto 0);
         AXI_28_RID          : out std_logic_vector(5 downto 0);
         AXI_28_RLAST        : out std_logic;
         AXI_28_RRESP        : out std_logic_vector(1 downto 0);
         AXI_28_RVALID       : out std_logic;
         AXI_28_WREADY       : out std_logic;
         AXI_28_BID          : out std_logic_vector(5 downto 0);
         AXI_28_BRESP        : out std_logic_vector(1 downto 0);
         AXI_28_BVALID       : out std_logic;
         apb_complete_0      : out std_logic;
         apb_complete_1      : out std_logic;
         DRAM_0_STAT_CATTRIP : out std_logic;
         DRAM_0_STAT_TEMP    : out std_logic_vector(6 downto 0);
         DRAM_1_STAT_CATTRIP : out std_logic;
         DRAM_1_STAT_TEMP    : out std_logic_vector(6 downto 0)
         );
   end component;

   component HbmAxiFifo
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

   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 64,  -- Match 64-bit address for axi_pcie_core.AxiPcieResizer
      DATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,  -- Matches the AXIS stream because you ***CANNOT*** resize an interleaved AXI stream
      ID_BITS_C    => 6,                -- Up to 64 IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface

   constant RESIZE_DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 64,  -- Match 64-bit address for axi_pcie_core.AxiPcieResizer
      DATA_BYTES_C => 64,               -- 512-bit data interface
      ID_BITS_C    => 6,                -- Up to 64 IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface

   -- HBM MEM AXI Configuration
   constant HBM_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 33,               -- 8GB HBM
      DATA_BYTES_C => 32,               -- 256-bit data interface
      ID_BITS_C    => 6,                -- Up to 64 IDS
      LEN_BITS_C   => 4);               -- 4-bit awlen/arlen interface

   constant AXI_BUFFER_WIDTH_C : positive := HBM_AXI_CONFIG_C.ADDR_WIDTH_C-3;  -- 8 GB HBM shared between 8 DMA lanes
   constant AXI_BASE_ADDR_C : Slv64Array(7 downto 0) := (
      0 => x"0000_0000_0000_0000",
      1 => x"0000_0000_4000_0000",      -- 1GB partitions
      2 => x"0000_0000_8000_0000",
      3 => x"0000_0000_C000_0000",
      4 => x"0000_0001_0000_0000",
      5 => x"0000_0001_4000_0000",
      6 => x"0000_0001_8000_0000",
      7 => x"0000_0001_C000_0000");

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(DMA_SIZE_G-1 downto 0) := genAxiLiteConfig(DMA_SIZE_G, AXIL_BASE_ADDR_G, 12, 8);

   signal axilWriteMasters : AxiLiteWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal axiWriteMasters : AxiWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal axiReadMasters  : AxiReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal axiReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal fifoWriteMasters : AxiWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal fifoWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal fifoReadMasters  : AxiReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal fifoReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal hbmWriteMasters : AxiWriteMasterArray(7 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal hbmWriteSlaves  : AxiWriteSlaveArray(7 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal hbmReadMasters  : AxiReadMasterArray(7 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal hbmReadSlaves   : AxiReadSlaveArray(7 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal sAxisCtrl : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);

   signal axilReset : sl;
   signal axisRstL  : slv(DMA_SIZE_G-1 downto 0);

   signal hbmClk        : sl;
   signal hbmRst        : sl;
   signal hbmRstVec     : slv(7 downto 0);
   signal hbmRstL       : slv(7 downto 0);
   signal hbmCatTripVec : slv(1 downto 0);

   signal apbDoneVec : slv(1 downto 0);
   signal apbDone    : sl;
   signal apbRstL    : sl;

   signal axiReady    : slv(DMA_SIZE_G-1 downto 0);
   signal wdataParity : Slv32Array(7 downto 0) := (others => (others => '0'));

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

   U_hbmClk : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 1,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 10.0,     -- 100 MHz
         CLKFBOUT_MULT_G   => 12,       -- 1.2GHz = 12 x 100 MHz
         CLKOUT0_DIVIDE_G  => 3)        -- 400MHz = 1.2GHz/3
      port map(
         -- Clock Input
         clkIn     => userClk,
         rstIn     => axilReset,
         -- Clock Outputs
         clkOut(0) => hbmClk,
         -- Reset Outputs
         rstOut(0) => hbmRst);

   -- Help with timing
   hbmRstVec <= (others => hbmRst);
   U_hbmRstL : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 8,
         INV_RST_G => true)             -- invert reset
      port map (
         clk    => hbmClk,
         rstIn  => hbmRstVec,           -- active HIGH
         rstOut => hbmRstL);            -- active LOW

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
            dataIn  => sAxisCtrl(i).pause,
            dataOut => eventTrigMsgCtrl(i).pause);

      U_axisRstL : entity surf.RstPipeline
         generic map (
            TPD_G     => TPD_G,
            INV_RST_G => true)          -- invert reset
         port map (
            clk    => axisClk(i),
            rstIn  => axisRst(i),       -- active HIGH
            rstOut => axisRstL(i));     -- active LOW

      U_axiReady : entity surf.Synchronizer
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => axisClk(i),
            dataIn  => apbDone,
            dataOut => axiReady(i));

      U_AxiFifo : entity surf.AxiStreamDmaV2Fifo
         generic map (
            TPD_G              => TPD_G,
            -- FIFO Configuration
            BUFF_FRAME_WIDTH_G => AXI_BUFFER_WIDTH_C-12,  -- Optimized to fix into 1 URAM (12-bit address) for free list
            AXI_BUFFER_WIDTH_G => AXI_BUFFER_WIDTH_C,
            SYNTH_MODE_G       => "xpm",
            MEMORY_TYPE_G      => "ultra",
            -- AXI Stream Configurations
            AXIS_CONFIG_G      => DMA_AXIS_CONFIG_G,
            -- AXI4 Configurations
            AXI_BASE_ADDR_G    => AXI_BASE_ADDR_C(i),
            AXI_CONFIG_G       => DMA_AXI_CONFIG_C,
            BURST_BYTES_G      => 512,  -- HBM is 32B AXI3, 32B x 2^16 AXI3 burst length = 512B
            RD_PEND_THRESH_G   => RD_PEND_THRESH_G)
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => axisClk(i),
            axiRst          => axisRst(i),
            axiReady        => axiReady(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i),
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            -- AXI Stream Interface (axiClk domain)
            sAxisMaster     => sAxisMasters(i),
            sAxisSlave      => sAxisSlaves(i),
            sAxisCtrl       => sAxisCtrl(i),
            mAxisMaster     => mAxisMasters(i),
            mAxisSlave      => mAxisSlaves(i),
            -- Optional: AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilReset,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_Resizer : entity axi_pcie_core.AxiPcieResizer
         generic map(
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            AXI_PCIE_CONFIG_G => RESIZE_DMA_AXI_CONFIG_C)
         port map(
            -- Clock and reset
            axiClk          => axisClk(i),
            axiRst          => axisRst(i),
            -- Slave Port
            sAxiReadMaster  => axiReadMasters(i),
            sAxiReadSlave   => axiReadSlaves(i),
            sAxiWriteMaster => axiWriteMasters(i),
            sAxiWriteSlave  => axiWriteSlaves(i),
            -- Master Port
            mAxiReadMaster  => fifoReadMasters(i),
            mAxiReadSlave   => fifoReadSlaves(i),
            mAxiWriteMaster => fifoWriteMasters(i),
            mAxiWriteSlave  => fifoWriteSlaves(i));

      U_HbmAxiFifo : HbmAxiFifo
         port map (
            INTERCONNECT_ACLK    => axisClk(i),
            INTERCONNECT_ARESETN => axisRstL(i),
            -- SLAVE[0]
            S00_AXI_ARESET_OUT_N => open,
            S00_AXI_ACLK         => axisClk(i),
            S00_AXI_AWID(0)      => '0',
            S00_AXI_AWADDR       => fifoWriteMasters(i).awaddr(32 downto 0),
            S00_AXI_AWLEN        => fifoWriteMasters(i).awlen,
            S00_AXI_AWSIZE       => fifoWriteMasters(i).awsize,
            S00_AXI_AWBURST      => fifoWriteMasters(i).awburst,
            S00_AXI_AWLOCK       => fifoWriteMasters(i).awlock(0),
            S00_AXI_AWCACHE      => fifoWriteMasters(i).awcache,
            S00_AXI_AWPROT       => fifoWriteMasters(i).awprot,
            S00_AXI_AWQOS        => fifoWriteMasters(i).awqos,
            S00_AXI_AWVALID      => fifoWriteMasters(i).awvalid,
            S00_AXI_AWREADY      => fifoWriteSlaves(i).awready,
            S00_AXI_WDATA        => fifoWriteMasters(i).wdata(511 downto 0),
            S00_AXI_WSTRB        => fifoWriteMasters(i).wstrb(63 downto 0),
            S00_AXI_WLAST        => fifoWriteMasters(i).wlast,
            S00_AXI_WVALID       => fifoWriteMasters(i).wvalid,
            S00_AXI_WREADY       => fifoWriteSlaves(i).wready,
            S00_AXI_BID          => fifoWriteSlaves(i).bid(0 downto 0),
            S00_AXI_BRESP        => fifoWriteSlaves(i).bresp,
            S00_AXI_BVALID       => fifoWriteSlaves(i).bvalid,
            S00_AXI_BREADY       => fifoWriteMasters(i).bready,
            S00_AXI_ARID(0)      => '0',
            S00_AXI_ARADDR       => fifoReadMasters(i).araddr(32 downto 0),
            S00_AXI_ARLEN        => fifoReadMasters(i).arlen,
            S00_AXI_ARSIZE       => fifoReadMasters(i).arsize,
            S00_AXI_ARBURST      => fifoReadMasters(i).arburst,
            S00_AXI_ARLOCK       => fifoReadMasters(i).arlock(0),
            S00_AXI_ARCACHE      => fifoReadMasters(i).arcache,
            S00_AXI_ARPROT       => fifoReadMasters(i).arprot,
            S00_AXI_ARQOS        => fifoReadMasters(i).arqos,
            S00_AXI_ARVALID      => fifoReadMasters(i).arvalid,
            S00_AXI_ARREADY      => fifoReadSlaves(i).arready,
            S00_AXI_RID          => fifoReadSlaves(i).rid(0 downto 0),
            S00_AXI_RDATA        => fifoReadSlaves(i).rdata(511 downto 0),
            S00_AXI_RRESP        => fifoReadSlaves(i).rresp,
            S00_AXI_RLAST        => fifoReadSlaves(i).rlast,
            S00_AXI_RVALID       => fifoReadSlaves(i).rvalid,
            S00_AXI_RREADY       => fifoReadMasters(i).rready,
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

      -- Calculate the WDATA parity bits
      GEN_VEC : for j in 31 downto 0 generate
         wdataParity(i)(j) <= oddParity(hbmWriteMasters(i).wdata(8*j+7 downto 8*j));
      end generate;

   end generate;

   U_HBM : HbmDmaBufferIpCore
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
         -- AXI_04 Interface
         AXI_04_ACLK         => hbmClk,
         AXI_04_ARESET_N     => hbmRstL(1),
         AXI_04_ARADDR       => hbmReadMasters(1).araddr(32 downto 0),
         AXI_04_ARBURST      => hbmReadMasters(1).arburst,
         AXI_04_ARID         => hbmReadMasters(1).arid(5 downto 0),
         AXI_04_ARLEN        => hbmReadMasters(1).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_04_ARSIZE       => hbmReadMasters(1).arsize,
         AXI_04_ARVALID      => hbmReadMasters(1).arvalid,
         AXI_04_AWADDR       => hbmWriteMasters(1).awaddr(32 downto 0),
         AXI_04_AWBURST      => hbmWriteMasters(1).awburst,
         AXI_04_AWID         => hbmWriteMasters(1).awid(5 downto 0),
         AXI_04_AWLEN        => hbmWriteMasters(1).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_04_AWSIZE       => hbmWriteMasters(1).awsize,
         AXI_04_AWVALID      => hbmWriteMasters(1).awvalid,
         AXI_04_RREADY       => hbmReadMasters(1).rready,
         AXI_04_BREADY       => hbmWriteMasters(1).bready,
         AXI_04_WDATA        => hbmWriteMasters(1).wdata(255 downto 0),
         AXI_04_WLAST        => hbmWriteMasters(1).wlast,
         AXI_04_WSTRB        => hbmWriteMasters(1).wstrb(31 downto 0),
         AXI_04_WDATA_PARITY => wdataParity(1),
         AXI_04_WVALID       => hbmWriteMasters(1).wvalid,
         AXI_04_ARREADY      => hbmReadSlaves(1).arready,
         AXI_04_AWREADY      => hbmWriteSlaves(1).awready,
         AXI_04_RDATA_PARITY => open,
         AXI_04_RDATA        => hbmReadSlaves(1).rdata(255 downto 0),
         AXI_04_RID          => open,
         AXI_04_RLAST        => hbmReadSlaves(1).rlast,
         AXI_04_RRESP        => hbmReadSlaves(1).rresp,
         AXI_04_RVALID       => hbmReadSlaves(1).rvalid,
         AXI_04_WREADY       => hbmWriteSlaves(1).wready,
         AXI_04_BID          => open,
         AXI_04_BRESP        => hbmWriteSlaves(1).bresp,
         AXI_04_BVALID       => hbmWriteSlaves(1).bvalid,
         -- AXI_08 Interface
         AXI_08_ACLK         => hbmClk,
         AXI_08_ARESET_N     => hbmRstL(2),
         AXI_08_ARADDR       => hbmReadMasters(2).araddr(32 downto 0),
         AXI_08_ARBURST      => hbmReadMasters(2).arburst,
         AXI_08_ARID         => hbmReadMasters(2).arid(5 downto 0),
         AXI_08_ARLEN        => hbmReadMasters(2).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_08_ARSIZE       => hbmReadMasters(2).arsize,
         AXI_08_ARVALID      => hbmReadMasters(2).arvalid,
         AXI_08_AWADDR       => hbmWriteMasters(2).awaddr(32 downto 0),
         AXI_08_AWBURST      => hbmWriteMasters(2).awburst,
         AXI_08_AWID         => hbmWriteMasters(2).awid(5 downto 0),
         AXI_08_AWLEN        => hbmWriteMasters(2).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_08_AWSIZE       => hbmWriteMasters(2).awsize,
         AXI_08_AWVALID      => hbmWriteMasters(2).awvalid,
         AXI_08_RREADY       => hbmReadMasters(2).rready,
         AXI_08_BREADY       => hbmWriteMasters(2).bready,
         AXI_08_WDATA        => hbmWriteMasters(2).wdata(255 downto 0),
         AXI_08_WLAST        => hbmWriteMasters(2).wlast,
         AXI_08_WSTRB        => hbmWriteMasters(2).wstrb(31 downto 0),
         AXI_08_WDATA_PARITY => wdataParity(2),
         AXI_08_WVALID       => hbmWriteMasters(2).wvalid,
         AXI_08_ARREADY      => hbmReadSlaves(2).arready,
         AXI_08_AWREADY      => hbmWriteSlaves(2).awready,
         AXI_08_RDATA_PARITY => open,
         AXI_08_RDATA        => hbmReadSlaves(2).rdata(255 downto 0),
         AXI_08_RID          => open,
         AXI_08_RLAST        => hbmReadSlaves(2).rlast,
         AXI_08_RRESP        => hbmReadSlaves(2).rresp,
         AXI_08_RVALID       => hbmReadSlaves(2).rvalid,
         AXI_08_WREADY       => hbmWriteSlaves(2).wready,
         AXI_08_BID          => open,
         AXI_08_BRESP        => hbmWriteSlaves(2).bresp,
         AXI_08_BVALID       => hbmWriteSlaves(2).bvalid,
         -- AXI_12 Interface
         AXI_12_ACLK         => hbmClk,
         AXI_12_ARESET_N     => hbmRstL(3),
         AXI_12_ARADDR       => hbmReadMasters(3).araddr(32 downto 0),
         AXI_12_ARBURST      => hbmReadMasters(3).arburst,
         AXI_12_ARID         => hbmReadMasters(3).arid(5 downto 0),
         AXI_12_ARLEN        => hbmReadMasters(3).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_12_ARSIZE       => hbmReadMasters(3).arsize,
         AXI_12_ARVALID      => hbmReadMasters(3).arvalid,
         AXI_12_AWADDR       => hbmWriteMasters(3).awaddr(32 downto 0),
         AXI_12_AWBURST      => hbmWriteMasters(3).awburst,
         AXI_12_AWID         => hbmWriteMasters(3).awid(5 downto 0),
         AXI_12_AWLEN        => hbmWriteMasters(3).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_12_AWSIZE       => hbmWriteMasters(3).awsize,
         AXI_12_AWVALID      => hbmWriteMasters(3).awvalid,
         AXI_12_RREADY       => hbmReadMasters(3).rready,
         AXI_12_BREADY       => hbmWriteMasters(3).bready,
         AXI_12_WDATA        => hbmWriteMasters(3).wdata(255 downto 0),
         AXI_12_WLAST        => hbmWriteMasters(3).wlast,
         AXI_12_WSTRB        => hbmWriteMasters(3).wstrb(31 downto 0),
         AXI_12_WDATA_PARITY => wdataParity(3),
         AXI_12_WVALID       => hbmWriteMasters(3).wvalid,
         AXI_12_ARREADY      => hbmReadSlaves(3).arready,
         AXI_12_AWREADY      => hbmWriteSlaves(3).awready,
         AXI_12_RDATA_PARITY => open,
         AXI_12_RDATA        => hbmReadSlaves(3).rdata(255 downto 0),
         AXI_12_RID          => open,
         AXI_12_RLAST        => hbmReadSlaves(3).rlast,
         AXI_12_RRESP        => hbmReadSlaves(3).rresp,
         AXI_12_RVALID       => hbmReadSlaves(3).rvalid,
         AXI_12_WREADY       => hbmWriteSlaves(3).wready,
         AXI_12_BID          => open,
         AXI_12_BRESP        => hbmWriteSlaves(3).bresp,
         AXI_12_BVALID       => hbmWriteSlaves(3).bvalid,
         -- AXI_16 Interface
         AXI_16_ACLK         => hbmClk,
         AXI_16_ARESET_N     => hbmRstL(4),
         AXI_16_ARADDR       => hbmReadMasters(4).araddr(32 downto 0),
         AXI_16_ARBURST      => hbmReadMasters(4).arburst,
         AXI_16_ARID         => hbmReadMasters(4).arid(5 downto 0),
         AXI_16_ARLEN        => hbmReadMasters(4).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_16_ARSIZE       => hbmReadMasters(4).arsize,
         AXI_16_ARVALID      => hbmReadMasters(4).arvalid,
         AXI_16_AWADDR       => hbmWriteMasters(4).awaddr(32 downto 0),
         AXI_16_AWBURST      => hbmWriteMasters(4).awburst,
         AXI_16_AWID         => hbmWriteMasters(4).awid(5 downto 0),
         AXI_16_AWLEN        => hbmWriteMasters(4).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_16_AWSIZE       => hbmWriteMasters(4).awsize,
         AXI_16_AWVALID      => hbmWriteMasters(4).awvalid,
         AXI_16_RREADY       => hbmReadMasters(4).rready,
         AXI_16_BREADY       => hbmWriteMasters(4).bready,
         AXI_16_WDATA        => hbmWriteMasters(4).wdata(255 downto 0),
         AXI_16_WLAST        => hbmWriteMasters(4).wlast,
         AXI_16_WSTRB        => hbmWriteMasters(4).wstrb(31 downto 0),
         AXI_16_WDATA_PARITY => wdataParity(4),
         AXI_16_WVALID       => hbmWriteMasters(4).wvalid,
         AXI_16_ARREADY      => hbmReadSlaves(4).arready,
         AXI_16_AWREADY      => hbmWriteSlaves(4).awready,
         AXI_16_RDATA_PARITY => open,
         AXI_16_RDATA        => hbmReadSlaves(4).rdata(255 downto 0),
         AXI_16_RID          => open,
         AXI_16_RLAST        => hbmReadSlaves(4).rlast,
         AXI_16_RRESP        => hbmReadSlaves(4).rresp,
         AXI_16_RVALID       => hbmReadSlaves(4).rvalid,
         AXI_16_WREADY       => hbmWriteSlaves(4).wready,
         AXI_16_BID          => open,
         AXI_16_BRESP        => hbmWriteSlaves(4).bresp,
         AXI_16_BVALID       => hbmWriteSlaves(4).bvalid,
         -- AXI_20 Interface
         AXI_20_ACLK         => hbmClk,
         AXI_20_ARESET_N     => hbmRstL(5),
         AXI_20_ARADDR       => hbmReadMasters(5).araddr(32 downto 0),
         AXI_20_ARBURST      => hbmReadMasters(5).arburst,
         AXI_20_ARID         => hbmReadMasters(5).arid(5 downto 0),
         AXI_20_ARLEN        => hbmReadMasters(5).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_20_ARSIZE       => hbmReadMasters(5).arsize,
         AXI_20_ARVALID      => hbmReadMasters(5).arvalid,
         AXI_20_AWADDR       => hbmWriteMasters(5).awaddr(32 downto 0),
         AXI_20_AWBURST      => hbmWriteMasters(5).awburst,
         AXI_20_AWID         => hbmWriteMasters(5).awid(5 downto 0),
         AXI_20_AWLEN        => hbmWriteMasters(5).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_20_AWSIZE       => hbmWriteMasters(5).awsize,
         AXI_20_AWVALID      => hbmWriteMasters(5).awvalid,
         AXI_20_RREADY       => hbmReadMasters(5).rready,
         AXI_20_BREADY       => hbmWriteMasters(5).bready,
         AXI_20_WDATA        => hbmWriteMasters(5).wdata(255 downto 0),
         AXI_20_WLAST        => hbmWriteMasters(5).wlast,
         AXI_20_WSTRB        => hbmWriteMasters(5).wstrb(31 downto 0),
         AXI_20_WDATA_PARITY => wdataParity(5),
         AXI_20_WVALID       => hbmWriteMasters(5).wvalid,
         AXI_20_ARREADY      => hbmReadSlaves(5).arready,
         AXI_20_AWREADY      => hbmWriteSlaves(5).awready,
         AXI_20_RDATA_PARITY => open,
         AXI_20_RDATA        => hbmReadSlaves(5).rdata(255 downto 0),
         AXI_20_RID          => open,
         AXI_20_RLAST        => hbmReadSlaves(5).rlast,
         AXI_20_RRESP        => hbmReadSlaves(5).rresp,
         AXI_20_RVALID       => hbmReadSlaves(5).rvalid,
         AXI_20_WREADY       => hbmWriteSlaves(5).wready,
         AXI_20_BID          => open,
         AXI_20_BRESP        => hbmWriteSlaves(5).bresp,
         AXI_20_BVALID       => hbmWriteSlaves(5).bvalid,
         -- AXI_24 Interface
         AXI_24_ACLK         => hbmClk,
         AXI_24_ARESET_N     => hbmRstL(6),
         AXI_24_ARADDR       => hbmReadMasters(6).araddr(32 downto 0),
         AXI_24_ARBURST      => hbmReadMasters(6).arburst,
         AXI_24_ARID         => hbmReadMasters(6).arid(5 downto 0),
         AXI_24_ARLEN        => hbmReadMasters(6).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_24_ARSIZE       => hbmReadMasters(6).arsize,
         AXI_24_ARVALID      => hbmReadMasters(6).arvalid,
         AXI_24_AWADDR       => hbmWriteMasters(6).awaddr(32 downto 0),
         AXI_24_AWBURST      => hbmWriteMasters(6).awburst,
         AXI_24_AWID         => hbmWriteMasters(6).awid(5 downto 0),
         AXI_24_AWLEN        => hbmWriteMasters(6).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_24_AWSIZE       => hbmWriteMasters(6).awsize,
         AXI_24_AWVALID      => hbmWriteMasters(6).awvalid,
         AXI_24_RREADY       => hbmReadMasters(6).rready,
         AXI_24_BREADY       => hbmWriteMasters(6).bready,
         AXI_24_WDATA        => hbmWriteMasters(6).wdata(255 downto 0),
         AXI_24_WLAST        => hbmWriteMasters(6).wlast,
         AXI_24_WSTRB        => hbmWriteMasters(6).wstrb(31 downto 0),
         AXI_24_WDATA_PARITY => wdataParity(6),
         AXI_24_WVALID       => hbmWriteMasters(6).wvalid,
         AXI_24_ARREADY      => hbmReadSlaves(6).arready,
         AXI_24_AWREADY      => hbmWriteSlaves(6).awready,
         AXI_24_RDATA_PARITY => open,
         AXI_24_RDATA        => hbmReadSlaves(6).rdata(255 downto 0),
         AXI_24_RID          => open,
         AXI_24_RLAST        => hbmReadSlaves(6).rlast,
         AXI_24_RRESP        => hbmReadSlaves(6).rresp,
         AXI_24_RVALID       => hbmReadSlaves(6).rvalid,
         AXI_24_WREADY       => hbmWriteSlaves(6).wready,
         AXI_24_BID          => open,
         AXI_24_BRESP        => hbmWriteSlaves(6).bresp,
         AXI_24_BVALID       => hbmWriteSlaves(6).bvalid,
         -- AXI_28 Interface
         AXI_28_ACLK         => hbmClk,
         AXI_28_ARESET_N     => hbmRstL(7),
         AXI_28_ARADDR       => hbmReadMasters(7).araddr(32 downto 0),
         AXI_28_ARBURST      => hbmReadMasters(7).arburst,
         AXI_28_ARID         => hbmReadMasters(7).arid(5 downto 0),
         AXI_28_ARLEN        => hbmReadMasters(7).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_28_ARSIZE       => hbmReadMasters(7).arsize,
         AXI_28_ARVALID      => hbmReadMasters(7).arvalid,
         AXI_28_AWADDR       => hbmWriteMasters(7).awaddr(32 downto 0),
         AXI_28_AWBURST      => hbmWriteMasters(7).awburst,
         AXI_28_AWID         => hbmWriteMasters(7).awid(5 downto 0),
         AXI_28_AWLEN        => hbmWriteMasters(7).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_28_AWSIZE       => hbmWriteMasters(7).awsize,
         AXI_28_AWVALID      => hbmWriteMasters(7).awvalid,
         AXI_28_RREADY       => hbmReadMasters(7).rready,
         AXI_28_BREADY       => hbmWriteMasters(7).bready,
         AXI_28_WDATA        => hbmWriteMasters(7).wdata(255 downto 0),
         AXI_28_WLAST        => hbmWriteMasters(7).wlast,
         AXI_28_WSTRB        => hbmWriteMasters(7).wstrb(31 downto 0),
         AXI_28_WDATA_PARITY => wdataParity(7),
         AXI_28_WVALID       => hbmWriteMasters(7).wvalid,
         AXI_28_ARREADY      => hbmReadSlaves(7).arready,
         AXI_28_AWREADY      => hbmWriteSlaves(7).awready,
         AXI_28_RDATA_PARITY => open,
         AXI_28_RDATA        => hbmReadSlaves(7).rdata(255 downto 0),
         AXI_28_RID          => open,
         AXI_28_RLAST        => hbmReadSlaves(7).rlast,
         AXI_28_RRESP        => hbmReadSlaves(7).rresp,
         AXI_28_RVALID       => hbmReadSlaves(7).rvalid,
         AXI_28_WREADY       => hbmWriteSlaves(7).wready,
         AXI_28_BID          => open,
         AXI_28_BRESP        => hbmWriteSlaves(7).bresp,
         AXI_28_BVALID       => hbmWriteSlaves(7).bvalid,
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
         asyncRst => hbmRst,
         syncRst  => apbRstL);

end mapping;
