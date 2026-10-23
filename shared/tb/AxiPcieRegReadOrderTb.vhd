-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation testbench for AxiPcieRegReadOrder
-------------------------------------------------------------------------------
-- Write W1 targets a slow slave and stalls the write channel. Write W2 (new
-- data for a fast register) is presented only after W1 is accepted, like a
-- posted write queued in the PCIe bridge. A read of the fast register issued
-- while W1 is stalled must return W2's data, not the stale value. A monitor
-- checks that a read presented to the crossbar is never withdrawn.
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.TextUtilPkg.all;

library axi_pcie_core;

entity AxiPcieRegReadOrderTb is end AxiPcieRegReadOrderTb;

architecture testbed of AxiPcieRegReadOrderTb is

   constant TPD_G        : time    := 1 ns;
   constant CLK_PERIOD_C : time    := 4 ns;
   constant SLOW_CYCLE_C : natural := 200;  -- slow slave write latency

   constant FAST_ADDR_C : slv(31 downto 0) := x"0000_0100";  -- AxiLiteRegs writeRegister(0)
   constant SLOW_ADDR_C : slv(31 downto 0) := x"0000_1000";

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(1 downto 0) := (
      0               => (
         baseAddr     => x"0000_0000",
         addrBits     => 12,
         connectivity => x"FFFF"),
      1               => (
         baseAddr     => x"0000_1000",
         addrBits     => 12,
         connectivity => x"FFFF"));

   signal clk : sl := '0';
   signal rst : sl := '1';

   signal sRdMaster   : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal sRdSlave    : AxiLiteReadSlaveType;
   signal sWrMaster   : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal sWrSlave    : AxiLiteWriteSlaveType;
   signal xbarRdMaster : AxiLiteReadMasterType;
   signal xbarRdSlave  : AxiLiteReadSlaveType;
   signal xbarWrMaster : AxiLiteWriteMasterType;
   signal xbarWrSlave  : AxiLiteWriteSlaveType;

   signal rdMasters : AxiLiteReadMasterArray(1 downto 0);
   signal rdSlaves  : AxiLiteReadSlaveArray(1 downto 0);
   signal wrMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal wrSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal slowWrSlave : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_INIT_C;

   signal passed : boolean := false;

