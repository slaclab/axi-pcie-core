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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiPciePkg.all;

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
      ADDR_S,
      DATA_S);

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
      state        => ADDR_S);

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
         when ADDR_S =>
            -- Check for access in PIP address space [0008_0000:0008_FFFF]
            if (sAxiWriteMaster.awaddr(23 downto 16) = x"08") then
               v.idx := 1;
            else
               v.idx := 0;
            end if;

            -- Check for address valid and bus response completed
            if (sAxiWriteMaster.awvalid = '1') and (v.writeMasters(v.idx).awvalid = '0') and (v.writeSlave.bvalid = '0') then

               -- Accept the transaction
               v.writeSlave.awready := '1';

               -- Forward the data
               v.writeMasters(v.idx) := sAxiWriteMaster;

               -- Set the response ID
               v.writeSlave.bid := sAxiWriteMaster.awid;

               -- Check for data with address valid cycle
               if (sAxiWriteMaster.wvalid = '1') then

                  -- Accept the transaction
                  v.writeSlave.wready := '1';

                  -- Check for last AXI last transaction cycle
                  if (sAxiWriteMaster.wlast = '1') then
                     -- Send the bus response
                     v.writeSlave.bvalid := '1';
                  else
                     -- Next state
                     v.state := DATA_S;
                  end if;

               else
                  -- Next state
                  v.state := DATA_S;
               end if;

            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            -- Check for address valid
            if (sAxiWriteMaster.wvalid = '1') and (v.writeMasters(r.idx).wvalid = '0') then

               -- Accept the transaction
               v.writeSlave.wready := '1';

               -- Forward the data
               v.writeMasters(r.idx) := sAxiWriteMaster;

               -- Check for last AXI last transaction cycle
               if (sAxiWriteMaster.wlast = '1') then

                  -- Send the bus response
                  v.writeSlave.bvalid := '1';

                  -- Next state
                  v.state := ADDR_S;

               end if;

            end if;
      ----------------------------------------------------------------------
      end case;

      -- Ignoring the bus response
      v.writeMasters(1).bready := '1';
      v.writeMasters(0).bready := '1';

      -- Outputs
      sAxiWriteSlave         <= r.writeSlave;
      sAxiWriteSlave.awready <= v.writeSlave.awready;
      sAxiWriteSlave.wready  <= v.writeSlave.wready;
      pipIbMaster            <= r.writeMasters(1);
      muxWriteMaster         <= r.writeMasters(0);

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
