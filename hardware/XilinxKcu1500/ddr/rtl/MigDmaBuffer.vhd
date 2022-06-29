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
   constant AXI_BASE_ADDR_C : Slv64Array(7 downto 0) := (
      0 => x"0000_0000_0000_0000",
      1 => x"0000_0000_8000_0000",
      2 => x"0000_0000_0000_0000",
      3 => x"0000_0000_8000_0000",
      4 => x"0000_0000_0000_0000",
      5 => x"0000_0000_8000_0000",
      6 => x"0000_0000_0000_0000",
      7 => x"0000_0000_8000_0000");

   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 40,  -- Match 40-bit address for axi_pcie_core.AxiPcieCrossbar
      DATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,  -- Matches the AXIS stream
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

   signal syncWriteMasters : AxiWriteMasterArray(7 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal syncWriteSlaves  : AxiWriteSlaveArray(7 downto 0)  := (others => AXI_WRITE_SLAVE_INIT_C);
   signal syncReadMasters  : AxiReadMasterArray(7 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
   signal syncReadSlaves   : AxiReadSlaveArray(7 downto 0)   := (others => AXI_READ_SLAVE_INIT_C);

   signal sAxisCtrl : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);

   signal ddrRdy    : slv(7 downto 0);
   signal axiReady  : slv(7 downto 0);
   signal axisReset : slv(DMA_SIZE_G-1 downto 0);
   signal axiReset  : slv(3 downto 0);

begin

   ddrRdy <= ddrReady(3) & ddrReady(3) & ddrReady(2) & ddrReady(2) & ddrReady(1) & ddrReady(1) & ddrReady(0) & ddrReady(0);
   U_axiReady : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 8)
      port map (
         clk     => axisClk,
         dataIn  => ddrRdy,
         dataOut => axiReady);

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

      U_pause : entity surf.Synchronizer
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => eventClk,
            dataIn  => sAxisCtrl(i).pause,
            dataOut => eventTrigMsgCtrl(i).pause);

      U_AxiFifo : entity surf.AxiStreamDmaV2Fifo
         generic map (
            TPD_G              => TPD_G,
            -- FIFO Configuration
            BUFF_FRAME_WIDTH_G => AXI_BUFFER_WIDTH_C-10,  -- Optimized to fix into 1 BRAM (10-bit address) for free list
            AXI_BUFFER_WIDTH_G => AXI_BUFFER_WIDTH_C,
            SYNTH_MODE_G       => "xpm",
            MEMORY_TYPE_G      => "block",
            -- AXI Stream Configurations
            AXIS_CONFIG_G      => DMA_AXIS_CONFIG_G,
            -- AXI4 Configurations
            AXI_BASE_ADDR_G    => AXI_BASE_ADDR_C(i),
            AXI_CONFIG_G       => DMA_AXI_CONFIG_C)
         port map (
            -- AXI4 Interface (axiClk domain)
            axiClk          => axisClk,
            axiRst          => axisReset(i),
            axiReady        => axiReady(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i),
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            -- AXI Stream Interface (axiClk domain)
            sAxisMaster     => sAxisMasters(i),
            sAxisSlave      => sAxisSlaves(i),
            sAxisCtrl       => sAxisCtrl(i),
            mAxisMaster     => mAxisMasters(i),
            mAxisSlave      => mAxisSlaves(i),
            -- Optional: AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

   end generate;

   GEN_XBAR : for i in 3 downto 0 generate

      -- Help with timing
      U_AxiRst : entity surf.RstPipeline
         generic map (
            TPD_G     => TPD_G,
            INV_RST_G => false)
         port map (
            clk    => axisClk,
            rstIn  => axisRst,
            rstOut => axiReset(i));

      -- Reuse the AxiPcieCrossbar for the MIGT DMA Buffer
      U_XBAR : entity axi_pcie_core.AxiPcieCrossbar
         generic map (
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            AXI_PCIE_CONFIG_G => INT_DMA_AXI_CONFIG_C,
            DMA_SIZE_G        => 2)
         port map (
            axiClk                       => axisClk,
            axiRst                       => axiReset(i),
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
            mAxiWriteMaster              => syncWriteMasters(i),
            mAxiWriteSlave               => syncWriteSlaves(i),
            mAxiReadMaster               => syncReadMasters(i),
            mAxiReadSlave                => syncReadSlaves(i));

      U_DdrSync : entity axi_pcie_core.MigClkConvtWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            -- USER AXI Memory Interface (axiClk domain)
            axiClk         => axisClk,
            axiRst         => axiReset(i),
            axiWriteMaster => syncWriteMasters(i),
            axiWriteSlave  => syncWriteSlaves(i),
            axiReadMaster  => syncReadMasters(i),
            axiReadSlave   => syncReadSlaves(i),
            -- DDR AXI Memory Interface (ddrClk domain)
            ddrClk         => ddrClk(i),
            ddrRst         => ddrRst(i),
            ddrWriteMaster => ddrWriteMasters(i),
            ddrWriteSlave  => ddrWriteSlaves(i),
            ddrReadMaster  => ddrReadMasters(i),
            ddrReadSlave   => ddrReadSlaves(i));

   end generate;

end mapping;
