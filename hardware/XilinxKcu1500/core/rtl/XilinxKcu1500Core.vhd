-------------------------------------------------------------------------------
-- File       : XilinxKcu1500Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2017-10-10
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

entity XilinxKcu1500Core is
   generic (
      TPD_G            : time                  := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      DRIVER_TYPE_ID_G : slv(31 downto 0)      := x"00000000";
      AXI_APP_BUS_EN_G : boolean               := false;
      DMA_SIZE_G       : positive range 1 to 9 := 9);
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------
      userClk156      : out   sl;       -- 156.25 MHz
      userClk100      : out   sl;       -- 100 MHz
      userSwDip       : out   slv(3 downto 0);
      userLed         : in    slv(7 downto 0);
      -- System Interface
      sysClk          : out   sl;
      sysRst          : out   sl;
      -- DMA Interfaces  (sysClk domain)
      dmaObMasters    : out   AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves     : in    AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters    : in    AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves     : out   AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- Application AXI Interface [0x000000000:0xFFFFFFFF] (sysClk domain)
      memReady        : out   slv(3 downto 0);
      memWriteMasters : in    AxiWriteMasterArray(15 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
      memWriteSlaves  : out   AxiWriteSlaveArray(15 downto 0);
      memReadMasters  : in    AxiReadMasterArray(15 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
      memReadSlaves   : out   AxiReadSlaveArray(15 downto 0);
      -- (Optional) Application AXI-Lite Interfaces [0x00800000:0x00FFFFFF] (appClk domain)
      appClk          : in    sl;
      appRst          : in    sl;
      appReadMaster   : out   AxiLiteReadMasterType;
      appReadSlave    : in    AxiLiteReadSlaveType             := AXI_LITE_READ_SLAVE_INIT_C;
      appWriteMaster  : out   AxiLiteWriteMasterType;
      appWriteSlave   : in    AxiLiteWriteSlaveType            := AXI_LITE_WRITE_SLAVE_INIT_C;      
      -------------------
      --  Top Level Ports
      -------------------      
      -- System Ports
      emcClk          : in    sl;
      userClkP        : in    slv(1 downto 0);
      userClkN        : in    slv(1 downto 0);
      swDip           : in    slv(3 downto 0);
      led             : out   slv(7 downto 0);
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
      -- Boot Memory Ports 
      flashCsL        : out   sl;
      flashMosi       : out   sl;
      flashMiso       : in    sl;
      flashHoldL      : out   sl;
      flashWp         : out   sl;
      -- DDR Ports
      ddrClkP         : in    slv(3 downto 0);
      ddrClkN         : in    slv(3 downto 0);
      ddrOut          : out   DdrOutArray(3 downto 0);
      ddrInOut        : inout DdrInOutArray(3 downto 0);
      -- PCIe Ports 
      pciRstL         : in    sl;
      pciRefClkP      : in    sl;
      pciRefClkN      : in    sl;
      pciRxP          : in    slv(7 downto 0);
      pciRxN          : in    slv(7 downto 0);
      pciTxP          : out   slv(7 downto 0);
      pciTxN          : out   slv(7 downto 0));
end XilinxKcu1500Core;

architecture mapping of XilinxKcu1500Core is

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

   signal sysClock    : sl;
   signal sysReset    : sl;
   signal systemReset : sl;
   signal cardReset   : sl;
   signal userClock   : slv(1 downto 0);
   signal dmaIrq      : sl;

   signal bootCsL  : slv(1 downto 0);
   signal bootSck  : slv(1 downto 0);
   signal bootMosi : slv(1 downto 0);
   signal bootMiso : slv(1 downto 0);
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);
   signal sck      : sl;
   signal emcClock : sl;
   signal userCclk : sl;
   signal eos      : sl;

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
         I  => userClkP(0),
         IB => userClkN(0),
         O  => userClock(0));

   U_BUFG : BUFG
      port map (
         I => userClock(0),
         O => userClk156);

   U_IBUFDS_GT : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => userClkP(1),
         IB    => userClkN(1),
         CEB   => '0',
         ODIV2 => userClock(1),
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => userClock(1),
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => userClk100);

   GEN_LED :
   for i in 7 downto 0 generate
      U_LED : OBUF
         port map (
            I => userLed(i),
            O => led(i));
   end generate GEN_LED;

   GEN_SW_DIP :
   for i in 3 downto 0 generate
      U_SwDip : IBUF
         port map (
            I => swDip(i),
            O => userSwDip(i));
   end generate GEN_SW_DIP;

   qsfp0RstL    <= not(systemReset);
   qsfp1RstL    <= not(systemReset);
   qsfp0LpMode  <= '0';
   qsfp1LpMode  <= '0';
   qsfp0ModSelL <= '1';
   qsfp1ModSelL <= '1';

   ---------------
   -- AXI PCIe PHY
   ---------------   
   U_AxiPciePhy : entity work.XilinxKcu1500PciePhyWrapper
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
         DRIVER_TYPE_ID_G => DRIVER_TYPE_ID_G,
         AXI_APP_BUS_EN_G => AXI_APP_BUS_EN_G,
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
         -- SPI Boot Memory Ports 
         spiCsL             => bootCsL,
         spiSck             => bootSck,
         spiMosi            => bootMosi,
         spiMiso            => bootMiso);

   flashCsL    <= bootCsL(1);
   flashMosi   <= bootMosi(1);
   bootMiso(1) <= flashMiso;
   flashHoldL  <= '1';
   flashWp     <= '1';

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => di,  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => eos,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
         DO        => do,  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => "1110",  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bootCsL(0),  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => userCclk,         -- 1-bit input: User CCLK input
         USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',  -- 1-bit input: User DONE pin output control
         USRDONETS => '0');  -- 1-bit input: User DONE 3-state enable output

   do          <= "111" & bootMosi(0);
   bootMiso(0) <= di(1);
   sck         <= uOr(bootSck);

   U_emcClk : IBUF
      port map (
         I => emcClk,
         O => emcClock);

   U_BUFGMUX : BUFGMUX
      port map (
         O  => userCclk,                -- 1-bit output: Clock output
         I0 => emcClock,                -- 1-bit input: Clock input (S=0)
         I1 => sck,                     -- 1-bit input: Clock input (S=1)
         S  => eos);                    -- 1-bit input: Clock select      

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

   ----------------- 
   -- AXI DDR MIG[0]
   ----------------- 
   U_Mig0 : entity work.Mig0
      generic map (
         TPD_G => TPD_G)
      port map (
         -- System Clock and reset
         sysClk          => sysClock,
         sysRst          => sysReset,
         -- AXI MEM Interface (sysClk domain)
         axiReady        => memReady(3),  -- $::env(NUM_MIG_CORES)  == 4
         axiWriteMasters => memWriteMasters(15 downto 12),
         axiWriteSlaves  => memWriteSlaves(15 downto 12),
         axiReadMasters  => memReadMasters(15 downto 12),
         axiReadSlaves   => memReadSlaves(15 downto 12),
         -- DDR Ports
         ddrClkP         => ddrClkP(0),
         ddrClkN         => ddrClkN(0),
         ddrOut          => ddrOut(0),
         ddrInOut        => ddrInOut(0));

   ----------------- 
   -- AXI DDR MIG[1]
   -----------------          
   U_Mig1 : entity work.Mig1
      generic map (
         TPD_G => TPD_G)
      port map (
         -- System Clock and reset
         sysClk          => sysClock,
         sysRst          => sysReset,
         -- AXI MEM Interface (sysClk domain)
         axiReady        => memReady(2),  -- $::env(NUM_MIG_CORES)  == 3
         axiWriteMasters => memWriteMasters(11 downto 8),
         axiWriteSlaves  => memWriteSlaves(11 downto 8),
         axiReadMasters  => memReadMasters(11 downto 8),
         axiReadSlaves   => memReadSlaves(11 downto 8),
         -- DDR Ports
         ddrClkP         => ddrClkP(1),
         ddrClkN         => ddrClkN(1),
         ddrOut          => ddrOut(1),
         ddrInOut        => ddrInOut(1));

   ----------------- 
   -- AXI DDR MIG[2]
   ----------------- 
   U_Mig2 : entity work.Mig2
      generic map (
         TPD_G => TPD_G)
      port map (
         -- System Clock and reset
         sysClk          => sysClock,
         sysRst          => sysReset,
         -- AXI MEM Interface (sysClk domain)
         axiReady        => memReady(1),  -- $::env(NUM_MIG_CORES)  == 2
         axiWriteMasters => memWriteMasters(7 downto 4),
         axiWriteSlaves  => memWriteSlaves(7 downto 4),
         axiReadMasters  => memReadMasters(7 downto 4),
         axiReadSlaves   => memReadSlaves(7 downto 4),
         -- DDR Ports
         ddrClkP         => ddrClkP(2),
         ddrClkN         => ddrClkN(2),
         ddrOut          => ddrOut(2),
         ddrInOut        => ddrInOut(2));

   ----------------- 
   -- AXI DDR MIG[3]
   ----------------- 
   U_Mig3 : entity work.Mig3
      generic map (
         TPD_G => TPD_G)
      port map (
         -- System Clock and reset
         sysClk          => sysClock,
         sysRst          => sysReset,
         -- AXI MEM Interface (sysClk domain)
         axiReady        => memReady(0),  -- $::env(NUM_MIG_CORES)  == 1
         axiWriteMasters => memWriteMasters(3 downto 0),
         axiWriteSlaves  => memWriteSlaves(3 downto 0),
         axiReadMasters  => memReadMasters(3 downto 0),
         axiReadSlaves   => memReadSlaves(3 downto 0),
         -- DDR Ports
         ddrClkP         => ddrClkP(3),
         ddrClkN         => ddrClkN(3),
         ddrOut          => ddrOut(3),
         ddrInOut        => ddrInOut(3));

end mapping;
