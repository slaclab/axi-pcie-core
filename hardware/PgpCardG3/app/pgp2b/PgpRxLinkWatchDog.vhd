-------------------------------------------------------------------------------
-- File       : PgpRxLinkWatchDog.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-07
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.Pgp2bPkg.all;

entity PgpRxLinkWatchDog is
   generic (
      TPD_G : time := 1 ns);
   port (
      stableClk   : in  sl;
      phyRxReady  : in  sl;
      pgpRxOut    : in  Pgp2bRxOutType;
      pgpRxRstIn  : in  sl;
      pgpRxRstOut : out sl);
end PgpRxLinkWatchDog;

architecture rtl of PgpRxLinkWatchDog is

   type StateType is (
      IDLE_S,
      RST_S);

   type RegType is record
      linkDown : sl;
      state    : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      linkDown => '0',
      state    => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal monitor : sl;
   signal wdtRst  : sl;
   signal reset   : sl;

begin

   Synchronizer_linkReady : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => stableClk,
         -- dataIn  => pgpRxOut.linkReady,
         dataIn  => phyRxReady,
         dataOut => monitor);

   WatchDogRst_Inst : entity work.WatchDogRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(125.0E+6, 0.2))  -- 5 s timeout
      port map (
         clk    => stableClk,
         monIn  => monitor,
         rstOut => wdtRst);

   PwrUpRst_Inst : entity work.PwrUpRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(125.0E+6, 10.0))  -- 100 ms reset
      port map (
         arst   => wdtRst,
         clk    => stableClk,
         rstOut => reset);

   pgpRxRstOut <= pgpRxRstIn or reset;

end rtl;
