-------------------------------------------------------------------------------
-- File       : XilinxKcu1500PcieExtendedCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for KCU1500 board 
--
-- # KCU1500 Product Page
-- https://www.xilinx.com/products/boards-and-kits/dk-u1-kcu1500-g.html
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxKcu1500PcieExtendedCore is
   generic (
      TPD_G             : time                  := 1 ns;
      BUILD_INFO_G      : BuildInfoType;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      DRIVER_TYPE_ID_G  : slv(31 downto 0)      := x"00000000";
      DMA_SIZE_G        : positive range 1 to 8 := 1);
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------
      -- DMA Interfaces  (dmaClk domain)
      dmaClk         : out sl;
      dmaRst         : out sl;
      dmaObMasters   : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves    : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters   : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves    : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- Application AXI-Lite Interfaces [0x00080000:0x00FFFFFF] (appClk domain)
      appClk         : in  sl;
      appRst         : in  sl;
      appReadMaster  : out AxiLiteReadMasterType;
      appReadSlave   : in  AxiLiteReadSlaveType;
      appWriteMaster : out AxiLiteWriteMasterType;
      appWriteSlave  : in  AxiLiteWriteSlaveType;
      -------------------
      --  Top Level Ports
      -------------------
      -- Extended PCIe Ports 
      pciRstL        : in  sl;
      pciExtRefClkP  : in  sl;
      pciExtRefClkN  : in  sl;
      pciExtRxP      : in  slv(7 downto 0);
      pciExtRxN      : in  slv(7 downto 0);
      pciExtTxP      : out slv(7 downto 0);
      pciExtTxN      : out slv(7 downto 0));
end XilinxKcu1500PcieExtendedCore;

architecture mapping of XilinxKcu1500PcieExtendedCore is

   signal dmaReadMaster  : AxiReadMasterType;
   signal dmaReadSlave   : AxiReadSlaveType;
   signal dmaWriteMaster : AxiWriteMasterType;
   signal dmaWriteSlave  : AxiWriteSlaveType;

   signal regReadMaster  : AxiReadMasterType;
   signal regReadSlave   : AxiReadSlaveType;
   signal regWriteMaster : AxiWriteMasterType;
   signal regWriteSlave  : AxiWriteSlaveType;

   signal dmaCtrlReadMasters  : AxiLiteReadMasterArray(2 downto 0);
   signal dmaCtrlReadSlaves   : AxiLiteReadSlaveArray(2 downto 0);
   signal dmaCtrlWriteMasters : AxiLiteWriteMasterArray(2 downto 0);
   signal dmaCtrlWriteSlaves  : AxiLiteWriteSlaveArray(2 downto 0);

   signal phyReadMaster  : AxiLiteReadMasterType;
   signal phyReadSlave   : AxiLiteReadSlaveType;
   signal phyWriteMaster : AxiLiteWriteMasterType;
   signal phyWriteSlave  : AxiLiteWriteSlaveType;

   signal sysClock    : sl;
   signal sysReset    : sl;
   signal systemReset : sl;
   signal cardReset   : sl;
   signal dmaIrq      : sl;


begin

   dmaClk <= sysClock;

   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClock,
         rstIn  => systemReset,
         rstOut => dmaRst);

   systemReset <= sysReset or cardReset;

   ---------------
   -- AXI PCIe PHY
   ---------------   
   U_AxiPciePhy : entity work.XilinxKcu1500ExtendedPciePhyWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI4 Interfaces
         axiClk         => sysClock,
         axiRst         => sysReset,
         dmaReadMaster  => dmaReadMaster,
         dmaReadSlave   => dmaReadSlave,
         dmaWriteMaster => dmaWriteMaster,
         dmaWriteSlave  => dmaWriteSlave,
         regReadMaster  => regReadMaster,
         regReadSlave   => regReadSlave,
         regWriteMaster => regWriteMaster,
         regWriteSlave  => regWriteSlave,
         phyReadMaster  => phyReadMaster,
         phyReadSlave   => phyReadSlave,
         phyWriteMaster => phyWriteMaster,
         phyWriteSlave  => phyWriteSlave,
         -- Interrupt Interface
         dmaIrq         => dmaIrq,
         -- PCIe Ports 
         pciRstL        => pciRstL,
         pciRefClkP     => pciExtRefClkP,
         pciRefClkN     => pciExtRefClkN,
         pciRxP         => pciExtRxP,
         pciRxN         => pciExtRxN,
         pciTxP         => pciExtTxP,
         pciTxN         => pciExtTxN);

   ---------------
   -- AXI PCIe REG
   --------------- 
   U_REG : entity work.AxiPcieReg
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         XIL_DEVICE_G      => "ULTRASCALE",
         BOOT_PROM_G       => "NONE",
         EN_DEVICE_DNA_G   => false,
         EN_ICAP_G         => false,
         DRIVER_TYPE_ID_G  => DRIVER_TYPE_ID_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
         DMA_SIZE_G        => DMA_SIZE_G)
      port map (
         -- AXI4 Interfaces
         axiClk              => sysClock,
         axiRst              => sysReset,
         regReadMaster       => regReadMaster,
         regReadSlave        => regReadSlave,
         regWriteMaster      => regWriteMaster,
         regWriteSlave       => regWriteSlave,
         -- DMA AXI-Lite Interfaces
         dmaCtrlReadMasters  => dmaCtrlReadMasters,
         dmaCtrlReadSlaves   => dmaCtrlReadSlaves,
         dmaCtrlWriteMasters => dmaCtrlWriteMasters,
         dmaCtrlWriteSlaves  => dmaCtrlWriteSlaves,
         -- PHY AXI-Lite Interfaces
         phyReadMaster       => phyReadMaster,
         phyReadSlave        => phyReadSlave,
         phyWriteMaster      => phyWriteMaster,
         phyWriteSlave       => phyWriteSlave,
         -- (Optional) Application AXI-Lite Interfaces
         appClk              => appClk,
         appRst              => appRst,
         appReadMaster       => appReadMaster,
         appReadSlave        => appReadSlave,
         appWriteMaster      => appWriteMaster,
         appWriteSlave       => appWriteSlave,
         -- Application Force reset
         cardResetOut        => cardReset,
         cardResetIn         => systemReset);

   ---------------
   -- AXI PCIe DMA
   ---------------   
   U_AxiPcieDma : entity work.AxiPcieDma
      generic map (
         TPD_G             => TPD_G,
         DMA_SIZE_G        => DMA_SIZE_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
         DESC_ARB_G        => false)    -- Round robin to help with timing
      port map (
         axiClk           => sysClock,
         axiRst           => sysReset,
         -- AXI4 Interfaces (
         axiReadMaster    => dmaReadMaster,
         axiReadSlave     => dmaReadSlave,
         axiWriteMaster   => dmaWriteMaster,
         axiWriteSlave    => dmaWriteSlave,
         -- AXI4-Lite Interfaces
         axilReadMasters  => dmaCtrlReadMasters,
         axilReadSlaves   => dmaCtrlReadSlaves,
         axilWriteMasters => dmaCtrlWriteMasters,
         axilWriteSlaves  => dmaCtrlWriteSlaves,
         -- DMA Interfaces
         dmaIrq           => dmaIrq,
         dmaObMasters     => dmaObMasters,
         dmaObSlaves      => dmaObSlaves,
         dmaIbMasters     => dmaIbMasters,
         dmaIbSlaves      => dmaIbSlaves);

end mapping;
