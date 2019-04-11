-------------------------------------------------------------------------------
-- File       : AxiPcie64BResize.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI Data Width 16B converter
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

entity AxiPcie64BResize is
   generic (
      TPD_G             : time := 1 ns;
      AXI_DMA_CONFIG_G  : AxiConfigType;
      AXI_PCIE_CONFIG_G : AxiConfigType);
   port (
      -- Clock and Reset
      axiClk          : in  sl;
      axiRst          : in  sl;
      -- Slaves
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      sAxiReadMaster  : in  AxiReadMasterType;
      sAxiReadSlave   : out AxiReadSlaveType;
      -- Master
      mAxiWriteMaster : out AxiWriteMasterType;
      mAxiWriteSlave  : in  AxiWriteSlaveType;
      mAxiReadMaster  : out AxiReadMasterType;
      mAxiReadSlave   : in  AxiReadSlaveType);
end AxiPcie64BResize;

architecture mapping of AxiPcie64BResize is

   constant RESIZE_C : boolean := (AXI_DMA_CONFIG_G.DATA_BYTES_C /= 64);

   component AxiPcie64BResize8BCore
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awaddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(8*8-1 downto 0);
         s_axi_wstrb    : in  std_logic_vector(8-1 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_araddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rdata    : out std_logic_vector(8*8-1 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_awlen    : out std_logic_vector(7 downto 0);
         m_axi_awsize   : out std_logic_vector(2 downto 0);
         m_axi_awburst  : out std_logic_vector(1 downto 0);
         m_axi_awlock   : out std_logic_vector(0 downto 0);
         m_axi_awcache  : out std_logic_vector(3 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awregion : out std_logic_vector(3 downto 0);
         m_axi_awqos    : out std_logic_vector(3 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wstrb    : out std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_araddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_arlen    : out std_logic_vector(7 downto 0);
         m_axi_arsize   : out std_logic_vector(2 downto 0);
         m_axi_arburst  : out std_logic_vector(1 downto 0);
         m_axi_arlock   : out std_logic_vector(0 downto 0);
         m_axi_arcache  : out std_logic_vector(3 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arregion : out std_logic_vector(3 downto 0);
         m_axi_arqos    : out std_logic_vector(3 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic);
   end component;

   component AxiPcie64BResize16BCore
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awaddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(8*16-1 downto 0);
         s_axi_wstrb    : in  std_logic_vector(16-1 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_araddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rdata    : out std_logic_vector(8*16-1 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_awlen    : out std_logic_vector(7 downto 0);
         m_axi_awsize   : out std_logic_vector(2 downto 0);
         m_axi_awburst  : out std_logic_vector(1 downto 0);
         m_axi_awlock   : out std_logic_vector(0 downto 0);
         m_axi_awcache  : out std_logic_vector(3 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awregion : out std_logic_vector(3 downto 0);
         m_axi_awqos    : out std_logic_vector(3 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wstrb    : out std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_araddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_arlen    : out std_logic_vector(7 downto 0);
         m_axi_arsize   : out std_logic_vector(2 downto 0);
         m_axi_arburst  : out std_logic_vector(1 downto 0);
         m_axi_arlock   : out std_logic_vector(0 downto 0);
         m_axi_arcache  : out std_logic_vector(3 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arregion : out std_logic_vector(3 downto 0);
         m_axi_arqos    : out std_logic_vector(3 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic);
   end component;

   component AxiPcie64BResize32BCore
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awaddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(8*32-1 downto 0);
         s_axi_wstrb    : in  std_logic_vector(32-1 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_araddr   : in  std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rdata    : out std_logic_vector(8*32-1 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_awlen    : out std_logic_vector(7 downto 0);
         m_axi_awsize   : out std_logic_vector(2 downto 0);
         m_axi_awburst  : out std_logic_vector(1 downto 0);
         m_axi_awlock   : out std_logic_vector(0 downto 0);
         m_axi_awcache  : out std_logic_vector(3 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awregion : out std_logic_vector(3 downto 0);
         m_axi_awqos    : out std_logic_vector(3 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wstrb    : out std_logic_vector(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_araddr   : out std_logic_vector(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
         m_axi_arlen    : out std_logic_vector(7 downto 0);
         m_axi_arsize   : out std_logic_vector(2 downto 0);
         m_axi_arburst  : out std_logic_vector(1 downto 0);
         m_axi_arlock   : out std_logic_vector(0 downto 0);
         m_axi_arcache  : out std_logic_vector(3 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arregion : out std_logic_vector(3 downto 0);
         m_axi_arqos    : out std_logic_vector(3 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic);
   end component;

   signal axiRstL : sl;

begin

   assert ((AXI_DMA_CONFIG_G.DATA_BYTES_C = 64) or (AXI_DMA_CONFIG_G.DATA_BYTES_C = 32) or (AXI_DMA_CONFIG_G.DATA_BYTES_C = 16) or (AXI_DMA_CONFIG_G.DATA_BYTES_C = 8))
      report "AxiPcieDma: AXI STREAM DMA must have a byte width of [64,32,16,8]" severity failure;

   axiRstL <= not(axiRst);

   NO_RESIZE : if (not RESIZE_C) generate
      mAxiWriteMaster <= sAxiWriteMaster;
      sAxiWriteSlave  <= mAxiWriteSlave;
      mAxiReadMaster  <= sAxiReadMaster;
      sAxiReadSlave   <= mAxiReadSlave;
   end generate;

   GEN_RESIZE : if (RESIZE_C) generate

      RESIZE_8B : if (AXI_DMA_CONFIG_G.DATA_BYTES_C = 8) generate

         U_Resize : AxiPcie64BResize8BCore
            port map (
               s_axi_aclk      => axiClk,
               s_axi_aresetn   => axiRstL,
               -- SLAVE Port
               s_axi_awaddr    => sAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_awlen     => sAxiWriteMaster.awlen,
               s_axi_awsize    => sAxiWriteMaster.awsize,
               s_axi_awburst   => sAxiWriteMaster.awburst,
               s_axi_awlock(0) => sAxiWriteMaster.awlock(0),
               s_axi_awcache   => "0010",  -- overwriting for merge-able writes
               s_axi_awprot    => sAxiWriteMaster.awprot,
               s_axi_awregion  => sAxiWriteMaster.awregion,
               s_axi_awqos     => sAxiWriteMaster.awqos,
               s_axi_awvalid   => sAxiWriteMaster.awvalid,
               s_axi_awready   => sAxiWriteSlave.awready,
               s_axi_wdata     => sAxiWriteMaster.wdata(8*8-1 downto 0),
               s_axi_wstrb     => sAxiWriteMaster.wstrb(8-1 downto 0),
               s_axi_wlast     => sAxiWriteMaster.wlast,
               s_axi_wvalid    => sAxiWriteMaster.wvalid,
               s_axi_wready    => sAxiWriteSlave.wready,
               s_axi_bresp     => sAxiWriteSlave.bresp,
               s_axi_bvalid    => sAxiWriteSlave.bvalid,
               s_axi_bready    => sAxiWriteMaster.bready,
               s_axi_araddr    => sAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_arlen     => sAxiReadMaster.arlen,
               s_axi_arsize    => sAxiReadMaster.arsize,
               s_axi_arburst   => sAxiReadMaster.arburst,
               s_axi_arlock(0) => sAxiReadMaster.arlock(0),
               s_axi_arcache   => sAxiReadMaster.arcache,
               s_axi_arprot    => sAxiReadMaster.arprot,
               s_axi_arregion  => sAxiReadMaster.arregion,
               s_axi_arqos     => sAxiReadMaster.arqos,
               s_axi_arvalid   => sAxiReadMaster.arvalid,
               s_axi_arready   => sAxiReadSlave.arready,
               s_axi_rdata     => sAxiReadSlave.rdata(8*8-1 downto 0),
               s_axi_rresp     => sAxiReadSlave.rresp,
               s_axi_rlast     => sAxiReadSlave.rlast,
               s_axi_rvalid    => sAxiReadSlave.rvalid,
               s_axi_rready    => sAxiReadMaster.rready,
               -- MASTER Port
               m_axi_awaddr    => mAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_awlen     => mAxiWriteMaster.awlen,
               m_axi_awsize    => mAxiWriteMaster.awsize,
               m_axi_awburst   => mAxiWriteMaster.awburst,
               m_axi_awlock(0) => mAxiWriteMaster.awlock(0),
               m_axi_awcache   => mAxiWriteMaster.awcache,
               m_axi_awprot    => mAxiWriteMaster.awprot,
               m_axi_awregion  => mAxiWriteMaster.awregion,
               m_axi_awqos     => mAxiWriteMaster.awqos,
               m_axi_awvalid   => mAxiWriteMaster.awvalid,
               m_axi_awready   => mAxiWriteSlave.awready,
               m_axi_wdata     => mAxiWriteMaster.wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wstrb     => mAxiWriteMaster.wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wlast     => mAxiWriteMaster.wlast,
               m_axi_wvalid    => mAxiWriteMaster.wvalid,
               m_axi_wready    => mAxiWriteSlave.wready,
               m_axi_bresp     => mAxiWriteSlave.bresp,
               m_axi_bvalid    => mAxiWriteSlave.bvalid,
               m_axi_bready    => mAxiWriteMaster.bready,
               m_axi_araddr    => mAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_arlen     => mAxiReadMaster.arlen,
               m_axi_arsize    => mAxiReadMaster.arsize,
               m_axi_arburst   => mAxiReadMaster.arburst,
               m_axi_arlock(0) => mAxiReadMaster.arlock(0),
               m_axi_arcache   => mAxiReadMaster.arcache,
               m_axi_arprot    => mAxiReadMaster.arprot,
               m_axi_arregion  => mAxiReadMaster.arregion,
               m_axi_arqos     => mAxiReadMaster.arqos,
               m_axi_arvalid   => mAxiReadMaster.arvalid,
               m_axi_arready   => mAxiReadSlave.arready,
               m_axi_rdata     => mAxiReadSlave.rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_rresp     => mAxiReadSlave.rresp,
               m_axi_rlast     => mAxiReadSlave.rlast,
               m_axi_rvalid    => mAxiReadSlave.rvalid,
               m_axi_rready    => mAxiReadMaster.rready);

      end generate;

      RESIZE_16B : if (AXI_DMA_CONFIG_G.DATA_BYTES_C = 16) generate

         U_Resize : AxiPcie64BResize16BCore
            port map (
               s_axi_aclk      => axiClk,
               s_axi_aresetn   => axiRstL,
               -- SLAVE Port
               s_axi_awaddr    => sAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_awlen     => sAxiWriteMaster.awlen,
               s_axi_awsize    => sAxiWriteMaster.awsize,
               s_axi_awburst   => sAxiWriteMaster.awburst,
               s_axi_awlock(0) => sAxiWriteMaster.awlock(0),
               s_axi_awcache   => "0010",  -- overwriting for merge-able writes
               s_axi_awprot    => sAxiWriteMaster.awprot,
               s_axi_awregion  => sAxiWriteMaster.awregion,
               s_axi_awqos     => sAxiWriteMaster.awqos,
               s_axi_awvalid   => sAxiWriteMaster.awvalid,
               s_axi_awready   => sAxiWriteSlave.awready,
               s_axi_wdata     => sAxiWriteMaster.wdata(8*16-1 downto 0),
               s_axi_wstrb     => sAxiWriteMaster.wstrb(16-1 downto 0),
               s_axi_wlast     => sAxiWriteMaster.wlast,
               s_axi_wvalid    => sAxiWriteMaster.wvalid,
               s_axi_wready    => sAxiWriteSlave.wready,
               s_axi_bresp     => sAxiWriteSlave.bresp,
               s_axi_bvalid    => sAxiWriteSlave.bvalid,
               s_axi_bready    => sAxiWriteMaster.bready,
               s_axi_araddr    => sAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_arlen     => sAxiReadMaster.arlen,
               s_axi_arsize    => sAxiReadMaster.arsize,
               s_axi_arburst   => sAxiReadMaster.arburst,
               s_axi_arlock(0) => sAxiReadMaster.arlock(0),
               s_axi_arcache   => sAxiReadMaster.arcache,
               s_axi_arprot    => sAxiReadMaster.arprot,
               s_axi_arregion  => sAxiReadMaster.arregion,
               s_axi_arqos     => sAxiReadMaster.arqos,
               s_axi_arvalid   => sAxiReadMaster.arvalid,
               s_axi_arready   => sAxiReadSlave.arready,
               s_axi_rdata     => sAxiReadSlave.rdata(8*16-1 downto 0),
               s_axi_rresp     => sAxiReadSlave.rresp,
               s_axi_rlast     => sAxiReadSlave.rlast,
               s_axi_rvalid    => sAxiReadSlave.rvalid,
               s_axi_rready    => sAxiReadMaster.rready,
               -- MASTER Port
               m_axi_awaddr    => mAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_awlen     => mAxiWriteMaster.awlen,
               m_axi_awsize    => mAxiWriteMaster.awsize,
               m_axi_awburst   => mAxiWriteMaster.awburst,
               m_axi_awlock(0) => mAxiWriteMaster.awlock(0),
               m_axi_awcache   => mAxiWriteMaster.awcache,
               m_axi_awprot    => mAxiWriteMaster.awprot,
               m_axi_awregion  => mAxiWriteMaster.awregion,
               m_axi_awqos     => mAxiWriteMaster.awqos,
               m_axi_awvalid   => mAxiWriteMaster.awvalid,
               m_axi_awready   => mAxiWriteSlave.awready,
               m_axi_wdata     => mAxiWriteMaster.wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wstrb     => mAxiWriteMaster.wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wlast     => mAxiWriteMaster.wlast,
               m_axi_wvalid    => mAxiWriteMaster.wvalid,
               m_axi_wready    => mAxiWriteSlave.wready,
               m_axi_bresp     => mAxiWriteSlave.bresp,
               m_axi_bvalid    => mAxiWriteSlave.bvalid,
               m_axi_bready    => mAxiWriteMaster.bready,
               m_axi_araddr    => mAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_arlen     => mAxiReadMaster.arlen,
               m_axi_arsize    => mAxiReadMaster.arsize,
               m_axi_arburst   => mAxiReadMaster.arburst,
               m_axi_arlock(0) => mAxiReadMaster.arlock(0),
               m_axi_arcache   => mAxiReadMaster.arcache,
               m_axi_arprot    => mAxiReadMaster.arprot,
               m_axi_arregion  => mAxiReadMaster.arregion,
               m_axi_arqos     => mAxiReadMaster.arqos,
               m_axi_arvalid   => mAxiReadMaster.arvalid,
               m_axi_arready   => mAxiReadSlave.arready,
               m_axi_rdata     => mAxiReadSlave.rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_rresp     => mAxiReadSlave.rresp,
               m_axi_rlast     => mAxiReadSlave.rlast,
               m_axi_rvalid    => mAxiReadSlave.rvalid,
               m_axi_rready    => mAxiReadMaster.rready);

      end generate;

      RESIZE_32B : if (AXI_DMA_CONFIG_G.DATA_BYTES_C = 32) generate

         U_Resize : AxiPcie64BResize32BCore
            port map (
               s_axi_aclk      => axiClk,
               s_axi_aresetn   => axiRstL,
               -- SLAVE Port
               s_axi_awaddr    => sAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_awlen     => sAxiWriteMaster.awlen,
               s_axi_awsize    => sAxiWriteMaster.awsize,
               s_axi_awburst   => sAxiWriteMaster.awburst,
               s_axi_awlock(0) => sAxiWriteMaster.awlock(0),
               s_axi_awcache   => "0010",  -- overwriting for merge-able writes
               s_axi_awprot    => sAxiWriteMaster.awprot,
               s_axi_awregion  => sAxiWriteMaster.awregion,
               s_axi_awqos     => sAxiWriteMaster.awqos,
               s_axi_awvalid   => sAxiWriteMaster.awvalid,
               s_axi_awready   => sAxiWriteSlave.awready,
               s_axi_wdata     => sAxiWriteMaster.wdata(8*32-1 downto 0),
               s_axi_wstrb     => sAxiWriteMaster.wstrb(32-1 downto 0),
               s_axi_wlast     => sAxiWriteMaster.wlast,
               s_axi_wvalid    => sAxiWriteMaster.wvalid,
               s_axi_wready    => sAxiWriteSlave.wready,
               s_axi_bresp     => sAxiWriteSlave.bresp,
               s_axi_bvalid    => sAxiWriteSlave.bvalid,
               s_axi_bready    => sAxiWriteMaster.bready,
               s_axi_araddr    => sAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               s_axi_arlen     => sAxiReadMaster.arlen,
               s_axi_arsize    => sAxiReadMaster.arsize,
               s_axi_arburst   => sAxiReadMaster.arburst,
               s_axi_arlock(0) => sAxiReadMaster.arlock(0),
               s_axi_arcache   => sAxiReadMaster.arcache,
               s_axi_arprot    => sAxiReadMaster.arprot,
               s_axi_arregion  => sAxiReadMaster.arregion,
               s_axi_arqos     => sAxiReadMaster.arqos,
               s_axi_arvalid   => sAxiReadMaster.arvalid,
               s_axi_arready   => sAxiReadSlave.arready,
               s_axi_rdata     => sAxiReadSlave.rdata(8*32-1 downto 0),
               s_axi_rresp     => sAxiReadSlave.rresp,
               s_axi_rlast     => sAxiReadSlave.rlast,
               s_axi_rvalid    => sAxiReadSlave.rvalid,
               s_axi_rready    => sAxiReadMaster.rready,
               -- MASTER Port
               m_axi_awaddr    => mAxiWriteMaster.awaddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_awlen     => mAxiWriteMaster.awlen,
               m_axi_awsize    => mAxiWriteMaster.awsize,
               m_axi_awburst   => mAxiWriteMaster.awburst,
               m_axi_awlock(0) => mAxiWriteMaster.awlock(0),
               m_axi_awcache   => mAxiWriteMaster.awcache,
               m_axi_awprot    => mAxiWriteMaster.awprot,
               m_axi_awregion  => mAxiWriteMaster.awregion,
               m_axi_awqos     => mAxiWriteMaster.awqos,
               m_axi_awvalid   => mAxiWriteMaster.awvalid,
               m_axi_awready   => mAxiWriteSlave.awready,
               m_axi_wdata     => mAxiWriteMaster.wdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wstrb     => mAxiWriteMaster.wstrb(AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_wlast     => mAxiWriteMaster.wlast,
               m_axi_wvalid    => mAxiWriteMaster.wvalid,
               m_axi_wready    => mAxiWriteSlave.wready,
               m_axi_bresp     => mAxiWriteSlave.bresp,
               m_axi_bvalid    => mAxiWriteSlave.bvalid,
               m_axi_bready    => mAxiWriteMaster.bready,
               m_axi_araddr    => mAxiReadMaster.araddr(AXI_PCIE_CONFIG_G.ADDR_WIDTH_C-1 downto 0),
               m_axi_arlen     => mAxiReadMaster.arlen,
               m_axi_arsize    => mAxiReadMaster.arsize,
               m_axi_arburst   => mAxiReadMaster.arburst,
               m_axi_arlock(0) => mAxiReadMaster.arlock(0),
               m_axi_arcache   => mAxiReadMaster.arcache,
               m_axi_arprot    => mAxiReadMaster.arprot,
               m_axi_arregion  => mAxiReadMaster.arregion,
               m_axi_arqos     => mAxiReadMaster.arqos,
               m_axi_arvalid   => mAxiReadMaster.arvalid,
               m_axi_arready   => mAxiReadSlave.arready,
               m_axi_rdata     => mAxiReadSlave.rdata(8*AXI_PCIE_CONFIG_G.DATA_BYTES_C-1 downto 0),
               m_axi_rresp     => mAxiReadSlave.rresp,
               m_axi_rlast     => mAxiReadSlave.rlast,
               m_axi_rvalid    => mAxiReadSlave.rvalid,
               m_axi_rready    => mAxiReadMaster.rready);

      end generate;

   end generate;

end mapping;
