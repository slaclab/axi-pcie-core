-------------------------------------------------------------------------------
-- File       : XilinxKcu1500Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx KCU1500 board (PCIe GEN3 x 8 lanes)
-- https://www.xilinx.com/products/boards-and-kits/kcu1500.html
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
use surf.I2cMuxPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxKcu1500Core is
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
      userClk156      : out   sl;
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
      -- User General Purpose AXI4 Interfaces (dmaClk domain)
      usrReadMaster   : in    AxiReadMasterType     := AXI_READ_MASTER_INIT_C;
      usrReadSlave    : out   AxiReadSlaveType      := AXI_READ_SLAVE_FORCE_C;
      usrWriteMaster  : in    AxiWriteMasterType    := AXI_WRITE_MASTER_INIT_C;
      usrWriteSlave   : out   AxiWriteSlaveType     := AXI_WRITE_SLAVE_FORCE_C;
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
      userClkP        : in    sl;
      userClkN        : in    sl;
      i2cRstL         : out   sl;
      i2cScl          : inout sl;
      i2cSda          : inout sl;
      -- QSFP[0] Ports
      qsfp0RstL       : out   sl;
      qsfp0LpMode     : out   sl;
      qsfp0ModSelL    : out   sl;
      qsfp0ModPrsL    : in    sl                    := '0';
      -- QSFP[1] Ports
      qsfp1RstL       : out   sl;
      qsfp1LpMode     : out   sl;
      qsfp1ModSelL    : out   sl;
      qsfp1ModPrsL    : in    sl                    := '0';
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
end XilinxKcu1500Core;

architecture mapping of XilinxKcu1500Core is

   constant XBAR_I2C_CONFIG_C : AxiLiteCrossbarMasterConfigArray(5 downto 0) := genAxiLiteConfig(6, x"0007_0000", 16, 12);

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
   signal i2cReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal i2cWriteMaster : AxiLiteWriteMasterType;
   signal i2cWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   signal i2cReadMasters  : AxiLiteReadMasterArray(5 downto 0);
   signal i2cReadSlaves   : AxiLiteReadSlaveArray(5 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal i2cWriteMasters : AxiLiteWriteMasterArray(5 downto 0);
   signal i2cWriteSlaves  : AxiLiteWriteSlaveArray(5 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal i2ci : i2c_in_type;
   signal i2coVec : i2c_out_array(6 downto 0) := (
      others    => (
         scl    => '1',
         scloen => '1',
         sda    => '1',
         sdaoen => '1',
         enable => '0'));
   signal i2co : i2c_out_type;

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
   signal userClk  : sl;

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

   U_IBUFDS : IBUFDS
      port map(
         I  => userClkP,
         IB => userClkN,
         O  => userClk);

   U_BUFG : BUFG
      port map(
         I  => userClk,
         O  => userClk156);

   i2cRstL      <= not(systemReset);
   qsfp0RstL    <= not(systemReset);
   qsfp1RstL    <= not(systemReset);
   qsfp0LpMode  <= '0';
   qsfp1LpMode  <= '0';
   qsfp0ModSelL <= '0';
   qsfp1ModSelL <= '0';

   ---------------
   -- AXI PCIe PHY
   ---------------
   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate

      U_AxiPciePhy : entity axi_pcie_core.XilinxKcu1500PciePhyWrapper
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

      U_XbarI2cMux : entity surf.AxiLiteCrossbarI2cMux
         generic map (
            TPD_G              => TPD_G,
            -- I2C MUX Generics
            MUX_DECODE_MAP_G   => I2C_MUX_DECODE_MAP_TCA9548_C,
            I2C_MUX_ADDR_G     => b"1110_100",
            I2C_SCL_FREQ_G     => 400.0E+3,  -- units of Hz
            AXIL_CLK_FREQ_G    => DMA_CLK_FREQ_C,
            -- AXI-Lite Crossbar Generics
            NUM_MASTER_SLOTS_G => 6,
            MASTERS_CONFIG_G   => XBAR_I2C_CONFIG_C)
         port map (
            -- Clocks and Resets
            axilClk           => sysClock,
            axilRst           => sysReset,
            -- Slave AXI-Lite Interface
            sAxilWriteMaster  => i2cWriteMaster,
            sAxilWriteSlave   => i2cWriteSlave,
            sAxilReadMaster   => i2cReadMaster,
            sAxilReadSlave    => i2cReadSlave,
            -- Master AXI-Lite Interfaces
            mAxilWriteMasters => i2cWriteMasters,
            mAxilWriteSlaves  => i2cWriteSlaves,
            mAxilReadMasters  => i2cReadMasters,
            mAxilReadSlaves   => i2cReadSlaves,
            -- I2C MUX Ports
            i2ci              => i2ci,
            i2co              => i2coVec(6));

      U_QSFP1 : entity surf.AxiI2cRegMasterCore
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
         port map (
            -- I2C Ports
            i2ci           => i2ci,
            i2co           => i2coVec(1),
            -- AXI-Lite Register Interface
            axiReadMaster  => i2cReadMasters(1),
            axiReadSlave   => i2cReadSlaves(1),
            axiWriteMaster => i2cWriteMasters(1),
            axiWriteSlave  => i2cWriteSlaves(1),
            -- Clocks and Resets
            axiClk         => sysClock,
            axiRst         => sysReset);

      U_QSFP0 : entity surf.AxiI2cRegMasterCore
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => SFF8472_I2C_CONFIG_C,
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
         port map (
            -- I2C Ports
            i2ci           => i2ci,
            i2co           => i2coVec(4),
            -- AXI-Lite Register Interface
            axiReadMaster  => i2cReadMasters(4),
            axiReadSlave   => i2cReadSlaves(4),
            axiWriteMaster => i2cWriteMasters(4),
            axiWriteSlave  => i2cWriteSlaves(4),
            -- Clocks and Resets
            axiClk         => sysClock,
            axiRst         => sysReset);

      process(i2cReadMasters, i2cWriteMasters, i2coVec)
         variable tmp : i2c_out_type;
      begin
         -- Init
         tmp := i2coVec(6);
         -- Check for TXN after XBAR/I2C_MUX
         for i in 0 to 5 loop
            if (i2cWriteMasters(i).awvalid = '1') or (i2cReadMasters(i).arvalid = '1') then
               tmp := i2coVec(i);
            end if;
         end loop;
         -- Return result
         i2co <= tmp;
      end process;

      IOBUF_SCL : IOBUF
         port map (
            O  => i2ci.scl,
            IO => i2cScl,
            I  => i2co.scl,
            T  => i2co.scloen);

      IOBUF_SDA : IOBUF
         port map (
            O  => i2ci.sda,
            IO => i2cSda,
            I  => i2co.sda,
            T  => i2co.sdaoen);

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
         PCIE_HW_TYPE_G       => HW_TYPE_XILINX_KCU1500_C,
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
         -- DMA AXI4 Interfaces (
         axiReadMaster    => dmaReadMaster,
         axiReadSlave     => dmaReadSlave,
         axiWriteMaster   => dmaWriteMaster,
         axiWriteSlave    => dmaWriteSlave,
         -- PIP AXI4 Interfaces
         pipObMaster      => intPipObMaster,
         pipObSlave       => intPipObSlave,
         -- User General Purpose AXI4 Interfaces
         usrReadMaster    => usrReadMaster,
         usrReadSlave     => usrReadSlave,
         usrWriteMaster   => usrWriteMaster,
         usrWriteSlave    => usrWriteSlave,
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
