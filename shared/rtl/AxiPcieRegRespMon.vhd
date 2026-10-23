-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Counts AXI-Lite error responses on a monitored interface
-------------------------------------------------------------------------------
-- BAR0 masks slave error responses to OK (AxiToAxiLite EN_SLAVE_RESP_G=false)
-- so error completions cannot reach the PCIe host. This module watches one
-- crossbar slot without driving it, counts reads and writes that respond
-- with an error, and keeps the BAR0 address and response code of the last
-- failure, so software can check a sequence of non-proxy I2C accesses.
--
-- Register map:
--    0x00 RdErrCnt  (RO): reads with rresp /= OK
--    0x04 WrErrCnt  (RO): writes with bresp /= OK
--    0x08 RdErrAddr (RO): address of the last failing read
--    0x0C WrErrAddr (RO): address of the last failing write
--    0x10 ErrResp   (RO): [1:0] last failing rresp, [9:8] last failing bresp
--    0x14 CntRst    (WO): any write clears all of the above
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

entity AxiPcieRegRespMon is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      axilClk         : in  sl;
      axilRst         : in  sl;
      -- Monitored AXI-Lite Interface (inputs only)
      monReadMaster   : in  AxiLiteReadMasterType;
      monReadSlave    : in  AxiLiteReadSlaveType;
      monWriteMaster  : in  AxiLiteWriteMasterType;
      monWriteSlave   : in  AxiLiteWriteSlaveType;
      -- Register Interface
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end AxiPcieRegRespMon;

architecture rtl of AxiPcieRegRespMon is

   type RegType is record
      rdAddr         : slv(31 downto 0);
      wrAddr         : slv(31 downto 0);
      rdErrCnt       : slv(31 downto 0);
      wrErrCnt       : slv(31 downto 0);
      rdErrAddr      : slv(31 downto 0);
      wrErrAddr      : slv(31 downto 0);
      rdErrResp      : slv(1 downto 0);
      wrErrResp      : slv(1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rdAddr         => (others => '0'),
      wrAddr         => (others => '0'),
      rdErrCnt       => (others => '0'),
      wrErrCnt       => (others => '0'),
      rdErrAddr      => (others => '0'),
      wrErrAddr      => (others => '0'),
      rdErrResp      => (others => '0'),
      wrErrResp      => (others => '0'),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axilReadMaster, axilRst, axilWriteMaster, monReadMaster,
                   monReadSlave, monWriteMaster, monWriteSlave, r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
      variable cntRst : sl;
   begin
      -- Latch the current value
      v := r;

      -- Track the address of the transaction in flight on each channel
      if (monReadMaster.arvalid = '1') and (monReadSlave.arready = '1') then
         v.rdAddr := monReadMaster.araddr;
      end if;
      if (monWriteMaster.awvalid = '1') and (monWriteSlave.awready = '1') then
         v.wrAddr := monWriteMaster.awaddr;
      end if;

      -- Record error responses
      if (monReadSlave.rvalid = '1') and (monReadMaster.rready = '1') and (monReadSlave.rresp /= AXI_RESP_OK_C) then
         v.rdErrCnt  := r.rdErrCnt + 1;
         v.rdErrAddr := v.rdAddr;
         v.rdErrResp := monReadSlave.rresp;
      end if;
      if (monWriteSlave.bvalid = '1') and (monWriteMaster.bready = '1') and (monWriteSlave.bresp /= AXI_RESP_OK_C) then
         v.wrErrCnt  := r.wrErrCnt + 1;
         v.wrErrAddr := v.wrAddr;
         v.wrErrResp := monWriteSlave.bresp;
      end if;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the registers
      axiSlaveRegisterR(axilEp, x"00", 0, r.rdErrCnt);
      axiSlaveRegisterR(axilEp, x"04", 0, r.wrErrCnt);
      axiSlaveRegisterR(axilEp, x"08", 0, r.rdErrAddr);
      axiSlaveRegisterR(axilEp, x"0C", 0, r.wrErrAddr);
      axiSlaveRegisterR(axilEp, x"10", 0, r.rdErrResp);
      axiSlaveRegisterR(axilEp, x"10", 8, r.wrErrResp);
      cntRst := '0';
      axiWrDetect(axilEp, x"14", cntRst);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Clear the counters and the last-error record
      if (cntRst = '1') then
         v.rdErrCnt  := (others => '0');
         v.wrErrCnt  := (others => '0');
         v.rdErrAddr := (others => '0');
         v.wrErrAddr := (others => '0');
         v.rdErrResp := (others => '0');
         v.wrErrResp := (others => '0');
      end if;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;

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
