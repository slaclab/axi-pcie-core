-------------------------------------------------------------------------------
-- File       : Pgp2bGtp7DrpWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-06-29
-- Last update: 2017-10-07
-------------------------------------------------------------------------------
-- Description: Gtp7 Variable Latency, multi-lane Module
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.Pgp2bPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity Pgp2bGtp7DrpWrapper is
   generic (
      TPD_G             : time                 := 1 ns;
      LANE_CNT_G        : integer range 1 to 1 := 1;
      VC_INTERLEAVE_G   : integer              := 0;  -- No interleave Frames
      PAYLOAD_CNT_TOP_G : integer              := 7;  -- Top bit for payload counter
      NUM_VC_EN_G       : integer range 1 to 4 := 4;
      AXI_ERROR_RESP_G  : slv(1 downto 0)      := AXI_RESP_DECERR_C;
      TX_POLARITY_G     : sl                   := '0';
      RX_POLARITY_G     : sl                   := '0';
      TX_ENABLE_G       : boolean              := true;  -- Enable TX direction
      RX_ENABLE_G       : boolean              := true);  -- Enable RX direction
   port (
      -- GT Clocking
      qPllRxSelect     : in  slv(1 downto 0);
      qPllTxSelect     : in  slv(1 downto 0);
      gtQPllOutRefClk  : in  slv(1 downto 0);
      gtQPllOutClk     : in  slv(1 downto 0);
      gtQPllLock       : in  slv(1 downto 0);
      gtQPllRefClkLost : in  slv(1 downto 0);
      gtQPllReset      : out slv(1 downto 0);
      -- Gt Serial IO
      gtTxP            : out slv((LANE_CNT_G-1) downto 0);  -- GT Serial Transmit Positive
      gtTxN            : out slv((LANE_CNT_G-1) downto 0);  -- GT Serial Transmit Negative
      gtRxP            : in  slv((LANE_CNT_G-1) downto 0);  -- GT Serial Receive Positive
      gtRxN            : in  slv((LANE_CNT_G-1) downto 0);  -- GT Serial Receive Negative
      -- Tx Clocking
      pgpTxReset       : in  sl;
      pgpTxClk         : out sl;
      -- Rx clocking
      pgpRxReset       : in  sl;
      pgpRxClk         : out sl;
      -- Non VC Rx Signals
      pgpRxIn          : in  Pgp2bRxInType;
      pgpRxOut         : out Pgp2bRxOutType;
      -- Non VC Tx Signals
      pgpTxIn          : in  Pgp2bTxInType;
      pgpTxOut         : out Pgp2bTxOutType;
      -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
      pgpTxMasters     : in  AxiStreamMasterArray(3 downto 0);
      pgpTxSlaves      : out AxiStreamSlaveArray(3 downto 0);
      -- Frame Receive Interface - 1 Lane, Array of 4 VCs
      pgpRxMasters     : out AxiStreamMasterArray(3 downto 0);
      pgpRxMasterMuxed : out AxiStreamMasterType;
      pgpRxCtrl        : in  AxiStreamCtrlArray(3 downto 0);

      -- Debug Interface 
      txPreCursor      : in  slv(4 downto 0);
      txPostCursor     : in  slv(4 downto 0);
      txDiffCtrl       : in  slv(3 downto 0);
      drpOverride      : in  sl;
      -- AXI-Lite Interface 
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMasters  : in  AxiLiteReadMasterArray((LANE_CNT_G-1) downto 0);
      axilReadSlaves   : out AxiLiteReadSlaveArray((LANE_CNT_G-1) downto 0);
      axilWriteMasters : in  AxiLiteWriteMasterArray((LANE_CNT_G-1) downto 0);
      axilWriteSlaves  : out AxiLiteWriteSlaveArray((LANE_CNT_G-1) downto 0));

end Pgp2bGtp7DrpWrapper;

