-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: TerminateQsfp File
-------------------------------------------------------------------------------
-- This file is part of 'PGP PCIe APP DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'PGP PCIe APP DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity TerminateQsfp is
   generic (
      TPD_G : time := 1 ns);
   port (
      axilClk      : in  sl;
      axilRst      : in  sl;
      ---------------------
      --  Application Ports
      ---------------------
      -- QSFP[0] Ports
      qsfp0RefClkP : in  sl;
      qsfp0RefClkN : in  sl;
      qsfp0RxP     : in  slv(3 downto 0);
      qsfp0RxN     : in  slv(3 downto 0);
      qsfp0TxP     : out slv(3 downto 0);
      qsfp0TxN     : out slv(3 downto 0);
      -- QSFP[1] Ports
      qsfp1RefClkP : in  sl;
      qsfp1RefClkN : in  sl;
      qsfp1RxP     : in  slv(3 downto 0);
      qsfp1RxN     : in  slv(3 downto 0);
      qsfp1TxP     : out slv(3 downto 0);
      qsfp1TxN     : out slv(3 downto 0));
end TerminateQsfp;

architecture mapping of TerminateQsfp is

   signal unusedGtClk : slv(1 downto 0);

   attribute dont_touch                : string;
   attribute dont_touch of unusedGtClk : signal is "TRUE";

begin

   -- Unused QSFP Port
   U_QSFP0 : entity surf.Gthe3ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => axilClk,
         gtRxP  => qsfp0RxP,
         gtRxN  => qsfp0RxN,
         gtTxP  => qsfp0TxP,
         gtTxN  => qsfp0TxN);

   -- Unused QSFP Port
   U_QSFP1 : entity surf.Gthe3ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => axilClk,
         gtRxP  => qsfp1RxP,
         gtRxN  => qsfp1RxN,
         gtTxP  => qsfp1TxP,
         gtTxN  => qsfp1TxN);


   U_unusedGtClk0 : IBUFDS_GTE3
      port map (
         I     => qsfp0RefClkP,
         IB    => qsfp0RefClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => unusedGtClk(0));

   U_unusedGtClk1 : IBUFDS_GTE3
      port map (
         I     => qsfp1RefClkP,
         IB    => qsfp1RefClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => unusedGtClk(1));

end mapping;
