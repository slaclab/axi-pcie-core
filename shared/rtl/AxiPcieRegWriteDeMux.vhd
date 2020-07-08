-------------------------------------------------------------------------------
-- File       : AxiPcieRegWriteDeMux.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: DEMUX the register access and
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

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

entity AxiPcieRegWriteMux is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      axiClk          : in  sl;
      axiRst          : in  sl;
      -- Slave AXI4 Interface
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      -- Master AXI4 Interface
      pipIbMaster     : out AxiWriteMasterType;
      pipIbSlave      : in  AxiWriteSlaveType;
      muxWriteMaster  : out AxiWriteMasterType;
      muxWriteSlave   : in  AxiWriteSlaveType);
end AxiPcieRegWriteMux;

architecture rtl of AxiPcieRegWriteMux is

   type StateType is (
      IDLE_S,
      MOVE_S);

   type RegType is record
      idx          : natural range 0 to 1;
      writeSlave   : AxiWriteSlaveType;
      writeMasters : AxiWriteMasterArray(1 downto 0);
      state        : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      idx          => 0,
      writeSlave   => AXI_WRITE_SLAVE_INIT_C,
      writeMasters => (others => AXI_WRITE_MASTER_INIT_C),
      state        => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axiRst, muxWriteSlave, pipIbSlave, r, sAxiWriteMaster) is
      variable v       : RegType;
      variable awready : sl;
      variable wready  : sl;
   begin
      -- Latch the current value
      v := r;

      -- S_AXI Handshaking
      v.writeSlave.awready := '0';
      v.writeSlave.wready  := '0';
      if (sAxiWriteMaster.bready = '1') then
         v.writeSlave.bvalid := '0';
      end if;

      -- PIP Handshaking
      if (pipIbSlave.awready = '1') then
         v.writeMasters(1).awvalid := '0';
      end if;
      if (pipIbSlave.wready = '1') then
         v.writeMasters(1).wvalid := '0';
      end if;

      -- REG Handshaking
      if (muxWriteSlave.awready = '1') then
         v.writeMasters(0).awvalid := '0';
      end if;
      if (muxWriteSlave.wready = '1') then
         v.writeMasters(0).wvalid := '0';
      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Check for access in PIP address space [0008_0000:0009_FFFF]
            if (sAxiWriteMaster.awaddr(23 downto 17) = b"0000_100") then
               v.idx := 1;
            else
               v.idx := 0;
            end if;

            -- Check if new transaction and ready for transaction
            if (sAxiWriteMaster.awvalid = '1') and (v.writeMasters(v.idx).awvalid = '0') and (v.writeSlave.bvalid = '0') then

               -- Accept the write address transaction
               v.writeSlave.awready := '1';

               -- Write address channel
               v.writeMasters(v.idx).awvalid  := sAxiWriteMaster.awvalid;
               v.writeMasters(v.idx).awaddr   := sAxiWriteMaster.awaddr;
               v.writeMasters(v.idx).awid     := sAxiWriteMaster.awid;
               v.writeMasters(v.idx).awlen    := sAxiWriteMaster.awlen;
               v.writeMasters(v.idx).awsize   := sAxiWriteMaster.awsize;
               v.writeMasters(v.idx).awburst  := sAxiWriteMaster.awburst;
               v.writeMasters(v.idx).awlock   := sAxiWriteMaster.awlock;
               v.writeMasters(v.idx).awprot   := sAxiWriteMaster.awprot;
               v.writeMasters(v.idx).awcache  := sAxiWriteMaster.awcache;
               v.writeMasters(v.idx).awqos    := sAxiWriteMaster.awqos;
               v.writeMasters(v.idx).awregion := sAxiWriteMaster.awregion;

               -- Set the response ID
               v.writeSlave.bid := sAxiWriteMaster.awid;

               -- Next state
               v.state := MOVE_S;

            end if;
         ----------------------------------------------------------------------
         when MOVE_S =>
            -- Check if new transaction and ready for transaction
            if (sAxiWriteMaster.wvalid = '1') and (v.writeMasters(r.idx).wvalid = '0') then

               -- Accept the write data transaction
               v.writeSlave.wready := '1';

               -- Write data channel
               v.writeMasters(r.idx).wdata  := sAxiWriteMaster.wdata;
               v.writeMasters(r.idx).wlast  := sAxiWriteMaster.wlast;
               v.writeMasters(r.idx).wvalid := sAxiWriteMaster.wvalid;
               v.writeMasters(r.idx).wid    := sAxiWriteMaster.wid;
               v.writeMasters(r.idx).wstrb  := sAxiWriteMaster.wstrb;

               -- Check for last AXI last transaction cycle
               if (sAxiWriteMaster.wlast = '1') then

                  -- Send the bus response
                  v.writeSlave.bvalid := '1';  -- Only posted writes

                  -- Next state
                  v.state := IDLE_S;

               end if;

            end if;
      ----------------------------------------------------------------------
      end case;

      -- S_AXI Outputs
      sAxiWriteSlave         <= r.writeSlave;
      sAxiWriteSlave.awready <= v.writeSlave.awready;
      sAxiWriteSlave.wready  <= v.writeSlave.wready;

      -- PIP Outputs
      pipIbMaster        <= r.writeMasters(1);
      pipIbMaster.bready <= pipIbSlave.bvalid;  -- Only posted writes

      -- REG Outputs
      muxWriteMaster        <= r.writeMasters(0);
      muxWriteMaster.bready <= muxWriteSlave.bvalid;  -- Only posted writes

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
