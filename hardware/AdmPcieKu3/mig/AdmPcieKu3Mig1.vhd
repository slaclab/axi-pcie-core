-------------------------------------------------------------------------------
-- File       : AdmPcieKu3Mig1.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2017-04-06
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AdmPcieKu3Mig1 is
   generic (
      TPD_G           : time    := 1 ns);
   port (
      -- System Clock and reset
      sysClk          : in    sl;
      sysRst          : in    sl;
      -- AXI MEM Interface (axiClk domain)
      axiClk          : out   sl;
      axiRst          : out   sl;
      axiWriteMaster  : in    AxiWriteMasterType;
      axiWriteSlave   : out   AxiWriteSlaveType;
      axiReadMaster   : in    AxiReadMasterType;
      axiReadSlave    : out   AxiReadSlaveType;
      -- Optional AXI-Lite Interface (sysClk domain)
      axilReadMaster  : in    AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- DDR3 SO-DIMM Ports
      ddrClkP         : in    sl;
      ddrClkN         : in    sl;
      ddrDqsP         : inout slv(8 downto 0);
      ddrDqsN         : inout slv(8 downto 0);
      ddrDq           : inout slv(71 downto 0);
      ddrA            : out   slv(15 downto 0);
      ddrBa           : out   slv(2 downto 0);
      ddrCsL          : out   slv(1 downto 0);
      ddrOdt          : out   slv(1 downto 0);
      ddrCke          : out   slv(1 downto 0);
      ddrCkP          : out   slv(1 downto 0);
      ddrCkN          : out   slv(1 downto 0);
      ddrWeL          : out   sl;
      ddrRasL         : out   sl;
      ddrCasL         : out   sl;
      ddrRstL         : out   sl);
end AdmPcieKu3Mig1;

architecture mapping of AdmPcieKu3Mig1 is

   component AdmPcieKu3MigPhy
      port (
         c0_init_calib_complete     : out   std_logic;
         dbg_clk                    : out   std_logic;
         c0_sys_clk_p               : in    std_logic;
         c0_sys_clk_n               : in    std_logic;
         dbg_bus                    : out   std_logic_vector(511 downto 0);
         c0_ddr3_addr               : out   std_logic_vector(15 downto 0);
         c0_ddr3_ba                 : out   std_logic_vector(2 downto 0);
         c0_ddr3_cas_n              : out   std_logic;
         c0_ddr3_cke                : out   std_logic_vector(1 downto 0);
         c0_ddr3_ck_n               : out   std_logic_vector(1 downto 0);
         c0_ddr3_ck_p               : out   std_logic_vector(1 downto 0);
         c0_ddr3_cs_n               : out   std_logic_vector(1 downto 0);
         c0_ddr3_dq                 : inout std_logic_vector(71 downto 0);
         c0_ddr3_dqs_n              : inout std_logic_vector(8 downto 0);
         c0_ddr3_dqs_p              : inout std_logic_vector(8 downto 0);
         c0_ddr3_odt                : out   std_logic_vector(1 downto 0);
         c0_ddr3_ras_n              : out   std_logic;
         c0_ddr3_reset_n            : out   std_logic;
         c0_ddr3_we_n               : out   std_logic;
         c0_ddr3_ui_clk             : out   std_logic;
         c0_ddr3_ui_clk_sync_rst    : out   std_logic;
         c0_ddr3_aresetn            : in    std_logic;
         c0_ddr3_s_axi_ctrl_awvalid : in    std_logic;
         c0_ddr3_s_axi_ctrl_awready : out   std_logic;
         c0_ddr3_s_axi_ctrl_awaddr  : in    std_logic_vector(31 downto 0);
         c0_ddr3_s_axi_ctrl_wvalid  : in    std_logic;
         c0_ddr3_s_axi_ctrl_wready  : out   std_logic;
         c0_ddr3_s_axi_ctrl_wdata   : in    std_logic_vector(31 downto 0);
         c0_ddr3_s_axi_ctrl_bvalid  : out   std_logic;
         c0_ddr3_s_axi_ctrl_bready  : in    std_logic;
         c0_ddr3_s_axi_ctrl_bresp   : out   std_logic_vector(1 downto 0);
         c0_ddr3_s_axi_ctrl_arvalid : in    std_logic;
         c0_ddr3_s_axi_ctrl_arready : out   std_logic;
         c0_ddr3_s_axi_ctrl_araddr  : in    std_logic_vector(31 downto 0);
         c0_ddr3_s_axi_ctrl_rvalid  : out   std_logic;
         c0_ddr3_s_axi_ctrl_rready  : in    std_logic;
         c0_ddr3_s_axi_ctrl_rdata   : out   std_logic_vector(31 downto 0);
         c0_ddr3_s_axi_ctrl_rresp   : out   std_logic_vector(1 downto 0);
         c0_ddr3_interrupt          : out   std_logic;
         c0_ddr3_s_axi_awid         : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_awaddr       : in    std_logic_vector(32 downto 0);
         c0_ddr3_s_axi_awlen        : in    std_logic_vector(7 downto 0);
         c0_ddr3_s_axi_awsize       : in    std_logic_vector(2 downto 0);
         c0_ddr3_s_axi_awburst      : in    std_logic_vector(1 downto 0);
         c0_ddr3_s_axi_awlock       : in    std_logic_vector(0 downto 0);
         c0_ddr3_s_axi_awcache      : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_awprot       : in    std_logic_vector(2 downto 0);
         c0_ddr3_s_axi_awqos        : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_awvalid      : in    std_logic;
         c0_ddr3_s_axi_awready      : out   std_logic;
         c0_ddr3_s_axi_wdata        : in    std_logic_vector(511 downto 0);
         c0_ddr3_s_axi_wstrb        : in    std_logic_vector(63 downto 0);
         c0_ddr3_s_axi_wlast        : in    std_logic;
         c0_ddr3_s_axi_wvalid       : in    std_logic;
         c0_ddr3_s_axi_wready       : out   std_logic;
         c0_ddr3_s_axi_bready       : in    std_logic;
         c0_ddr3_s_axi_bid          : out   std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_bresp        : out   std_logic_vector(1 downto 0);
         c0_ddr3_s_axi_bvalid       : out   std_logic;
         c0_ddr3_s_axi_arid         : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_araddr       : in    std_logic_vector(32 downto 0);
         c0_ddr3_s_axi_arlen        : in    std_logic_vector(7 downto 0);
         c0_ddr3_s_axi_arsize       : in    std_logic_vector(2 downto 0);
         c0_ddr3_s_axi_arburst      : in    std_logic_vector(1 downto 0);
         c0_ddr3_s_axi_arlock       : in    std_logic_vector(0 downto 0);
         c0_ddr3_s_axi_arcache      : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_arprot       : in    std_logic_vector(2 downto 0);
         c0_ddr3_s_axi_arqos        : in    std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_arvalid      : in    std_logic;
         c0_ddr3_s_axi_arready      : out   std_logic;
         c0_ddr3_s_axi_rready       : in    std_logic;
         c0_ddr3_s_axi_rlast        : out   std_logic;
         c0_ddr3_s_axi_rvalid       : out   std_logic;
         c0_ddr3_s_axi_rresp        : out   std_logic_vector(1 downto 0);
         c0_ddr3_s_axi_rid          : out   std_logic_vector(3 downto 0);
         c0_ddr3_s_axi_rdata        : out   std_logic_vector(511 downto 0);
         sys_rst                    : in    std_logic);
   end component;

   signal ddrWriteMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal ddrWriteSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
   signal ddrReadMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal ddrReadSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;   
   
   signal ddrClk     : sl;
   signal ddrRst     : sl;
   signal dbgClk     : sl;
   signal ddrCalDone : sl;
   signal ddrIrq     : sl;
   signal dbgBus     : slv(511 downto 0);
   signal coreRst    : slv(1 downto 0);
   signal sysRstL    : sl;

