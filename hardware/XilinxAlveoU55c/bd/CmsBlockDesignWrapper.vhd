-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
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

entity CmsBlockDesignWrapper is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Card Management Solution (CMS) Interface
      cmsHbmCatTrip  : in  sl;
      cmsHbmTemp     : in  Slv7Array(1 downto 0);
      cmsUartRxd     : in  sl;
      cmsUartTxd     : out sl;
      cmsGpio        : in  slv (3 downto 0);
      -- I2C AXI-Lite Interfaces (axiClk domain)
      axiClk         : in  sl;
      axiRst         : in  sl;
      i2cReadMaster  : in  AxiLiteReadMasterType;
      i2cReadSlave   : out AxiLiteReadSlaveType;
      i2cWriteMaster : in  AxiLiteWriteMasterType;
      i2cWriteSlave  : out AxiLiteWriteSlaveType);
end CmsBlockDesignWrapper;

architecture mapping of CmsBlockDesignWrapper is

   component CmsBlockDesign is
      port (
         satellite_uart_0_rxd    : in  std_logic;
         satellite_uart_0_txd    : out std_logic;
         s_axi_ctrl_0_awaddr     : in  std_logic_vector (17 downto 0);
         s_axi_ctrl_0_awprot     : in  std_logic_vector (2 downto 0);
         s_axi_ctrl_0_awvalid    : in  std_logic_vector (0 to 0);
         s_axi_ctrl_0_awready    : out std_logic_vector (0 to 0);
         s_axi_ctrl_0_wdata      : in  std_logic_vector (31 downto 0);
         s_axi_ctrl_0_wstrb      : in  std_logic_vector (3 downto 0);
         s_axi_ctrl_0_wvalid     : in  std_logic_vector (0 to 0);
         s_axi_ctrl_0_wready     : out std_logic_vector (0 to 0);
         s_axi_ctrl_0_bresp      : out std_logic_vector (1 downto 0);
         s_axi_ctrl_0_bvalid     : out std_logic_vector (0 to 0);
         s_axi_ctrl_0_bready     : in  std_logic_vector (0 to 0);
         s_axi_ctrl_0_araddr     : in  std_logic_vector (17 downto 0);
         s_axi_ctrl_0_arprot     : in  std_logic_vector (2 downto 0);
         s_axi_ctrl_0_arvalid    : in  std_logic_vector (0 to 0);
         s_axi_ctrl_0_arready    : out std_logic_vector (0 to 0);
         s_axi_ctrl_0_rdata      : out std_logic_vector (31 downto 0);
         s_axi_ctrl_0_rresp      : out std_logic_vector (1 downto 0);
         s_axi_ctrl_0_rvalid     : out std_logic_vector (0 to 0);
         s_axi_ctrl_0_rready     : in  std_logic_vector (0 to 0);
         satellite_gpio_0        : in  std_logic_vector (3 downto 0);
         aclk_ctrl_0             : in  std_logic;
         aresetn_ctrl_0          : in  std_logic;
         interrupt_hbm_cattrip_0 : in  std_logic_vector (0 to 0);
         hbm_temp_1_0            : in  std_logic_vector (6 downto 0);
         hbm_temp_2_0            : in  std_logic_vector (6 downto 0)
         );
   end component CmsBlockDesign;

   signal cmsClk         : sl;
   signal cmsRst         : sl;
   signal cmsRstL        : sl;
   signal cmsReadMaster  : AxiLiteReadMasterType;
   signal cmsReadSlave   : AxiLiteReadSlaveType;
   signal cmsWriteMaster : AxiLiteWriteMasterType;
   signal cmsWriteSlave  : AxiLiteWriteSlaveType;

begin

   U_Bufg : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 5)
      port map (
         I   => axiClk,                 -- 250 MHz
         CE  => '1',
         CLR => '0',
         O   => cmsClk);                -- 50 MHz

   U_RstSync : entity surf.RstSync
      port map (
         clk      => cmsClk,
         asyncRst => axiRst,
         syncRst  => cmsRst);

   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 18)
      port map (
         -- Slave Interface
         sAxiClk         => axiClk,
         sAxiClkRst      => axiRst,
         sAxiReadMaster  => i2cReadMaster,
         sAxiReadSlave   => i2cReadSlave,
         sAxiWriteMaster => i2cWriteMaster,
         sAxiWriteSlave  => i2cWriteSlave,
         -- Master Interface
         mAxiClk         => cmsClk,
         mAxiClkRst      => cmsRst,
         mAxiReadMaster  => cmsReadMaster,
         mAxiReadSlave   => cmsReadSlave,
         mAxiWriteMaster => cmsWriteMaster,
         mAxiWriteSlave  => cmsWriteSlave);

   cmsRstL <= not cmsRst;

   U_CmsBlockDesign : component CmsBlockDesign
      port map (
         aclk_ctrl_0                      => cmsClk,  -- Must be 50 MHz
         aresetn_ctrl_0                   => cmsRstL,
         hbm_temp_1_0(6 downto 0)         => cmsHbmTemp(0),
         hbm_temp_2_0(6 downto 0)         => cmsHbmTemp(1),
         interrupt_hbm_cattrip_0(0)       => cmsHbmCatTrip,
         s_axi_ctrl_0_araddr(17 downto 0) => cmsReadMaster.araddr(17 downto 0),
         s_axi_ctrl_0_arprot(2 downto 0)  => cmsReadMaster.arprot,
         s_axi_ctrl_0_arready(0)          => cmsReadSlave.arready,
         s_axi_ctrl_0_arvalid(0)          => cmsReadMaster.arvalid,
         s_axi_ctrl_0_awaddr(17 downto 0) => cmsWriteMaster.awaddr(17 downto 0),
         s_axi_ctrl_0_awprot(2 downto 0)  => cmsWriteMaster.awprot,
         s_axi_ctrl_0_awready(0)          => cmsWriteSlave.awready,
         s_axi_ctrl_0_awvalid(0)          => cmsWriteMaster.awvalid,
         s_axi_ctrl_0_bready(0)           => cmsWriteMaster.bready,
         s_axi_ctrl_0_bresp(1 downto 0)   => cmsWriteSlave.bresp,
         s_axi_ctrl_0_bvalid(0)           => cmsWriteSlave.bvalid,
         s_axi_ctrl_0_rdata(31 downto 0)  => cmsReadSlave.rdata,
         s_axi_ctrl_0_rready(0)           => cmsReadMaster.rready,
         s_axi_ctrl_0_rresp(1 downto 0)   => cmsReadSlave.rresp,
         s_axi_ctrl_0_rvalid(0)           => cmsReadSlave.rvalid,
         s_axi_ctrl_0_wdata(31 downto 0)  => cmsWriteMaster.wdata,
         s_axi_ctrl_0_wready(0)           => cmsWriteSlave.wready,
         s_axi_ctrl_0_wstrb(3 downto 0)   => cmsWriteMaster.wstrb,
         s_axi_ctrl_0_wvalid(0)           => cmsWriteMaster.wvalid,
         satellite_gpio_0(3 downto 0)     => cmsGpio,
         satellite_uart_0_rxd             => cmsUartRxd,
         satellite_uart_0_txd             => cmsUartTxd);

end mapping;
