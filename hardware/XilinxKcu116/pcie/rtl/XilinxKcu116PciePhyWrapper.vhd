-------------------------------------------------------------------------------
-- File       : XilinxKcu116PciePhyWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AXI PCIe Core
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
use work.AxiLitePkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxKcu116PciePhyWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- AXI4 Interfaces
      axiClk         : out sl;
      axiRst         : out sl;
      dmaReadMaster  : in  AxiReadMasterType;
      dmaReadSlave   : out AxiReadSlaveType;
      dmaWriteMaster : in  AxiWriteMasterType;
      dmaWriteSlave  : out AxiWriteSlaveType;
      regReadMaster  : out AxiReadMasterType;
      regReadSlave   : in  AxiReadSlaveType;
      regWriteMaster : out AxiWriteMasterType;
      regWriteSlave  : in  AxiWriteSlaveType;
      phyReadMaster  : in  AxiLiteReadMasterType;
      phyReadSlave   : out AxiLiteReadSlaveType;
      phyWriteMaster : in  AxiLiteWriteMasterType;
      phyWriteSlave  : out AxiLiteWriteSlaveType;
      -- Interrupt Interface
      dmaIrq         : in  sl;
      -- PCIe Ports 
      pciRstL        : in  sl;
      pciRefClkP     : in  sl;
      pciRefClkN     : in  sl;
      pciRxP         : in  slv(7 downto 0);
      pciRxN         : in  slv(7 downto 0);
      pciTxP         : out slv(7 downto 0);
      pciTxN         : out slv(7 downto 0));
end XilinxKcu116PciePhyWrapper;

