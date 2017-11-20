-------------------------------------------------------------------------------
-- File       : EvrGthCoreWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-06-09
-- Last update: 2016-12-04
-------------------------------------------------------------------------------
-- Description: Wrapper for GTH Core
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 Timing Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 Timing Core', including this file, 
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

entity EvrGthCoreWrapper is
   generic (
      TPD_G            : time            := 1 ns;
      EXTREF_G         : boolean         := false;
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- AXI-Lite Port
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      stableClk : in  sl;
      -- GTH FPGA IO
      gtRefClk  : in  sl;
      gtRxP     : in  sl;
      gtRxN     : in  sl;
      gtTxP     : out sl;
      gtTxN     : out sl;

      -- Rx ports
      rxControl      : in  TimingPhyControlType;
      rxStatus       : out TimingPhyStatusType;
      rxUsrClkActive : in  sl;
      rxCdrStable    : out sl;
      rxUsrClk       : in  sl;
      rxData         : out slv(15 downto 0);
      rxDataK        : out slv(1 downto 0);
      rxDispErr      : out slv(1 downto 0);
      rxDecErr       : out slv(1 downto 0);
      rxOutClk       : out sl;

      -- Tx Ports
      txControl      : in  TimingPhyControlType;
      txStatus       : out TimingPhyStatusType;
      txUsrClk       : in  sl;
      txUsrClkActive : in  sl;
      txData         : in  slv(15 downto 0);
      txDataK        : in  slv(1 downto 0);
      txOutClk       : out sl;

      loopback : in slv(2 downto 0));
end entity EvrGthCoreWrapper;

