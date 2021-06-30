-------------------------------------------------------------------------------
-- File       : SlacPgpCardG4Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for SLAC PGP Gen4 board (PCIe GEN3 x 8 lanes)
-- https://confluence.slac.stanford.edu/x/cQbWDw
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
use surf.AxiStreamPkg.all;
use surf.AxiPkg.all;
use surf.I2cPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity SlacPgpCardG4Core is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 8000;
      ROGUE_SIM_CH_COUNT_G : natural range 1 to 256      := 256;
      BUILD_INFO_G         : BuildInfoType;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
      DRIVER_TYPE_ID_G     : slv(31 downto 0)            := x"00000000";
      DMA_BURST_BYTES_G    : positive range 256 to 4096  := 256;
      DMA_SIZE_G           : positive range 1 to 8       := 1);
   port (
      ------------------------
      --  Top Level Interfaces
      ------------------------
      -- DMA Interfaces  (dmaClk domain)
      dmaClk          : out   sl;
      dmaRst          : out   sl;
      dmaBuffGrpPause : out   slv(7 downto 0);
      dmaObMasters    : out   AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves     : in    AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters    : in    AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves     : out   AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- PIP Interface [0x00080000:0009FFFF] (dmaClk domain)
      pipIbMaster     : out   AxiWriteMasterType    := AXI_WRITE_MASTER_INIT_C;
      pipIbSlave      : in    AxiWriteSlaveType     := AXI_WRITE_SLAVE_FORCE_C;
      pipObMaster     : in    AxiWriteMasterType    := AXI_WRITE_MASTER_INIT_C;
      pipObSlave      : out   AxiWriteSlaveType     := AXI_WRITE_SLAVE_FORCE_C;
      -- Application AXI-Lite Interfaces [0x00100000:0x00FFFFFF] (appClk domain)
      appClk          : in    sl                    := '0';
      appRst          : in    sl                    := '1';
      appReadMaster   : out   AxiLiteReadMasterType;
      appReadSlave    : in    AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      appWriteMaster  : out   AxiLiteWriteMasterType;
      appWriteSlave   : in    AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -------------------
      --  Top Level Ports
      -------------------
      -- System Ports
      emcClk          : in    sl;
      pwrScl          : inout sl;
      pwrSda          : inout sl;
      sfpScl          : inout sl;
      sfpSda          : inout sl;
      qsfpScl         : inout slv(1 downto 0);
      qsfpSda         : inout slv(1 downto 0);
      qsfpRstL        : out   slv(1 downto 0);
      qsfpLpMode      : out   slv(1 downto 0);
      qsfpModSelL     : out   slv(1 downto 0);
      qsfpModPrsL     : in    slv(1 downto 0);
      -- Boot Memory Ports
      flashCsL        : out   sl;
      flashMosi       : out   sl;
      flashMiso       : in    sl;
      flashHoldL      : out   sl;
      flashWp         : out   sl;
      -- PCIe Ports
      pciRstL         : in    sl;
      pciRefClkP      : in    sl;
      pciRefClkN      : in    sl;
      pciRxP          : in    slv(7 downto 0);
      pciRxN          : in    slv(7 downto 0);
      pciTxP          : out   slv(7 downto 0);
      pciTxN          : out   slv(7 downto 0));
end SlacPgpCardG4Core;

