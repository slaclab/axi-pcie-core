-------------------------------------------------------------------------------
-- File       : AxiPciePipTx.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PCIe Intercommunication Protocol (PIP) Receiver Module
-- https://docs.google.com/presentation/d/1q2_Do7NnphHalV-whGrYIs9gwy7iVHokBgztF4KVqBk/edit?usp=sharing
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

entity AxiPciePipTx is
   generic (
      TPD_G              : time                   := 1 ns;
      BURST_BYTES_G      : positive               := 256;  -- Units of Bytes
      NUM_AXIS_G         : positive range 1 to 16 := 1;
      PCIE_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- Clock and Reset
      axiClk            : in  sl;
      axiRst            : in  sl;
      -- Configuration Interface
      enableTx          : in  slv(NUM_AXIS_G-1 downto 0);
      remoteBarBaseAddr : in  Slv32Array(NUM_AXIS_G-1 downto 0);
      awcache           : in  slv(3 downto 0);
      txFrame           : out sl;
      txDropFrame       : out sl;
      txAxiError        : out sl;
      -- AXI Stream Interface
      pipObMaster       : in  AxiStreamMasterType;
      pipObSlave        : out AxiStreamSlaveType;
      -- AXI4 Interface
      pipObWriteMaster  : out AxiWriteMasterType;
      pipObWriteSlave   : in  AxiWriteSlaveType);
end AxiPciePipTx;

