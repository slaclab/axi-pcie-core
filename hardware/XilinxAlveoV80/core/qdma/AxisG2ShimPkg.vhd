-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Package for the AxisG2 BAR0 compatibility shim (AxisG2RegShim)
-- and the QDMA descriptor-bypass adapter (QdmaBypassAdapter) on the Alveo V80.
--
-- Defines the decoded descriptor-submission records passed from the shim (which
-- captures the datadev driver's AxisG2 FIFO writes) to the adapter (which turns
-- them into CPM5 QDMA descriptor-bypass descriptors). Kept in its own file so
-- both entities can share it. See [[v80-qdma-bypass-migration]].
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

package AxisG2ShimPkg is

   -- Index width for the dmaAddr table (driver uses up to 4096 entries).
   constant AXISG2_INDEX_BITS_C : positive := 12;

   -- One TX (readFifo) descriptor submission decoded from the FIFO-A/B writes.
   type AxisG2TxSubType is record
      valid     : sl;
      index     : slv(AXISG2_INDEX_BITS_C-1 downto 0);
      size      : slv(23 downto 0);
      dest      : slv(7 downto 0);
      cont      : sl;
      timeout   : sl;
      firstUser : slv(7 downto 0);
      lastUser  : slv(7 downto 0);
   end record AxisG2TxSubType;

   constant AXISG2_TX_SUB_INIT_C : AxisG2TxSubType := (
      valid     => '0',
      index     => (others => '0'),
      size      => (others => '0'),
      dest      => (others => '0'),
      cont      => '0',
      timeout   => '0',
      firstUser => (others => '0'),
      lastUser  => (others => '0'));

   -- One RX free-buffer submission decoded from the writeFifo-A write.
   type AxisG2RxFreeType is record
      valid : sl;
      index : slv(AXISG2_INDEX_BITS_C-1 downto 0);
   end record AxisG2RxFreeType;

   constant AXISG2_RX_FREE_INIT_C : AxisG2RxFreeType := (
      valid => '0',
      index => (others => '0'));

end package AxisG2ShimPkg;
