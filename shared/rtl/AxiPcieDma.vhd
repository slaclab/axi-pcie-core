-------------------------------------------------------------------------------
-- File       : AxiPcieDma.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AXIS DMA Engine
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
use surf.SsiPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

entity AxiPcieDma is
   generic (
      TPD_G                : time                         := 1 ns;
      ROGUE_SIM_EN_G       : boolean                      := false;
      ROGUE_SIM_PORT_NUM_G : positive range 1024 to 49151 := 8000;
      ROGUE_SIM_CH_COUNT_G : positive range 1 to 256      := 256;
      SIMULATION_G         : boolean                      := false;
      DMA_BURST_BYTES_G    : positive range 256 to 4096   := 256;
      DMA_SIZE_G           : positive range 1 to 8        := 1;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType          := ssiAxiStreamConfig(16);
      INT_PIPE_STAGES_G    : natural range 0 to 16        := 1;
      PIPE_STAGES_G        : natural range 0 to 16        := 1;
      DESC_SYNTH_MODE_G    : string                       := "inferred";
      DESC_MEMORY_TYPE_G   : string                       := "block";
      DESC_ARB_G           : boolean                      := false);  -- false = Round robin to help with timing
   port (
      -- Clock and Reset
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- PCIe AXI4 Interfaces (axiClk domain)
      axiReadMaster    : out AxiReadMasterType;
      axiReadSlave     : in  AxiReadSlaveType;
      axiWriteMaster   : out AxiWriteMasterType;
      axiWriteSlave    : in  AxiWriteSlaveType;
      -- PIP AXI4 Interfaces (axiClk domain)
      pipObMaster      : in  AxiWriteMasterType                 := AXI_WRITE_MASTER_INIT_C;
      pipObSlave       : out AxiWriteSlaveType                  := AXI_WRITE_SLAVE_FORCE_C;
      -- User General Purpose AXI4 Interfaces (axiClk domain)
      usrReadMaster    : in  AxiReadMasterType                  := AXI_READ_MASTER_INIT_C;
      usrReadSlave     : out AxiReadSlaveType                   := AXI_READ_SLAVE_FORCE_C;
      usrWriteMaster   : in  AxiWriteMasterType                 := AXI_WRITE_MASTER_INIT_C;
      usrWriteSlave    : out AxiWriteSlaveType                  := AXI_WRITE_SLAVE_FORCE_C;
      -- AXI4-Lite Interfaces (axiClk domain)
      axilReadMasters  : in  AxiLiteReadMasterArray(2 downto 0);
      axilReadSlaves   : out AxiLiteReadSlaveArray(2 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);
      axilWriteMasters : in  AxiLiteWriteMasterArray(2 downto 0);
      axilWriteSlaves  : out AxiLiteWriteSlaveArray(2 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
      -- DMA Interfaces (axiClk domain)
      dmaIrq           : out sl                                 := '0';
      dmaBuffGrpPause  : out slv(7 downto 0)                    := (others => '0');
      dmaObMasters     : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves      : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters     : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves      : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0));
end AxiPcieDma;

architecture mapping of AxiPcieDma is

   constant INT_DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => DMA_AXIS_CONFIG_G.TDATA_BYTES_C,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 3,
      TKEEP_MODE_C  => TKEEP_COUNT_C,   -- AXI DMA V2 uses TKEEP_COUNT_C to help meet timing
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   -- DMA AXI Configuration
   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => AXI_PCIE_CONFIG_C.ADDR_WIDTH_C,
      DATA_BYTES_C => INT_DMA_AXIS_CONFIG_C.TDATA_BYTES_C,  -- Matches the AXIS stream
      ID_BITS_C    => AXI_PCIE_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => AXI_PCIE_CONFIG_C.LEN_BITS_C);

   signal dmaReadMasters  : AxiReadMasterArray(DMA_SIZE_G downto 0);
   signal dmaReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G downto 0);
   signal dmaWriteMasters : AxiWriteMasterArray(DMA_SIZE_G downto 0);
   signal dmaWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G downto 0);

   signal axiReadMasters  : AxiReadMasterArray(DMA_SIZE_G+1 downto 0);
   signal axiReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G+1 downto 0);
   signal axiWriteMasters : AxiWriteMasterArray(DMA_SIZE_G+1 downto 0);
   signal axiWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G+1 downto 0);

   signal sAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
   signal sAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);

   signal mAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
   signal mAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
   signal mAxisCtrl    : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0);

   signal axisReset : slv(DMA_SIZE_G-1 downto 0);

   attribute dont_touch              : string;
   attribute dont_touch of axisReset : signal is "true";

