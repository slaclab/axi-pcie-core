-------------------------------------------------------------------------------
-- File       : XilinxKcu1500PciePhyWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-02-12
-- Last update: 2017-08-27
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

library unisim;
use unisim.vcomponents.all;

entity XilinxKcu1500PciePhyWrapper is
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
end XilinxKcu1500PciePhyWrapper;

architecture mapping of XilinxKcu1500PciePhyWrapper is

   component XilinxKcu1500PciePhy
      port (
    sys_rst_n : IN STD_LOGIC;
    cfg_ltssm_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    user_link_up : OUT STD_LOGIC;
    axi_ctl_aclk : IN STD_LOGIC;
    sys_clk_gt : IN STD_LOGIC;
    intx_msi_request : IN STD_LOGIC;
    s_axi_awid : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_awregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    s_axi_wuser : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_wlast : IN STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_arid : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_arregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    m_axi_awready : IN STD_LOGIC;
    m_axi_wready : IN STD_LOGIC;
    m_axi_bid : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_bvalid : IN STD_LOGIC;
    m_axi_arready : IN STD_LOGIC;
    m_axi_rid : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_rdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    m_axi_ruser : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_rlast : IN STD_LOGIC;
    m_axi_rvalid : IN STD_LOGIC;
    pci_exp_rxp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    pci_exp_rxn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    refclk : IN STD_LOGIC;
    s_axi_ctl_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_ctl_awvalid : IN STD_LOGIC;
    s_axi_ctl_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_ctl_wvalid : IN STD_LOGIC;
    s_axi_ctl_bready : IN STD_LOGIC;
    s_axi_ctl_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_ctl_arvalid : IN STD_LOGIC;
    s_axi_ctl_rready : IN STD_LOGIC;
    axi_aclk : OUT STD_LOGIC;
    axi_aresetn : OUT STD_LOGIC;
    axi_ctl_aresetn : OUT STD_LOGIC;
    interrupt_out : OUT STD_LOGIC;
    intx_msi_grant : OUT STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bid : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rid : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_rdata : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    s_axi_ruser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rvalid : OUT STD_LOGIC;
    m_axi_awid : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awvalid : OUT STD_LOGIC;
    m_axi_awlock : OUT STD_LOGIC;
    m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_wdata : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    m_axi_wuser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axi_wstrb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axi_wlast : OUT STD_LOGIC;
    m_axi_wvalid : OUT STD_LOGIC;
    m_axi_bready : OUT STD_LOGIC;
    m_axi_arid : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arvalid : OUT STD_LOGIC;
    m_axi_arlock : OUT STD_LOGIC;
    m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_rready : OUT STD_LOGIC;
    pci_exp_txp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    pci_exp_txn : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_ctl_awready : OUT STD_LOGIC;
    s_axi_ctl_wready : OUT STD_LOGIC;
    s_axi_ctl_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_ctl_bvalid : OUT STD_LOGIC;
    s_axi_ctl_arready : OUT STD_LOGIC;
    s_axi_ctl_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_ctl_rvalid : OUT STD_LOGIC
         );
   end component;

   signal refClk   : sl;
   signal refClkGt : sl;
   signal clk      : sl;
   signal rst      : sl;
   signal rstL     : sl;
   signal axiClock : sl;
   signal axiReset : sl;
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
   U_IBUFDS_GTE3 : IBUFDS_GTE3
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
   U_AxiPcie : XilinxKcu1500PciePhy
      port map (
         -- Clocks and Resets
         sys_clk_gt             => refClkGt,
         refclk                 => refClk,
         sys_rst_n              => pciRstL,
         axi_aclk               => clk,
         axi_aresetn            => rstL,
         axi_ctl_aclk           => clk,
         axi_ctl_aresetn        => open,
         user_link_up           => open,
         cfg_ltssm_state        => open,
         -- Interrupt Interface
         intx_msi_request       => dmaIrq,
         intx_msi_grant         => open,
         interrupt_out          => open,
         -- Slave AXI4 Interface
         s_axi_awid             => dmaWriteMaster.awid(4 downto 0),
         s_axi_awaddr           => dmaWriteMaster.awaddr(31 downto 0),
         s_axi_awregion         => dmaWriteMaster.awregion,
         s_axi_awlen            => dmaWriteMaster.awlen(7 downto 0),
         s_axi_awsize           => dmaWriteMaster.awsize(2 downto 0),
         s_axi_awburst          => dmaWriteMaster.awburst(1 downto 0),
         s_axi_awvalid          => dmaWriteMaster.awvalid,
         s_axi_awready          => dmaWriteSlave.awready,
         s_axi_wdata            => dmaWriteMaster.wdata(255 downto 0),
         s_axi_wuser            => (others => '0'),
         s_axi_wstrb            => dmaWriteMaster.wstrb(31 downto 0),
         s_axi_wlast            => dmaWriteMaster.wlast,
         s_axi_wvalid           => dmaWriteMaster.wvalid,
         s_axi_wready           => dmaWriteSlave.wready,
         s_axi_bid              => dmaWriteSlave.bid(4 downto 0),
         s_axi_bresp            => dmaWriteSlave.bresp(1 downto 0),
         s_axi_bvalid           => dmaWriteSlave.bvalid,
         s_axi_bready           => dmaWriteMaster.bready,
         s_axi_arid             => dmaReadMaster.arid(4 downto 0),
         s_axi_araddr           => dmaReadMaster.araddr(31 downto 0),
         s_axi_arregion         => dmaReadMaster.arregion,
         s_axi_arlen            => dmaReadMaster.arlen(7 downto 0),
         s_axi_arsize           => dmaReadMaster.arsize(2 downto 0),
         s_axi_arburst          => dmaReadMaster.arburst(1 downto 0),
         s_axi_arvalid          => dmaReadMaster.arvalid,
         s_axi_arready          => dmaReadSlave.arready,
         s_axi_rid              => dmaReadSlave.rid(4 downto 0),
         s_axi_rdata            => dmaReadSlave.rdata(255 downto 0),
         s_axi_ruser            => open,
         s_axi_rresp            => dmaReadSlave.rresp(1 downto 0),
         s_axi_rlast            => dmaReadSlave.rlast,
         s_axi_rvalid           => dmaReadSlave.rvalid,
         s_axi_rready           => dmaReadMaster.rready,
         -- Master AXI4 Interface
         m_axi_awaddr           => regWriteMaster.awaddr(31 downto 0),
         m_axi_awlen            => regWriteMaster.awlen(7 downto 0),
         m_axi_awsize           => regWriteMaster.awsize(2 downto 0),
         m_axi_awburst          => regWriteMaster.awburst(1 downto 0),
         m_axi_awprot           => regWriteMaster.awprot,
         m_axi_awvalid          => regWriteMaster.awvalid,
         m_axi_awready          => regWriteSlave.awready,
         m_axi_awlock           => regWriteMaster.awlock(0),
         m_axi_awcache          => regWriteMaster.awcache,
         m_axi_wdata            => regWriteMaster.wdata(255 downto 0),
         m_axi_wuser            => open,
         m_axi_wstrb            => regWriteMaster.wstrb(31 downto 0),
         m_axi_wlast            => regWriteMaster.wlast,
         m_axi_wvalid           => regWriteMaster.wvalid,
         m_axi_wready           => regWriteSlave.wready,
         m_axi_bid              => regWriteSlave.bid(2 downto 0),
         m_axi_bresp            => regWriteSlave.bresp(1 downto 0),
         m_axi_bvalid           => regWriteSlave.bvalid,
         m_axi_bready           => regWriteMaster.bready,
         m_axi_araddr           => regReadMaster.araddr(31 downto 0),
         m_axi_arlen            => regReadMaster.arlen(7 downto 0),
         m_axi_arsize           => regReadMaster.arsize(2 downto 0),
         m_axi_arburst          => regReadMaster.arburst(1 downto 0),
         m_axi_arprot           => regReadMaster.arprot,
         m_axi_arvalid          => regReadMaster.arvalid,
         m_axi_arready          => regReadSlave.arready,
         m_axi_arlock           => regReadMaster.arlock(0),
         m_axi_arcache          => regReadMaster.arcache,
         m_axi_rid              => regReadSlave.rid(2 downto 0),
         m_axi_rdata            => regReadSlave.rdata(255 downto 0),
         m_axi_ruser            => (others => '0'),
         m_axi_rresp            => regReadSlave.rresp(1 downto 0),
         m_axi_rlast            => regReadSlave.rlast,
         m_axi_rvalid           => regReadSlave.rvalid,
         m_axi_rready           => regReadMaster.rready,
         -- PCIe PHY Interface
         pci_exp_txp            => pciTxP,
         pci_exp_txn            => pciTxN,
         pci_exp_rxp            => pciRxP,
         pci_exp_rxn            => pciRxN,
         -- Slave AXI4-Lite Interface
         s_axi_ctl_awaddr       => phyWriteMaster.awaddr(11 downto 0),
         s_axi_ctl_awvalid      => phyWriteMaster.awvalid,
         s_axi_ctl_awready      => phyWriteSlave.awready,
         s_axi_ctl_wdata        => phyWriteMaster.wdata,
         s_axi_ctl_wstrb        => phyWriteMaster.wstrb,
         s_axi_ctl_wvalid       => phyWriteMaster.wvalid,
         s_axi_ctl_wready       => phyWriteSlave.wready,
         s_axi_ctl_bresp        => phyWriteSlave.bresp,
         s_axi_ctl_bvalid       => phyWriteSlave.bvalid,
         s_axi_ctl_bready       => phyWriteMaster.bready,
         s_axi_ctl_araddr       => phyReadMaster.araddr(11 downto 0),
         s_axi_ctl_arvalid      => phyReadMaster.arvalid,
         s_axi_ctl_arready      => phyReadSlave.arready,
         s_axi_ctl_rdata        => phyReadSlave.rdata,
         s_axi_ctl_rresp        => phyReadSlave.rresp,
         s_axi_ctl_rvalid       => phyReadSlave.rvalid,
         s_axi_ctl_rready       => phyReadMaster.rready);

end mapping;
