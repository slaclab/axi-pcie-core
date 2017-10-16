-------------------------------------------------------------------------------
-- File       : EvrFrontEnd.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-06
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'SLAC PGP Gen3 Card'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC PGP Gen3 Card', including this file, 
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
      -- AXI-Lite Interface
      sysClk          : in  sl;
      sysRst          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- GT Serial Ports
      evrRefClkP      : in  slv(1 downto 0);
      evrRefClkN      : in  slv(1 downto 0);
      evrMuxSel       : out slv(1 downto 0);
      evrRxP          : in  sl;
      evrRxN          : in  sl;
      evrTxP          : out sl;
      evrTxN          : out sl);
end EvrFrontEnd;

architecture mapping of EvrFrontEnd is

   constant NUM_AXI_MASTERS_C : natural := 2;

   constant EVR_INDEX_C  : natural := 0;
   constant MISC_INDEX_C : natural := 1;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 18, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

   signal refClk           : slv(1 downto 0);
   signal refClockDiv2     : slv(1 downto 0);
   signal refClkDiv2       : slv(1 downto 0);
   signal gtQPllOutRefClk  : slv(1 downto 0);
   signal gtQPllOutClk     : slv(1 downto 0);
   signal gtQPllLock       : slv(1 downto 0);
   signal gtQPllRefClkLost : slv(1 downto 0);
   signal qPllLockDetClk   : slv(1 downto 0);
   signal gtQPllReset      : slv(1 downto 0);
   signal gtQPllRst        : slv(1 downto 0);
   signal qPllReset        : slv(1 downto 0);
   signal qPllRxSelect     : slv(1 downto 0);
   signal qPllTxSelect     : slv(1 downto 0);
   signal loopback         : slv(2 downto 0);

   signal rxUserRst : sl;
   signal rxClk     : sl;
   signal rxRst     : sl;
   signal rxData    : slv(15 downto 0);
   signal rxDataK   : slv(1 downto 0);
   signal rxDispErr : slv(1 downto 0);
   signal rxDecErr  : slv(1 downto 0);
   signal rxStatus  : TimingPhyStatusType;
   signal rxControl : TimingPhyControlType;

   signal txUserRst : sl;
   signal txClk     : sl;
   signal txRst     : sl;
   signal txData    : slv(15 downto 0);
   signal txDataK   : slv(1 downto 0);
   signal txStatus  : TimingPhyStatusType;
   signal timingPhy : TimingPhyType;

begin

   evrClk <= rxClk;
   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => rxClk,
         rstIn  => rxRst,
         rstOut => evrRst);

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

   -------------------------         
   -- Input Reference Clocks
   -------------------------         
   GEN_VEC :
   for i in 1 downto 0 generate

      U_IBUFDS : IBUFDS_GTE2
         port map (
            I     => evrRefClkP(i),
            IB    => evrRefClkN(i),
            CEB   => '0',
            ODIV2 => refClockDiv2(i),
            O     => refClk(i));

      U_BUFG : BUFG
         port map (
            I => refClockDiv2(i),
            O => refClkDiv2(i));

   end generate GEN_VEC;

   --------------
   -- QPLL Module
   --------------
   U_QPLL : entity work.Gtp7QuadPll
      generic map (
         TPD_G                => TPD_G,
         AXI_ERROR_RESP_G     => AXI_ERROR_RESP_G,
         PLL0_REFCLK_SEL_G    => "001",  -- GTREFCLK0 selected
         PLL0_FBDIV_IN_G      => 2,      -- 238 MHz clock reference
         PLL0_FBDIV_45_IN_G   => 5,
         PLL0_REFCLK_DIV_IN_G => 1,
         PLL1_REFCLK_SEL_G    => "010",  -- GTREFCLK1 selected
         PLL1_FBDIV_IN_G      => 2,      -- 371 MHz clock reference
         PLL1_FBDIV_45_IN_G   => 5,
         PLL1_REFCLK_DIV_IN_G => 1)
      port map (
         qPllRefClk     => refClk,
         qPllOutClk     => gtQPllOutClk,
         qPllOutRefClk  => gtQPllOutRefClk,
         qPllLock       => gtQPllLock,
         qPllRefClkLost => gtQPllRefClkLost,
         qPllLockDetClk => qPllLockDetClk,
         qPllReset      => gtQPllRst,
         -- AXI Lite interface
         axilClk        => sysClk,
         axilRst        => sysRst);

   qPllLockDetClk <= sysClk & sysClk;
   gtQPllRst(0)   <= gtQPllReset(0) or qPllReset(0) or sysRst;
   gtQPllRst(1)   <= gtQPllReset(1) or qPllReset(1) or sysRst;

   -------------
   -- GTP Module
   -------------         
   U_GTP : entity work.EvrGtp7
      generic map (
         TPD_G            => TPD_G,
         DEFAULT_TIMING_G => DEFAULT_TIMING_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- GT Serial Ports
         gtTxP            => evrTxP,
         gtTxN            => evrTxN,
         gtRxP            => evrRxP,
         gtRxN            => evrRxN,
         -- GT Parallel Interface
         gtQPllOutRefClk  => gtQPllOutRefClk,
         gtQPllOutClk     => gtQPllOutClk,
         gtQPllLock       => gtQPllLock,
         gtQPllRefClkLost => gtQPllRefClkLost,
         gtQPllReset      => gtQPllReset,
         qPllRxSelect     => qPllRxSelect,
         qPllTxSelect     => qPllTxSelect,
         loopback         => loopback,
         stableClk        => sysClk,
         -- Rx Interface
         rxUserRst        => rxUserRst,
         rxClk            => rxClk,
         rxRst            => rxRst,
         rxData           => rxData,
         rxDataK          => rxDataK,
         rxDispErr        => rxDispErr,
         rxDecErr         => rxDecErr,
         rxControl        => rxControl,
         rxStatus         => rxStatus,
         -- Tx Interface
         txUserRst        => txUserRst,
         txClk            => txClk,
         txRst            => txRst,
         txData           => timingPhy.data,
         txDataK          => timingPhy.dataK,
         txControl        => timingPhy.control,
         txStatus         => txStatus);

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
         AXIL_ERROR_RESP_G => AXI_RESP_DECERR_C)
      port map (
         -- GT Interface
         gtTxUsrClk      => txClk,
         gtTxUsrRst      => txRst,
         gtRxRecClk      => rxClk,
         gtRxData        => rxData,
         gtRxDataK       => rxDataK,
         gtRxDispErr     => rxDispErr,
         gtRxDecErr      => rxDecErr,
         gtRxControl     => rxControl,
         gtRxStatus      => rxStatus,
         -- Decoded timing message interface
         appTimingClk    => rxClk,
         appTimingRst    => rxRst,
         appTimingBus    => evrTimingBus,
         timingPhy       => timingPhy,
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
         loopback        => loopback,
         evrMuxSel       => evrMuxSel,
         qPllRxSelect    => qPllRxSelect,
         qPllTxSelect    => qPllTxSelect,
         qPllReset       => qPllReset,
         gtQPllLock      => gtQPllLock,
         refClkDiv2      => refClkDiv2,
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
