-------------------------------------------------------------------------------
-- File       : XilinxKcu105PciePhyWrapper.vhd
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

entity XilinxKcu105PciePhyWrapper is
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
end XilinxKcu105PciePhyWrapper;

architecture mapping of XilinxKcu105PciePhyWrapper is

   component XilinxKcu105PciePhy
      port (
         sys_rst_n              : in  std_logic;
         cfg_ltssm_state        : out std_logic_vector(5 downto 0);
         user_link_up           : out std_logic;
         axi_ctl_aclk           : in  std_logic;
         sys_clk_gt             : in  std_logic;
         intx_msi_request       : in  std_logic;
         s_axi_awid             : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axi_awaddr           : in  std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         s_axi_awregion         : in  std_logic_vector(3 downto 0);
         s_axi_awlen            : in  std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         s_axi_awsize           : in  std_logic_vector(2 downto 0);
         s_axi_awburst          : in  std_logic_vector(1 downto 0);
         s_axi_awvalid          : in  std_logic;
         s_axi_wdata            : in  std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axi_wuser            : in  std_logic_vector(31 downto 0);
         s_axi_wstrb            : in  std_logic_vector(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axi_wlast            : in  std_logic;
         s_axi_wvalid           : in  std_logic;
         s_axi_bready           : in  std_logic;
         s_axi_arid             : in  std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axi_araddr           : in  std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         s_axi_arregion         : in  std_logic_vector(3 downto 0);
         s_axi_arlen            : in  std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         s_axi_arsize           : in  std_logic_vector(2 downto 0);
         s_axi_arburst          : in  std_logic_vector(1 downto 0);
         s_axi_arvalid          : in  std_logic;
         s_axi_rready           : in  std_logic;
         m_axi_awready          : in  std_logic;
         m_axi_wready           : in  std_logic;
         m_axi_bid              : in  std_logic_vector(2 downto 0);
         m_axi_bresp            : in  std_logic_vector(1 downto 0);
         m_axi_bvalid           : in  std_logic;
         m_axi_arready          : in  std_logic;
         m_axi_rid              : in  std_logic_vector(2 downto 0);
         m_axi_rdata            : in  std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axi_ruser            : in  std_logic_vector(31 downto 0);
         m_axi_rresp            : in  std_logic_vector(1 downto 0);
         m_axi_rlast            : in  std_logic;
         m_axi_rvalid           : in  std_logic;
         pci_exp_rxp            : in  std_logic_vector(7 downto 0);
         pci_exp_rxn            : in  std_logic_vector(7 downto 0);
         refclk                 : in  std_logic;
         s_axi_ctl_awaddr       : in  std_logic_vector(11 downto 0);
         s_axi_ctl_awvalid      : in  std_logic;
         s_axi_ctl_wdata        : in  std_logic_vector(31 downto 0);
         s_axi_ctl_wstrb        : in  std_logic_vector(3 downto 0);
         s_axi_ctl_wvalid       : in  std_logic;
         s_axi_ctl_bready       : in  std_logic;
         s_axi_ctl_araddr       : in  std_logic_vector(11 downto 0);
         s_axi_ctl_arvalid      : in  std_logic;
         s_axi_ctl_rready       : in  std_logic;
         axi_aclk               : out std_logic;
         axi_aresetn            : out std_logic;
         axi_ctl_aresetn        : out std_logic;
         interrupt_out          : out std_logic;
         intx_msi_grant         : out std_logic;
         s_axi_awready          : out std_logic;
         s_axi_wready           : out std_logic;
         s_axi_bid              : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axi_bresp            : out std_logic_vector(1 downto 0);
         s_axi_bvalid           : out std_logic;
         s_axi_arready          : out std_logic;
         s_axi_rid              : out std_logic_vector(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0);
         s_axi_rdata            : out std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         s_axi_ruser            : out std_logic_vector(31 downto 0);
         s_axi_rresp            : out std_logic_vector(1 downto 0);
         s_axi_rlast            : out std_logic;
         s_axi_rvalid           : out std_logic;
         m_axi_awid             : out std_logic_vector(2 downto 0);
         m_axi_awaddr           : out std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         m_axi_awlen            : out std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         m_axi_awsize           : out std_logic_vector(2 downto 0);
         m_axi_awburst          : out std_logic_vector(1 downto 0);
         m_axi_awprot           : out std_logic_vector(2 downto 0);
         m_axi_awvalid          : out std_logic;
         m_axi_awlock           : out std_logic;
         m_axi_awcache          : out std_logic_vector(3 downto 0);
         m_axi_wdata            : out std_logic_vector(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axi_wuser            : out std_logic_vector(31 downto 0);
         m_axi_wstrb            : out std_logic_vector(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0);
         m_axi_wlast            : out std_logic;
         m_axi_wvalid           : out std_logic;
         m_axi_bready           : out std_logic;
         m_axi_arid             : out std_logic_vector(2 downto 0);
         m_axi_araddr           : out std_logic_vector(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         m_axi_arlen            : out std_logic_vector(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0);
         m_axi_arsize           : out std_logic_vector(2 downto 0);
         m_axi_arburst          : out std_logic_vector(1 downto 0);
         m_axi_arprot           : out std_logic_vector(2 downto 0);
         m_axi_arvalid          : out std_logic;
         m_axi_arlock           : out std_logic;
         m_axi_arcache          : out std_logic_vector(3 downto 0);
         m_axi_rready           : out std_logic;
         pci_exp_txp            : out std_logic_vector(7 downto 0);
         pci_exp_txn            : out std_logic_vector(7 downto 0);
         s_axi_ctl_awready      : out std_logic;
         s_axi_ctl_wready       : out std_logic;
         s_axi_ctl_bresp        : out std_logic_vector(1 downto 0);
         s_axi_ctl_bvalid       : out std_logic;
         s_axi_ctl_arready      : out std_logic;
         s_axi_ctl_rdata        : out std_logic_vector(31 downto 0);
         s_axi_ctl_rresp        : out std_logic_vector(1 downto 0);
         s_axi_ctl_rvalid       : out std_logic;
         int_qpll1lock_out      : out std_logic_vector(1 downto 0);
         int_qpll1outrefclk_out : out std_logic_vector(1 downto 0);
         int_qpll1outclk_out    : out std_logic_vector(1 downto 0)
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
   U_AxiPcie : XilinxKcu105PciePhy
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
         s_axi_awid             => dmaWriteMaster.awid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axi_awaddr           => dmaWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         s_axi_awregion         => dmaWriteMaster.awregion,
         s_axi_awlen            => dmaWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         s_axi_awsize           => dmaWriteMaster.awsize(2 downto 0),
         s_axi_awburst          => dmaWriteMaster.awburst(1 downto 0),
         s_axi_awvalid          => dmaWriteMaster.awvalid,
         s_axi_awready          => dmaWriteSlave.awready,
         s_axi_wdata            => dmaWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axi_wuser            => (others => '0'),
         s_axi_wstrb            => dmaWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axi_wlast            => dmaWriteMaster.wlast,
         s_axi_wvalid           => dmaWriteMaster.wvalid,
         s_axi_wready           => dmaWriteSlave.wready,
         s_axi_bid              => dmaWriteSlave.bid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axi_bresp            => dmaWriteSlave.bresp(1 downto 0),
         s_axi_bvalid           => dmaWriteSlave.bvalid,
         s_axi_bready           => dmaWriteMaster.bready,
         s_axi_arid             => dmaReadMaster.arid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axi_araddr           => dmaReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         s_axi_arregion         => dmaReadMaster.arregion,
         s_axi_arlen            => dmaReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         s_axi_arsize           => dmaReadMaster.arsize(2 downto 0),
         s_axi_arburst          => dmaReadMaster.arburst(1 downto 0),
         s_axi_arvalid          => dmaReadMaster.arvalid,
         s_axi_arready          => dmaReadSlave.arready,
         s_axi_rid              => dmaReadSlave.rid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         s_axi_rdata            => dmaReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         s_axi_ruser            => open,
         s_axi_rresp            => dmaReadSlave.rresp(1 downto 0),
         s_axi_rlast            => dmaReadSlave.rlast,
         s_axi_rvalid           => dmaReadSlave.rvalid,
         s_axi_rready           => dmaReadMaster.rready,
         -- Master AXI4 Interface
         m_axi_awaddr           => regWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         m_axi_awlen            => regWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         m_axi_awsize           => regWriteMaster.awsize(2 downto 0),
         m_axi_awburst          => regWriteMaster.awburst(1 downto 0),
         m_axi_awprot           => regWriteMaster.awprot,
         m_axi_awvalid          => regWriteMaster.awvalid,
         m_axi_awready          => regWriteSlave.awready,
         m_axi_awlock           => regWriteMaster.awlock(0),
         m_axi_awcache          => regWriteMaster.awcache,
         m_axi_wdata            => regWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         m_axi_wuser            => open,
         m_axi_wstrb            => regWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         m_axi_wlast            => regWriteMaster.wlast,
         m_axi_wvalid           => regWriteMaster.wvalid,
         m_axi_wready           => regWriteSlave.wready,
         m_axi_bid              => regWriteSlave.bid(2 downto 0),
         -- m_axi_bresp         => regWriteSlave.bresp(1 downto 0),
         m_axi_bresp            => AXI_RESP_OK_C, -- Always respond OK         
         m_axi_bvalid           => regWriteSlave.bvalid,
         m_axi_bready           => regWriteMaster.bready,
         m_axi_araddr           => regReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         m_axi_arlen            => regReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         m_axi_arsize           => regReadMaster.arsize(2 downto 0),
         m_axi_arburst          => regReadMaster.arburst(1 downto 0),
         m_axi_arprot           => regReadMaster.arprot,
         m_axi_arvalid          => regReadMaster.arvalid,
         m_axi_arready          => regReadSlave.arready,
         m_axi_arlock           => regReadMaster.arlock(0),
         m_axi_arcache          => regReadMaster.arcache,
         m_axi_rid              => regReadSlave.rid(2 downto 0),
         m_axi_rdata            => regReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         m_axi_ruser            => (others => '0'),
         -- m_axi_rresp         => regReadSlave.rresp(1 downto 0),
         m_axi_rresp            => AXI_RESP_OK_C, -- Always respond OK    
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
         s_axi_ctl_rready       => phyReadMaster.rready,
         -- QPLL Interface
         int_qpll1lock_out      => open,
         int_qpll1outrefclk_out => open,
         int_qpll1outclk_out    => open);

end mapping;
