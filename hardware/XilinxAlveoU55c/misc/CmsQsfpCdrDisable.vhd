-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Used to periodically write CDR disable to the QSFP modules via AXI-Lite crossbar + CMS bridge
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

entity CmsQsfpCdrDisable is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Monitor External Software
      extSwWrDet       : in  sl;
      extSwRdDet       : in  sl;
      -- AXI-Lite Register Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType);
end CmsQsfpCdrDisable;

architecture rtl of CmsQsfpCdrDisable is

   constant PERIODIC_UPDATE_C : positive := 5;  -- Units of seconds

   constant CMS_BRIDGE_OFFSET_C : slv(31 downto 0) := x"8000_0000";

   constant TIMEOUT_1SEC_C : positive := getTimeRatio(250.0E+6, 1.0);

   type StateType is (
      IDLE_S,
      REQ_S,
      ACK_S);

   type RegType is record
      extSwDet : sl;
      armed    : sl;
      cageSel  : natural range 0 to 1;
      txnCnt   : natural range 0 to 8;
      secCnt   : natural range 0 to PERIODIC_UPDATE_C-1;
      timer    : natural range 0 to TIMEOUT_1SEC_C-1;
      req      : AxiLiteReqType;
      state    : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      extSwDet => '0',
      armed    => '0',
      cageSel  => 0,
      txnCnt   => 0,
      secCnt   => PERIODIC_UPDATE_C-1,
      timer    => TIMEOUT_1SEC_C-1,
      req      => AXI_LITE_REQ_INIT_C,
      state    => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ack : AxiLiteAckType;

   attribute dont_touch        : string;
   attribute dont_touch of r   : signal is "TRUE";
   attribute dont_touch of ack : signal is "TRUE";

begin

   U_AxiLiteMaster : entity surf.AxiLiteMaster
      generic map (
         TPD_G => TPD_G)
      port map (
         req             => r.req,
         ack             => ack,
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilWriteMaster => mAxilWriteMaster,
         axilWriteSlave  => mAxilWriteSlave,
         axilReadMaster  => mAxilReadMaster,
         axilReadSlave   => mAxilReadSlave);

   ---------------------
   -- AXI Lite Interface
   ---------------------
   comb : process (ack, axilRst, extSwRdDet, extSwWrDet, r) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Decrement the timer
      if (r.timer /= 0) then
         v.timer := r.timer -1;
      end if;

      -- Check for external software
      v.extSwDet := extSwRdDet or extSwWrDet;

      -- Check if not armed
      if (r.armed = '0') then
         v.armed := r.extSwDet;
      end if;

      -- Check if we detect external software
      if (r.extSwDet = '1') then

         -- Re-arm the timer
         v.timer := TIMEOUT_1SEC_C-1;

         -- Re-arm the counter
         v.secCnt := PERIODIC_UPDATE_C - 1;

      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset the flags
            v.req.request := '0';
            v.armed       := '0';

            -- Check for timeout
            if (r.timer = 0) then

               -- Re-arm the timer
               v.timer := TIMEOUT_1SEC_C - 1;

               -- Check for timeout
               if (r.secCnt = 0) then

                  -- Re-arm the counter
                  v.secCnt := PERIODIC_UPDATE_C - 1;

                  -- Next state
                  v.state := REQ_S;

               else

                  -- Decrement the counter
                  v.secCnt := r.secCnt - 1;

               end if;

            end if;
         ----------------------------------------------------------------------
         when REQ_S =>
            -- Check if ready for next transaction
            if (ack.done = '0') then

               -- Setup the AXI-Lite Master request
               v.req.request := '1';
               v.req.rnw     := '0';

               case (r.txnCnt) is
                  when 0 =>
                     -- self.MB_RESETN_REG.set(value=0x0, write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"0002_0000";
                     v.req.wrData  := x"0000_0000";

                  when 1 =>
                     -- self.MB_RESETN_REG.set(value=0x1, write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"0002_0000";
                     v.req.wrData  := x"0000_0001";

                  when 2 =>
                     -- self.MAILBOX.set(index=0, value=0x10000000, write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_9000";
                     v.req.wrData  := x"1000_0000";

                  when 3 =>
                     -- self.MAILBOX.set(index=1, value=cageSel,    write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_9004";
                     v.req.wrData  := toSlv(r.cageSel, 32);  -- cageSel

                  when 4 =>
                     -- self.MAILBOX.set(index=2, value=pageSel,    write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_9008";
                     v.req.wrData  := x"0000_0000";  -- pageSel

                  when 5 =>
                     -- self.MAILBOX.set(index=3, value=0,          write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_900C";
                     v.req.wrData  := x"0000_0000";  -- Extended I2C Addressing

                  when 6 =>
                     -- self.MAILBOX.set(index=4, value=wordSel,    write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_9010";
                     v.req.wrData  := toSlv(98, 32);  -- Tx and Rx CDR Controls register

                  when 7 =>
                     -- self.MAILBOX.set(index=5, value=data,       write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_9014";
                     v.req.wrData  := x"0000_0000";  -- Turn off all the TX and RX CDR channels

                  when 8 =>
                     -- self.CONTROL_REG[5].set(value=0x1, write=True)
                     v.req.address := CMS_BRIDGE_OFFSET_C + x"002_8018";
                     v.req.wrData  := x"0000_0020";  -- Set to 1 by host to indicate new message present in Mailbox

               end case;

               -- Next state
               v.state := ACK_S;

            end if;
         ----------------------------------------------------------------------
         when ACK_S =>
            -- Wait for DONE to set
            if (ack.done = '1') then

               -- Reset the flag
               v.req.request := '0';

               -- Re-arm the timer
               v.timer := TIMEOUT_1SEC_C-1;

               -- Re-arm the counter
               v.secCnt := PERIODIC_UPDATE_C - 1;

               -- Check if this was last channel or external SW detected
               if (r.txnCnt = 8) or (r.armed = '1') then

                  -- Preset the counter
                  v.txnCnt := 2;

                  -- Toggle the cage select
                  if r.cageSel = 0 then
                     v.cageSel := 1;
                  else
                     v.cageSel := 0;
                  end if;

                  -- Next state
                  v.state := IDLE_S;

               else

                  -- Increment the counter
                  v.txnCnt := r.txnCnt + 1;

                  -- Check for MB_RESETN_REG
                  if (r.txnCnt = 0) or (r.txnCnt = 1) then
                     -- Next state
                     v.state := IDLE_S;
                  else
                     -- Next state
                     v.state := REQ_S;
                  end if;

               end if;

            end if;
      ----------------------------------------------------------------------
      end case;

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