begin

   REAL_PCIE : if (not ROGUE_SIM_EN_G) generate

      ----------------
      -- AXI PCIe XBAR
      -----------------
      U_XBAR : entity axi_pcie_core.AxiPcieCrossbar
         generic map (
            TPD_G             => TPD_G,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            AXI_PCIE_CONFIG_G => AXI_PCIE_CONFIG_C,
            DMA_SIZE_G        => DMA_SIZE_G)
         port map (
            axiClk           => axiClk,
            axiRst           => axiRst,
            -- Slaves
            sAxiWriteMasters => axiWriteMasters,
            sAxiWriteSlaves  => axiWriteSlaves,
            sAxiReadMasters  => axiReadMasters,
            sAxiReadSlaves   => axiReadSlaves,
            -- Master
            mAxiWriteMaster  => axiWriteMaster,
            mAxiWriteSlave   => axiWriteSlave,
            mAxiReadMaster   => axiReadMaster,
            mAxiReadSlave    => axiReadSlave);

      -----------
      -- DMA Core
      -----------
      U_V2Gen : entity surf.AxiStreamDmaV2
         generic map (
            TPD_G              => TPD_G,
            DESC_AWIDTH_G      => 12,    -- 4096 entries
            DESC_ARB_G         => DESC_ARB_G,
            DESC_SYNTH_MODE_G  => DESC_SYNTH_MODE_G,
            DESC_MEMORY_TYPE_G => DESC_MEMORY_TYPE_G,
            AXIL_BASE_ADDR_G   => x"00000000",
            AXI_READY_EN_G     => true,  -- Using "Packet FIFO" option in AXI Interconnect IP core
            AXIS_READY_EN_G    => false,
            AXIS_CONFIG_G      => INT_DMA_AXIS_CONFIG_C,
            AXI_DMA_CONFIG_G   => DMA_AXI_CONFIG_C,
            CHAN_COUNT_G       => DMA_SIZE_G,
            RD_PIPE_STAGES_G   => 1,
            BURST_BYTES_G      => DMA_BURST_BYTES_G,
            RD_PEND_THRESH_G   => 1)
         port map (
            -- Clock/Reset
            axiClk          => axiClk,
            axiRst          => axiRst,
            -- Register Access & Interrupt
            axilReadMaster  => axilReadMasters(0),
            axilReadSlave   => axilReadSlaves(0),
            axilWriteMaster => axilWriteMasters(0),
            axilWriteSlave  => axilWriteSlaves(0),
            interrupt       => dmaIrq,
            buffGrpPause    => dmaBuffGrpPause,
            -- AXI Stream Interface
            sAxisMasters    => sAxisMasters,
            sAxisSlaves     => sAxisSlaves,
            mAxisMasters    => mAxisMasters,
            mAxisSlaves     => mAxisSlaves,
            mAxisCtrl       => mAxisCtrl,
            -- AXI Interfaces, 0 = Desc, 1-CHAN_COUNT_G = DMA
            axiReadMasters  => dmaReadMasters,
            axiReadSlaves   => dmaReadSlaves,
            axiWriteCtrl    => (others => AXI_CTRL_UNUSED_C),
            axiWriteMasters => dmaWriteMasters,
            axiWriteSlaves  => dmaWriteSlaves);

      ------------------------------------------------------------------------
      -- axi[0].[read]  = DMA descriptor's AXI read
      -- axi[0].[write] = Outbound PIP interface
      -- axi[DMA_SIZE_G:1].[read/write] = Mapped to DMA_SIZE_G DMA lanes
      -- axi[DMA_SIZE_G+1].[read/write] = User General Purpose
      ------------------------------------------------------------------------

      -- Map the DMA descriptor's AXI read
      axiReadMasters(0) <= dmaReadMasters(0);
      dmaReadSlaves(0)  <= axiReadSlaves(0);

      -- Map PIP Interface
      axiWriteMasters(0) <= pipObMaster;
      pipObSlave         <= axiWriteSlaves(0);
      dmaWriteSlaves(0)  <= AXI_WRITE_SLAVE_FORCE_C;  -- Terminate unused write bus

      -- Map DMA AXI interfaces
      axiReadMasters(DMA_SIZE_G downto 1)  <= dmaReadMasters(DMA_SIZE_G downto 1);
      dmaReadSlaves(DMA_SIZE_G downto 1)   <= axiReadSlaves(DMA_SIZE_G downto 1);
      axiWriteMasters(DMA_SIZE_G downto 1) <= dmaWriteMasters(DMA_SIZE_G downto 1);
      dmaWriteSlaves(DMA_SIZE_G downto 1)  <= axiWriteSlaves(DMA_SIZE_G downto 1);

      -- Map User General Purpose AXI interfaces
      axiReadMasters(DMA_SIZE_G+1)  <= usrReadMaster;
      usrReadSlave                  <= axiReadSlaves(DMA_SIZE_G+1);
      axiWriteMasters(DMA_SIZE_G+1) <= usrWriteMaster;
      usrWriteSlave                 <= axiWriteSlaves(DMA_SIZE_G+1);

      GEN_AXIS_FIFO : for i in DMA_SIZE_G-1 downto 0 generate

         -- Help with timing
         U_AxisRst : entity surf.RstPipeline
            generic map (
               TPD_G     => TPD_G,
               INV_RST_G => false)
            port map (
               clk    => axiClk,
               rstIn  => axiRst,
               rstOut => axisReset(i));

         --------------------------
         -- Inbound AXI Stream FIFO
         --------------------------
         U_IbFifo : entity surf.AxiStreamFifoV2
            generic map (
               -- General Configurations
               TPD_G               => TPD_G,
               INT_PIPE_STAGES_G   => INT_PIPE_STAGES_G,
               PIPE_STAGES_G       => PIPE_STAGES_G,
               SLAVE_READY_EN_G    => true,
               VALID_THOLD_G       => 1,
               -- FIFO configurations
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => true,
               FIFO_ADDR_WIDTH_G   => 9,
               -- AXI Stream Port Configurations
               SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
               MASTER_AXI_CONFIG_G => INT_DMA_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => axiClk,
               sAxisRst    => axisReset(i),
               sAxisMaster => dmaIbMasters(i),
               sAxisSlave  => dmaIbSlaves(i),
               -- Master Port
               mAxisClk    => axiClk,
               mAxisRst    => axisReset(i),
               mAxisMaster => sAxisMasters(i),
               mAxisSlave  => sAxisSlaves(i));

         ---------------------------
         -- Outbound AXI Stream FIFO
         ---------------------------
         U_ObFifo : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               INT_PIPE_STAGES_G   => INT_PIPE_STAGES_G,
               PIPE_STAGES_G       => PIPE_STAGES_G,
               SLAVE_READY_EN_G    => false,
               VALID_THOLD_G       => 1,
               -- FIFO configurations
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => true,
               FIFO_ADDR_WIDTH_G   => 9,
               FIFO_FIXED_THRESH_G => true,
               FIFO_PAUSE_THRESH_G => 300,  -- 1800 byte buffer before pause and 1696 byte of buffer before FIFO FULL
               -- AXI Stream Port Configurations
               SLAVE_AXI_CONFIG_G  => INT_DMA_AXIS_CONFIG_C,
               MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
            port map (
               -- Slave Port
               sAxisClk    => axiClk,
               sAxisRst    => axisReset(i),
               sAxisMaster => mAxisMasters(i),
               sAxisSlave  => mAxisSlaves(i),
               sAxisCtrl   => mAxisCtrl(i),
               -- Master Port
               mAxisClk    => axiClk,
               mAxisRst    => axisReset(i),
               mAxisMaster => dmaObMasters(i),
               mAxisSlave  => dmaObSlaves(i));

      end generate;

      ----------------------------------
      -- Monitor the Inbound DMA streams
      ----------------------------------
      DMA_AXIS_MON_IB : entity surf.AxiStreamMonAxiL
         generic map(
            TPD_G            => TPD_G,
            COMMON_CLK_G     => true,
            AXIS_CLK_FREQ_G  => DMA_CLK_FREQ_C,
            AXIS_NUM_SLOTS_G => DMA_SIZE_G,
            AXIS_CONFIG_G    => INT_DMA_AXIS_CONFIG_C)
         port map(
            -- AXIS Stream Interface
            axisClk          => axiClk,
            axisRst          => axiRst,
            axisMasters      => sAxisMasters,
            axisSlaves       => sAxisSlaves,
            -- AXI lite slave port for register access
            axilClk          => axiClk,
            axilRst          => axiRst,
            sAxilWriteMaster => axilWriteMasters(1),
            sAxilWriteSlave  => axilWriteSlaves(1),
            sAxilReadMaster  => axilReadMasters(1),
            sAxilReadSlave   => axilReadSlaves(1));

      -----------------------------------
      -- Monitor the Outbound DMA streams
      -----------------------------------
      DMA_AXIS_MON_OB : entity surf.AxiStreamMonAxiL
         generic map(
            TPD_G            => TPD_G,
            COMMON_CLK_G     => true,
            AXIS_CLK_FREQ_G  => DMA_CLK_FREQ_C,
            AXIS_NUM_SLOTS_G => DMA_SIZE_G,
            AXIS_CONFIG_G    => INT_DMA_AXIS_CONFIG_C)
         port map(
            -- AXIS Stream Interface
            axisClk          => axiClk,
            axisRst          => axiRst,
            axisMasters      => mAxisMasters,
            axisSlaves       => (others => AXI_STREAM_SLAVE_FORCE_C),  -- U_ObFifo.SLAVE_READY_EN_G=false
            -- AXI lite slave port for register access
            axilClk          => axiClk,
            axilRst          => axiRst,
            sAxilWriteMaster => axilWriteMasters(2),
            sAxilWriteSlave  => axilWriteSlaves(2),
            sAxilReadMaster  => axilReadMasters(2),
            sAxilReadSlave   => axilReadSlaves(2));

   end generate;

   SIM_PCIE : if (ROGUE_SIM_EN_G) generate

      GEN_VEC : for i in DMA_SIZE_G-1 downto 0 generate
         -------------------------------------------------------
         -- DMA.LANE.TDEST Mapping:
         -------------------------------------------------------
         -- DMA[Lane=0][TDEST=0] maps to TCP ports ROGUE_SIM_PORT_NUM_G+2
         -- DMA[Lane=0][TDEST=1] maps to TCP ports ROGUE_SIM_PORT_NUM_G+4
         -- DMA[Lane=0][TDEST=2] maps to TCP ports ROGUE_SIM_PORT_NUM_G+6
         -- .....
         -- .....
         -- DMA[Lane=0][TDEST=255] maps to TCP ports ROGUE_SIM_PORT_NUM_G+512
         -- DMA[Lane=1][TDEST=0] maps to TCP ports ROGUE_SIM_PORT_NUM_G+514
         -- DMA[Lane=1][TDEST=1] maps to TCP ports ROGUE_SIM_PORT_NUM_G+516
         -- .....
         -- .....
         -------------------------------------------------------

         U_DMA_LANE : entity surf.RogueTcpStreamWrap
            generic map (
               TPD_G         => TPD_G,
               PORT_NUM_G    => (ROGUE_SIM_PORT_NUM_G + i*512 + 2),
               SSI_EN_G      => true,
               CHAN_COUNT_G  => ROGUE_SIM_CH_COUNT_G,
               AXIS_CONFIG_G => DMA_AXIS_CONFIG_G)
            port map (
               axisClk     => axiClk,
               axisRst     => axiRst,
               sAxisMaster => dmaIbMasters(i),
               sAxisSlave  => dmaIbSlaves(i),
               mAxisMaster => dmaObMasters(i),
               mAxisSlave  => dmaObSlaves(i));
      end generate GEN_VEC;

   end generate;

end mapping;
