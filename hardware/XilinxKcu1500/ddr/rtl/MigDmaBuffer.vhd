-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: MIG DMA buffer
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library axi_pcie_core;
use axi_pcie_core.MigPkg.all;

entity MigDmaBuffer is
   generic (
      TPD_G             : time                  := 1 ns;
      DMA_SIZE_G        : positive range 1 to 8 := 8;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      AXIL_BASE_ADDR_G  : slv(31 downto 0));
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Trigger Event streams (eventClk domain)
      eventClk         : in  sl;
      eventTrigMsgCtrl : out AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);
      -- AXI Stream Interface (axisClk domain)
      axisClk          : in  sl;
      axisRst          : in  sl;
      sAxisMasters     : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      mAxisMasters     : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      mAxisSlaves      : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- DDR AXI MEM Interface
      ddrClk           : in  slv(3 downto 0);
      ddrRst           : in  slv(3 downto 0);
      ddrReady         : in  slv(3 downto 0);
      ddrWriteMasters  : out AxiWriteMasterArray(3 downto 0);
      ddrWriteSlaves   : in  AxiWriteSlaveArray(3 downto 0);
      ddrReadMasters   : out AxiReadMasterArray(3 downto 0);
      ddrReadSlaves    : in  AxiReadSlaveArray(3 downto 0));
end MigDmaBuffer;

