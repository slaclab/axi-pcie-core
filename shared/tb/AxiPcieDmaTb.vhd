-------------------------------------------------------------------------------
-- File       : AxiPcieDmaTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the AxiPcieDmaTb module
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 AMC Development'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 AMC Development', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity AxiPcieDmaTb is end AxiPcieDmaTb;

architecture testbed of AxiPcieDmaTb is

   component AxiBram
      port (
         s_aclk        : in  std_logic;
         s_aresetn     : in  std_logic;
         s_axi_awid    : in  std_logic_vector(3 downto 0);
         s_axi_awaddr  : in  std_logic_vector(31 downto 0);
         s_axi_awlen   : in  std_logic_vector(7 downto 0);
         s_axi_awsize  : in  std_logic_vector(2 downto 0);
         s_axi_awburst : in  std_logic_vector(1 downto 0);
         s_axi_awvalid : in  std_logic;
         s_axi_awready : out std_logic;
         s_axi_wdata   : in  std_logic_vector(255 downto 0);
         s_axi_wstrb   : in  std_logic_vector(31 downto 0);
         s_axi_wlast   : in  std_logic;
         s_axi_wvalid  : in  std_logic;
         s_axi_wready  : out std_logic;
         s_axi_bid     : out std_logic_vector(3 downto 0);
         s_axi_bresp   : out std_logic_vector(1 downto 0);
         s_axi_bvalid  : out std_logic;
         s_axi_bready  : in  std_logic;
         s_axi_arid    : in  std_logic_vector(3 downto 0);
         s_axi_araddr  : in  std_logic_vector(31 downto 0);
         s_axi_arlen   : in  std_logic_vector(7 downto 0);
         s_axi_arsize  : in  std_logic_vector(2 downto 0);
         s_axi_arburst : in  std_logic_vector(1 downto 0);
         s_axi_arvalid : in  std_logic;
         s_axi_arready : out std_logic;
         s_axi_rid     : out std_logic_vector(3 downto 0);
         s_axi_rdata   : out std_logic_vector(255 downto 0);
         s_axi_rresp   : out std_logic_vector(1 downto 0);
         s_axi_rlast   : out std_logic;
         s_axi_rvalid  : out std_logic;
         s_axi_rready  : in  std_logic
         );
   end component;

   constant CLK_PERIOD_C : time := 10 ns;
   constant TPD_G        : time := CLK_PERIOD_C/4;

   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 1,               -- 8-bit data interface
      -- TDATA_BYTES_C => 2,              -- 16-bit data interface
      -- TDATA_BYTES_C => 4,              -- 32-bit data interface
      -- TDATA_BYTES_C => 8,              -- 64-bit data interface
      -- TDATA_BYTES_C => 16,              -- 128-bit data interface
      -- TDATA_BYTES_C => 32,              -- 256-bit data interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   constant PRBS_SEED_SIZE_C : positive := 32;

   type RegType is record
      packetLength : slv(31 downto 0);
      trig         : sl;
      txBusy       : sl;
      errorDet     : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      packetLength => toSlv(0,32),
      trig         => '0',
      txBusy       => '0',
      errorDet     => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal clk  : sl := '0';
   signal rst  : sl := '0';
   signal rstL : sl := '1';

   signal memWriteMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal memWriteSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
   signal memReadMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal memReadSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;

   signal dmaObMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal dmaObSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
   signal dmaIbMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal dmaIbSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal txMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal txSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal updatedResults : sl;
   signal errorDet       : sl;
   signal rxBusy         : sl;
   signal txBusy         : sl;

