-------------------------------------------------------------------------------
-- File       : AdmPcieKu3Mig0Empty.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2017-04-08
-------------------------------------------------------------------------------
-- Description: Wrapper for the MIG core
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AdmPcieKu3Mig0 is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- System Clock and reset
      sysClk          : in    sl;
      sysRst          : in    sl;
      -- AXI MEM Interface (axiClk domain)
      axiClk          : out   sl;
      axiRst          : out   sl;
      axiWriteMaster  : in    AxiWriteMasterType;
      axiWriteSlave   : out   AxiWriteSlaveType;
      axiReadMaster   : in    AxiReadMasterType;
      axiReadSlave    : out   AxiReadSlaveType;
      -- Optional AXI-Lite Interface (sysClk domain)
      axilReadMaster  : in    AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- DDR3 SO-DIMM Ports
      ddrClkP         : in    sl;
      ddrClkN         : in    sl;
      ddrDqsP         : inout slv(8 downto 0);
      ddrDqsN         : inout slv(8 downto 0);
      ddrDq           : inout slv(71 downto 0);
      ddrA            : out   slv(15 downto 0);
      ddrBa           : out   slv(2 downto 0);
      ddrCsL          : out   slv(1 downto 0);
      ddrOdt          : out   slv(1 downto 0);
      ddrCke          : out   slv(1 downto 0);
      ddrCkP          : out   slv(1 downto 0);
      ddrCkN          : out   slv(1 downto 0);
      ddrWeL          : out   sl;
      ddrRasL         : out   sl;
      ddrCasL         : out   sl;
      ddrRstL         : out   sl);
end AdmPcieKu3Mig0;

architecture mapping of AdmPcieKu3Mig0 is

begin

   axiClk        <= '0';
   axiRst        <= '1';
   axiWriteSlave <= AXI_WRITE_SLAVE_FORCE_C;
   axiReadSlave  <= AXI_READ_SLAVE_FORCE_C;

   ddrA    <= (others => '0');
   ddrBa   <= (others => '0');
   ddrCsL  <= (others => '1');          -- active LOW
   ddrOdt  <= (others => '0');
   ddrCke  <= (others => '0');
   ddrCkP  <= (others => '0');
   ddrCkN  <= (others => '0');
   ddrWeL  <= '1';                      -- active LOW
   ddrRasL <= '1';                      -- active LOW
   ddrCasL <= '1';                      -- active LOW
   ddrRstL <= '0';                      -- put into reset state

   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G => TPD_G)
      port map (
         axiClk         => sysClk,
         axiClkRst      => sysRst,
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave);

end mapping;
