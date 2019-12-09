-------------------------------------------------------------------------------
-- File       : AxiPcieGpuAsyncReg.vhd
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

entity AxiPcieGpuAsyncReg is
   generic (
      TPD_G      : time                   := 1 ns;
      NUM_CHAN_G : positive range 1 to 4  := 1);
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
      rxFrame           : in  sl;
      txFrame           : in  sl;
      txAxiError        : in  sl;
      enableTx          : out sl;
      enableRx          : out sl;
      awcache           : out slv(3 downto 0);
      remoteDmaAddr     : out Slv32Array(NUM_CHAN_G-1 downto 0);
      remoteDmaSize     : out Slv32Array(NUM_CHAN_G-1 downto 0));
end AxiPcieGpuAsyncReg;

architecture mapping of AxiPcieGpuAsyncReg is

   type RegType is record
      rxFrameCnt        : slv(31 downto 0);
      txFrameCnt        : slv(31 downto 0);
      axiErrorCnt       : slv(31 downto 0);
      cntRst            : sl;
      enableTx          : sl;
      enableRx          : sl;
      awcache           : slv(3 downto 0);
      remoteDmaAddr     : Slv32Array(NUM_CHAN_G-1 downto 0);
      remoteDmaSize     : Slv32Array(NUM_CHAN_G-1 downto 0);
      readSlave         : AxiLiteReadSlaveType;
      writeSlave        : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rxFrameCnt        => (others => '0'),
      txFrameCnt        => (others => '0'),
      axiErrorCnt       => (others => '0'),
      cntRst            => '0',
      enableTx          => '0',
      enableRx          => '0',
      awcache           => (others => '0'),
      remoteDmaAddr     => (others => (others => '0')),
      remoteDmaSize     => (others => (others => '0')),
      readSlave         => AXI_LITE_READ_SLAVE_INIT_C,
      writeSlave        => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal readMaster  : AxiLiteReadMasterType;
   signal readSlave   : AxiLiteReadSlaveType;
   signal writeMaster : AxiLiteWriteMasterType;
   signal writeSlave  : AxiLiteWriteSlaveType;

begin

   U_AxiLiteAsync : entity work.AxiLiteAsync
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
   comb : process (axiRst, r, readMaster, rxFrame, txAxiError, txFrame, writeMaster) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.cntRst := '0';

      if (txAxiError = '1') then
         v.axiErrorCnt := r.axiErrorCnt + 1;
      end if;

      -- Check for RX/TX frames
      if (rxFrame = '1') then
         v.rxFrameCnt := r.rxFrameCnt + 1;
      end if;
      if (txFrame = '1') then
         v.txFrameCnt := r.txFrameCnt + 1;
      end if;

      -- Check for counter reset
      if (r.cntRst = '1') then
         v.rxFrameCnt  := (others => '0');
         v.txFrameCnt  := (others => '0');
         v.axiErrorCnt := (others => '0');
      end if;

      --------------------------------------------------------------------------------------------
      -- Determine the transaction type
      --------------------------------------------------------------------------------------------
      axiSlaveWaitTxn(axilEp, writeMaster, readMaster, v.writeSlave, v.readSlave);

      -- Register Mapping
      for i in NUM_CHAN_G-1 downto 0 loop
         axiSlaveRegister (axilEp, toSlv(i*8, 12), 0,     v.remoteDmaAddr(i));      -- [0x000:0x07F]
         axiSlaveRegister (axilEp, toSlv(128+i*4, 12), 0, v.remoteDmaSize(i));      -- [0x080:0x0BF]
      end loop;

      axiSlaveRegisterR(axilEp, x"0E0", 0, r.rxFrameCnt);
      axiSlaveRegisterR(axilEp, x"0E8", 0, r.txFrameCnt);
      axiSlaveRegisterR(axilEp, x"0F0", 0, r.axiErrorCnt);

      axiSlaveRegisterR(axilEp, x"0F4", 0, toSlv(NUM_CHAN_G, 5));
      axiSlaveRegister (axilEp, x"0F8", 0, v.enableTx);
      axiSlaveRegister (axilEp, x"0F8", 1, v.enableRx);
      axiSlaveRegister (axilEp, x"0F8", 16, v.awcache);
      axiSlaveRegister (axilEp, x"0FC", 0, v.cntRst);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.writeSlave, v.readSlave, AXI_RESP_DECERR_C);
      --------------------------------------------------------------------------------------------

      -- Outputs
      writeSlave        <= r.writeSlave;
      readSlave         <= r.readSlave;
      enableTx          <= r.enableTx;
      enableRx          <= r.enableRx;
      awcache           <= r.awcache;
      remoteDmaAddr     <= r.remoteDmaAddr;
      remoteDmaSize     <= r.remoteDmaSize;

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
