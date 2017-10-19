-------------------------------------------------------------------------------
-- File       : PgpLaneRx.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'SLAC PGP Gen3 Card'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC PGP Gen3 Card', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiPciePkg.all;
use work.AppPkg.all;
use work.Pgp2bPkg.all;
use work.TimingPkg.all;

entity PgpLaneRx is
   generic (
      TPD_G            : time                  := 1 ns;
      SLAVE_READY_EN_G : boolean               := false;
      LANE_G           : positive range 0 to 7 := 0);
   port (
      -- DMA Interface (sysClk domain)
      sysClk       : in  sl;
      sysRst       : in  sl;
      dmaIbMaster  : out AxiStreamMasterType;
      dmaIbSlave   : in  AxiStreamSlaveType;
      -- Control/Status  (sysClk domain)
      config       : in  ConfigType;
      status       : out StatusType;
      -- Timing Interface (evrClk domain)
      evrClk       : in  sl;
      evrRst       : in  sl;
      evrTimingBus : in  TimingBusType;
      -- PGP Trigger Interface (pgpTxClk domain)
      pgpTxClk     : in  sl;
      pgpTxRst     : in  sl;
      pgpTxIn      : out Pgp2bTxInType;
      -- PGP RX Interface (pgpRxClk domain)
      pgpRxClk     : in  sl;
      pgpRxRst     : in  sl;
      pgpRxMasters : in  AxiStreamMasterArray(3 downto 0);
      pgpRxSlaves  : out AxiStreamSlaveArray(3 downto 0);
      pgpRxCtrl    : out AxiStreamCtrlArray(3 downto 0));
end PgpLaneRx;

