-------------------------------------------------------------------------------
-- File       : EvrMisc.vhd
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPciePkg.all;

entity EvrMisc is
   generic (
      TPD_G            : time            := 1 ns;
      DEFAULT_TIMING_G : boolean         := true;  -- false = LCLS-I, true = LCLS-II
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C);
   port (
      rxUserRst       : out sl;
      txUserRst       : out sl;
      loopback        : out slv(2 downto 0);
      evrMuxSel       : out slv(1 downto 0);
      qPllRxSelect    : out slv(1 downto 0);
      qPllTxSelect    : out slv(1 downto 0);
      qPllReset       : out slv(1 downto 0);
      gtQPllLock      : in  slv(1 downto 0);
      refClkDiv2      : in  slv(1 downto 0);
      txClk           : in  sl;
      txRst           : in  sl;
      rxClk           : in  sl;
      rxRst           : in  sl;
      -- AXI-Lite Register Interface (sysClk domain)
      sysClk          : in  sl;
      sysRst          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end EvrMisc;

architecture rtl of EvrMisc is

   type RegType is record
      rxUserRst      : sl;
      txUserRst      : sl;
      loopback       : slv(2 downto 0);
      evrMuxSel      : slv(1 downto 0);
      qPllRxSelect   : slv(1 downto 0);
      qPllTxSelect   : slv(1 downto 0);
      qPllReset      : slv(1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rxUserRst      => '0',
      txUserRst      => '0',
      loopback       => (others => '0'),
      evrMuxSel      => (others => '0'),
      qPllRxSelect   => ite(DEFAULT_TIMING_G, "11", "00"),
      qPllTxSelect   => ite(DEFAULT_TIMING_G, "11", "00"),
      qPllReset      => (others => '0'),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal qPllLock   : slv(1 downto 0);
   signal refClkFreq : Slv32Array(1 downto 0);

   signal txReset   : sl;
   signal txClkFreq : slv(31 downto 0);

   signal rxReset   : sl;
   signal rxClkFreq : slv(31 downto 0);

begin

   -- GEN_VEC :
   -- for i in 1 downto 0 generate

   -- U_refClkFreq : entity work.SyncClockFreq
   -- generic map (
   -- TPD_G          => TPD_G,
   -- USE_DSP48_G    => "yes",
   -- REF_CLK_FREQ_G => SYS_CLK_FREQ_C,
   -- REFRESH_RATE_G => 1.0,
   -- CNT_WIDTH_G    => 32)
   -- port map (
   -- -- Frequency Measurement (locClk domain)
   -- freqOut => refClkFreq(i),
   -- -- Clocks
   -- clkIn   => refClkDiv2(i),
   -- locClk  => sysClk,
   -- refClk  => sysClk);

   -- end generate GEN_VEC;

   Sync_qPllLock : entity work.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk     => sysClk,
         dataIn  => gtQPllLock,
         dataOut => qPllLock);

   Sync_txRst : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => sysClk,
         dataIn  => txRst,
         dataOut => txReset);

   U_txClkFreq : entity work.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         USE_DSP48_G    => "yes",
         REF_CLK_FREQ_G => SYS_CLK_FREQ_C,
         REFRESH_RATE_G => 1.0,
         CNT_WIDTH_G    => 32)
      port map (
         -- Frequency Measurement (locClk domain)
         freqOut => txClkFreq,
         -- Clocks
         clkIn   => txClk,
         locClk  => sysClk,
         refClk  => sysClk);

   Sync_rxRst : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => sysClk,
         dataIn  => rxRst,
         dataOut => rxReset);

   U_rxClkFreq : entity work.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         USE_DSP48_G    => "yes",
         REF_CLK_FREQ_G => SYS_CLK_FREQ_C,
         REFRESH_RATE_G => 1.0,
         CNT_WIDTH_G    => 32)
      port map (
         -- Frequency Measurement (locClk domain)
         freqOut => rxClkFreq,
         -- Clocks
         clkIn   => rxClk,
         locClk  => sysClk,
         refClk  => sysClk);

   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilWriteMaster, qPllLock, r, rxClkFreq,
                   rxReset, sysRst, txClkFreq, txReset) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.qPllReset := "00";
      v.rxUserRst := '0';
      v.txUserRst := '0';

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister(regCon, x"00", 0, v.evrMuxSel);
      axiSlaveRegister(regCon, x"04", 0, v.qPllRxSelect);
      axiSlaveRegister(regCon, x"08", 0, v.qPllTxSelect);
      axiSlaveRegister(regCon, x"0C", 0, v.qPllReset);

      axiSlaveRegister(regCon, x"10", 0, v.loopback);
      axiSlaveRegister(regCon, x"14", 0, v.rxUserRst);
      axiSlaveRegister(regCon, x"18", 0, v.txUserRst);

      axiSlaveRegisterR(regCon, x"40", 0, txReset);
      axiSlaveRegisterR(regCon, x"44", 0, txClkFreq);
      axiSlaveRegisterR(regCon, x"48", 0, rxReset);
      axiSlaveRegisterR(regCon, x"4C", 0, rxClkFreq);

      -- axiSlaveRegisterR(regCon, x"50", 0, refClkFreq(0));
      -- axiSlaveRegisterR(regCon, x"54", 0, refClkFreq(1));
      axiSlaveRegisterR(regCon, x"58", 0, qPllLock);

      -- Closeout the transaction
      axiSlaveDefault(regCon, v.axilWriteSlave, v.axilReadSlave, AXI_ERROR_RESP_G);

      -- Synchronous Reset
      if (sysRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      evrMuxSel      <= r.evrMuxSel;
      qPllRxSelect   <= r.qPllRxSelect;
      qPllTxSelect   <= r.qPllTxSelect;
      loopback       <= r.loopback;

   end process comb;

   seq : process (sysClk) is
   begin
      if (rising_edge(sysClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   GEN_QPLL_RST :
   for i in 1 downto 0 generate
      U_PwrUpRst : entity work.PwrUpRst
         generic map (
            TPD_G       => TPD_G,
            USE_DSP48_G => "yes",
            DURATION_G  => 125000000)
         port map (
            arst   => r.qPllReset(i),
            clk    => sysClk,
            rstOut => qPllReset(i));
   end generate GEN_QPLL_RST;

   U_rxUserRst : entity work.PwrUpRst
      generic map (
         TPD_G       => TPD_G,
         USE_DSP48_G => "yes",
         DURATION_G  => 125000000)
      port map (
         arst   => r.rxUserRst,
         clk    => sysClk,
         rstOut => rxUserRst);

   U_txUserRst : entity work.PwrUpRst
      generic map (
         TPD_G       => TPD_G,
         USE_DSP48_G => "yes",
         DURATION_G  => 125000000)
      port map (
         arst   => r.txUserRst,
         clk    => sysClk,
         rstOut => txUserRst);

end rtl;
