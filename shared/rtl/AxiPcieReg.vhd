-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI-Lite Crossbar and Register Access
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
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;
use axi_pcie_core.AxiPcieSharedPkg.all;

entity AxiPcieReg is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 8000;
      BUILD_INFO_G         : BuildInfoType;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
      XIL_DEVICE_G         : string                      := "7SERIES";
      BOOT_PROM_G          : string                      := "BPI";
      DRIVER_TYPE_ID_G     : slv(31 downto 0)            := x"00000000";
      PCIE_HW_TYPE_G       : slv(31 downto 0)            := HW_TYPE_UNDEFINED_C;
      EN_DEVICE_DNA_G      : boolean                     := true;
      EN_ICAP_G            : boolean                     := true;
      DMA_SIZE_G           : positive range 1 to 16      := 1);
   port (
      -- AXI4 Interfaces (axiClk domain)
      axiClk              : in  sl;
      axiRst              : in  sl;
      regReadMaster       : in  AxiReadMasterType;
      regReadSlave        : out AxiReadSlaveType;
      regWriteMaster      : in  AxiWriteMasterType;
      regWriteSlave       : out AxiWriteSlaveType;
      pipIbMaster         : out AxiWriteMasterType    := AXI_WRITE_MASTER_INIT_C;
      pipIbSlave          : in  AxiWriteSlaveType     := AXI_WRITE_SLAVE_FORCE_C;
      -- DMA AXI-Lite Interfaces (axiClk domain)
      dmaCtrlReadMasters  : out AxiLiteReadMasterArray(2 downto 0);
      dmaCtrlReadSlaves   : in  AxiLiteReadSlaveArray(2 downto 0);
      dmaCtrlWriteMasters : out AxiLiteWriteMasterArray(2 downto 0);
      dmaCtrlWriteSlaves  : in  AxiLiteWriteSlaveArray(2 downto 0);
      -- PHY AXI-Lite Interfaces (axiClk domain)
      phyReadMaster       : out AxiLiteReadMasterType;
      phyReadSlave        : in  AxiLiteReadSlaveType;
      phyWriteMaster      : out AxiLiteWriteMasterType;
      phyWriteSlave       : in  AxiLiteWriteSlaveType;
      -- I2C AXI-Lite Interfaces (axiClk domain)
      i2cReadMaster       : out AxiLiteReadMasterType;
      i2cReadSlave        : in  AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      i2cWriteMaster      : out AxiLiteWriteMasterType;
      i2cWriteSlave       : in  AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
      -- Application AXI-Lite Interfaces [0x00028000:0x00028FFF] (appClk domain)
      appClk              : in  sl;
      appRst              : in  sl;
      appReadMaster       : out AxiLiteReadMasterType;
      appReadSlave        : in  AxiLiteReadSlaveType;
      appWriteMaster      : out AxiLiteWriteMasterType;
      appWriteSlave       : in  AxiLiteWriteSlaveType;
      -- GPU AXI-Lite Interfaces [0x00100000:0x00FFFFFF] (appClk domain)
      gpuReadMaster       : out AxiLiteReadMasterType;
      gpuReadSlave        : in  AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      gpuWriteMaster      : out AxiLiteWriteMasterType;
      gpuWriteSlave       : in  AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
      -- Application Force reset
      cardResetIn         : in  sl;
      cardResetOut        : out sl;
      -- BPI Boot Memory Ports
      bpiAddr             : out slv(25 downto 0);
      bpiRstL             : out sl;
      bpiCeL              : out sl;
      bpiOeL              : out sl;
      bpiWeL              : out sl;
      bpiTri              : out sl;
      bpiDin              : out slv(15 downto 0);
      bpiDout             : in  slv(15 downto 0)      := x"FFFF";
      -- SPI Boot Memory Ports
      spiCsL              : out slv(1 downto 0);
      spiSck              : out slv(1 downto 0);
      spiMosi             : out slv(1 downto 0);
      spiMiso             : in  slv(1 downto 0)       := "11");
end AxiPcieReg;

