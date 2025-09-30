-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the HbmDmaBufferV2 module
-------------------------------------------------------------------------------
-- This file is part of 'epixuhr-3x2-readout-testing'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'epixuhr-3x2-readout-testing', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.HtspPkg.all;

library axi_pcie_core;

entity HbmDmaBufferV2Tb is end HbmDmaBufferV2Tb;

architecture testbed of HbmDmaBufferV2Tb is

   constant CLK_PERIOD_C : time := 4 ns;
   constant TPD_C        : time := 1 ns;

   signal dmaClk : sl := '0';
   signal dmaRst : sl := '0';

   signal hbmRefClk  : sl := '0';
   signal axisMemRdy : sl := '0';
   signal trig       : sl := '0';

   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;

   signal ibAxisMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal ibAxisSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal obAxisMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal obAxisSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal updated         : sl := '0';
   signal errMissedPacket : sl := '0';
   signal errLength       : sl := '0';
   signal errDataBus      : sl := '0';
   signal errEofe         : sl := '0';

   signal errWordCnt : slv(31 downto 0) := (others => '0');

   signal passed : sl := '0';
   signal failed : sl := '0';

begin

   -- Generate DMA clock/reset
   U_ClkRst : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_C,
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 1 us)     -- Hold reset for this long
      port map (
         clkP => dmaClk,
         rst  => dmaRst);

   -- Generate HBM reference clock
   U_userClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 10 ns,
         RST_START_DELAY_G => 0 ns,  -- Wait this long into simulation before asserting reset
         RST_HOLD_TIME_G   => 70 us)    -- Hold reset for this long
      port map (
         clkP => hbmRefClk,
         rstL => trig);

   -- Data Generator
   U_SsiPrbsTx : entity surf.SsiPrbsTx
      generic map (
         -- General Configurations
         TPD_G                      => TPD_C,
         AXI_EN_G                   => '0',
         PRBS_SEED_SIZE_G           => 8*HTSP_AXIS_CONFIG_C.TDATA_BYTES_C,
         -- AXI Stream Configurations
         MASTER_AXI_STREAM_CONFIG_G => HTSP_AXIS_CONFIG_C)
      port map (
         -- Master Port (mAxisClk)
         mAxisClk     => dmaClk,
         mAxisRst     => dmaRst,
         mAxisMaster  => ibAxisMaster,
         mAxisSlave   => ibAxisSlave,
         -- Trigger Signal (locClk domain)
         locClk       => dmaClk,
         locRst       => dmaRst,
         trig         => trig,
         packetLength => toSlv((64512/HTSP_AXIS_CONFIG_C.TDATA_BYTES_C)-1, 32),  -- 64B x 2^12 = 262,144B > 64,512B/frame
         forceEofe    => '0',
         busy         => open,
         tDest        => (others => '0'),
         tId          => (others => '0'));

   -- Design Under Test (DUT)
   U_DUT : entity axi_pcie_core.HbmDmaBufferV2
      generic map (
         TPD_G             => TPD_C,
         SIMULATION_G      => true,
         DMA_SIZE_G        => 1,
         DMA_AXIS_CONFIG_G => HTSP_AXIS_CONFIG_C,
         AXIL_BASE_ADDR_G  => x"0000_0000")
      port map (
         -- Card Management Solution (CMS) Interface
         cmsHbmCatTrip    => open,
         cmsHbmTemp       => open,
         -- HBM Interface
         userClk          => hbmRefClk,  -- 100 MHz
         hbmRefClk        => hbmRefClk,  -- 100 MHz
         hbmCatTrip       => open,
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => dmaClk,
         axilRst          => dmaRst,
         axilReadMaster   => AXI_LITE_READ_MASTER_INIT_C,
         axilReadSlave    => open,
         axilWriteMaster  => AXI_LITE_WRITE_MASTER_INIT_C,
         axilWriteSlave   => open,
         -- Trigger Event streams (eventClk domain)
         eventClk(0)      => dmaClk,
         eventTrigMsgCtrl => open,
         -- AXI Stream Interface (axisClk domain)
         axisClk(0)       => dmaClk,
         axisRst(0)       => dmaRst,
         axisMemRdy(0)    => axisMemRdy,
         sAxisMasters(0)  => ibAxisMaster,
         sAxisSlaves(0)   => ibAxisSlave,
         mAxisMasters(0)  => obAxisMaster,
         mAxisSlaves(0)   => obAxisSlave);

   -- Monitor the AXIS bandwidth
   U_AxiStreamMonAxiL : entity surf.AxiStreamMonAxiL
      generic map(
         TPD_G            => TPD_C,
         COMMON_CLK_G     => true,
         AXIS_CLK_FREQ_G  => 250.0E+6,
         AXIS_NUM_SLOTS_G => 1,
         AXIS_CONFIG_G    => HTSP_AXIS_CONFIG_C)
      port map(
         -- AXIS Stream Interface
         axisClk          => dmaClk,
         axisRst          => dmaRst,
         axisMasters(0)   => obAxisMaster,
         axisSlaves(0)    => obAxisSlave,
         -- AXI lite slave port for register access
         axilClk          => dmaClk,
         axilRst          => dmaRst,
         sAxilWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
         sAxilWriteSlave  => open,
         sAxilReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
         sAxilReadSlave   => open);

   -- Data Sink
   U_SsiPrbsRx : entity surf.SsiPrbsRx
      generic map (
         TPD_G                     => TPD_C,
         PRBS_SEED_SIZE_G          => 8*HTSP_AXIS_CONFIG_C.TDATA_BYTES_C,
         SLAVE_AXI_STREAM_CONFIG_G => HTSP_AXIS_CONFIG_C)
      port map (
         -- Streaming RX Data Interface (sAxisClk domain)
         sAxisClk        => dmaClk,
         sAxisRst        => dmaRst,
         sAxisMaster     => obAxisMaster,
         sAxisSlave      => obAxisSlave,
         -- Optional: AXI-Lite Register Interface (axiClk domain)
         axiClk          => dmaClk,
         axiRst          => dmaRst,
         axiReadMaster   => AXI_LITE_READ_MASTER_INIT_C,
         axiReadSlave    => open,
         axiWriteMaster  => AXI_LITE_WRITE_MASTER_INIT_C,
         -- Error Detection Signals (sAxisClk domain)
         updatedResults  => updated,
         busy            => open,
         errMissedPacket => errMissedPacket,
         errLength       => errLength,
         errDataBus      => errDataBus,
         errEofe         => errEofe,
         errWordCnt      => errWordCnt);

   process(dmaClk)
   begin
      if rising_edge(dmaClk) then
         if dmaRst = '1' then
            passed <= '0' after TPD_C;
            failed <= '0' after TPD_C;
         elsif updated = '1' then
            -- Check for missed packet error
            if errMissedPacket = '1' then
               failed <= '1' after TPD_C;
            end if;
            -- Check for packet length error
            if errLength = '1' then
               failed <= '1' after TPD_C;
            end if;
            -- Check for packet data bus error
            if errDataBus = '1' then
               failed <= '1' after TPD_C;
            end if;
            -- Check for EOFE error
            if errEofe = '1' then
               failed <= '1' after TPD_C;
            end if;
            -- Check for word error
            if errWordCnt /= 0 then
               failed <= '1' after TPD_C;
            end if;
         end if;
      end if;
   end process;

   process(failed, passed)
   begin
      if failed = '1' then
         assert false
            report "Simulation Failed!" severity failure;
      end if;
      if passed = '1' then
         assert false
            report "Simulation Passed!" severity note;
      end if;
   end process;

end testbed;