architecture mapping of PgpLaneRx is

   type RegType is record
      evrToPgp : EvrToPgpType;
   end record;

   constant REG_INIT_C : RegType := (
      evrToPgp => EVR_TO_PGP_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   constant TDEST_ROUTES_C : Slv8Array := (
      0 => toSlv((16*LANE_G)+0, 8),
      1 => toSlv((16*LANE_G)+1, 8),
      2 => toSlv((16*LANE_G)+2, 8),
      3 => toSlv((16*LANE_G)+3, 8));

   signal rxMasters : AxiStreamMasterArray(3 downto 0);
   signal rxSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal dmaIbMasters : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal trigLutIn  : TrigLutInArray(3 downto 0);
   signal trigLutOut : TrigLutOutArray(3 downto 0);

   signal enableTrig : sl;
   signal runCode    : slv(7 downto 0);
   signal acceptCode : slv(7 downto 0);

   signal lutDrop    : slv(3 downto 0);
   signal fifoError  : slv(3 downto 0);
   signal vcPause    : slv(3 downto 0);
   signal vcOverflow : slv(3 downto 0);

begin

   U_enableTrig : entity work.Synchronizer
      generic map(
         TPD_G => TPD_G)
      port map (
         clk     => evrClk,
         dataIn  => config.enableTrig,
         dataOut => enableTrig);

   Sync_OpCodeMask : entity work.SynchronizerFifo
      generic map(
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 16)
      port map(
         -- Write Ports (wr_clk domain)
         wr_clk            => sysClk,
         din(7 downto 0)   => config.runCode,
         din(15 downto 8)  => config.acceptCode,
         -- Read Ports (rd_clk domain)
         rd_clk            => evrClk,
         dout(7 downto 0)  => runCode,
         dout(15 downto 8) => acceptCode);

   comb : process (acceptCode, enableTrig, evrRst, evrTimingBus, r, runCode) is
      variable v           : RegType;
      variable runIndex    : natural;
      variable acceptIndex : natural;
   begin
      -- Latch the current value
      v := r;

      -- Update the variables
      runIndex    := conv_integer(runCode);
      acceptIndex := conv_integer(acceptCode);

      -- Reset the strobes
      v.evrToPgp.run    := '0';
      v.evrToPgp.accept := '0';

      -- Phase up the trigger detect with EPICS timestamp
      v.evrToPgp.seconds := evrTimingBus.stream.dbuff.epicsTime(63 downto 32);
      v.evrToPgp.offset  := evrTimingBus.stream.dbuff.epicsTime(31 downto 0);

      -- Check if enabled
      if (enableTrig = '1') and (evrTimingBus.valid = '1') and (evrTimingBus.strobe = '1') then
         -- Check for run/accept OP code
         v.evrToPgp.run    := evrTimingBus.stream.eventCodes(runIndex);
         v.evrToPgp.accept := evrTimingBus.stream.eventCodes(acceptIndex);
      end if;

      -- Reset
      if (evrRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (evrClk) is
   begin
      if rising_edge(evrClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   ----------------------------
   -- EVR OP Code Look Up Table
   ----------------------------      
   PgpOpCode_Inst : entity work.PgpOpCode
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Configurations
         runDelay      => config.runDelay,
         acceptDelay   => config.acceptDelay,
         acceptCntRst  => config.acceptCntRst,
         evrOpCodeMask => config.evrOpCodeMask,
         evrSyncSel    => config.evrSyncSel,
         evrSyncEn     => config.evrSyncEn,
         evrSyncWord   => config.evrSyncWord,
         evrSyncStatus => status.evrSyncStatus,
         acceptCnt     => status.acceptCnt,
         -- External Interfaces
         evrToPgp      => r.evrToPgp,
         --PGP Core interfaces
         pgpTxIn       => pgpTxIn,
         -- RX Virtual Channel Interface
         trigLutIn     => trigLutIn,
         trigLutOut    => trigLutOut,
         --Global Signals
         sysClk        => sysClk,
         sysRst        => sysRst,
         pgpRxClk      => pgpRxClk,
         pgpTxRst      => pgpTxRst,
         pgpTxClk      => pgpTxClk,
         pgpRxRst      => pgpRxRst,
         evrClk        => evrClk,
         evrRst        => evrRst);

   GEN_VEC :
   for i in 3 downto 0 generate
      U_RxBuffer : entity work.PgpVcRxBuffer
         generic map (
            TPD_G            => TPD_G,
            CASCADE_SIZE_G   => 1,
            SLAVE_READY_EN_G => SLAVE_READY_EN_G,
            LANE_G           => LANE_G,
            VC_G             => i)
         port map (
            -- EVR Trigger Interface
            enHeaderCheck => config.enHeaderCheck(i),
            trigLutOut    => trigLutOut(i),
            trigLutIn     => trigLutIn(i),
            -- 16-bit Streaming RX Interface
            pgpRxMaster   => pgpRxMasters(i),
            pgpRxSlave    => pgpRxSlaves(i),
            pgpRxCtrl     => pgpRxCtrl(i),
            -- 32-bit Streaming TX Interface
            mAxisMaster   => rxMasters(i),
            mAxisSlave    => rxSlaves(i),
            -- Diagnostic Monitoring Interface
            lutDrop       => lutDrop(i),
            fifoError     => fifoError(i),
            vcPause       => vcPause(i),
            vcOverflow    => vcOverflow(i),
            -- Global Signals
            clk           => pgpRxClk,
            rst           => pgpRxRst);

      Sync_OneShot : entity work.SynchronizerOneShotVector
         generic map(
            TPD_G   => TPD_G,
            WIDTH_G => 4)
         port map(
            clk        => sysClk,
            dataIn(0)  => lutDrop(i),
            dataIn(1)  => fifoError(i),
            dataIn(2)  => vcPause(i),
            dataIn(3)  => vcOverflow(i),
            dataOut(0) => status.lutDrop(i),
            dataOut(1) => status.fifoError(i),
            dataOut(2) => status.vcPause(i),
            dataOut(3) => status.vcOverflow(i));

      U_IbFifo : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 0,
            VALID_THOLD_G       => 128,  -- Hold until enough to burst into the interleaving MUX
            VALID_BURST_MODE_G  => true,
            INT_WIDTH_SELECT_G  => "NARROW",
            -- FIFO configurations
            BRAM_EN_G           => true,
            XIL_DEVICE_G        => "7SERIES",
            USE_BUILT_IN_G      => false,
            GEN_SYNC_FIFO_G     => false,
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => pgpRxClk,
            sAxisRst    => pgpRxRst,
            sAxisMaster => rxMasters(i),
            sAxisSlave  => rxSlaves(i),
            -- Master Port
            mAxisClk    => sysClk,
            mAxisRst    => sysRst,
            mAxisMaster => dmaIbMasters(i),
            mAxisSlave  => dmaIbSlaves(i));

   end generate GEN_VEC;

   U_Mux : entity work.AxiStreamMux
      generic map (
         TPD_G          => TPD_G,
         NUM_SLAVES_G   => 4,
         MODE_G         => "ROUTED",
         TDEST_ROUTES_G => TDEST_ROUTES_C,
         ILEAVE_EN_G    => true,        -- Using interleaving MUX
         ILEAVE_REARB_G => 0,
         PIPE_STAGES_G  => 1)
      port map (
         -- Clock and reset
         axisClk      => sysClk,
         axisRst      => sysRst,
         -- Slaves
         sAxisMasters => dmaIbMasters,
         sAxisSlaves  => dmaIbSlaves,
         -- Master
         mAxisMaster  => dmaIbMaster,
         mAxisSlave   => dmaIbSlave);

end mapping;
