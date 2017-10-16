-------------------------------------------------------------------------------
-- File       : EvrGtp7.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-04
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

entity EvrGtp7 is
   generic (
      TPD_G            : time            := 1 ns;
      DEFAULT_TIMING_G : boolean         := false;  -- false = LCLS-I, true = LCLS-II
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C);
   port (
      -- GT Serial Ports
      gtTxP            : out sl;
      gtTxN            : out sl;
      gtRxP            : in  sl;
      gtRxN            : in  sl;
      -- GT Parallel Interface
      gtQPllOutRefClk  : in  slv(1 downto 0);
      gtQPllOutClk     : in  slv(1 downto 0);
      gtQPllLock       : in  slv(1 downto 0);
      gtQPllRefClkLost : in  slv(1 downto 0);
      gtQPllReset      : out slv(1 downto 0);
      qPllRxSelect     : in  slv(1 downto 0);
      qPllTxSelect     : in  slv(1 downto 0);
      loopback         : in  slv(2 downto 0);
      stableClk        : in  sl;
      -- Rx Interface
      rxUserRst        : in  sl;
      rxClk            : out sl;
      rxRst            : out sl;
      rxData           : out slv(15 downto 0);
      rxDataK          : out slv(1 downto 0);
      rxDispErr        : out slv(1 downto 0);
      rxDecErr         : out slv(1 downto 0);
      rxControl        : in  TimingPhyControlType;
      rxStatus         : out TimingPhyStatusType;
      -- Tx Interface
      txUserRst        : in  sl;
      txClk            : out sl;
      txRst            : out sl;
      txData           : in  slv(15 downto 0);
      txDataK          : in  slv(1 downto 0);
      txControl        : in  TimingPhyControlType;
      txStatus         : out TimingPhyStatusType);
end EvrGtp7;

architecture mapping of EvrGtp7 is

   signal gtTxResetDone : sl;
   signal gtRxResetDone : sl;
   signal gtRxData      : slv(19 downto 0);
   signal gtTxData      : slv(15 downto 0);
   signal gtTxDataK     : slv(1 downto 0);

   signal data    : slv(15 downto 0);
   signal dataK   : slv(1 downto 0);
   signal decErr  : slv(1 downto 0);
   signal dispErr : slv(1 downto 0);


   signal cnt       : slv(23 downto 0);
   signal dataValid : sl;
   signal linkUp    : sl;

   signal evrRxRecClk : sl;
   signal evrTxClkOut : sl;
   signal evrTxClk    : sl;

   signal drpGnt  : sl;
   signal drpRdy  : sl;
   signal drpEn   : sl;
   signal drpWe   : sl;
   signal drpAddr : slv(8 downto 0);
   signal drpDi   : slv(15 downto 0);
   signal drpDo   : slv(15 downto 0);