-- Define architecture
architecture rtl of Pgp2bGtp7DrpWrapper is

   component Pgp2bGtp7Drp
      port
         (
            SYSCLK_IN                   : in  std_logic;
            SOFT_RESET_TX_IN            : in  std_logic;
            SOFT_RESET_RX_IN            : in  std_logic;
            DONT_RESET_ON_DATA_ERROR_IN : in  std_logic;
            GT0_TX_FSM_RESET_DONE_OUT   : out std_logic;
            GT0_RX_FSM_RESET_DONE_OUT   : out std_logic;
            GT0_DRP_BUSY_OUT            : out std_logic;
            GT0_DATA_VALID_IN           : in  std_logic;

            --_________________________________________________________________________
            --GT0  (X0Y0)
            --____________________________CHANNEL PORTS________________________________
            ---------------------------- Channel - DRP Ports  --------------------------
            gt0_drpaddr_in           : in  std_logic_vector(8 downto 0);
            gt0_drpclk_in            : in  std_logic;
            gt0_drpdi_in             : in  std_logic_vector(15 downto 0);
            gt0_drpdo_out            : out std_logic_vector(15 downto 0);
            gt0_drpen_in             : in  std_logic;
            gt0_drprdy_out           : out std_logic;
            gt0_drpwe_in             : in  std_logic;
            ------------------------------- Clocking Ports -----------------------------
            gt0_rxsysclksel_in       : in  std_logic_vector(1 downto 0);
            gt0_txsysclksel_in       : in  std_logic_vector(1 downto 0);
            ------------------------------- Loopback Ports -----------------------------
            gt0_loopback_in          : in  std_logic_vector(2 downto 0);
            --------------------- RX Initialization and Reset Ports --------------------
            gt0_eyescanreset_in      : in  std_logic;
            gt0_rxuserrdy_in         : in  std_logic;
            -------------------------- RX Margin Analysis Ports ------------------------
            gt0_eyescandataerror_out : out std_logic;
            gt0_eyescantrigger_in    : in  std_logic;
            ------------------------- Receive Ports - CDR Ports ------------------------
            gt0_rxcdrovrden_in       : in  std_logic;
            ------------------- Receive Ports - Clock Correction Ports -----------------
            gt0_rxclkcorcnt_out      : out std_logic_vector(1 downto 0);
            ------------------ Receive Ports - FPGA RX Interface Ports -----------------
            gt0_rxdata_out           : out std_logic_vector(15 downto 0);
            gt0_rxusrclk_in          : in  std_logic;
            gt0_rxusrclk2_in         : in  std_logic;
            ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
            gt0_rxcharisk_out        : out std_logic_vector(1 downto 0);
            gt0_rxdisperr_out        : out std_logic_vector(1 downto 0);
            gt0_rxnotintable_out     : out std_logic_vector(1 downto 0);
            ------------------------ Receive Ports - RX AFE Ports ----------------------
            gt0_gtprxn_in            : in  std_logic;
            gt0_gtprxp_in            : in  std_logic;
            ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
            gt0_rxbufreset_in        : in  std_logic;
            ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
            gt0_dmonitorout_out      : out std_logic_vector(14 downto 0);
            -------------------- Receive Ports - RX Equailizer Ports -------------------
            gt0_rxlpmhfhold_in       : in  std_logic;
            gt0_rxlpmhfovrden_in     : in  std_logic;
            gt0_rxlpmlfhold_in       : in  std_logic;
            --------------- Receive Ports - RX Fabric Output Control Ports -------------
            gt0_rxoutclk_out         : out std_logic;
            gt0_rxoutclkfabric_out   : out std_logic;
            ------------- Receive Ports - RX Initialization and Reset Ports ------------
            gt0_gtrxreset_in         : in  std_logic;
            gt0_rxlpmreset_in        : in  std_logic;
            gt0_rxpcsreset_in        : in  std_logic;
            gt0_rxpmareset_in        : in  std_logic;
            ----------------- Receive Ports - RX Polarity Control Ports ----------------
            gt0_rxpolarity_in        : in  std_logic;
            -------------- Receive Ports -RX Initialization and Reset Ports ------------
            gt0_rxresetdone_out      : out std_logic;
            ------------------------ TX Configurable Driver Ports ----------------------
            gt0_txpostcursor_in      : in  std_logic_vector(4 downto 0);
            gt0_txprecursor_in       : in  std_logic_vector(4 downto 0);
            --------------------- TX Initialization and Reset Ports --------------------
            gt0_gttxreset_in         : in  std_logic;
            gt0_txuserrdy_in         : in  std_logic;
            ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
            gt0_txdata_in            : in  std_logic_vector(15 downto 0);
            gt0_txusrclk_in          : in  std_logic;
            gt0_txusrclk2_in         : in  std_logic;
            ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
            gt0_txcharisk_in         : in  std_logic_vector(1 downto 0);
            --------------- Transmit Ports - TX Configurable Driver Ports --------------
            gt0_gtptxn_out           : out std_logic;
            gt0_gtptxp_out           : out std_logic;
            gt0_txdiffctrl_in        : in  std_logic_vector(3 downto 0);
            ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
            gt0_txoutclk_out         : out std_logic;
            gt0_txoutclkfabric_out   : out std_logic;
            gt0_txoutclkpcs_out      : out std_logic;
            ------------- Transmit Ports - TX Initialization and Reset Ports -----------
            gt0_txpcsreset_in        : in  std_logic;
            gt0_txpmareset_in        : in  std_logic;
            gt0_txresetdone_out      : out std_logic;
            ----------------- Transmit Ports - TX Polarity Control Ports ---------------
            gt0_txpolarity_in        : in  std_logic;


            --____________________________COMMON PORTS________________________________
            GT0_PLL0OUTCLK_IN     : in  std_logic;
            GT0_PLL0OUTREFCLK_IN  : in  std_logic;
            GT0_PLL0RESET_OUT     : out std_logic;
            GT0_PLL0LOCK_IN       : in  std_logic;
            GT0_PLL0REFCLKLOST_IN : in  std_logic;
            GT0_PLL1RESET_OUT     : out std_logic;
            GT0_PLL1LOCK_IN       : in  std_logic;
            GT0_PLL1REFCLKLOST_IN : in  std_logic;
            GT0_PLL1OUTCLK_IN     : in  std_logic;
            GT0_PLL1OUTREFCLK_IN  : in  std_logic

            );
   end component;

   --------------------------------------------------------------------------------------------------
   -- Types
   --------------------------------------------------------------------------------------------------
   type QPllResetsVector is array (integer range<>) of slv(1 downto 0);

   --------------------------------------------------------------------------------------------------
   -- Constants
   --------------------------------------------------------------------------------------------------
   signal gtQPllResets : QPllResetsVector((LANE_CNT_G-1) downto 0);

   -- PgpRx Signals
   signal pgpTxRecClk     : slv((LANE_CNT_G-1) downto 0);
   signal pgpTxClock      : slv((LANE_CNT_G-1) downto 0);
   signal gtRxResetDone   : slv((LANE_CNT_G-1) downto 0);
   signal gtRxReset       : sl;
   signal gtRxUserRst     : sl;
   signal gtRxUserReset   : sl;
   signal gtRxUserResetIn : sl;
   signal phyRxLanesIn    : Pgp2bRxPhyLaneInArray((LANE_CNT_G-1) downto 0);
   signal phyRxLanesOut   : Pgp2bRxPhyLaneOutArray((LANE_CNT_G-1) downto 0);
   signal phyRxReady      : sl;
   signal phyRxInit       : sl;
   signal locRxOut        : Pgp2bRxOutType;

   -- Rx Channel Bonding
   signal rxChBondLevel : slv(2 downto 0);
   signal rxChBondIn    : Slv4Array(LANE_CNT_G-1 downto 0);
   signal rxChBondOut   : Slv4Array(LANE_CNT_G-1 downto 0);

   -- PgpTx Signals
   signal pgpRxRecClk     : slv((LANE_CNT_G-1) downto 0);
   signal pgpRxClock      : slv((LANE_CNT_G-1) downto 0);
   signal gtTxResetDone   : slv((LANE_CNT_G-1) downto 0);
   signal gtTxUserResetIn : sl;
   signal phyTxLanesOut   : Pgp2bTxPhyLaneOutArray((LANE_CNT_G-1) downto 0);
   signal phyTxReady      : sl;

   signal drpGntL : slv(LANE_CNT_G-1 downto 0);
   signal drpGnt  : slv(LANE_CNT_G-1 downto 0);
   signal drpRdy  : slv(LANE_CNT_G-1 downto 0);
   signal drpEn   : slv(LANE_CNT_G-1 downto 0);
   signal drpWe   : slv(LANE_CNT_G-1 downto 0);
   signal drpAddr : Slv9Array(LANE_CNT_G-1 downto 0);
   signal drpDi   : Slv16Array(LANE_CNT_G-1 downto 0);
   signal drpDo   : Slv16Array(LANE_CNT_G-1 downto 0);

