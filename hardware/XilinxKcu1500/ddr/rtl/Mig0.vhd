-------------------------------------------------------------------------------
-- File       : Mig0.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for the MIG core
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
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;

library axi_pcie_core;
use axi_pcie_core.MigPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Mig0 is
   generic (
      TPD_G : time := 1 ns);
   port (
      extRst         : in    sl := '0';
      -- AXI MEM Interface
      axiClk         : out   sl;
      axiRst         : out   sl;
      axiReady       : out   sl;
      axiWriteMaster : in    AxiWriteMasterType;
      axiWriteSlave  : out   AxiWriteSlaveType;
      axiReadMaster  : in    AxiReadMasterType;
      axiReadSlave   : out   AxiReadSlaveType;
      -- DDR Ports
      ddrClkP        : in    sl;
      ddrClkN        : in    sl;
      ddrOut         : out   DdrOutType;
      ddrInOut       : inout DdrInOutType);
end Mig0;

architecture mapping of Mig0 is

   component XilinxKcu1500Mig0Core
      port (
         c0_init_calib_complete     : out   std_logic;
         dbg_clk                    : out   std_logic;
         c0_sys_clk_p               : in    std_logic;
         c0_sys_clk_n               : in    std_logic;
         dbg_bus                    : out   std_logic_vector(511 downto 0);
         c0_ddr4_adr                : out   std_logic_vector(16 downto 0);
         c0_ddr4_ba                 : out   std_logic_vector(1 downto 0);
         c0_ddr4_cke                : out   std_logic_vector(0 downto 0);
         c0_ddr4_cs_n               : out   std_logic_vector(1 downto 0);
         c0_ddr4_dm_dbi_n           : inout std_logic_vector(8 downto 0);
         c0_ddr4_dq                 : inout std_logic_vector(71 downto 0);
         c0_ddr4_dqs_c              : inout std_logic_vector(8 downto 0);
         c0_ddr4_dqs_t              : inout std_logic_vector(8 downto 0);
         c0_ddr4_odt                : out   std_logic_vector(0 downto 0);
         c0_ddr4_bg                 : out   std_logic_vector(0 downto 0);
         c0_ddr4_reset_n            : out   std_logic;
         c0_ddr4_act_n              : out   std_logic;
         c0_ddr4_ck_c               : out   std_logic_vector(0 downto 0);
         c0_ddr4_ck_t               : out   std_logic_vector(0 downto 0);
         c0_ddr4_ui_clk             : out   std_logic;
         c0_ddr4_ui_clk_sync_rst    : out   std_logic;
         c0_ddr4_aresetn            : in    std_logic;
         c0_ddr4_s_axi_ctrl_awvalid : in    std_logic;
         c0_ddr4_s_axi_ctrl_awready : out   std_logic;
         c0_ddr4_s_axi_ctrl_awaddr  : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_ctrl_wvalid  : in    std_logic;
         c0_ddr4_s_axi_ctrl_wready  : out   std_logic;
         c0_ddr4_s_axi_ctrl_wdata   : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_ctrl_bvalid  : out   std_logic;
         c0_ddr4_s_axi_ctrl_bready  : in    std_logic;
         c0_ddr4_s_axi_ctrl_bresp   : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_ctrl_arvalid : in    std_logic;
         c0_ddr4_s_axi_ctrl_arready : out   std_logic;
         c0_ddr4_s_axi_ctrl_araddr  : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_ctrl_rvalid  : out   std_logic;
         c0_ddr4_s_axi_ctrl_rready  : in    std_logic;
         c0_ddr4_s_axi_ctrl_rdata   : out   std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_ctrl_rresp   : out   std_logic_vector(1 downto 0);
         c0_ddr4_interrupt          : out   std_logic;
         c0_ddr4_s_axi_awid         : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awaddr       : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_awlen        : in    std_logic_vector(7 downto 0);
         c0_ddr4_s_axi_awsize       : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awburst      : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_awlock       : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_awcache      : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awprot       : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awqos        : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awvalid      : in    std_logic;
         c0_ddr4_s_axi_awready      : out   std_logic;
         c0_ddr4_s_axi_wdata        : in    std_logic_vector(511 downto 0);
         c0_ddr4_s_axi_wstrb        : in    std_logic_vector(63 downto 0);
         c0_ddr4_s_axi_wlast        : in    std_logic;
         c0_ddr4_s_axi_wvalid       : in    std_logic;
         c0_ddr4_s_axi_wready       : out   std_logic;
         c0_ddr4_s_axi_bready       : in    std_logic;
         c0_ddr4_s_axi_bid          : out   std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_bresp        : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_bvalid       : out   std_logic;
         c0_ddr4_s_axi_arid         : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_araddr       : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_arlen        : in    std_logic_vector(7 downto 0);
         c0_ddr4_s_axi_arsize       : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arburst      : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_arlock       : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_arcache      : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arprot       : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arqos        : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arvalid      : in    std_logic;
         c0_ddr4_s_axi_arready      : out   std_logic;
         c0_ddr4_s_axi_rready       : in    std_logic;
         c0_ddr4_s_axi_rlast        : out   std_logic;
         c0_ddr4_s_axi_rvalid       : out   std_logic;
         c0_ddr4_s_axi_rresp        : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_rid          : out   std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_rdata        : out   std_logic_vector(511 downto 0);
         sys_rst                    : in    std_logic);
   end component;

   signal ddrWriteMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal ddrWriteSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
   signal ddrReadMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal ddrReadSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;

   signal ddrClk     : sl;
   signal ddrRst     : sl;
   signal ddrCalDone : sl;
   signal coreReset  : sl;
   signal coreRst    : sl;
   signal extRstL    : sl;