architecture mapping of SlacPgpCardG4Core is

   constant XBAR_I2C_CONFIG_C : AxiLiteCrossbarMasterConfigArray(3 downto 0) := genAxiLiteConfig(4, x"0007_0000", 16, 12);

   constant SFF8472_I2C_CONFIG_C : I2cAxiLiteDevArray(1 downto 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010000",      -- 2 wire address 1010000X (A0h)
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- No repeat start
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010001",      -- 2 wire address 1010001X (A2h)
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'));          -- Repeat Start

   constant PWR_I2C_C : I2cAxiLiteDevArray(0 downto 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1001000",      -- 0x90 = SA56004ATK
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '0'));          -- No repeat start

   signal dmaReadMaster  : AxiReadMasterType;
   signal dmaReadSlave   : AxiReadSlaveType;
   signal dmaWriteMaster : AxiWriteMasterType;
   signal dmaWriteSlave  : AxiWriteSlaveType;

   signal regReadMaster  : AxiReadMasterType;
   signal regReadSlave   : AxiReadSlaveType;
   signal regWriteMaster : AxiWriteMasterType;
   signal regWriteSlave  : AxiWriteSlaveType;

   signal dmaCtrlReadMasters  : AxiLiteReadMasterArray(2 downto 0);
   signal dmaCtrlReadSlaves   : AxiLiteReadSlaveArray(2 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);
   signal dmaCtrlWriteMasters : AxiLiteWriteMasterArray(2 downto 0);
   signal dmaCtrlWriteSlaves  : AxiLiteWriteSlaveArray(2 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);

   signal phyReadMaster  : AxiLiteReadMasterType;
   signal phyReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal phyWriteMaster : AxiLiteWriteMasterType;
   signal phyWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal intPipIbMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal intPipIbSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_FORCE_C;
   signal intPipObMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal intPipObSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_FORCE_C;

   signal i2cReadMaster  : AxiLiteReadMasterType;
   signal i2cReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal i2cWriteMaster : AxiLiteWriteMasterType;
   signal i2cWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal i2cReadMasters  : AxiLiteReadMasterArray(3 downto 0);
   signal i2cReadSlaves   : AxiLiteReadSlaveArray(3 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);
   signal i2cWriteMasters : AxiLiteWriteMasterArray(3 downto 0);
   signal i2cWriteSlaves  : AxiLiteWriteSlaveArray(3 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);

   signal sysClock    : sl;
   signal sysReset    : sl;
   signal systemReset : sl;
   signal cardReset   : sl;
   signal userClock   : sl;
   signal dmaIrq      : sl;

   signal bootCsL  : slv(1 downto 0);
   signal bootSck  : slv(1 downto 0);
   signal bootMosi : slv(1 downto 0);
   signal bootMiso : slv(1 downto 0);
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);
   signal sck      : sl;

   signal eos      : sl;
   signal userCclk : sl;

