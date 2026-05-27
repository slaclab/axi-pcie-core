-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Ultrascale+ IRQ FSM
--
-- Drives the Xilinx XDMA usr_irq_req / usr_irq_ack handshake. Per PG195 the
-- ack semantics differ by interrupt mode:
--   INTX        : ack on req rising edge (Assert_INTA TLP sent)
--                 AND ack on req falling edge (Deassert_INTA TLP sent)
--                 -> 6-state two-ack handshake (default).
--   MSI / MSIX  : ack on req rising edge (MSI/MSI-X memory write completed),
--                 NO ack on falling edge (message-based, no deassert TLP)
--                 -> 4-state single-ack handshake.
-- Select via IRQ_TYPE_G ("INTX" | "MSI" | "MSIX"). MSI and MSIX behave
-- identically on the firmware side; the difference lives in the PCIe IP
-- XCI configuration and the host-side capability discovery.
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
      TPD_G      : time   := 1 ns;
      IRQ_TYPE_G : string := "INTX");  -- "INTX" | "MSI" | "MSIX"
   port (
      -- Clock and Reset
      clk       : in  sl;
      rstL      : in  sl;
      -- Interrupt Interface
      dmaIrq    : in  sl;
      usrIrqAck : in  sl;
      usrIrqReq : out sl);
end AxiPcieUltrascalePlusIrqFsm;

architecture rtl of AxiPcieUltrascalePlusIrqFsm is

   -- Synthesis-time mode select. INTX uses the legacy two-ack handshake;
   -- MSI / MSIX use the single-ack message-based handshake.
   constant INTX_C : boolean := (IRQ_TYPE_G = "INTX");

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

   assert (IRQ_TYPE_G = "INTX") or (IRQ_TYPE_G = "MSI") or (IRQ_TYPE_G = "MSIX")
      report "AxiPcieUltrascalePlusIrqFsm: IRQ_TYPE_G must be ""INTX"", ""MSI"", or ""MSIX"" (got: " & IRQ_TYPE_G & ")"
      severity failure;

   comb : process (dmaIrq, r, rstL, usrIrqAck) is
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
               if INTX_C then
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
