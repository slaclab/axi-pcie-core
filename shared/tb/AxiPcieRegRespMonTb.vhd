-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation testbench for AxiPcieRegRespMon
-------------------------------------------------------------------------------
-- Drives the monitored channel with OK and error responses on reads and
-- writes, then checks the counters, the last failing address and response
-- code through the register interface, and that CntRst clears them.
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
use surf.TextUtilPkg.all;

library axi_pcie_core;

entity AxiPcieRegRespMonTb is end AxiPcieRegRespMonTb;

architecture testbed of AxiPcieRegRespMonTb is

   constant TPD_G        : time := 1 ns;
   constant CLK_PERIOD_C : time := 4 ns;

   signal clk : sl := '0';
   signal rst : sl := '1';

   signal monRdMaster : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal monRdSlave  : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
   signal monWrMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal monWrSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;

   signal regRdMaster : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal regRdSlave  : AxiLiteReadSlaveType;
   signal regWrMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal regWrSlave  : AxiLiteWriteSlaveType;

   signal passed : boolean := false;

begin

   clk <= not clk after CLK_PERIOD_C/2;

   U_DUT : entity axi_pcie_core.AxiPcieRegRespMon
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk         => clk,
         axilRst         => rst,
         monReadMaster   => monRdMaster,
         monReadSlave    => monRdSlave,
         monWriteMaster  => monWrMaster,
         monWriteSlave   => monWrSlave,
         axilReadMaster  => regRdMaster,
         axilReadSlave   => regRdSlave,
         axilWriteMaster => regWrMaster,
         axilWriteSlave  => regWrSlave);

   TEST : process is

      procedure cycles(n : natural) is
      begin
         for i in 1 to n loop
            wait until rising_edge(clk);
         end loop;
      end procedure;

      -- One monitored read: address handshake, then a response with resp
      procedure monRead(addr : slv(31 downto 0); resp : slv(1 downto 0)) is
      begin
         monRdMaster.araddr  <= addr after TPD_G;
         monRdMaster.arvalid <= '1' after TPD_G;
         monRdSlave.arready  <= '1' after TPD_G;
         cycles(1);
         monRdMaster.arvalid <= '0' after TPD_G;
         monRdSlave.arready  <= '0' after TPD_G;
         cycles(3);
         monRdSlave.rresp    <= resp after TPD_G;
         monRdSlave.rvalid   <= '1' after TPD_G;
         monRdMaster.rready  <= '1' after TPD_G;
         cycles(1);
         monRdSlave.rvalid   <= '0' after TPD_G;
         monRdMaster.rready  <= '0' after TPD_G;
         cycles(2);
      end procedure;

      procedure monWrite(addr : slv(31 downto 0); resp : slv(1 downto 0)) is
      begin
         monWrMaster.awaddr  <= addr after TPD_G;
         monWrMaster.awvalid <= '1' after TPD_G;
         monWrSlave.awready  <= '1' after TPD_G;
         cycles(1);
         monWrMaster.awvalid <= '0' after TPD_G;
         monWrSlave.awready  <= '0' after TPD_G;
         cycles(3);
         monWrSlave.bresp    <= resp after TPD_G;
         monWrSlave.bvalid   <= '1' after TPD_G;
         monWrMaster.bready  <= '1' after TPD_G;
         cycles(1);
         monWrSlave.bvalid   <= '0' after TPD_G;
         monWrMaster.bready  <= '0' after TPD_G;
         cycles(2);
      end procedure;

      procedure regRead(addr : slv(31 downto 0); data : out slv(31 downto 0)) is
      begin
         regRdMaster.araddr  <= addr after TPD_G;
         regRdMaster.arvalid <= '1' after TPD_G;
         regRdMaster.rready  <= '1' after TPD_G;
         loop
            wait until rising_edge(clk);
            if (regRdSlave.arready = '1') then
               regRdMaster.arvalid <= '0' after TPD_G;
            end if;
            exit when regRdSlave.rvalid = '1';
         end loop;
         data := regRdSlave.rdata;
         regRdMaster.rready <= '0' after TPD_G;
         cycles(1);
      end procedure;

      procedure regWrite(addr : slv(31 downto 0); data : slv(31 downto 0)) is
      begin
         regWrMaster.awaddr  <= addr after TPD_G;
         regWrMaster.wdata   <= data after TPD_G;
         regWrMaster.wstrb   <= x"F" after TPD_G;
         regWrMaster.awvalid <= '1' after TPD_G;
         regWrMaster.wvalid  <= '1' after TPD_G;
         regWrMaster.bready  <= '1' after TPD_G;
         loop
            wait until rising_edge(clk);
            if (regWrSlave.awready = '1') then
               regWrMaster.awvalid <= '0' after TPD_G;
               regWrMaster.wvalid  <= '0' after TPD_G;
            end if;
            exit when regWrSlave.bvalid = '1';
         end loop;
         regWrMaster.bready <= '0' after TPD_G;
         cycles(1);
      end procedure;

      procedure check(addr : slv(31 downto 0); expected : slv(31 downto 0); what : string) is
         variable data : slv(31 downto 0);
      begin
         regRead(addr, data);
         assert (data = expected)
            report "AxiPcieRegRespMonTb: " & what & " = 0x" & hstr(data) & ", expected 0x" & hstr(expected)
            severity failure;
      end procedure;

   begin
      cycles(10);
      rst <= '0' after TPD_G;
      cycles(5);

      monRead(x"0007_A01C", AXI_RESP_OK_C);
      monRead(x"0007_8000", AXI_RESP_DECERR_C);
      monRead(x"0007_A030", AXI_RESP_OK_C);
      monRead(x"0007_A020", AXI_RESP_SLVERR_C);
      monWrite(x"0007_A224", AXI_RESP_OK_C);
      monWrite(x"0007_A21C", AXI_RESP_SLVERR_C);

      check(x"0000_0000", x"0000_0002", "RdErrCnt");
      check(x"0000_0004", x"0000_0001", "WrErrCnt");
      check(x"0000_0008", x"0007_A020", "RdErrAddr");
      check(x"0000_000C", x"0007_A21C", "WrErrAddr");
      check(x"0000_0010", x"0000_0202", "ErrResp");

      regWrite(x"0000_0014", x"0000_0001");
      check(x"0000_0000", x"0000_0000", "RdErrCnt after CntRst");
      check(x"0000_0004", x"0000_0000", "WrErrCnt after CntRst");
      check(x"0000_0010", x"0000_0000", "ErrResp after CntRst");

      passed <= true;
      report "AxiPcieRegRespMonTb: PASSED" severity note;
      wait;
   end process TEST;

   TIMEOUT : process is
   begin
      wait for 20 us;
      assert passed report "AxiPcieRegRespMonTb: TIMEOUT" severity failure;
      std.env.stop;
      wait;
   end process TIMEOUT;

end testbed;
