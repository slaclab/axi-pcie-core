-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Keeps BAR0 AXI-Lite reads from passing earlier writes
-------------------------------------------------------------------------------
-- AXI-Lite read and write channels are independent, so a read can reach a
-- fast slave while an earlier (PCIe posted) write is still stalled behind a
-- slow slave, such as an I2C device on the non-proxy path, and return stale
-- data. PCIe ordering does not allow a read to pass a posted write. This
-- module holds a new read until no write is pending or outstanding, and for
-- RD_HOLDOFF_G more cycles after the last write response so a posted write
-- that the bridge presents a few cycles later is not overtaken. Once a read is
-- presented to the crossbar it stays presented until accepted. Writes always
-- pass through unchanged.
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
use surf.AxiLitePkg.all;

entity AxiPcieRegReadOrder is
   generic (
      TPD_G        : time    := 1 ns;
      RD_HOLDOFF_G : natural := 16);  -- cycles a new read waits after a write response
   port (
      -- Clock and Reset
      axilClk          : in  sl;
      axilRst          : in  sl;
      -- Slave AXI-Lite Interface
      sAxilReadMaster  : in  AxiLiteReadMasterType;
      sAxilReadSlave   : out AxiLiteReadSlaveType;
      sAxilWriteMaster : in  AxiLiteWriteMasterType;
      sAxilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Master AXI-Lite Interface
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType);
end AxiPcieRegReadOrder;

architecture rtl of AxiPcieRegReadOrder is

   type RegType is record
      wrCnt   : slv(3 downto 0);
      holdCnt : natural range 0 to RD_HOLDOFF_G;
      rdOpen  : sl;
   end record;

   constant REG_INIT_C : RegType := (
      wrCnt   => (others => '0'),
      holdCnt => 0,
      rdOpen  => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axilRst, mAxilReadSlave, mAxilWriteSlave, r,
                   sAxilReadMaster, sAxilWriteMaster) is
      variable v        : RegType;
      variable rdAllow  : sl;
      variable rdMaster : AxiLiteReadMasterType;
      variable rdSlave  : AxiLiteReadSlaveType;
   begin
      -- Latch the current value
      v := r;

      -- Count writes accepted by the crossbar that have not responded yet
      if (sAxilWriteMaster.awvalid = '1') and (mAxilWriteSlave.awready = '1') then
         v.wrCnt := v.wrCnt + 1;
      end if;
      if (mAxilWriteSlave.bvalid = '1') and (sAxilWriteMaster.bready = '1') then
         v.wrCnt   := v.wrCnt - 1;
         v.holdCnt := RD_HOLDOFF_G;
      elsif (r.holdCnt /= 0) then
         v.holdCnt := r.holdCnt - 1;
      end if;

      -- Start a new read only when no write is pending, outstanding or just completed
      if (r.rdOpen = '1') or ((r.wrCnt = 0) and (r.holdCnt = 0) and
                              (sAxilWriteMaster.awvalid = '0') and (sAxilWriteMaster.wvalid = '0')) then
         rdAllow := '1';
      else
         rdAllow := '0';
      end if;

      -- Gate the read address handshake
      rdMaster         := sAxilReadMaster;
      rdMaster.arvalid := sAxilReadMaster.arvalid and rdAllow;
      rdSlave          := mAxilReadSlave;
      rdSlave.arready  := mAxilReadSlave.arready and rdAllow;

      -- Keep a presented read presented until it is accepted
      v.rdOpen := rdMaster.arvalid and not(mAxilReadSlave.arready);

      -- Outputs
      mAxilReadMaster  <= rdMaster;
      sAxilReadSlave   <= rdSlave;
      mAxilWriteMaster <= sAxilWriteMaster;
      sAxilWriteSlave  <= mAxilWriteSlave;

      -- Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
