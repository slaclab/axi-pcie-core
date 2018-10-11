-------------------------------------------------------------------------------
-- File       : AxiPcieCrossbar.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI DMA Crossbar
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;

entity AxiPcieCrossbar is
   generic (
      TPD_G             : time                  := 1 ns;
      USE_XBAR_IPCORE_G : boolean               := true;
      AXI_DESC_CONFIG_G : AxiConfigType;
      AXI_DMA_CONFIG_G  : AxiConfigType;
      AXI_PCIE_CONFIG_G : AxiConfigType;
      DMA_SIZE_G        : positive range 1 to 8 := 1);
   port (
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- Slaves
      sAxiWriteMasters : in  AxiWriteMasterArray(DMA_SIZE_G downto 0);
      sAxiWriteSlaves  : out AxiWriteSlaveArray(DMA_SIZE_G downto 0);
      sAxiWriteCtrl    : out AxiCtrlArray(DMA_SIZE_G downto 0);
      sAxiReadMasters  : in  AxiReadMasterArray(DMA_SIZE_G downto 0);
      sAxiReadSlaves   : out AxiReadSlaveArray(DMA_SIZE_G downto 0);
      -- Master
      mAxiWriteMaster  : out AxiWriteMasterType;
      mAxiWriteSlave   : in  AxiWriteSlaveType;
      mAxiReadMaster   : out AxiReadMasterType;
      mAxiReadSlave    : in  AxiReadSlaveType);
end AxiPcieCrossbar;

