-------------------------------------------------------------------------------
-- File       : AxiPciePipReg.vhd
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


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;
use surf.AxiStreamPacketizer2Pkg.all;

entity AxiPciePipReg is
   generic (
      TPD_G      : time                   := 1 ns;
      NUM_AXIS_G : positive range 1 to 16 := 1);
   port (
      -- AXI4-Lite Interfaces (axilClk domain)
      axilClk           : in  sl;
      axilRst           : in  sl;
      axilReadMaster    : in  AxiLiteReadMasterType;
      axilReadSlave     : out AxiLiteReadSlaveType;
      axilWriteMaster   : in  AxiLiteWriteMasterType;
      axilWriteSlave    : out AxiLiteWriteSlaveType;
      -- AXI4 Interfaces (axiClk domain)
      axiClk            : in  sl;
      axiRst            : in  sl;
      rxDropFrame       : in  sl;
      txDropFrame       : in  sl;
      rxFrame           : in  sl;
      txFrame           : in  sl;
      txAxiError        : in  sl;
      depackDebug       : in  Packetizer2DebugArray(NUM_AXIS_G-1 downto 0);
      enableTx          : out slv(NUM_AXIS_G-1 downto 0);
      awcache           : out slv(3 downto 0);
      remoteBarBaseAddr : out Slv32Array(NUM_AXIS_G-1 downto 0);
      axiReady          : out sl);
end AxiPciePipReg;

architecture mapping of AxiPciePipReg is

   type RegType is record
      rxFrameCnt        : slv(31 downto 0);
      txFrameCnt        : slv(31 downto 0);
      rxDropFrameCnt    : slv(31 downto 0);
      txDropFrameCnt    : slv(31 downto 0);
      txAxiErrorCnt     : slv(31 downto 0);
      depackEofeCnt     : Slv32Array(NUM_AXIS_G-1 downto 0);
      cntRst            : sl;
      enableTx          : slv(NUM_AXIS_G-1 downto 0);
      awcache           : slv(3 downto 0);
      remoteBarBaseAddr : Slv32Array(NUM_AXIS_G-1 downto 0);
      readSlave         : AxiLiteReadSlaveType;
      writeSlave        : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rxFrameCnt        => (others => '0'),
      txFrameCnt        => (others => '0'),
      rxDropFrameCnt    => (others => '0'),
      txDropFrameCnt    => (others => '0'),
      txAxiErrorCnt     => (others => '0'),
      depackEofeCnt     => (others => (others => '0')),
      cntRst            => '0',
      enableTx          => (others => '0'),
      awcache           => (others => '0'),
      remoteBarBaseAddr => (others => (others => '0')),
      readSlave         => AXI_LITE_READ_SLAVE_INIT_C,
      writeSlave        => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal readMaster  : AxiLiteReadMasterType;
   signal readSlave   : AxiLiteReadSlaveType;
   signal writeMaster : AxiLiteWriteMasterType;
   signal writeSlave  : AxiLiteWriteSlaveType;

begin

   axiReady <= depackDebug(0).initDone;  -- Used to synchronize with simulation testbed

   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 12)
      port map (
         -- Slave Interface
         sAxiClk         => axilClk,
         sAxiClkRst      => axilRst,
         sAxiReadMaster  => axilReadMaster,
         sAxiReadSlave   => axilReadSlave,
         sAxiWriteMaster => axilWriteMaster,
         sAxiWriteSlave  => axilWriteSlave,
         -- Master Interface
         mAxiClk         => axiClk,
         mAxiClkRst      => axiRst,
         mAxiReadMaster  => readMaster,
         mAxiReadSlave   => readSlave,
         mAxiWriteMaster => writeMaster,
         mAxiWriteSlave  => writeSlave);

   ---------------------
   -- AXI Lite Interface
   ---------------------
   comb : process (axiRst, depackDebug, r, readMaster, rxDropFrame, rxFrame,
                   txAxiError, txDropFrame, txFrame, writeMaster) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.cntRst := '0';

      -- Check for drop frames
      if (rxDropFrame = '1') then
         v.rxDropFrameCnt := r.rxDropFrameCnt + 1;
      end if;
      if (txDropFrame = '1') then
         v.txDropFrameCnt := r.txDropFrameCnt + 1;
      end if;
      if (txAxiError = '1') then
         v.txAxiErrorCnt := r.txAxiErrorCnt + 1;
      end if;

      -- Check for RX/TX frames
      if (rxFrame = '1') then
         v.rxFrameCnt := r.rxFrameCnt + 1;
      end if;
      if (txFrame = '1') then
         v.txFrameCnt := r.txFrameCnt + 1;
      end if;

      -- Check for EOFE on the depacker
      for i in NUM_AXIS_G-1 downto 0 loop
         if (depackDebug(i).eofe = '1') then
            v.depackEofeCnt(i) := r.depackEofeCnt(i) + 1;
         end if;
      end loop;

      -- Check for counter reset
      if (r.cntRst = '1') then
         -- Reset counters
         v.rxFrameCnt     := (others => '0');
         v.txFrameCnt     := (others => '0');
         v.rxDropFrameCnt := (others => '0');
         v.txDropFrameCnt := (others => '0');
         v.txAxiErrorCnt  := (others => '0');
         v.depackEofeCnt  := (others => (others => '0'));
      end if;

      --------------------------------------------------------------------------------------------
      -- Determine the transaction type
      --------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, writeMaster, readMaster, v.writeSlave, v.readSlave);

      -- Register Mapping
      for i in NUM_AXIS_G-1 downto 0 loop
         axiSlaveRegister (axilEp, toSlv(i*8, 12), 0, v.remoteBarBaseAddr(i));  -- [0x000:0x07F]
         axiSlaveRegisterR(axilEp, toSlv(128+i*4, 12), 0, r.depackEofeCnt(i));  -- [0x080:0x0BF]
      end loop;

      axiSlaveRegisterR(axilEp, x"0E0", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp, x"0E4", 0, r.rxDropFrameCnt);
      axiSlaveRegisterR(axilEp, x"0E8", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp, x"0EC", 0, r.txDropFrameCnt);
      axiSlaveRegisterR(axilEp, x"0F0", 0, r.txAxiErrorCnt);

      axiSlaveRegisterR(axilEp, x"0F4", 0, toSlv(NUM_AXIS_G, 5));
      axiSlaveRegister (axilEp, x"0F8", 0, v.enableTx);
      axiSlaveRegister (axilEp, x"0F8", 16, v.awcache);
      axiSlaveRegister (axilEp, x"0FC", 0, v.cntRst);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.writeSlave, v.readSlave, AXI_RESP_DECERR_C);
      --------------------------------------------------------------------------------------------

      -- Outputs
      writeSlave        <= r.writeSlave;
      readSlave         <= r.readSlave;
      enableTx          <= r.enableTx;
      awcache           <= r.awcache;
      remoteBarBaseAddr <= r.remoteBarBaseAddr;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
