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

use work.StdRtlPkg.all;
use work.SsiPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPciePkg.all;

entity AxiPcieDma is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 8000;
      ROGUE_SIM_CH_COUNT_G : natural range 1 to 256      := 256;
      SIMULATION_G         : boolean                     := false;
      DMA_SIZE_G           : positive range 1 to 8       := 1;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType         := ssiAxiStreamConfig(16);
      INT_PIPE_STAGES_G    : natural range 0 to 1        := 1;
      PIPE_STAGES_G        : natural range 0 to 1        := 1;
      DESC_ARB_G           : boolean                     := true);
   port (
      axiClk           : in  sl;
      axiRst           : in  sl;
      -- AXI4 Interfaces (axiClk domain)
      axiReadMaster    : out AxiReadMasterType;
      axiReadSlave     : in  AxiReadSlaveType;
      axiWriteMaster   : out AxiWriteMasterType;
      axiWriteSlave    : in  AxiWriteSlaveType;
      -- AXI4-Lite Interfaces (axiClk domain)
      axilReadMasters  : in  AxiLiteReadMasterArray(2 downto 0);
      axilReadSlaves   : out AxiLiteReadSlaveArray(2 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);
      axilWriteMasters : in  AxiLiteWriteMasterArray(2 downto 0);
      axilWriteSlaves  : out AxiLiteWriteSlaveArray(2 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
      -- DMA Interfaces (axiClk domain)
      dmaIrq           : out sl                                 := '0';
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
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COUNT_C,  -- AXI DMA V2 uses TKEEP_COUNT_C to help meet timing
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   -- DMA AXI Configuration   
   constant DMA_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => AXI_PCIE_CONFIG_C.ADDR_WIDTH_C,
      DATA_BYTES_C => INT_DMA_AXIS_CONFIG_C.TDATA_BYTES_C,  -- Matches the AXIS stream
      ID_BITS_C    => AXI_PCIE_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => AXI_PCIE_CONFIG_C.LEN_BITS_C);

   -- AXI DMA descriptor  
   constant AXI_DESC_CONFIG_C : AxiConfigType             := (
      ADDR_WIDTH_C => AXI_PCIE_CONFIG_C.ADDR_WIDTH_C,
      DATA_BYTES_C => ite((AXI_PCIE_CONFIG_C.ADDR_WIDTH_C <= 32) or (DMA_AXI_CONFIG_C.DATA_BYTES_C = 8), 8, 16),  -- 64-bits wide if address space <= 32-bits ELSE 128b wide for 64-bit support
      ID_BITS_C    => AXI_PCIE_CONFIG_C.ID_BITS_C,
      LEN_BITS_C   => AXI_PCIE_CONFIG_C.LEN_BITS_C);

   signal axiReadMasters  : AxiReadMasterArray(DMA_SIZE_G downto 0);
   signal axiReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G downto 0);
   signal axiWriteMasters : AxiWriteMasterArray(DMA_SIZE_G downto 0);
   signal axiWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G downto 0);

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
      U_XBAR : entity work.AxiPcieCrossbar
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
      U_V2Gen : entity work.AxiStreamDmaV2
         generic map (
            TPD_G             => TPD_G,
            DESC_AWIDTH_G     => 12,    -- 4096 entries
            DESC_ARB_G        => DESC_ARB_G,
            AXIL_BASE_ADDR_G  => x"00000000",
            AXI_READY_EN_G    => true,  -- Using "Packet FIFO" option in AXI Interconnect IP core
            AXIS_READY_EN_G   => false,
            AXIS_CONFIG_G     => INT_DMA_AXIS_CONFIG_C,
            AXI_DESC_CONFIG_G => AXI_DESC_CONFIG_C,
            AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
            CHAN_COUNT_G      => DMA_SIZE_G,
            RD_PIPE_STAGES_G  => 1,
            BURST_BYTES_G     => 256,  -- 256B chucks (prevent out of ordering PCIe TLP)
            RD_PEND_THRESH_G  => 1)
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
            -- AXI Stream Interface 
            sAxisMasters    => sAxisMasters,
            sAxisSlaves     => sAxisSlaves,
            mAxisMasters    => mAxisMasters,
            mAxisSlaves     => mAxisSlaves,
            mAxisCtrl       => mAxisCtrl,
            -- AXI Interfaces, 0 = Desc, 1-CHAN_COUNT_G = DMA
            axiReadMasters  => axiReadMasters,
            axiReadSlaves   => axiReadSlaves,
            axiWriteMasters => axiWriteMasters,
            axiWriteSlaves  => axiWriteSlaves,
            axiWriteCtrl    => (others => AXI_CTRL_UNUSED_C));

      GEN_AXIS_FIFO : for i in DMA_SIZE_G-1 downto 0 generate

         -- Help with timing
         U_AxisRst : entity work.RstPipeline
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
         U_IbFifo : entity work.AxiStreamFifoV2
            generic map (
               -- General Configurations
               TPD_G               => TPD_G,
               INT_PIPE_STAGES_G   => INT_PIPE_STAGES_G,
               PIPE_STAGES_G       => PIPE_STAGES_G,
               SLAVE_READY_EN_G    => true,
               VALID_THOLD_G       => 1,
               -- FIFO configurations
               BRAM_EN_G           => true,
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
         U_ObFifo : entity work.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               INT_PIPE_STAGES_G   => INT_PIPE_STAGES_G,
               PIPE_STAGES_G       => PIPE_STAGES_G,
               SLAVE_READY_EN_G    => false,
               VALID_THOLD_G       => 1,
               -- FIFO configurations
               BRAM_EN_G           => true,
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
      DMA_AXIS_MON_IB : entity work.AxiStreamMonAxiL
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
      DMA_AXIS_MON_OB : entity work.AxiStreamMonAxiL
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
         U_DMA_LANE : entity work.RogueTcpStreamWrap
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
