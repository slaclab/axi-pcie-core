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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AxiPciePkg.all;

entity AxiPciePipTx is
   generic (
      TPD_G              : time                   := 1 ns;
      BURST_BYTES_G      : positive               := 256;  -- Units of Bytes
      NUM_AXIS_G         : positive range 1 to 16 := 1;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- Clock and Reset
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- Configuration Interface
      enableTx   : in  slv(NUM_AXIS_G-1 downto 0);
      remoteBar0BaseAddr   : in  Slv64Array(NUM_AXIS_G-1 downto 0);
      -- AXI Stream Interface
      pipObMaster      : in  AxiStreamMasterType;
      pipObSlave       : out AxiStreamSlaveType;
      -- AXI4 Interface
      pipObWriteMaster : out AxiWriteMasterType;
      pipObWriteSlave  : in  AxiWriteSlaveType);
end AxiPciePipTx;

architecture rtl of AxiPciePipTx is

   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => AXI_PCIE_CONFIG_C.ADDR_WIDTH_C,
      DATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,  -- Matches the AXIS stream
      ID_BITS_C    => AXI_PCIE_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => AXI_PCIE_CONFIG_C.LEN_BITS_C);

   constant BYTE_WIDTH_C : positive        := DMA_AXIS_CONFIG_G.TDATA_BYTES_C;  -- AXI and AXIS matched at DMA before the AXI Interconnection
   constant AXI_LEN_C    : slv(7 downto 0) := getAxiLen(DMA_AXI_CONFIG_C, BURST_BYTES_G);

   type StateType is (
      IDLE_S,
      ADDR_S,
      DATA_S);

   type RegType is record
      tReady           : sl;
      cnt              : slv(7 downto 0);
      pipObWriteMaster : AxiWriteMasterType;
      pipObSlave       : AxiStreamSlaveType;
      state            : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      tReady           => '0',
      cnt              => x"00",
      pipObWriteMaster => axiWriteMasterInit(DMA_AXI_CONFIG_C, '1', "01", "1111"),
      pipObSlave       => AXI_STREAM_SLAVE_INIT_C,
      state            => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axiRst, pipObMaster, pipObWriteSlave, r, remoteBar0BaseAddr,
                   enableTx) is
      variable v   : RegType;
      variable idx : natural range 0 to 15;
   begin
      -- Latch the current value
      v := r;

      -- Update the index variable
      idx := conv_integer(pipObMaster.tDest(3 downto 0));

      -- Reset strobes
      v.pipObSlave.tReady := '0';

      -- Hand shaking
      if (pipObWriteSlave.awready = '1') then
         v.pipObWriteMaster.awvalid := '0';
      end if;
      if (pipObWriteSlave.wready = '1') then
         v.pipObWriteMaster.wvalid := '0';
         v.pipObWriteMaster.wlast  := '0';
      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Check if ready to move data
            if (pipObMaster.tValid = '1') then

               -- Check for SOF and SW enabled the channel after setting the remote BAR0 address
               if (ssiGetUserSof(DMA_AXIS_CONFIG_G, pipObMaster) = '1') and (enableTx(idx) = '1') then
                  -- Next state
                  v.state := ADDR_S;
               else
                  -- Blow off the data 
                  v.pipObSlave.tReady := '1';
               end if;

            end if;
         ----------------------------------------------------------------------
         when ADDR_S =>
            -- Check if ready to send address transaction
            if (v.pipObWriteMaster.awvalid = '0') then

               -- Send the address transaction
               v.pipObWriteMaster.awvalid := '1';
               v.pipObWriteMaster.awaddr  := remoteBar0BaseAddr(idx);
               
               -- Enforce 4kB alignment
               v.pipObWriteMaster.awaddr(11 downto 0) := (others => '0');
               
               -- Set the stream index w.r.t. TDEST
               v.pipObWriteMaster.awaddr(15 downto 12) := pipObMaster.tDest(3 downto 0);
               
               -- Enforce Bar0 PIP address space
               v.pipObWriteMaster.awaddr(23 downto 16) := x"08";               
               
               
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
               if (r.cnt = AXI_LEN_C) then
                  -- Reset the counter
                  v.cnt                    := x"00";
                  -- Terminate the transaction
                  v.pipObWriteMaster.wlast := '1';
                  -- Next state
                  v.state                  := IDLE_S;
               else
                  -- Increment the counter
                  v.cnt := r.cnt + 1;
               end if;

            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      pipObSlave              <= v.pipObSlave;
      pipObWriteMaster        <= r.pipObWriteMaster;
      pipObWriteMaster.bready <= '1';   -- Ignoring the bus response
      pipObWriteMaster.awsize <= toSlv(log2(DMA_AXI_CONFIG_C.DATA_BYTES_C), 3);
      pipObWriteMaster.awlen  <= AXI_LEN_C;

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
