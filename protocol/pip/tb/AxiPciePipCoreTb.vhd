-------------------------------------------------------------------------------
-- File       : AxiPciePipCoreTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the FPGA module
-------------------------------------------------------------------------------
-- This file is part of 'Camera link gateway'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Camera link gateway', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


library surf;
use surf.StdRtlPkg.all;
use work.BuildInfoPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

entity AxiPciePipCoreTb is end AxiPciePipCoreTb;

architecture testbed of AxiPciePipCoreTb is

   constant CLK_PERIOD_C      : time                   := 10 ns;  -- 1 us makes it easy to count clock cycles in sim GUI
   constant TPD_G             : time                   := CLK_PERIOD_C/4;
   constant PRBS_SEED_SIZE_C  : positive               := 32;
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType    := ssiAxiStreamConfig(8);
   constant PKT_LEN_C         : slv(31 downto 0)       := x"000000FF";  -- PRBS TX packet length
   constant BAR_BASE_ADDR_C   : Slv32Array(3 downto 0) := (0 => x"10000000", 1 => x"20000000", 2 => x"30000000", 3 => x"40000000");
   constant APP_STREAMS_C     : positive               := 4;

   type RegType is record
      packetLength : Slv32Array(APP_STREAMS_C-1 downto 0);
      trig         : slv(APP_STREAMS_C-1 downto 0);
      txBusy       : slv(APP_STREAMS_C-1 downto 0);
      errorDet     : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      packetLength => (others => (others => '0')),
      trig         => (others => '0'),
      txBusy       => (others => '0'),
      errorDet     => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal txMasters : AxiStreamMasterArray(APP_STREAMS_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal txSlaves  : AxiStreamSlaveArray(APP_STREAMS_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal rxMasters : AxiStreamMasterArray(APP_STREAMS_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves  : AxiStreamSlaveArray(APP_STREAMS_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal updateDet : slv(APP_STREAMS_C-1 downto 0);
   signal errorDet  : slv(APP_STREAMS_C-1 downto 0);
   signal enableTx  : slv(APP_STREAMS_C-1 downto 0);
   signal txBusy    : slv(APP_STREAMS_C-1 downto 0);
   signal axiReady  : sl;

   signal axiWriteMaster : AxiWriteMasterType;
   signal axiWriteSlave  : AxiWriteSlaveType;

   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;

   signal clk : sl := '0';
   signal rst : sl := '1';

   signal passed : sl := '0';
   signal failed : sl := '0';

begin

   U_ClkRst : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_C,
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1 us)     -- Hold reset for this long)
      port map (
         clkP => clk,
         rst  => rst);

   GEN_VEC :
   for i in 0 to APP_STREAMS_C-1 generate

      U_SsiPrbsTx : entity surf.SsiPrbsTx
         generic map (
            TPD_G                      => TPD_G,
            AXI_EN_G                   => '0',
            GEN_SYNC_FIFO_G            => true,
            PRBS_SEED_SIZE_G           => PRBS_SEED_SIZE_C,
            MASTER_AXI_STREAM_CONFIG_G => DMA_AXIS_CONFIG_C)
         port map (
            mAxisClk     => clk,
            mAxisRst     => rst,
            mAxisMaster  => txMasters(i),
            mAxisSlave   => txSlaves(i),
            locClk       => clk,
            locRst       => rst,
            -- packetLength => PKT_LEN_C,
            packetLength => r.packetLength(i),
            trig         => r.trig(i),
            busy         => txBusy(i));

      U_SsiPrbsRx : entity surf.SsiPrbsRx
         generic map (
            TPD_G                     => TPD_G,
            GEN_SYNC_FIFO_G           => true,
            PRBS_SEED_SIZE_G          => PRBS_SEED_SIZE_C,
            SLAVE_AXI_STREAM_CONFIG_G => DMA_AXIS_CONFIG_C)
         port map (
            sAxisClk       => clk,
            sAxisRst       => rst,
            sAxisMaster    => rxMasters(i),
            sAxisSlave     => rxSlaves(i),
            updatedResults => updateDet(i),
            errorDet       => errorDet(i),
            axiClk         => clk,
            axiRst         => rst);

   end generate GEN_VEC;

   U_AxiPciePipCore : entity axi_pcie_core.AxiPciePipCore
      generic map (
         TPD_G             => TPD_G,
         NUM_AXIS_G        => APP_STREAMS_C,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C)
      port map (
         -- AXI4-Lite Interfaces (axilClk domain)
         axilClk         => clk,
         axilRst         => rst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         enableTx        => enableTx,
         -- AXI Stream Interface (axisClk domain)
         axisClk         => clk,
         axisRst         => rst,
         sAxisMasters    => txMasters,
         sAxisSlaves     => txSlaves,
         mAxisMasters    => rxMasters,
         mAxisSlaves     => rxSlaves,
         -- AXI4 Interfaces (axiClk domain)
         axiClk          => clk,
         axiRst          => rst,
         axiReady        => axiReady,
         sAxiWriteMaster => axiWriteMaster,
         sAxiWriteSlave  => axiWriteSlave,
         mAxiWriteMaster => axiWriteMaster,
         mAxiWriteSlave  => axiWriteSlave);

   comb : process (axiReady, enableTx, errorDet, r, rst, txBusy) is
      variable v : RegType;
   begin
      -- Latch the current value   
      v := r;

      for i in 0 to APP_STREAMS_C-1 loop

         -- Keep delay copies
         v.txBusy(i) := txBusy(i) or not(enableTx(i));
         v.trig(i)   := not(r.txBusy(i)) and enableTx(i) and axiReady;

         -- Check for the packet completion 
         if (txBusy(i) = '1') and (r.txBusy(i) = '0') then
            -- Sweeping the packet size size
            v.packetLength(i) := r.packetLength(i) + 1;
         end if;

      end loop;

      -- OR all the error detected bits
      v.errorDet := uOr(errorDet);

      -- Reset      
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      ---------------------------------
      -- Simulation Error Self-checking
      ---------------------------------
      if r.errorDet = '1' then
         assert false
            report "Simulation Failed!" severity failure;
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

   ---------------------------------
   -- AXI-Lite Register Transactions
   ---------------------------------
   test : process is
      variable debugData : slv(31 downto 0) := (others => '0');
   begin
      wait until rst = '1';
      wait until rst = '0';
      wait for 1 us;

      for i in APP_STREAMS_C-1 downto 0 loop
         axiLiteBusSimWrite(clk, axilWriteMaster, axilWriteSlave, toSlv(i*8, 32), BAR_BASE_ADDR_C(i), true);  -- remoteBarBaseAddr[i]
      end loop;
      axiLiteBusSimWrite (clk, axilWriteMaster, axilWriteSlave, x"0000_00F8", toSlv(2**APP_STREAMS_C-1, 32), true);  -- enableTx

   end process test;

end testbed;
