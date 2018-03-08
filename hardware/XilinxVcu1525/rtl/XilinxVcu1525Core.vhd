-------------------------------------------------------------------------------
-- File       : XilinxVcu1525Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-01-29
-- Last update: 2018-02-07
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for VCU1525 board 
--
-- VCU1525 Product Page:
-- https://www.xilinx.com/products/boards-and-kits/vcu1525-a.html
--
-- VCU1525 Known Issues:
-- https://www.xilinx.com/support/answers/69844.html
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

entity XilinxVcu1525Core is
   generic (
      TPD_G            : time             := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      DRIVER_TYPE_ID_G : slv(31 downto 0) := x"00000000");
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------
      -- System Interface
      sysClk          : out   sl;
      sysRst          : out   sl;
      userClk156      : out   sl;       -- 156.25 MHz
      -- DMA Interfaces  (sysClk domain)
      dmaObMasters    : out   AxiStreamMasterArray(7 downto 0);
      dmaObSlaves     : in    AxiStreamSlaveArray(7 downto 0);
      dmaIbMasters    : in    AxiStreamMasterArray(7 downto 0);
      dmaIbSlaves     : out   AxiStreamSlaveArray(7 downto 0);
      -- Application AXI-Lite Interfaces [0x00800000:0x00FFFFFF] (appClk domain)
      appClk          : in    sl;
      appRst          : in    sl;
      appReadMaster   : out   AxiLiteReadMasterType;
      appReadSlave    : in    AxiLiteReadSlaveType;
      appWriteMaster  : out   AxiLiteWriteMasterType;
      appWriteSlave   : in    AxiLiteWriteSlaveType;
      -- AXI MEM Interface (mig1Clk domain)
      mig1Clk         : out   sl;
      mig1Rst         : out   sl;
      mig1Ready       : out   sl;
      mig1WriteMaster : in    AxiWriteMasterType;
      mig1WriteSlave  : out   AxiWriteSlaveType;
      mig1ReadMaster  : in    AxiReadMasterType;
      mig1ReadSlave   : out   AxiReadSlaveType;
      -------------------
      --  Top Level Ports
      -------------------      
      -- System Ports
      userClkP        : in    sl;
      userClkN        : in    sl;
      -- MIG[1] DDR Ports
      mig1DdrClkP     : in    sl;
      mig1DdrClkN     : in    sl;
      mig1DdrOut      : out   DdrOutType;
      mig1DdrInOut    : inout DdrInOutType;
      -- QSFP[0] Ports
      qsfp0RstL       : out   sl;
      qsfp0LpMode     : out   sl;
      qsfp0ModSelL    : out   sl;
      qsfp0ModPrsL    : in    sl;
      -- QSFP[1] Ports
      qsfp1RstL       : out   sl;
      qsfp1LpMode     : out   sl;
      qsfp1ModSelL    : out   sl;
      qsfp1ModPrsL    : in    sl;
      -- PCIe Ports 
      pciRstL         : in    sl;
      pciRefClkP      : in    sl;
      pciRefClkN      : in    sl;
      pciRxP          : in    slv(15 downto 0);
      pciRxN          : in    slv(15 downto 0);
      pciTxP          : out   slv(15 downto 0);
      pciTxN          : out   slv(15 downto 0));
end XilinxVcu1525Core;

architecture mapping of XilinxVcu1525Core is

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
   signal userClock   : sl;
   signal dmaIrq      : sl;

   signal bootCsL  : slv(1 downto 0) := (others => '0');
   signal bootSck  : slv(1 downto 0) := (others => '0');
   signal bootMosi : slv(1 downto 0) := (others => '0');
   signal bootMiso : slv(1 downto 0) := (others => '0');
   signal di       : slv(3 downto 0) := (others => '0');
   signal do       : slv(3 downto 0) := (others => '0');

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

   U_IBUFDS : IBUFDS
      port map(
         I  => userClkP,
         IB => userClkN,
         O  => userClock);

   U_BUFG : BUFG
      port map (
         I => userClock,
         O => userClk156);

   qsfp0RstL    <= not(systemReset);
   qsfp1RstL    <= not(systemReset);
   qsfp0LpMode  <= '0';
   qsfp1LpMode  <= '0';
   qsfp0ModSelL <= '1';
   qsfp1ModSelL <= '1';

   ---------------
   -- AXI PCIe PHY
   ---------------   
   U_AxiPciePhy : entity work.XilinxVcu1525PciePhyWrapper
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
         BOOT_PROM_G      => "SPI",
         DRIVER_TYPE_ID_G => DRIVER_TYPE_ID_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_C,
         DMA_SIZE_G       => 8)
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
         cardResetIn         => systemReset,
         -- SPI Boot Memory Ports 
         spiCsL              => bootCsL,
         spiSck              => bootSck,
         spiMosi             => bootMosi,
         spiMiso             => bootMiso);

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => di,  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
         DO        => do,  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => "1110",  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bootCsL(0),  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => bootSck(0),       -- 1-bit input: User CCLK input
         USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',  -- 1-bit input: User DONE pin output control
         USRDONETS => '0');  -- 1-bit input: User DONE 3-state enable output

   do          <= "111" & bootMosi(0);
   bootMiso(0) <= di(1);

   ---------------
   -- AXI PCIe DMA
   ---------------   
   U_AxiPcieDma : entity work.AxiPcieDma
      generic map (
         TPD_G            => TPD_G,
         DMA_SIZE_G       => 8,
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

   ----------------- 
   -- AXI DDR MIG[1]
   ----------------- 
   U_Mig1 : entity work.Mig1
      generic map (
         TPD_G => TPD_G)
      port map (
         -- System Clock and reset
         sysClk         => sysClock,
         sysRst         => sysReset,
         -- AXI MEM Interface (axiClk domain)
         axiClk         => mig1Clk,
         axiRst         => mig1Rst,
         axiReady       => mig1Ready,
         axiWriteMaster => mig1WriteMaster,
         axiWriteSlave  => mig1WriteSlave,
         axiReadMaster  => mig1ReadMaster,
         axiReadSlave   => mig1ReadSlave,
         -- DDR Ports
         ddrClkP        => mig1DdrClkP,
         ddrClkN        => mig1DdrClkN,
         ddrOut         => mig1DdrOut,
         ddrInOut       => mig1DdrInOut);

end mapping;
