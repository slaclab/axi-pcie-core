-------------------------------------------------------------------------------
-- File       : AppPgp2bTop.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-22
-- Last update: 2017-10-10
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AppPgp2bTop is
   generic (
      TPD_G             : time             := 1 ns;
      AXIL_CLK_FREQ_C   : real             := 156.25e6;
      AXIL_BASE_ADDR_G  : slv(31 downto 0) := (others => '0');
      AXIL_ERROR_RESP_G : slv(1 downto 0)  := AXI_RESP_DECERR_C);
   port (
      -- PGP CLock
      pgpClk          : in  sl;
      -- DMA Interface  
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaObMasters    : in  AxiStreamMasterArray(7 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      dmaObSlaves     : out AxiStreamSlaveArray(7 downto 0);
      dmaIbMasters    : out AxiStreamMasterArray(7 downto 0);
      dmaIbSlaves     : in  AxiStreamSlaveArray(7 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType            := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType           := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- QSFP[0] Ports
      qsfp0RefClkP    : in  slv(1 downto 0);
      qsfp0RefClkN    : in  slv(1 downto 0);
      qsfp0RxP        : in  slv(3 downto 0);
      qsfp0RxN        : in  slv(3 downto 0);
      qsfp0TxP        : out slv(3 downto 0);
      qsfp0TxN        : out slv(3 downto 0);
      -- QSFP[1] Ports
      qsfp1RefClkP    : in  slv(1 downto 0);
      qsfp1RefClkN    : in  slv(1 downto 0);
      qsfp1RxP        : in  slv(3 downto 0);
      qsfp1RxN        : in  slv(3 downto 0);
      qsfp1TxP        : out slv(3 downto 0);
      qsfp1TxN        : out slv(3 downto 0));
end AppPgp2bTop;

architecture mapping of AppPgp2bTop is

   constant NUM_AXIL_MASTERS_C : natural := 2;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 11, 10);

   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal pgpRst     : sl;
   signal dmaRstPipe : sl;
   signal gtRefClk   : slv(1 downto 0);

   attribute dont_touch                : string;
   attribute dont_touch of unusedGtClk : signal is "TRUE";


begin

   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => dmaClk,
         rstIn  => dmaRst,
         rstOut => dmaRstPipe);

   U_GtRefClk0 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfp0RefClkP(0),
         IB    => qsfp0RefClkN(0),
         CEB   => '0',
         ODIV2 => open,
         O     => gtRefClk(0));

   U_GtRefClk1 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfp1RefClkP(0),
         IB    => qsfp1RefClkN(0),
         CEB   => '0',
         ODIV2 => open,
         O     => gtRefClk(1));

   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1')
      port map (
         clk    => pgpClk,
         rstOut => pgpRst);

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         DEC_ERROR_RESP_G   => AXIL_ERROR_RESP_G,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   U_QSFP0 : entity work.AppPgp2bQuad
      generic map (
         TPD_G             => TPD_G,
         AXIL_CLK_FREQ_G   => AXIL_CLK_FREQ_G,
         AXIL_BASE_ADDR_G  => XBAR_CONFIG_C(0).baseAddr,
         AXIL_ERROR_RESP_G => AXIL_ERROR_RESP_G)
      port map (
         -- DMA Interface  (sysClk domain)
         dmaClk          => dmaClk,
         dmaRst          => dmaRst,
         dmaObMasters    => dmaObMasters(3 downto 0),
         dmaObSlaves     => dmaObSlaves(3 downto 0),
         dmaIbMasters    => dmaIbMasters(3 downto 0),
         dmaIbSlaves     => dmaIbSlaves(3 downto 0),
         -- AXI-Lite Interface (sysClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(0),
         axilReadSlave   => axilReadSlaves(0),
         axilWriteMaster => axilWriteMasters(0),
         axilWriteSlave  => axilWriteSlaves(0),
         -- PGP Interface
         pgpClk          => pgpClk,
         pgpRst          => pgpRst,
         gtRefClk        => gtRefClk(0),
         gtRxP           => qsfp0RxP,
         gtRxN           => qsfp0RxN,
         gtTxP           => qsfp0TxP,
         gtTxN           => qsfp0TxN);

   U_QSFP1 : entity work.AppPgp2bQuad
      generic map (
         TPD_G             => TPD_G,
         AXIL_CLK_FREQ_G   => AXIL_CLK_FREQ_G,
         AXIL_BASE_ADDR_G  => XBAR_CONFIG_C(1).baseAddr,
         AXIL_ERROR_RESP_G => AXIL_ERROR_RESP_G)
      port map (
         -- DMA Interface 
         dmaClk          => dmaClk,
         dmaRst          => dmaRst,
         dmaObMasters    => dmaObMasters(7 downto 4),
         dmaObSlaves     => dmaObSlaves(7 downto 4),
         dmaIbMasters    => dmaIbMasters(7 downto 4),
         dmaIbSlaves     => dmaIbSlaves(7 downto 4),
         -- AXI-Lite Interface 
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(1),
         axilReadSlave   => axilReadSlaves(1),
         axilWriteMaster => axilWriteMasters(1),
         axilWriteSlave  => axilWriteSlaves(1),
         -- PGP Interface
         pgpClk          => pgpClk,
         pgpRst          => pgpRst,
         gtRefClk        => gtRefClk(1),
         gtRxP           => qsfp1RxP,
         gtRxN           => qsfp1RxN,
         gtTxP           => qsfp1TxP,
         gtTxN           => qsfp1TxN);

end mapping;
