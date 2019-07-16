-------------------------------------------------------------------------------
-- File       : AxiPciePipCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PCIe Intercommunication Protocol (PIP) Core
-- https://docs.google.com/presentation/d/1q2_Do7NnphHalV-whGrYIs9gwy7iVHokBgztF4KVqBk/edit?usp=sharing
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
use work.AxiStreamPacketizer2Pkg.all;

entity AxiPciePipCore is
   generic (
      TPD_G             : time                   := 1 ns;
      NUM_AXIS_G        : positive range 1 to 16 := 1;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      enableTx        : out slv(NUM_AXIS_G-1 downto 0);
      -- AXI Stream Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      sAxisMasters    : in  AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
      sAxisSlaves     : out AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);
      mAxisMasters    : out AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
      mAxisSlaves     : in  AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);
      -- AXI4 Interfaces (axiClk domain)
      axiClk          : in  sl;
      axiRst          : in  sl;
      axiReady        : out sl;
      sAxiWriteMaster : in  AxiWriteMasterType;
      sAxiWriteSlave  : out AxiWriteSlaveType;
      mAxiWriteMaster : out AxiWriteMasterType;
      mAxiWriteSlave  : in  AxiWriteSlaveType);
end AxiPciePipCore;

architecture mapping of AxiPciePipCore is

   constant BURST_BYTES_C : positive := 256;  -- 256B chucks (prevent out of ordering PCIe TLP)

   constant PCIE_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => AXI_PCIE_CONFIG_C.DATA_BYTES_C,  -- Match the AXI and AXIS widths for M_AXI port
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 8,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 8,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   constant PACKETIZER_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 8,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 8,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   signal ibAxisMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal ibAxisSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal packetizerMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal packetizerSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal pipObMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal pipObSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal pipObMaster : AxiStreamMasterType;
   signal pipObSlave  : AxiStreamSlaveType;

   signal pipIbMaster : AxiStreamMasterType;
   signal pipIbSlave  : AxiStreamSlaveType;

   signal pipIbMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal pipIbSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal depacketizerMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal depacketizerSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal obAxisMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal obAxisSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

   signal rxFrame     : sl;
   signal rxDropFrame : sl;

   signal txFrame           : sl;
   signal txDropFrame       : sl;
   signal txAxiError        : sl;
   signal enTx              : slv(NUM_AXIS_G-1 downto 0);
   signal awcache           : slv(3 downto 0);
   signal remoteBarBaseAddr : Slv32Array(NUM_AXIS_G-1 downto 0);

   signal depackDebug : Packetizer2DebugArray(NUM_AXIS_G-1 downto 0);

