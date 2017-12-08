-------------------------------------------------------------------------------
-- File       : EvrFrontEnd.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-09-20
-- Last update: 2017-10-24
-------------------------------------------------------------------------------
-- Description: 
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.TimingPkg.all;

library unisim;
use unisim.vcomponents.all;

entity EvrFrontEnd is
   generic (
      TPD_G            : time             := 1 ns;
      DEFAULT_TIMING_G : boolean          := false;  -- false = LCLS-I, true = LCLS-II
      AXI_ERROR_RESP_G : slv(1 downto 0)  := AXI_RESP_DECERR_C;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0'));
   port (
      -- Timing Interface
      evrClk          : out sl;
      evrRst          : out sl;
      evrTimingBus    : out TimingBusType;
      -- DRP Clock and Reset
      drpClk          : in  sl;
      drpRst          : in  sl;
      -- AXI-Lite Interface
      sysRst          : in  sl;
      sysClk          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Reference Clocks
      userClk156      : in  sl;
      -- GT Serial Ports
      evrRxP          : in  slv(1 downto 0);
      evrRxN          : in  slv(1 downto 0);
      evrTxP          : out slv(1 downto 0);
      evrTxN          : out slv(1 downto 0));
end EvrFrontEnd;

architecture mapping of EvrFrontEnd is

   constant NUM_AXI_MASTERS_C : natural := 4;

   constant EVR_INDEX_C  : natural := 0;
   constant MISC_INDEX_C : natural := 1;
   constant GTP0_INDEX_C : natural := 2;
   constant GTP1_INDEX_C : natural := 3;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 18, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

   signal gtWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal gtWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);
   signal gtReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal gtReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);

   signal mmcmRst        : sl;
   signal refClk         : slv(2 downto 0);
   signal refRst         : slv(2 downto 0);
   signal mmcmLocked     : slv(2 downto 0);
   signal timingClockSel : sl;
   signal loopback       : slv(2 downto 0);

   signal rxUserRst   : sl;
   signal gtRxClk     : slv(1 downto 0);
   signal rxClk       : sl;
   signal rxRst       : sl;
   signal rxReset     : sl;
   signal gtRxData    : Slv16Array(1 downto 0);
   signal rxData      : slv(15 downto 0);
   signal gtRxDataK   : Slv2Array(1 downto 0);
   signal rxDataK     : slv(1 downto 0);
   signal gtRxDispErr : Slv2Array(1 downto 0);
   signal rxDispErr   : slv(1 downto 0);
   signal gtRxDecErr  : Slv2Array(1 downto 0);
   signal rxDecErr    : slv(1 downto 0);
   signal gtRxStatus  : TimingPhyStatusArray(1 downto 0);
   signal rxStatus    : TimingPhyStatusType;
   signal rxCtrl      : TimingPhyControlType;
   signal rxControl   : TimingPhyControlType;

   signal txUserRst    : sl;
   signal gtTxClk      : slv(1 downto 0);
   signal txClk        : sl;
   signal txRst        : sl;
   signal txData       : slv(15 downto 0);
   signal txDataK      : slv(1 downto 0);
   signal txDiffCtrl   : slv(3 downto 0);
   signal txPreCursor  : slv(4 downto 0);
   signal txPostCursor : slv(4 downto 0);
   signal gtTxStatus   : TimingPhyStatusArray(1 downto 0);
   signal txStatus     : TimingPhyStatusType;
   signal timingPhy    : TimingPhyType;

