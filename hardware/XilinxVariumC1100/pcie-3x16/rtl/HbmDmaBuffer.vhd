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
      AXIL_BASE_ADDR_G  : slv(31 downto 0));
   port (
      -- HBM Interface
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
      eventClk         : in  sl;
      eventTrigMsgCtrl : out AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);
      -- AXI Stream Interface (axisClk domain)
      axisClk          : in  sl;
      axisRst          : in  sl;
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
         AXI_01_ACLK         : in  std_logic;
         AXI_01_ARESET_N     : in  std_logic;
         AXI_01_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_01_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_01_ARID         : in  std_logic_vector(5 downto 0);
         AXI_01_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_01_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_01_ARVALID      : in  std_logic;
         AXI_01_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_01_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_01_AWID         : in  std_logic_vector(5 downto 0);
         AXI_01_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_01_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_01_AWVALID      : in  std_logic;
         AXI_01_RREADY       : in  std_logic;
         AXI_01_BREADY       : in  std_logic;
         AXI_01_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_01_WLAST        : in  std_logic;
         AXI_01_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_01_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_01_WVALID       : in  std_logic;
         AXI_02_ACLK         : in  std_logic;
         AXI_02_ARESET_N     : in  std_logic;
         AXI_02_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_02_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_02_ARID         : in  std_logic_vector(5 downto 0);
         AXI_02_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_02_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_02_ARVALID      : in  std_logic;
         AXI_02_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_02_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_02_AWID         : in  std_logic_vector(5 downto 0);
         AXI_02_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_02_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_02_AWVALID      : in  std_logic;
         AXI_02_RREADY       : in  std_logic;
         AXI_02_BREADY       : in  std_logic;
         AXI_02_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_02_WLAST        : in  std_logic;
         AXI_02_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_02_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_02_WVALID       : in  std_logic;
         AXI_03_ACLK         : in  std_logic;
         AXI_03_ARESET_N     : in  std_logic;
         AXI_03_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_03_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_03_ARID         : in  std_logic_vector(5 downto 0);
         AXI_03_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_03_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_03_ARVALID      : in  std_logic;
         AXI_03_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_03_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_03_AWID         : in  std_logic_vector(5 downto 0);
         AXI_03_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_03_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_03_AWVALID      : in  std_logic;
         AXI_03_RREADY       : in  std_logic;
         AXI_03_BREADY       : in  std_logic;
         AXI_03_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_03_WLAST        : in  std_logic;
         AXI_03_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_03_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_03_WVALID       : in  std_logic;
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
         AXI_05_ACLK         : in  std_logic;
         AXI_05_ARESET_N     : in  std_logic;
         AXI_05_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_05_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_05_ARID         : in  std_logic_vector(5 downto 0);
         AXI_05_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_05_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_05_ARVALID      : in  std_logic;
         AXI_05_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_05_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_05_AWID         : in  std_logic_vector(5 downto 0);
         AXI_05_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_05_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_05_AWVALID      : in  std_logic;
         AXI_05_RREADY       : in  std_logic;
         AXI_05_BREADY       : in  std_logic;
         AXI_05_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_05_WLAST        : in  std_logic;
         AXI_05_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_05_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_05_WVALID       : in  std_logic;
         AXI_06_ACLK         : in  std_logic;
         AXI_06_ARESET_N     : in  std_logic;
         AXI_06_ARADDR       : in  std_logic_vector(32 downto 0);
         AXI_06_ARBURST      : in  std_logic_vector(1 downto 0);
         AXI_06_ARID         : in  std_logic_vector(5 downto 0);
         AXI_06_ARLEN        : in  std_logic_vector(3 downto 0);
         AXI_06_ARSIZE       : in  std_logic_vector(2 downto 0);
         AXI_06_ARVALID      : in  std_logic;
         AXI_06_AWADDR       : in  std_logic_vector(32 downto 0);
         AXI_06_AWBURST      : in  std_logic_vector(1 downto 0);
         AXI_06_AWID         : in  std_logic_vector(5 downto 0);
         AXI_06_AWLEN        : in  std_logic_vector(3 downto 0);
         AXI_06_AWSIZE       : in  std_logic_vector(2 downto 0);
         AXI_06_AWVALID      : in  std_logic;
         AXI_06_RREADY       : in  std_logic;
         AXI_06_BREADY       : in  std_logic;
         AXI_06_WDATA        : in  std_logic_vector(255 downto 0);
         AXI_06_WLAST        : in  std_logic;
         AXI_06_WSTRB        : in  std_logic_vector(31 downto 0);
         AXI_06_WDATA_PARITY : in  std_logic_vector(31 downto 0);
         AXI_06_WVALID       : in  std_logic;
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
         AXI_01_ARREADY      : out std_logic;
         AXI_01_AWREADY      : out std_logic;
         AXI_01_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_01_RDATA        : out std_logic_vector(255 downto 0);
         AXI_01_RID          : out std_logic_vector(5 downto 0);
         AXI_01_RLAST        : out std_logic;
         AXI_01_RRESP        : out std_logic_vector(1 downto 0);
         AXI_01_RVALID       : out std_logic;
         AXI_01_WREADY       : out std_logic;
         AXI_01_BID          : out std_logic_vector(5 downto 0);
         AXI_01_BRESP        : out std_logic_vector(1 downto 0);
         AXI_01_BVALID       : out std_logic;
         AXI_02_ARREADY      : out std_logic;
         AXI_02_AWREADY      : out std_logic;
         AXI_02_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_02_RDATA        : out std_logic_vector(255 downto 0);
         AXI_02_RID          : out std_logic_vector(5 downto 0);
         AXI_02_RLAST        : out std_logic;
         AXI_02_RRESP        : out std_logic_vector(1 downto 0);
         AXI_02_RVALID       : out std_logic;
         AXI_02_WREADY       : out std_logic;
         AXI_02_BID          : out std_logic_vector(5 downto 0);
         AXI_02_BRESP        : out std_logic_vector(1 downto 0);
         AXI_02_BVALID       : out std_logic;
         AXI_03_ARREADY      : out std_logic;
         AXI_03_AWREADY      : out std_logic;
         AXI_03_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_03_RDATA        : out std_logic_vector(255 downto 0);
         AXI_03_RID          : out std_logic_vector(5 downto 0);
         AXI_03_RLAST        : out std_logic;
         AXI_03_RRESP        : out std_logic_vector(1 downto 0);
         AXI_03_RVALID       : out std_logic;
         AXI_03_WREADY       : out std_logic;
         AXI_03_BID          : out std_logic_vector(5 downto 0);
         AXI_03_BRESP        : out std_logic_vector(1 downto 0);
         AXI_03_BVALID       : out std_logic;
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
         AXI_05_ARREADY      : out std_logic;
         AXI_05_AWREADY      : out std_logic;
         AXI_05_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_05_RDATA        : out std_logic_vector(255 downto 0);
         AXI_05_RID          : out std_logic_vector(5 downto 0);
         AXI_05_RLAST        : out std_logic;
         AXI_05_RRESP        : out std_logic_vector(1 downto 0);
         AXI_05_RVALID       : out std_logic;
         AXI_05_WREADY       : out std_logic;
         AXI_05_BID          : out std_logic_vector(5 downto 0);
         AXI_05_BRESP        : out std_logic_vector(1 downto 0);
         AXI_05_BVALID       : out std_logic;
         AXI_06_ARREADY      : out std_logic;
         AXI_06_AWREADY      : out std_logic;
         AXI_06_RDATA_PARITY : out std_logic_vector(31 downto 0);
         AXI_06_RDATA        : out std_logic_vector(255 downto 0);
         AXI_06_RID          : out std_logic_vector(5 downto 0);
         AXI_06_RLAST        : out std_logic;
         AXI_06_RRESP        : out std_logic_vector(1 downto 0);
         AXI_06_RVALID       : out std_logic;
         AXI_06_WREADY       : out std_logic;
         AXI_06_BID          : out std_logic_vector(5 downto 0);
         AXI_06_BRESP        : out std_logic_vector(1 downto 0);
         AXI_06_BVALID       : out std_logic;
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
         aclk          : in  std_logic;
         aresetn       : in  std_logic;
         s_axi_awaddr  : in  std_logic_vector(32 downto 0);
         s_axi_awlen   : in  std_logic_vector(3 downto 0);
         s_axi_awsize  : in  std_logic_vector(2 downto 0);
         s_axi_awburst : in  std_logic_vector(1 downto 0);
         s_axi_awlock  : in  std_logic_vector(1 downto 0);
         s_axi_awcache : in  std_logic_vector(3 downto 0);
         s_axi_awprot  : in  std_logic_vector(2 downto 0);
         s_axi_awqos   : in  std_logic_vector(3 downto 0);
         s_axi_awvalid : in  std_logic;
         s_axi_awready : out std_logic;
         s_axi_wdata   : in  std_logic_vector(255 downto 0);
         s_axi_wstrb   : in  std_logic_vector(31 downto 0);
         s_axi_wlast   : in  std_logic;
         s_axi_wvalid  : in  std_logic;
         s_axi_wready  : out std_logic;
         s_axi_bresp   : out std_logic_vector(1 downto 0);
         s_axi_bvalid  : out std_logic;
         s_axi_bready  : in  std_logic;
         s_axi_araddr  : in  std_logic_vector(32 downto 0);
         s_axi_arlen   : in  std_logic_vector(3 downto 0);
         s_axi_arsize  : in  std_logic_vector(2 downto 0);
         s_axi_arburst : in  std_logic_vector(1 downto 0);
         s_axi_arlock  : in  std_logic_vector(1 downto 0);
         s_axi_arcache : in  std_logic_vector(3 downto 0);
         s_axi_arprot  : in  std_logic_vector(2 downto 0);
         s_axi_arqos   : in  std_logic_vector(3 downto 0);
         s_axi_arvalid : in  std_logic;
         s_axi_arready : out std_logic;
         s_axi_rdata   : out std_logic_vector(255 downto 0);
         s_axi_rresp   : out std_logic_vector(1 downto 0);
         s_axi_rlast   : out std_logic;
         s_axi_rvalid  : out std_logic;
         s_axi_rready  : in  std_logic;
         m_axi_awaddr  : out std_logic_vector(32 downto 0);
         m_axi_awlen   : out std_logic_vector(3 downto 0);
         m_axi_awsize  : out std_logic_vector(2 downto 0);
         m_axi_awburst : out std_logic_vector(1 downto 0);
         m_axi_awlock  : out std_logic_vector(1 downto 0);
         m_axi_awcache : out std_logic_vector(3 downto 0);
         m_axi_awprot  : out std_logic_vector(2 downto 0);
         m_axi_awqos   : out std_logic_vector(3 downto 0);
         m_axi_awvalid : out std_logic;
         m_axi_awready : in  std_logic;
         m_axi_wdata   : out std_logic_vector(255 downto 0);
         m_axi_wstrb   : out std_logic_vector(31 downto 0);
         m_axi_wlast   : out std_logic;
         m_axi_wvalid  : out std_logic;
         m_axi_wready  : in  std_logic;
         m_axi_bresp   : in  std_logic_vector(1 downto 0);
         m_axi_bvalid  : in  std_logic;
         m_axi_bready  : out std_logic;
         m_axi_araddr  : out std_logic_vector(32 downto 0);
         m_axi_arlen   : out std_logic_vector(3 downto 0);
         m_axi_arsize  : out std_logic_vector(2 downto 0);
         m_axi_arburst : out std_logic_vector(1 downto 0);
         m_axi_arlock  : out std_logic_vector(1 downto 0);
         m_axi_arcache : out std_logic_vector(3 downto 0);
         m_axi_arprot  : out std_logic_vector(2 downto 0);
         m_axi_arqos   : out std_logic_vector(3 downto 0);
         m_axi_arvalid : out std_logic;
         m_axi_arready : in  std_logic;
         m_axi_rdata   : in  std_logic_vector(255 downto 0);
         m_axi_rresp   : in  std_logic_vector(1 downto 0);
         m_axi_rlast   : in  std_logic;
         m_axi_rvalid  : in  std_logic;
         m_axi_rready  : out std_logic
         );
   end component;

   -- HBM MEM AXI Configuration
   constant MEM_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 33,               -- 8GB HBM
      DATA_BYTES_C => 32,               -- 256-bit data interface
      ID_BITS_C    => 6,                -- Up to 64 IDS
      LEN_BITS_C   => 4);               -- 4-bit awlen/arlen interface

   constant AXI_BUFFER_WIDTH_C : positive := MEM_AXI_CONFIG_C.ADDR_WIDTH_C-3;  -- 8 GB HBM shared between 8 DMA lanes
   constant AXI_BASE_ADDR_C : Slv64Array(7 downto 0) := (
      0 => x"0000_0000_0000_0000",
      1 => x"0000_0000_4000_0000",      -- 1GB partitions
      2 => x"0000_0000_8000_0000",
      3 => x"0000_0000_C000_0000",
      4 => x"0000_0001_0000_0000",
      5 => x"0000_0001_4000_0000",
      6 => x"0000_0001_8000_0000",
      7 => x"0000_0001_C000_0000");

   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,  -- Match 40-bit address for axi_pcie_core.AxiPcieResizer
      DATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,  -- Matches the AXIS stream because you ***CANNOT*** resize an interleaved AXI stream
      ID_BITS_C    => MEM_AXI_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => MEM_AXI_CONFIG_C.LEN_BITS_C);

   constant INT_DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,  -- Match 40-bit address for axi_pcie_core.AxiPcieResizer
      DATA_BYTES_C => MEM_AXI_CONFIG_C.DATA_BYTES_C,  -- Actual memory interface width
      ID_BITS_C    => MEM_AXI_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => MEM_AXI_CONFIG_C.LEN_BITS_C);

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(DMA_SIZE_G-1 downto 0) := genAxiLiteConfig(DMA_SIZE_G, AXIL_BASE_ADDR_G, 12, 8);

   signal axilWriteMasters : AxiLiteWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal memWriteMasters : AxiWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal memWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal memReadMasters  : AxiReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal memReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal fifoWriteMasters : AxiWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal fifoWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal fifoReadMasters  : AxiReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal fifoReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal axiWriteMasters : AxiWriteMasterArray(7 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(7 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal axiReadMasters  : AxiReadMasterArray(7 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal axiReadSlaves   : AxiReadSlaveArray(7 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal sAxisCtrl : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);

   signal axisReset     : slv(7 downto 0);
   signal axisRstL      : slv(7 downto 0);
   signal hbmCatTripVec : slv(1 downto 0);
   signal apbDoneVec    : slv(1 downto 0);
   signal apbDone       : sl;
   signal apbDoneSync   : sl;
   signal apbRstL       : sl;
   signal axiReady      : slv(7 downto 0);
   signal wdataParity   : Slv32Array(7 downto 0) := (others => (others => '0'));

begin

   -- Help with timing
   U_axisReset : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 8,
         INV_RST_G => false)
      port map (
         clk    => axisClk,
         rstIn  => (others => axisRst),
         rstOut => axisReset);

   -- Help with timing
   U_axisRstL : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 8,
         INV_RST_G => true)              -- invert reset
      port map (
         clk    => axisClk,
         rstIn  => (others => axisRst),  -- active HIGH
         rstOut => axisRstL);            -- active LOW

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
         axiClkRst           => axilRst,
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
            clk     => eventClk,
            dataIn  => sAxisCtrl(i).pause,
            dataOut => eventTrigMsgCtrl(i).pause);

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
            BURST_BYTES_G      => 256)  -- Match the HBM AXI switch's native max block transfer
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => axisClk,
            axiRst          => axisReset(i),
            axiReady        => axiReady(i),
            axiReadMaster   => memReadMasters(i),
            axiReadSlave    => memReadSlaves(i),
            axiWriteMaster  => memWriteMasters(i),
            axiWriteSlave   => memWriteSlaves(i),
            -- AXI Stream Interface (axiClk domain)
            sAxisMaster     => sAxisMasters(i),
            sAxisSlave      => sAxisSlaves(i),
            sAxisCtrl       => sAxisCtrl(i),
            mAxisMaster     => mAxisMasters(i),
            mAxisSlave      => mAxisSlaves(i),
            -- Optional: AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_Resizer : entity axi_pcie_core.AxiPcieResizer
         generic map(
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            AXI_PCIE_CONFIG_G => INT_DMA_AXI_CONFIG_C)
         port map(
            -- Clock and reset
            axiClk          => axisClk,
            axiRst          => axisReset(i),
            -- Slave Port
            sAxiReadMaster  => memReadMasters(i),
            sAxiReadSlave   => memReadSlaves(i),
            sAxiWriteMaster => memWriteMasters(i),
            sAxiWriteSlave  => memWriteSlaves(i),
            -- Master Port
            mAxiReadMaster  => fifoReadMasters(i),
            mAxiReadSlave   => fifoReadSlaves(i),
            mAxiWriteMaster => fifoWriteMasters(i),
            mAxiWriteSlave  => fifoWriteSlaves(i));

      -- Store/Forward AXI3 FIFO
      U_StoreAndForwardFifo : HbmAxiFifo
         port map (
            aclk          => axisClk,
            aresetn       => axisRstL(i),
            -- Slave Interface
            s_axi_awaddr  => fifoWriteMasters(i).awaddr(32 downto 0),
            s_axi_awlen   => fifoWriteMasters(i).awlen(3 downto 0),
            s_axi_awsize  => fifoWriteMasters(i).awsize,
            s_axi_awburst => fifoWriteMasters(i).awburst,
            s_axi_awlock  => fifoWriteMasters(i).awlock,
            s_axi_awcache => fifoWriteMasters(i).awcache,
            s_axi_awprot  => fifoWriteMasters(i).awprot,
            s_axi_awqos   => fifoWriteMasters(i).awqos,
            s_axi_awvalid => fifoWriteMasters(i).awvalid,
            s_axi_awready => fifoWriteSlaves(i).awready,
            s_axi_wdata   => fifoWriteMasters(i).wdata(255 downto 0),
            s_axi_wstrb   => fifoWriteMasters(i).wstrb(31 downto 0),
            s_axi_wlast   => fifoWriteMasters(i).wlast,
            s_axi_wvalid  => fifoWriteMasters(i).wvalid,
            s_axi_wready  => fifoWriteSlaves(i).wready,
            s_axi_bresp   => fifoWriteSlaves(i).bresp,
            s_axi_bvalid  => fifoWriteSlaves(i).bvalid,
            s_axi_bready  => fifoWriteMasters(i).bready,
            s_axi_araddr  => fifoReadMasters(i).araddr(32 downto 0),
            s_axi_arlen   => fifoReadMasters(i).arlen(3 downto 0),
            s_axi_arsize  => fifoReadMasters(i).arsize,
            s_axi_arburst => fifoReadMasters(i).arburst,
            s_axi_arlock  => fifoReadMasters(i).arlock,
            s_axi_arcache => fifoReadMasters(i).arcache,
            s_axi_arprot  => fifoReadMasters(i).arprot,
            s_axi_arqos   => fifoReadMasters(i).arqos,
            s_axi_arvalid => fifoReadMasters(i).arvalid,
            s_axi_arready => fifoReadSlaves(i).arready,
            s_axi_rdata   => fifoReadSlaves(i).rdata(255 downto 0),
            s_axi_rresp   => fifoReadSlaves(i).rresp,
            s_axi_rlast   => fifoReadSlaves(i).rlast,
            s_axi_rvalid  => fifoReadSlaves(i).rvalid,
            s_axi_rready  => fifoReadMasters(i).rready,
            -- Master Interface
            m_axi_awaddr  => axiWriteMasters(i).awaddr(32 downto 0),
            m_axi_awlen   => axiWriteMasters(i).awlen(3 downto 0),
            m_axi_awsize  => axiWriteMasters(i).awsize,
            m_axi_awburst => axiWriteMasters(i).awburst,
            m_axi_awlock  => axiWriteMasters(i).awlock,
            m_axi_awcache => axiWriteMasters(i).awcache,
            m_axi_awprot  => axiWriteMasters(i).awprot,
            m_axi_awqos   => axiWriteMasters(i).awqos,
            m_axi_awvalid => axiWriteMasters(i).awvalid,
            m_axi_awready => axiWriteSlaves(i).awready,
            m_axi_wdata   => axiWriteMasters(i).wdata(255 downto 0),
            m_axi_wstrb   => axiWriteMasters(i).wstrb(31 downto 0),
            m_axi_wlast   => axiWriteMasters(i).wlast,
            m_axi_wvalid  => axiWriteMasters(i).wvalid,
            m_axi_wready  => axiWriteSlaves(i).wready,
            m_axi_bresp   => axiWriteSlaves(i).bresp,
            m_axi_bvalid  => axiWriteSlaves(i).bvalid,
            m_axi_bready  => axiWriteMasters(i).bready,
            m_axi_araddr  => axiReadMasters(i).araddr(32 downto 0),
            m_axi_arlen   => axiReadMasters(i).arlen(3 downto 0),
            m_axi_arsize  => axiReadMasters(i).arsize,
            m_axi_arburst => axiReadMasters(i).arburst,
            m_axi_arlock  => axiReadMasters(i).arlock,
            m_axi_arcache => axiReadMasters(i).arcache,
            m_axi_arprot  => axiReadMasters(i).arprot,
            m_axi_arqos   => axiReadMasters(i).arqos,
            m_axi_arvalid => axiReadMasters(i).arvalid,
            m_axi_arready => axiReadSlaves(i).arready,
            m_axi_rdata   => axiReadSlaves(i).rdata(255 downto 0),
            m_axi_rresp   => axiReadSlaves(i).rresp,
            m_axi_rlast   => axiReadSlaves(i).rlast,
            m_axi_rvalid  => axiReadSlaves(i).rvalid,
            m_axi_rready  => axiReadMasters(i).rready);

      -- Calculate the WDATA parity bits
      GEN_VEC : for j in MEM_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0 generate
         wdataParity(i)(j) <= oddParity(axiWriteMasters(i).wdata(8*j+7 downto 8*j));
      end generate;

   end generate;

   U_HBM : HbmDmaBufferIpCore
      port map (
         -- Reference Clocks
         HBM_REF_CLK_0       => hbmRefClk,
         HBM_REF_CLK_1       => hbmRefClk,
         -- AXI_00 Interface
         AXI_00_ACLK         => axisClk,
         AXI_00_ARESET_N     => axisRstL(0),
         AXI_00_ARADDR       => axiReadMasters(0).araddr(32 downto 0),
         AXI_00_ARBURST      => axiReadMasters(0).arburst,
         AXI_00_ARID         => toSlv(0, 6),
         AXI_00_ARLEN        => axiReadMasters(0).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_00_ARSIZE       => axiReadMasters(0).arsize,
         AXI_00_ARVALID      => axiReadMasters(0).arvalid,
         AXI_00_AWADDR       => axiWriteMasters(0).awaddr(32 downto 0),
         AXI_00_AWBURST      => axiWriteMasters(0).awburst,
         AXI_00_AWID         => toSlv(0, 6),
         AXI_00_AWLEN        => axiWriteMasters(0).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_00_AWSIZE       => axiWriteMasters(0).awsize,
         AXI_00_AWVALID      => axiWriteMasters(0).awvalid,
         AXI_00_RREADY       => axiReadMasters(0).rready,
         AXI_00_BREADY       => axiWriteMasters(0).bready,
         AXI_00_WDATA        => axiWriteMasters(0).wdata(255 downto 0),
         AXI_00_WLAST        => axiWriteMasters(0).wlast,
         AXI_00_WSTRB        => axiWriteMasters(0).wstrb(31 downto 0),
         AXI_00_WDATA_PARITY => wdataParity(0),
         AXI_00_WVALID       => axiWriteMasters(0).wvalid,
         AXI_00_ARREADY      => axiReadSlaves(0).arready,
         AXI_00_AWREADY      => axiWriteSlaves(0).awready,
         AXI_00_RDATA_PARITY => open,
         AXI_00_RDATA        => axiReadSlaves(0).rdata(255 downto 0),
         AXI_00_RID          => open,
         AXI_00_RLAST        => axiReadSlaves(0).rlast,
         AXI_00_RRESP        => axiReadSlaves(0).rresp,
         AXI_00_RVALID       => axiReadSlaves(0).rvalid,
         AXI_00_WREADY       => axiWriteSlaves(0).wready,
         AXI_00_BID          => open,
         AXI_00_BRESP        => axiWriteSlaves(0).bresp,
         AXI_00_BVALID       => axiWriteSlaves(0).bvalid,
         -- AXI_01 Interface
         AXI_01_ACLK         => axisClk,
         AXI_01_ARESET_N     => axisRstL(1),
         AXI_01_ARADDR       => axiReadMasters(1).araddr(32 downto 0),
         AXI_01_ARBURST      => axiReadMasters(1).arburst,
         AXI_01_ARID         => toSlv(1, 6),
         AXI_01_ARLEN        => axiReadMasters(1).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_01_ARSIZE       => axiReadMasters(1).arsize,
         AXI_01_ARVALID      => axiReadMasters(1).arvalid,
         AXI_01_AWADDR       => axiWriteMasters(1).awaddr(32 downto 0),
         AXI_01_AWBURST      => axiWriteMasters(1).awburst,
         AXI_01_AWID         => toSlv(1, 6),
         AXI_01_AWLEN        => axiWriteMasters(1).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_01_AWSIZE       => axiWriteMasters(1).awsize,
         AXI_01_AWVALID      => axiWriteMasters(1).awvalid,
         AXI_01_RREADY       => axiReadMasters(1).rready,
         AXI_01_BREADY       => axiWriteMasters(1).bready,
         AXI_01_WDATA        => axiWriteMasters(1).wdata(255 downto 0),
         AXI_01_WLAST        => axiWriteMasters(1).wlast,
         AXI_01_WSTRB        => axiWriteMasters(1).wstrb(31 downto 0),
         AXI_01_WDATA_PARITY => wdataParity(1),
         AXI_01_WVALID       => axiWriteMasters(1).wvalid,
         AXI_01_ARREADY      => axiReadSlaves(1).arready,
         AXI_01_AWREADY      => axiWriteSlaves(1).awready,
         AXI_01_RDATA_PARITY => open,
         AXI_01_RDATA        => axiReadSlaves(1).rdata(255 downto 0),
         AXI_01_RID          => open,
         AXI_01_RLAST        => axiReadSlaves(1).rlast,
         AXI_01_RRESP        => axiReadSlaves(1).rresp,
         AXI_01_RVALID       => axiReadSlaves(1).rvalid,
         AXI_01_WREADY       => axiWriteSlaves(1).wready,
         AXI_01_BID          => open,
         AXI_01_BRESP        => axiWriteSlaves(1).bresp,
         AXI_01_BVALID       => axiWriteSlaves(1).bvalid,
         -- AXI_02 Interface
         AXI_02_ACLK         => axisClk,
         AXI_02_ARESET_N     => axisRstL(2),
         AXI_02_ARADDR       => axiReadMasters(2).araddr(32 downto 0),
         AXI_02_ARBURST      => axiReadMasters(2).arburst,
         AXI_02_ARID         => toSlv(2, 6),
         AXI_02_ARLEN        => axiReadMasters(2).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_02_ARSIZE       => axiReadMasters(2).arsize,
         AXI_02_ARVALID      => axiReadMasters(2).arvalid,
         AXI_02_AWADDR       => axiWriteMasters(2).awaddr(32 downto 0),
         AXI_02_AWBURST      => axiWriteMasters(2).awburst,
         AXI_02_AWID         => toSlv(2, 6),
         AXI_02_AWLEN        => axiWriteMasters(2).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_02_AWSIZE       => axiWriteMasters(2).awsize,
         AXI_02_AWVALID      => axiWriteMasters(2).awvalid,
         AXI_02_RREADY       => axiReadMasters(2).rready,
         AXI_02_BREADY       => axiWriteMasters(2).bready,
         AXI_02_WDATA        => axiWriteMasters(2).wdata(255 downto 0),
         AXI_02_WLAST        => axiWriteMasters(2).wlast,
         AXI_02_WSTRB        => axiWriteMasters(2).wstrb(31 downto 0),
         AXI_02_WDATA_PARITY => wdataParity(2),
         AXI_02_WVALID       => axiWriteMasters(2).wvalid,
         AXI_02_ARREADY      => axiReadSlaves(2).arready,
         AXI_02_AWREADY      => axiWriteSlaves(2).awready,
         AXI_02_RDATA_PARITY => open,
         AXI_02_RDATA        => axiReadSlaves(2).rdata(255 downto 0),
         AXI_02_RID          => open,
         AXI_02_RLAST        => axiReadSlaves(2).rlast,
         AXI_02_RRESP        => axiReadSlaves(2).rresp,
         AXI_02_RVALID       => axiReadSlaves(2).rvalid,
         AXI_02_WREADY       => axiWriteSlaves(2).wready,
         AXI_02_BID          => open,
         AXI_02_BRESP        => axiWriteSlaves(2).bresp,
         AXI_02_BVALID       => axiWriteSlaves(2).bvalid,
         -- AXI_03 Interface
         AXI_03_ACLK         => axisClk,
         AXI_03_ARESET_N     => axisRstL(3),
         AXI_03_ARADDR       => axiReadMasters(3).araddr(32 downto 0),
         AXI_03_ARBURST      => axiReadMasters(3).arburst,
         AXI_03_ARID         => toSlv(3, 6),
         AXI_03_ARLEN        => axiReadMasters(3).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_03_ARSIZE       => axiReadMasters(3).arsize,
         AXI_03_ARVALID      => axiReadMasters(3).arvalid,
         AXI_03_AWADDR       => axiWriteMasters(3).awaddr(32 downto 0),
         AXI_03_AWBURST      => axiWriteMasters(3).awburst,
         AXI_03_AWID         => toSlv(3, 6),
         AXI_03_AWLEN        => axiWriteMasters(3).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_03_AWSIZE       => axiWriteMasters(3).awsize,
         AXI_03_AWVALID      => axiWriteMasters(3).awvalid,
         AXI_03_RREADY       => axiReadMasters(3).rready,
         AXI_03_BREADY       => axiWriteMasters(3).bready,
         AXI_03_WDATA        => axiWriteMasters(3).wdata(255 downto 0),
         AXI_03_WLAST        => axiWriteMasters(3).wlast,
         AXI_03_WSTRB        => axiWriteMasters(3).wstrb(31 downto 0),
         AXI_03_WDATA_PARITY => wdataParity(3),
         AXI_03_WVALID       => axiWriteMasters(3).wvalid,
         AXI_03_ARREADY      => axiReadSlaves(3).arready,
         AXI_03_AWREADY      => axiWriteSlaves(3).awready,
         AXI_03_RDATA_PARITY => open,
         AXI_03_RDATA        => axiReadSlaves(3).rdata(255 downto 0),
         AXI_03_RID          => open,
         AXI_03_RLAST        => axiReadSlaves(3).rlast,
         AXI_03_RRESP        => axiReadSlaves(3).rresp,
         AXI_03_RVALID       => axiReadSlaves(3).rvalid,
         AXI_03_WREADY       => axiWriteSlaves(3).wready,
         AXI_03_BID          => open,
         AXI_03_BRESP        => axiWriteSlaves(3).bresp,
         AXI_03_BVALID       => axiWriteSlaves(3).bvalid,
         -- AXI_04 Interface
         AXI_04_ACLK         => axisClk,
         AXI_04_ARESET_N     => axisRstL(4),
         AXI_04_ARADDR       => axiReadMasters(4).araddr(32 downto 0),
         AXI_04_ARBURST      => axiReadMasters(4).arburst,
         AXI_04_ARID         => toSlv(4, 6),
         AXI_04_ARLEN        => axiReadMasters(4).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_04_ARSIZE       => axiReadMasters(4).arsize,
         AXI_04_ARVALID      => axiReadMasters(4).arvalid,
         AXI_04_AWADDR       => axiWriteMasters(4).awaddr(32 downto 0),
         AXI_04_AWBURST      => axiWriteMasters(4).awburst,
         AXI_04_AWID         => toSlv(4, 6),
         AXI_04_AWLEN        => axiWriteMasters(4).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_04_AWSIZE       => axiWriteMasters(4).awsize,
         AXI_04_AWVALID      => axiWriteMasters(4).awvalid,
         AXI_04_RREADY       => axiReadMasters(4).rready,
         AXI_04_BREADY       => axiWriteMasters(4).bready,
         AXI_04_WDATA        => axiWriteMasters(4).wdata(255 downto 0),
         AXI_04_WLAST        => axiWriteMasters(4).wlast,
         AXI_04_WSTRB        => axiWriteMasters(4).wstrb(31 downto 0),
         AXI_04_WDATA_PARITY => wdataParity(4),
         AXI_04_WVALID       => axiWriteMasters(4).wvalid,
         AXI_04_ARREADY      => axiReadSlaves(4).arready,
         AXI_04_AWREADY      => axiWriteSlaves(4).awready,
         AXI_04_RDATA_PARITY => open,
         AXI_04_RDATA        => axiReadSlaves(4).rdata(255 downto 0),
         AXI_04_RID          => open,
         AXI_04_RLAST        => axiReadSlaves(4).rlast,
         AXI_04_RRESP        => axiReadSlaves(4).rresp,
         AXI_04_RVALID       => axiReadSlaves(4).rvalid,
         AXI_04_WREADY       => axiWriteSlaves(4).wready,
         AXI_04_BID          => open,
         AXI_04_BRESP        => axiWriteSlaves(4).bresp,
         AXI_04_BVALID       => axiWriteSlaves(4).bvalid,
         -- AXI_05 Interface
         AXI_05_ACLK         => axisClk,
         AXI_05_ARESET_N     => axisRstL(5),
         AXI_05_ARADDR       => axiReadMasters(5).araddr(32 downto 0),
         AXI_05_ARBURST      => axiReadMasters(5).arburst,
         AXI_05_ARID         => toSlv(5, 6),
         AXI_05_ARLEN        => axiReadMasters(5).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_05_ARSIZE       => axiReadMasters(5).arsize,
         AXI_05_ARVALID      => axiReadMasters(5).arvalid,
         AXI_05_AWADDR       => axiWriteMasters(5).awaddr(32 downto 0),
         AXI_05_AWBURST      => axiWriteMasters(5).awburst,
         AXI_05_AWID         => toSlv(5, 6),
         AXI_05_AWLEN        => axiWriteMasters(5).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_05_AWSIZE       => axiWriteMasters(5).awsize,
         AXI_05_AWVALID      => axiWriteMasters(5).awvalid,
         AXI_05_RREADY       => axiReadMasters(5).rready,
         AXI_05_BREADY       => axiWriteMasters(5).bready,
         AXI_05_WDATA        => axiWriteMasters(5).wdata(255 downto 0),
         AXI_05_WLAST        => axiWriteMasters(5).wlast,
         AXI_05_WSTRB        => axiWriteMasters(5).wstrb(31 downto 0),
         AXI_05_WDATA_PARITY => wdataParity(5),
         AXI_05_WVALID       => axiWriteMasters(5).wvalid,
         AXI_05_ARREADY      => axiReadSlaves(5).arready,
         AXI_05_AWREADY      => axiWriteSlaves(5).awready,
         AXI_05_RDATA_PARITY => open,
         AXI_05_RDATA        => axiReadSlaves(5).rdata(255 downto 0),
         AXI_05_RID          => open,
         AXI_05_RLAST        => axiReadSlaves(5).rlast,
         AXI_05_RRESP        => axiReadSlaves(5).rresp,
         AXI_05_RVALID       => axiReadSlaves(5).rvalid,
         AXI_05_WREADY       => axiWriteSlaves(5).wready,
         AXI_05_BID          => open,
         AXI_05_BRESP        => axiWriteSlaves(5).bresp,
         AXI_05_BVALID       => axiWriteSlaves(5).bvalid,
         -- AXI_06 Interface
         AXI_06_ACLK         => axisClk,
         AXI_06_ARESET_N     => axisRstL(6),
         AXI_06_ARADDR       => axiReadMasters(6).araddr(32 downto 0),
         AXI_06_ARBURST      => axiReadMasters(6).arburst,
         AXI_06_ARID         => toSlv(6, 6),
         AXI_06_ARLEN        => axiReadMasters(6).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_06_ARSIZE       => axiReadMasters(6).arsize,
         AXI_06_ARVALID      => axiReadMasters(6).arvalid,
         AXI_06_AWADDR       => axiWriteMasters(6).awaddr(32 downto 0),
         AXI_06_AWBURST      => axiWriteMasters(6).awburst,
         AXI_06_AWID         => toSlv(6, 6),
         AXI_06_AWLEN        => axiWriteMasters(6).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_06_AWSIZE       => axiWriteMasters(6).awsize,
         AXI_06_AWVALID      => axiWriteMasters(6).awvalid,
         AXI_06_RREADY       => axiReadMasters(6).rready,
         AXI_06_BREADY       => axiWriteMasters(6).bready,
         AXI_06_WDATA        => axiWriteMasters(6).wdata(255 downto 0),
         AXI_06_WLAST        => axiWriteMasters(6).wlast,
         AXI_06_WSTRB        => axiWriteMasters(6).wstrb(31 downto 0),
         AXI_06_WDATA_PARITY => wdataParity(6),
         AXI_06_WVALID       => axiWriteMasters(6).wvalid,
         AXI_06_ARREADY      => axiReadSlaves(6).arready,
         AXI_06_AWREADY      => axiWriteSlaves(6).awready,
         AXI_06_RDATA_PARITY => open,
         AXI_06_RDATA        => axiReadSlaves(6).rdata(255 downto 0),
         AXI_06_RID          => open,
         AXI_06_RLAST        => axiReadSlaves(6).rlast,
         AXI_06_RRESP        => axiReadSlaves(6).rresp,
         AXI_06_RVALID       => axiReadSlaves(6).rvalid,
         AXI_06_WREADY       => axiWriteSlaves(6).wready,
         AXI_06_BID          => open,
         AXI_06_BRESP        => axiWriteSlaves(6).bresp,
         AXI_06_BVALID       => axiWriteSlaves(6).bvalid,
         -- AXI_07 Interface
         AXI_07_ACLK         => axisClk,
         AXI_07_ARESET_N     => axisRstL(7),
         AXI_07_ARADDR       => axiReadMasters(7).araddr(32 downto 0),
         AXI_07_ARBURST      => axiReadMasters(7).arburst,
         AXI_07_ARID         => toSlv(7, 6),
         AXI_07_ARLEN        => axiReadMasters(7).arlen(3 downto 0),  -- 4-bits = AXI3
         AXI_07_ARSIZE       => axiReadMasters(7).arsize,
         AXI_07_ARVALID      => axiReadMasters(7).arvalid,
         AXI_07_AWADDR       => axiWriteMasters(7).awaddr(32 downto 0),
         AXI_07_AWBURST      => axiWriteMasters(7).awburst,
         AXI_07_AWID         => toSlv(7, 6),
         AXI_07_AWLEN        => axiWriteMasters(7).awlen(3 downto 0),  -- 4-bits = AXI3
         AXI_07_AWSIZE       => axiWriteMasters(7).awsize,
         AXI_07_AWVALID      => axiWriteMasters(7).awvalid,
         AXI_07_RREADY       => axiReadMasters(7).rready,
         AXI_07_BREADY       => axiWriteMasters(7).bready,
         AXI_07_WDATA        => axiWriteMasters(7).wdata(255 downto 0),
         AXI_07_WLAST        => axiWriteMasters(7).wlast,
         AXI_07_WSTRB        => axiWriteMasters(7).wstrb(31 downto 0),
         AXI_07_WDATA_PARITY => wdataParity(7),
         AXI_07_WVALID       => axiWriteMasters(7).wvalid,
         AXI_07_ARREADY      => axiReadSlaves(7).arready,
         AXI_07_AWREADY      => axiWriteSlaves(7).awready,
         AXI_07_RDATA_PARITY => open,
         AXI_07_RDATA        => axiReadSlaves(7).rdata(255 downto 0),
         AXI_07_RID          => open,
         AXI_07_RLAST        => axiReadSlaves(7).rlast,
         AXI_07_RRESP        => axiReadSlaves(7).rresp,
         AXI_07_RVALID       => axiReadSlaves(7).rvalid,
         AXI_07_WREADY       => axiWriteSlaves(7).wready,
         AXI_07_BID          => open,
         AXI_07_BRESP        => axiWriteSlaves(7).bresp,
         AXI_07_BVALID       => axiWriteSlaves(7).bvalid,
         -- APB Interface
         APB_0_PCLK          => hbmRefClk,
         APB_1_PCLK          => hbmRefClk,
         APB_0_PRESET_N      => apbRstL,
         APB_1_PRESET_N      => apbRstL,
         apb_complete_0      => apbDoneVec(0),
         apb_complete_1      => apbDoneVec(1),
         DRAM_0_STAT_CATTRIP => hbmCatTripVec(0),
         DRAM_1_STAT_CATTRIP => hbmCatTripVec(1),
         DRAM_0_STAT_TEMP    => open,
         DRAM_1_STAT_TEMP    => open);

   hbmCatTrip <= uOr(hbmCatTripVec);
   apbDone    <= uAnd(apbDoneVec);

   U_apbDone : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axisClk,
         dataIn  => apbDone,
         dataOut => apbDoneSync);

   U_axiReady : entity surf.RstPipelineVector
      generic map (
         TPD_G     => TPD_G,
         WIDTH_G   => 8,
         INV_RST_G => false)
      port map (
         clk    => axisClk,
         rstIn  => (others => apbDoneSync),
         rstOut => axiReady);

   U_apbRstL : entity surf.RstSync
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0')         -- active LOW
      port map (
         clk      => hbmRefClk,
         asyncRst => axisRst,
         syncRst  => apbRstL);

end mapping;
