-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: BAR0 I2C slot [0x00070000:0x0007FFFF] of AxiPcieReg
-------------------------------------------------------------------------------
-- I2C_FAST_EN_G = false: the whole 64 kB slot goes through the AXI-Lite
-- master proxy.
--
-- I2C_FAST_EN_G = true: the slot is split in two 32 kB windows:
--    [0x00070000:0x00077FFF] through the AXI-Lite master proxy
--    [0x00078000:0x0007FFFF] direct to the I2C devices (no proxy, BIT15
--                            cleared so the devices see the same address)
-- AxiPcieRegReadOrder keeps reads from passing writes stalled behind the
-- slow non-proxy path.
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library axi_pcie_core;

entity AxiPcieRegI2c is
   generic (
      TPD_G            : time    := 1 ns;
      I2C_FAST_EN_G    : boolean := false;  -- Non-proxy I2C path at AXIL_BASE_ADDR_G + 0x8000
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- Clock and Reset
      axiClk             : in  sl;
      axiRst             : in  sl;
      -- Slave AXI-Lite Interface (axiClk domain)
      sAxilReadMaster    : in  AxiLiteReadMasterType;
      sAxilReadSlave     : out AxiLiteReadSlaveType;
      sAxilWriteMaster   : in  AxiLiteWriteMasterType;
      sAxilWriteSlave    : out AxiLiteWriteSlaveType;
      -- I2C AXI-Lite Interfaces With Proxy (axiClk domain)
      i2cReadMaster      : out AxiLiteReadMasterType;
      i2cReadSlave       : in  AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      i2cWriteMaster     : out AxiLiteWriteMasterType;
      i2cWriteSlave      : in  AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
      -- I2C AXI-Lite Interfaces Without Proxy (axiClk domain)
      i2cFastReadMaster  : out AxiLiteReadMasterType;
      i2cFastReadSlave   : in  AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      i2cFastWriteMaster : out AxiLiteWriteMasterType;
      i2cFastWriteSlave  : in  AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
end AxiPcieRegI2c;

architecture mapping of AxiPcieRegI2c is

   constant PROXY_INDEX_C : natural := 0;
   constant FAST_INDEX_C  : natural := 1;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(1 downto 0) := genAxiLiteConfig(2, AXIL_BASE_ADDR_G, 16, 15);

   signal proxyReadMaster  : AxiLiteReadMasterType;
   signal proxyReadSlave   : AxiLiteReadSlaveType;
   signal proxyWriteMaster : AxiLiteWriteMasterType;
   signal proxyWriteSlave  : AxiLiteWriteSlaveType;

begin

   GEN_I2C_FAST : if (I2C_FAST_EN_G) generate

      signal xbarReadMaster  : AxiLiteReadMasterType;
      signal xbarReadSlave   : AxiLiteReadSlaveType;
      signal xbarWriteMaster : AxiLiteWriteMasterType;
      signal xbarWriteSlave  : AxiLiteWriteSlaveType;

      signal axilReadMasters  : AxiLiteReadMasterArray(1 downto 0);
      signal axilReadSlaves   : AxiLiteReadSlaveArray(1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
      signal axilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
      signal axilWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   begin

      ----------------------------------------------------------------
      -- Keep reads from passing writes stalled behind the slow non-proxy
      -- I2C path
      ----------------------------------------------------------------
      U_ReadOrder : entity axi_pcie_core.AxiPcieRegReadOrder
         generic map (
            TPD_G => TPD_G)
         port map (
            axilClk          => axiClk,
            axilRst          => axiRst,
            sAxilReadMaster  => sAxilReadMaster,
            sAxilReadSlave   => sAxilReadSlave,
            sAxilWriteMaster => sAxilWriteMaster,
            sAxilWriteSlave  => sAxilWriteSlave,
            mAxilReadMaster  => xbarReadMaster,
            mAxilReadSlave   => xbarReadSlave,
            mAxilWriteMaster => xbarWriteMaster,
            mAxilWriteSlave  => xbarWriteSlave);

      --------------------------------------------
      -- Split the proxy and non-proxy I2C windows
      --------------------------------------------
      U_XBAR : entity surf.AxiLiteCrossbar
         generic map (
            TPD_G              => TPD_G,
            NUM_SLAVE_SLOTS_G  => 1,
            NUM_MASTER_SLOTS_G => 2,
            MASTERS_CONFIG_G   => XBAR_CONFIG_C)
         port map (
            axiClk              => axiClk,
            axiClkRst           => axiRst,
            sAxiWriteMasters(0) => xbarWriteMaster,
            sAxiWriteSlaves(0)  => xbarWriteSlave,
            sAxiReadMasters(0)  => xbarReadMaster,
            sAxiReadSlaves(0)   => xbarReadSlave,
            mAxiWriteMasters    => axilWriteMasters,
            mAxiWriteSlaves     => axilWriteSlaves,
            mAxiReadMasters     => axilReadMasters,
            mAxiReadSlaves      => axilReadSlaves);

      proxyReadMaster                <= axilReadMasters(PROXY_INDEX_C);
      axilReadSlaves(PROXY_INDEX_C)  <= proxyReadSlave;
      proxyWriteMaster               <= axilWriteMasters(PROXY_INDEX_C);
      axilWriteSlaves(PROXY_INDEX_C) <= proxyWriteSlave;

      ------------------------------------------------
      -- Map the AXI-Lite to I2C without proxy (fast)
      ------------------------------------------------
      process(axilReadMasters, axilWriteMasters)
         variable rdMaster : AxiLiteReadMasterType;
         variable wrMaster : AxiLiteWriteMasterType;
      begin
         rdMaster            := axilReadMasters(FAST_INDEX_C);
         wrMaster            := axilWriteMasters(FAST_INDEX_C);
         -- Force BIT15 to zero so the I2C devices see the same address as the proxy path
         rdMaster.araddr(15) := '0';
         wrMaster.awaddr(15) := '0';
         i2cFastReadMaster   <= rdMaster;
         i2cFastWriteMaster  <= wrMaster;
      end process;

      axilReadSlaves(FAST_INDEX_C)  <= i2cFastReadSlave;
      axilWriteSlaves(FAST_INDEX_C) <= i2cFastWriteSlave;

   end generate;

   NO_I2C_FAST : if (not I2C_FAST_EN_G) generate

      proxyReadMaster  <= sAxilReadMaster;
      sAxilReadSlave   <= proxyReadSlave;
      proxyWriteMaster <= sAxilWriteMaster;
      sAxilWriteSlave  <= proxyWriteSlave;

      i2cFastReadMaster  <= AXI_LITE_READ_MASTER_INIT_C;
      i2cFastWriteMaster <= AXI_LITE_WRITE_MASTER_INIT_C;

   end generate;

   --------------------------
   -- Map the AXI-Lite to I2C
   --------------------------
   U_AxiLiteMasterProxy : entity surf.AxiLiteMasterProxy
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clocks and Resets
         axiClk          => axiClk,
         axiRst          => axiRst,
         -- AXI-Lite Register Interface
         sAxiReadMaster  => proxyReadMaster,
         sAxiReadSlave   => proxyReadSlave,
         sAxiWriteMaster => proxyWriteMaster,
         sAxiWriteSlave  => proxyWriteSlave,
         -- AXI-Lite Register Interface
         mAxiReadMaster  => i2cReadMaster,
         mAxiReadSlave   => i2cReadSlave,
         mAxiWriteMaster => i2cWriteMaster,
         mAxiWriteSlave  => i2cWriteSlave);

end mapping;