architecture mapping of XilinxKcu116PciePhyWrapper is

   component XilinxKcu116PciePhy
      port (

         sys_clk          : in  std_logic;
         sys_clk_gt       : in  std_logic;
         sys_rst_n        : in  std_logic;
         cfg_ltssm_state  : out std_logic_vector(5 downto 0);
         user_lnk_up      : out std_logic;
         pci_exp_txp      : out std_logic_vector(7 downto 0);
         pci_exp_txn      : out std_logic_vector(7 downto 0);
         pci_exp_rxp      : in  std_logic_vector(7 downto 0);
         pci_exp_rxn      : in  std_logic_vector(7 downto 0);
         axi_aclk         : out std_logic;
         axi_aresetn      : out std_logic;
         axi_ctl_aresetn  : out std_logic;
         usr_irq_req      : in  std_logic_vector(0 downto 0);
         usr_irq_ack      : out std_logic_vector(0 downto 0);
         msi_enable       : out std_logic;
         msi_vector_width : out std_logic_vector(2 downto 0);
         m_axib_awid      : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         m_axib_awaddr    : out std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         m_axib_awlen     : out std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         m_axib_awsize    : out std_logic_vector(2 downto 0);
         m_axib_awburst   : out std_logic_vector(1 downto 0);
         m_axib_awprot    : out std_logic_vector(2 downto 0);
         m_axib_awvalid   : out std_logic;
         m_axib_awready   : in  std_logic;
         m_axib_awlock    : out std_logic;
         m_axib_awcache   : out std_logic_vector(3 downto 0);
         m_axib_wdata     : out std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axib_wstrb     : out std_logic_vector(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axib_wlast     : out std_logic;
         m_axib_wvalid    : out std_logic;
         m_axib_wready    : in  std_logic;
         m_axib_bid       : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         m_axib_bresp     : in  std_logic_vector(1 downto 0);
         m_axib_bvalid    : in  std_logic;
         m_axib_bready    : out std_logic;
         m_axib_arid      : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         m_axib_araddr    : out std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         m_axib_arlen     : out std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         m_axib_arsize    : out std_logic_vector(2 downto 0);
         m_axib_arburst   : out std_logic_vector(1 downto 0);
         m_axib_arprot    : out std_logic_vector(2 downto 0);
         m_axib_arvalid   : out std_logic;
         m_axib_arready   : in  std_logic;
         m_axib_arlock    : out std_logic;
         m_axib_arcache   : out std_logic_vector(3 downto 0);
         m_axib_rid       : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         m_axib_rdata     : in  std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axib_rresp     : in  std_logic_vector(1 downto 0);
         m_axib_rlast     : in  std_logic;
         m_axib_rvalid    : in  std_logic;
         m_axib_rready    : out std_logic;
         s_axil_awaddr    : in  std_logic_vector(31 downto 0);
         s_axil_awprot    : in  std_logic_vector(2 downto 0);
         s_axil_awvalid   : in  std_logic;
         s_axil_awready   : out std_logic;
         s_axil_wdata     : in  std_logic_vector(31 downto 0);
         s_axil_wstrb     : in  std_logic_vector(3 downto 0);
         s_axil_wvalid    : in  std_logic;
         s_axil_wready    : out std_logic;
         s_axil_bvalid    : out std_logic;
         s_axil_bresp     : out std_logic_vector(1 downto 0);
         s_axil_bready    : in  std_logic;
         s_axil_araddr    : in  std_logic_vector(31 downto 0);
         s_axil_arprot    : in  std_logic_vector(2 downto 0);
         s_axil_arvalid   : in  std_logic;
         s_axil_arready   : out std_logic;
         s_axil_rdata     : out std_logic_vector(31 downto 0);
         s_axil_rresp     : out std_logic_vector(1 downto 0);
         s_axil_rvalid    : out std_logic;
         s_axil_rready    : in  std_logic;
         interrupt_out    : out std_logic;
         s_axib_awid      : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axib_awaddr    : in  std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         s_axib_awregion  : in  std_logic_vector(3 downto 0);
         s_axib_awlen     : in  std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         s_axib_awsize    : in  std_logic_vector(2 downto 0);
         s_axib_awburst   : in  std_logic_vector(1 downto 0);
         s_axib_awvalid   : in  std_logic;
         s_axib_wdata     : in  std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axib_wstrb     : in  std_logic_vector(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axib_wlast     : in  std_logic;
         s_axib_wvalid    : in  std_logic;
         s_axib_bready    : in  std_logic;
         s_axib_arid      : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axib_araddr    : in  std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         s_axib_arregion  : in  std_logic_vector(3 downto 0);
         s_axib_arlen     : in  std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         s_axib_arsize    : in  std_logic_vector(2 downto 0);
         s_axib_arburst   : in  std_logic_vector(1 downto 0);
         s_axib_arvalid   : in  std_logic;
         s_axib_rready    : in  std_logic;
         s_axib_awready   : out std_logic;
         s_axib_wready    : out std_logic;
         s_axib_bid       : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axib_bresp     : out std_logic_vector(1 downto 0);
         s_axib_bvalid    : out std_logic;
         s_axib_arready   : out std_logic;
         s_axib_rid       : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axib_rdata     : out std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axib_rresp     : out std_logic_vector(1 downto 0);
         s_axib_rlast     : out std_logic;
         s_axib_rvalid    : out std_logic);
   end component;

   signal refClk   : sl;
   signal refClkGt : sl;
   signal clk      : sl;
   signal rst      : sl;
   signal rstL     : sl;
   signal axiClock : sl;
   signal axiReset : sl;

   signal sAxilAwaddr : slv(31 downto 0);
   signal sAxilAraddr : slv(31 downto 0);

begin

   axiClk <= clk;
   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => clk,
         rstIn  => rstL,
         rstOut => axiRst);

   ------------------
   -- Clock and Reset
   ------------------
   U_IBUFDS_GTE3 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => pciRefClkP,
         IB    => pciRefClkN,
         CEB   => '0',
         ODIV2 => refClk,
         O     => refClkGt);

   -------------------
   -- AXI PCIe IP Core
   -------------------
   U_AxiPcie : XilinxKcu116PciePhy
      port map (
         -- Clocks and Resets
         sys_clk         => refClk,
         sys_clk_gt      => refClkGt,
         sys_rst_n       => pciRstL,
         axi_aclk        => clk,
         axi_aresetn     => rstL,
         axi_ctl_aresetn => open,
         user_lnk_up     => open,
         cfg_ltssm_state => open,
         -- Interrupt Interface
         usr_irq_req(0)  => dmaIrq,
         usr_irq_ack(0)  => open,  -- Action Item: Unclear if there needs to be handshaking with existing AxisDMAv2's IRQ.  Need to determine if a FSM between the usr_irq_req/usr_irq_ack to dmaIrq is need???
         interrupt_out   => open,
         -- Slave AXI4 Interface
         s_axib_awid     => dmaWriteMaster.awid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axib_awaddr   => dmaWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         s_axib_awregion => dmaWriteMaster.awregion,
         s_axib_awlen    => dmaWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         s_axib_awsize   => dmaWriteMaster.awsize(2 downto 0),
         s_axib_awburst  => dmaWriteMaster.awburst(1 downto 0),
         s_axib_awvalid  => dmaWriteMaster.awvalid,
         s_axib_awready  => dmaWriteSlave.awready,
         s_axib_wdata    => dmaWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axib_wstrb    => dmaWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axib_wlast    => dmaWriteMaster.wlast,
         s_axib_wvalid   => dmaWriteMaster.wvalid,
         s_axib_wready   => dmaWriteSlave.wready,
         s_axib_bid      => dmaWriteSlave.bid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axib_bresp    => dmaWriteSlave.bresp(1 downto 0),
         s_axib_bvalid   => dmaWriteSlave.bvalid,
         s_axib_bready   => dmaWriteMaster.bready,
         s_axib_arid     => dmaReadMaster.arid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axib_araddr   => dmaReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         s_axib_arregion => dmaReadMaster.arregion,
         s_axib_arlen    => dmaReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         s_axib_arsize   => dmaReadMaster.arsize(2 downto 0),
         s_axib_arburst  => dmaReadMaster.arburst(1 downto 0),
         s_axib_arvalid  => dmaReadMaster.arvalid,
         s_axib_arready  => dmaReadSlave.arready,
         s_axib_rid      => dmaReadSlave.rid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axib_rdata    => dmaReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axib_rresp    => dmaReadSlave.rresp(1 downto 0),
         s_axib_rlast    => dmaReadSlave.rlast,
         s_axib_rvalid   => dmaReadSlave.rvalid,
         s_axib_rready   => dmaReadMaster.rready,
         -- Master AXI4 Interface
         m_axib_awaddr   => regWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         m_axib_awlen    => regWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         m_axib_awsize   => regWriteMaster.awsize(2 downto 0),
         m_axib_awburst  => regWriteMaster.awburst(1 downto 0),
         m_axib_awprot   => regWriteMaster.awprot,
         m_axib_awvalid  => regWriteMaster.awvalid,
         m_axib_awready  => regWriteSlave.awready,
         m_axib_awlock   => regWriteMaster.awlock(0),
         m_axib_awcache  => regWriteMaster.awcache,
         m_axib_wdata    => regWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         m_axib_wstrb    => regWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         m_axib_wlast    => regWriteMaster.wlast,
         m_axib_wvalid   => regWriteMaster.wvalid,
         m_axib_wready   => regWriteSlave.wready,
         m_axib_bid      => regWriteSlave.bid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         -- m_axi_bresp         => regWriteSlave.bresp(1 downto 0),
         m_axib_bresp    => AXI_RESP_OK_C,  -- Always respond OK   
         m_axib_bvalid   => regWriteSlave.bvalid,
         m_axib_bready   => regWriteMaster.bready,
         m_axib_araddr   => regReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         m_axib_arlen    => regReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         m_axib_arsize   => regReadMaster.arsize(2 downto 0),
         m_axib_arburst  => regReadMaster.arburst(1 downto 0),
         m_axib_arprot   => regReadMaster.arprot,
         m_axib_arvalid  => regReadMaster.arvalid,
         m_axib_arready  => regReadSlave.arready,
         m_axib_arlock   => regReadMaster.arlock(0),
         m_axib_arcache  => regReadMaster.arcache,
         m_axib_rid      => regReadSlave.rid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         m_axib_rdata    => regReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         -- m_axi_rresp         => regReadSlave.rresp(1 downto 0),
         m_axib_rresp    => AXI_RESP_OK_C,  -- Always respond OK    
         m_axib_rlast    => regReadSlave.rlast,
         m_axib_rvalid   => regReadSlave.rvalid,
         m_axib_rready   => regReadMaster.rready,
         -- PCIe PHY Interface
         pci_exp_txp     => pciTxP,
         pci_exp_txn     => pciTxN,
         pci_exp_rxp     => pciRxP,
         pci_exp_rxn     => pciRxN,
         -- Slave AXI4-Lite Interface
         s_axil_awaddr   => sAxilAwaddr,
         s_axil_awprot   => phyWriteMaster.awprot,
         s_axil_awvalid  => phyWriteMaster.awvalid,
         s_axil_awready  => phyWriteSlave.awready,
         s_axil_wdata    => phyWriteMaster.wdata,
         s_axil_wstrb    => phyWriteMaster.wstrb,
         s_axil_wvalid   => phyWriteMaster.wvalid,
         s_axil_wready   => phyWriteSlave.wready,
         s_axil_bresp    => phyWriteSlave.bresp,
         s_axil_bvalid   => phyWriteSlave.bvalid,
         s_axil_bready   => phyWriteMaster.bready,
         s_axil_araddr   => sAxilAraddr,
         s_axil_arprot   => phyReadMaster.arprot,
         s_axil_arvalid  => phyReadMaster.arvalid,
         s_axil_arready  => phyReadSlave.arready,
         s_axil_rdata    => phyReadSlave.rdata,
         s_axil_rresp    => phyReadSlave.rresp,
         s_axil_rvalid   => phyReadSlave.rvalid,
         s_axil_rready   => phyReadMaster.rready);

   sAxilAwaddr(11 downto 0)  <= phyWriteMaster.awaddr(11 downto 0);
   sAxilAwaddr(31 downto 12) <= (others => '0');

   sAxilAraddr(11 downto 0)  <= phyReadMaster.araddr(11 downto 0);
   sAxilAraddr(31 downto 12) <= (others => '0');
end mapping;