begin

   ---------------------------
   -- Generate clock and reset
   ---------------------------
   U_ClkRst : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_C,
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1000 ns)  -- Hold reset for this long)
      port map (
         clkP => clk,
         clkN => open,
         rst  => rst,
         rstL => rstL);

   -------------
   -- AXI Memory
   -------------
   U_AxiBram : AxiBram
      port map (
         s_aclk        => clk,
         s_aresetn     => rstL,
         s_axi_awid    => memWriteMaster.awid(3 downto 0),
         s_axi_awaddr  => memWriteMaster.awaddr(31 downto 0),
         s_axi_awlen   => memWriteMaster.awlen(7 downto 0),
         s_axi_awsize  => memWriteMaster.awsize(2 downto 0),
         s_axi_awburst => memWriteMaster.awburst(1 downto 0),
         s_axi_awvalid => memWriteMaster.awvalid,
         s_axi_awready => memWriteSlave.awready,
         s_axi_wdata   => memWriteMaster.wdata(255 downto 0),
         s_axi_wstrb   => memWriteMaster.wstrb(31 downto 0),
         s_axi_wlast   => memWriteMaster.wlast,
         s_axi_wvalid  => memWriteMaster.wvalid,
         s_axi_wready  => memWriteSlave.wready,
         s_axi_bid     => memWriteSlave.bid(3 downto 0),
         s_axi_bresp   => memWriteSlave.bresp(1 downto 0),
         s_axi_bvalid  => memWriteSlave.bvalid,
         s_axi_bready  => memWriteMaster.bready,
         s_axi_arid    => memReadMaster.arid(3 downto 0),
         s_axi_araddr  => memReadMaster.araddr(31 downto 0),
         s_axi_arlen   => memReadMaster.arlen(7 downto 0),
         s_axi_arsize  => memReadMaster.arsize(2 downto 0),
         s_axi_arburst => memReadMaster.arburst(1 downto 0),
         s_axi_arvalid => memReadMaster.arvalid,
         s_axi_arready => memReadSlave.arready,
         s_axi_rid     => memReadSlave.rid(3 downto 0),
         s_axi_rdata   => memReadSlave.rdata(255 downto 0),
         s_axi_rresp   => memReadSlave.rresp(1 downto 0),
         s_axi_rlast   => memReadSlave.rlast,
         s_axi_rvalid  => memReadSlave.rvalid,
         s_axi_rready  => memReadMaster.rready);

   ---------------
   -- AXI PCIe DMA
   ---------------   
   U_AxiPcieDma : entity work.AxiPcieDma
      generic map (
         TPD_G             => TPD_G,
         SIMULATION_G      => true,
         USE_XBAR_IPCORE_G => true,
         DMA_SIZE_G        => 1,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DESC_ARB_G        => false)    -- Round robin to help with timing
      port map (
         axiClk           => clk,
         axiRst           => rst,
         -- AXI4 Interfaces (
         axiReadMaster    => memReadMaster,
         axiReadSlave     => memReadSlave,
         axiWriteMaster   => memWriteMaster,
         axiWriteSlave    => memWriteSlave,
         -- AXI4-Lite Interfaces
         axilReadMasters  => (others => AXI_LITE_READ_MASTER_INIT_C),
         axilReadSlaves   => open,
         axilWriteMasters => (others => AXI_LITE_WRITE_MASTER_INIT_C),
         axilWriteSlaves  => open,
         -- DMA Interfaces
         dmaIrq           => open,
         dmaObMasters(0)  => dmaObMaster,
         dmaObSlaves(0)   => dmaObSlave,
         dmaIbMasters(0)  => dmaIbMaster,
         dmaIbSlaves(0)   => dmaIbSlave);

   ------------
   -- TX Module
   ------------
   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map(
         TPD_G                      => TPD_G,
         AXI_EN_G                   => '0',
         PRBS_SEED_SIZE_G           => PRBS_SEED_SIZE_C,
         MASTER_AXI_STREAM_CONFIG_G => DMA_AXIS_CONFIG_C)
      port map(
         -- Master Port (mAxisClk)
         mAxisClk     => clk,
         mAxisRst     => rst,
         mAxisMaster  => txMaster,
         mAxisSlave   => txSlave,
         -- Trigger Signal (locClk domain)
         locClk       => clk,
         locRst       => rst,
         packetLength => r.packetLength,
         -- packetLength => toSlv(800,32),
         trig         => r.trig,
         busy         => txBusy);

   -----------------------
   -- TX PRBS Flow Control
   -----------------------
   U_PrbsFlowCtrl : entity work.AxiStreamPrbsFlowCtrl
      generic map(
         TPD_G => TPD_G)
      port map (
         clk => clk,
         rst => rst,

         threshold => x"0000_0000",  -- Bypass flow control (pass through mode)
         -- threshold   => x"F000_0000",

         -- Slave Port
         sAxisMaster => txMaster,
         sAxisSlave  => txSlave,
         -- Master Port
         mAxisMaster => dmaIbMaster,
         mAxisSlave  => dmaIbSlave);

   ------------
   -- RX Module
   ------------
   U_SsiPrbsRx : entity work.SsiPrbsRx
      generic map(
         TPD_G                     => TPD_G,
         PRBS_SEED_SIZE_G          => PRBS_SEED_SIZE_C,
         SLAVE_AXI_STREAM_CONFIG_G => DMA_AXIS_CONFIG_C)
      port map(
         -- Slave Port (sAxisClk)
         sAxisClk       => clk,
         sAxisRst       => rst,
         sAxisMaster    => dmaObMaster,
         sAxisSlave     => dmaObSlave,
         -- Error Detection Signals (sAxisClk domain)
         updatedResults => updatedResults,
         errorDet       => errorDet,
         busy           => rxBusy);


   comb : process (errorDet, r, rst, txBusy) is
      variable v : RegType;
   begin
      -- Latch the current value   
      v := r;

      -- Keep delay copies
      v.errorDet := errorDet;
      v.txBusy   := txBusy;
      v.trig     := not(r.txBusy);

      -- Check for rising edge
      if (txBusy = '1') and (r.txBusy = '0') then
         v.packetLength := r.packetLength + 1;
      end if;

      -- Reset      
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle      
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   process(r)
   begin
      if r.errorDet = '1' then
         assert false
            report "Simulation Failed!" severity failure;
      end if;
   end process;

end testbed;