begin

   axiClk  <= ddrClk;
   axiRst  <= ddrRst;
   sysRstL <= not(sysRst);
   
   ddrWriteMaster <= axiWriteMaster;
   axiWriteSlave  <= ddrWriteSlave;
   ddrReadMaster  <= axiReadMaster;
   axiReadSlave   <= ddrReadSlave;

   U_MIG : AdmPcieKu3MigPhy
      port map (
         -- DDR Interface
         c0_sys_clk_p               => ddrClkP,
         c0_sys_clk_n               => ddrClkN,
         c0_ddr3_addr               => ddrA,
         c0_ddr3_ba                 => ddrBa,
         c0_ddr3_cas_n              => ddrCasL,
         c0_ddr3_cke                => ddrCke,
         c0_ddr3_ck_n               => ddrCkN,
         c0_ddr3_ck_p               => ddrCkP,
         c0_ddr3_cs_n               => ddrCsL,
         c0_ddr3_dq                 => ddrDq,
         c0_ddr3_dqs_n              => ddrDqsN,
         c0_ddr3_dqs_p              => ddrDqsP,
         c0_ddr3_odt                => ddrOdt,
         c0_ddr3_ras_n              => ddrRasL,
         c0_ddr3_reset_n            => ddrRstL,
         c0_ddr3_we_n               => ddrWeL,
         -- SYS Interface
         c0_ddr3_ui_clk             => ddrClk,
         c0_ddr3_ui_clk_sync_rst    => coreRst(0),
         c0_ddr3_aresetn            => sysRstL,
         sys_rst                    => sysRst,
         -- DEBUG Interface
         dbg_clk                    => dbgClk,
         dbg_bus                    => dbgBus,
         c0_init_calib_complete     => ddrCalDone,
         -- ECC Monitoring Interface
         c0_ddr3_s_axi_ctrl_awvalid => axilWriteMaster.awvalid,
         c0_ddr3_s_axi_ctrl_awready => axilWriteSlave.awready,
         c0_ddr3_s_axi_ctrl_awaddr  => axilWriteMaster.awaddr,
         c0_ddr3_s_axi_ctrl_wvalid  => axilWriteMaster.wvalid,
         c0_ddr3_s_axi_ctrl_wready  => axilWriteSlave.wready,
         c0_ddr3_s_axi_ctrl_wdata   => axilWriteMaster.wdata,
         c0_ddr3_s_axi_ctrl_bvalid  => axilWriteSlave.bvalid,
         c0_ddr3_s_axi_ctrl_bready  => axilWriteMaster.bready,
         c0_ddr3_s_axi_ctrl_bresp   => axilWriteSlave.bresp,
         c0_ddr3_s_axi_ctrl_arvalid => axilReadMaster.arvalid,
         c0_ddr3_s_axi_ctrl_arready => axilReadSlave.arready,
         c0_ddr3_s_axi_ctrl_araddr  => axilReadMaster.araddr,
         c0_ddr3_s_axi_ctrl_rvalid  => axilReadSlave.rvalid,
         c0_ddr3_s_axi_ctrl_rready  => axilReadMaster.rready,
         c0_ddr3_s_axi_ctrl_rdata   => axilReadSlave.rdata,
         c0_ddr3_s_axi_ctrl_rresp   => axilReadSlave.rresp,
         c0_ddr3_interrupt          => ddrIrq,
         -- MEM Interface
         c0_ddr3_s_axi_awid         => ddrWriteMaster.awid(3 downto 0),
         c0_ddr3_s_axi_awaddr       => ddrWriteMaster.awaddr(32 downto 0),
         c0_ddr3_s_axi_awlen        => ddrWriteMaster.awlen(7 downto 0),
         c0_ddr3_s_axi_awsize       => ddrWriteMaster.awsize(2 downto 0),
         c0_ddr3_s_axi_awburst      => ddrWriteMaster.awburst(1 downto 0),
         c0_ddr3_s_axi_awlock       => ddrWriteMaster.awlock(0 downto 0),
         c0_ddr3_s_axi_awcache      => ddrWriteMaster.awcache(3 downto 0),
         c0_ddr3_s_axi_awprot       => ddrWriteMaster.awprot(2 downto 0),
         c0_ddr3_s_axi_awqos        => ddrWriteMaster.awqos(3 downto 0),
         c0_ddr3_s_axi_awvalid      => ddrWriteMaster.awvalid,
         c0_ddr3_s_axi_awready      => ddrWriteSlave.awready,
         c0_ddr3_s_axi_wdata        => ddrWriteMaster.wdata(511 downto 0),
         c0_ddr3_s_axi_wstrb        => ddrWriteMaster.wstrb(63 downto 0),
         c0_ddr3_s_axi_wlast        => ddrWriteMaster.wlast,
         c0_ddr3_s_axi_wvalid       => ddrWriteMaster.wvalid,
         c0_ddr3_s_axi_wready       => ddrWriteSlave.wready,
         c0_ddr3_s_axi_bready       => ddrWriteMaster.bready,
         c0_ddr3_s_axi_bid          => ddrWriteSlave.bid(3 downto 0),
         c0_ddr3_s_axi_bresp        => ddrWriteSlave.bresp(1 downto 0),
         c0_ddr3_s_axi_bvalid       => ddrWriteSlave.bvalid,
         c0_ddr3_s_axi_arid         => ddrReadMaster.arid(3 downto 0),
         c0_ddr3_s_axi_araddr       => ddrReadMaster.araddr(32 downto 0),
         c0_ddr3_s_axi_arlen        => ddrReadMaster.arlen(7 downto 0),
         c0_ddr3_s_axi_arsize       => ddrReadMaster.arsize(2 downto 0),
         c0_ddr3_s_axi_arburst      => ddrReadMaster.arburst(1 downto 0),
         c0_ddr3_s_axi_arlock       => ddrReadMaster.arlock(0 downto 0),
         c0_ddr3_s_axi_arcache      => ddrReadMaster.arcache(3 downto 0),
         c0_ddr3_s_axi_arprot       => ddrReadMaster.arprot(2 downto 0),
         c0_ddr3_s_axi_arqos        => ddrReadMaster.arqos(3 downto 0),
         c0_ddr3_s_axi_arvalid      => ddrReadMaster.arvalid,
         c0_ddr3_s_axi_arready      => ddrReadSlave.arready,
         c0_ddr3_s_axi_rready       => ddrReadMaster.rready,
         c0_ddr3_s_axi_rlast        => ddrReadSlave.rlast,
         c0_ddr3_s_axi_rvalid       => ddrReadSlave.rvalid,
         c0_ddr3_s_axi_rresp        => ddrReadSlave.rresp(1 downto 0),
         c0_ddr3_s_axi_rid          => ddrReadSlave.rid(3 downto 0),
         c0_ddr3_s_axi_rdata        => ddrReadSlave.rdata(511 downto 0));

   process(ddrClk)
   begin
      if rising_edge(ddrClk) then
         coreRst(1) <= coreRst(0) after TPD_G;  -- Register to help with timing
         ddrRst     <= coreRst(1) after TPD_G;  -- Register to help with timing
      end if;
   end process;

end mapping;