begin

   rxClk <= evrRxRecClk;
   rxRst <= not(linkUp);

   txClk <= evrTxClk;
   txRst <= not(gtTxResetDone);

   rxStatus.locked       <= linkUp;
   rxStatus.resetDone    <= gtRxResetDone;
   rxStatus.bufferByDone <= gtRxResetDone;
   rxStatus.bufferByErr  <= not(dataValid);

   txStatus.locked       <= gtTxResetDone;
   txStatus.resetDone    <= gtTxResetDone;
   txStatus.bufferByDone <= gtTxResetDone;
   txStatus.bufferByErr  <= '0';

   --------------------------------------------------------------------------------------------------
   -- Rx Data Path
   -- Hold Decoder and PgpRx in reset until GtRxResetDone.
   --------------------------------------------------------------------------------------------------
   Decoder8b10b_Inst : entity work.Decoder8b10b
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '0',         -- Active low polarity
         NUM_BYTES_G    => 2)
      port map (
         clk      => evrRxRecClk,
         rst      => gtRxResetDone,
         dataIn   => gtRxData,
         dataOut  => data,
         dataKOut => dataK,
         codeErr  => decErr,
         dispErr  => dispErr);

   rxData    <= data    when(linkUp = '1') else (others => '0');
   rxDataK   <= dataK   when(linkUp = '1') else (others => '0');
   rxDispErr <= dispErr when(linkUp = '1') else (others => '0');
   rxDecErr  <= decErr  when(linkUp = '1') else (others => '0');
   dataValid <= not (uOr(decErr) or uOr(dispErr));

   -- Link up watchdog process
   process(evrRxRecClk, gtQPllLock, gtRxResetDone)
   begin
      if (gtRxResetDone = '0') or (gtQPllLock(1) = '0') then
         cnt    <= (others => '0') after TPD_G;
         linkUp <= '0'             after TPD_G;
      elsif rising_edge(evrRxRecClk) then
         if cnt = x"FFFFFF" then
            linkUp <= '1' after TPD_G;
         else
            cnt <= cnt + 1 after TPD_G;
         end if;
      end if;
   end process;

   --------------------------------------------------------------------------------------------------
   -- Generate the GTX channels (fixed latency)
   --------------------------------------------------------------------------------------------------

   Gtp7Core_Inst : entity work.Gtp7Core
      generic map (
         -- Simulation Generics
         TPD_G                 => 1 ns,
         SIM_GTRESET_SPEEDUP_G => "FALSE",
         SIM_VERSION_G         => "2.0",
         SIMULATION_G          => false,
         STABLE_CLOCK_PERIOD_G => 4.0E-9,
         -- TX/RX Settings
         RXOUT_DIV_G           => 2,
         TXOUT_DIV_G           => 2,
         RX_CLK25_DIV_G        => 7,
         TX_CLK25_DIV_G        => 7,
         RX_OS_CFG_G           => "0000010000000",
         RXCDR_CFG_G           => x"0001107FE206021081010",
         RXLPM_INCM_CFG_G      => '0',
         RXLPM_IPCM_CFG_G      => '1',
         -- Configure PLL sources
         DYNAMIC_QPLL_G        => true,
         TX_PLL_G              => "PLL0",
         RX_PLL_G              => "PLL1",
         -- Configure Data widths
         RX_EXT_DATA_WIDTH_G   => 20,
         RX_INT_DATA_WIDTH_G   => 20,
         RX_8B10B_EN_G         => false,
         TX_EXT_DATA_WIDTH_G   => 16,
         TX_INT_DATA_WIDTH_G   => 20,
         TX_8B10B_EN_G         => true,
         -- Configure RX comma alignment and buffer usage
         RX_ALIGN_MODE_G       => "FIXED_LAT",
         RX_BUF_EN_G           => false,
         RX_OUTCLK_SRC_G       => "OUTCLKPMA",
         RX_USRCLK_SRC_G       => "RXOUTCLK",
         RX_DLY_BYPASS_G       => '1',
         RX_DDIEN_G            => '0',
         RXSLIDE_MODE_G        => "PMA",
         -- Configure TX buffer
         TX_BUF_EN_G           => true,
         TX_OUTCLK_SRC_G       => "PLLREFDV2",
         -- TX_OUTCLK_SRC_G       => "OUTCLKPMA",
         TX_DLY_BYPASS_G       => '0',
         -- Fixed Latency comma alignment (If RX_ALIGN_MODE_G = "FIXED_LAT")
         FIXED_COMMA_EN_G      => "0011",
         FIXED_ALIGN_COMMA_0_G => "----------0101111100",  -- Normal Comma
         FIXED_ALIGN_COMMA_1_G => "----------1010000011",  -- Inverted Comma
         FIXED_ALIGN_COMMA_2_G => "XXXXXXXXXXXXXXXXXXXX",  -- Unused
         FIXED_ALIGN_COMMA_3_G => "XXXXXXXXXXXXXXXXXXXX")  -- Unused         
      port map (
         stableClkIn      => stableClk,
         qPllRefClkIn     => gtQPllOutRefClk,
         qPllClkIn        => gtQPllOutClk,
         qPllLockIn       => gtQPllLock,
         qPllRefClkLostIn => gtQPllRefClkLost,
         qPllResetOut     => gtQPllReset,
         qPllRxSelect     => qPllRxSelect,  -- "00" for LCLS-I timing, "11" for LCLS-II timing (changed via EvrMisc.vhd)
         qPllTxSelect     => qPllTxSelect,  -- "00" for LCLS-I timing, "11" for LCLS-II timing (changed via EvrMisc.vhd)
         -- Serial IO
         gtTxP            => gtTxP,
         gtTxN            => gtTxN,
         gtRxP            => gtRxP,
         gtRxN            => gtRxN,
         -- Rx Clock related signals
         rxOutClkOut      => evrRxRecClk,
         rxUsrClkIn       => evrRxRecClk,
         rxUsrClk2In      => evrRxRecClk,
         rxMmcmLockedIn   => '1',
         -- Rx User Reset Signals
         rxUserResetIn    => rxUserRst,
         rxResetDoneOut   => gtRxResetDone,
         -- Manual Comma Align signals
         rxDataValidIn    => dataValid,
         rxSlideIn        => '0',
         -- Rx Data and decode signals
         rxDataOut        => gtRxData,
         rxPolarityIn     => rxControl.polarity,
         -- Tx Clock Related Signals
         txOutClkOut      => evrTxClkOut,
         txUsrClkIn       => evrTxClk,
         txUsrClk2In      => evrTxClk,
         txMmcmLockedIn   => '1',
         -- Tx User Reset signals
         txUserResetIn    => txUserRst,
         txResetDoneOut   => gtTxResetDone,
         -- Tx Data
         txDataIn         => gtTxData,
         txCharIsKIn      => gtTxDataK,
         txPolarityIn     => txControl.polarity,
         -- Misc.
         loopbackIn       => loopback,
         txPreCursor      => "00000",
         txPostCursor     => "00000",
         txDiffCtrl       => "1000");

   U_BUFG : BUFG
      port map (
         I => evrTxClkOut,
         O => evrTxClk);

   -- Help with timing
   process(evrTxClk)
   begin
      if rising_edge(evrTxClk) then
         gtTxData  <= txData  after TPD_G;
         gtTxDataK <= txDataK after TPD_G;
      end if;
   end process;

end mapping;