begin

   enableTx <= enTx;

   ------------------------------
   -- AXI-Lite Control/Monitoring
   ------------------------------
   U_AxiPciePipReg : entity work.AxiPciePipReg
      generic map (
         TPD_G      => TPD_G,
         NUM_AXIS_G => NUM_AXIS_G)
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
         rxDropFrame       => rxDropFrame,
         txDropFrame       => txDropFrame,
         rxFrame           => rxFrame,
         txFrame           => txFrame,
         txAxiError        => txAxiError,
         depackDebug       => depackDebug,
         enableTx          => enTx,
         awcache           => awcache,
         remoteBarBaseAddr => remoteBarBaseAddr,
         axiReady          => axiReady);

   ------------------------------------
   -- Inbound AXI Stream to AXI4 Layers
   ------------------------------------

   GEN_IB :
   for i in (NUM_AXIS_G-1) downto 0 generate

      U_IbResize : entity work.AxiStreamResize
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => PACKETIZER_AXIS_CONFIG_C)
         port map (
            -- Clock and reset
            axisClk     => axisClk,
            axisRst     => axisRst,
            -- Slave Port
            sAxisMaster => sAxisMasters(i),
            sAxisSlave  => sAxisSlaves(i),
            -- Master Port
            mAxisMaster => ibAxisMasters(i),
            mAxisSlave  => ibAxisSlaves(i));

      U_PacketizerV2 : entity work.AxiStreamPacketizer2
         generic map (
            TPD_G                => TPD_G,
            BRAM_EN_G            => true,
            REG_EN_G             => true,
            CRC_MODE_G           => "FULL",
            CRC_POLY_G           => x"04C11DB7",
            TDEST_BITS_G         => 8,
            MAX_PACKET_BYTES_G   => BURST_BYTES_C,
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 1)
         port map (
            axisClk     => axisClk,
            axisRst     => axisRst,
            sAxisMaster => ibAxisMasters(i),
            sAxisSlave  => ibAxisSlaves(i),
            mAxisMaster => packetizerMasters(i),
            mAxisSlave  => packetizerSlaves(i));

      BURST_RESIZE_FIFO : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 1,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => (BURST_BYTES_C/PACKETIZER_AXIS_CONFIG_C.TDATA_BYTES_C),
            VALID_BURST_MODE_G  => true,
            -- FIFO configurations
            BRAM_EN_G           => true,
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            INT_WIDTH_SELECT_G  => "CUSTOM",
            INT_DATA_WIDTH_G    => PACKETIZER_AXIS_CONFIG_C.TDATA_BYTES_C,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => PACKETIZER_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => PCIE_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => axisClk,
            sAxisRst    => axisRst,
            sAxisMaster => packetizerMasters(i),
            sAxisSlave  => packetizerSlaves(i),
            -- Master Port
            mAxisClk    => axiClk,
            mAxisRst    => axiRst,
            mAxisMaster => pipObMasters(i),
            mAxisSlave  => pipObSlaves(i));

   end generate GEN_IB;

   U_AxiStreamMux : entity work.AxiStreamMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => NUM_AXIS_G)
      port map (
         -- Clock and reset
         axisClk      => axiClk,
         axisRst      => axiRst,
         -- Slaves
         sAxisMasters => pipObMasters,
         sAxisSlaves  => pipObSlaves,
         -- Master
         mAxisMaster  => pipObMaster,
         mAxisSlave   => pipObSlave);

   U_AxiPciePipTx : entity work.AxiPciePipTx
      generic map (
         TPD_G              => TPD_G,
         NUM_AXIS_G         => NUM_AXIS_G,
         BURST_BYTES_G      => BURST_BYTES_C,
         PCIE_AXIS_CONFIG_G => PCIE_AXIS_CONFIG_C)
      port map (
         -- Clock and Reset
         axiClk            => axiClk,
         axiRst            => axiRst,
         -- Configuration Interface
         enableTx          => enTx,
         remoteBarBaseAddr => remoteBarBaseAddr,
         awcache           => awcache,
         txFrame           => txFrame,
         txDropFrame       => txDropFrame,
         txAxiError        => txAxiError,
         -- AXI Stream Interface
         pipObMaster       => pipObMaster,
         pipObSlave        => pipObSlave,
         -- AXI4 Interfaces
         pipObWriteMaster  => mAxiWriteMaster,
         pipObWriteSlave   => mAxiWriteSlave);

   -------------------------------------
   -- Outbound AXI4 to AXI Stream Layers
   -------------------------------------

   U_AxiPciePipRx : entity work.AxiPciePipRx
      generic map (
         TPD_G              => TPD_G,
         BURST_BYTES_G      => BURST_BYTES_C,
         PCIE_AXIS_CONFIG_G => PCIE_AXIS_CONFIG_C)
      port map (
         -- Clock and Reset
         axiClk           => axiClk,
         axiRst           => axiRst,
         -- Debugging
         rxFrame          => rxFrame,
         rxDropFrame      => rxDropFrame,
         -- AXI4 Interfaces
         pipIbWriteMaster => sAxiWriteMaster,
         pipIbWriteSlave  => sAxiWriteSlave,
         -- AXI Stream Interface
         pipIbMaster      => pipIbMaster,
         pipIbSlave       => pipIbSlave);

   U_AxiStreamDeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => NUM_AXIS_G)
      port map (
         -- Clock and reset
         axisClk      => axiClk,
         axisRst      => axiRst,
         -- Slaves
         sAxisMaster  => pipIbMaster,
         sAxisSlave   => pipIbSlave,
         -- Master
         mAxisMasters => pipIbMasters,
         mAxisSlaves  => pipIbSlaves);

   GEN_OB :
   for i in (NUM_AXIS_G-1) downto 0 generate

      BURST_RESIZE_FIFO : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 1,
            -- FIFO configurations
            BRAM_EN_G           => true,
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => PCIE_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => PACKETIZER_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => axiClk,
            sAxisRst    => axiRst,
            sAxisMaster => pipIbMasters(i),
            sAxisSlave  => pipIbSlaves(i),
            -- Master Port
            mAxisClk    => axisClk,
            mAxisRst    => axisRst,
            mAxisMaster => depacketizerMasters(i),
            mAxisSlave  => depacketizerSlaves(i));

      U_Depacketizer : entity work.AxiStreamDepacketizer2
         generic map (
            TPD_G                => TPD_G,
            BRAM_EN_G            => true,
            REG_EN_G             => true,
            CRC_MODE_G           => "FULL",
            CRC_POLY_G           => x"04C11DB7",
            TDEST_BITS_G         => 8,
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 1)
         port map (
            axisClk     => axisClk,
            axisRst     => axisRst,
            linkGood    => '1',
            debug       => depackDebug(i),
            sAxisMaster => depacketizerMasters(i),
            sAxisSlave  => depacketizerSlaves(i),
            mAxisMaster => obAxisMasters(i),
            mAxisSlave  => obAxisSlaves(i));

      U_ObResize : entity work.AxiStreamResize
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => PACKETIZER_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
         port map (
            -- Clock and reset
            axisClk     => axisClk,
            axisRst     => axisRst,
            -- Slave Port
            sAxisMaster => obAxisMasters(i),
            sAxisSlave  => obAxisSlaves(i),
            -- Master Port
            mAxisMaster => mAxisMasters(i),
            mAxisSlave  => mAxisSlaves(i));

   end generate GEN_OB;

end mapping;