begin

   evrClk  <= rxClk;
   txRst   <= txUserRst;
   rxReset <= rxUserRst or not(rxStatus.resetDone);
   rxRst   <= rxUserRst;

   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => rxClk,
         rstIn  => rxReset,
         rstOut => evrRst);

   U_25MHz : entity work.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 1,
         -- PLL attributes
         CLKIN_PERIOD_G    => 6.4,      -- 156.25MHz
         DIVCLK_DIVIDE_G   => 1,        -- 156.25MHz = 156.25MHz/1
         CLKFBOUT_MULT_G   => 8,        -- 1.25GHz = 156.25MHz x 8
         CLKOUT0_DIVIDE_G  => 50)       -- 25MHz = 1.25GHz/50
      port map(
         -- Clock Input
         clkIn     => userClk156,
         rstIn     => mmcmRst,
         -- Clock Outputs
         clkOut(0) => refClk(0),
         -- Reset Outputs
         rstOut(0) => refRst(0),
         -- Locked Status
         locked    => mmcmLocked(0));

   U_238MHz : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 40.0,    -- 25 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 25 MHz = 25MHz/1
         CLKFBOUT_MULT_F_G  => 29.750,  -- 743.75 MHz = 25 MHz x 29.75
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 238 MHz = 743.75 MHz/3.125
      port map(
         -- Clock Input
         clkIn     => refClk(0),
         rstIn     => refRst(0),
         -- Clock Outputs
         clkOut(0) => refClk(1),
         -- Reset Outputs
         rstOut(0) => refRst(1),
         -- Locked Status
         locked    => mmcmLocked(1));

   U_371MHz : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "HIGH",
         CLKIN_PERIOD_G     => 40.0,    -- 25 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 25 MHz = 25MHz/1
         CLKFBOUT_MULT_F_G  => 52.000,  -- 1.3 GHz = 25 MHz x 52
         CLKOUT0_DIVIDE_F_G => 3.500)   -- 371.429 MHz = 1.3 GHz/3.5
      port map(
         -- Clock Input
         clkIn     => refClk(0),
         rstIn     => refRst(0),
         -- Clock Outputs
         clkOut(0) => refClk(2),
         -- Reset Outputs
         rstOut(0) => refRst(2),
         -- Locked Status
         locked    => mmcmLocked(2));

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CONFIG_C)
      port map (
         axiClk              => sysClk,
         axiClkRst           => sysRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   -------------
   -- GTH Module
   -------------
   GEN_VEC : for i in 1 downto 0 generate

      U_AxiLiteAsync : entity work.AxiLiteAsync
         generic map (
            TPD_G            => TPD_G,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
            COMMON_CLK_G     => false,
            NUM_ADDR_BITS_G  => 32)
         port map (
            -- Slave Interface
            sAxiClk         => sysClk,
            sAxiClkRst      => sysRst,
            sAxiReadMaster  => axilReadMasters(GTP0_INDEX_C+i),
            sAxiReadSlave   => axilReadSlaves(GTP0_INDEX_C+i),
            sAxiWriteMaster => axilWriteMasters(GTP0_INDEX_C+i),
            sAxiWriteSlave  => axilWriteSlaves(GTP0_INDEX_C+i),
            -- Master Interface
            mAxiClk         => drpClk,
            mAxiClkRst      => drpRst,
            mAxiReadMaster  => gtReadMasters(i),
            mAxiReadSlave   => gtReadSlaves(i),
            mAxiWriteMaster => gtWriteMasters(i),
            mAxiWriteSlave  => gtWriteSlaves(i));

      U_GTP : entity work.EvrGthCoreWrapper
         generic map (
            TPD_G            => TPD_G,
            AXIL_BASE_ADDR_G => AXI_CONFIG_C(GTP0_INDEX_C+i).baseAddr,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
         port map (
            axilClk         => drpClk,
            axilRst         => drpRst,
            axilReadMaster  => gtReadMasters(i),
            axilReadSlave   => gtReadSlaves(i),
            axilWriteMaster => gtWriteMasters(i),
            axilWriteSlave  => gtWriteSlaves(i),
            stableClk       => drpClk,
            gtRefClk        => refClk(1+i),
            gtRxP           => evrRxP(i),
            gtRxN           => evrRxN(i),
            gtTxP           => evrTxP(i),
            gtTxN           => evrTxN(i),
            rxControl       => rxControl,
            rxStatus        => gtRxStatus(i),
            rxUsrClkActive  => mmcmLocked(1+i),
            rxUsrClk        => gtRxClk(i),
            rxData          => gtRxData(i),
            rxDataK         => gtRxDataK(i),
            rxDispErr       => gtRxDispErr(i),
            rxDecErr        => gtRxDecErr(i),
            rxOutClk        => gtRxClk(i),
            txControl       => timingPhy.control,
            txStatus        => gtTxStatus(i),
            txUsrClk        => gtTxClk(i),
            txUsrClkActive  => mmcmLocked(1+i),
            txData          => timingPhy.data,
            txDataK         => timingPhy.dataK,
            txOutClk        => gtTxClk(i),
            loopback        => loopback);

   end generate GEN_VEC;

   rxStatus  <= gtRxStatus(1)  when (timingClockSel = '1') else gtRxStatus(0);
   rxData    <= gtRxData(1)    when (timingClockSel = '1') else gtRxData(0);
   rxDataK   <= gtRxDataK(1)   when (timingClockSel = '1') else gtRxDataK(0);
   rxDispErr <= gtRxDispErr(1) when (timingClockSel = '1') else gtRxDispErr(0);
   rxDecErr  <= gtRxDecErr(1)  when (timingClockSel = '1') else gtRxDecErr(0);
   txStatus  <= gtTxStatus(1)  when (timingClockSel = '1') else gtTxStatus(0);

   U_RXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => rxClk,                   -- 1-bit output: Clock output
         I0 => gtRxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtRxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClockSel);         -- 1-bit input: Clock select

   U_TXCLK : BUFGMUX
      generic map (
         CLK_SEL_TYPE => "ASYNC")       -- ASYNC, SYNC
      port map (
         O  => txClk,                   -- 1-bit output: Clock output
         I0 => gtTxClk(0),              -- 1-bit input: Clock input (S=0)
         I1 => gtTxClk(1),              -- 1-bit input: Clock input (S=1)
         S  => timingClockSel);         -- 1-bit input: Clock select         

   -----------------------
   -- Insert user RX reset
   -----------------------
   rxControl.reset       <= rxCtrl.reset or rxUserRst;
   rxControl.inhibit     <= rxCtrl.inhibit;
   rxControl.polarity    <= rxCtrl.polarity;
   rxControl.bufferByRst <= rxCtrl.bufferByRst;
   rxControl.pllReset    <= rxCtrl.pllReset or rxUserRst;

   --------------
   -- Timing Core
   --------------
   U_TimingCore : entity work.TimingCore
      generic map (
         TPD_G             => TPD_G,
         DEFAULT_CLK_SEL_G => ite(DEFAULT_TIMING_G, '1', '0'),
         AXIL_RINGB_G      => false,
         ASYNC_G           => false,
         AXIL_BASE_ADDR_G  => AXI_CONFIG_C(EVR_INDEX_C).baseAddr,
         AXIL_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- GT Interface
         gtTxUsrClk      => txClk,
         gtTxUsrRst      => txRst,
         gtRxRecClk      => rxClk,
         gtRxData        => rxData,
         gtRxDataK       => rxDataK,
         gtRxDispErr     => rxDispErr,
         gtRxDecErr      => rxDecErr,
         gtRxControl     => rxCtrl,
         gtRxStatus      => rxStatus,
         -- Decoded timing message interface
         appTimingClk    => rxClk,
         appTimingRst    => rxRst,
         appTimingBus    => evrTimingBus,
         timingPhy       => timingPhy,
         timingClkSel    => timingClockSel,
         -- AXI Lite interface
         axilClk         => sysClk,
         axilRst         => sysRst,
         axilReadMaster  => axilReadMasters(EVR_INDEX_C),
         axilReadSlave   => axilReadSlaves(EVR_INDEX_C),
         axilWriteMaster => axilWriteMasters(EVR_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(EVR_INDEX_C));

   --------------
   -- Misc Core
   --------------
   U_EvrMisc : entity work.EvrMisc
      generic map (
         TPD_G            => TPD_G,
         DEFAULT_TIMING_G => DEFAULT_TIMING_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         rxUserRst       => rxUserRst,
         txUserRst       => txUserRst,
         txDiffCtrl      => txDiffCtrl,
         txPreCursor     => txPreCursor,
         txPostCursor    => txPostCursor,
         loopback        => loopback,
         userClk156      => userClk156,
         mmcmRst         => mmcmRst,
         mmcmLocked      => mmcmLocked,
         refClk          => refClk,
         refRst          => refRst,
         txClk           => txClk,
         txRst           => txRst,
         rxClk           => rxClk,
         rxRst           => rxRst,
         -- AXI Lite interface
         sysClk          => sysClk,
         sysRst          => sysRst,
         axilReadMaster  => axilReadMasters(MISC_INDEX_C),
         axilReadSlave   => axilReadSlaves(MISC_INDEX_C),
         axilWriteMaster => axilWriteMasters(MISC_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(MISC_INDEX_C));

end mapping;