begin

   pgpRxOut <= locRxOut;

   gtQPllReset <= gtQPllResets(0);

   pgpRxClk <= pgpRxClock(0);
   pgpTxClk <= pgpTxClock(0);

   phyTxReady <= gtTxResetDone(0);
   phyRxReady <= gtRxResetDone(0);

   gtTxUserResetIn <= pgpTxReset;
   gtRxUserRst     <= gtRxUserReset and not(drpOverride);
   gtRxReset       <= gtRxUserRst or pgpRxReset;

   -- U_PgpRxLinkWatchDog : entity work.PgpRxLinkWatchDog
      -- generic map (
         -- TPD_G => TPD_G)
      -- port map (
         -- stableClk   => axilClk,
         -- phyRxReady  => phyRxReady,
         -- pgpRxOut    => locRxOut,
         -- pgpRxRstIn  => gtRxReset,
         -- pgpRxRstOut => gtRxUserResetIn);
         
   gtRxUserResetIn <= gtRxReset;     

   U_Pgp2bLane : entity work.Pgp2bLane
      generic map (
         TPD_G             => TPD_G,
         LANE_CNT_G        => 1,
         VC_INTERLEAVE_G   => VC_INTERLEAVE_G,
         PAYLOAD_CNT_TOP_G => PAYLOAD_CNT_TOP_G,
         NUM_VC_EN_G       => NUM_VC_EN_G,
         TX_ENABLE_G       => TX_ENABLE_G,
         RX_ENABLE_G       => RX_ENABLE_G)
      port map (
         pgpTxClk         => pgpTxClock(0),
         pgpTxClkRst      => pgpTxReset,
         pgpTxIn          => pgpTxIn,
         pgpTxOut         => pgpTxOut,
         pgpTxMasters     => pgpTxMasters,
         pgpTxSlaves      => pgpTxSlaves,
         phyTxLanesOut    => phyTxLanesOut,
         phyTxReady       => phyTxReady,
         pgpRxClk         => pgpRxClock(0),
         pgpRxClkRst      => pgpRxReset,
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => locRxOut,
         pgpRxMasters     => pgpRxMasters,
         pgpRxMasterMuxed => pgpRxMasterMuxed,
         pgpRxCtrl        => pgpRxCtrl,
         phyRxLanesOut    => phyRxLanesOut,
         phyRxLanesIn     => phyRxLanesIn,
         phyRxReady       => phyRxReady,
         phyRxInit        => gtRxUserReset);

   --------------------------------------------------------------------------------------------------
   -- Generate the GTP channels
   --------------------------------------------------------------------------------------------------
   GTP7_CORE_GEN : for i in (LANE_CNT_G-1) downto 0 generate

      drpGnt(i) <= not(drpGntL(i));

      U_GT : Pgp2bGtp7Drp
         port map(
            SYSCLK_IN                   => axilClk,
            SOFT_RESET_TX_IN            => gtTxUserResetIn,
            SOFT_RESET_RX_IN            => gtRxUserResetIn,
            DONT_RESET_ON_DATA_ERROR_IN => drpOverride,
            GT0_TX_FSM_RESET_DONE_OUT   => gtTxResetDone(i),
            GT0_RX_FSM_RESET_DONE_OUT   => gtRxResetDone(i),
            GT0_DRP_BUSY_OUT            => drpGntL(i),
            GT0_DATA_VALID_IN           => '1',

            --_________________________________________________________________________
            --GT0  (X0Y0)
            --____________________________CHANNEL PORTS________________________________
            ---------------------------- Channel - DRP Ports  --------------------------
            gt0_drpaddr_in           => drpAddr(i),
            gt0_drpclk_in            => axilClk,
            gt0_drpdi_in             => drpDi(i),
            gt0_drpdo_out            => drpDo(i),
            gt0_drpen_in             => drpEn(i),
            gt0_drprdy_out           => drpRdy(i),
            gt0_drpwe_in             => drpWe(i),
            ------------------------------- Clocking Ports -----------------------------
            gt0_rxsysclksel_in       => qPllRxSelect,
            gt0_txsysclksel_in       => qPllTxSelect,
            ------------------------------- Loopback Ports -----------------------------
            gt0_loopback_in          => pgpRxIn.loopback,
            --------------------- RX Initialization and Reset Ports --------------------
            gt0_eyescanreset_in      => '0',
            gt0_rxuserrdy_in         => '1',
            -------------------------- RX Margin Analysis Ports ------------------------
            gt0_eyescandataerror_out => open,
            gt0_eyescantrigger_in    => '0',
            ------------------------- Receive Ports - CDR Ports ------------------------
            gt0_rxcdrovrden_in       => '0',
            ------------------- Receive Ports - Clock Correction Ports -----------------
            gt0_rxclkcorcnt_out      => open,
            ------------------ Receive Ports - FPGA RX Interface Ports -----------------
            gt0_rxdata_out           => phyRxLanesIn(i).data,
            gt0_rxusrclk_in          => pgpRxClock(i),
            gt0_rxusrclk2_in         => pgpRxClock(i),
            ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
            gt0_rxcharisk_out        => phyRxLanesIn(i).dataK,
            gt0_rxdisperr_out        => phyRxLanesIn(i).dispErr,
            gt0_rxnotintable_out     => phyRxLanesIn(i).decErr,
            ------------------------ Receive Ports - RX AFE Ports ----------------------
            gt0_gtprxn_in            => gtRxN(i),
            gt0_gtprxp_in            => gtRxP(i),
            ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
            gt0_rxbufreset_in        => gtRxUserResetIn,
            ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
            gt0_dmonitorout_out      => open,
            -------------------- Receive Ports - RX Equailizer Ports -------------------
            gt0_rxlpmhfhold_in       => '0',
            gt0_rxlpmhfovrden_in     => '0',
            gt0_rxlpmlfhold_in       => '0',
            --------------- Receive Ports - RX Fabric Output Control Ports -------------
            gt0_rxoutclk_out         => pgpRxRecClk(i),
            gt0_rxoutclkfabric_out   => open,
            ------------- Receive Ports - RX Initialization and Reset Ports ------------
            gt0_gtrxreset_in         => gtRxUserResetIn,
            gt0_rxlpmreset_in        => gtRxUserResetIn,
            gt0_rxpcsreset_in        => gtRxUserResetIn,
            gt0_rxpmareset_in        => gtRxUserResetIn,
            ----------------- Receive Ports - RX Polarity Control Ports ----------------
            gt0_rxpolarity_in        => RX_POLARITY_G,
            -------------- Receive Ports -RX Initialization and Reset Ports ------------
            gt0_rxresetdone_out      => open,
            ------------------------ TX Configurable Driver Ports ----------------------
            gt0_txpostcursor_in      => txPostCursor,
            gt0_txprecursor_in       => txPreCursor,
            --------------------- TX Initialization and Reset Ports --------------------
            gt0_gttxreset_in         => gtTxUserResetIn,
            gt0_txuserrdy_in         => '1',
            ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
            gt0_txdata_in            => phyTxLanesOut(i).data,
            gt0_txusrclk_in          => pgpTxClock(i),
            gt0_txusrclk2_in         => pgpTxClock(i),
            ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
            gt0_txcharisk_in         => phyTxLanesOut(i).dataK,
            --------------- Transmit Ports - TX Configurable Driver Ports --------------
            gt0_gtptxn_out           => gtTxN(i),
            gt0_gtptxp_out           => gtTxP(i),
            gt0_txdiffctrl_in        => txDiffCtrl,
            ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
            gt0_txoutclk_out         => pgpTxRecClk(i),
            gt0_txoutclkfabric_out   => open,
            gt0_txoutclkpcs_out      => open,
            ------------- Transmit Ports - TX Initialization and Reset Ports -----------
            gt0_txpcsreset_in        => gtTxUserResetIn,
            gt0_txpmareset_in        => gtTxUserResetIn,
            gt0_txresetdone_out      => open,
            ----------------- Transmit Ports - TX Polarity Control Ports ---------------
            gt0_txpolarity_in        => TX_POLARITY_G,
            --____________________________COMMON PORTS________________________________
            GT0_PLL0OUTREFCLK_IN     => gtQPllOutRefClk(0),
            GT0_PLL0OUTCLK_IN        => gtQPllOutClk(0),
            GT0_PLL0LOCK_IN          => gtQPllLock(0),
            GT0_PLL0REFCLKLOST_IN    => gtQPllRefClkLost(0),
            GT0_PLL0RESET_OUT        => gtQPllResets(i)(0),
            GT0_PLL1OUTREFCLK_IN     => gtQPllOutRefClk(1),
            GT0_PLL1OUTCLK_IN        => gtQPllOutClk(1),
            GT0_PLL1LOCK_IN          => gtQPllLock(1),
            GT0_PLL1REFCLKLOST_IN    => gtQPllRefClkLost(1),
            GT0_PLL1RESET_OUT        => gtQPllResets(i)(1));

      U_TX : BUFG
         port map (
            I => pgpTxRecClk(i),
            O => pgpTxClock(i));

      U_RX : BUFG
         port map (
            I => pgpRxRecClk(i),
            O => pgpRxClock(i));

      U_AxiLiteToDrp : entity work.AxiLiteToDrp
         generic map (
            TPD_G            => TPD_G,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
            COMMON_CLK_G     => true,
            EN_ARBITRATION_G => true,
            TIMEOUT_G        => 4096,
            ADDR_WIDTH_G     => 9,
            DATA_WIDTH_G     => 16)
         port map (
            -- AXI-Lite Port
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i),
            -- DRP Interface
            drpClk          => axilClk,
            drpRst          => axilRst,
            drpGnt          => drpGnt(i),
            drpRdy          => drpRdy(i),
            drpEn           => drpEn(i),
            drpWe           => drpWe(i),
            drpAddr         => drpAddr(i),
            drpDi           => drpDi(i),
            drpDo           => drpDo(i));

   end generate GTP7_CORE_GEN;

end rtl;
