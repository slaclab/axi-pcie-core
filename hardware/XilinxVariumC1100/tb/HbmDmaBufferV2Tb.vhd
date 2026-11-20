-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: cocotb/GHDL simulation top-level for the HbmDmaBufferV2 module
--
-- Wraps the unmodified HbmDmaBufferV2 (both DMA lanes) and flattens its
-- AXI stream records into ports for the cocotb regression in
-- tests/hardware/XilinxVariumC1100/test_HbmDmaBufferV2.py. The Xilinx HBM IP
-- and the MMCM wrapper are replaced by the simulation models in this
-- directory (HbmDmaBufferV2IpCore.vhd and ClockManagerUltraScaleSim.vhd).
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.HtspPkg.all;

library axi_pcie_core;

entity HbmDmaBufferV2Tb is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clocks and Reset
      userClk        : in  sl;          -- 100 MHz (also used as hbmRefClk)
      axisClk        : in  sl;          -- Stream, event and AXI-Lite clock
      axisRst        : in  sl;
      -- Status
      pause          : out slv(1 downto 0);
      -- DMA Lane 0: Inbound and Outbound AXI Streams (axisClk domain)
      S_AXIS0_TVALID : in  sl;
      S_AXIS0_TDATA  : in  slv(511 downto 0);
      S_AXIS0_TKEEP  : in  slv(63 downto 0);
      S_AXIS0_TLAST  : in  sl;
      S_AXIS0_TDEST  : in  slv(3 downto 0);
      S_AXIS0_TREADY : out sl;
      M_AXIS0_TVALID : out sl;
      M_AXIS0_TDATA  : out slv(511 downto 0);
      M_AXIS0_TKEEP  : out slv(63 downto 0);
      M_AXIS0_TLAST  : out sl;
      M_AXIS0_TDEST  : out slv(3 downto 0);
      M_AXIS0_TREADY : in  sl;
      -- DMA Lane 1: Inbound and Outbound AXI Streams (axisClk domain)
      S_AXIS1_TVALID : in  sl;
      S_AXIS1_TDATA  : in  slv(511 downto 0);
      S_AXIS1_TKEEP  : in  slv(63 downto 0);
      S_AXIS1_TLAST  : in  sl;
      S_AXIS1_TDEST  : in  slv(3 downto 0);
      S_AXIS1_TREADY : out sl;
      M_AXIS1_TVALID : out sl;
      M_AXIS1_TDATA  : out slv(511 downto 0);
      M_AXIS1_TKEEP  : out slv(63 downto 0);
      M_AXIS1_TLAST  : out sl;
      M_AXIS1_TDEST  : out slv(3 downto 0);
      M_AXIS1_TREADY : in  sl);
end entity HbmDmaBufferV2Tb;

architecture testbed of HbmDmaBufferV2Tb is

   signal axisRstL : sl := '1';

   signal eventTrigMsgCtrl : AxiStreamCtrlArray(1 downto 0) := (others => AXI_STREAM_CTRL_INIT_C);

   signal sAxisMasters : AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal sAxisSlaves  : AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal mAxisMasters : AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal mAxisSlaves  : AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

