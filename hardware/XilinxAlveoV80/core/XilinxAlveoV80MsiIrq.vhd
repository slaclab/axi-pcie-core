-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PL-driven MSI generator for the Xilinx Alveo V80 (CPM5).
--
-- Workaround for the CPM5 bridge1 usr_irq handshake defect: the
-- bridge1_usr_irq_req / bridge1_usr_irq_ack path never completes and no MSI TLP
-- is emitted (confirmed on hardware via ILA; SLAC RTL asserts and holds
-- usr_irq_req per PG347, but the CPM never acks). Instead of relying on that
-- hardware handshake, this block generates the PCIe TX MSI in software-trigger
-- mode by writing the CPM5_DMA1 TX_IRQ_CSR register directly from PL fabric.
--
-- On each dmaIrq assertion it issues a single AXI-Lite write of INT_SET_VAL_G
-- (int_set = bit 24) to TX_IRQ_CSR_ADDR_G (0xFCEA0E7C). PG347 v3.4 Table 215:
-- the CPM5 bridge register block is reachable from PL only through the LPD AXI
-- slave interface, so this master is expected to drive the CIPS S_AXI_LPD port.
--
-- Per the TX_IRQ_CSR definition, writing int_set=1 sends the PCIe TX MSI/MSI-X
-- interrupt; the message is edge-like (one MSI per write), so a single write
-- per dmaIrq assertion is sufficient and the request is not held. A watchdog
-- re-arms the FSM if dmaIrq stays asserted, matching the 1 s cadence of the
-- retired AxiPcieUltrascalePlusIrqFsm.
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

entity XilinxAlveoV80MsiIrq is
   generic (
      TPD_G             : time     := 1 ns;
      -- Global address of the CPM5_DMA1 TX_IRQ_CSR register (PG347 Table 215)
      TX_IRQ_CSR_ADDR_G : slv(31 downto 0) := x"FCEA0E7C";
      -- int_set = bit 24; int_vector = 0, int_function = 0 (PF0, MSI vector 0)
      INT_SET_VAL_G     : slv(31 downto 0) := x"01000000";
      -- Re-arm watchdog (clock cycles) if dmaIrq remains asserted; 250e6 ~ 1 s
      -- at the 250 MHz PL clock.
      WATCHDOG_G        : positive := 250000000);
   port (
      -- Clock and Reset
      clk             : in  sl;
      rstL            : in  sl;         -- active LOW reset
      -- Interrupt Interface
      dmaIrq          : in  sl;
      -- AXI-Lite Master (drives the CIPS S_AXI_LPD slave)
      axilWriteMaster : out AxiLiteWriteMasterType;
      axilWriteSlave  : in  AxiLiteWriteSlaveType;
      axilReadMaster  : out AxiLiteReadMasterType;
      axilReadSlave   : in  AxiLiteReadSlaveType);
end XilinxAlveoV80MsiIrq;

architecture rtl of XilinxAlveoV80MsiIrq is

   type StateType is (
      IDLE_S,
      REQ_S,
      WAIT_DONE_S,
      HOLD_S);

   type RegType is record
      req      : AxiLiteReqType;
      irqTimer : slv(31 downto 0);
      state    : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      req      => AXI_LITE_REQ_INIT_C,
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
         when IDLE_S =>
            v.irqTimer := (others => '0');
            -- Wait for the DMA interrupt request
            if (dmaIrq = '1') then
               v.state := REQ_S;
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
            -- Wait for the AXI-Lite write to complete
            if (ack.done = '1') then
               -- Deassert the request (AxiLiteMaster clears ack when request=0)
               v.req.request := '0';
               v.state       := HOLD_S;
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

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
