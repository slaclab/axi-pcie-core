-------------------------------------------------------------------------------
-- File       : AxiPcieDma.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-06
-- Last update: 2017-04-08
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
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPciePkg.all;

entity AxiPcieDma is
   generic (
      TPD_G            : time                   := 1 ns;
      DMA_SIZE_G       : positive range 1 to 16 := 1;
      AXI_ERROR_RESP_G : slv(1 downto 0)        := AXI_RESP_OK_C);
   port (
      -- Clock and reset
      axiClk          : in  sl;
      axiRst          : in  sl;
      -- AXI4 Interfaces
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType;
      axiWriteMaster  : out AxiWriteMasterType;
      axiWriteSlave   : in  AxiWriteSlaveType;
      -- AXI4-Lite Interfaces
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Interrupts
      dmaIrq          : out sl;
      -- DMA Interfaces
      dmaObMasters    : out AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves     : in  AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters    : in  AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves     : out AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0));
end AxiPcieDma;

architecture mapping of AxiPcieDma is

   signal locReadMasters  : AxiReadMasterArray(DMA_SIZE_G downto 0);
   signal locReadSlaves   : AxiReadSlaveArray(DMA_SIZE_G downto 0);
   signal locWriteMasters : AxiWriteMasterArray(DMA_SIZE_G downto 0);
   signal locWriteSlaves  : AxiWriteSlaveArray(DMA_SIZE_G downto 0);
   signal locWriteCtrl    : AxiCtrlArray(DMA_SIZE_G downto 0);

   signal axiReadMasters  : AxiReadMasterArray(16 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(16 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);
   signal axiWriteMasters : AxiWriteMasterArray(16 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(16 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);

   signal sAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
   signal sAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);

   signal mAxisMasters : AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
   signal mAxisSlaves  : AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
   signal mAxisCtrl    : AxiStreamCtrlArray(DMA_SIZE_G-1 downto 0);

begin

   ----------------
   -- AXI PCIe XBAR
   -----------------
   U_XBAR : entity work.AxiPcieCrossbar
      generic map (
         TPD_G      => TPD_G,
         DMA_SIZE_G => DMA_SIZE_G)
      port map (
         -- Clock and Reset
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
         DESC_AWIDTH_G     => 12,       -- 4096 entries
         AXIL_BASE_ADDR_G  => x"00010000",
         AXI_ERROR_RESP_G  => AXI_ERROR_RESP_G,
         AXI_READY_EN_G    => false,
         AXIS_READY_EN_G   => false,
         AXIS_CONFIG_G     => DMA_AXIS_CONFIG_C,
         AXI_DESC_CONFIG_G => DMA_AXI_CONFIG_C,
         AXI_DMA_CONFIG_G  => DMA_AXI_CONFIG_C,
         CHAN_COUNT_G      => DMA_SIZE_G,
         RD_PIPE_STAGES_G  => 1,
         --RD_PEND_THRESH_G  => 512)
         RD_PEND_THRESH_G  => 0)
      port map (
         -- Clock/Reset
         axiClk          => axiClk,
         axiRst          => axiRst,
         -- Register Access & Interrupt
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         interrupt       => dmaIrq,
         -- AXI Stream Interface 
         sAxisMaster     => sAxisMasters,
         sAxisSlave      => sAxisSlaves,
         mAxisMaster     => mAxisMasters,
         mAxisSlave      => mAxisSlaves,
         mAxisCtrl       => mAxisCtrl,
         -- AXI Interfaces, 0 = Desc, 1-CHAN_COUNT_G = DMA
         axiReadMaster   => locReadMasters,
         axiReadSlave    => locReadSlaves,
         axiWriteMaster  => locWriteMasters,
         axiWriteSlave   => locWriteSlaves,
         axiWriteCtrl    => locWriteCtrl);

   GEN_AXIS_FIFO : for i in DMA_SIZE_G-1 downto 0 generate

      --------------------------
      -- Inbound AXI Stream FIFO
      --------------------------
      U_IbFifo : entity work.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 1,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 1,
            BRAM_EN_G           => true,
            XIL_DEVICE_G        => "7SERIES",
            USE_BUILT_IN_G      => false,
            GEN_SYNC_FIFO_G     => true,
            ALTERA_SYN_G        => false,
            ALTERA_RAM_G        => "M9K",
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 500,  -- Unused
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_C)
         port map (
            sAxisClk        => axiClk,
            sAxisRst        => axiRst,
            sAxisMaster     => dmaIbMasters(i),
            sAxisSlave      => dmaIbSlaves(i),
            sAxisCtrl       => open,
            fifoPauseThresh => (others => '1'),
            mAxisClk        => axiClk,
            mAxisRst        => axiRst,
            mAxisMaster     => sAxisMasters(i),
            mAxisSlave      => sAxisSlaves(i));

      ---------------------------
      -- Outbound AXI Stream FIFO
      ---------------------------
      U_ObFifo : entity work.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 1,
            SLAVE_READY_EN_G    => false,
            VALID_THOLD_G       => 1,
            BRAM_EN_G           => true,
            XIL_DEVICE_G        => "7SERIES",
            USE_BUILT_IN_G      => false,
            GEN_SYNC_FIFO_G     => true,
            ALTERA_SYN_G        => false,
            ALTERA_RAM_G        => "M9K",
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 300,  -- 1800 byte buffer before pause and 1696 byte of buffer before FIFO FULL
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_C)
         port map (
            sAxisClk        => axiClk,
            sAxisRst        => axiRst,
            sAxisMaster     => mAxisMasters(i),
            sAxisSlave      => mAxisSlaves(i),
            sAxisCtrl       => mAxisCtrl(i),
            fifoPauseThresh => (others => '1'),
            mAxisClk        => axiClk,
            mAxisRst        => axiRst,
            mAxisMaster     => dmaObMasters(i),
            mAxisSlave      => dmaObSlaves(i));

   end generate;

   GEN_AXI_FIFO : for i in DMA_SIZE_G downto 0 generate

      ---------------------
      -- Read Path AXI FIFO
      ---------------------
      U_AxiReadPathFifo : entity work.AxiReadPathFifo
         generic map (
            TPD_G                  => TPD_G,
            XIL_DEVICE_G           => "7SERIES",
            USE_BUILT_IN_G         => false,
            GEN_SYNC_FIFO_G        => true,
            ALTERA_SYN_G           => false,
            ALTERA_RAM_G           => "M9K",
            ADDR_LSB_G             => 3,
            ID_FIXED_EN_G          => true,
            SIZE_FIXED_EN_G        => true,
            BURST_FIXED_EN_G       => true,
            LEN_FIXED_EN_G         => false,
            LOCK_FIXED_EN_G        => true,
            PROT_FIXED_EN_G        => true,
            CACHE_FIXED_EN_G       => true,
            ADDR_BRAM_EN_G         => false,
            ADDR_CASCADE_SIZE_G    => 1,
            ADDR_FIFO_ADDR_WIDTH_G => 4,
            DATA_BRAM_EN_G         => false,
            DATA_CASCADE_SIZE_G    => 1,
            DATA_FIFO_ADDR_WIDTH_G => 4,
            AXI_CONFIG_G           => DMA_AXI_CONFIG_C)
         port map (
            sAxiClk        => axiClk,
            sAxiRst        => axiRst,
            sAxiReadMaster => locReadMasters(i),
            sAxiReadSlave  => locReadSlaves(i),
            mAxiClk        => axiClk,
            mAxiRst        => axiRst,
            mAxiReadMaster => axiReadMasters(i),
            mAxiReadSlave  => axiReadSlaves(i));

      ----------------------
      -- Write Path AXI FIFO
      ----------------------
      U_AxiWritePathFifo : entity work.AxiWritePathFifo
         generic map (
            TPD_G                    => TPD_G,
            XIL_DEVICE_G             => "7SERIES",
            USE_BUILT_IN_G           => false,
            GEN_SYNC_FIFO_G          => true,
            ALTERA_SYN_G             => false,
            ALTERA_RAM_G             => "M9K",
            ADDR_LSB_G               => 3,
            ID_FIXED_EN_G            => true,
            SIZE_FIXED_EN_G          => true,
            BURST_FIXED_EN_G         => true,
            LEN_FIXED_EN_G           => false,
            LOCK_FIXED_EN_G          => true,
            PROT_FIXED_EN_G          => true,
            CACHE_FIXED_EN_G         => true,
            ADDR_BRAM_EN_G           => true,
            ADDR_CASCADE_SIZE_G      => 1,
            ADDR_FIFO_ADDR_WIDTH_G   => 9,
            DATA_BRAM_EN_G           => true,
            DATA_CASCADE_SIZE_G      => 1,
            DATA_FIFO_ADDR_WIDTH_G   => 9,
            DATA_FIFO_PAUSE_THRESH_G => 456,
            RESP_BRAM_EN_G           => false,
            RESP_CASCADE_SIZE_G      => 1,
            RESP_FIFO_ADDR_WIDTH_G   => 4,
            AXI_CONFIG_G             => DMA_AXI_CONFIG_C)
         port map (
            sAxiClk         => axiClk,
            sAxiRst         => axiRst,
            sAxiWriteMaster => locWriteMasters(i),
            sAxiWriteSlave  => locWriteSlaves(i),
            sAxiCtrl        => locWriteCtrl(i),
            mAxiClk         => axiClk,
            mAxiRst         => axiRst,
            mAxiWriteMaster => axiWriteMasters(i),
            mAxiWriteSlave  => axiWriteSlaves(i));

   end generate;

end mapping;
