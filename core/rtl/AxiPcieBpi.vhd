-------------------------------------------------------------------------------
-- File       : AxiPcieBpi.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-24
-- Last update: 2017-03-24
-------------------------------------------------------------------------------
-- Description: Wrapper for AxiPcieBpiFlash
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity AxiPcieBpi is
   generic (
      TPD_G            : time            := 1 ns;
      AXI_CLK_FREQ_G   : real            := 125.0E+6;  -- units of Hz
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_SLVERR_C);
   port (
      -- FLASH Interface 
      flashAddr      : out slv(30 downto 0);
      flashAdv       : out sl;
      flashClk       : out sl;
      flashRstL      : out sl;
      flashCeL       : out sl;
      flashOeL       : out sl;
      flashWeL       : out sl;
      flashTri       : out sl;
      flashDin       : out slv(15 downto 0);
      flashDout      : in  slv(15 downto 0);
      -- AXI-Lite Register Interface
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;
      -- Clocks and Resets
      axiClk         : in  sl;
      axiRst         : in  sl);
end AxiPcieBpi;

architecture rtl of AxiPcieBpi is

   type stateType is (
      IDLE_S,
      WAIT_S);

   type RegType is record
      cnt           : natural range 0 to 3;
      regCs         : sl;
      regAddr       : slv(9 downto 2);
      regWrEn       : sl;
      regWrData     : slv(31 downto 0);
      regRdEn       : sl;
      axiReadSlave  : AxiLiteReadSlaveType;
      axiWriteSlave : AxiLiteWriteSlaveType;
      state         : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      cnt           => 0,
      regCs         => '0',
      regAddr       => (others => '0'),
      regWrEn       => '0',
      regWrData     => (others => '0'),
      regRdEn       => '0',
      axiReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
      state         => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal address   : slv(25 downto 0);
   signal regRdData : slv(31 downto 0);
   signal regBusy   : sl;

begin

   flashAddr(25 downto 0)  <= address;
   flashAddr(30 downto 26) <= (others => '0');

   U_AxiPcieBpiFlash : entity work.AxiPcieBpiFlash
      port map (
         -- FLASH Interface 
         flashAddr => address,
         flashAdv  => flashAdv,
         flashCe   => flashCeL,
         flashOe   => flashOeL,
         flashWe   => flashWeL,
         flashDin  => flashDin,
         flashDout => flashDout,
         flashTri  => flashTri,
         -- Register Interface
         regCs     => r.regCs,
         regAddr   => r.regAddr,
         regWrEn   => r.regWrEn,
         regWrData => r.regWrData,
         regRdEn   => r.regRdEn,
         regRdData => regRdData,
         regBusy   => regBusy,
         --Global Signals
         pciClk    => axiClk,
         pciRst    => axiRst);

   comb : process (axiReadMaster, axiRst, axiWriteMaster, r, regBusy,
                   regRdData) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      -- Latch the current value
      v := r;

      -- Determine the transaction type
      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset the flags
            v.regCs   := '0';
            v.regRdEn := '0';
            v.regWrEn := '0';
            -- Check if module is not busy
            if (regBusy = '0') then
               -- Check for a read request            
               if (axiStatus.readEnable = '1') then
                  -- Update the address bus
                  v.regAddr := axiReadMaster.araddr(9 downto 2);
                  -- Set the flags
                  v.regCs   := '1';
                  v.regRdEn := '1';
                  -- Next state
                  v.state   := WAIT_S;
               -- Check for a write request
               elsif (axiStatus.writeEnable = '1') then
                  -- Update the address bus
                  v.regAddr   := axiWriteMaster.awaddr(9 downto 2);
                  -- Set the flags
                  v.regCs     := '1';
                  v.regWrEn   := '1';
                  -- Update the data bus
                  v.regWrData := axiWriteMaster.wdata;
                  -- Send AXI-Lite response
                  axiSlaveWriteResponse(v.axiWriteSlave, AXI_RESP_OK_C);
               end if;
            end if;
         ----------------------------------------------------------------------
         when WAIT_S =>
            -- Check the counter
            if (r.cnt = 3) then         -- not optimized and conservative value
               -- Reset the counter
               v.cnt                := 0;
               -- Update the AXI-lite read bus
               v.axiReadSlave.rdata := regRdData;
               -- Send AXI-Lite Response
               axiSlaveReadResponse(v.axiReadSlave, AXI_RESP_OK_C);
               -- Next state
               v.state              := IDLE_S;
            else
               -- Increment the counter
               v.cnt := r.cnt + 1;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Synchronous Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      flashClk      <= '1';
      flashRstL     <= not(axiRst);

   end process comb;

   seq : process (axiClk) is
   begin
      if rising_edge(axiClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
