-------------------------------------------------------------------------------
-- File       : AxiPcieBpiFlash.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-08-19
-- Last update: 2014-07-08
-------------------------------------------------------------------------------
-- Description:
-- This controller is designed around the PC28F00AP30TFA FLASH IC.
-- I assume that the address's MSB is dedicated to the FPGA's RS0 pin
--
-- Write Only Registers:
-- Addr 0 : Bits[31:16] = wr_data(1) // opCode
--          Bits[15:00] = wr_data(0) // data
--
-- Addr 1 : Bits[31]    = RnW bit
--          Bits[30:23] = unused
--          Bits[25:00] = address bus
--
-- Read Only Registers:
-- Addr 0 : Bits[31:16] = wr_data(1) // opCode
--          Bits[15:00] = wr_data(0) // data
--
-- Addr 1 : Bits[31:23] = zeros
--          Bits[25:00] = address bus
--
-- Addr 2 : Bits[31:16] = zeros
--          Bits[15:00] = rd_data
--
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

library unisim;
use unisim.vcomponents.all;

entity AxiPcieBpiFlash is
   port (
      -- FLASH Interface 
      flashAddr : out   slv(25 downto 0);
      -- flashData : inout slv(15 downto 0);
      flashAdv  : out   sl;
      flashCe   : out   sl;
      flashOe   : out   sl;
      flashWe   : out   sl;
      flashTri  : out sl;
      flashDin  : out slv(15 downto 0);
      flashDout : in  slv(15 downto 0);      
      -- Register Interface
      regCs     : in    sl;
      regAddr   : in    slv(9 downto 2);
      regWrEn   : in    sl;
      regWrData : in    slv(31 downto 0);
      regRdEn   : in    sl;
      regRdData : out   slv(31 downto 0);
      regBusy   : out   sl;
      --Global Signals
      pciClk    : in    sl;             --125 MHz
      pciRst    : in    sl); 
end AxiPcieBpiFlash;

architecture rtl of AxiPcieBpiFlash is

   type DataArray is array (0 to 1) of slv(15 downto 0);

   type stateType is (
      IDLE_S,
      CMD_LOW_S,
      CMD_HIGH_S,
      WAIT_S,
      DATA_LOW_S,
      DATA_HIGH_S);
   signal state : stateType := IDLE_S;
   signal tristate,
      cclk,
      ce,
      oe,
      RnW,
      busy,
      we : sl := '1';
   signal cnt : slv(3 downto 0) := (others => '0');
   signal din,
      dout,
      dataReg : slv(15 downto 0) := (others => '0');
   signal addr   : slv(25 downto 0) := (others => '0');
   signal rdData : slv(31 downto 0) := (others => '0');
   signal wrData : DataArray;
   