begin

   dmaClk <= sysClock;

   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClock,
         rstIn  => systemReset,
         rstOut => dmaRst);

   systemReset <= sysReset or cardReset;

   qsfpRstL(0) <= not(systemReset);
   qsfpRstL(1) <= not(systemReset);
   qsfpLpMode  <= "00";
   qsfpModSelL <= "00";

   ---------------
   -- AXI PCIe PHY
   ---------------
   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate

      U_AxiPciePhy : entity axi_pcie_core.SlacPgpCardG4PciePhyWrapper
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

      intPipObMaster <= pipObMaster;
      pipObSlave     <= intPipObSlave;

      pipIbMaster   <= intPipIbMaster;
      intPipIbSlave <= pipIbSlave;

      U_XBAR : entity surf.AxiLiteCrossbar
         generic map (
            TPD_G              => TPD_G,
            NUM_SLAVE_SLOTS_G  => 1,
            NUM_MASTER_SLOTS_G => 4,
            MASTERS_CONFIG_G   => XBAR_I2C_CONFIG_C)
         port map (
            axiClk              => sysClock,
            axiClkRst           => sysReset,
            sAxiWriteMasters(0) => i2cWriteMaster,
            sAxiWriteSlaves(0)  => i2cWriteSlave,
            sAxiReadMasters(0)  => i2cReadMaster,
            sAxiReadSlaves(0)   => i2cReadSlave,
            mAxiWriteMasters    => i2cWriteMasters,
            mAxiWriteSlaves     => i2cWriteSlaves,
            mAxiReadMasters     => i2cReadMasters,
            mAxiReadSlaves      => i2cReadSlaves);

      U_PwrI2C : entity surf.AxiI2cRegMaster
         generic map (
            TPD_G          => TPD_G,
            DEVICE_MAP_G   => PWR_I2C_C,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
         port map (
            -- I2C Ports
            scl            => pwrScl,
            sda            => pwrSda,
            -- AXI-Lite Register Interface
            axiReadMaster  => i2cReadMasters(3),
            axiReadSlave   => i2cReadSlaves(3),
            axiWriteMaster => i2cWriteMasters(3),
            axiWriteSlave  => i2cWriteSlaves(3),
            -- Clocks and Resets
            axiClk         => sysClock,
            axiRst         => sysReset);

      U_SFP_I2C : entity surf.AxiI2cRegMaster
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
         port map (
            -- I2C Ports
            scl            => sfpScl,
            sda            => sfpSda,
            -- AXI-Lite Register Interface
            axiReadMaster  => i2cReadMasters(2),
            axiReadSlave   => i2cReadSlaves(2),
            axiWriteMaster => i2cWriteMasters(2),
            axiWriteSlave  => i2cWriteSlaves(2),
            -- Clocks and Resets
            axiClk         => sysClock,
            axiRst         => sysReset);

      GEN_QSFP :
      for i in 1 downto 0 generate
         U_I2C : entity surf.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
               AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
            port map (
               -- I2C Ports
               scl            => qsfpScl(i),
               sda            => qsfpSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => i2cReadMasters(i),
               axiReadSlave   => i2cReadSlaves(i),
               axiWriteMaster => i2cWriteMasters(i),
               axiWriteSlave  => i2cWriteSlaves(i),
               -- Clocks and Resets
               axiClk         => sysClock,
               axiRst         => sysReset);
      end generate GEN_QSFP;

   end generate;

   SIM_PCIE : if (ROGUE_SIM_EN_G) generate

      -- Generate local 250 MHz clock
      U_sysClock : entity surf.ClkRst
         generic map (
            CLK_PERIOD_G      => 4 ns,  -- 250 MHz
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => sysClock,
            rst  => sysReset);

      -- Loopback PIP interface
      pipIbMaster <= pipObMaster;
      pipObSlave  <= pipIbSlave;

   end generate;

   ---------------
   -- AXI PCIe REG
   ---------------
   U_REG : entity axi_pcie_core.AxiPcieReg
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_PORT_NUM_G => ROGUE_SIM_PORT_NUM_G,
         BUILD_INFO_G         => BUILD_INFO_G,
         XIL_DEVICE_G         => "ULTRASCALE",
         BOOT_PROM_G          => "SPIx8",
         DRIVER_TYPE_ID_G     => DRIVER_TYPE_ID_G,
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
         DMA_SIZE_G           => DMA_SIZE_G)
      port map (
         -- AXI4 Interfaces
         axiClk              => sysClock,
         axiRst              => sysReset,
         regReadMaster       => regReadMaster,
         regReadSlave        => regReadSlave,
         regWriteMaster      => regWriteMaster,
         regWriteSlave       => regWriteSlave,
         pipIbMaster         => intPipIbMaster,
         pipIbSlave          => intPipIbSlave,
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
         -- I2C AXI-Lite Interfaces (axiClk domain)
         i2cReadMaster       => i2cReadMaster,
         i2cReadSlave        => i2cReadSlave,
         i2cWriteMaster      => i2cWriteMaster,
         i2cWriteSlave       => i2cWriteSlave,
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

   userCclk <= emcClk when(eos = '0') else sck;

   ---------------
   -- AXI PCIe DMA
   ---------------
   U_AxiPcieDma : entity axi_pcie_core.AxiPcieDma
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_PORT_NUM_G => ROGUE_SIM_PORT_NUM_G,
         ROGUE_SIM_CH_COUNT_G => ROGUE_SIM_CH_COUNT_G,
         DMA_SIZE_G           => DMA_SIZE_G,
         DMA_BURST_BYTES_G    => DMA_BURST_BYTES_G,
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G)
      port map (
         axiClk           => sysClock,
         axiRst           => sysReset,
         -- AXI4 Interfaces (
         axiReadMaster    => dmaReadMaster,
         axiReadSlave     => dmaReadSlave,
         axiWriteMaster   => dmaWriteMaster,
         axiWriteSlave    => dmaWriteSlave,
         pipObMaster      => intPipObMaster,
         pipObSlave       => intPipObSlave,
         -- AXI4-Lite Interfaces
         axilReadMasters  => dmaCtrlReadMasters,
         axilReadSlaves   => dmaCtrlReadSlaves,
         axilWriteMasters => dmaCtrlWriteMasters,
         axilWriteSlaves  => dmaCtrlWriteSlaves,
         -- DMA Interfaces
         dmaIrq           => dmaIrq,
         dmaBuffGrpPause  => dmaBuffGrpPause,
         dmaObMasters     => dmaObMasters,
         dmaObSlaves      => dmaObSlaves,
         dmaIbMasters     => dmaIbMasters,
         dmaIbSlaves      => dmaIbSlaves);

end mapping;
