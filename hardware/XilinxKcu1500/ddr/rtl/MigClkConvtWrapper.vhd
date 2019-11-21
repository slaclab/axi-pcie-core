-------------------------------------------------------------------------------
-- File       : MigClkConvtWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'PGP PCIe APP DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'PGP PCIe APP DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;

entity MigClkConvtWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- USER AXI Memory Interface (axiClk domain)
      axiClk         : in  sl;
      axiRst         : in  sl;
      axiWriteMaster : in  AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
      axiWriteSlave  : out AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
      axiReadMaster  : in  AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
      axiReadSlave   : out AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;
      -- DDR AXI Memory Interface (ddrClk domain)
      ddrClk         : in  sl;
      ddrRst         : in  sl;
      ddrWriteMaster : out AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
      ddrWriteSlave  : in  AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
      ddrReadMaster  : out AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
      ddrReadSlave   : in  AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C);
end MigClkConvtWrapper;

architecture mapping of MigClkConvtWrapper is

   component MigClkConvt
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awid     : in  std_logic_vector (3 downto 0);
         s_axi_awaddr   : in  std_logic_vector (63 downto 0);
         s_axi_awlen    : in  std_logic_vector (7 downto 0);
         s_axi_awsize   : in  std_logic_vector (2 downto 0);
         s_axi_awburst  : in  std_logic_vector (1 downto 0);
         s_axi_awlock   : in  std_logic_vector (0 to 0);
         s_axi_awcache  : in  std_logic_vector (3 downto 0);
         s_axi_awprot   : in  std_logic_vector (2 downto 0);
         s_axi_awregion : in  std_logic_vector (3 downto 0);
         s_axi_awqos    : in  std_logic_vector (3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector (511 downto 0);
         s_axi_wstrb    : in  std_logic_vector (63 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bid      : out std_logic_vector (3 downto 0);
         s_axi_bresp    : out std_logic_vector (1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_arid     : in  std_logic_vector (3 downto 0);
         s_axi_araddr   : in  std_logic_vector (63 downto 0);
         s_axi_arlen    : in  std_logic_vector (7 downto 0);
         s_axi_arsize   : in  std_logic_vector (2 downto 0);
         s_axi_arburst  : in  std_logic_vector (1 downto 0);
         s_axi_arlock   : in  std_logic_vector (0 to 0);
         s_axi_arcache  : in  std_logic_vector (3 downto 0);
         s_axi_arprot   : in  std_logic_vector (2 downto 0);
         s_axi_arregion : in  std_logic_vector (3 downto 0);
         s_axi_arqos    : in  std_logic_vector (3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rid      : out std_logic_vector (3 downto 0);
         s_axi_rdata    : out std_logic_vector (511 downto 0);
         s_axi_rresp    : out std_logic_vector (1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_aclk     : in  std_logic;
         m_axi_aresetn  : in  std_logic;
         m_axi_awid     : out std_logic_vector (3 downto 0);
         m_axi_awaddr   : out std_logic_vector (63 downto 0);
         m_axi_awlen    : out std_logic_vector (7 downto 0);
         m_axi_awsize   : out std_logic_vector (2 downto 0);
         m_axi_awburst  : out std_logic_vector (1 downto 0);
         m_axi_awlock   : out std_logic_vector (0 to 0);
         m_axi_awcache  : out std_logic_vector (3 downto 0);
         m_axi_awprot   : out std_logic_vector (2 downto 0);
         m_axi_awregion : out std_logic_vector (3 downto 0);
         m_axi_awqos    : out std_logic_vector (3 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector (511 downto 0);
         m_axi_wstrb    : out std_logic_vector (63 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bid      : in  std_logic_vector (3 downto 0);
         m_axi_bresp    : in  std_logic_vector (1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_arid     : out std_logic_vector (3 downto 0);
         m_axi_araddr   : out std_logic_vector (63 downto 0);
         m_axi_arlen    : out std_logic_vector (7 downto 0);
         m_axi_arsize   : out std_logic_vector (2 downto 0);
         m_axi_arburst  : out std_logic_vector (1 downto 0);
         m_axi_arlock   : out std_logic_vector (0 to 0);
         m_axi_arcache  : out std_logic_vector (3 downto 0);
         m_axi_arprot   : out std_logic_vector (2 downto 0);
         m_axi_arregion : out std_logic_vector (3 downto 0);
         m_axi_arqos    : out std_logic_vector (3 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rid      : in  std_logic_vector (3 downto 0);
         m_axi_rdata    : in  std_logic_vector (511 downto 0);
         m_axi_rresp    : in  std_logic_vector (1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic);
   end component;

   signal axiRstL : sl;
   signal ddrRstL : sl;

begin

   axiRstL <= not(axiRst);
   ddrRstL <= not(ddrRst);

   ------------------------
   -- MIG
   ------------------------
   U_Clk_Convt : MigClkConvt
      port map (
         -- Slave Ports
         s_axi_aclk     => axiClk,
         s_axi_aresetn  => axiRstL,
         s_axi_awid     => axiWriteMaster.awid(3 downto 0),
         s_axi_awaddr   => axiWriteMaster.awaddr(63 downto 0),
         s_axi_awlen    => axiWriteMaster.awlen(7 downto 0),
         s_axi_awsize   => axiWriteMaster.awsize(2 downto 0),
         s_axi_awburst  => axiWriteMaster.awburst(1 downto 0),
         s_axi_awlock   => axiWriteMaster.awlock(0 downto 0),
         s_axi_awcache  => axiWriteMaster.awcache(3 downto 0),
         s_axi_awprot   => axiWriteMaster.awprot(2 downto 0),
         s_axi_awregion => axiWriteMaster.awregion(3 downto 0),
         s_axi_awqos    => axiWriteMaster.awqos(3 downto 0),
         s_axi_awvalid  => axiWriteMaster.awvalid,
         s_axi_awready  => axiWriteSlave.awready,
         s_axi_wdata    => axiWriteMaster.wdata(511 downto 0),
         s_axi_wstrb    => axiWriteMaster.wstrb(63 downto 0),
         s_axi_wlast    => axiWriteMaster.wlast,
         s_axi_wvalid   => axiWriteMaster.wvalid,
         s_axi_wready   => axiWriteSlave.wready,
         s_axi_bid      => axiWriteSlave.bid(3 downto 0),
         s_axi_bresp    => axiWriteSlave.bresp(1 downto 0),
         s_axi_bvalid   => axiWriteSlave.bvalid,
         s_axi_bready   => axiWriteMaster.bready,
         s_axi_arid     => axiReadMaster.arid(3 downto 0),
         s_axi_araddr   => axiReadMaster.araddr(63 downto 0),
         s_axi_arlen    => axiReadMaster.arlen(7 downto 0),
         s_axi_arsize   => axiReadMaster.arsize(2 downto 0),
         s_axi_arburst  => axiReadMaster.arburst(1 downto 0),
         s_axi_arlock   => axiReadMaster.arlock(0 downto 0),
         s_axi_arcache  => axiReadMaster.arcache(3 downto 0),
         s_axi_arprot   => axiReadMaster.arprot(2 downto 0),
         s_axi_arregion => axiReadMaster.arregion(3 downto 0),
         s_axi_arqos    => axiReadMaster.arqos(3 downto 0),
         s_axi_arvalid  => axiReadMaster.arvalid,
         s_axi_arready  => axiReadSlave.arready,
         s_axi_rid      => axiReadSlave.rid(3 downto 0),
         s_axi_rdata    => axiReadSlave.rdata(511 downto 0),
         s_axi_rresp    => axiReadSlave.rresp(1 downto 0),
         s_axi_rlast    => axiReadSlave.rlast,
         s_axi_rvalid   => axiReadSlave.rvalid,
         s_axi_rready   => axiReadMaster.rready,
         -- Master Ports
         m_axi_aclk     => ddrClk,
         m_axi_aresetn  => ddrRstL,
         m_axi_awid     => ddrWriteMaster.awid(3 downto 0),
         m_axi_awaddr   => ddrWriteMaster.awaddr(63 downto 0),
         m_axi_awlen    => ddrWriteMaster.awlen(7 downto 0),
         m_axi_awsize   => ddrWriteMaster.awsize(2 downto 0),
         m_axi_awburst  => ddrWriteMaster.awburst(1 downto 0),
         m_axi_awlock   => ddrWriteMaster.awlock(0 downto 0),
         m_axi_awcache  => ddrWriteMaster.awcache(3 downto 0),
         m_axi_awprot   => ddrWriteMaster.awprot(2 downto 0),
         m_axi_awregion => ddrWriteMaster.awregion(3 downto 0),
         m_axi_awqos    => ddrWriteMaster.awqos(3 downto 0),
         m_axi_awvalid  => ddrWriteMaster.awvalid,
         m_axi_awready  => ddrWriteSlave.awready,
         m_axi_wdata    => ddrWriteMaster.wdata(511 downto 0),
         m_axi_wstrb    => ddrWriteMaster.wstrb(63 downto 0),
         m_axi_wlast    => ddrWriteMaster.wlast,
         m_axi_wvalid   => ddrWriteMaster.wvalid,
         m_axi_wready   => ddrWriteSlave.wready,
         m_axi_bid      => ddrWriteSlave.bid(3 downto 0),
         m_axi_bresp    => ddrWriteSlave.bresp(1 downto 0),
         m_axi_bvalid   => ddrWriteSlave.bvalid,
         m_axi_bready   => ddrWriteMaster.bready,
         m_axi_arid     => ddrReadMaster.arid(3 downto 0),
         m_axi_araddr   => ddrReadMaster.araddr(63 downto 0),
         m_axi_arlen    => ddrReadMaster.arlen(7 downto 0),
         m_axi_arsize   => ddrReadMaster.arsize(2 downto 0),
         m_axi_arburst  => ddrReadMaster.arburst(1 downto 0),
         m_axi_arlock   => ddrReadMaster.arlock(0 downto 0),
         m_axi_arcache  => ddrReadMaster.arcache(3 downto 0),
         m_axi_arprot   => ddrReadMaster.arprot(2 downto 0),
         m_axi_arregion => ddrReadMaster.arregion(3 downto 0),
         m_axi_arqos    => ddrReadMaster.arqos(3 downto 0),
         m_axi_arvalid  => ddrReadMaster.arvalid,
         m_axi_arready  => ddrReadSlave.arready,
         m_axi_rid      => ddrReadSlave.rid(3 downto 0),
         m_axi_rdata    => ddrReadSlave.rdata(511 downto 0),
         m_axi_rresp    => ddrReadSlave.rresp(1 downto 0),
         m_axi_rlast    => ddrReadSlave.rlast,
         m_axi_rvalid   => ddrReadSlave.rvalid,
         m_axi_rready   => ddrReadMaster.rready);

end mapping;