architecture mapping of MigDmaBuffer is

   constant AXI_BUFFER_WIDTH_C : positive := MEM_AXI_CONFIG_C.ADDR_WIDTH_C-1;  -- 1 DDR DIMM split between 2 DMA lanes
   constant AXI_BASE_ADDR_C : Slv64Array(1 downto 0) := (
      0 => toSlv(0, 64),
      1 => toSlv(2**AXI_BUFFER_WIDTH_C, 64));  -- Units of bytes

   constant INT_DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 3,
      TKEEP_MODE_C  => TKEEP_COUNT_C,  -- AXI DMA V2 uses TKEEP_COUNT_C to help meet timing
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,  -- Match 40-bit address for axi_pcie_core.AxiPcieCrossbar
      DATA_BYTES_C => INT_DMA_AXIS_CONFIG_C.TDATA_BYTES_C,  -- Matches the AXIS stream
      ID_BITS_C    => MEM_AXI_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => MEM_AXI_CONFIG_C.LEN_BITS_C);

   constant INT_DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,  -- Match 40-bit address for axi_pcie_core.AxiPcieCrossbar
      DATA_BYTES_C => MEM_AXI_CONFIG_C.DATA_BYTES_C,  -- Actual memory interface width
      ID_BITS_C    => MEM_AXI_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => MEM_AXI_CONFIG_C.LEN_BITS_C);

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(DMA_SIZE_G-1 downto 0) := genAxiLiteConfig(DMA_SIZE_G, AXIL_BASE_ADDR_G, 12, 8);

   signal axilWriteMasters : AxiLiteWriteMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(DMA_SIZE_G-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal axiWriteMasters : AxiWriteMasterArray(7 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(7 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal axiReadMasters  : AxiReadMasterArray(7 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal axiReadSlaves   : AxiReadSlaveArray(7 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal unusedWriteMasters : AxiWriteMasterArray(7 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal unusedWriteSlaves  : AxiWriteSlaveArray(7 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal unusedReadMasters  : AxiReadMasterArray(7 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal unusedReadSlaves   : AxiReadSlaveArray(7 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal sAxisCtrl : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);

   signal rxMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal txMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal txSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal ddrClock  : slv(7 downto 0);
   signal ddrReset  : slv(7 downto 0);
   signal ddrRdy    : slv(7 downto 0);
   signal axisReset : slv(7 downto 0);

begin

   ddrClock <= ddrClk(3) & ddrClk(3) & ddrClk(2) & ddrClk(2) & ddrClk(1) & ddrClk(1) & ddrClk(0) & ddrClk(0);
   ddrReset <= ddrRst(3) & ddrRst(3) & ddrRst(2) & ddrRst(2) & ddrRst(1) & ddrRst(1) & ddrRst(0) & ddrRst(0);
   ddrRdy   <= ddrReady(3) & ddrReady(3) & ddrReady(2) & ddrReady(2) & ddrReady(1) & ddrReady(1) & ddrReady(0) & ddrReady(0);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => DMA_SIZE_G,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   GEN_FIFO : for i in DMA_SIZE_G-1 downto 0 generate

      -- Help with timing
      U_AxisRst : entity surf.RstPipeline
         generic map (
            TPD_G     => TPD_G,
            INV_RST_G => false)
         port map (
            clk    => axisClk,
            rstIn  => axisRst,
            rstOut => axisReset(i));

      --------------------------
      -- Inbound AXI Stream FIFO
      --------------------------
      U_IbFifo : entity surf.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 1,
            -- FIFO configurations
            MEMORY_TYPE_G       => "block",
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => INT_DMA_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => axisClk,
            sAxisRst    => axisReset(i),
            sAxisMaster => sAxisMasters(i),
            sAxisSlave  => sAxisSlaves(i),
            -- Master Port
            mAxisClk    => ddrClock(i),
            mAxisRst    => ddrReset(i),
            mAxisMaster => rxMasters(i),
            mAxisSlave  => rxSlaves(i));

      U_AxiFifo : entity surf.AxiStreamDmaV2Fifo
         generic map (
            TPD_G              => TPD_G,
            -- FIFO Configuration
            BUFF_FRAME_WIDTH_G => AXI_BUFFER_WIDTH_C-10,  -- Optimized to fix into 1 BRAM (10-bit address) for free list
            AXI_BUFFER_WIDTH_G => AXI_BUFFER_WIDTH_C,
            SYNTH_MODE_G       => "xpm",
            MEMORY_TYPE_G      => "block",
            -- AXI Stream Configurations
            AXIS_CONFIG_G      => INT_DMA_AXIS_CONFIG_C,
            -- AXI4 Configurations
            AXI_BASE_ADDR_G    => AXI_BASE_ADDR_C(i mod 2),
            AXI_CONFIG_G       => DMA_AXI_CONFIG_C)
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => ddrClock(i),
            axiRst          => ddrReset(i),
            axiReady        => ddrRdy(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i),
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            -- AXI Stream Interface (axiClk domain)
            sAxisMaster     => rxMasters(i),
            sAxisSlave      => rxSlaves(i),
            sAxisCtrl       => sAxisCtrl(i),
            mAxisMaster     => txMasters(i),
            mAxisSlave      => txSlaves(i),
            -- Optional: AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_pause : entity surf.Synchronizer
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => eventClk,
            dataIn  => sAxisCtrl(i).pause,
            dataOut => eventTrigMsgCtrl(i).pause);

      U_ObFifo : entity surf.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 1,
            -- FIFO configurations
            MEMORY_TYPE_G       => "block",
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => INT_DMA_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
         port map (
            -- Slave Port
            sAxisClk    => ddrClock(i),
            sAxisRst    => ddrReset(i),
            sAxisMaster => txMasters(i),
            sAxisSlave  => txSlaves(i),
            -- Master Port
            mAxisClk    => axisClk,
            mAxisRst    => axisReset(i),
            mAxisMaster => mAxisMasters(i),
            mAxisSlave  => mAxisSlaves(i));

   end generate;

   GEN_XBAR : for i in 3 downto 0 generate
      -- Reuse the AxiPcieCrossbar for the MIG DMA Buffer
      U_XBAR : entity axi_pcie_core.AxiPcieCrossbar
         generic map (
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            AXI_PCIE_CONFIG_G => INT_DMA_AXI_CONFIG_C,
            DMA_SIZE_G        => 2)
         port map (
            axiClk                       => ddrClk(i),
            axiRst                       => ddrRst(i),
            -- Slave Write Masters
            sAxiWriteMasters(3)          => unusedWriteMasters(i+4),  -- General Purpose AXI path
            sAxiWriteMasters(2 downto 1) => axiWriteMasters(2*i+1 downto 2*i),
            sAxiWriteMasters(0)          => unusedWriteMasters(i+0),  -- PIP path
            -- Slave Write Slaves
            sAxiWriteSlaves(3)           => unusedWriteSlaves(i+4),  -- General Purpose AXI path
            sAxiWriteSlaves(2 downto 1)  => axiWriteSlaves(2*i+1 downto 2*i),
            sAxiWriteSlaves(0)           => unusedWriteSlaves(i+0),  -- PIP path
            -- Slave Read Masters
            sAxiReadMasters(3)           => unusedReadMasters(i+4),  -- General Purpose AXI path
            sAxiReadMasters(2 downto 1)  => axiReadMasters(2*i+1 downto 2*i),
            sAxiReadMasters(0)           => unusedReadMasters(i+0),  -- PIP path
            -- Slave Read Slaves
            sAxiReadSlaves(3)            => unusedReadSlaves(i+4),  -- General Purpose AXI path
            sAxiReadSlaves(2 downto 1)   => axiReadSlaves(2*i+1 downto 2*i),
            sAxiReadSlaves(0)            => unusedReadSlaves(i+0),  -- PIP path
            -- Master
            mAxiWriteMaster              => ddrWriteMasters(i),
            mAxiWriteSlave               => ddrWriteSlaves(i),
            mAxiReadMaster               => ddrReadMasters(i),
            mAxiReadSlave                => ddrReadSlaves(i));
   end generate;

end mapping;
