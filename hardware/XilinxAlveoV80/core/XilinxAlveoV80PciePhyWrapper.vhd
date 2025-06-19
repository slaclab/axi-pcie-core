-------------------------------------------------------------------------------
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxAlveoV80PciePhyWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      userClk        : in    sl;
      -- AXI4 Interfaces
      axiClk         : out   sl;
      axiRst         : out   sl;
      dmaReadMaster  : in    AxiReadMasterType;
      dmaReadSlave   : out   AxiReadSlaveType;
      dmaWriteMaster : in    AxiWriteMasterType;
      dmaWriteSlave  : out   AxiWriteSlaveType;
      regReadMaster  : out   AxiReadMasterType;
      regReadSlave   : in    AxiReadSlaveType;
      regWriteMaster : out   AxiWriteMasterType;
      regWriteSlave  : in    AxiWriteSlaveType;
      phyReadMaster  : in    AxiLiteReadMasterType;
      phyReadSlave   : out   AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      phyWriteMaster : in    AxiLiteWriteMasterType;
      phyWriteSlave  : out   AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -- Interrupt Interface
      dmaIrq         : in    sl;
      -- PS DDR Ports
      psDdrDq        : inout slv(71 downto 0);
      psDdrDqsT      : inout slv(8 downto 0);
      psDdrDqsC      : inout slv(8 downto 0);
      psDdrAdr       : out   slv(16 downto 0);
      psDdrBa        : out   slv(1 downto 0);
      psDdrBg        : out   slv(0 to 0);
      psDdrActN      : out   slv(0 to 0);
      psDdrResetN    : out   slv(0 to 0);
      psDdrCkT       : out   slv(0 to 0);
      psDdrCkC       : out   slv(0 to 0);
      psDdrCke       : out   slv(0 to 0);
      psDdrCsN       : out   slv(0 to 0);
      psDdrDmN       : inout slv(8 downto 0);
      psDdrOdt       : out   slv(0 to 0);
      psDdrClkP      : in    slv(0 to 0);
      psDdrClkN      : in    slv(0 to 0);
      -- PCIe Ports
      pciRefClkP     : in    sl;
      pciRefClkN     : in    sl;
      pciRxP         : in    slv(7 downto 0);
      pciRxN         : in    slv(7 downto 0);
      pciTxP         : out   slv(7 downto 0);
      pciTxN         : out   slv(7 downto 0));
end XilinxAlveoV80PciePhyWrapper;

