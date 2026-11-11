-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Versal CPM5 management block for the Xilinx Alveo V80.
--
-- Drives the CIPS S_AXI_LPD slave to manage the CPM5_DMA1 controller from PL
-- fabric. It does two jobs over one AXI-Lite master:
--
--  1) On the FIRST dmaIrq it programs the CPM5 BDF (address-translation) table,
--     writing each entry's six 32-bit words in order (see
--     XilinxAlveoV80CpmManagerPkg). The default single-entry table is an
--     identity mapping, function 0, read+write enabled, 128 GiB aperture --
--     reproducing the reference sequence (0xFCEA2420..0xFCEA2434, word +0x10 =
--     0xC2000000). Programming is deferred to the first interrupt (rather than
--     done at reset) so the CPM5 is guaranteed past its own boot/CDO
--     initialization and PCIe is up before the BDF entry is written -- a reset-
--     time write was observed to read back as 0 (clobbered by / racing the CDO).
--
--  2) It then services DMA interrupts: on each dmaIrq assertion it writes
--     int_set (bit 24) to the CPM5_DMA1 TX_IRQ_CSR (0xFCEA0E7C), generating the
--     PCIe TX MSI directly. This replaces the defective CPM5 bridge1
--     usr_irq_req / usr_irq_ack hardware handshake (confirmed broken on
--     hardware: the CPM never acks and no MSI TLP is emitted). The first
--     interrupt therefore programs the table and then sends its MSI.
--
-- PG347 v3.4 Table 215: the CPM5 register block is reachable from PL only
-- through the LPD AXI slave interface, so this master drives cips/S_AXI_LPD
-- (whose address space maps the CPM aperture at 0xFC00_0000, 16 MB).
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
use surf.AxiLitePkg.all;

library axi_pcie_core;
use axi_pcie_core.XilinxAlveoV80CpmManagerPkg.all;

entity XilinxAlveoV80CpmManager is
   generic (
      TPD_G             : time     := 1 ns;
      -- Global address of the CPM5_DMA1 TX_IRQ_CSR register (PG347 Table 215)
      TX_IRQ_CSR_ADDR_G : slv(31 downto 0) := x"FCEA0E7C";
      -- int_set = bit 24; int_vector = 0, int_function = 0 (PF0, MSI vector 0)
      INT_SET_VAL_G     : slv(31 downto 0) := x"01000000";
      -- Global base address of the CPM5_DMA1 BDF address-translation table
      BDF_TABLE_ADDR_G  : slv(31 downto 0) := x"FCEA2420";
      -- BDF address-translation table to program after reset
      BDF_TABLE_G       : CpmBdfEntryArray := (0 => CPM_BDF_ENTRY_INIT_C);
      -- Re-arm watchdog (clock cycles) if dmaIrq remains asserted; 250e6 ~ 1 s
      -- at the 250 MHz PL clock.
      WATCHDOG_G        : positive := 250000000);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rstL            : in  sl;         -- active LOW reset
      -- Interrupt Interface
      dmaIrq          : in  sl;
      -- Status
      bdfDone         : out sl;         -- BDF table programming complete
      -- AXI-Lite Master (drives the CIPS S_AXI_LPD slave)
      axilWriteMaster : out AxiLiteWriteMasterType;
      axilWriteSlave  : in  AxiLiteWriteSlaveType;
      axilReadMaster  : out AxiLiteReadMasterType;
      axilReadSlave   : in  AxiLiteReadSlaveType);
end XilinxAlveoV80CpmManager;

architecture rtl of XilinxAlveoV80CpmManager is

   -- Flattened BDF table: the ordered register addresses and data words.
   constant BDF_ADDR_C : Slv32Array := genBdfAddr(BDF_TABLE_ADDR_G, BDF_TABLE_G);
   constant BDF_DATA_C : Slv32Array := genBdfData(BDF_TABLE_G);
   constant BDF_LEN_C  : natural    := BDF_DATA_C'length;

   type StateType is (
      IDLE_S,
      BDF_REQ_S,
      REQ_S,
      WAIT_DONE_S,
      HOLD_S);

   type RegType is record
      req      : AxiLiteReqType;
      bdfDone  : sl;
      bdfIndex : natural range 0 to BDF_LEN_C;
      irqTimer : slv(31 downto 0);
      state    : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      req      => AXI_LITE_REQ_INIT_C,
      bdfDone  => '0',
      bdfIndex => 0,
      irqTimer => (others => '0'),
      state    => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ack : AxiLiteAckType;

begin

   --------------------------------------------------------------------------
   -- AXI-Lite master transaction engine (REQ/ACK controlled)
   --------------------------------------------------------------------------
   U_AxiLiteMaster : entity surf.AxiLiteMaster
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '0')         -- active LOW reset
      port map (
         axilClk         => clk,
         axilRst         => rstL,
         req             => r.req,
         ack             => ack,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave);

   comb : process (ack, dmaIrq, r, rstL) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when BDF_REQ_S =>
            -- Program the BDF table one 32-bit word at a time, in order.
            v.req.request := '1';
            v.req.rnw     := '0';
            v.req.address := BDF_ADDR_C(r.bdfIndex);
            v.req.wrData  := BDF_DATA_C(r.bdfIndex);
            v.state       := WAIT_DONE_S;
         ----------------------------------------------------------------------
         when IDLE_S =>
            v.irqTimer := (others => '0');
            -- Wait for the DMA interrupt request. On the FIRST interrupt, program
            -- the CPM5 BDF address-translation table before sending the MSI; on
            -- later interrupts the table is already programmed so go straight to
            -- the TX_IRQ_CSR write. Programming on the first IRQ (rather than at
            -- reset) ensures the CPM5 is past its boot/CDO init and PCIe is up
            -- before the BDF entry is written.
            if (dmaIrq = '1') then
               if (r.bdfDone = '0') then
                  v.bdfIndex := 0;
                  v.state    := BDF_REQ_S;
               else
                  v.state := REQ_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when REQ_S =>
            -- Issue a single 32-bit write of int_set to TX_IRQ_CSR
            v.req.request := '1';
            v.req.rnw     := '0';
            v.req.address := TX_IRQ_CSR_ADDR_G;
            v.req.wrData  := INT_SET_VAL_G;
            v.state       := WAIT_DONE_S;
         ----------------------------------------------------------------------
         when WAIT_DONE_S =>
            -- Wait for the current AXI-Lite write to complete, then return to
            -- the state that issued it (BDF programming or IRQ service).
            if (ack.done = '1') then
               -- Deassert the request (AxiLiteMaster clears ack when request=0)
               v.req.request := '0';
               if (r.bdfDone = '0') then
                  -- Still programming the BDF table.
                  if (r.bdfIndex = BDF_LEN_C-1) then
                     v.bdfDone := '1';
                     v.state   := REQ_S;  -- table done; now send this IRQ's MSI
                  else
                     v.bdfIndex := r.bdfIndex + 1;
                     v.state    := BDF_REQ_S;
                  end if;
               else
                  -- IRQ service write completed.
                  v.state := HOLD_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when HOLD_S =>
            -- One MSI has been sent. Return to IDLE when dmaIrq deasserts; if it
            -- stays asserted, re-arm after the watchdog so a persistent request
            -- is not lost.
            v.irqTimer := r.irqTimer + 1;
            if (dmaIrq = '0') then
               v.state := IDLE_S;
            elsif (r.irqTimer = WATCHDOG_G) then
               v.irqTimer := (others => '0');
               v.state    := REQ_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Reset
      if (rstL = '0') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      bdfDone <= r.bdfDone;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