begin

   extRstL  <= not(extRst);
   axiReady <= ddrCalDone;

   U_MIG : XilinxKcu1500Mig0Core
      port map (
         c0_init_calib_complete     => ddrCalDone,
         dbg_clk                    => open,
         c0_sys_clk_p               => ddrClkP,
         c0_sys_clk_n               => ddrClkN,
         dbg_bus                    => open,
         c0_ddr4_adr                => ddrOut.addr,
         c0_ddr4_ba                 => ddrOut.ba,
         c0_ddr4_cke                => ddrOut.cke,
         c0_ddr4_cs_n               => ddrOut.csL,
         c0_ddr4_dm_dbi_n           => ddrInOut.dm,
         c0_ddr4_dq                 => ddrInOut.dq,
         c0_ddr4_dqs_c              => ddrInOut.dqsC,
         c0_ddr4_dqs_t              => ddrInOut.dqsT,
         c0_ddr4_odt                => ddrOut.odt,
         c0_ddr4_bg                 => ddrOut.bg,
         c0_ddr4_reset_n            => ddrOut.rstL,
         c0_ddr4_act_n              => ddrOut.actL,
         c0_ddr4_ck_c               => ddrOut.ckC,
         c0_ddr4_ck_t               => ddrOut.ckT,
         c0_ddr4_ui_clk             => ddrClk,
         c0_ddr4_ui_clk_sync_rst    => coreReset,
         c0_ddr4_aresetn            => extRstL,
         c0_ddr4_s_axi_ctrl_awvalid => AXI_LITE_WRITE_MASTER_INIT_C.awvalid,
         c0_ddr4_s_axi_ctrl_awready => open,
         c0_ddr4_s_axi_ctrl_awaddr  => AXI_LITE_WRITE_MASTER_INIT_C.awaddr,
         c0_ddr4_s_axi_ctrl_wvalid  => AXI_LITE_WRITE_MASTER_INIT_C.wvalid,
         c0_ddr4_s_axi_ctrl_wready  => open,
         c0_ddr4_s_axi_ctrl_wdata   => AXI_LITE_WRITE_MASTER_INIT_C.wdata,
         c0_ddr4_s_axi_ctrl_bvalid  => open,
         c0_ddr4_s_axi_ctrl_bready  => AXI_LITE_WRITE_MASTER_INIT_C.bready,
         c0_ddr4_s_axi_ctrl_bresp   => open,
         c0_ddr4_s_axi_ctrl_arvalid => AXI_LITE_READ_MASTER_INIT_C.arvalid,
         c0_ddr4_s_axi_ctrl_arready => open,
         c0_ddr4_s_axi_ctrl_araddr  => AXI_LITE_READ_MASTER_INIT_C.araddr,
         c0_ddr4_s_axi_ctrl_rvalid  => open,
         c0_ddr4_s_axi_ctrl_rready  => AXI_LITE_READ_MASTER_INIT_C.rready,
         c0_ddr4_s_axi_ctrl_rdata   => open,
         c0_ddr4_s_axi_ctrl_rresp   => open,
         c0_ddr4_interrupt          => open,
         c0_ddr4_s_axi_awid         => ddrWriteMaster.awid(3 downto 0),
         c0_ddr4_s_axi_awaddr       => ddrWriteMaster.awaddr(31 downto 0),
         c0_ddr4_s_axi_awlen        => ddrWriteMaster.awlen(7 downto 0),
         c0_ddr4_s_axi_awsize       => ddrWriteMaster.awsize(2 downto 0),
         c0_ddr4_s_axi_awburst      => ddrWriteMaster.awburst(1 downto 0),
         c0_ddr4_s_axi_awlock       => ddrWriteMaster.awlock(0 downto 0),
         c0_ddr4_s_axi_awcache      => ddrWriteMaster.awcache(3 downto 0),
         c0_ddr4_s_axi_awprot       => ddrWriteMaster.awprot(2 downto 0),
         c0_ddr4_s_axi_awqos        => ddrWriteMaster.awqos(3 downto 0),
         c0_ddr4_s_axi_awvalid      => ddrWriteMaster.awvalid,
         c0_ddr4_s_axi_awready      => ddrWriteSlave.awready,
         c0_ddr4_s_axi_wdata        => ddrWriteMaster.wdata(511 downto 0),
         c0_ddr4_s_axi_wstrb        => ddrWriteMaster.wstrb(63 downto 0),
         c0_ddr4_s_axi_wlast        => ddrWriteMaster.wlast,
         c0_ddr4_s_axi_wvalid       => ddrWriteMaster.wvalid,
         c0_ddr4_s_axi_wready       => ddrWriteSlave.wready,
         c0_ddr4_s_axi_bready       => ddrWriteMaster.bready,
         c0_ddr4_s_axi_bid          => ddrWriteSlave.bid(3 downto 0),
         c0_ddr4_s_axi_bresp        => ddrWriteSlave.bresp(1 downto 0),
         c0_ddr4_s_axi_bvalid       => ddrWriteSlave.bvalid,
         c0_ddr4_s_axi_arid         => ddrReadMaster.arid(3 downto 0),
         c0_ddr4_s_axi_araddr       => ddrReadMaster.araddr(31 downto 0),
         c0_ddr4_s_axi_arlen        => ddrReadMaster.arlen(7 downto 0),
         c0_ddr4_s_axi_arsize       => ddrReadMaster.arsize(2 downto 0),
         c0_ddr4_s_axi_arburst      => ddrReadMaster.arburst(1 downto 0),
         c0_ddr4_s_axi_arlock       => ddrReadMaster.arlock(0 downto 0),
         c0_ddr4_s_axi_arcache      => ddrReadMaster.arcache(3 downto 0),
         c0_ddr4_s_axi_arprot       => ddrReadMaster.arprot(2 downto 0),
         c0_ddr4_s_axi_arqos        => ddrReadMaster.arqos(3 downto 0),
         c0_ddr4_s_axi_arvalid      => ddrReadMaster.arvalid,
         c0_ddr4_s_axi_arready      => ddrReadSlave.arready,
         c0_ddr4_s_axi_rready       => ddrReadMaster.rready,
         c0_ddr4_s_axi_rlast        => ddrReadSlave.rlast,
         c0_ddr4_s_axi_rvalid       => ddrReadSlave.rvalid,
         c0_ddr4_s_axi_rresp        => ddrReadSlave.rresp(1 downto 0),
         c0_ddr4_s_axi_rid          => ddrReadSlave.rid(3 downto 0),
         c0_ddr4_s_axi_rdata        => ddrReadSlave.rdata(511 downto 0),
         sys_rst                    => extRst);

   coreRst <= coreReset and not(ddrCalDone);

   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ddrClk,
         rstIn  => coreRst,
         rstOut => ddrRst);

   axiClk <= ddrClk;
   axiRst <= ddrRst;

   ddrWriteMaster <= axiWriteMaster;
   axiWriteSlave  <= ddrWriteSlave;

   ddrReadMaster <= axiReadMaster;
   axiReadSlave  <= ddrReadSlave;

end mapping;