architecture mapping of AxiPcieReg is

   constant DMA_INDEX_C     : natural := 0;
   constant PHY_INDEX_C     : natural := 1;
   constant VERSION_INDEX_C : natural := 2;
   constant GPU_INDEX_C     : natural := 3;
   constant BPI_INDEX_C     : natural := 4;
   constant SPI0_INDEX_C    : natural := 5;
   constant SPI1_INDEX_C    : natural := 6;
   constant AXIS_MON_IB_C   : natural := 7;
   constant AXIS_MON_OB_C   : natural := 8;
   constant I2C_INDEX_C     : natural := 9;
   -- constant APP0_INDEX_C    : natural := XXX; -- Now used for PIP interface
   constant APP1_INDEX_C    : natural := 10;
   constant APP2_INDEX_C    : natural := 11;
   constant APP3_INDEX_C    : natural := 12;
   constant APP4_INDEX_C    : natural := 13;

   constant NUM_AXI_MASTERS_C : natural := 14;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := (
      DMA_INDEX_C     => (
         baseAddr     => x"0000_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      PHY_INDEX_C     => (
         baseAddr     => x"0001_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      VERSION_INDEX_C => (
         baseAddr     => x"0002_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      GPU_INDEX_C     => (
         baseAddr     => x"0002_8000",
         addrBits     => 12,
         connectivity => x"FFFF"),
      BPI_INDEX_C     => (
         baseAddr     => x"0003_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      SPI0_INDEX_C    => (
         baseAddr     => x"0004_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      SPI1_INDEX_C    => (
         baseAddr     => x"0005_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      AXIS_MON_IB_C   => (
         baseAddr     => x"0006_0000",
         addrBits     => 15,
         connectivity => x"FFFF"),
      AXIS_MON_OB_C   => (
         baseAddr     => x"0006_8000",
         addrBits     => 15,
         connectivity => x"FFFF"),
      I2C_INDEX_C     => (
         baseAddr     => x"0007_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
--      APP0_INDEX_C    => (
--         baseAddr     => x"0008_0000",
--         addrBits     => 19,
--         connectivity => x"FFFF"),
      APP1_INDEX_C    => (
         baseAddr     => x"0010_0000",
         addrBits     => 20,
         connectivity => x"FFFF"),
      APP2_INDEX_C    => (
         baseAddr     => x"0020_0000",
         addrBits     => 21,
         connectivity => x"FFFF"),
      APP3_INDEX_C    => (
         baseAddr     => x"0040_0000",
         addrBits     => 22,
         connectivity => x"FFFF"),
      APP4_INDEX_C    => (
         baseAddr     => x"0080_0000",
         addrBits     => 23,
         connectivity => x"FFFF"));

   constant APP_CROSSBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(0 downto 0) := (
      0               => (
         baseAddr     => x"00000000",
         addrBits     => 24,
         connectivity => x"FFFF"));

   signal maskWriteMaster : AxiWriteMasterType;
   signal maskWriteSlave  : AxiWriteSlaveType;
   signal maskReadMaster  : AxiReadMasterType;
   signal maskReadSlave   : AxiReadSlaveType;

   signal muxWriteMaster : AxiWriteMasterType;
   signal muxWriteSlave  : AxiWriteSlaveType;

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal mAxilReadMaster  : AxiLiteReadMasterType;
   signal mAxilReadSlave   : AxiLiteReadSlaveType;
   signal mAxilWriteMaster : AxiLiteWriteMasterType;
   signal mAxilWriteSlave  : AxiLiteWriteSlaveType;

   signal userValues : Slv32Array(0 to 63) := (others => x"00000000");
   signal spiBusyIn  : slv(1 downto 0);
   signal spiBusyOut : slv(1 downto 0);

   signal cardResetApp : sl;
   signal appRstTmp    : sl;
   signal appRstInt    : sl;
   signal appRstAxi    : sl;
   signal appClkFreq   : slv(31 downto 0);

begin

   ---------------------------------------------------------------------------------------------
   -- Driver Polls the userValues to determine the firmware's configurations and interrupt state
   ---------------------------------------------------------------------------------------------
   process(appClkFreq, appRstAxi)
      variable i : natural;
   begin
      -- Number of DMA lanes (defined by user)
      userValues(0) <= toSlv(DMA_SIZE_G, 32);

      -- Reserved
      userValues(1) <= x"00000001";

      -- Driver TYPE ID (defined by user)
      userValues(2) <= DRIVER_TYPE_ID_G;

      -- FPGA Fabric Type
      if (XIL_DEVICE_G = "ULTRASCALE") then
         userValues(3) <= x"00000000";
      elsif (XIL_DEVICE_G = "7SERIES") then
         userValues(3) <= x"00000001";
      else
         userValues(3) <= x"FFFFFFFF";
      end if;

      -- System Clock Frequency
      userValues(4) <= toSlv(getTimeRatio(DMA_CLK_FREQ_C, 1.0), 32);

      -- PROM configuration
      if (BOOT_PROM_G = "BPI") then
         userValues(5) <= x"00000000";
      elsif (BOOT_PROM_G = "SPIx8") then
         userValues(5) <= x"00000001";
      elsif (BOOT_PROM_G = "SPIx4") then
         userValues(5) <= x"00000002";
      else
         userValues(5) <= x"FFFFFFFF";
      end if;

      -- DMA AXI Stream Configuration
      userValues(6)(31 downto 24) <= toSlv(DMA_AXIS_CONFIG_G.TDATA_BYTES_C, 8);
      userValues(6)(23 downto 20) <= toSlv(DMA_AXIS_CONFIG_G.TDEST_BITS_C, 4);
      userValues(6)(19 downto 16) <= toSlv(DMA_AXIS_CONFIG_G.TUSER_BITS_C, 4);
      userValues(6)(15 downto 12) <= toSlv(DMA_AXIS_CONFIG_G.TID_BITS_C, 4);

      case DMA_AXIS_CONFIG_G.TKEEP_MODE_C is
         when TKEEP_NORMAL_C => userValues(6)(11 downto 8) <= x"0";
         when TKEEP_COMP_C   => userValues(6)(11 downto 8) <= x"1";
         when TKEEP_FIXED_C  => userValues(6)(11 downto 8) <= x"2";
         when TKEEP_COUNT_C  => userValues(6)(11 downto 8) <= x"3";
         when others         => userValues(6)(11 downto 8) <= x"F";
      end case;

      case DMA_AXIS_CONFIG_G.TUSER_MODE_C is
         when TUSER_NORMAL_C     => userValues(6)(7 downto 4) <= x"0";
         when TUSER_FIRST_LAST_C => userValues(6)(7 downto 4) <= x"1";
         when TUSER_LAST_C       => userValues(6)(7 downto 4) <= x"2";
         when TUSER_NONE_C       => userValues(6)(7 downto 4) <= x"3";
         when others             => userValues(6)(7 downto 4) <= x"F";
      end case;

      -- Application Reset
      userValues(6)(1) <= ite(DMA_AXIS_CONFIG_G.TSTRB_EN_C, '1', '0');
      userValues(6)(0) <= appRstAxi;

      -- PCIE PHY AXI Configuration
      userValues(7)(31 downto 24) <= toSlv(AXI_PCIE_CONFIG_C.ADDR_WIDTH_C, 8);
      userValues(7)(23 downto 16) <= toSlv(AXI_PCIE_CONFIG_C.DATA_BYTES_C, 8);
      userValues(7)(15 downto 8)  <= toSlv(AXI_PCIE_CONFIG_C.ID_BITS_C, 8);
      userValues(7)(7 downto 0)   <= toSlv(AXI_PCIE_CONFIG_C.LEN_BITS_C, 8);

      -- Application Clock Frequency
      userValues(8) <= appClkFreq;

      -- PCIe Hardware Type
      userValues(9) <= PCIE_HW_TYPE_G;

      -- Set unused to zero
      for i in 63 downto 10 loop
         userValues(i) <= x"00000000";
      end loop;

   end process;

   ----------------------------------------
   -- Mask off upper address for 16 MB BAR0
   ----------------------------------------
   MASK_ADDR : process (regReadMaster, regWriteMaster) is
      variable tmpWr : AxiWriteMasterType;
      variable tmpRd : AxiReadMasterType;
   begin
      tmpWr := regWriteMaster;
      tmpRd := regReadMaster;

      tmpWr.awaddr(63 downto 24) := (others => '0');
      tmpRd.araddr(63 downto 24) := (others => '0');

      maskWriteMaster <= tmpWr;
      maskReadMaster  <= tmpRd;
   end process;

   regWriteSlave <= maskWriteSlave;
   regReadSlave  <= maskReadSlave;

   -------------------------
   -- AXI-to-AXI-Lite Bridge
   -------------------------
   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate

      U_AxiPcieRegWriteMux : entity axi_pcie_core.AxiPcieRegWriteMux
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Clock and Reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Slave AXI4 Interface
            sAxiWriteMaster => maskWriteMaster,
            sAxiWriteSlave  => maskWriteSlave,
            -- Master AXI4 Interface
            pipIbMaster     => pipIbMaster,
            pipIbSlave      => pipIbSlave,
            muxWriteMaster  => muxWriteMaster,
            muxWriteSlave   => muxWriteSlave);

      U_AxiToAxiLite : entity surf.AxiToAxiLite
         generic map (
            TPD_G           => TPD_G,
            EN_SLAVE_RESP_G => false)
         port map (
            axiClk          => axiClk,
            axiClkRst       => axiRst,
            axiReadMaster   => maskReadMaster,
            axiReadSlave    => maskReadSlave,
            axiWriteMaster  => muxWriteMaster,
            axiWriteSlave   => muxWriteSlave,
            axilReadMaster  => axilReadMaster,
            axilReadSlave   => axilReadSlave,
            axilWriteMaster => axilWriteMaster,
            axilWriteSlave  => axilWriteSlave);

   end generate;

   SIM_PCIE : if (ROGUE_SIM_EN_G) generate
      U_TcpToAxiLite : entity surf.RogueTcpMemoryWrap
         generic map (
            TPD_G      => TPD_G,
            PORT_NUM_G => ROGUE_SIM_PORT_NUM_G+0)
         port map (
            axilClk         => axiClk,
            axilRst         => axiRst,
            axilReadMaster  => axilReadMaster,
            axilReadSlave   => axilReadSlave,
            axilWriteMaster => axilWriteMaster,
            axilWriteSlave  => axilWriteSlave);
   end generate;

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => ite(ROGUE_SIM_EN_G, AXI_RESP_DECERR_C, AXI_RESP_OK_C),
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         axiClk              => axiClk,
         axiClkRst           => axiRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   --------------------------
   -- AXI-Lite Version Module
   --------------------------
   U_Version : entity surf.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         DEVICE_ID_G     => DRIVER_TYPE_ID_G,
         CLK_PERIOD_G    => (1.0/DMA_CLK_FREQ_C),
         EN_DEVICE_DNA_G => EN_DEVICE_DNA_G,
         XIL_DEVICE_G    => XIL_DEVICE_G,
         EN_ICAP_G       => EN_ICAP_G)
      port map (
         -- AXI-Lite Interface
         axiClk         => axiClk,
         axiRst         => axiRst,
         axiReadMaster  => axilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => axilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => axilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(VERSION_INDEX_C),
         -- Optional: User Reset
         userReset      => cardResetOut,
         -- Optional: user values
         userValues     => userValues);

   --------------------------------------
   -- Map the AXI-Lite to AxiGpuAsyncCore
   --------------------------------------
   U_GpuAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 12)
      port map (
         -- Slave Interface
         sAxiClk         => axiClk,
         sAxiClkRst      => axiRst,
         sAxiReadMaster  => axilReadMasters(GPU_INDEX_C),
         sAxiReadSlave   => axilReadSlaves(GPU_INDEX_C),
         sAxiWriteMaster => axilWriteMasters(GPU_INDEX_C),
         sAxiWriteSlave  => axilWriteSlaves(GPU_INDEX_C),
         -- Master Interface
         mAxiClk         => appClk,
         mAxiClkRst      => appRstInt,
         mAxiReadMaster  => gpuWriteMaster,
         mAxiReadSlave   => gpuWriteSlave,
         mAxiWriteMaster => gpuReadMaster,
         mAxiWriteSlave  => gpuReadSlave);

   -----------------------------
   -- AXI-Lite Boot Flash Module
   -----------------------------
   GEN_BPI : if (BOOT_PROM_G = "BPI") and (not ROGUE_SIM_EN_G) generate

      U_BootProm : entity surf.AxiMicronMt28ewReg
         generic map (
            TPD_G          => TPD_G,
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_C)
         port map (
            -- FLASH Interface
            flashAddr      => bpiAddr,
            flashRstL      => bpiRstL,
            flashCeL       => bpiCeL,
            flashOeL       => bpiOeL,
            flashWeL       => bpiWeL,
            flashTri       => bpiTri,
            flashDin       => bpiDin,
            flashDout      => bpiDout,
            -- AXI-Lite Register Interface
            axiReadMaster  => axilReadMasters(BPI_INDEX_C),
            axiReadSlave   => axilReadSlaves(BPI_INDEX_C),
            axiWriteMaster => axilWriteMasters(BPI_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(BPI_INDEX_C),
            -- Clocks and Resets
            axiClk         => axiClk,
            axiRst         => axiRst);

      GEN_VEC : for i in 1 downto 0 generate
         spiCsL  <= (others => '1');
         spiSck  <= (others => '1');
         spiMosi <= (others => '1');
      end generate GEN_VEC;

   end generate;

   GEN_SPI : if (BOOT_PROM_G = "SPIx4" or BOOT_PROM_G = "SPIx8") and (not ROGUE_SIM_EN_G) generate

      bpiAddr <= (others => '1');
      bpiRstL <= '1';
      bpiCeL  <= '1';
      bpiOeL  <= '1';
      bpiWeL  <= '1';
      bpiTri  <= '1';
      bpiDin  <= (others => '1');

      spiBusyIn(0) <= spiBusyOut(1);
      spiBusyIn(1) <= spiBusyOut(0);

      GEN_VEC : for i in 1 downto 0 generate

         U_BootProm : entity surf.AxiMicronN25QCore
            generic map (
               TPD_G          => TPD_G,
               AXI_CLK_FREQ_G => DMA_CLK_FREQ_C,        -- units of Hz
               SPI_CLK_FREQ_G => (DMA_CLK_FREQ_C/8.0))  -- units of Hz
            port map (
               -- FLASH Memory Ports
               csL            => spiCsL(i),
               sck            => spiSck(i),
               mosi           => spiMosi(i),
               miso           => spiMiso(i),
               -- Shared SPI Interface
               busyIn         => spiBusyIn(i),
               busyOut        => spiBusyOut(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => axilReadMasters(SPI0_INDEX_C+i),
               axiReadSlave   => axilReadSlaves(SPI0_INDEX_C+i),
               axiWriteMaster => axilWriteMasters(SPI0_INDEX_C+i),
               axiWriteSlave  => axilWriteSlaves(SPI0_INDEX_C+i),
               -- Clocks and Resets
               axiClk         => axiClk,
               axiRst         => axiRst);

      end generate GEN_VEC;

   end generate;

   GEN_NO_PROM : if (BOOT_PROM_G /= "BPI" and BOOT_PROM_G /= "SPIx4" and BOOT_PROM_G /= "SPIx8") or (ROGUE_SIM_EN_G) generate

      bpiAddr <= (others => '1');
      bpiRstL <= '1';
      bpiCeL  <= '1';
      bpiOeL  <= '1';
      bpiWeL  <= '1';
      bpiTri  <= '1';
      bpiDin  <= (others => '1');

      GEN_VEC : for i in 1 downto 0 generate

         spiCsL  <= (others => '1');
         spiSck  <= (others => '1');
         spiMosi <= (others => '1');

      end generate GEN_VEC;

   end generate;

   ---------------------------------
   -- Map the AXI-Lite to DMA Engine
   ---------------------------------
   dmaCtrlWriteMasters(0)       <= axilWriteMasters(DMA_INDEX_C);
   axilWriteSlaves(DMA_INDEX_C) <= dmaCtrlWriteSlaves(0);
   dmaCtrlReadMasters(0)        <= axilReadMasters(DMA_INDEX_C);
   axilReadSlaves(DMA_INDEX_C)  <= dmaCtrlReadSlaves(0);

   dmaCtrlWriteMasters(1)         <= axilWriteMasters(AXIS_MON_IB_C);
   axilWriteSlaves(AXIS_MON_IB_C) <= dmaCtrlWriteSlaves(1);
   dmaCtrlReadMasters(1)          <= axilReadMasters(AXIS_MON_IB_C);
   axilReadSlaves(AXIS_MON_IB_C)  <= dmaCtrlReadSlaves(1);

   dmaCtrlWriteMasters(2)         <= axilWriteMasters(AXIS_MON_OB_C);
   axilWriteSlaves(AXIS_MON_OB_C) <= dmaCtrlWriteSlaves(2);
   dmaCtrlReadMasters(2)          <= axilReadMasters(AXIS_MON_OB_C);
   axilReadSlaves(AXIS_MON_OB_C)  <= dmaCtrlReadSlaves(2);

   -------------------------------
   -- Map the AXI-Lite to PCIe PHY
   -------------------------------
   phyWriteMaster               <= axilWriteMasters(PHY_INDEX_C);
   axilWriteSlaves(PHY_INDEX_C) <= phyWriteSlave;
   phyReadMaster                <= axilReadMasters(PHY_INDEX_C);
   axilReadSlaves(PHY_INDEX_C)  <= phyReadSlave;

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
         sAxiReadMaster  => axilReadMasters(I2C_INDEX_C),
         sAxiReadSlave   => axilReadSlaves(I2C_INDEX_C),
         sAxiWriteMaster => axilWriteMasters(I2C_INDEX_C),
         sAxiWriteSlave  => axilWriteSlaves(I2C_INDEX_C),
         -- AXI-Lite Register Interface
         mAxiReadMaster  => i2cReadMaster,
         mAxiReadSlave   => i2cReadSlave,
         mAxiWriteMaster => i2cWriteMaster,
         mAxiWriteSlave  => i2cWriteSlave);

   --------------------------------------
   -- Combine APP AXI-Lite buses together
   --------------------------------------
   U_APP_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => ite(ROGUE_SIM_EN_G, AXI_RESP_DECERR_C, AXI_RESP_OK_C),
         NUM_SLAVE_SLOTS_G  => (APP4_INDEX_C-APP1_INDEX_C+1),
         NUM_MASTER_SLOTS_G => 1,
         MASTERS_CONFIG_G   => APP_CROSSBAR_CONFIG_C)
      port map (
         axiClk              => axiClk,
         axiClkRst           => axiRst,
         sAxiWriteMasters    => axilWriteMasters(APP4_INDEX_C downto APP1_INDEX_C),
         sAxiWriteSlaves     => axilWriteSlaves(APP4_INDEX_C downto APP1_INDEX_C),
         sAxiReadMasters     => axilReadMasters(APP4_INDEX_C downto APP1_INDEX_C),
         sAxiReadSlaves      => axilReadSlaves(APP4_INDEX_C downto APP1_INDEX_C),
         mAxiWriteMasters(0) => mAxilWriteMaster,
         mAxiWriteSlaves(0)  => mAxilWriteSlave,
         mAxiReadMasters(0)  => mAxilReadMaster,
         mAxiReadSlaves(0)   => mAxilReadSlave);

   ----------------------------------
   -- Synchronize cardRestIn to appClk
   ----------------------------------
   U_AppResetSync1 : entity surf.RstSync
      port map (
         clk      => appClk,
         asyncRst => cardResetIn,
         syncRst  => cardResetApp);

   -- Tie cardReset to appRst
   appRstTmp <= cardResetApp or appRst;

   -- Resynchronize the or'd reset
   U_AppResetSync2 : entity surf.RstSync
      port map (
         clk      => appClk,
         asyncRst => appRstTmp,
         syncRst  => appRstInt);

   -- Synchronize appRstInt back to AXI clock for readout
   U_AppResetSync3 : entity surf.Synchronizer
      port map (
         clk     => axiClk,
         dataIn  => appRstInt,
         dataOut => appRstAxi);


   ----------------------------------
   -- Map the AXI-Lite to Application
   ----------------------------------
   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 24)
      port map (
         -- Slave Interface
         sAxiClk         => axiClk,
         sAxiClkRst      => axiRst,
         sAxiReadMaster  => mAxilReadMaster,
         sAxiReadSlave   => mAxilReadSlave,
         sAxiWriteMaster => mAxilWriteMaster,
         sAxiWriteSlave  => mAxilWriteSlave,
         -- Master Interface
         mAxiClk         => appClk,
         mAxiClkRst      => appRstInt,
         mAxiReadMaster  => appReadMaster,
         mAxiReadSlave   => appReadSlave,
         mAxiWriteMaster => appWriteMaster,
         mAxiWriteSlave  => appWriteSlave);


   U_appClkFreq : entity surf.SyncClockFreq
      generic map (
         TPD_G          => TPD_G,
         REF_CLK_FREQ_G => DMA_CLK_FREQ_C,
         REFRESH_RATE_G => 1.0,
         CNT_WIDTH_G    => 32)
      port map (
         -- Frequency Measurement (locClk domain)
         freqOut => appClkFreq,
         -- Clocks
         clkIn   => appClk,
         locClk  => axiClk,
         refClk  => axiClk);

end mapping;
