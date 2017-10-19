-------------------------------------------------------------------------------
-- File       : EvrPipeline.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-04
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

use work.StdRtlPkg.all;
use work.TimingPkg.all;

entity EvrPipeline is
   generic (
      TPD_G         : time     := 1 ns;
      PIPE_STAGES_G : positive := 2;
      MAX_FANOUT_G  : positive := 16384);
   port (
      evrClk : in  sl;
      evrIn  : in  TimingBusType;
      evrOut : out TimingBusType);
end EvrPipeline;

architecture rtl of EvrPipeline is

   type RegType is record
      shift : TimingBusArray(PIPE_STAGES_G-1 downto 0);
   end record RegType;
   constant REG_INIT_C : RegType := (
      shift => (others => TIMING_BUS_INIT_C));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute shreg_extract      : string;
   attribute shreg_extract of r : signal is "NO";

   attribute max_fanout      : integer;
   attribute max_fanout of r : signal is MAX_FANOUT_G;

begin

   comb : process (evrIn, r) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Shift the LSB
      v.shift(0) := evrIn;

      -- Check for multi-stage delay
      if (PIPE_STAGES_G > 1) then
         -- Shift old data
         v.shift(PIPE_STAGES_G-1 downto 1) := r.shift(PIPE_STAGES_G-2 downto 0);
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs        
      evrOut <= r.shift(PIPE_STAGES_G-1);

   end process comb;

   seq : process (evrClk) is
   begin
      if rising_edge(evrClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