architecture rtl of AxiPciePipTx is

   constant BYTE_WIDTH_C        : positive        := AXI_PCIE_CONFIG_C.DATA_BYTES_C;  -- AXI and AXIS matched at DMA before the AXI Interconnection
   constant AXI_TRANSPORT_LEN_C : slv(7 downto 0) := getAxiLen(AXI_PCIE_CONFIG_C, BURST_BYTES_G);
   constant AXI_TERMINATE_LEN_C : slv(7 downto 0) := getAxiLen(AXI_PCIE_CONFIG_C, 1);

   type StateType is (
      IDLE_S,
      ADDR_S,
      DATA_S,
      TERMINATE_S);

   type RegType is record
      txAxiError       : sl;
      txDropFrame      : sl;
      txFrame          : sl;
      tReady           : sl;
      cnt              : slv(7 downto 0);
      pipObWriteMaster : AxiWriteMasterType;
      pipObSlave       : AxiStreamSlaveType;
      state            : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      txAxiError       => '0',
      txDropFrame      => '0',
      txFrame          => '0',
      tReady           => '0',
      cnt              => x"00",
      pipObWriteMaster => axiWriteMasterInit(AXI_PCIE_CONFIG_C, '1', "01", "1111"),
      pipObSlave       => AXI_STREAM_SLAVE_INIT_C,
      state            => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (awcache, axiRst, enableTx, pipObMaster, pipObWriteSlave, r,
                   remoteBarBaseAddr) is
      variable v   : RegType;
      variable idx : natural range 0 to 15;
   begin
      -- Latch the current value
      v := r;

      -- Update the index variable
      idx := conv_integer(pipObMaster.tDest(3 downto 0));

      -- Reset strobes
      v.txFrame     := '0';
      v.txDropFrame := '0';

      v.pipObSlave.tReady := '0';

      -- Hand shaking
      if (pipObWriteSlave.awready = '1') then
         v.pipObWriteMaster.awvalid := '0';
      end if;
      if (pipObWriteSlave.wready = '1') then
         v.pipObWriteMaster.wvalid := '0';
         v.pipObWriteMaster.wlast  := '0';
      end if;

      -- Update the AXI bus error flag
      v.txAxiError := pipObWriteSlave.bvalid and uOr(pipObWriteSlave.bresp);

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Check if ready to move data
            if (pipObMaster.tValid = '1') then

               -- Check for the enabled conditions
               if (ssiGetUserSof(PCIE_AXIS_CONFIG_G, pipObMaster) = '1')  -- Check for SOF
                               and (remoteBarBaseAddr(idx)(31 downto 24) /= 0)  -- Check for non-zero BAR base address
                               and (remoteBarBaseAddr(idx)(23 downto 0) = 0)  -- Check for 16MB alignment
                               and (enableTx(idx) = '1') then  -- Check for TX enabled
                  -- Set the flag
                  v.txFrame := '1';
                  -- Next state
                  v.state   := ADDR_S;
               else
                  -- Blow off the data
                  v.pipObSlave.tReady := '1';
                  -- Set the flag
                  v.txDropFrame       := pipObMaster.tLast;
               end if;

            end if;
         ----------------------------------------------------------------------
         when ADDR_S =>
            -- Check if ready to send address transaction
            if (v.pipObWriteMaster.awvalid = '0') then

               -- Send the address transaction
               v.pipObWriteMaster.awvalid              := '1';
               v.pipObWriteMaster.awaddr(31 downto 24) := remoteBarBaseAddr(idx)(31 downto 24);

               -- Enforce PIP address space
               v.pipObWriteMaster.awaddr(23 downto 16) := x"08";

               -- Set the stream index w.r.t. TDEST
               v.pipObWriteMaster.awaddr(15 downto 12) := pipObMaster.tDest(3 downto 0);

               -- Enforce 4kB alignment
               v.pipObWriteMaster.awaddr(11 downto 0) := (others => '0');

               -- Set the flag
               v.tReady := '1';

               -- Next state
               v.state := DATA_S;

            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            -- Check if ready to move data
            if ((pipObMaster.tValid = '1') or (r.tReady = '0')) and (v.pipObWriteMaster.wvalid = '0') then

               -- Accept the data
               v.pipObSlave.tReady := r.tReady;

               -- Move the data
               v.pipObWriteMaster.wvalid                           := '1';
               v.pipObWriteMaster.wdata(8*BYTE_WIDTH_C-1 downto 0) := pipObMaster.tData(8*BYTE_WIDTH_C-1 downto 0);
               if (r.tReady = '1') then
                  v.pipObWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0) := pipObMaster.tKeep(BYTE_WIDTH_C-1 downto 0);
               else
                  v.pipObWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0) := (others => '0');
               end if;

               -- Check for tLast
               if (pipObMaster.tLast = '1') and (r.tReady = '1') then
                  -- Reset the flag
                  v.tReady := '0';
               end if;

               -- Check for last cycle of the transaction
               if (r.cnt = AXI_TRANSPORT_LEN_C) then
                  -- Reset the counter
                  v.cnt                    := x"00";
                  -- Terminate the transaction
                  v.pipObWriteMaster.wlast := '1';
                  -- Next state
                  v.state                  := TERMINATE_S;
               else
                  -- Increment the counter
                  v.cnt := r.cnt + 1;
               end if;

            end if;
         ----------------------------------------------------------------------
         when TERMINATE_S =>
            if (v.pipObWriteMaster.awvalid = '0') and (v.pipObWriteMaster.wvalid = '0') then
               -- Send the address termination transaction
               v.pipObWriteMaster.awvalid                        := '1';
               v.pipObWriteMaster.awaddr(23 downto 16)           := x"09";
               v.pipObWriteMaster.wvalid                         := '1';
               v.pipObWriteMaster.wlast                          := '1';
               v.pipObWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0) := toSlv(1, BYTE_WIDTH_C);
               -- Next state
               v.state                                           := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      txAxiError               <= r.txAxiError;
      txDropFrame              <= r.txDropFrame;
      txFrame                  <= r.txFrame;
      pipObSlave               <= v.pipObSlave;
      pipObWriteMaster         <= r.pipObWriteMaster;
      pipObWriteMaster.bready  <= '1';  -- Ignoring the bus response
      pipObWriteMaster.awsize  <= toSlv(log2(AXI_PCIE_CONFIG_C.DATA_BYTES_C), 3);
      pipObWriteMaster.awcache <= awcache;

      if (r.pipObWriteMaster.awaddr(23 downto 16) = x"08") then
         pipObWriteMaster.awlen <= AXI_TRANSPORT_LEN_C;
      else
         pipObWriteMaster.awlen <= AXI_TERMINATE_LEN_C;
      end if;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