architecture mapping of AxiPcieCrossbar is

   component AxiPcieCrossbarIpCore
      port (
         INTERCONNECT_ACLK    : in  std_logic;
         INTERCONNECT_ARESETN : in  std_logic;
         S00_AXI_ARESET_OUT_N : out std_logic;
         S00_AXI_ACLK         : in  std_logic;
         S00_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S00_AXI_AWADDR       : in  std_logic_vector(47 downto 0);
         S00_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S00_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S00_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S00_AXI_AWLOCK       : in  std_logic;
         S00_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S00_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S00_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S00_AXI_AWVALID      : in  std_logic;
         S00_AXI_AWREADY      : out std_logic;
         S00_AXI_WDATA        : in  std_logic_vector(127 downto 0);
         S00_AXI_WSTRB        : in  std_logic_vector(15 downto 0);
         S00_AXI_WLAST        : in  std_logic;
         S00_AXI_WVALID       : in  std_logic;
         S00_AXI_WREADY       : out std_logic;
         S00_AXI_BID          : out std_logic_vector(0 downto 0);
         S00_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S00_AXI_BVALID       : out std_logic;
         S00_AXI_BREADY       : in  std_logic;
         S00_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S00_AXI_ARADDR       : in  std_logic_vector(47 downto 0);
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
         S00_AXI_RDATA        : out std_logic_vector(127 downto 0);
         S00_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S00_AXI_RLAST        : out std_logic;
         S00_AXI_RVALID       : out std_logic;
         S00_AXI_RREADY       : in  std_logic;
         S01_AXI_ARESET_OUT_N : out std_logic;
         S01_AXI_ACLK         : in  std_logic;
         S01_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S01_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S01_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S01_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S01_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S01_AXI_AWLOCK       : in  std_logic;
         S01_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S01_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S01_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S01_AXI_AWVALID      : in  std_logic;
         S01_AXI_AWREADY      : out std_logic;
         S01_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S01_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S01_AXI_WLAST        : in  std_logic;
         S01_AXI_WVALID       : in  std_logic;
         S01_AXI_WREADY       : out std_logic;
         S01_AXI_BID          : out std_logic_vector(0 downto 0);
         S01_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S01_AXI_BVALID       : out std_logic;
         S01_AXI_BREADY       : in  std_logic;
         S01_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S01_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S01_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S01_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S01_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S01_AXI_ARLOCK       : in  std_logic;
         S01_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S01_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S01_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S01_AXI_ARVALID      : in  std_logic;
         S01_AXI_ARREADY      : out std_logic;
         S01_AXI_RID          : out std_logic_vector(0 downto 0);
         S01_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S01_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S01_AXI_RLAST        : out std_logic;
         S01_AXI_RVALID       : out std_logic;
         S01_AXI_RREADY       : in  std_logic;
         S02_AXI_ARESET_OUT_N : out std_logic;
         S02_AXI_ACLK         : in  std_logic;
         S02_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S02_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S02_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S02_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S02_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S02_AXI_AWLOCK       : in  std_logic;
         S02_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S02_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S02_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S02_AXI_AWVALID      : in  std_logic;
         S02_AXI_AWREADY      : out std_logic;
         S02_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S02_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S02_AXI_WLAST        : in  std_logic;
         S02_AXI_WVALID       : in  std_logic;
         S02_AXI_WREADY       : out std_logic;
         S02_AXI_BID          : out std_logic_vector(0 downto 0);
         S02_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S02_AXI_BVALID       : out std_logic;
         S02_AXI_BREADY       : in  std_logic;
         S02_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S02_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S02_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S02_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S02_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S02_AXI_ARLOCK       : in  std_logic;
         S02_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S02_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S02_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S02_AXI_ARVALID      : in  std_logic;
         S02_AXI_ARREADY      : out std_logic;
         S02_AXI_RID          : out std_logic_vector(0 downto 0);
         S02_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S02_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S02_AXI_RLAST        : out std_logic;
         S02_AXI_RVALID       : out std_logic;
         S02_AXI_RREADY       : in  std_logic;
         S03_AXI_ARESET_OUT_N : out std_logic;
         S03_AXI_ACLK         : in  std_logic;
         S03_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S03_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S03_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S03_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S03_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S03_AXI_AWLOCK       : in  std_logic;
         S03_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S03_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S03_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S03_AXI_AWVALID      : in  std_logic;
         S03_AXI_AWREADY      : out std_logic;
         S03_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S03_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S03_AXI_WLAST        : in  std_logic;
         S03_AXI_WVALID       : in  std_logic;
         S03_AXI_WREADY       : out std_logic;
         S03_AXI_BID          : out std_logic_vector(0 downto 0);
         S03_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S03_AXI_BVALID       : out std_logic;
         S03_AXI_BREADY       : in  std_logic;
         S03_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S03_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S03_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S03_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S03_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S03_AXI_ARLOCK       : in  std_logic;
         S03_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S03_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S03_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S03_AXI_ARVALID      : in  std_logic;
         S03_AXI_ARREADY      : out std_logic;
         S03_AXI_RID          : out std_logic_vector(0 downto 0);
         S03_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S03_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S03_AXI_RLAST        : out std_logic;
         S03_AXI_RVALID       : out std_logic;
         S03_AXI_RREADY       : in  std_logic;
         S04_AXI_ARESET_OUT_N : out std_logic;
         S04_AXI_ACLK         : in  std_logic;
         S04_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S04_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S04_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S04_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S04_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S04_AXI_AWLOCK       : in  std_logic;
         S04_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S04_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S04_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S04_AXI_AWVALID      : in  std_logic;
         S04_AXI_AWREADY      : out std_logic;
         S04_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S04_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S04_AXI_WLAST        : in  std_logic;
         S04_AXI_WVALID       : in  std_logic;
         S04_AXI_WREADY       : out std_logic;
         S04_AXI_BID          : out std_logic_vector(0 downto 0);
         S04_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S04_AXI_BVALID       : out std_logic;
         S04_AXI_BREADY       : in  std_logic;
         S04_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S04_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S04_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S04_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S04_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S04_AXI_ARLOCK       : in  std_logic;
         S04_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S04_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S04_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S04_AXI_ARVALID      : in  std_logic;
         S04_AXI_ARREADY      : out std_logic;
         S04_AXI_RID          : out std_logic_vector(0 downto 0);
         S04_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S04_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S04_AXI_RLAST        : out std_logic;
         S04_AXI_RVALID       : out std_logic;
         S04_AXI_RREADY       : in  std_logic;
         S05_AXI_ARESET_OUT_N : out std_logic;
         S05_AXI_ACLK         : in  std_logic;
         S05_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S05_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S05_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S05_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S05_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S05_AXI_AWLOCK       : in  std_logic;
         S05_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S05_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S05_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S05_AXI_AWVALID      : in  std_logic;
         S05_AXI_AWREADY      : out std_logic;
         S05_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S05_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S05_AXI_WLAST        : in  std_logic;
         S05_AXI_WVALID       : in  std_logic;
         S05_AXI_WREADY       : out std_logic;
         S05_AXI_BID          : out std_logic_vector(0 downto 0);
         S05_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S05_AXI_BVALID       : out std_logic;
         S05_AXI_BREADY       : in  std_logic;
         S05_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S05_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S05_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S05_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S05_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S05_AXI_ARLOCK       : in  std_logic;
         S05_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S05_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S05_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S05_AXI_ARVALID      : in  std_logic;
         S05_AXI_ARREADY      : out std_logic;
         S05_AXI_RID          : out std_logic_vector(0 downto 0);
         S05_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S05_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S05_AXI_RLAST        : out std_logic;
         S05_AXI_RVALID       : out std_logic;
         S05_AXI_RREADY       : in  std_logic;
         S06_AXI_ARESET_OUT_N : out std_logic;
         S06_AXI_ACLK         : in  std_logic;
         S06_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S06_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S06_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S06_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S06_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S06_AXI_AWLOCK       : in  std_logic;
         S06_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S06_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S06_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S06_AXI_AWVALID      : in  std_logic;
         S06_AXI_AWREADY      : out std_logic;
         S06_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S06_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S06_AXI_WLAST        : in  std_logic;
         S06_AXI_WVALID       : in  std_logic;
         S06_AXI_WREADY       : out std_logic;
         S06_AXI_BID          : out std_logic_vector(0 downto 0);
         S06_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S06_AXI_BVALID       : out std_logic;
         S06_AXI_BREADY       : in  std_logic;
         S06_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S06_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S06_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S06_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S06_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S06_AXI_ARLOCK       : in  std_logic;
         S06_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S06_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S06_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S06_AXI_ARVALID      : in  std_logic;
         S06_AXI_ARREADY      : out std_logic;
         S06_AXI_RID          : out std_logic_vector(0 downto 0);
         S06_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S06_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S06_AXI_RLAST        : out std_logic;
         S06_AXI_RVALID       : out std_logic;
         S06_AXI_RREADY       : in  std_logic;
         S07_AXI_ARESET_OUT_N : out std_logic;
         S07_AXI_ACLK         : in  std_logic;
         S07_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S07_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S07_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S07_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S07_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S07_AXI_AWLOCK       : in  std_logic;
         S07_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S07_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S07_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S07_AXI_AWVALID      : in  std_logic;
         S07_AXI_AWREADY      : out std_logic;
         S07_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S07_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S07_AXI_WLAST        : in  std_logic;
         S07_AXI_WVALID       : in  std_logic;
         S07_AXI_WREADY       : out std_logic;
         S07_AXI_BID          : out std_logic_vector(0 downto 0);
         S07_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S07_AXI_BVALID       : out std_logic;
         S07_AXI_BREADY       : in  std_logic;
         S07_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S07_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S07_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S07_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S07_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S07_AXI_ARLOCK       : in  std_logic;
         S07_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S07_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S07_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S07_AXI_ARVALID      : in  std_logic;
         S07_AXI_ARREADY      : out std_logic;
         S07_AXI_RID          : out std_logic_vector(0 downto 0);
         S07_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S07_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S07_AXI_RLAST        : out std_logic;
         S07_AXI_RVALID       : out std_logic;
         S07_AXI_RREADY       : in  std_logic;
         S08_AXI_ARESET_OUT_N : out std_logic;
         S08_AXI_ACLK         : in  std_logic;
         S08_AXI_AWID         : in  std_logic_vector(0 downto 0);
         S08_AXI_AWADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S08_AXI_AWLEN        : in  std_logic_vector(7 downto 0);
         S08_AXI_AWSIZE       : in  std_logic_vector(2 downto 0);
         S08_AXI_AWBURST      : in  std_logic_vector(1 downto 0);
         S08_AXI_AWLOCK       : in  std_logic;
         S08_AXI_AWCACHE      : in  std_logic_vector(3 downto 0);
         S08_AXI_AWPROT       : in  std_logic_vector(2 downto 0);
         S08_AXI_AWQOS        : in  std_logic_vector(3 downto 0);
         S08_AXI_AWVALID      : in  std_logic;
         S08_AXI_AWREADY      : out std_logic;
         S08_AXI_WDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S08_AXI_WSTRB        : in  std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S08_AXI_WLAST        : in  std_logic;
         S08_AXI_WVALID       : in  std_logic;
         S08_AXI_WREADY       : out std_logic;
         S08_AXI_BID          : out std_logic_vector(0 downto 0);
         S08_AXI_BRESP        : out std_logic_vector(1 downto 0);
         S08_AXI_BVALID       : out std_logic;
         S08_AXI_BREADY       : in  std_logic;
         S08_AXI_ARID         : in  std_logic_vector(0 downto 0);
         S08_AXI_ARADDR       : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         S08_AXI_ARLEN        : in  std_logic_vector(7 downto 0);
         S08_AXI_ARSIZE       : in  std_logic_vector(2 downto 0);
         S08_AXI_ARBURST      : in  std_logic_vector(1 downto 0);
         S08_AXI_ARLOCK       : in  std_logic;
         S08_AXI_ARCACHE      : in  std_logic_vector(3 downto 0);
         S08_AXI_ARPROT       : in  std_logic_vector(2 downto 0);
         S08_AXI_ARQOS        : in  std_logic_vector(3 downto 0);
         S08_AXI_ARVALID      : in  std_logic;
         S08_AXI_ARREADY      : out std_logic;
         S08_AXI_RID          : out std_logic_vector(0 downto 0);
         S08_AXI_RDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         S08_AXI_RRESP        : out std_logic_vector(1 downto 0);
         S08_AXI_RLAST        : out std_logic;
         S08_AXI_RVALID       : out std_logic;
         S08_AXI_RREADY       : in  std_logic;
         M00_AXI_ARESET_OUT_N : out std_logic;
         M00_AXI_ACLK         : in  std_logic;
         M00_AXI_AWID         : out std_logic_vector(3 downto 0);
         M00_AXI_AWADDR       : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         M00_AXI_AWLEN        : out std_logic_vector(7 downto 0);
         M00_AXI_AWSIZE       : out std_logic_vector(2 downto 0);
         M00_AXI_AWBURST      : out std_logic_vector(1 downto 0);
         M00_AXI_AWLOCK       : out std_logic;
         M00_AXI_AWCACHE      : out std_logic_vector(3 downto 0);
         M00_AXI_AWPROT       : out std_logic_vector(2 downto 0);
         M00_AXI_AWQOS        : out std_logic_vector(3 downto 0);
         M00_AXI_AWVALID      : out std_logic;
         M00_AXI_AWREADY      : in  std_logic;
         M00_AXI_WDATA        : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         M00_AXI_WSTRB        : out std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         M00_AXI_WLAST        : out std_logic;
         M00_AXI_WVALID       : out std_logic;
         M00_AXI_WREADY       : in  std_logic;
         M00_AXI_BID          : in  std_logic_vector(3 downto 0);
         M00_AXI_BRESP        : in  std_logic_vector(1 downto 0);
         M00_AXI_BVALID       : in  std_logic;
         M00_AXI_BREADY       : out std_logic;
         M00_AXI_ARID         : out std_logic_vector(3 downto 0);
         M00_AXI_ARADDR       : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
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
         M00_AXI_RDATA        : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         M00_AXI_RRESP        : in  std_logic_vector(1 downto 0);
         M00_AXI_RLAST        : in  std_logic;
         M00_AXI_RVALID       : in  std_logic;
         M00_AXI_RREADY       : out std_logic);
   end component;

   signal resizeWriteMasters : AxiWriteMasterArray(8 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal resizeWriteSlaves  : AxiWriteSlaveArray(8 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal resizeReadMasters  : AxiReadMasterArray(8 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal resizeReadSlaves   : AxiReadSlaveArray(8 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

   signal axiWriteMasters : AxiWriteMasterArray(8 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(8 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal axiReadMasters  : AxiReadMasterArray(8 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(8 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

   signal axiRstL  : sl;
   signal axiReset : slv(DMA_SIZE_G downto 0);
   
   attribute dont_touch             : string;
   attribute dont_touch of axiReset : signal is "true";      

begin

   axiRstL <= not(axiRst);

   ---------------------
   -- Read Path AXI FIFO
   ---------------------
   U_AxiReadPathFifo : entity work.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         GEN_SYNC_FIFO_G        => true,
         ADDR_LSB_G             => 3,
         ID_FIXED_EN_G          => true,
         SIZE_FIXED_EN_G        => true,
         BURST_FIXED_EN_G       => true,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => true,
         PROT_FIXED_EN_G        => true,
         CACHE_FIXED_EN_G       => true,
         AXI_CONFIG_G           => AXI_DESC_CONFIG_G,
         -- Address channel
         ADDR_BRAM_EN_G         => false,
         ADDR_FIFO_ADDR_WIDTH_G => 4,
         -- Data channel
         DATA_BRAM_EN_G         => false,
         DATA_FIFO_ADDR_WIDTH_G => 4)
      port map (
         sAxiClk        => axiClk,
         sAxiRst        => axiRst,
         sAxiReadMaster => sAxiReadMasters(0),
         sAxiReadSlave  => sAxiReadSlaves(0),
         mAxiClk        => axiClk,
         mAxiRst        => axiRst,
         mAxiReadMaster => axiReadMasters(0),
         mAxiReadSlave  => axiReadSlaves(0));

   ----------------------
   -- Write Path AXI FIFO
   ----------------------
   U_AxiWritePathFifo : entity work.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         GEN_SYNC_FIFO_G          => true,
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => true,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         AXI_CONFIG_G             => AXI_DESC_CONFIG_G,
         -- Address channel
         ADDR_BRAM_EN_G           => true,
         ADDR_FIFO_ADDR_WIDTH_G   => 9,
         -- Data channel
         DATA_BRAM_EN_G           => true,
         DATA_FIFO_ADDR_WIDTH_G   => 9,
         DATA_FIFO_PAUSE_THRESH_G => 456,
         -- Response channel
         RESP_BRAM_EN_G           => false,
         RESP_FIFO_ADDR_WIDTH_G   => 4)
      port map (
         sAxiClk         => axiClk,
         sAxiRst         => axiRst,
         sAxiWriteMaster => sAxiWriteMasters(0),
         sAxiWriteSlave  => sAxiWriteSlaves(0),
         sAxiCtrl        => sAxiWriteCtrl(0),
         mAxiClk         => axiClk,
         mAxiRst         => axiRst,
         mAxiWriteMaster => axiWriteMasters(0),
         mAxiWriteSlave  => axiWriteSlaves(0));

   ----------------------------------------------------------------------   
   -- I have tried to use both the Xilinx IP core -- AXI resizer and the 
   -- SURF AXI Resizer and neither resizer cores with with the Xilinx
   -- AXI-Interconnect IP core or the SURF. I think we have an issue with 
   -- the AxiStreamDmaDescriptor's AXI write generation. We should revisit 
   -- this "bug" in the AxiStreamDmaDescriptor's AXI write generation at 
   -- a later time.  For the time being, we will bypass the resizers for 
   -- the AxiStreamDmaDescriptor's AXI write path (index=0)
   ----------------------------------------------------------------------            

   -- GEN_VEC : for i in DMA_SIZE_G downto 0 generate
   GEN_VEC : for i in DMA_SIZE_G downto 1 generate

      -- Help with timing
      U_AxiRst : entity work.RstPipeline
         generic map (
            TPD_G     => TPD_G,
            INV_RST_G => false)
         port map (
            clk    => axiClk,
            rstIn  => axiRst,
            rstOut => axiReset(i));

      -------------------
      -- AXI Resizer Module
      -------------------   
      U_AxiResize : entity work.AxiResize
         generic map(
            TPD_G               => TPD_G,
            SLAVE_AXI_CONFIG_G  => ite(i = 0, AXI_DESC_CONFIG_G, AXI_DMA_CONFIG_G),
            MASTER_AXI_CONFIG_G => AXI_PCIE_CONFIG_G)
         port map(
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiReset(i),
            -- Slave Port
            sAxiReadMaster  => sAxiReadMasters(i),
            sAxiReadSlave   => sAxiReadSlaves(i),
            sAxiWriteMaster => sAxiWriteMasters(i),
            sAxiWriteSlave  => sAxiWriteSlaves(i),
            -- Master Port
            mAxiReadMaster  => resizeReadMasters(i),
            mAxiReadSlave   => resizeReadSlaves(i),
            mAxiWriteMaster => resizeWriteMasters(i),
            mAxiWriteSlave  => resizeWriteSlaves(i));

      ---------------------
      -- Read Path AXI FIFO
      ---------------------
      U_AxiReadPathFifo : entity work.AxiReadPathFifo
         generic map (
            TPD_G                  => TPD_G,
            GEN_SYNC_FIFO_G        => true,
            ADDR_LSB_G             => 3,
            ID_FIXED_EN_G          => true,
            SIZE_FIXED_EN_G        => true,
            BURST_FIXED_EN_G       => true,
            LEN_FIXED_EN_G         => false,
            LOCK_FIXED_EN_G        => true,
            PROT_FIXED_EN_G        => true,
            CACHE_FIXED_EN_G       => true,
            AXI_CONFIG_G           => AXI_PCIE_CONFIG_G,
            -- Address channel
            ADDR_BRAM_EN_G         => false,
            ADDR_FIFO_ADDR_WIDTH_G => 4,
            -- Data channel
            DATA_BRAM_EN_G         => false,
            DATA_FIFO_ADDR_WIDTH_G => 4)
         port map (
            sAxiClk        => axiClk,
            sAxiRst        => axiReset(i),
            sAxiReadMaster => resizeReadMasters(i),
            sAxiReadSlave  => resizeReadSlaves(i),
            mAxiClk        => axiClk,
            mAxiRst        => axiReset(i),
            mAxiReadMaster => axiReadMasters(i),
            mAxiReadSlave  => axiReadSlaves(i));

      ----------------------
      -- Write Path AXI FIFO
      ----------------------
      U_AxiWritePathFifo : entity work.AxiWritePathFifo
         generic map (
            TPD_G                    => TPD_G,
            GEN_SYNC_FIFO_G          => true,
            ADDR_LSB_G               => 3,
            ID_FIXED_EN_G            => true,
            SIZE_FIXED_EN_G          => true,
            BURST_FIXED_EN_G         => true,
            LEN_FIXED_EN_G           => false,
            LOCK_FIXED_EN_G          => true,
            PROT_FIXED_EN_G          => true,
            CACHE_FIXED_EN_G         => true,
            AXI_CONFIG_G             => AXI_PCIE_CONFIG_G,
            -- Address channel
            ADDR_BRAM_EN_G           => true,
            ADDR_FIFO_ADDR_WIDTH_G   => 9,
            -- Data channel
            DATA_BRAM_EN_G           => true,
            DATA_FIFO_ADDR_WIDTH_G   => 9,
            DATA_FIFO_PAUSE_THRESH_G => 456,
            -- Response channel
            RESP_BRAM_EN_G           => false,
            RESP_FIFO_ADDR_WIDTH_G   => 4)
         port map (
            sAxiClk         => axiClk,
            sAxiRst         => axiReset(i),
            sAxiWriteMaster => resizeWriteMasters(i),
            sAxiWriteSlave  => resizeWriteSlaves(i),
            sAxiCtrl        => sAxiWriteCtrl(i),
            mAxiClk         => axiClk,
            mAxiRst         => axiReset(i),
            mAxiWriteMaster => axiWriteMasters(i),
            mAxiWriteSlave  => axiWriteSlaves(i));

   end generate;

   ----------------------------------------------------------------------
   -- I have tried the SURF AXI Read/Write Path MUX/DEMUX. But doesn't 
   -- appear to work.  I have reverted back to using the AXI-Interconnect 
   -- IP core. We should revisit this "bug" in "SURF AXI Read/Write Path 
   -- MUX/DEMUX" at a later time.  I am only using this path for the 
   -- Artix-7 PCIe build (hardware/SlacPciePgpCardG3)
   ----------------------------------------------------------------------
   BPY_IP_CORE : if (USE_XBAR_IPCORE_G = false) generate
      --------------------
      -- AXI Read Path MUX
      --------------------
      U_AxiReadPathMux : entity work.AxiReadPathMux
         generic map (
            TPD_G        => TPD_G,
            NUM_SLAVES_G => (DMA_SIZE_G+1))
         port map (
            -- Clock and reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slaves
            sAxiReadMasters => axiReadMasters(DMA_SIZE_G downto 0),
            sAxiReadSlaves  => axiReadSlaves(DMA_SIZE_G downto 0),
            -- Master
            mAxiReadMaster  => mAxiReadMaster,
            mAxiReadSlave   => mAxiReadSlave);

      -----------------------
      -- AXI Write Path DEMUX
      -----------------------
      U_AxiWritePathMux : entity work.AxiWritePathMux
         generic map (
            TPD_G        => TPD_G,
            NUM_SLAVES_G => (DMA_SIZE_G+1))
         port map (
            -- Clock and reset
            axiClk           => axiClk,
            axiRst           => axiRst,
            -- Slaves
            sAxiWriteMasters => axiWriteMasters(DMA_SIZE_G downto 0),
            sAxiWriteSlaves  => axiWriteSlaves(DMA_SIZE_G downto 0),
            -- Master
            mAxiWriteMaster  => mAxiWriteMaster,
            mAxiWriteSlave   => mAxiWriteSlave);
   end generate;

   -------------------
   -- AXI PCIe IP Core
   -------------------
   GEN_IP_CORE : if (USE_XBAR_IPCORE_G = true) generate
      U_AxiCrossbar : AxiPcieCrossbarIpCore
         port map (
            INTERCONNECT_ACLK    => axiClk,
            INTERCONNECT_ARESETN => axiRstL,
            -- SLAVE[0]
            S00_AXI_ARESET_OUT_N => open,
            S00_AXI_ACLK         => axiClk,
            S00_AXI_AWID(0)      => '0',
            S00_AXI_AWADDR       => axiWriteMasters(0).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S00_AXI_AWLEN        => axiWriteMasters(0).awlen,
            S00_AXI_AWSIZE       => axiWriteMasters(0).awsize,
            S00_AXI_AWBURST      => axiWriteMasters(0).awburst,
            S00_AXI_AWLOCK       => axiWriteMasters(0).awlock(0),
            S00_AXI_AWCACHE      => axiWriteMasters(0).awcache,
            S00_AXI_AWPROT       => axiWriteMasters(0).awprot,
            S00_AXI_AWQOS        => axiWriteMasters(0).awqos,
            S00_AXI_AWVALID      => axiWriteMasters(0).awvalid,
            S00_AXI_AWREADY      => axiWriteSlaves(0).awready,
            S00_AXI_WDATA        => axiWriteMasters(0).wdata(127 downto 0),
            S00_AXI_WSTRB        => axiWriteMasters(0).wstrb(15 downto 0),
            S00_AXI_WLAST        => axiWriteMasters(0).wlast,
            S00_AXI_WVALID       => axiWriteMasters(0).wvalid,
            S00_AXI_WREADY       => axiWriteSlaves(0).wready,
            S00_AXI_BID          => axiWriteSlaves(0).bid(0 downto 0),
            S00_AXI_BRESP        => axiWriteSlaves(0).bresp,
            S00_AXI_BVALID       => axiWriteSlaves(0).bvalid,
            S00_AXI_BREADY       => axiWriteMasters(0).bready,
            S00_AXI_ARID(0)      => '0',
            S00_AXI_ARADDR       => axiReadMasters(0).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S00_AXI_ARLEN        => axiReadMasters(0).arlen,
            S00_AXI_ARSIZE       => axiReadMasters(0).arsize,
            S00_AXI_ARBURST      => axiReadMasters(0).arburst,
            S00_AXI_ARLOCK       => axiReadMasters(0).arlock(0),
            S00_AXI_ARCACHE      => axiReadMasters(0).arcache,
            S00_AXI_ARPROT       => axiReadMasters(0).arprot,
            S00_AXI_ARQOS        => axiReadMasters(0).arqos,
            S00_AXI_ARVALID      => axiReadMasters(0).arvalid,
            S00_AXI_ARREADY      => axiReadSlaves(0).arready,
            S00_AXI_RID          => axiReadSlaves(0).rid(0 downto 0),
            S00_AXI_RDATA        => axiReadSlaves(0).rdata(127 downto 0),
            S00_AXI_RRESP        => axiReadSlaves(0).rresp,
            S00_AXI_RLAST        => axiReadSlaves(0).rlast,
            S00_AXI_RVALID       => axiReadSlaves(0).rvalid,
            S00_AXI_RREADY       => axiReadMasters(0).rready,
            -- SLAVE[1]
            S01_AXI_ARESET_OUT_N => open,
            S01_AXI_ACLK         => axiClk,
            S01_AXI_AWID(0)      => '0',
            S01_AXI_AWADDR       => axiWriteMasters(1).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S01_AXI_AWLEN        => axiWriteMasters(1).awlen,
            S01_AXI_AWSIZE       => axiWriteMasters(1).awsize,
            S01_AXI_AWBURST      => axiWriteMasters(1).awburst,
            S01_AXI_AWLOCK       => axiWriteMasters(1).awlock(0),
            S01_AXI_AWCACHE      => axiWriteMasters(1).awcache,
            S01_AXI_AWPROT       => axiWriteMasters(1).awprot,
            S01_AXI_AWQOS        => axiWriteMasters(1).awqos,
            S01_AXI_AWVALID      => axiWriteMasters(1).awvalid,
            S01_AXI_AWREADY      => axiWriteSlaves(1).awready,
            S01_AXI_WDATA        => axiWriteMasters(1).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S01_AXI_WSTRB        => axiWriteMasters(1).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S01_AXI_WLAST        => axiWriteMasters(1).wlast,
            S01_AXI_WVALID       => axiWriteMasters(1).wvalid,
            S01_AXI_WREADY       => axiWriteSlaves(1).wready,
            S01_AXI_BID          => axiWriteSlaves(1).bid(0 downto 0),
            S01_AXI_BRESP        => axiWriteSlaves(1).bresp,
            S01_AXI_BVALID       => axiWriteSlaves(1).bvalid,
            S01_AXI_BREADY       => axiWriteMasters(1).bready,
            S01_AXI_ARID(0)      => '0',
            S01_AXI_ARADDR       => axiReadMasters(1).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S01_AXI_ARLEN        => axiReadMasters(1).arlen,
            S01_AXI_ARSIZE       => axiReadMasters(1).arsize,
            S01_AXI_ARBURST      => axiReadMasters(1).arburst,
            S01_AXI_ARLOCK       => axiReadMasters(1).arlock(0),
            S01_AXI_ARCACHE      => axiReadMasters(1).arcache,
            S01_AXI_ARPROT       => axiReadMasters(1).arprot,
            S01_AXI_ARQOS        => axiReadMasters(1).arqos,
            S01_AXI_ARVALID      => axiReadMasters(1).arvalid,
            S01_AXI_ARREADY      => axiReadSlaves(1).arready,
            S01_AXI_RID          => axiReadSlaves(1).rid(0 downto 0),
            S01_AXI_RDATA        => axiReadSlaves(1).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S01_AXI_RRESP        => axiReadSlaves(1).rresp,
            S01_AXI_RLAST        => axiReadSlaves(1).rlast,
            S01_AXI_RVALID       => axiReadSlaves(1).rvalid,
            S01_AXI_RREADY       => axiReadMasters(1).rready,
            -- SLAVE[2]
            S02_AXI_ARESET_OUT_N => open,
            S02_AXI_ACLK         => axiClk,
            S02_AXI_AWID(0)      => '0',
            S02_AXI_AWADDR       => axiWriteMasters(2).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S02_AXI_AWLEN        => axiWriteMasters(2).awlen,
            S02_AXI_AWSIZE       => axiWriteMasters(2).awsize,
            S02_AXI_AWBURST      => axiWriteMasters(2).awburst,
            S02_AXI_AWLOCK       => axiWriteMasters(2).awlock(0),
            S02_AXI_AWCACHE      => axiWriteMasters(2).awcache,
            S02_AXI_AWPROT       => axiWriteMasters(2).awprot,
            S02_AXI_AWQOS        => axiWriteMasters(2).awqos,
            S02_AXI_AWVALID      => axiWriteMasters(2).awvalid,
            S02_AXI_AWREADY      => axiWriteSlaves(2).awready,
            S02_AXI_WDATA        => axiWriteMasters(2).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S02_AXI_WSTRB        => axiWriteMasters(2).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S02_AXI_WLAST        => axiWriteMasters(2).wlast,
            S02_AXI_WVALID       => axiWriteMasters(2).wvalid,
            S02_AXI_WREADY       => axiWriteSlaves(2).wready,
            S02_AXI_BID          => axiWriteSlaves(2).bid(0 downto 0),
            S02_AXI_BRESP        => axiWriteSlaves(2).bresp,
            S02_AXI_BVALID       => axiWriteSlaves(2).bvalid,
            S02_AXI_BREADY       => axiWriteMasters(2).bready,
            S02_AXI_ARID(0)      => '0',
            S02_AXI_ARADDR       => axiReadMasters(2).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S02_AXI_ARLEN        => axiReadMasters(2).arlen,
            S02_AXI_ARSIZE       => axiReadMasters(2).arsize,
            S02_AXI_ARBURST      => axiReadMasters(2).arburst,
            S02_AXI_ARLOCK       => axiReadMasters(2).arlock(0),
            S02_AXI_ARCACHE      => axiReadMasters(2).arcache,
            S02_AXI_ARPROT       => axiReadMasters(2).arprot,
            S02_AXI_ARQOS        => axiReadMasters(2).arqos,
            S02_AXI_ARVALID      => axiReadMasters(2).arvalid,
            S02_AXI_ARREADY      => axiReadSlaves(2).arready,
            S02_AXI_RID          => axiReadSlaves(2).rid(0 downto 0),
            S02_AXI_RDATA        => axiReadSlaves(2).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S02_AXI_RRESP        => axiReadSlaves(2).rresp,
            S02_AXI_RLAST        => axiReadSlaves(2).rlast,
            S02_AXI_RVALID       => axiReadSlaves(2).rvalid,
            S02_AXI_RREADY       => axiReadMasters(2).rready,
            -- SLAVE[3]
            S03_AXI_ARESET_OUT_N => open,
            S03_AXI_ACLK         => axiClk,
            S03_AXI_AWID(0)      => '0',
            S03_AXI_AWADDR       => axiWriteMasters(3).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S03_AXI_AWLEN        => axiWriteMasters(3).awlen,
            S03_AXI_AWSIZE       => axiWriteMasters(3).awsize,
            S03_AXI_AWBURST      => axiWriteMasters(3).awburst,
            S03_AXI_AWLOCK       => axiWriteMasters(3).awlock(0),
            S03_AXI_AWCACHE      => axiWriteMasters(3).awcache,
            S03_AXI_AWPROT       => axiWriteMasters(3).awprot,
            S03_AXI_AWQOS        => axiWriteMasters(3).awqos,
            S03_AXI_AWVALID      => axiWriteMasters(3).awvalid,
            S03_AXI_AWREADY      => axiWriteSlaves(3).awready,
            S03_AXI_WDATA        => axiWriteMasters(3).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S03_AXI_WSTRB        => axiWriteMasters(3).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S03_AXI_WLAST        => axiWriteMasters(3).wlast,
            S03_AXI_WVALID       => axiWriteMasters(3).wvalid,
            S03_AXI_WREADY       => axiWriteSlaves(3).wready,
            S03_AXI_BID          => axiWriteSlaves(3).bid(0 downto 0),
            S03_AXI_BRESP        => axiWriteSlaves(3).bresp,
            S03_AXI_BVALID       => axiWriteSlaves(3).bvalid,
            S03_AXI_BREADY       => axiWriteMasters(3).bready,
            S03_AXI_ARID(0)      => '0',
            S03_AXI_ARADDR       => axiReadMasters(3).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S03_AXI_ARLEN        => axiReadMasters(3).arlen,
            S03_AXI_ARSIZE       => axiReadMasters(3).arsize,
            S03_AXI_ARBURST      => axiReadMasters(3).arburst,
            S03_AXI_ARLOCK       => axiReadMasters(3).arlock(0),
            S03_AXI_ARCACHE      => axiReadMasters(3).arcache,
            S03_AXI_ARPROT       => axiReadMasters(3).arprot,
            S03_AXI_ARQOS        => axiReadMasters(3).arqos,
            S03_AXI_ARVALID      => axiReadMasters(3).arvalid,
            S03_AXI_ARREADY      => axiReadSlaves(3).arready,
            S03_AXI_RID          => axiReadSlaves(3).rid(0 downto 0),
            S03_AXI_RDATA        => axiReadSlaves(3).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S03_AXI_RRESP        => axiReadSlaves(3).rresp,
            S03_AXI_RLAST        => axiReadSlaves(3).rlast,
            S03_AXI_RVALID       => axiReadSlaves(3).rvalid,
            S03_AXI_RREADY       => axiReadMasters(3).rready,
            -- SLAVE[4]
            S04_AXI_ARESET_OUT_N => open,
            S04_AXI_ACLK         => axiClk,
            S04_AXI_AWID(0)      => '0',
            S04_AXI_AWADDR       => axiWriteMasters(4).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S04_AXI_AWLEN        => axiWriteMasters(4).awlen,
            S04_AXI_AWSIZE       => axiWriteMasters(4).awsize,
            S04_AXI_AWBURST      => axiWriteMasters(4).awburst,
            S04_AXI_AWLOCK       => axiWriteMasters(4).awlock(0),
            S04_AXI_AWCACHE      => axiWriteMasters(4).awcache,
            S04_AXI_AWPROT       => axiWriteMasters(4).awprot,
            S04_AXI_AWQOS        => axiWriteMasters(4).awqos,
            S04_AXI_AWVALID      => axiWriteMasters(4).awvalid,
            S04_AXI_AWREADY      => axiWriteSlaves(4).awready,
            S04_AXI_WDATA        => axiWriteMasters(4).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S04_AXI_WSTRB        => axiWriteMasters(4).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S04_AXI_WLAST        => axiWriteMasters(4).wlast,
            S04_AXI_WVALID       => axiWriteMasters(4).wvalid,
            S04_AXI_WREADY       => axiWriteSlaves(4).wready,
            S04_AXI_BID          => axiWriteSlaves(4).bid(0 downto 0),
            S04_AXI_BRESP        => axiWriteSlaves(4).bresp,
            S04_AXI_BVALID       => axiWriteSlaves(4).bvalid,
            S04_AXI_BREADY       => axiWriteMasters(4).bready,
            S04_AXI_ARID(0)      => '0',
            S04_AXI_ARADDR       => axiReadMasters(4).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S04_AXI_ARLEN        => axiReadMasters(4).arlen,
            S04_AXI_ARSIZE       => axiReadMasters(4).arsize,
            S04_AXI_ARBURST      => axiReadMasters(4).arburst,
            S04_AXI_ARLOCK       => axiReadMasters(4).arlock(0),
            S04_AXI_ARCACHE      => axiReadMasters(4).arcache,
            S04_AXI_ARPROT       => axiReadMasters(4).arprot,
            S04_AXI_ARQOS        => axiReadMasters(4).arqos,
            S04_AXI_ARVALID      => axiReadMasters(4).arvalid,
            S04_AXI_ARREADY      => axiReadSlaves(4).arready,
            S04_AXI_RID          => axiReadSlaves(4).rid(0 downto 0),
            S04_AXI_RDATA        => axiReadSlaves(4).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S04_AXI_RRESP        => axiReadSlaves(4).rresp,
            S04_AXI_RLAST        => axiReadSlaves(4).rlast,
            S04_AXI_RVALID       => axiReadSlaves(4).rvalid,
            S04_AXI_RREADY       => axiReadMasters(4).rready,
            -- SLAVE[5]
            S05_AXI_ARESET_OUT_N => open,
            S05_AXI_ACLK         => axiClk,
            S05_AXI_AWID(0)      => '0',
            S05_AXI_AWADDR       => axiWriteMasters(5).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S05_AXI_AWLEN        => axiWriteMasters(5).awlen,
            S05_AXI_AWSIZE       => axiWriteMasters(5).awsize,
            S05_AXI_AWBURST      => axiWriteMasters(5).awburst,
            S05_AXI_AWLOCK       => axiWriteMasters(5).awlock(0),
            S05_AXI_AWCACHE      => axiWriteMasters(5).awcache,
            S05_AXI_AWPROT       => axiWriteMasters(5).awprot,
            S05_AXI_AWQOS        => axiWriteMasters(5).awqos,
            S05_AXI_AWVALID      => axiWriteMasters(5).awvalid,
            S05_AXI_AWREADY      => axiWriteSlaves(5).awready,
            S05_AXI_WDATA        => axiWriteMasters(5).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S05_AXI_WSTRB        => axiWriteMasters(5).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S05_AXI_WLAST        => axiWriteMasters(5).wlast,
            S05_AXI_WVALID       => axiWriteMasters(5).wvalid,
            S05_AXI_WREADY       => axiWriteSlaves(5).wready,
            S05_AXI_BID          => axiWriteSlaves(5).bid(0 downto 0),
            S05_AXI_BRESP        => axiWriteSlaves(5).bresp,
            S05_AXI_BVALID       => axiWriteSlaves(5).bvalid,
            S05_AXI_BREADY       => axiWriteMasters(5).bready,
            S05_AXI_ARID(0)      => '0',
            S05_AXI_ARADDR       => axiReadMasters(5).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S05_AXI_ARLEN        => axiReadMasters(5).arlen,
            S05_AXI_ARSIZE       => axiReadMasters(5).arsize,
            S05_AXI_ARBURST      => axiReadMasters(5).arburst,
            S05_AXI_ARLOCK       => axiReadMasters(5).arlock(0),
            S05_AXI_ARCACHE      => axiReadMasters(5).arcache,
            S05_AXI_ARPROT       => axiReadMasters(5).arprot,
            S05_AXI_ARQOS        => axiReadMasters(5).arqos,
            S05_AXI_ARVALID      => axiReadMasters(5).arvalid,
            S05_AXI_ARREADY      => axiReadSlaves(5).arready,
            S05_AXI_RID          => axiReadSlaves(5).rid(0 downto 0),
            S05_AXI_RDATA        => axiReadSlaves(5).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S05_AXI_RRESP        => axiReadSlaves(5).rresp,
            S05_AXI_RLAST        => axiReadSlaves(5).rlast,
            S05_AXI_RVALID       => axiReadSlaves(5).rvalid,
            S05_AXI_RREADY       => axiReadMasters(5).rready,
            -- SLAVE[6]
            S06_AXI_ARESET_OUT_N => open,
            S06_AXI_ACLK         => axiClk,
            S06_AXI_AWID(0)      => '0',
            S06_AXI_AWADDR       => axiWriteMasters(6).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S06_AXI_AWLEN        => axiWriteMasters(6).awlen,
            S06_AXI_AWSIZE       => axiWriteMasters(6).awsize,
            S06_AXI_AWBURST      => axiWriteMasters(6).awburst,
            S06_AXI_AWLOCK       => axiWriteMasters(6).awlock(0),
            S06_AXI_AWCACHE      => axiWriteMasters(6).awcache,
            S06_AXI_AWPROT       => axiWriteMasters(6).awprot,
            S06_AXI_AWQOS        => axiWriteMasters(6).awqos,
            S06_AXI_AWVALID      => axiWriteMasters(6).awvalid,
            S06_AXI_AWREADY      => axiWriteSlaves(6).awready,
            S06_AXI_WDATA        => axiWriteMasters(6).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S06_AXI_WSTRB        => axiWriteMasters(6).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S06_AXI_WLAST        => axiWriteMasters(6).wlast,
            S06_AXI_WVALID       => axiWriteMasters(6).wvalid,
            S06_AXI_WREADY       => axiWriteSlaves(6).wready,
            S06_AXI_BID          => axiWriteSlaves(6).bid(0 downto 0),
            S06_AXI_BRESP        => axiWriteSlaves(6).bresp,
            S06_AXI_BVALID       => axiWriteSlaves(6).bvalid,
            S06_AXI_BREADY       => axiWriteMasters(6).bready,
            S06_AXI_ARID(0)      => '0',
            S06_AXI_ARADDR       => axiReadMasters(6).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S06_AXI_ARLEN        => axiReadMasters(6).arlen,
            S06_AXI_ARSIZE       => axiReadMasters(6).arsize,
            S06_AXI_ARBURST      => axiReadMasters(6).arburst,
            S06_AXI_ARLOCK       => axiReadMasters(6).arlock(0),
            S06_AXI_ARCACHE      => axiReadMasters(6).arcache,
            S06_AXI_ARPROT       => axiReadMasters(6).arprot,
            S06_AXI_ARQOS        => axiReadMasters(6).arqos,
            S06_AXI_ARVALID      => axiReadMasters(6).arvalid,
            S06_AXI_ARREADY      => axiReadSlaves(6).arready,
            S06_AXI_RID          => axiReadSlaves(6).rid(0 downto 0),
            S06_AXI_RDATA        => axiReadSlaves(6).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S06_AXI_RRESP        => axiReadSlaves(6).rresp,
            S06_AXI_RLAST        => axiReadSlaves(6).rlast,
            S06_AXI_RVALID       => axiReadSlaves(6).rvalid,
            S06_AXI_RREADY       => axiReadMasters(6).rready,
            -- SLAVE[7]
            S07_AXI_ARESET_OUT_N => open,
            S07_AXI_ACLK         => axiClk,
            S07_AXI_AWID(0)      => '0',
            S07_AXI_AWADDR       => axiWriteMasters(7).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S07_AXI_AWLEN        => axiWriteMasters(7).awlen,
            S07_AXI_AWSIZE       => axiWriteMasters(7).awsize,
            S07_AXI_AWBURST      => axiWriteMasters(7).awburst,
            S07_AXI_AWLOCK       => axiWriteMasters(7).awlock(0),
            S07_AXI_AWCACHE      => axiWriteMasters(7).awcache,
            S07_AXI_AWPROT       => axiWriteMasters(7).awprot,
            S07_AXI_AWQOS        => axiWriteMasters(7).awqos,
            S07_AXI_AWVALID      => axiWriteMasters(7).awvalid,
            S07_AXI_AWREADY      => axiWriteSlaves(7).awready,
            S07_AXI_WDATA        => axiWriteMasters(7).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S07_AXI_WSTRB        => axiWriteMasters(7).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S07_AXI_WLAST        => axiWriteMasters(7).wlast,
            S07_AXI_WVALID       => axiWriteMasters(7).wvalid,
            S07_AXI_WREADY       => axiWriteSlaves(7).wready,
            S07_AXI_BID          => axiWriteSlaves(7).bid(0 downto 0),
            S07_AXI_BRESP        => axiWriteSlaves(7).bresp,
            S07_AXI_BVALID       => axiWriteSlaves(7).bvalid,
            S07_AXI_BREADY       => axiWriteMasters(7).bready,
            S07_AXI_ARID(0)      => '0',
            S07_AXI_ARADDR       => axiReadMasters(7).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S07_AXI_ARLEN        => axiReadMasters(7).arlen,
            S07_AXI_ARSIZE       => axiReadMasters(7).arsize,
            S07_AXI_ARBURST      => axiReadMasters(7).arburst,
            S07_AXI_ARLOCK       => axiReadMasters(7).arlock(0),
            S07_AXI_ARCACHE      => axiReadMasters(7).arcache,
            S07_AXI_ARPROT       => axiReadMasters(7).arprot,
            S07_AXI_ARQOS        => axiReadMasters(7).arqos,
            S07_AXI_ARVALID      => axiReadMasters(7).arvalid,
            S07_AXI_ARREADY      => axiReadSlaves(7).arready,
            S07_AXI_RID          => axiReadSlaves(7).rid(0 downto 0),
            S07_AXI_RDATA        => axiReadSlaves(7).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S07_AXI_RRESP        => axiReadSlaves(7).rresp,
            S07_AXI_RLAST        => axiReadSlaves(7).rlast,
            S07_AXI_RVALID       => axiReadSlaves(7).rvalid,
            S07_AXI_RREADY       => axiReadMasters(7).rready,
            -- SLAVE[8]
            S08_AXI_ARESET_OUT_N => open,
            S08_AXI_ACLK         => axiClk,
            S08_AXI_AWID(0)      => '0',
            S08_AXI_AWADDR       => axiWriteMasters(8).awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S08_AXI_AWLEN        => axiWriteMasters(8).awlen,
            S08_AXI_AWSIZE       => axiWriteMasters(8).awsize,
            S08_AXI_AWBURST      => axiWriteMasters(8).awburst,
            S08_AXI_AWLOCK       => axiWriteMasters(8).awlock(0),
            S08_AXI_AWCACHE      => axiWriteMasters(8).awcache,
            S08_AXI_AWPROT       => axiWriteMasters(8).awprot,
            S08_AXI_AWQOS        => axiWriteMasters(8).awqos,
            S08_AXI_AWVALID      => axiWriteMasters(8).awvalid,
            S08_AXI_AWREADY      => axiWriteSlaves(8).awready,
            S08_AXI_WDATA        => axiWriteMasters(8).wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S08_AXI_WSTRB        => axiWriteMasters(8).wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S08_AXI_WLAST        => axiWriteMasters(8).wlast,
            S08_AXI_WVALID       => axiWriteMasters(8).wvalid,
            S08_AXI_WREADY       => axiWriteSlaves(8).wready,
            S08_AXI_BID          => axiWriteSlaves(8).bid(0 downto 0),
            S08_AXI_BRESP        => axiWriteSlaves(8).bresp,
            S08_AXI_BVALID       => axiWriteSlaves(8).bvalid,
            S08_AXI_BREADY       => axiWriteMasters(8).bready,
            S08_AXI_ARID(0)      => '0',
            S08_AXI_ARADDR       => axiReadMasters(8).araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            S08_AXI_ARLEN        => axiReadMasters(8).arlen,
            S08_AXI_ARSIZE       => axiReadMasters(8).arsize,
            S08_AXI_ARBURST      => axiReadMasters(8).arburst,
            S08_AXI_ARLOCK       => axiReadMasters(8).arlock(0),
            S08_AXI_ARCACHE      => axiReadMasters(8).arcache,
            S08_AXI_ARPROT       => axiReadMasters(8).arprot,
            S08_AXI_ARQOS        => axiReadMasters(8).arqos,
            S08_AXI_ARVALID      => axiReadMasters(8).arvalid,
            S08_AXI_ARREADY      => axiReadSlaves(8).arready,
            S08_AXI_RID          => axiReadSlaves(8).rid(0 downto 0),
            S08_AXI_RDATA        => axiReadSlaves(8).rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            S08_AXI_RRESP        => axiReadSlaves(8).rresp,
            S08_AXI_RLAST        => axiReadSlaves(8).rlast,
            S08_AXI_RVALID       => axiReadSlaves(8).rvalid,
            S08_AXI_RREADY       => axiReadMasters(8).rready,
            -- MASTER         
            M00_AXI_ARESET_OUT_N => open,
            M00_AXI_ACLK         => axiClk,
            M00_AXI_AWID         => mAxiWriteMaster.awid(3 downto 0),
            M00_AXI_AWADDR       => mAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            M00_AXI_AWLEN        => mAxiWriteMaster.awlen,
            M00_AXI_AWSIZE       => mAxiWriteMaster.awsize,
            M00_AXI_AWBURST      => mAxiWriteMaster.awburst,
            M00_AXI_AWLOCK       => mAxiWriteMaster.awlock(0),
            M00_AXI_AWCACHE      => mAxiWriteMaster.awcache,
            M00_AXI_AWPROT       => mAxiWriteMaster.awprot,
            M00_AXI_AWQOS        => mAxiWriteMaster.awqos,
            M00_AXI_AWVALID      => mAxiWriteMaster.awvalid,
            M00_AXI_AWREADY      => mAxiWriteSlave.awready,
            M00_AXI_WDATA        => mAxiWriteMaster.wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            M00_AXI_WSTRB        => mAxiWriteMaster.wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            M00_AXI_WLAST        => mAxiWriteMaster.wlast,
            M00_AXI_WVALID       => mAxiWriteMaster.wvalid,
            M00_AXI_WREADY       => mAxiWriteSlave.wready,
            M00_AXI_BID          => mAxiWriteSlave.bid(3 downto 0),
            M00_AXI_BRESP        => mAxiWriteSlave.bresp,
            M00_AXI_BVALID       => mAxiWriteSlave.bvalid,
            M00_AXI_BREADY       => mAxiWriteMaster.bready,
            M00_AXI_ARID         => mAxiReadMaster.arid(3 downto 0),
            M00_AXI_ARADDR       => mAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
            M00_AXI_ARLEN        => mAxiReadMaster.arlen,
            M00_AXI_ARSIZE       => mAxiReadMaster.arsize,
            M00_AXI_ARBURST      => mAxiReadMaster.arburst,
            M00_AXI_ARLOCK       => mAxiReadMaster.arlock(0),
            M00_AXI_ARCACHE      => mAxiReadMaster.arcache,
            M00_AXI_ARPROT       => mAxiReadMaster.arprot,
            M00_AXI_ARQOS        => mAxiReadMaster.arqos,
            M00_AXI_ARVALID      => mAxiReadMaster.arvalid,
            M00_AXI_ARREADY      => mAxiReadSlave.arready,
            M00_AXI_RID          => mAxiReadSlave.rid(3 downto 0),
            M00_AXI_RDATA        => mAxiReadSlave.rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
            M00_AXI_RRESP        => mAxiReadSlave.rresp,
            M00_AXI_RLAST        => mAxiReadSlave.rlast,
            M00_AXI_RVALID       => mAxiReadSlave.rvalid,
            M00_AXI_RREADY       => mAxiReadMaster.rready);
   end generate;

end mapping;
