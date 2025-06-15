-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx Alveo U55c board (PCIe GEN3 x 16 lanes)
-- https://www.xilinx.com/products/boards-and-kits/alveo/u55c.html
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

library unisim;
use unisim.vcomponents.all;

entity XilinxAlveoV80Core is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 8000;
      ROGUE_SIM_CH_COUNT_G : natural range 1 to 256      := 256;
      BUILD_INFO_G         : BuildInfoType;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
      DRIVER_TYPE_ID_G     : slv(31 downto 0)            := x"00000000";
      DMA_BURST_BYTES_G    : positive range 256 to 4096  := 256;
      DATAGPU_EN_G         : boolean                     := false;
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
      -- GPU AXI-Lite Interfaces [0x00028000:0x00028FFF] (appClk domain)
      gpuReadMaster   : out   AxiLiteReadMasterType;
      gpuReadSlave    : in    AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      gpuWriteMaster  : out   AxiLiteWriteMasterType;
      gpuWriteSlave   : in    AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -------------------
      --  Top Level Ports
      -------------------
      -- PS DDR Ports
      psDdrDq         : inout slv(71 downto 0);
      psDdrDqsT       : inout slv(8 downto 0);
      psDdrDqsC       : inout slv(8 downto 0);
      psDdrAdr        : out   slv(16 downto 0);
      psDdrBa         : out   slv(1 downto 0);
      psDdrBg         : out   slv(0 to 0);
      psDdrActN       : out   slv(0 to 0);
      psDdrResetN     : out   slv(0 to 0);
      psDdrCkT        : out   slv(0 to 0);
      psDdrCkC        : out   slv(0 to 0);
      psDdrCke        : out   slv(0 to 0);
      psDdrCsN        : out   slv(0 to 0);
      psDdrDmN        : inout slv(8 downto 0);
      psDdrOdt        : out   slv(0 to 0);
      psDdrClkP       : in    slv(0 to 0);
      psDdrClkN       : in    slv(0 to 0);
      -- PCIe Ports
      pciRefClkP      : in    sl;
      pciRefClkN      : in    sl;
      pciRxP          : in    slv(7 downto 0);
      pciRxN          : in    slv(7 downto 0);
      pciTxP          : out   slv(7 downto 0);
      pciTxN          : out   slv(7 downto 0));
end XilinxAlveoV80Core;

architecture mapping of XilinxAlveoV80Core is

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

   signal sysClock     : sl;
   signal sysReset     : sl;
   signal systemReset  : sl;
   signal systemResetL : sl;
   signal cardReset    : sl;
   signal dmaIrq       : sl;

begin

   dmaClk <= sysClock;

   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClock,
         rstIn  => systemReset,
         rstOut => dmaRst);

   systemReset  <= sysReset or cardReset;
   systemResetL <= not(systemReset);

   ---------------
   -- AXI PCIe PHY
   ---------------
   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate

      U_AxiPciePhy : entity axi_pcie_core.XilinxAlveoV80PciePhyWrapper
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
            -- PS DDR Ports
            psDdrDq        => psDdrDq,
            psDdrDqsT      => psDdrDqsT,
            psDdrDqsC      => psDdrDqsC,
            psDdrAdr       => psDdrAdr,
            psDdrBa        => psDdrBa,
            psDdrBg        => psDdrBg,
            psDdrActN      => psDdrActN,
            psDdrResetN    => psDdrResetN,
            psDdrCkT       => psDdrCkT,
            psDdrCkC       => psDdrCkC,
            psDdrCke       => psDdrCke,
            psDdrCsN       => psDdrCsN,
            psDdrDmN       => psDdrDmN,
            psDdrOdt       => psDdrOdt,
            psDdrClkP      => psDdrClkP,
            psDdrClkN      => psDdrClkN,
            -- PCIe Ports
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
         XIL_DEVICE_G         => "VERSAL",
         BOOT_PROM_G          => "NONE",
         DRIVER_TYPE_ID_G     => DRIVER_TYPE_ID_G,
         PCIE_HW_TYPE_G       => HW_TYPE_XILINX_V80_C,
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
         DATAGPU_EN_G         => DATAGPU_EN_G,
         EN_DEVICE_DNA_G      => false,
         EN_ICAP_G            => false,
         GEN_SYSMON_G         => false,
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
         i2cReadMaster       => open,
         i2cReadSlave        => AXI_LITE_READ_SLAVE_EMPTY_OK_C,
         i2cWriteMaster      => open,
         i2cWriteSlave       => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C,
         -- (Optional) Application AXI-Lite Interfaces
         appClk              => appClk,
         appRst              => appRst,
         appReadMaster       => appReadMaster,
         appReadSlave        => appReadSlave,
         appWriteMaster      => appWriteMaster,
         appWriteSlave       => appWriteSlave,
         -- (Optional) GPU AXI-Lite Interfaces
         gpuReadMaster       => gpuReadMaster,
         gpuReadSlave        => gpuReadSlave,
         gpuWriteMaster      => gpuWriteMaster,
         gpuWriteSlave       => gpuWriteSlave,
         -- Application Force reset
         cardResetOut        => cardReset,
         cardResetIn         => systemReset);

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
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
         DESC_SYNTH_MODE_G    => "xpm",
         DESC_MEMORY_TYPE_G   => "ultra")
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