begin

   axisRstL <= not axisRst;

   pause(0) <= eventTrigMsgCtrl(0).pause;
   pause(1) <= eventTrigMsgCtrl(1).pause;

   ---------------------------------------------------------------------------
   -- AXI Stream shims
   ---------------------------------------------------------------------------
   U_S_AXIS0 : entity surf.SlaveAxiStreamIpIntegrator
      generic map (
         INTERFACENAME   => "S_AXIS0",
         TDEST_WIDTH     => HTSP_AXIS_CONFIG_C.TDEST_BITS_C,
         TDATA_NUM_BYTES => HTSP_AXIS_CONFIG_C.TDATA_BYTES_C)
      port map (
         S_AXIS_ACLK    => axisClk,
         S_AXIS_ARESETN => axisRstL,
         S_AXIS_TVALID  => S_AXIS0_TVALID,
         S_AXIS_TDATA   => S_AXIS0_TDATA,
         S_AXIS_TKEEP   => S_AXIS0_TKEEP,
         S_AXIS_TLAST   => S_AXIS0_TLAST,
         S_AXIS_TDEST   => S_AXIS0_TDEST,
         S_AXIS_TREADY  => S_AXIS0_TREADY,
         axisClk        => open,
         axisRst        => open,
         axisMaster     => sAxisMasters(0),
         axisSlave      => sAxisSlaves(0));

   U_M_AXIS0 : entity surf.MasterAxiStreamIpIntegrator
      generic map (
         INTERFACENAME   => "M_AXIS0",
         TDEST_WIDTH     => HTSP_AXIS_CONFIG_C.TDEST_BITS_C,
         TDATA_NUM_BYTES => HTSP_AXIS_CONFIG_C.TDATA_BYTES_C)
      port map (
         M_AXIS_ACLK    => axisClk,
         M_AXIS_ARESETN => axisRstL,
         M_AXIS_TVALID  => M_AXIS0_TVALID,
         M_AXIS_TDATA   => M_AXIS0_TDATA,
         M_AXIS_TSTRB   => open,
         M_AXIS_TKEEP   => M_AXIS0_TKEEP,
         M_AXIS_TLAST   => M_AXIS0_TLAST,
         M_AXIS_TDEST   => M_AXIS0_TDEST,
         M_AXIS_TID     => open,
         M_AXIS_TUSER   => open,
         M_AXIS_TREADY  => M_AXIS0_TREADY,
         axisClk        => open,
         axisRst        => open,
         axisMaster     => mAxisMasters(0),
         axisSlave      => mAxisSlaves(0));

   U_S_AXIS1 : entity surf.SlaveAxiStreamIpIntegrator
      generic map (
         INTERFACENAME   => "S_AXIS1",
         TDEST_WIDTH     => HTSP_AXIS_CONFIG_C.TDEST_BITS_C,
         TDATA_NUM_BYTES => HTSP_AXIS_CONFIG_C.TDATA_BYTES_C)
      port map (
         S_AXIS_ACLK    => axisClk,
         S_AXIS_ARESETN => axisRstL,
         S_AXIS_TVALID  => S_AXIS1_TVALID,
         S_AXIS_TDATA   => S_AXIS1_TDATA,
         S_AXIS_TKEEP   => S_AXIS1_TKEEP,
         S_AXIS_TLAST   => S_AXIS1_TLAST,
         S_AXIS_TDEST   => S_AXIS1_TDEST,
         S_AXIS_TREADY  => S_AXIS1_TREADY,
         axisClk        => open,
         axisRst        => open,
         axisMaster     => sAxisMasters(1),
         axisSlave      => sAxisSlaves(1));

   U_M_AXIS1 : entity surf.MasterAxiStreamIpIntegrator
      generic map (
         INTERFACENAME   => "M_AXIS1",
         TDEST_WIDTH     => HTSP_AXIS_CONFIG_C.TDEST_BITS_C,
         TDATA_NUM_BYTES => HTSP_AXIS_CONFIG_C.TDATA_BYTES_C)
      port map (
         M_AXIS_ACLK    => axisClk,
         M_AXIS_ARESETN => axisRstL,
         M_AXIS_TVALID  => M_AXIS1_TVALID,
         M_AXIS_TDATA   => M_AXIS1_TDATA,
         M_AXIS_TSTRB   => open,
         M_AXIS_TKEEP   => M_AXIS1_TKEEP,
         M_AXIS_TLAST   => M_AXIS1_TLAST,
         M_AXIS_TDEST   => M_AXIS1_TDEST,
         M_AXIS_TID     => open,
         M_AXIS_TUSER   => open,
         M_AXIS_TREADY  => M_AXIS1_TREADY,
         axisClk        => open,
         axisRst        => open,
         axisMaster     => mAxisMasters(1),
         axisSlave      => mAxisSlaves(1));

   ---------------------------------------------------------------------------
   -- Design Under Test (DUT)
   ---------------------------------------------------------------------------
   U_DUT : entity axi_pcie_core.HbmDmaBufferV2
      generic map (
         TPD_G             => TPD_G,
         SYNTH_MODE_G      => "inferred",  -- XPM is not supported in GHDL
         MEMORY_TYPE_G     => "block",
         DMA_SIZE_G        => 2,
         DMA_AXIS_CONFIG_G => HTSP_AXIS_CONFIG_C,
         AXIL_BASE_ADDR_G  => x"0000_0000")
      port map (
         -- Card Management Solution (CMS) Interface
         cmsHbmCatTrip    => open,
         cmsHbmTemp       => open,
         -- HBM Interface
         userClk          => userClk,
         hbmRefClk        => userClk,
         hbmCatTrip       => open,
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => axisClk,
         axilRst          => axisRst,
         axilReadMaster   => AXI_LITE_READ_MASTER_INIT_C,
         axilReadSlave    => open,
         axilWriteMaster  => AXI_LITE_WRITE_MASTER_INIT_C,
         axilWriteSlave   => open,
         -- Trigger Event streams (eventClk domain)
         eventClk(0)      => axisClk,
         eventClk(1)      => axisClk,
         eventTrigMsgCtrl => eventTrigMsgCtrl,
         -- Inbound AXIS Interface (sAxisClk domain)
         sAxisClk(0)      => axisClk,
         sAxisClk(1)      => axisClk,
         sAxisRst(0)      => axisRst,
         sAxisRst(1)      => axisRst,
         sAxisMasters     => sAxisMasters,
         sAxisSlaves      => sAxisSlaves,
         -- Outbound AXIS Interface (mAxisClk domain)
         mAxisClk(0)      => axisClk,
         mAxisClk(1)      => axisClk,
         mAxisRst(0)      => axisRst,
         mAxisRst(1)      => axisRst,
         mAxisMasters     => mAxisMasters,
         mAxisSlaves      => mAxisSlaves);

end architecture testbed;
