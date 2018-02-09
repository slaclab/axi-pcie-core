-------------------------------------------------------------------------------
-- File       : AdmPcieKu3Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2018-02-07
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for ADM-PCIE-KU3 board 
--
-- # ADM-PCIE-KU3 Product Page
-- http://www.alpha-data.com/dcp/products.php?product=adm-pcie-ku3
--
-- # ADM-PCIE-KU3 Pinout
-- http://www.alpha-data.com/dcp/otherproductdatafiles/adm-pcie-ku3_pinout.csv
--
-- # ADM-PCIE-KU3 Datasheet
-- http://www.alpha-data.com/pdfs/adm-pcie-ku3.pdf
--
-- # ADM-PCIE-KU3 User Manual
-- http://www.alpha-data.com/pdfs/adm-pcie-ku3%20user%20manual.pdf
--
-- # ADM-PCIE-KU3 Factory Default image
-- https://support.alpha-data.com/portals/0/downloads/adm-pcie-ku3_default_images/adm-pcie-ku3_default_images.zip
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

entity AdmPcieKu3Core is
   generic (
      TPD_G            : time                  := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      DRIVER_TYPE_ID_G : slv(31 downto 0)      := x"00000000";
      DMA_SIZE_G       : positive range 1 to 8 := 1);
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------
      -- System Interface
      sysClk         : out sl;
      sysRst         : out sl;
      -- DMA Interfaces  (sysClk domain)
      dmaObMasters   : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves    : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters   : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves    : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- Application AXI-Lite Interfaces [0x00800000:0x00FFFFFF] (appClk domain)
      appClk         : in  sl;
      appRst         : in  sl;
      appReadMaster  : out AxiLiteReadMasterType;
      appReadSlave   : in  AxiLiteReadSlaveType;
      appWriteMaster : out AxiLiteWriteMasterType;
      appWriteSlave  : in  AxiLiteWriteSlaveType;
      -------------------
      --  Top Level Ports
      -------------------      
      -- QSFP[0] Ports
      qsfp0RstL      : out sl;
      qsfp0LpMode    : out sl;
      -- QSFP[1] Ports
      qsfp1RstL      : out sl;
      qsfp1LpMode    : out sl;
      -- PCIe Ports 
      pciRstL        : in  sl;
      pciRefClkP     : in  sl;
      pciRefClkN     : in  sl;
      pciRxP         : in  slv(7 downto 0);
      pciRxN         : in  slv(7 downto 0);
      pciTxP         : out slv(7 downto 0);
      pciTxN         : out slv(7 downto 0));
end AdmPcieKu3Core;

architecture mapping of AdmPcieKu3Core is

   constant AXI_ERROR_RESP_C : slv(1 downto 0) := AXI_RESP_OK_C;  -- Always return OK to a MMAP()

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

   sysClk <= sysClock;

   systemReset <= sysReset or cardReset;

   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClock,
         rstIn  => systemReset,
         rstOut => sysRst);

   qsfp0RstL   <= not(systemReset);
   qsfp1RstL   <= not(systemReset);
   qsfp0LpMode <= '0';
   qsfp1LpMode <= '0';

   ---------------
   -- AXI PCIe PHY
   ---------------   
   U_AxiPciePhy : entity work.AdmPcieKu3PciePhyWrapper
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
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   ---------------
   -- AXI PCIe REG
   --------------- 
   U_REG : entity work.AxiPcieReg
      generic map (
         TPD_G            => TPD_G,
         BUILD_INFO_G     => BUILD_INFO_G,
         XIL_DEVICE_G     => "ULTRASCALE",
         BOOT_PROM_G      => "NOT_SUPPORTED",
         DRIVER_TYPE_ID_G => DRIVER_TYPE_ID_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_C,
         DMA_SIZE_G       => DMA_SIZE_G)
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
         TPD_G            => TPD_G,
         DMA_SIZE_G       => DMA_SIZE_G,
         DESC_ARB_G       => false,  -- Round robin to help with timing @ 250 MHz system clock
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_C)
      port map (
         -- Clock and reset
         axiClk           => sysClock,
         axiRst           => sysReset,
         -- AXI4 Interfaces
         axiReadMaster    => dmaReadMaster,
         axiReadSlave     => dmaReadSlave,
         axiWriteMaster   => dmaWriteMaster,
         axiWriteSlave    => dmaWriteSlave,
         -- AXI4-Lite Interfaces
         axilReadMasters  => dmaCtrlReadMasters,
         axilReadSlaves   => dmaCtrlReadSlaves,
         axilWriteMasters => dmaCtrlWriteMasters,
         axilWriteSlaves  => dmaCtrlWriteSlaves,
         -- Interrupts
         dmaIrq           => dmaIrq,
         -- DMA Interfaces
         dmaObMasters     => dmaObMasters,
         dmaObSlaves      => dmaObSlaves,
         dmaIbMasters     => dmaIbMasters,
         dmaIbSlaves      => dmaIbSlaves);

end mapping;
