-------------------------------------------------------------------------------
-- File       : EvrMisc.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-09-20
-- Last update: 2017-12-06
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
      txDiffCtrl      : out slv(3 downto 0);
      txPreCursor     : out slv(4 downto 0);
      txPostCursor    : out slv(4 downto 0);
      loopback        : out slv(2 downto 0);
      userClk156      : in  sl;
      mmcmRst         : out sl;
      mmcmLocked      : in  slv(2 downto 0);
      refClk          : in  slv(2 downto 0);
      refRst          : in  slv(2 downto 0);
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
      mmcmRst        : sl;
      rxUserRst      : sl;
      txUserRst      : sl;
      txDiffCtrl     : slv(3 downto 0);
      txPreCursor    : slv(4 downto 0);
      txPostCursor   : slv(4 downto 0);
      loopback       : slv(2 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      mmcmRst        => '0',
      rxUserRst      => '0',
      txUserRst      => '0',
      txDiffCtrl     => "1000",
      txPreCursor    => "00000",
      txPostCursor   => "00000",
      loopback       => "100",          -- 100: Far-end PMA Loopback
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal userClk156Freq : slv(31 downto 0);
   signal refClkFreq     : Slv32Array(2 downto 0);

   signal txReset   : sl;
   signal txClkFreq : slv(31 downto 0);

   signal rxReset   : sl;
   signal rxClkFreq : slv(31 downto 0);

begin

   U_userClk156 : entity work.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         REF_CLK_FREQ_G => SYS_CLK_FREQ_C,
         REFRESH_RATE_G => 1.0,
         CNT_WIDTH_G    => 32)
      port map (
         -- Frequency Measurement (locClk domain)
         freqOut => userClk156Freq,
         -- Clocks
         clkIn   => userClk156,
         locClk  => sysClk,
         refClk  => sysClk);

   GEN_REFCLK_FREQ :
   for i in 2 downto 0 generate
      U_refClk : entity work.SyncClockFreq
         generic map (
            TPD_G          => TPD_G,
            REF_CLK_FREQ_G => SYS_CLK_FREQ_C,
            REFRESH_RATE_G => 1.0,
            CNT_WIDTH_G    => 32)
         port map (
            -- Frequency Measurement (locClk domain)
            freqOut => refClkFreq(i),
            -- Clocks
            clkIn   => refClk(i),
            locClk  => sysClk,
            refClk  => sysClk);
   end generate GEN_REFCLK_FREQ;

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
   comb : process (axilReadMaster, axilWriteMaster, mmcmLocked, r, refClkFreq,
                   refRst, rxClkFreq, rxReset, sysRst, txClkFreq, txReset,
                   userClk156Freq) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.rxUserRst := '0';
      v.txUserRst := '0';
      v.mmcmRst   := '0';

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister(regCon, x"00", 0, v.mmcmRst);
      axiSlaveRegisterR(regCon, x"04", 0, mmcmLocked);
      axiSlaveRegisterR(regCon, x"08", 0, refRst);

      axiSlaveRegister(regCon, x"10", 0, v.loopback);
      axiSlaveRegister(regCon, x"14", 0, v.rxUserRst);
      axiSlaveRegister(regCon, x"18", 0, v.txUserRst);
      axiSlaveRegister(regCon, x"1C", 0, v.txDiffCtrl);

      axiSlaveRegister(regCon, x"20", 0, v.txPreCursor);
      axiSlaveRegister(regCon, x"24", 0, v.txPostCursor);

      axiSlaveRegisterR(regCon, x"40", 0, txReset);
      axiSlaveRegisterR(regCon, x"44", 0, txClkFreq);
      axiSlaveRegisterR(regCon, x"48", 0, rxReset);
      axiSlaveRegisterR(regCon, x"4C", 0, rxClkFreq);

      axiSlaveRegisterR(regCon, x"50", 0, userClk156Freq);

      axiSlaveRegisterR(regCon, x"60", 0, refClkFreq(0));
      axiSlaveRegisterR(regCon, x"64", 0, refClkFreq(1));
      axiSlaveRegisterR(regCon, x"68", 0, refClkFreq(2));

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
      loopback       <= r.loopback;
      txDiffCtrl     <= r.txDiffCtrl;
      txPreCursor    <= r.txPreCursor;
      txPostCursor   <= r.txPostCursor;

   end process comb;

   seq : process (sysClk) is
   begin
      if (rising_edge(sysClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_mmcmRst : entity work.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 156000000)
      port map (
         arst   => r.mmcmRst,
         clk    => userClk156,
         rstOut => mmcmRst);

   U_rxUserRst : entity work.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 125000000)
      port map (
         arst   => r.rxUserRst,
         clk    => sysClk,
         rstOut => rxUserRst);

   U_txUserRst : entity work.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 125000000)
      port map (
         arst   => r.txUserRst,
         clk    => sysClk,
         rstOut => txUserRst);

end rtl;
