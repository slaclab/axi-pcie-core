-------------------------------------------------------------------------------
-- File       : MigClkCross.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-08-02
-- Last update: 2017-08-03
-------------------------------------------------------------------------------
-- Description: Wrapper for the AXI clock converter IP core
--              DDR4 is ~85% at 4kB burst
--              300 MHz x 85% = 252 MHz (matched to 250 MHz system clock)
-- Note: Requires a "store-and-forward" AXI FIFO between the MIG and this module
--       to prevent bandwidth bottle necking at this module
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

entity MigClkCross is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Slave Interface
      sAxiClk         : in  sl;
      sAxiRst         : in  sl;
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      sAxiReadMaster  : in  AxiReadMasterType;
      sAxiReadSlave   : out AxiReadSlaveType;
      -- Master Interface
      mAxiClk         : in  sl;
      mAxiRst         : in  sl;
      mAxiWriteMaster : out AxiWriteMasterType;
      mAxiWriteSlave  : in  AxiWriteSlaveType;
      mAxiReadMaster  : out AxiReadMasterType;
      mAxiReadSlave   : in  AxiReadSlaveType);
end MigClkCross;

architecture mapping of MigClkCross is

   component DdrClkCross
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awid     : in  std_logic_vector(3 downto 0);
         s_axi_awaddr   : in  std_logic_vector(31 downto 0);
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
         s_axi_wdata    : in  std_logic_vector(511 downto 0);
         s_axi_wstrb    : in  std_logic_vector(63 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bid      : out std_logic_vector(3 downto 0);
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_arid     : in  std_logic_vector(3 downto 0);
         s_axi_araddr   : in  std_logic_vector(31 downto 0);
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
         s_axi_rid      : out std_logic_vector(3 downto 0);
         s_axi_rdata    : out std_logic_vector(511 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_aclk     : in  std_logic;
         m_axi_aresetn  : in  std_logic;
         m_axi_awid     : out std_logic_vector(3 downto 0);
         m_axi_awaddr   : out std_logic_vector(31 downto 0);
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
         m_axi_wdata    : out std_logic_vector(511 downto 0);
         m_axi_wstrb    : out std_logic_vector(63 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bid      : in  std_logic_vector(3 downto 0);
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_arid     : out std_logic_vector(3 downto 0);
         m_axi_araddr   : out std_logic_vector(31 downto 0);
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
         m_axi_rid      : in  std_logic_vector(3 downto 0);
         m_axi_rdata    : in  std_logic_vector(511 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic);
   end component;

   signal sAxiRstL : sl;
   signal mAxiRstL : sl;

begin

   sAxiRstL <= not(sAxiRst);
   mAxiRstL <= not(mAxiRst);

   U_DdrClkCross : DdrClkCross
      port map (
         -- Master Interface
         s_axi_aclk     => sAxiClk,
         s_axi_aresetn  => sAxiRstL,
         s_axi_awid     => sAxiWriteMaster.awid(3 downto 0),
         s_axi_awaddr   => sAxiWriteMaster.awaddr(31 downto 0),
         s_axi_awlen    => sAxiWriteMaster.awlen(7 downto 0),
         s_axi_awsize   => sAxiWriteMaster.awsize(2 downto 0),
         s_axi_awburst  => sAxiWriteMaster.awburst(1 downto 0),
         s_axi_awlock   => sAxiWriteMaster.awlock(0 downto 0),
         s_axi_awcache  => sAxiWriteMaster.awcache(3 downto 0),
         s_axi_awprot   => sAxiWriteMaster.awprot(2 downto 0),
         s_axi_awregion => sAxiWriteMaster.awregion(3 downto 0),
         s_axi_awqos    => sAxiWriteMaster.awqos(3 downto 0),
         s_axi_awvalid  => sAxiWriteMaster.awvalid,
         s_axi_awready  => sAxiWriteSlave.awready,
         s_axi_wdata    => sAxiWriteMaster.wdata(511 downto 0),
         s_axi_wstrb    => sAxiWriteMaster.wstrb(63 downto 0),
         s_axi_wlast    => sAxiWriteMaster.wlast,
         s_axi_wvalid   => sAxiWriteMaster.wvalid,
         s_axi_wready   => sAxiWriteSlave.wready,
         s_axi_bid      => sAxiWriteSlave.bid(3 downto 0),
         s_axi_bresp    => sAxiWriteSlave.bresp(1 downto 0),
         s_axi_bvalid   => sAxiWriteSlave.bvalid,
         s_axi_bready   => sAxiWriteMaster.bready,
         s_axi_arid     => sAxiReadMaster.arid(3 downto 0),
         s_axi_araddr   => sAxiReadMaster.araddr(31 downto 0),
         s_axi_arlen    => sAxiReadMaster.arlen(7 downto 0),
         s_axi_arsize   => sAxiReadMaster.arsize(2 downto 0),
         s_axi_arburst  => sAxiReadMaster.arburst(1 downto 0),
         s_axi_arlock   => sAxiReadMaster.arlock(0 downto 0),
         s_axi_arcache  => sAxiReadMaster.arcache(3 downto 0),
         s_axi_arprot   => sAxiReadMaster.arprot(2 downto 0),
         s_axi_arregion => sAxiReadMaster.arregion(3 downto 0),
         s_axi_arqos    => sAxiReadMaster.arqos(3 downto 0),
         s_axi_arvalid  => sAxiReadMaster.arvalid,
         s_axi_arready  => sAxiReadSlave.arready,
         s_axi_rid      => sAxiReadSlave.rid(3 downto 0),
         s_axi_rdata    => sAxiReadSlave.rdata(511 downto 0),
         s_axi_rresp    => sAxiReadSlave.rresp(1 downto 0),
         s_axi_rlast    => sAxiReadSlave.rlast,
         s_axi_rvalid   => sAxiReadSlave.rvalid,
         s_axi_rready   => sAxiReadMaster.rready,
         -- Master Interface
         m_axi_aclk     => mAxiClk,
         m_axi_aresetn  => mAxiRstL,
         m_axi_awid     => mAxiWriteMaster.awid(3 downto 0),
         m_axi_awaddr   => mAxiWriteMaster.awaddr(31 downto 0),
         m_axi_awlen    => mAxiWriteMaster.awlen(7 downto 0),
         m_axi_awsize   => mAxiWriteMaster.awsize(2 downto 0),
         m_axi_awburst  => mAxiWriteMaster.awburst(1 downto 0),
         m_axi_awlock   => mAxiWriteMaster.awlock(0 downto 0),
         m_axi_awcache  => mAxiWriteMaster.awcache(3 downto 0),
         m_axi_awprot   => mAxiWriteMaster.awprot(2 downto 0),
         m_axi_awregion => mAxiWriteMaster.awregion(3 downto 0),
         m_axi_awqos    => mAxiWriteMaster.awqos(3 downto 0),
         m_axi_awvalid  => mAxiWriteMaster.awvalid,
         m_axi_awready  => mAxiWriteSlave.awready,
         m_axi_wdata    => mAxiWriteMaster.wdata(511 downto 0),
         m_axi_wstrb    => mAxiWriteMaster.wstrb(63 downto 0),
         m_axi_wlast    => mAxiWriteMaster.wlast,
         m_axi_wvalid   => mAxiWriteMaster.wvalid,
         m_axi_wready   => mAxiWriteSlave.wready,
         m_axi_bid      => mAxiWriteSlave.bid(3 downto 0),
         m_axi_bresp    => mAxiWriteSlave.bresp(1 downto 0),
         m_axi_bvalid   => mAxiWriteSlave.bvalid,
         m_axi_bready   => mAxiWriteMaster.bready,
         m_axi_arid     => mAxiReadMaster.arid(3 downto 0),
         m_axi_araddr   => mAxiReadMaster.araddr(31 downto 0),
         m_axi_arlen    => mAxiReadMaster.arlen(7 downto 0),
         m_axi_arsize   => mAxiReadMaster.arsize(2 downto 0),
         m_axi_arburst  => mAxiReadMaster.arburst(1 downto 0),
         m_axi_arlock   => mAxiReadMaster.arlock(0 downto 0),
         m_axi_arcache  => mAxiReadMaster.arcache(3 downto 0),
         m_axi_arprot   => mAxiReadMaster.arprot(2 downto 0),
         m_axi_arregion => mAxiReadMaster.arregion(3 downto 0),
         m_axi_arqos    => mAxiReadMaster.arqos(3 downto 0),
         m_axi_arvalid  => mAxiReadMaster.arvalid,
         m_axi_arready  => mAxiReadSlave.arready,
         m_axi_rid      => mAxiReadSlave.rid(3 downto 0),
         m_axi_rdata    => mAxiReadSlave.rdata(511 downto 0),
         m_axi_rresp    => mAxiReadSlave.rresp(1 downto 0),
         m_axi_rlast    => mAxiReadSlave.rlast,
         m_axi_rvalid   => mAxiReadSlave.rvalid,
         m_axi_rready   => mAxiReadMaster.rready);

end mapping;
