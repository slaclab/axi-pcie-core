-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Package for XilinxAlveoV80CpmManager (Versal CPM5 management block).
--
-- XilinxAlveoV80CpmManager is payload-agnostic: it simply replays an ordered
-- list of 32-bit register writes (CpmRegWriteArray) once at start-up and then
-- services interrupts. This package holds the CPM5-specific payloads the caller
-- composes into that list:
--
--   * the BDF (Bus/Device/Function) address-translation table and the
--     genBdfWrites() helper that flattens it into register writes, and
--   * NOC_CACHE_CONF_C, the CPM5 NoC cache-configuration register writes.
--
-- The composition (and its coupling to the PCIe BAR2 aperture) lives in
-- XilinxAlveoV80PciePhyWrapper, not here and not in the manager.
--
-- Each BDF table entry flattens to six 32-bit words, written in this order
-- (offsets from the entry base, e.g. CPM5_DMA1 BDF table base 0xFCEA2420):
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

   -----------------------------------------------------------------------------
   -- Generic register-write list consumed by XilinxAlveoV80CpmManager. One
   -- entry is a single absolute-address 32-bit write; the manager performs the
   -- list in order and is agnostic to what each write means.
   -----------------------------------------------------------------------------
   type CpmRegWriteType is record
      addr : slv(31 downto 0);
      data : slv(31 downto 0);
   end record CpmRegWriteType;

   type CpmRegWriteArray is array (natural range <>) of CpmRegWriteType;

   -----------------------------------------------------------------------------
   -- BDF (address-translation) table payload
   -----------------------------------------------------------------------------
   -- Number of 32-bit words per BDF table entry
   constant CPM_BDF_WORDS_PER_ENTRY_C : positive := 6;

   -- Global base address of the CPM5_DMA1 BDF address-translation table
   constant CPM_BDF_TABLE_BASE_C : slv(31 downto 0) := x"FCEA2420";

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

   -- Default single-entry BDF table (identity mapping).
   constant CPM_BDF_TABLE_DEFAULT_C : CpmBdfEntryArray := (0 => CPM_BDF_ENTRY_INIT_C);

   -- Flatten a BDF table into the ordered register writes that program it.
   function genBdfWrites (baseAddr : slv(31 downto 0); table : CpmBdfEntryArray) return CpmRegWriteArray;

   -----------------------------------------------------------------------------
   -- NoC cache-configuration payload
   -----------------------------------------------------------------------------
   -- CPM5 register writes that set the NoC AxCACHE behavior on the PCIe BAR2 ->
   -- NOC_PMC_AXI_0 path (re-establishing the non-cacheable behavior the removed
   -- SmartConnect-route axcache tie-off used to force). These values track the
   -- BAR2 aperture -- see XilinxAlveoV80PciePhyWrapper.
   constant NOC_CACHE_CONF_C : CpmRegWriteArray := (
      0 => (addr => x"FCEA0F1C", data => x"00000100"),
      1 => (addr => x"FCEA0F20", data => x"80000040"));

end package XilinxAlveoV80CpmManagerPkg;

package body XilinxAlveoV80CpmManagerPkg is

   function genBdfWrites (baseAddr : slv(31 downto 0); table : CpmBdfEntryArray) return CpmRegWriteArray is
      variable retVar : CpmRegWriteArray(0 to CPM_BDF_WORDS_PER_ENTRY_C*table'length-1);
      variable idx    : natural;
      variable entry  : CpmBdfEntryType;
      variable word3  : slv(31 downto 0);
      variable word4  : slv(31 downto 0);
   begin
      for k in table'range loop
         idx   := CPM_BDF_WORDS_PER_ENTRY_C*(k - table'low);
         entry := table(k);

         -- +0x0C function number (lower 12 bits, upper bits reserved 0)
         word3              := (others => '0');
         word3(11 downto 0) := entry.funcNum;

         -- +0x10 permissions + size
         word4              := (others => '0');
         word4(31)          := entry.rdPerm;
         word4(30)          := entry.wrPerm;
         word4(25 downto 0) := entry.size;

         -- Address of each word = table base + entry offset + word offset
         for w in 0 to CPM_BDF_WORDS_PER_ENTRY_C-1 loop
            retVar(idx+w).addr := baseAddr + toSlv((k - table'low)*(4*CPM_BDF_WORDS_PER_ENTRY_C) + 4*w, 32);
         end loop;

         retVar(idx+0).data := entry.addrTransLow;   -- +0x00
         retVar(idx+1).data := entry.addrTransHigh;  -- +0x04
         retVar(idx+2).data := (others => '0');       -- +0x08 reserved
         retVar(idx+3).data := word3;                 -- +0x0C
         retVar(idx+4).data := word4;                 -- +0x10
         retVar(idx+5).data := (others => '0');       -- +0x14 reserved
      end loop;
      return retVar;
   end function genBdfWrites;

end package body XilinxAlveoV80CpmManagerPkg;
