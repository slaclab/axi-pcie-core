-------------------------------------------------------------------------------
-- File       : AxiPcieGpuAsyncCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Support for GpuDirectAsync like data transport to/from a GPU
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
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AxiPciePkg.all;
use work.AxiDmaPkg.all;
use work.AxiStreamPacketizer2Pkg.all;

entity AxiPcieGpuAsyncCore is
   generic (
      TPD_G             : time := 1 ns;
      NUM_CHAN_G        : positive range 1 to 4 := 1;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- AXI Stream Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      sAxisMaster     : in  AxiStreamMasterType;
      sAxisSlave      : out AxiStreamSlaveType;
      mAxisMaster     : out AxiStreamMasterType;
      mAxisSlave      : in  AxiStreamSlaveType;
      -- AXI4 Interfaces (axiClk domain)
      axiClk          : in  sl;
      axiRst          : in  sl;
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      mAxiWriteMaster : out AxiWriteMasterType;
      mAxiWriteSlave  : in  AxiWriteSlaveType);
end AxiPcieGpuAsyncCore;

architecture mapping of AxiPcieGpuAsyncCore is

   constant PCIE_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => AXI_PCIE_CONFIG_C.DATA_BYTES_C,  -- Match the AXI and AXIS widths for M_AXI port
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 8,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 8,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   signal dmaWrDescReq    : AxiWriteDmaDescReqType;
   signal dmaWrDescAck    : AxiWriteDmaDescAckType;
   signal dmaWrDescRet    : AxiWriteDmaDescRetType;
   signal dmaWrDescRetAck : sl;

   signal awCache         : slv(3 downto 0);

   signal sAxisMasterInt  : AxiStreamMasterType;
   signal sAxisSlaveInt   : AxiStreamSlaveType;
   signal mAxisMasterInt  : AxiStreamMasterType;
   signal mAxisSlaveInt   : AxiStreamSlaveType;

begin

   ------------------------------
   -- AXI-Lite Control/Monitoring
   ------------------------------
   U_AxiPcieGpuAsyncControl : entity work.AxiPcieGpuAsyncControl
      generic map (
         TPD_G      => TPD_G,
         NUM_CHAN_G => NUM_CHAN_G)
      port map (
         -- AXI4-Lite Interfaces (axilClk domain)
         axilClk           => axilClk,
         axilRst           => axilRst,
         axilReadMaster    => axilReadMaster,
         axilReadSlave     => axilReadSlave,
         axilWriteMaster   => axilWriteMaster,
         axilWriteSlave    => axilWriteSlave,
         -- AXI4 Interfaces (axiClk domain)
         axiClk            => axiClk,
         axiRst            => axiRst,
         awCache           => awCache,
         dmaWrDescReq      => dmaWrDescReq,
         dmaWrDescAck      => dmaWrDescAck,
         dmaWrDescRet      => dmaWrDescRet,
         dmaWrDescRetAck   => dmaWrDescRetAck);

   ------------------------------------
   -- Stream receiver to GPU DMA
   ------------------------------------

   AxisRxFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         BRAM_EN_G           => true,
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => PCIE_AXIS_CONFIG_C)
      port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => sAxisMaster,
         sAxisSlave  => sAxisSlave,
         mAxisClk    => axiClk,
         mAxisRst    => axiRst,
         mAxisMaster => sAxisMasterInt,
         mAxisSlave  => sAxisSlaveInt);

   U_DmaWrite: entity work.AxiStreamDmaV2Write
      generic map (
         TPD_G             => TPD_G,
         AXI_READY_EN_G    => true,
         AXIS_CONFIG_G     => PCIE_AXIS_CONFIG_C,
         AXI_CONFIG_G      => AXI_PCIE_CONFIG_C)
      port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaWrDescReq    => dmaWrDescReq,
         dmaWrDescAck    => dmaWrDescAck,
         dmaWrDescRet    => dmaWrDescRet,
         dmaWrDescRetAck => dmaWrDescRetAck,
         axiCache        => awCache,
         axisMaster      => sAxisMasterInt,
         axisSlave       => sAxisSlaveInt,
         axiWriteMaster  => mAxiWriteMaster,
         axiWriteSlave   => mAxiWriteSlave);

   ------------------------------------
   -- Stream transmitter from GPU DMA
   ------------------------------------

   --sAxiWriteMaster : in  AxiWriteMasterType;
   sAxiWriteSlave <= AXI_WRITE_SLAVE_INIT_C;
   mAxisMasterInt <= AXI_STREAM_MASTER_INIT_C;
   --mAxisSlaveInt,

   AxisTxFifo : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         BRAM_EN_G           => true,
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         SLAVE_AXI_CONFIG_G  => PCIE_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => mAxisMasterInt,
         sAxisSlave  => mAxisSlaveInt,
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => mAxisMaster,
         mAxisSlave  => mAxisSlave);

end mapping;

