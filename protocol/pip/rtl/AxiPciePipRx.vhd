-------------------------------------------------------------------------------
-- File       : AxiPciePipRx.vhd
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

entity AxiPciePipRx is
   generic (
      TPD_G             : time := 1 ns;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- Clock and Reset
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- AXI4 Interface
      pipIbWriteMaster : in  AxiWriteMasterType;
      pipIbWriteSlave  : out AxiWriteSlaveType;
      -- AXI Stream Interface
      pipIbMaster      : out AxiStreamMasterType;
      pipIbSlave       : in  AxiStreamSlaveType);
end AxiPciePipRx;

architecture rtl of AxiPciePipRx is

   constant BYTE_WIDTH_C    : positive                     := DMA_AXIS_CONFIG_G.TDATA_BYTES_C;  -- AXI and AXIS matched at DMA before the AXI Interconnection
   constant WSTRB_NOT_EOF_C : slv(BYTE_WIDTH_C-1 downto 0) := (others => '1');

   type StateType is (
      ADDR_S,
      DATA_S,
      RESP_S);

   type RegType is record
      tValid          : sl;
      tFirst          : sl;
      tLast           : sl;
      pipIbWriteSlave : AxiWriteSlaveType;
      obMasters       : AxiStreamMasterArray(1 downto 0);
      state           : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      tValid          => '0',
      tFirst          => '0',
      tLast           => '0',
      pipIbWriteSlave => AXI_WRITE_SLAVE_INIT_C,
      obMasters       => (others => AXI_STREAM_MASTER_INIT_C),
      state           => ADDR_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal obCtrl : AxiStreamCtrlType;

begin

   comb : process (axiRst, obCtrl, pipIbWriteMaster, r) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.pipIbWriteSlave.awready := '0';
      v.pipIbWriteSlave.wready  := '0';
      v.obMasters(0).tValid     := '0';

      -- Hand shaking
      if (pipIbWriteMaster.bready = '1') then
         v.pipIbWriteSlave.bvalid := '0';
      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when ADDR_S =>
            -- Check for address valid
            if (pipIbWriteMaster.awvalid = '1') then

               -- Accept the transaction
               v.pipIbWriteSlave.awready := '1';

               -- Set the bus response ID
               v.pipIbWriteSlave.bid := pipIbWriteMaster.awid;

               -- Set the TDEST w.r.t. Address[15:12]
               v.obMasters(1).tDest(3 downto 0) := pipIbWriteMaster.awaddr(15 downto 12);

               -- Check for 4kB alignment and enough room in FIFO
               if (pipIbWriteMaster.awaddr(11 downto 0) = 0) and (obCtrl.pause = '0') then
                  -- Set the flag
                  v.tValid := '1';
               end if;

               -- Next state
               v.state := DATA_S;

            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            -- Check for address valid
            if (pipIbWriteMaster.wvalid = '1') then

               -- Accept the transaction
               v.pipIbWriteSlave.wready := '1';

               -- Check if moving data
               if (r.tValid = '1') and (pipIbWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0) /= 0) then
                  -- Update the data bus
                  v.obMasters(1).tValid                           := '1';
                  v.obMasters(1).tData(8*BYTE_WIDTH_C-1 downto 0) := pipIbWriteMaster.wdata(8*BYTE_WIDTH_C-1 downto 0);
                  v.obMasters(1).tKeep(BYTE_WIDTH_C-1 downto 0)   := pipIbWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0);
                  v.obMasters(1).tUser                            := (others => '0');

                  -- Advance the pipeline
                  v.obMasters(0) := r.obMasters(1);
               end if;
               
               -- Check for SOF condition
               if (r.tFirst = '0') then
                  -- Set the flag
                  v.tFirst := '1';
                  -- Set SOF               
                  ssiSetUserSof(DMA_AXIS_CONFIG_G, v.obMasters(1), '1');
               end if;

               -- Check for the EOF condition
               if (r.tLast = '0') and ((pipIbWriteMaster.wlast = '1') or (pipIbWriteMaster.wstrb(BYTE_WIDTH_C-1 downto 0) /= WSTRB_NOT_EOF_C)) then
                  -- Set the flag
                  v.tLast              := '1';
                  v.tValid             := '0';
                  -- Set the flag
                  v.obMasters(1).tLast := '1';
               end if;

               -- Check for last AXI last transaction cycle
               if (pipIbWriteMaster.wlast = '1') then
                  -- Send the bus response
                  v.pipIbWriteSlave.bvalid := '1';
                  -- Next state
                  v.state                  := RESP_S;
               end if;

            end if;
         ----------------------------------------------------------------------
         when RESP_S =>
            -- Advance the pipeline
            v.obMasters(1).tValid := '0';
            v.obMasters(1).tLast  := '0';
            v.obMasters(1).tUser  := (others => '0');            
            v.obMasters(0)        := r.obMasters(1);

            -- Wait for the bus response hand shaking 
            if (v.pipIbWriteSlave.bvalid = '0') then

               -- Reset the flags
               v.tValid := '0';
               v.tFirst := '0';
               v.tLast  := '0';

               -- Next state
               v.state := ADDR_S;

            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      pipIbWriteSlave         <= r.pipIbWriteSlave;
      pipIbWriteSlave.awready <= v.pipIbWriteSlave.awready;
      pipIbWriteSlave.wready  <= v.pipIbWriteSlave.wready;

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

   U_FIFO : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => false,  -- Using pause
         GEN_SYNC_FIFO_G     => true,
         BRAM_EN_G           => true,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 250,
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => axiClk,
         sAxisRst    => axiRst,
         sAxisMaster => r.obMasters(0),
         sAxisCtrl   => obCtrl,
         -- Master Port
         mAxisClk    => axiClk,
         mAxisRst    => axiRst,
         mAxisMaster => pipIbMaster,
         mAxisSlave  => pipIbSlave);

end rtl;
