-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Package for XilinxAlveoV80CpmManager (Versal CPM5 management block).
--
-- Defines the CPM5 BDF (Bus/Device/Function) address-translation table entry
-- type and helpers that flatten a table of entries into the ordered
-- address/data word pairs CpmManager writes over the S_AXI_LPD slave.
--
-- Each BDF table entry is six 32-bit words, written in this order (offsets from
-- the entry base, e.g. CPM5_DMA1 BDF table base 0xFCEA2420):
--   +0x00  address translation low   (32 bit)
--   +0x04  address translation high  (32 bit)
--   +0x08  reserved (always 0)
--   +0x0C  function number           (bits 11:0; upper bits reserved 0)
--   +0x10  permissions / size        (bit31=read, bit30=write, bits25:0=size
--                                      in multiples of 4 KiB; bits29:26 reserved)
--   +0x14  reserved (always 0)
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;

package XilinxAlveoV80CpmManagerPkg is

   -- Number of 32-bit words per BDF table entry
   constant CPM_BDF_WORDS_PER_ENTRY_C : positive := 6;

   -- One CPM5 BDF address-translation table entry
   type CpmBdfEntryType is record
      addrTransLow  : slv(31 downto 0);  -- +0x00 address translation low
      addrTransHigh : slv(31 downto 0);  -- +0x04 address translation high
      funcNum       : slv(11 downto 0);  -- +0x0C function number (bits 11:0)
      rdPerm        : sl;                -- +0x10 bit31 read permission
      wrPerm        : sl;                -- +0x10 bit30 write permission
      size          : slv(25 downto 0);  -- +0x10 bits25:0 size in 4 KiB pages
   end record CpmBdfEntryType;

   type CpmBdfEntryArray is array (natural range <>) of CpmBdfEntryType;

   -- Default entry: identity (no address translation), function 0, read+write
   -- enabled, 128 GiB aperture (128 GiB / 4 KiB = 2**25 pages). This reproduces
   -- the reference programming sequence word +0x10 = 0xC2000000.
   constant CPM_BDF_ENTRY_INIT_C : CpmBdfEntryType := (
      addrTransLow  => (others => '0'),
      addrTransHigh => (others => '0'),
      funcNum       => (others => '0'),
      rdPerm        => '1',
      wrPerm        => '1',
      size          => toSlv(2**25, 26));

   -- Flatten a BDF table into the ordered list of register addresses to write.
   function genBdfAddr (baseAddr : slv(31 downto 0); table : CpmBdfEntryArray) return Slv32Array;

   -- Flatten a BDF table into the ordered list of 32-bit data words to write.
   function genBdfData (table : CpmBdfEntryArray) return Slv32Array;

end package XilinxAlveoV80CpmManagerPkg;

package body XilinxAlveoV80CpmManagerPkg is

   function genBdfAddr (baseAddr : slv(31 downto 0); table : CpmBdfEntryArray) return Slv32Array is
      variable retVar : Slv32Array(0 to CPM_BDF_WORDS_PER_ENTRY_C*table'length-1);
      variable idx    : natural;
   begin
      for k in table'range loop
         idx := CPM_BDF_WORDS_PER_ENTRY_C*(k - table'low);
         for w in 0 to CPM_BDF_WORDS_PER_ENTRY_C-1 loop
            retVar(idx+w) := baseAddr + toSlv((k - table'low)*(4*CPM_BDF_WORDS_PER_ENTRY_C) + 4*w, 32);
         end loop;
      end loop;
      return retVar;
   end function genBdfAddr;

   function genBdfData (table : CpmBdfEntryArray) return Slv32Array is
      variable retVar : Slv32Array(0 to CPM_BDF_WORDS_PER_ENTRY_C*table'length-1);
      variable idx    : natural;
      variable entry  : CpmBdfEntryType;
      variable word3  : slv(31 downto 0);
      variable word4  : slv(31 downto 0);
   begin
      for k in table'range loop
         idx   := CPM_BDF_WORDS_PER_ENTRY_C*(k - table'low);
         entry := table(k);

         -- +0x0C function number (lower 12 bits, upper bits reserved 0)
         word3               := (others => '0');
         word3(11 downto 0)  := entry.funcNum;

         -- +0x10 permissions + size
         word4               := (others => '0');
         word4(31)           := entry.rdPerm;
         word4(30)           := entry.wrPerm;
         word4(25 downto 0)  := entry.size;

         retVar(idx+0) := entry.addrTransLow;   -- +0x00
         retVar(idx+1) := entry.addrTransHigh;  -- +0x04
         retVar(idx+2) := (others => '0');      -- +0x08 reserved
         retVar(idx+3) := word3;                -- +0x0C
         retVar(idx+4) := word4;                -- +0x10
         retVar(idx+5) := (others => '0');      -- +0x14 reserved
      end loop;
      return retVar;
   end function genBdfData;

end package body XilinxAlveoV80CpmManagerPkg;
