-------------------------------------------------------------------------------
-- File       : EvrOpCodeDelay.vhd
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;

entity EvrOpCodeDelay is
   generic (
      TPD_G : time := 1 ns); 
   port (
      evrClk      : in  sl;
      evrRst      : in  sl;
      delayConfig : in  slv(31 downto 0);
      din         : in  slv(64 downto 0);
      dout        : out slv(64 downto 0));
end EvrOpCodeDelay;

architecture rtl of EvrOpCodeDelay is

   type StateType is (
      IDLE_S,
      TIMER_S);

   type RegType is record
      dout  : slv(64 downto 0);
      cnt   : slv(31 downto 0);
      size  : slv(31 downto 0);
      state : StateType;
   end record RegType;
   
   constant REG_INIT_C : RegType := (
      dout  => (others => '0'),
      cnt   => (others => '0'),
      size  => (others => '0'),
      state => IDLE_S);      

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;
   
  attribute use_dsp48      : string;
  attribute use_dsp48 of r : signal is "yes";    

begin

   comb : process (delayConfig, din, evrRst, r) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobing signals
      v.dout(64) := '0';

      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Check for OP-Code detection
            if din(64) = '1' then
               -- Latch the size 
               v.size              := delayConfig;
               -- Latch the input value
               v.dout(63 downto 0) := din(63 downto 0);
               -- Next state
               v.state             := TIMER_S;
            end if;
         ----------------------------------------------------------------------
         when TIMER_S =>
            -- Increment the timer
            v.cnt := r.cnt + 1;
            -- Check for OP-Code detection
            if r.cnt = r.size then
               -- Reset the timer
               v.cnt      := (others => '0');
               -- Output the delayed OP-Code detection
               v.dout(64) := '1';
               -- Next state
               v.state    := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Reset
      if (evrRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      dout <= r.dout;
      
   end process comb;

   seq : process (evrClk) is
   begin
      if rising_edge(evrClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
