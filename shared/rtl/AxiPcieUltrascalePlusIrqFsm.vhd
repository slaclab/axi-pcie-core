-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Ultrascale+ IRQ FSM
--
-- Drives the usr_irq_req / usr_irq_ack handshake for the Xilinx XDMA / CPM5
-- AXI Bridge user-interrupt interface. The ack semantics are identical between
-- PG195 (UltraScale+ XDMA / DMA Bridge Subsystem for PCIe) and PG347 (Versal
-- CPM DMA and Bridge Mode for PCI Express, AXI Bridge for PCIe Interrupts);
-- both explicitly state: "Two acks are generated for legacy interrupt. One
-- ack is generated for MSI/MSI-X interrupts." This FSM therefore drives both
-- IPs with a single shared implementation:
--   INTX        : ack on req rising edge (Assert_INTA TLP sent)
--                 AND ack on req falling edge (Deassert_INTA TLP sent)
--                 -> 6-state two-ack handshake (default).
--   MSI / MSIX  : ack on req rising edge (MSI/MSI-X memory write completed),
--                 NO ack on falling edge (message-based, no deassert TLP)
--                 -> 4-state single-ack handshake.
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

entity AxiPcieUltrascalePlusIrqFsm is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      clk        : in  sl;
      rstL       : in  sl;
      -- Interrupt Interface
      dmaIrq     : in  sl;
      msiEnable  : in  sl := '0';
      msixEnable : in  sl := '0';
      usrIrqAck  : in  sl;
      usrIrqReq  : out sl);
end AxiPcieUltrascalePlusIrqFsm;

architecture rtl of AxiPcieUltrascalePlusIrqFsm is

   type StateType is (
      IDLE_S,
      SET_S,
      SYNC0_S,
      SERV_S,
      CLR_S,
      SYNC1_S);

   type RegType is record
      usrIrqReq : sl;
      irqTimer  : slv(31 downto 0);
      state     : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      usrIrqReq => '0',
      irqTimer  => (others => '0'),
      state     => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (dmaIrq, msiEnable, msixEnable, r, rstL, usrIrqAck) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            if (dmaIrq = '1')then
               v.usrIrqReq := '1';
               v.state     := SET_S;
            end if;
         ----------------------------------------------------------------------
         when SET_S =>
            if (usrIrqAck = '1') then
               v.state := SYNC0_S;
            end if;
         ----------------------------------------------------------------------
         when SYNC0_S =>
            if (usrIrqAck = '0') then
               v.state := SERV_S;
            end if;
         ----------------------------------------------------------------------
         when SERV_S =>
            v.irqTimer := v.irqTimer + 1;
            if (dmaIrq = '0') or (r.irqTimer = 250000000) then
               v.irqTimer  := (others => '0');
               v.usrIrqReq := '0';
               if (msiEnable = '0') and (msixEnable = '0') then
                  -- Legacy INTx: wait for the Deassert_INTA ack pair.
                  v.state := CLR_S;
               else
                  -- MSI / MSIX: no deassert message, no second ack.
                  v.state := IDLE_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when CLR_S =>
            if (usrIrqAck = '1') then
               v.state := SYNC1_S;
            end if;
         ----------------------------------------------------------------------
         when SYNC1_S =>
            if (usrIrqAck = '0') then
               v.state := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      usrIrqReq <= r.usrIrqReq;

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
