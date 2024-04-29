-------------------------------------------------------------------------------
-- File       : AbacoFMC134Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx KCU105 board (PCIe GEN3 x 8 lanes)
-- https://www.xilinx.com/products/boards-and-kits/kcu105.html
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


library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;
use axi_pcie_core.AxiPcieSharedPkg.all;


use surf.I2cPkg.all;
use surf.I2cMuxPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AbacoPC821Core is
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
      -- Application AXI-Lite Interfaces [0x00100000:0x00FFFFFF] (appClk domain)
      appClk          : in    sl;
      appRst          : in    sl;
      appReadMaster   : out   AxiLiteReadMasterType;
      appReadSlave    : in    AxiLiteReadSlaveType;
      appWriteMaster  : out   AxiLiteWriteMasterType;
      appWriteSlave   : in    AxiLiteWriteSlaveType;
      -------------------
      --  Top Level Ports
      -------------------
      -- System Ports
      -- i2cRstL         : out   sl;
      i2cScl          : inout sl;
      i2cSda          : inout sl;
      -- Boot Memory Ports
      flashAddr       : out   slv(25 downto 0);
      flashData       : inout slv(15 downto 4);
      flashOeL        : out   sl;
      flashWeL        : out   sl;
      -- PCIe Ports
      pciRstL         : in    sl;
      pciRefClkP      : in    sl;
      pciRefClkN      : in    sl;
      pciRxP          : in    slv(7 downto 0);
      pciRxN          : in    slv(7 downto 0);
      pciTxP          : out   slv(7 downto 0);
      pciTxN          : out   slv(7 downto 0));
end AbacoPC821Core;

architecture mapping of AbacoPC821Core is

   constant XBAR_I2C_CONFIG_C : AxiLiteCrossbarMasterConfigArray(5 downto 0) := genAxiLiteConfig(6, x"0007_0000", 16, 12);
   constant FMC134_CPLD_I2C_CONFIG_C :I2cAxiLiteDevArray(0 downto 0) := (
      0              => MakeI2cAxiLiteDevType( "0011100", 8, 8, '0' ));
      
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
   signal dmaIrq      : sl;

   signal bpiCeL  : sl;
   signal bpiDin  : slv(15 downto 0);
   signal bpiDout : slv(15 downto 0);
   signal bpiTri  : sl;
   signal bpiDts  : slv(3 downto 0);
   signal i2cRstL : sl;
   -- signal dmaBuffGrpPause : slv(7 downto 0);

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

   i2cRstL      <= not(systemReset);

   ---------------
   -- AXI PCIe PHY
   ---------------
   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate
      U_AxiPciePhy : entity axi_pcie_core.AbacoPc821PciePhyWrapper
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
   end generate;
   SIM_PCIE : if (ROGUE_SIM_EN_G) generate
      U_sysClock : entity surf.ClkRst
         generic map (
            CLK_PERIOD_G      => 4 ns,  -- 250 MHz
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => sysClock,
            rst  => sysReset);
   end generate;


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

      U_CPLD : entity surf.AxiI2cRegMasterCore
         generic map (
            TPD_G          => TPD_G,
            I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            DEVICE_MAP_G   => FMC134_CPLD_I2C_CONFIG_C,
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
         BOOT_PROM_G          => "BPI",  -- s29gl01gs-bpi-x16
         DRIVER_TYPE_ID_G     => DRIVER_TYPE_ID_G,
         PCIE_HW_TYPE_G       => HW_TYPE_ABACO_PC821_TYPE_C,
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
         -- I2C AXI-Lite Interfaces
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
         -- Boot Memory Ports
         bpiAddr             => flashAddr,
         bpiCeL              => bpiCeL,
         bpiOeL              => flashOeL,
         bpiWeL              => flashWeL,
         bpiDin              => bpiDin,
         bpiDout             => bpiDout,
         bpiTri              => bpiTri);

   bpiDts <= (others => bpiTri);

   GEN_IOBUF :
   for i in 15 downto 4 generate
      IOBUF_inst : IOBUF
         port map (
            O  => bpiDout(i),           -- Buffer output
            IO => flashData(i),  -- Buffer inout port (connect directly to top-level port)
            I  => bpiDin(i),            -- Buffer input
            T  => bpiTri);  -- 3-state enable input, high=input, low=output
   end generate GEN_IOBUF;

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstream
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => bpiDout(3 downto 0),  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
         DO        => bpiDin(3 downto 0),  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => bpiDts,  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bpiCeL,  -- 1-bit input: Controls the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypted Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => '0',              -- 1-bit input: User CCLK input
         USRCCLKTS => '1',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '0',  -- 1-bit input: User DONE pin output control
         USRDONETS => '1');  -- 1-bit input: User DONE 3-state enable output

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