architecture mapping of XilinxAlveoV80PciePhyWrapper is

   component XilinxAlveoV80PcieBlockDesign is
      port (
         psDDR_dq           : inout std_logic_vector (71 downto 0);
         psDDR_dqs_t        : inout std_logic_vector (8 downto 0);
         psDDR_dqs_c        : inout std_logic_vector (8 downto 0);
         psDDR_adr          : out   std_logic_vector (16 downto 0);
         psDDR_ba           : out   std_logic_vector (1 downto 0);
         psDDR_bg           : out   std_logic_vector (0 to 0);
         psDDR_act_n        : out   std_logic_vector (0 to 0);
         psDDR_reset_n      : out   std_logic_vector (0 to 0);
         psDDR_ck_t         : out   std_logic_vector (0 to 0);
         psDDR_ck_c         : out   std_logic_vector (0 to 0);
         psDDR_cke          : out   std_logic_vector (0 to 0);
         psDDR_cs_n         : out   std_logic_vector (0 to 0);
         psDDR_dm_n         : inout std_logic_vector (8 downto 0);
         psDDR_odt          : out   std_logic_vector (0 to 0);
         psDdrClk_clk_p     : in    std_logic_vector (0 to 0);
         psDdrClk_clk_n     : in    std_logic_vector (0 to 0);
         gtPcieRefClk_clk_n : in    std_logic;
         gtPcieRefClk_clk_p : in    std_logic;
         gtPcie_grx_n       : in    std_logic_vector (7 downto 0);
         gtPcie_gtx_n       : out   std_logic_vector (7 downto 0);
         gtPcie_grx_p       : in    std_logic_vector (7 downto 0);
         gtPcie_gtx_p       : out   std_logic_vector (7 downto 0);
         sAxi_awid          : in    std_logic_vector (3 downto 0);
         sAxi_awaddr        : in    std_logic_vector (63 downto 0);
         sAxi_awlen         : in    std_logic_vector (7 downto 0);
         sAxi_awsize        : in    std_logic_vector (2 downto 0);
         sAxi_awburst       : in    std_logic_vector (1 downto 0);
         sAxi_awlock        : in    std_logic_vector (0 to 0);
         sAxi_awcache       : in    std_logic_vector (3 downto 0);
         sAxi_awprot        : in    std_logic_vector (2 downto 0);
         sAxi_awregion      : in    std_logic_vector (3 downto 0);
         sAxi_awqos         : in    std_logic_vector (3 downto 0);
         sAxi_awvalid       : in    std_logic_vector (0 to 0);
         sAxi_awready       : out   std_logic_vector (0 to 0);
         sAxi_wdata         : in    std_logic_vector (511 downto 0);
         sAxi_wstrb         : in    std_logic_vector (63 downto 0);
         sAxi_wlast         : in    std_logic_vector (0 to 0);
         sAxi_wvalid        : in    std_logic_vector (0 to 0);
         sAxi_wready        : out   std_logic_vector (0 to 0);
         sAxi_bid           : out   std_logic_vector (3 downto 0);
         sAxi_bresp         : out   std_logic_vector (1 downto 0);
         sAxi_bvalid        : out   std_logic_vector (0 to 0);
         sAxi_bready        : in    std_logic_vector (0 to 0);
         sAxi_arid          : in    std_logic_vector (3 downto 0);
         sAxi_araddr        : in    std_logic_vector (63 downto 0);
         sAxi_arlen         : in    std_logic_vector (7 downto 0);
         sAxi_arsize        : in    std_logic_vector (2 downto 0);
         sAxi_arburst       : in    std_logic_vector (1 downto 0);
         sAxi_arlock        : in    std_logic_vector (0 to 0);
         sAxi_arcache       : in    std_logic_vector (3 downto 0);
         sAxi_arprot        : in    std_logic_vector (2 downto 0);
         sAxi_arregion      : in    std_logic_vector (3 downto 0);
         sAxi_arqos         : in    std_logic_vector (3 downto 0);
         sAxi_arvalid       : in    std_logic_vector (0 to 0);
         sAxi_arready       : out   std_logic_vector (0 to 0);
         sAxi_rid           : out   std_logic_vector (3 downto 0);
         sAxi_rdata         : out   std_logic_vector (511 downto 0);
         sAxi_rresp         : out   std_logic_vector (1 downto 0);
         sAxi_rlast         : out   std_logic_vector (0 to 0);
         sAxi_rvalid        : out   std_logic_vector (0 to 0);
         sAxi_rready        : in    std_logic_vector (0 to 0);
         mAxi_awid          : out   std_logic_vector (15 downto 0);
         mAxi_awaddr        : out   std_logic_vector (63 downto 0);
         mAxi_awlen         : out   std_logic_vector (7 downto 0);
         mAxi_awsize        : out   std_logic_vector (2 downto 0);
         mAxi_awburst       : out   std_logic_vector (1 downto 0);
         mAxi_awlock        : out   std_logic_vector (0 to 0);
         mAxi_awcache       : out   std_logic_vector (3 downto 0);
         mAxi_awprot        : out   std_logic_vector (2 downto 0);
         mAxi_awregion      : out   std_logic_vector (3 downto 0);
         mAxi_awqos         : out   std_logic_vector (3 downto 0);
         mAxi_awuser        : out   std_logic_vector (31 downto 0);
         mAxi_awvalid       : out   std_logic_vector (0 to 0);
         mAxi_awready       : in    std_logic_vector (0 to 0);
         mAxi_wdata         : out   std_logic_vector (511 downto 0);
         mAxi_wstrb         : out   std_logic_vector (63 downto 0);
         mAxi_wlast         : out   std_logic_vector (0 to 0);
         mAxi_wvalid        : out   std_logic_vector (0 to 0);
         mAxi_wready        : in    std_logic_vector (0 to 0);
         mAxi_bid           : in    std_logic_vector (15 downto 0);
         mAxi_bresp         : in    std_logic_vector (1 downto 0);
         mAxi_bvalid        : in    std_logic_vector (0 to 0);
         mAxi_bready        : out   std_logic_vector (0 to 0);
         mAxi_arid          : out   std_logic_vector (15 downto 0);
         mAxi_araddr        : out   std_logic_vector (63 downto 0);
         mAxi_arlen         : out   std_logic_vector (7 downto 0);
         mAxi_arsize        : out   std_logic_vector (2 downto 0);
         mAxi_arburst       : out   std_logic_vector (1 downto 0);
         mAxi_arlock        : out   std_logic_vector (0 to 0);
         mAxi_arcache       : out   std_logic_vector (3 downto 0);
         mAxi_arprot        : out   std_logic_vector (2 downto 0);
         mAxi_arregion      : out   std_logic_vector (3 downto 0);
         mAxi_arqos         : out   std_logic_vector (3 downto 0);
         mAxi_aruser        : out   std_logic_vector (31 downto 0);
         mAxi_arvalid       : out   std_logic_vector (0 to 0);
         mAxi_arready       : in    std_logic_vector (0 to 0);
         mAxi_rid           : in    std_logic_vector (15 downto 0);
         mAxi_rdata         : in    std_logic_vector (511 downto 0);
         mAxi_rresp         : in    std_logic_vector (1 downto 0);
         mAxi_rlast         : in    std_logic_vector (0 to 0);
         mAxi_rvalid        : in    std_logic_vector (0 to 0);
         mAxi_rready        : out   std_logic_vector (0 to 0);
         mAxi_buser         : in    std_logic;
         mAxi_ruser         : in    std_logic_vector (127 downto 0);
         mAxi_wid           : out   std_logic_vector (15 downto 0);
         mAxi_wuser         : out   std_logic_vector (127 downto 0);
         dmaClk             : in    std_logic;
         plRstN             : out   std_logic;
         plRefClk           : out   std_logic;
         dmaIrq             : in    std_logic;
         dmaRstN            : in    std_logic;
         dmaAck             : out   std_logic_vector (0 to 0)
         );
   end component;

   signal clk    : sl;
   signal rst    : sl;
   signal rstL   : sl;
   signal plRstN : sl;

   signal sAxilAwaddr : slv(31 downto 0);
   signal sAxilAraddr : slv(31 downto 0);

   signal usrIrqReq : sl;
   signal usrIrqAck : sl;

