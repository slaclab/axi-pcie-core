-------------------------------------------------------------------------------
-- File       : PgpLane.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-07
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPciePkg.all;
use work.AppPkg.all;
use work.Pgp2bPkg.all;
use work.TimingPkg.all;

library unisim;
use unisim.vcomponents.all;

entity PgpLane is
   generic (
      TPD_G            : time                  := 1 ns;
      ENABLE_G         : boolean               := true;
      LANE_G           : positive range 0 to 7 := 0;
      AXI_ERROR_RESP_G : slv(1 downto 0)       := AXI_RESP_DECERR_C;
      AXI_BASE_ADDR_G  : slv(31 downto 0)      := (others => '0'));
   port (
      -- QPLL Clocking
      gtQPllOutRefClk  : in  slv(1 downto 0);
      gtQPllOutClk     : in  slv(1 downto 0);
      gtQPllLock       : in  slv(1 downto 0);
      gtQPllRefClkLost : in  slv(1 downto 0);
      gtQPllReset      : out slv(1 downto 0);
      -- PGP Serial Ports
      pgpTxP           : out sl;
      pgpTxN           : out sl;
      pgpRxP           : in  sl;
      pgpRxN           : in  sl;
      -- DMA Interface (sysClk domain)
      dmaObMaster      : in  AxiStreamMasterType;
      dmaObSlave       : out AxiStreamSlaveType;
      dmaIbMaster      : out AxiStreamMasterType;
      dmaIbSlave       : in  AxiStreamSlaveType;
      -- Timing Interface (evrClk domain)
      evrClk           : in  sl;
      evrRst           : in  sl;
      evrTimingBus     : in  TimingBusType;
      -- AXI-Lite Interface (sysClk domain)
      sysClk           : in  sl;
      sysRst           : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType);
end PgpLane;

architecture mapping of PgpLane is

   constant NUM_AXI_MASTERS_C : natural := 3;

   constant GT_INDEX_C   : natural := 0;
   constant MON_INDEX_C  : natural := 1;
   constant CTRL_INDEX_C : natural := 2;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 16, 12);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

   signal locTxIn  : Pgp2bTxInType;
   signal pgpTxIn  : Pgp2bTxInType;
   signal pgpTxOut : Pgp2bTxOutType;

   signal pgpRxIn  : Pgp2bRxInType;
   signal pgpRxOut : Pgp2bRxOutType;

   signal pgpTxMasters : AxiStreamMasterArray(3 downto 0);
   signal pgpTxSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal pgpRxMasters : AxiStreamMasterArray(3 downto 0);
   signal pgpRxCtrl    : AxiStreamCtrlArray(3 downto 0);

   signal gtQPllRst    : slv(1 downto 0);
   signal gtQPllLocked : slv(1 downto 0);
   signal lockedStrobe : slv(1 downto 0);

   signal pgpTxRecClk : sl;
   signal pgpTxClk    : sl;
   signal pgpTxRst    : sl;

   signal pgpRxClk : sl;
   signal pgpRxRst : sl;

   signal status : StatusType;
   signal config : ConfigType;