begin

   clk <= not clk after CLK_PERIOD_C/2;

   U_DUT : entity axi_pcie_core.AxiPcieRegReadOrder
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk          => clk,
         axilRst          => rst,
         sAxilReadMaster  => sRdMaster,
         sAxilReadSlave   => sRdSlave,
         sAxilWriteMaster => sWrMaster,
         sAxilWriteSlave  => sWrSlave,
         mAxilReadMaster  => xbarRdMaster,
         mAxilReadSlave   => xbarRdSlave,
         mAxilWriteMaster => xbarWrMaster,
         mAxilWriteSlave  => xbarWrSlave);

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 2,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => xbarWrMaster,
         sAxiWriteSlaves(0)  => xbarWrSlave,
         sAxiReadMasters(0)  => xbarRdMaster,
         sAxiReadSlaves(0)   => xbarRdSlave,
         mAxiWriteMasters    => wrMasters,
         mAxiWriteSlaves     => wrSlaves,
         mAxiReadMasters     => rdMasters,
         mAxiReadSlaves      => rdSlaves);

   -- Fast slave: plain register
   U_FAST : entity surf.AxiLiteRegs
      generic map (
         TPD_G           => TPD_G,
         NUM_WRITE_REG_G => 1,
         NUM_READ_REG_G  => 1)
      port map (
         axiClk         => clk,
         axiClkRst      => rst,
         axiReadMaster  => rdMasters(0),
         axiReadSlave   => rdSlaves(0),
         axiWriteMaster => wrMasters(0),
         axiWriteSlave  => wrSlaves(0));

   -- Slow slave: writes take SLOW_CYCLE_C cycles, reads are not used
   rdSlaves(1) <= AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   wrSlaves(1) <= slowWrSlave;

   SLOW : process is
   begin
      wait until rising_edge(clk);
      if (wrMasters(1).awvalid = '1') and (wrMasters(1).wvalid = '1') then
         for i in 1 to SLOW_CYCLE_C loop
            wait until rising_edge(clk);
         end loop;
         slowWrSlave.awready <= '1' after TPD_G;
         slowWrSlave.wready  <= '1' after TPD_G;
         wait until rising_edge(clk);
         slowWrSlave.awready <= '0' after TPD_G;
         slowWrSlave.wready  <= '0' after TPD_G;
         slowWrSlave.bvalid  <= '1' after TPD_G;
         wait until rising_edge(clk) and wrMasters(1).bready = '1';
         slowWrSlave.bvalid  <= '0' after TPD_G;
      end if;
   end process SLOW;

   -- A read presented to the crossbar must stay presented until accepted
   MON : process is
      variable pending : boolean := false;
   begin
      wait until rising_edge(clk);
      if pending then
         assert (xbarRdMaster.arvalid = '1')
            report "AxiPcieRegReadOrderTb: arvalid withdrawn before arready" severity failure;
      end if;
      pending := (xbarRdMaster.arvalid = '1') and (xbarRdSlave.arready = '0');
   end process MON;

   TEST : process is

      procedure cycles(n : natural) is
      begin
         for i in 1 to n loop
            wait until rising_edge(clk);
         end loop;
      end procedure;

      procedure axilWrite(addr : slv(31 downto 0); data : slv(31 downto 0)) is
      begin
         sWrMaster.awaddr  <= addr after TPD_G;
         sWrMaster.wdata   <= data after TPD_G;
         sWrMaster.wstrb   <= x"F" after TPD_G;
         sWrMaster.awvalid <= '1' after TPD_G;
         sWrMaster.wvalid  <= '1' after TPD_G;
         sWrMaster.bready  <= '1' after TPD_G;
         wait until rising_edge(clk) and sWrSlave.awready = '1';
         sWrMaster.awvalid <= '0' after TPD_G;
         sWrMaster.wvalid  <= '0' after TPD_G;
         if (sWrSlave.bvalid = '0') then
            wait until rising_edge(clk) and sWrSlave.bvalid = '1';
         end if;
      end procedure;

      procedure axilRead(addr : slv(31 downto 0); data : out slv(31 downto 0); lat : out natural) is
         variable n : natural := 0;
      begin
         sRdMaster.araddr  <= addr after TPD_G;
         sRdMaster.arvalid <= '1' after TPD_G;
         sRdMaster.rready  <= '1' after TPD_G;
         loop
            wait until rising_edge(clk);
            n := n + 1;
            if (sRdSlave.arready = '1') then
               sRdMaster.arvalid <= '0' after TPD_G;
            end if;
            exit when sRdSlave.rvalid = '1';
         end loop;
         data := sRdSlave.rdata;
         lat  := n;
         sRdMaster.rready <= '0' after TPD_G;
      end procedure;

      variable data   : slv(31 downto 0);
      variable lat    : natural;
      variable w1Done : boolean;
      variable w2Done : boolean;
      variable rDone  : boolean;

   begin
      cycles(10);
      rst <= '0' after TPD_G;
      cycles(10);

      -- Sanity: write then read the fast register
      axilWrite(FAST_ADDR_C, x"1111_1111");
      axilRead(FAST_ADDR_C, data, lat);
      assert (data = x"1111_1111")
         report "AxiPcieRegReadOrderTb: sanity read mismatch" severity failure;
      cycles(5);

      -- Ordering: W1 (slow) then W2 (fast, new data), read issued while W1 stalls
      sWrMaster.awaddr  <= SLOW_ADDR_C after TPD_G;
      sWrMaster.wdata   <= x"DEAD_BEEF" after TPD_G;
      sWrMaster.wstrb   <= x"F" after TPD_G;
      sWrMaster.awvalid <= '1' after TPD_G;
      sWrMaster.wvalid  <= '1' after TPD_G;
      sWrMaster.bready  <= '1' after TPD_G;
      cycles(10);
      sRdMaster.araddr  <= FAST_ADDR_C after TPD_G;
      sRdMaster.arvalid <= '1' after TPD_G;
      sRdMaster.rready  <= '1' after TPD_G;
      w1Done := false;
      w2Done := false;
      rDone  := false;
      while not (w2Done and rDone) loop
         wait until rising_edge(clk);
         -- Write address channel: W2 follows W1 once W1 is accepted
         if (sWrMaster.awvalid = '1') and (sWrSlave.awready = '1') then
            if not w1Done then
               w1Done            := true;
               sWrMaster.awaddr  <= FAST_ADDR_C after TPD_G;
               sWrMaster.wdata   <= x"2222_2222" after TPD_G;
            else
               w2Done            := true;
               sWrMaster.awvalid <= '0' after TPD_G;
               sWrMaster.wvalid  <= '0' after TPD_G;
            end if;
         end if;
         -- Read channel
         if (sRdMaster.arvalid = '1') and (sRdSlave.arready = '1') then
            sRdMaster.arvalid <= '0' after TPD_G;
         end if;
         if (sRdSlave.rvalid = '1') and not rDone then
            rDone            := true;
            data             := sRdSlave.rdata;
            sRdMaster.rready <= '0' after TPD_G;
         end if;
      end loop;
      assert (data = x"2222_2222")
         report "AxiPcieRegReadOrderTb: read passed an earlier write, got 0x" & hstr(data) severity failure;
      cycles(10);

      -- A read already presented is not held back by a later slow write
      sRdMaster.araddr  <= FAST_ADDR_C after TPD_G;
      sRdMaster.arvalid <= '1' after TPD_G;
      sRdMaster.rready  <= '1' after TPD_G;
      wait until rising_edge(clk);
      sWrMaster.awaddr  <= SLOW_ADDR_C after TPD_G;
      sWrMaster.wdata   <= x"0BAD_F00D" after TPD_G;
      sWrMaster.awvalid <= '1' after TPD_G;
      sWrMaster.wvalid  <= '1' after TPD_G;
      lat := 0;
      loop
         wait until rising_edge(clk);
         lat := lat + 1;
         if (sRdSlave.arready = '1') then
            sRdMaster.arvalid <= '0' after TPD_G;
         end if;
         exit when sRdSlave.rvalid = '1';
      end loop;
      sRdMaster.rready <= '0' after TPD_G;
      assert (sRdSlave.rdata = x"2222_2222") and (lat < SLOW_CYCLE_C/2)
         report "AxiPcieRegReadOrderTb: presented read was delayed by a later write" severity failure;
      wait until rising_edge(clk) and sWrSlave.awready = '1';
      sWrMaster.awvalid <= '0' after TPD_G;
      sWrMaster.wvalid  <= '0' after TPD_G;
      cycles(5);

      passed <= true;
      report "AxiPcieRegReadOrderTb: PASSED" severity note;
      wait;
   end process TEST;

   TIMEOUT : process is
   begin
      wait for 50 us;
      assert passed report "AxiPcieRegReadOrderTb: TIMEOUT" severity failure;
      std.env.stop;
      wait;
   end process TIMEOUT;

end testbed;