begin

   axiClk <= clk;
   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => clk,
         rstIn  => rstL,
         rstOut => axiRst);

   U_IRQ_FSM : entity axi_pcie_core.AxiPcieUltrascalePlusIrqFsm
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clock and Reset
         clk       => clk,
         rstL      => rstL,
         -- Interrupt Interface
         dmaIrq    => dmaIrq,
         usrIrqAck => usrIrqAck,
         usrIrqReq => usrIrqReq);

   U_PwrUpRst : entity surf.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',                          -- Active LOW reset
         OUT_POLARITY_G => '0',                          -- Active LOW reset
         DURATION_G     => getTimeRatio(250.0E+6, 1.0))  -- 1 s reset
      port map(
         clk    => clk,
         arst   => plRstN,
         rstOut => rstL);

   -------------------
   -- AXI PCIe IP Core
   -------------------
   U_AxiPcie : XilinxAlveoV80PcieBlockDesign
      port map (
         -- Clocks and Resets
         dmaClk             => clk,
         dmaRstN            => rstL,
         plRefClk           => clk,
         plRstN             => plRstN,
         -- Interrupt Interface
         dmaIrq             => usrIrqReq,
         dmaAck(0)          => usrIrqAck,
         -- PCIe PHY Interface
         gtPcieRefClk_clk_p => pciRefClkP,
         gtPcieRefClk_clk_n => pciRefClkN,
         gtPcie_grx_p       => pciRxP,
         gtPcie_grx_n       => pciRxN,
         gtPcie_gtx_p       => pciTxP,
         gtPcie_gtx_n       => pciTxN,
         -- Master AXI4 Interface
         mAxi_awid          => regWriteMaster.awid(15 downto 0),
         mAxi_awaddr        => regWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         mAxi_awlen         => regWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         mAxi_awsize        => regWriteMaster.awsize(2 downto 0),
         mAxi_awburst       => regWriteMaster.awburst(1 downto 0),
         mAxi_awlock(0)     => regWriteMaster.awlock(0),
         mAxi_awcache       => regWriteMaster.awcache,
         mAxi_awprot        => regWriteMaster.awprot,
         mAxi_awregion      => regWriteMaster.awregion(3 downto 0),
         mAxi_awqos         => regWriteMaster.awqos(3 downto 0),
         mAxi_awuser        => open,
         mAxi_awvalid(0)    => regWriteMaster.awvalid,
         mAxi_awready(0)    => regWriteSlave.awready,
         mAxi_wdata         => regWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         mAxi_wstrb         => regWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         mAxi_wlast(0)      => regWriteMaster.wlast,
         mAxi_wvalid(0)     => regWriteMaster.wvalid,
         mAxi_wready(0)     => regWriteSlave.wready,
         mAxi_bid           => regWriteSlave.bid(15 downto 0),
         mAxi_bresp         => AXI_RESP_OK_C,  -- Always respond OK
         mAxi_bvalid(0)     => regWriteSlave.bvalid,
         mAxi_bready(0)     => regWriteMaster.bready,
         mAxi_arid          => regReadMaster.arid(15 downto 0),
         mAxi_araddr        => regReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         mAxi_arlen         => regReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         mAxi_arsize        => regReadMaster.arsize(2 downto 0),
         mAxi_arburst       => regReadMaster.arburst(1 downto 0),
         mAxi_arlock(0)     => regReadMaster.arlock(0),
         mAxi_arcache       => regReadMaster.arcache,
         mAxi_arprot        => regReadMaster.arprot,
         mAxi_arregion      => regReadMaster.arregion(3 downto 0),
         mAxi_arqos         => regReadMaster.arqos(3 downto 0),
         mAxi_aruser        => open,
         mAxi_arvalid(0)    => regReadMaster.arvalid,
         mAxi_arready(0)    => regReadSlave.arready,
         mAxi_rid           => regReadSlave.rid(15 downto 0),
         mAxi_rdata         => regReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         mAxi_rresp         => AXI_RESP_OK_C,  -- Always respond OK
         mAxi_rlast(0)      => regReadSlave.rlast,
         mAxi_rvalid(0)     => regReadSlave.rvalid,
         mAxi_rready(0)     => regReadMaster.rready,
         maxi_buser         => '0',
         maxi_ruser         => (others => '0'),
         mAxi_wid           => open,
         mAxi_wuser         => open,
         -- PS DDR Interface
         psDDR_dq           => psDdrDq,
         psDDR_dqs_t        => psDdrDqsT,
         psDDR_dqs_c        => psDdrDqsC,
         psDDR_adr          => psDdrAdr,
         psDDR_ba           => psDdrBa,
         psDDR_bg           => psDdrBg,
         psDDR_act_n        => psDdrActN,
         psDDR_reset_n      => psDdrResetN,
         psDDR_ck_t         => psDdrCkT,
         psDDR_ck_c         => psDdrCkC,
         psDDR_cke          => psDdrCke,
         psDDR_cs_n         => psDdrCsN,
         psDDR_dm_n         => psDdrDmN,
         psDDR_odt          => psDdrOdt,
         psDdrClk_clk_p     => psDdrClkP,
         psDdrClk_clk_n     => psDdrClkN,
         -- Slave AXI4 Interface
         sAxi_awid          => dmaWriteMaster.awid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         sAxi_awaddr        => dmaWriteMaster.awaddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         sAxi_awregion      => dmaWriteMaster.awregion,
         sAxi_awlen         => dmaWriteMaster.awlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         sAxi_awsize        => dmaWriteMaster.awsize(2 downto 0),
         sAxi_awburst       => dmaWriteMaster.awburst(1 downto 0),
         sAxi_awvalid(0)    => dmaWriteMaster.awvalid,
         sAxi_awready(0)    => dmaWriteSlave.awready,
         sAxi_wdata         => dmaWriteMaster.wdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         sAxi_wstrb         => dmaWriteMaster.wstrb(AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         sAxi_wlast(0)      => dmaWriteMaster.wlast,
         sAxi_wvalid(0)     => dmaWriteMaster.wvalid,
         sAxi_wready(0)     => dmaWriteSlave.wready,
         sAxi_bid           => dmaWriteSlave.bid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         sAxi_bresp         => dmaWriteSlave.bresp(1 downto 0),
         sAxi_bvalid(0)     => dmaWriteSlave.bvalid,
         sAxi_bready(0)     => dmaWriteMaster.bready,
         sAxi_arid          => dmaReadMaster.arid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         sAxi_araddr        => dmaReadMaster.araddr(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         sAxi_arregion      => dmaReadMaster.arregion,
         sAxi_arlen         => dmaReadMaster.arlen(AXI_PCIE_CONFIG_C.LEN_BITS_C-1 downto 0),
         sAxi_arsize        => dmaReadMaster.arsize(2 downto 0),
         sAxi_arburst       => dmaReadMaster.arburst(1 downto 0),
         sAxi_arvalid(0)    => dmaReadMaster.arvalid,
         sAxi_arready(0)    => dmaReadSlave.arready,
         sAxi_rid           => dmaReadSlave.rid(AXI_PCIE_CONFIG_C.ID_BITS_C-1 downto 0),
         sAxi_rdata         => dmaReadSlave.rdata(8*AXI_PCIE_CONFIG_C.DATA_BYTES_C-1 downto 0),
         sAxi_rresp         => dmaReadSlave.rresp(1 downto 0),
         sAxi_rlast(0)      => dmaReadSlave.rlast,
         sAxi_rvalid(0)     => dmaReadSlave.rvalid,
         sAxi_rready(0)     => dmaReadMaster.rready,
         sAxi_arcache       => dmaReadMaster.arcache(3 downto 0),
         sAxi_arlock(0)     => dmaReadMaster.arlock(0),
         sAxi_arprot        => dmaReadMaster.arprot(2 downto 0),
         sAxi_arqos         => dmaReadMaster.arqos(3 downto 0),
         sAxi_awcache       => dmaWriteMaster.awcache(3 downto 0),
         sAxi_awlock(0)     => dmaWriteMaster.awlock(0),
         sAxi_awprot        => dmaWriteMaster.awprot(2 downto 0),
         sAxi_awqos         => dmaWriteMaster.awqos(3 downto 0));

end mapping;
