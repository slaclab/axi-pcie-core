-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation-only stand-in for surf.ClockManagerUltraScale
--
-- The real wrapper instantiates UNISIM primitives, which GHDL cannot simulate.
-- The GHDL regression manifest (top-level ruckus.tcl) compiles this model into
-- the surf library in its place. It only implements what HbmDmaBufferV2 uses:
-- CLKOUT0 of an MMCM with fractional feedback multiplier and output divider.
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

library surf;
use surf.StdRtlPkg.all;

entity ClockManagerUltraScale is
   generic (
      TPD_G              : time                    := 1 ns;
      TYPE_G             : string                  := "MMCM";
      INPUT_BUFG_G       : boolean                 := true;
      FB_BUFG_G          : boolean                 := true;
      RST_IN_POLARITY_G  : sl                      := '1';
      NUM_CLOCKS_G       : integer range 1 to 7;
      CLKIN_PERIOD_G     : real                    := 10.0;  -- Units of ns
      CLKFBOUT_MULT_F_G  : real range 1.0 to 64.0  := 1.0;
      CLKOUT0_DIVIDE_F_G : real range 1.0 to 128.0 := 1.0);
   port (
      clkIn  : in  sl;
      rstIn  : in  sl := '0';
      clkOut : out slv(NUM_CLOCKS_G-1 downto 0);
      rstOut : out slv(NUM_CLOCKS_G-1 downto 0));
end entity ClockManagerUltraScale;

architecture sim of ClockManagerUltraScale is

   constant HALF_PERIOD_C : time := (CLKIN_PERIOD_G * CLKOUT0_DIVIDE_F_G / CLKFBOUT_MULT_F_G / 2.0) * 1 ns;

   signal clk : sl := '0';
   signal rst : sl := '1';

begin

   assert (NUM_CLOCKS_G = 1)
      report "ClockManagerUltraScaleSim: only CLKOUT0 is modeled" severity failure;

   clk <= not clk after HALF_PERIOD_C;

   -- Hold the output reset for a few cycles after the input reset releases
   process (clk) is
      variable cnt : natural range 0 to 15 := 0;
   begin
      if rising_edge(clk) then
         if (rstIn = RST_IN_POLARITY_G) then
            cnt := 0;
            rst <= '1' after TPD_G;
         elsif (cnt = 15) then
            rst <= '0' after TPD_G;
         else
            cnt := cnt + 1;
         end if;
      end if;
   end process;

   clkOut(0) <= clk;
   rstOut(0) <= rst;

end architecture sim;
