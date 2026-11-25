-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Versal CPM5 management block for the Xilinx Alveo V80.
--
-- Payload-agnostic CPM5 manager. Over one AXI-Lite master it does two jobs and
-- knows nothing about what the registers it touches mean:
--
--  1) START-UP WRITES: on the FIRST host register access it replays the ordered
--     list STARTUP_WRITES_G (address/data pairs) one 32-bit write at a time,
--     then asserts startupDone. The caller composes this list and decides what
--     it contains -- see XilinxAlveoV80PciePhyWrapper, which builds it from the
--     CPM5 NoC cache-configuration writes and the BDF address-translation table
--     (XilinxAlveoV80CpmManagerPkg). Replay is deferred to the first host access
--     (rather than done at reset) so the CPM5 is guaranteed past its own boot/CDO
--     initialization and PCIe is up before the writes land -- a reset-time write
--     was observed to read back as 0 (clobbered by / racing the CDO).
--
--  2) IRQ DELIVERY: after start-up it services DMA interrupts -- on each dmaIrq
--     assertion it writes int_set (bit 24) to the CPM5_DMA1 TX_IRQ_CSR
--     (TX_IRQ_CSR_ADDR_G), generating the PCIe TX MSI directly. This replaces the
--     defective CPM5 bridge1 usr_irq_req / usr_irq_ack hardware handshake
--     (confirmed broken on hardware: the CPM never acks and no MSI TLP is
--     emitted). dmaIrq is not serviced until the start-up writes have completed.
--
-- The AXI-Lite master is routed to the CPM5 register space by the block design
-- (on the V80 this currently goes out the external sAxiLpd port into the CPM
-- NoC); how it gets there is not this block's concern.
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
      -- Ordered list of 32-bit register writes replayed once, on the first host
      -- access, before any interrupt is serviced. The manager is agnostic to
      -- what these mean; the caller composes them (see PciePhyWrapper).
      STARTUP_WRITES_G  : CpmRegWriteArray;
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
      startupDone     : out sl;         -- start-up register writes complete
      -- Host BAR0 request seen on the bridge master (link up, CPM5 configured)
      hostAccess      : in  sl;
      -- AXI-Lite Master (routed to the CPM5 register space by the block design)
      axilWriteMaster : out AxiLiteWriteMasterType;
      axilWriteSlave  : in  AxiLiteWriteSlaveType;
      axilReadMaster  : out AxiLiteReadMasterType;
      axilReadSlave   : in  AxiLiteReadSlaveType);
end XilinxAlveoV80CpmManager;

architecture rtl of XilinxAlveoV80CpmManager is

   -- Start-up write list, normalized to an ascending 0-based range for indexing.
   constant WRITES_C     : CpmRegWriteArray(0 to STARTUP_WRITES_G'length-1) := STARTUP_WRITES_G;
   constant NUM_WRITES_C : natural                                          := WRITES_C'length;

   type StateType is (
      IDLE_S,
      WRITE_REQ_S,
      REQ_S,
      WAIT_DONE_S,
      HOLD_S);

   type RegType is record
      req         : AxiLiteReqType;
      startupDone : sl;
      wrIndex     : natural range 0 to NUM_WRITES_C;
      irqTimer    : slv(31 downto 0);
      state       : StateType;
   end record RegType;

   -- With an empty STARTUP_WRITES_G, startupDone is forced in IDLE_S so the
   -- first interrupt goes straight to the TX_IRQ_CSR write (pure MSI gen).
   constant REG_INIT_C : RegType := (
      req         => AXI_LITE_REQ_INIT_C,
      startupDone => '0',
      wrIndex     => 0,
      irqTimer    => (others => '0'),
      state       => IDLE_S);

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

   comb : process (ack, dmaIrq, r, rstL, hostAccess) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when WRITE_REQ_S =>
            -- Replay the start-up write list one 32-bit write at a time, in order.
            v.req.request := '1';
            v.req.rnw     := '0';
            v.req.address := WRITES_C(r.wrIndex).addr;
            v.req.wrData  := WRITES_C(r.wrIndex).data;
            v.state       := WAIT_DONE_S;
         ----------------------------------------------------------------------
         when IDLE_S =>
            v.irqTimer := (others => '0');
            if (r.startupDone = '0') then
               -- Replay the start-up writes on the first host BAR0 access.
               if (NUM_WRITES_C = 0) then
                  -- Nothing to write; go straight to IRQ service.
                  v.startupDone := '1';
               elsif (hostAccess = '1') then
                  v.wrIndex := 0;
                  v.state   := WRITE_REQ_S;
               end if;
            elsif (dmaIrq = '1') then
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
            -- Wait for the current AXI-Lite write to complete, then return to the
            -- state that issued it (start-up replay or IRQ service).
            if (ack.done = '1') then
               -- Deassert the request (AxiLiteMaster clears ack when request=0)
               v.req.request := '0';
               if (r.startupDone = '0') then
                  if (ack.resp /= AXI_RESP_OK_C) then
                     -- Write rejected: start over on the next host access
                     v.state := IDLE_S;
                  elsif (r.wrIndex = NUM_WRITES_C-1) then
                     v.startupDone := '1';
                     v.state       := IDLE_S;  -- no IRQ pending yet
                  else
                     v.wrIndex := r.wrIndex + 1;
                     v.state   := WRITE_REQ_S;
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
      startupDone <= r.startupDone;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