begin

   flashAddr <= addr;
   flashAdv  <= '0';
   flashCe   <= ce;
   flashOe   <= oe;
   flashWe   <= we;
   regBusy   <= busy;
   
   flashTri <= tristate;
   flashDin <= din;
   dout     <= flashDout;

   -- GEN_IOBUF :
   -- for i in 15 downto 0 generate
      -- IOBUF_inst : IOBUF
         -- port map (
            -- O  => dout(i),              -- Buffer output
            -- IO => flashData(i),         -- Buffer inout port (connect directly to top-level port)
            -- I  => din(i),               -- Buffer input
            -- T  => tristate);            -- 3-state enable input, high=input, low=output     
   -- end generate GEN_IOBUF;

   -----------------------------
   -- Register Writes
   -----------------------------
   process (pciClk)
   begin
      if rising_edge(pciClk) then
         if pciRst = '1' then
            ce       <= '1';
            oe       <= '1';
            we       <= '1';
            RnW      <= '1';
            tristate <= '1';
            din      <= (others => '0');
            dataReg  <= (others => '0');
            wrData   <= (others => (others => '0'));
            addr     <= (others => '0');
            cnt      <= (others => '0');
            busy     <= '0';
            state    <= IDLE_S;
         else
            case state is
               ----------------------------------------------------------------------
               when IDLE_S =>
                  busy     <= '0';
                  ce       <= '1';
                  oe       <= '1';
                  we       <= '1';
                  tristate <= '1';
                  if regWrEn = '1' and regCs = '1' then
                     busy <= '1';
                     if regAddr = 0 then
                        --set the write data bus
                        wrData(1) <= regWrData(31 downto 16);
                        wrData(0) <= regWrData(15 downto 0);
                     elsif regAddr = 1 then
                        -- Set the RnW
                        RnW   <= regWrData(31);
                        -- Set the address bus
                        addr  <= regWrData(25 downto 0);
                        -- Next state
                        state <= CMD_LOW_S;
                     end if;
                  end if;
               ----------------------------------------------------------------------
               when CMD_LOW_S =>
                  ce       <= '0';
                  oe       <= '1';
                  we       <= '0';
                  tristate <= '0';
                  din      <= wrData(1);
                  -- Increment the counter
                  cnt      <= cnt + 1;
                  -- Check the counter 
                  if cnt = x"F" then
                     -- Reset the counter
                     cnt   <= (others => '0');
                     -- Next state
                     state <= CMD_HIGH_S;
                  end if;
               ----------------------------------------------------------------------
               when CMD_HIGH_S =>
                  ce       <= '1';
                  oe       <= '1';
                  we       <= '1';
                  tristate <= '0';
                  din      <= wrData(1);
                  -- Increment the counter
                  cnt      <= cnt + 1;
                  -- Check the counter 
                  if cnt = x"F" then
                     -- Reset the counter
                     cnt   <= (others => '0');
                     -- Next state
                     state <= WAIT_S;
                  end if;
               ----------------------------------------------------------------------
               when WAIT_S =>
                  ce       <= '1';
                  oe       <= '1';
                  we       <= '1';
                  tristate <= '1';
                  din      <= wrData(0);
                  -- Increment the counter
                  cnt      <= cnt + 1;
                  -- Check the counter 
                  if cnt = x"F" then
                     -- Reset the counter
                     cnt   <= (others => '0');
                     -- Next state
                     state <= DATA_LOW_S;
                  end if;
               ----------------------------------------------------------------------
               when DATA_LOW_S =>
                  ce       <= '0';
                  oe       <= not(RnW);
                  we       <= RnW;
                  tristate <= RnW;
                  din      <= wrData(0);
                  -- Increment the counter
                  cnt      <= cnt + 1;
                  -- Check the counter 
                  if cnt = x"F" then
                     -- Reset the counter
                     cnt     <= (others => '0');
                     --latch the data bus value
                     dataReg <= dout;
                     -- Next state
                     state   <= DATA_HIGH_S;
                  end if;
               ----------------------------------------------------------------------
               when DATA_HIGH_S =>
                  ce       <= '1';
                  oe       <= '1';
                  we       <= '1';
                  tristate <= RnW;
                  din      <= wrData(0);
                  -- Increment the counter
                  cnt      <= cnt + 1;
                  -- Check the counter 
                  if cnt = x"F" then
                     -- Reset the counter
                     cnt   <= (others => '0');
                     -- Next state
                     state <= IDLE_S;
                  end if;
            ----------------------------------------------------------------------
            end case;
         end if;
      end if;
   end process;

   -----------------------------
   -- Register Reads
   -----------------------------
   process (pciClk)
   begin
      if rising_edge(pciClk) then
         if pciRst = '1' then
            regRdData <= (others => '0');
         else
            -- Register Read
            if regRdEn = '1' and regCs = '1' then
               regRdData <= (others => '0');
               if regAddr = 0 then
                  --get the write data bus
                  regRdData(15 downto 0) <= din;
               elsif regAddr = 1 then
                  --get the address bus
                  regRdData(25 downto 0) <= addr;
               elsif regAddr = 2 then
                  --get the read data bus
                  regRdData(15 downto 0) <= dataReg;
               else
                  regRdData <= (others => '1');
               end if;
            end if;
         end if;
      end if;
   end process;
   
end rtl;
