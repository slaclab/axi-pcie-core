-------------------------------------------------------------------------------
-- File       : AppPgp2bQuad.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-22
-- Last update: 2017-10-12
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
use work.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AppPgp2bQuad is
   generic (
      TPD_G             : time             := 1 ns;
      PGP_RX_ENABLE_G   : boolean          := true;
      PGP_TX_ENABLE_G   : boolean          := true;
      AXIS_CFG_G        : AxiStreamConfigType;
      AXIL_CLK_FREQ_G   : real             := 156.25e6;
      AXIL_BASE_ADDR_G  : slv(31 downto 0) := (others => '0');
      AXIL_ERROR_RESP_G : slv(1 downto 0)  := AXI_RESP_DECERR_C);
   port (
      -- Pgp Stream Interface
      pgpClk          : in  sl;
      pgpRst          : in  sl;
      pgpTxMasters    : in  AxiStreamMasterArray(3 downto 0);
      pgpTxSlaves     : out AxiStreamSlaveArray(3 downto 0);
      pgpTxIn         : in  Pgp2bTxInArray(3 downto 0) := (others => PGP2B_TX_IN_INIT_C);
      pgpTxOut        : out Pgp2bTxOutArray(3 downto 0);
      pgpRxMasters    : out AxiStreamMasterArray(3 downto 0);
      pgpRxSlaves     : in  AxiStreamSlaveArray(3 downto 0);
      pgpRxIn         : in  Pgp2bRxInArray(3 downto 0) := (others => PGP2B_RX_IN_INIT_C);
      pgpRxOut        : out Pgp2bRxOutArray(3 downto 0);
      -- AXI-Lite Interface 
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- PGP Interface
      stableClk       : in  sl;
      stableRst       : in  sl;
      gtRefClk        : in  sl;
      gtRxP           : in  slv(3 downto 0);
      gtRxN           : in  slv(3 downto 0);
      gtTxP           : out slv(3 downto 0);
      gtTxN           : out slv(3 downto 0));
end AppPgp2bQuad;

architecture mapping of AppPgp2bQuad is

   constant NUM_AXIL_MASTERS_C : natural := 4;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) :=
      genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 13, 12);

   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

begin


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

   GEN_VEC : for i in 3 downto 0 generate

      U_PGP : entity work.AppPgp2bLane
         generic map (
            TPD_G             => TPD_G,
            PGP_RX_ENABLE_G   => PGP_RX_ENABLE_G,
            PGP_TX_ENABLE_G   => PGP_TX_ENABLE_G,
            AXIS_CFG_G        => AXIS_CFG_G,
            AXIL_CLK_FREQ_G   => AXIL_CLK_FREQ_G,
            AXIL_BASE_ADDR_G  => XBAR_CONFIG_C(i).baseAddr,
            AXIL_ERROR_RESP_G => AXIL_ERROR_RESP_G)
         port map(
            -- PGP Stream
            pgpClk          => pgpClk,
            pgpRst          => pgpRst,
            pgpTxMaster     => pgpTxMasters(i),
            pgpTxSlave      => pgpTxSlaves(i),
            pgpTxIn         => pgpTxIn(i),
            pgpTxOut        => pgpTxOut(i),
            pgpRxMaster     => pgpRxMasters(i),
            pgpRxSlave      => pgpRxSlaves(i),
            pgpRxIn         => pgpRxIn(i),
            pgpRxOut        => pgpRxOut(i),
            -- AXI-Lite Interface            
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i),
            -- PGP Interface
            stableClk       => stableClk,
            stableRst       => stableRst,
            gtRefClk        => gtRefClk,
            gtRxP           => gtRxP(i),
            gtRxN           => gtRxN(i),
            gtTxP           => gtTxP(i),
            gtTxN           => gtTxN(i));

   end generate;

end mapping;
