-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: One-shot AXI-Lite initializer for the QSFP-GPIO PCA9555 on the
--              BittWare XUP-VV8. At reset release, writes the Output, Polarity
--              Inversion, and Configuration byte registers of the PCA9555 to
--              put the four QSFP-DD slots into a known state:
--                 OP  (regs 0x02/0x03) = 0x88  -- LP=0, RST_L=1 for each nibble
--                 POL (regs 0x04/0x05) = 0x00  -- no inversion
--                 CFG (regs 0x06/0x07) = 0x33  -- PRSNT_L/INT_L=input,
--                                              -- LP/RST_L=output
--
--              Output Port is written before Configuration so LP[i] never
--              briefly drives '1' (low-power asserted) during the moment the
--              direction bits flip from input (PCA9555 power-up default) to
--              output. The PCA9555 OP register defaults to 0xFF on power-up.
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

entity BittWareXupVv8QsfpInit is
   generic (
      TPD_G           : time             := 1 ns;
      -- AXI-Lite base address of the QSFP-GPIO PCA9555 device.
      PCA9555_ADDR_G  : slv(31 downto 0) := x"0007_3000";
      AXIL_CLK_FREQ_G : real             := 250.0E+6);
   port (
      -- AXI-Lite Master Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType);
end BittWareXupVv8QsfpInit;

architecture rtl of BittWareXupVv8QsfpInit is

   -- 1 ms settling delay before the first I2C transaction.
   constant SETTLE_DELAY_C : positive := getTimeRatio(AXIL_CLK_FREQ_G, 1000.0);

   -- PCA9555 byte-register offsets, AXI-Lite-word-aligned (reg << 2).
   constant ADDR_OP0_C  : slv(31 downto 0) := x"0000_0008";  -- Output Port 0
   constant ADDR_OP1_C  : slv(31 downto 0) := x"0000_000C";  -- Output Port 1
   constant ADDR_POL0_C : slv(31 downto 0) := x"0000_0010";  -- Polarity Inv 0
   constant ADDR_POL1_C : slv(31 downto 0) := x"0000_0014";  -- Polarity Inv 1
   constant ADDR_CFG0_C : slv(31 downto 0) := x"0000_0018";  -- Configuration 0
   constant ADDR_CFG1_C : slv(31 downto 0) := x"0000_001C";  -- Configuration 1

   type StateType is (
      REQ_S,
      ACK_S,
      DONE_S);

   type RegType is record
      cnt   : natural range 0 to 5;
      timer : natural range 0 to SETTLE_DELAY_C;
      req   : AxiLiteReqType;
      state : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      cnt   => 0,
      timer => SETTLE_DELAY_C,
      req   => AXI_LITE_REQ_INIT_C,
      state => REQ_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ack : AxiLiteAckType;

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
   comb : process (ack, axilRst, r) is
      variable v : RegType;
   begin
      v := r;

      -- Decrement the settling timer
      if (r.timer /= 0) then
         v.timer := r.timer - 1;
      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when REQ_S =>
            if (ack.done = '0') and (r.timer = 0) then

               v.req.request := '1';
               v.req.rnw     := '0';        -- write

               case r.cnt is
                  when 0 =>  -- OP_PORT_0 = 0x88  (LP=0, RST_L=1; write OP before CFG)
                     v.req.address := PCA9555_ADDR_G + ADDR_OP0_C;
                     v.req.wrData  := x"0000_0088";
                  when 1 =>  -- OP_PORT_1 = 0x88
                     v.req.address := PCA9555_ADDR_G + ADDR_OP1_C;
                     v.req.wrData  := x"0000_0088";
                  when 2 =>  -- POL_PORT_0 = 0x00  (no inversion)
                     v.req.address := PCA9555_ADDR_G + ADDR_POL0_C;
                     v.req.wrData  := x"0000_0000";
                  when 3 =>  -- POL_PORT_1 = 0x00
                     v.req.address := PCA9555_ADDR_G + ADDR_POL1_C;
                     v.req.wrData  := x"0000_0000";
                  when 4 =>  -- CFG_PORT_0 = 0x33  (PRSNT_L/INT_L=in, LP/RST_L=out)
                     v.req.address := PCA9555_ADDR_G + ADDR_CFG0_C;
                     v.req.wrData  := x"0000_0033";
                  when others =>  -- 5: CFG_PORT_1 = 0x33
                     v.req.address := PCA9555_ADDR_G + ADDR_CFG1_C;
                     v.req.wrData  := x"0000_0033";
               end case;

               v.state := ACK_S;
            end if;
         ----------------------------------------------------------------------
         when ACK_S =>
            if (ack.done = '1') then

               v.req.request := '0';

               if (r.cnt = 5) then
                  v.state := DONE_S;
               else
                  v.cnt   := r.cnt + 1;
                  v.state := REQ_S;
               end if;

            end if;
         ----------------------------------------------------------------------
         when DONE_S =>
            -- One-shot init complete; remain here until next axilRst.
            v.timer := 0;
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