architecture rtl of EvrGthCoreWrapper is
   component TimingGth_clksel
      port (
         gtwiz_userclk_tx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_userdata_tx_in               : in  std_logic_vector(15 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
         drpaddr_in                         : in  std_logic_vector(8 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         drpdi_in                           : in  std_logic_vector(15 downto 0);
         drpen_in                           : in  std_logic_vector(0 downto 0);
         drpwe_in                           : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         loopback_in                        : in  std_logic_vector(2 downto 0);
         rx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         rxcommadeten_in                    : in  std_logic_vector(0 downto 0);
         rxmcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpolarity_in                      : in  std_logic_vector(0 downto 0);
         rxusrclk_in                        : in  std_logic_vector(0 downto 0);
         rxusrclk2_in                       : in  std_logic_vector(0 downto 0);
         tx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         txctrl0_in                         : in  std_logic_vector(15 downto 0);
         txctrl1_in                         : in  std_logic_vector(15 downto 0);
         txctrl2_in                         : in  std_logic_vector(7 downto 0);
         txinhibit_in                       : in  std_logic_vector(0 downto 0);
         txpolarity_in                      : in  std_logic_vector(0 downto 0);
         txusrclk_in                        : in  std_logic_vector(0 downto 0);
         txusrclk2_in                       : in  std_logic_vector(0 downto 0);
         drpdo_out                          : out std_logic_vector(15 downto 0);
         drprdy_out                         : out std_logic_vector(0 downto 0);
         gthtxn_out                         : out std_logic_vector(0 downto 0);
         gthtxp_out                         : out std_logic_vector(0 downto 0);
         rxbyteisaligned_out                : out std_logic_vector(0 downto 0);
         rxbyterealign_out                  : out std_logic_vector(0 downto 0);
         rxcommadet_out                     : out std_logic_vector(0 downto 0);
         rxctrl0_out                        : out std_logic_vector(15 downto 0);
         rxctrl1_out                        : out std_logic_vector(15 downto 0);
         rxctrl2_out                        : out std_logic_vector(7 downto 0);
         rxctrl3_out                        : out std_logic_vector(7 downto 0);
         rxoutclk_out                       : out std_logic_vector(0 downto 0);
         rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
         txoutclk_out                       : out std_logic_vector(0 downto 0);
         txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
         );
   end component;
   component TimingGth_fixedlat
      port (
         gtwiz_userclk_tx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_userdata_tx_in               : in  std_logic_vector(15 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
         drpaddr_in                         : in  std_logic_vector(8 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         drpdi_in                           : in  std_logic_vector(15 downto 0);
         drpen_in                           : in  std_logic_vector(0 downto 0);
         drpwe_in                           : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         loopback_in                        : in  std_logic_vector(2 downto 0);
         rx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         rxcommadeten_in                    : in  std_logic_vector(0 downto 0);
         rxmcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpolarity_in                      : in  std_logic_vector(0 downto 0);
         rxusrclk_in                        : in  std_logic_vector(0 downto 0);
         rxusrclk2_in                       : in  std_logic_vector(0 downto 0);
         tx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         txctrl0_in                         : in  std_logic_vector(15 downto 0);
         txctrl1_in                         : in  std_logic_vector(15 downto 0);
         txctrl2_in                         : in  std_logic_vector(7 downto 0);
         txinhibit_in                       : in  std_logic_vector(0 downto 0);
         txpolarity_in                      : in  std_logic_vector(0 downto 0);
         txusrclk_in                        : in  std_logic_vector(0 downto 0);
         txusrclk2_in                       : in  std_logic_vector(0 downto 0);
         drpdo_out                          : out std_logic_vector(15 downto 0);
         drprdy_out                         : out std_logic_vector(0 downto 0);
         gthtxn_out                         : out std_logic_vector(0 downto 0);
         gthtxp_out                         : out std_logic_vector(0 downto 0);
         rxbyteisaligned_out                : out std_logic_vector(0 downto 0);
         rxbyterealign_out                  : out std_logic_vector(0 downto 0);
         rxcommadet_out                     : out std_logic_vector(0 downto 0);
         rxctrl0_out                        : out std_logic_vector(15 downto 0);
         rxctrl1_out                        : out std_logic_vector(15 downto 0);
         rxctrl2_out                        : out std_logic_vector(7 downto 0);
         rxctrl3_out                        : out std_logic_vector(7 downto 0);
         rxdlysresetdone_out                : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxoutclk_out                       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxphaligndone_out                  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxphalignerr_out                   : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxpmaresetdone_out                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxresetdone_out                    : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxsyncdone_out                     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxsyncout_out                      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txoutclk_out                       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txpmaresetdone_out                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txresetdone_out                    : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
         );
   end component;
   component TimingGth_extref
      port (
         gtwiz_userclk_tx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_userdata_tx_in               : in  std_logic_vector(15 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
         drpaddr_in                         : in  std_logic_vector(8 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         drpdi_in                           : in  std_logic_vector(15 downto 0);
         drpen_in                           : in  std_logic_vector(0 downto 0);
         drpwe_in                           : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         loopback_in                        : in  std_logic_vector(2 downto 0);
         rx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         rxcommadeten_in                    : in  std_logic_vector(0 downto 0);
         rxmcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpolarity_in                      : in  std_logic_vector(0 downto 0);
         rxusrclk_in                        : in  std_logic_vector(0 downto 0);
         rxusrclk2_in                       : in  std_logic_vector(0 downto 0);
         tx8b10ben_in                       : in  std_logic_vector(0 downto 0);
         txctrl0_in                         : in  std_logic_vector(15 downto 0);
         txctrl1_in                         : in  std_logic_vector(15 downto 0);
         txctrl2_in                         : in  std_logic_vector(7 downto 0);
         txinhibit_in                       : in  std_logic_vector(0 downto 0);
         txpolarity_in                      : in  std_logic_vector(0 downto 0);
         txusrclk_in                        : in  std_logic_vector(0 downto 0);
         txusrclk2_in                       : in  std_logic_vector(0 downto 0);
         drpdo_out                          : out std_logic_vector(15 downto 0);
         drprdy_out                         : out std_logic_vector(0 downto 0);
         gthtxn_out                         : out std_logic_vector(0 downto 0);
         gthtxp_out                         : out std_logic_vector(0 downto 0);
         rxbyteisaligned_out                : out std_logic_vector(0 downto 0);
         rxbyterealign_out                  : out std_logic_vector(0 downto 0);
         rxcommadet_out                     : out std_logic_vector(0 downto 0);
         rxctrl0_out                        : out std_logic_vector(15 downto 0);
         rxctrl1_out                        : out std_logic_vector(15 downto 0);
         rxctrl2_out                        : out std_logic_vector(7 downto 0);
         rxctrl3_out                        : out std_logic_vector(7 downto 0);
         rxdlysresetdone_out                : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxoutclk_out                       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxphaligndone_out                  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxphalignerr_out                   : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxpmaresetdone_out                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxresetdone_out                    : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxsyncdone_out                     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         rxsyncout_out                      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txoutclk_out                       : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txpmaresetdone_out                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         txresetdone_out                    : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
         );
   end component;
   
   
   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(1 downto 0) := (
      0               => (
         baseAddr     => (AXIL_BASE_ADDR_G+x"00000000"),
         addrBits     => 12,
         connectivity => x"FFFF"),
      1               => (
         baseAddr     => (AXIL_BASE_ADDR_G+x"00001000"), 
         addrBits     => 12,
         connectivity => x"FFFF"));   

   signal rxCtrl0Out   : slv(15 downto 0);
   signal rxCtrl1Out   : slv(15 downto 0);
   signal rxCtrl3Out   : slv(7 downto 0);
   signal txoutclk_out : sl;
   signal txoutclkb    : sl;
   signal rxoutclk_out : sl;
   signal rxoutclkb    : sl;

   signal drpClk  : sl;
   signal drpRst  : sl;
   signal drpAddr : slv(8 downto 0);
   signal drpDi   : slv(15 downto 0);
   signal drpEn   : sl;
   signal drpWe   : sl;
   signal drpDO   : slv(15 downto 0);
   signal drpRdy  : sl;
   signal txbypassrst  : sl;
   signal rxbypassrst  : sl;
   signal rxRst         : sl;
   signal bypassdone    : sl;
   signal bypasserr     : sl;
   
   signal axilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);   
   
   signal mAxilWriteMaster : AxiLiteWriteMasterType;
   signal mAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal mAxilReadMaster  : AxiLiteReadMasterType;
   signal mAxilReadSlave   : AxiLiteReadSlaveType;
   
begin
 
   rxStatus.bufferByDone <= bypassdone;
   rxStatus.bufferByErr  <= bypasserr;

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => 2,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteMasters(1) => mAxilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiWriteSlaves(1)  => mAxilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadMasters(1)  => mAxilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         sAxiReadSlaves(1)   => mAxilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves); 

   U_AlignCheck : entity work.GthRxAlignCheck
      generic map (
        TPD_G            => TPD_G,
        AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
        DRP_ADDR_G       => AXI_CROSSBAR_MASTERS_CONFIG_C(1).baseAddr)
      port map (
         -- GTH Status/Control Interface
         resetIn         => rxControl.reset,
         resetDone       => bypassdone,
         resetErr        => bypasserr,
         resetOut        => rxRst,
         locked          => rxStatus.locked,
         -- Clock and Reset
         axilClk          => axilClk,
         axilRst          => axilRst,
         -- Slave AXI-Lite Interface
         mAxilReadMaster   => mAxilReadMaster,
         mAxilReadSlave    => mAxilReadSlave,
         mAxilWriteMaster  => mAxilWriteMaster,
         mAxilWriteSlave   => mAxilWriteSlave,
         -- Slave AXI-Lite Interface
         sAxilReadMaster   => axilReadMasters(0),
         sAxilReadSlave    => axilReadSlaves(0),
         sAxilWriteMaster  => axilWriteMasters(0),
         sAxilWriteSlave   => axilWriteSlaves(0));

   U_AxiLiteToDrp : entity work.AxiLiteToDrp
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
         COMMON_CLK_G     => true,
         EN_ARBITRATION_G => false,
         TIMEOUT_G        => 4096,
         ADDR_WIDTH_G     => 9,
         DATA_WIDTH_G     => 16)      
      port map (
         -- AXI-Lite Port
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(1),
         axilReadSlave   => axilReadSlaves(1),
         axilWriteMaster => axilWriteMasters(1),
         axilWriteSlave  => axilWriteSlaves(1),
         -- DRP Interface
         drpClk          => axilClk,
         drpRst          => axilRst,
         drpRdy          => drpRdy,
         drpEn           => drpEn,
         drpWe           => drpWe,
         drpAddr         => drpAddr,
         drpDi           => drpDi,
         drpDo           => drpDo); 

   drpClk <= axilClk;
   drpRst <= axilRst;

   GEN_EXTREF : if EXTREF_G generate
      U_TimingGthCore : TimingGth_extref
         port map (
            gtwiz_userclk_tx_active_in(0)         => txUsrClkActive,
            gtwiz_userclk_rx_active_in(0)         => rxUsrClkActive,
            gtwiz_buffbypass_tx_reset_in(0)       => txbypassrst,
            gtwiz_buffbypass_tx_start_user_in(0)  => '0',
            gtwiz_buffbypass_tx_done_out          => open,
            gtwiz_buffbypass_tx_error_out         => open,
            gtwiz_buffbypass_rx_reset_in(0)       => rxbypassrst,
            gtwiz_buffbypass_rx_start_user_in(0)  => '0',
            gtwiz_buffbypass_rx_done_out(0)       => bypassdone,
            gtwiz_buffbypass_rx_error_out(0)      => bypasserr,
            gtwiz_reset_clk_freerun_in(0)         => stableClk,
            gtwiz_reset_all_in(0)                 => '0',
            gtwiz_reset_tx_pll_and_datapath_in(0) => txControl.pllReset,
            gtwiz_reset_tx_datapath_in(0)         => txControl.reset,
            gtwiz_reset_rx_pll_and_datapath_in(0) => rxControl.pllReset,
            gtwiz_reset_rx_datapath_in(0)         => rxRst,
            gtwiz_reset_rx_cdr_stable_out(0)      => rxCdrStable,
            gtwiz_reset_tx_done_out(0)            => txStatus.resetDone,
            gtwiz_reset_rx_done_out(0)            => rxStatus.resetDone,
            gtwiz_userdata_tx_in                  => txData,
            gtwiz_userdata_rx_out                 => rxData,
            drpaddr_in                            => drpAddr,
            drpclk_in(0)                          => drpClk,
            drpdi_in                              => drpDi,
            drpen_in(0)                           => drpEn,
            drpwe_in(0)                           => drpWe,
            gthrxn_in(0)                          => gtRxN,
            gthrxp_in(0)                          => gtRxP,
            gtrefclk0_in(0)                       => gtRefClk,
            loopback_in                           => loopback,
            rx8b10ben_in(0)                       => '1',
            rxcommadeten_in(0)                    => '1',
            rxmcommaalignen_in(0)                 => '1',
            rxpcommaalignen_in(0)                 => '1',
            rxpolarity_in(0)                      => rxControl.polarity,
            rxusrclk_in(0)                        => rxUsrClk,
            rxusrclk2_in(0)                       => rxUsrClk,
            tx8b10ben_in(0)                       => '1',
            txctrl0_in                            => X"0000",
            txctrl1_in                            => X"0000",
            txctrl2_in(1 downto 0)                => txDataK,
            txctrl2_in(7 downto 2)                => (others => '0'),
            txinhibit_in(0)                       => txControl.inhibit,
            txpolarity_in(0)                      => txControl.polarity,
            txusrclk_in(0)                        => txUsrClk,
            txusrclk2_in(0)                       => txUsrClk,
            drpdo_out                             => drpDo,
            drprdy_out(0)                         => drpRdy,
            gthtxn_out(0)                         => gtTxN,
            gthtxp_out(0)                         => gtTxP,
            rxbyteisaligned_out                   => open,
            rxbyterealign_out                     => open,
            rxcommadet_out                        => open,
            rxctrl0_out                           => rxCtrl0Out,
            rxctrl1_out                           => rxCtrl1Out,
            rxctrl2_out                           => open,
            rxctrl3_out                           => rxCtrl3Out,
            rxoutclk_out(0)                       => rxoutclk_out,
            rxpmaresetdone_out(0)                 => open,
            txoutclk_out(0)                       => txoutclk_out,
            txpmaresetdone_out(0)                 => open );

      rxDataK   <= rxCtrl0Out(1 downto 0);
      rxDispErr <= rxCtrl1Out(1 downto 0);
      rxDecErr  <= rxCtrl3Out(1 downto 0);

      TIMING_TXCLK_BUFG_GT : BUFG_GT
         port map (
            I       => txoutclk_out,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide-by-1
            O       => txoutclkb);

      TIMING_RECCLK_BUFG_GT : BUFG_GT
         port map (
            I       => rxoutclk_out,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide-by-1
            O       => rxoutclkb);
   end generate;

   LOCREF_G : if not EXTREF_G generate
      U_TimingGthCore : TimingGth_fixedlat
         port map (
            gtwiz_userclk_tx_active_in(0)         => txUsrClkActive,
            gtwiz_userclk_rx_active_in(0)         => rxUsrClkActive,
            gtwiz_buffbypass_tx_reset_in(0)       => txbypassrst,
            gtwiz_buffbypass_tx_start_user_in(0)  => '0',
            gtwiz_buffbypass_tx_done_out          => open,
            gtwiz_buffbypass_tx_error_out         => open,
            gtwiz_buffbypass_rx_reset_in(0)       => rxbypassrst,
            gtwiz_buffbypass_rx_start_user_in(0)  => '0',
            gtwiz_buffbypass_rx_done_out(0)       => bypassdone,
            gtwiz_buffbypass_rx_error_out(0)      => bypasserr,
            gtwiz_reset_clk_freerun_in(0)         => stableClk,
            gtwiz_reset_all_in(0)                 => '0',
            gtwiz_reset_tx_pll_and_datapath_in(0) => txControl.pllReset,
            gtwiz_reset_tx_datapath_in(0)         => txControl.reset,
            gtwiz_reset_rx_pll_and_datapath_in(0) => rxControl.pllReset,
            gtwiz_reset_rx_datapath_in(0)         => rxRst,
            gtwiz_reset_rx_cdr_stable_out(0)      => rxCdrStable,
            gtwiz_reset_tx_done_out(0)            => txStatus.resetDone,
            gtwiz_reset_rx_done_out(0)            => rxStatus.resetDone,
            gtwiz_userdata_tx_in                  => txData,
            gtwiz_userdata_rx_out                 => rxData,
            drpaddr_in                            => drpAddr,
            drpclk_in(0)                          => drpClk,
            drpdi_in                              => drpDi,
            drpen_in(0)                           => drpEn,
            drpwe_in(0)                           => drpWe,
            gthrxn_in(0)                          => gtRxN,
            gthrxp_in(0)                          => gtRxP,
            gtrefclk0_in(0)                       => gtRefClk,
            loopback_in                           => loopback,
            rx8b10ben_in(0)                       => '1',
            rxcommadeten_in(0)                    => '1',
            rxmcommaalignen_in(0)                 => '1',
            rxpcommaalignen_in(0)                 => '1',
            rxpolarity_in(0)                      => rxControl.polarity,
            rxusrclk_in(0)                        => rxUsrClk,
            rxusrclk2_in(0)                       => rxUsrClk,
            tx8b10ben_in(0)                       => '1',
            txctrl0_in                            => X"0000",
            txctrl1_in                            => X"0000",
            txctrl2_in(1 downto 0)                => txDataK,
            txctrl2_in(7 downto 2)                => (others => '0'),
            txinhibit_in(0)                       => txControl.inhibit,
            txpolarity_in(0)                      => txControl.polarity,
            txusrclk_in(0)                        => txUsrClk,
            txusrclk2_in(0)                       => txUsrClk,
            drpdo_out                             => drpDo,
            drprdy_out(0)                         => drpRdy,
            gthtxn_out(0)                         => gtTxN,
            gthtxp_out(0)                         => gtTxP,
            rxbyteisaligned_out                   => open,
            rxbyterealign_out                     => open,
            rxcommadet_out                        => open,
            rxctrl0_out                           => rxCtrl0Out,
            rxctrl1_out                           => rxCtrl1Out,
            rxctrl2_out                           => open,
            rxctrl3_out                           => rxCtrl3Out,
            rxoutclk_out(0)                       => rxoutclk_out,
            rxpmaresetdone_out(0)                 => open,
            txoutclk_out(0)                       => txoutclk_out,
            txpmaresetdone_out(0)                 => open );

      rxDataK   <= rxCtrl0Out(1 downto 0);
      rxDispErr <= rxCtrl1Out(1 downto 0);
      rxDecErr  <= rxCtrl3Out(1 downto 0);

      TIMING_TXCLK_BUFG_GT : BUFG_GT
         port map (
            I       => txoutclk_out,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "001",           -- Divide-by-2
            O       => txoutclkb);

      TIMING_RECCLK_BUFG_GT : BUFG_GT
         port map (
            I       => rxoutclk_out,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide-by-1
            O       => rxoutclkb);
   end generate;

   U_RstSyncTx : entity work.RstSync
      generic map (TPD_G  => TPD_G)
      port map ( clk      => txoutclkb,
                 asyncRst => txControl.reset,
                 syncRst  => txbypassrst );

   U_RstSyncRx : entity work.RstSync
      generic map (TPD_G  => TPD_G)
      port map ( clk      => rxoutclkb,
                 asyncRst => rxRst,
                 syncRst  => rxbypassrst );

--   txRst    <= txControl.reset;
--   rxRst    <= rxControl.reset;
   
   txOutClk <= txoutclkb;
   rxOutClk <= rxoutclkb;
   
end architecture rtl;