begin

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

   ----------------------------------------------------------------------------
   -- Prevent the gtQPllRst of this lane disrupting the other lanes in the QUAD
   ----------------------------------------------------------------------------
   GEN_VEC :
   for i in 1 downto 0 generate

      U_PwrUpRst : entity work.PwrUpRst
         generic map (
            TPD_G      => TPD_G,
            DURATION_G => 12500)        -- 100 us pulse
         port map (
            arst   => gtQPllRst(i),
            clk    => sysClk,
            rstOut => lockedStrobe(i));

      gtQPllReset(i)  <= gtQPllRst(i) and not (gtQPllLock(i));
      gtQPllLocked(i) <= gtQPllLock(i) and not(lockedStrobe(i));

   end generate GEN_VEC;

   -----------
   -- PGP Core
   -----------
   U_Pgp : entity work.Pgp2bGtp7DrpWrapper
      -- U_Pgp : entity work.Pgp2bGtp7MultiLane
      generic map (
         TPD_G            => TPD_G,
         VC_INTERLEAVE_G  => 1,         -- AxiStreamDmaV2 supports interleaving
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- GT Clocking
         gtQPllOutRefClk     => gtQPllOutRefClk,
         gtQPllOutClk        => gtQPllOutClk,
         gtQPllLock          => gtQPllLocked,
         gtQPllRefClkLost    => gtQPllRefClkLost,
         gtQPllReset         => gtQPllRst,
         qPllRxSelect        => config.qPllRxSelect,
         qPllTxSelect        => config.qPllTxSelect,
         drpOverride         => config.gtDrpOverride,
         -- Gt Serial IO
         gtTxP(0)            => pgpTxP,
         gtTxN(0)            => pgpTxN,
         gtRxP(0)            => pgpRxP,
         gtRxN(0)            => pgpRxN,
         -- Tx Clocking
         pgpTxReset          => pgpTxRst,
         pgpTxClk            => pgpTxClk,
         -- Rx clocking
         pgpRxReset          => pgpRxRst,
         pgpRxClk            => pgpRxClk,
         -- Non VC Rx Signals
         pgpRxIn             => pgpRxIn,
         pgpRxOut            => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn             => pgpTxIn,
         pgpTxOut            => pgpTxOut,
         -- Frame Transmit Interface
         pgpTxMasters        => pgpTxMasters,
         pgpTxSlaves         => pgpTxSlaves,
         -- Frame Receive Interface
         pgpRxMasters        => pgpRxMasters,
         pgpRxCtrl           => pgpRxCtrl,
         -- Debug Interface 
         txPreCursor         => config.txPreCursor,
         txPostCursor        => config.txPostCursor,
         txDiffCtrl          => config.txDiffCtrl,
         -- AXI-Lite Interface 
         axilClk             => sysClk,
         axilRst             => sysRst,
         axilReadMasters(0)  => axilReadMasters(GT_INDEX_C),
         axilReadSlaves(0)   => axilReadSlaves(GT_INDEX_C),
         axilWriteMasters(0) => axilWriteMasters(GT_INDEX_C),
         axilWriteSlaves(0)  => axilWriteSlaves(GT_INDEX_C));

   --------------         
   -- PGP Monitor
   --------------         
   U_PgpMon : entity work.Pgp2bAxi
      generic map (
         TPD_G              => TPD_G,
         AXI_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         COMMON_TX_CLK_G    => false,
         COMMON_RX_CLK_G    => false,
         WRITE_EN_G         => true,
         AXI_CLK_FREQ_G     => SYS_CLK_FREQ_C,
         STATUS_CNT_WIDTH_G => 16,
         ERROR_CNT_WIDTH_G  => 16)
      port map (
         -- TX PGP Interface (pgpTxClk)
         pgpTxClk        => pgpTxClk,
         pgpTxClkRst     => pgpTxRst,
         pgpTxIn         => pgpTxIn,
         pgpTxOut        => pgpTxOut,
         locTxIn         => locTxIn,
         -- RX PGP Interface (pgpRxClk)
         pgpRxClk        => pgpRxClk,
         pgpRxClkRst     => pgpRxRst,
         pgpRxIn         => pgpRxIn,
         pgpRxOut        => pgpRxOut,
         -- AXI-Lite Register Interface (axilClk domain)
         axilClk         => sysClk,
         axilRst         => sysRst,
         axilReadMaster  => axilReadMasters(MON_INDEX_C),
         axilReadSlave   => axilReadSlaves(MON_INDEX_C),
         axilWriteMaster => axilWriteMasters(MON_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(MON_INDEX_C));
   ------------
   -- Misc Core
   ------------
   U_PgpMiscCtrl : entity work.PgpMiscCtrl
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- Control/Status  (sysClk domain)
         status          => status,
         config          => config,
         txUserRst       => pgpTxRst,
         rxUserRst       => pgpRxRst,
         -- AXI Lite interface
         sysClk          => sysClk,
         sysRst          => sysRst,
         axilReadMaster  => axilReadMasters(CTRL_INDEX_C),
         axilReadSlave   => axilReadSlaves(CTRL_INDEX_C),
         axilWriteMaster => axilWriteMasters(CTRL_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(CTRL_INDEX_C));



   BUILD_FIFO : if (ENABLE_G = true) generate
      ---------
      -- PGP TX
      ---------
      U_Tx : entity work.PgpLaneTx
         generic map (
            TPD_G => TPD_G)
         port map (
            -- DMA Interface (sysClk domain)
            sysClk       => sysClk,
            sysRst       => sysRst,
            dmaObMaster  => dmaObMaster,
            dmaObSlave   => dmaObSlave,
            -- PGP Interface
            pgpTxClk     => pgpTxClk,
            pgpTxRst     => pgpTxRst,
            pgpTxMasters => pgpTxMasters,
            pgpTxSlaves  => pgpTxSlaves);

      ---------
      -- PGP RX
      ---------
      U_Rx : entity work.PgpLaneRx
         generic map (
            TPD_G  => TPD_G,
            LANE_G => LANE_G)
         port map (
            -- DMA Interface (sysClk domain)
            sysClk       => sysClk,
            sysRst       => sysRst,
            dmaIbMaster  => dmaIbMaster,
            dmaIbSlave   => dmaIbSlave,
            -- Control/Status  (sysClk domain)
            config       => config,
            status       => status,
            -- Timing Interface (evrClk domain)
            evrClk       => evrClk,
            evrRst       => evrRst,
            evrTimingBus => evrTimingBus,
            -- PGP Trigger Interface (pgpTxClk domain)
            pgpTxClk     => pgpTxClk,
            pgpTxRst     => pgpTxRst,
            pgpTxIn      => locTxIn,
            -- PGP RX Interface (pgpRxClk domain)
            pgpRxClk     => pgpRxClk,
            pgpRxRst     => pgpRxRst,
            pgpRxMasters => pgpRxMasters,
            pgpRxCtrl    => pgpRxCtrl);

   end generate;

   BYPASS_FIFO : if (ENABLE_G = false) generate
      -- PGP TX
      dmaObSlave   <= AXI_STREAM_SLAVE_FORCE_C;
      pgpTxMasters <= (others => AXI_STREAM_MASTER_INIT_C);
      -- PGP RX
      dmaIbMaster  <= AXI_STREAM_MASTER_INIT_C;
      status       <= STATUS_INIT_C;
      locTxIn      <= PGP2B_TX_IN_INIT_C;
      pgpRxCtrl    <= (others => AXI_STREAM_CTRL_UNUSED_C);
   end generate;

end mapping;
