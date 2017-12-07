-------------------------------------------------------------------------------
-- File       : AdmPcieKu3Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2017-12-06
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
      sysClk         : out   sl;
      sysRst         : out   sl;
      -- DMA Interfaces  (sysClk domain)
      dmaObMasters   : out   AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves    : in    AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters   : in    AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves    : out   AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- Application AXI-Lite Interfaces [0x00800000:0x00FFFFFF] (appClk domain)
      appClk         : in    sl;
      appRst         : in    sl;
      appReadMaster  : out   AxiLiteReadMasterType;
      appReadSlave   : in    AxiLiteReadSlaveType;
      appWriteMaster : out   AxiLiteWriteMasterType;
      appWriteSlave  : in    AxiLiteWriteSlaveType;
      -------------------
      --  Top Level Ports
      -------------------      
      -- QSFP[0] Ports
      qsfp0RstL      : out   sl;
      qsfp0LpMode    : out   sl;
      -- QSFP[1] Ports
      qsfp1RstL      : out   sl;
      qsfp1LpMode    : out   sl;
      -- Boot Memory Ports 
      flashAddr      : out   slv(23 downto 0);
      flashData      : inout slv(15 downto 4);
      flashAdv       : out   sl;
      flashOeL       : out   sl;
      flashWeL       : out   sl;
      flashRstL      : out   sl;
      -- PCIe Ports 
      pciRstL        : in    sl;
      pciRefClkP     : in    sl;
      pciRefClkN     : in    sl;
      pciRxP         : in    slv(7 downto 0);
      pciRxN         : in    slv(7 downto 0);
      pciTxP         : out   slv(7 downto 0);
      pciTxN         : out   slv(7 downto 0));
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

   signal dmaCtrlReadMaster  : AxiLiteReadMasterType;
   signal dmaCtrlReadSlave   : AxiLiteReadSlaveType;
   signal dmaCtrlWriteMaster : AxiLiteWriteMasterType;
   signal dmaCtrlWriteSlave  : AxiLiteWriteSlaveType;

   signal phyReadMaster  : AxiLiteReadMasterType;
   signal phyReadSlave   : AxiLiteReadSlaveType;
   signal phyWriteMaster : AxiLiteWriteMasterType;
   signal phyWriteSlave  : AxiLiteWriteSlaveType;

   signal flashAddress : slv(28 downto 0);
   signal flashDin     : slv(15 downto 0);
   signal flashDout    : slv(15 downto 0);
   signal flashTri     : sl;

   signal sysClock    : sl;
   signal sysReset    : sl;
   signal systemReset : sl;
   signal cardReset   : sl;
   signal dmaIrq      : sl;
   signal flashCeL    : sl;
   signal flashClk    : sl;

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
         axiClk             => sysClock,
         axiRst             => sysReset,
         regReadMaster      => regReadMaster,
         regReadSlave       => regReadSlave,
         regWriteMaster     => regWriteMaster,
         regWriteSlave      => regWriteSlave,
         -- DMA AXI-Lite Interfaces
         dmaCtrlReadMaster  => dmaCtrlReadMaster,
         dmaCtrlReadSlave   => dmaCtrlReadSlave,
         dmaCtrlWriteMaster => dmaCtrlWriteMaster,
         dmaCtrlWriteSlave  => dmaCtrlWriteSlave,
         -- PHY AXI-Lite Interfaces
         phyReadMaster      => phyReadMaster,
         phyReadSlave       => phyReadSlave,
         phyWriteMaster     => phyWriteMaster,
         phyWriteSlave      => phyWriteSlave,
         -- (Optional) Application AXI-Lite Interfaces
         appClk             => appClk,
         appRst             => appRst,
         appReadMaster      => appReadMaster,
         appReadSlave       => appReadSlave,
         appWriteMaster     => appWriteMaster,
         appWriteSlave      => appWriteSlave,
         -- Application Force reset
         cardResetOut       => cardReset,
         cardResetIn        => systemReset,
         -- Boot Memory Ports 
         bpiAddr            => flashAddress,
         bpiAdv             => flashAdv,
         bpiClk             => flashClk,
         bpiRstL            => flashRstL,
         bpiCeL             => flashCeL,
         bpiOeL             => flashOeL,
         bpiWeL             => flashWeL,
         bpiDin             => flashDin,
         bpiDout            => flashDout,
         bpiTri             => flashTri);

   flashAddr <= flashAddress(23 downto 0);

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => flashDout(3 downto 0),  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output         
         DO        => flashDin(3 downto 0),  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => (others => flashTri),  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => flashCeL,  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => flashClk,         -- 1-bit input: User CCLK input
         USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',  -- 1-bit input: User DONE pin output control
         USRDONETS => '1');  -- 1-bit input: User DONE 3-state enable output              

   GEN_IOBUF :
   for i in 15 downto 4 generate
      IOBUF_inst : IOBUF
         port map (
            O  => flashDout(i),         -- Buffer output
            IO => flashData(i),  -- Buffer inout port (connect directly to top-level port)
            I  => flashDin(i),          -- Buffer input
            T  => flashTri);  -- 3-state enable input, high=input, low=output     
   end generate GEN_IOBUF;

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
         axiClk          => sysClock,
         axiRst          => sysReset,
         -- AXI4 Interfaces
         axiReadMaster   => dmaReadMaster,
         axiReadSlave    => dmaReadSlave,
         axiWriteMaster  => dmaWriteMaster,
         axiWriteSlave   => dmaWriteSlave,
         -- AXI4-Lite Interfaces
         axilReadMaster  => dmaCtrlReadMaster,
         axilReadSlave   => dmaCtrlReadSlave,
         axilWriteMaster => dmaCtrlWriteMaster,
         axilWriteSlave  => dmaCtrlWriteSlave,
         -- Interrupts
         dmaIrq          => dmaIrq,
         -- DMA Interfaces
         dmaObMasters    => dmaObMasters,
         dmaObSlaves     => dmaObSlaves,
         dmaIbMasters    => dmaIbMasters,
         dmaIbSlaves     => dmaIbSlaves);

end mapping;
