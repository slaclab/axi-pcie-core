-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: TerminateQsfp File
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity TerminateQsfp is
   generic (
      TPD_G           : time    := 1 ns;
      SIMULATION_G    : boolean := false;
      AXIL_CLK_FREQ_G : real    := 125.0E+6;  -- units of Hz
      QSFP_HIGH_G     : integer := 31;
      QSFP_LOW_G      : integer := 0;
      REFCLK_HIGH_G   : integer := 7;
      REFCLK_LOW_G    : integer := 0);
   port (
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      ---------------------
      --  Application Ports
      ---------------------
      -- QSFP[31:0] Ports
      qsfpRefClkP     : in  slv(REFCLK_HIGH_G downto REFCLK_LOW_G);
      qsfpRefClkN     : in  slv(REFCLK_HIGH_G downto REFCLK_LOW_G);
      qsfpRxP         : in  slv(QSFP_HIGH_G downto QSFP_LOW_G);
      qsfpRxN         : in  slv(QSFP_HIGH_G downto QSFP_LOW_G);
      qsfpTxP         : out slv(QSFP_HIGH_G downto QSFP_LOW_G);
      qsfpTxN         : out slv(QSFP_HIGH_G downto QSFP_LOW_G));
end TerminateQsfp;

architecture mapping of TerminateQsfp is

   type RegType is record
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;
   constant REG_INIT_C : RegType := (
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal refClk     : slv(REFCLK_HIGH_G downto REFCLK_LOW_G) := (others => '0');
   signal refClkBufg : slv(REFCLK_HIGH_G downto REFCLK_LOW_G) := (others => '0');

   signal refClkFreq : Slv32Array(7 downto 0) := (others => (others => '0'));

begin

   U_QSFP : entity surf.Gtye4ChannelDummy
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         WIDTH_G      => (QSFP_HIGH_G-QSFP_LOW_G)+1)
      port map (
         refClk => axilClk,
         gtRxP  => qsfpRxP,
         gtRxN  => qsfpRxN,
         gtTxP  => qsfpTxP,
         gtTxN  => qsfpTxN);

   GEN_VEC : for i in REFCLK_HIGH_G downto REFCLK_LOW_G generate

      U_IBUFDS : IBUFDS_GTE4
         generic map (
            REFCLK_EN_TX_PATH  => '0',
            REFCLK_HROW_CK_SEL => "00",  -- 2'b00: ODIV2 = O
            REFCLK_ICNTL_RX    => "00")
         port map (
            I     => qsfpRefClkP(i),
            IB    => qsfpRefClkN(i),
            CEB   => '0',
            ODIV2 => refClk(i),
            O     => open);

      U_BUFG : BUFG_GT
         port map (
            I       => refClk(i),
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide-by-1
            O       => refClkBufg(i));

      U_appClkFreq : entity surf.SyncClockFreq
         generic map (
            TPD_G          => TPD_G,
            REF_CLK_FREQ_G => AXIL_CLK_FREQ_G,
            REFRESH_RATE_G => 1.0,
            CNT_WIDTH_G    => 32)
         port map (
            -- Frequency Measurement (locClk domain)
            freqOut => refClkFreq(i),
            -- Clocks
            clkIn   => refClkBufg(i),
            locClk  => axilClk,
            refClk  => axilClk);

   end generate GEN_VEC;

   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, refClkFreq) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegisterR(axilEp, x"00", 0, refClkFreq(0));
      axiSlaveRegisterR(axilEp, x"04", 0, refClkFreq(1));
      axiSlaveRegisterR(axilEp, x"08", 0, refClkFreq(2));
      axiSlaveRegisterR(axilEp, x"0C", 0, refClkFreq(3));
      axiSlaveRegisterR(axilEp, x"10", 0, refClkFreq(4));
      axiSlaveRegisterR(axilEp, x"14", 0, refClkFreq(5));
      axiSlaveRegisterR(axilEp, x"18", 0, refClkFreq(6));
      axiSlaveRegisterR(axilEp, x"1C", 0, refClkFreq(7));

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;

      -- Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if rising_edge(axilClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
