-------------------------------------------------------------------------------
-- File       : PgpMiscCtrl.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-10-04
-- Last update: 2017-10-05
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
use work.AxiLitePkg.all;
use work.AxiPciePkg.all;
use work.AppPkg.all;

entity PgpMiscCtrl is
   generic (
      TPD_G            : time            := 1 ns;
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C);
   port (
      -- Control/Status  (sysClk domain)
      status          : in  StatusType;
      config          : out ConfigType;
      rxUserRst       : out sl;
      txUserRst       : out sl;
      -- AXI-Lite Register Interface (sysClk domain)
      sysClk          : in  sl;
      sysRst          : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end PgpMiscCtrl;

architecture rtl of PgpMiscCtrl is

   constant CNT_MAX_C : slv(31 downto 0) := (others => '1');

   type RegType is record
      config         : ConfigType;
      rxUserRst      : sl;
      txUserRst      : sl;
      cntRst         : sl;
      lutDropCnt     : Slv32Array(3 downto 0);
      fifoErrorCnt   : Slv32Array(3 downto 0);
      vcPauseCnt     : Slv32Array(3 downto 0);
      vcOverflowCnt  : Slv32Array(3 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      config         => CONFIG_INIT_C,
      rxUserRst      => '0',
      txUserRst      => '0',
      cntRst         => '0',
      lutDropCnt     => (others => (others => '0')),
      fifoErrorCnt   => (others => (others => '0')),
      vcPauseCnt     => (others => (others => '0')),
      vcOverflowCnt  => (others => (others => '0')),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal rxUserReset : sl;
   signal txUserReset : sl;

  attribute use_dsp48      : string;
  attribute use_dsp48 of r : signal is "yes";    
   
begin

   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilWriteMaster, r, status, sysRst) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
      variable i      : natural;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.cntRst              := '0';
      v.config.acceptCntRst := '0';

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      for i in 3 downto 0 loop
         axiSlaveRegisterR(regCon, toSlv((4*i)+0, 8), 0, v.lutDropCnt(i));  -- 0x00:0x0F
         axiSlaveRegisterR(regCon, toSlv((4*i)+16, 8), 0, v.fifoErrorCnt(i));  -- 0x10:0x1F
         axiSlaveRegisterR(regCon, toSlv((4*i)+32, 8), 0, v.vcPauseCnt(i));  -- 0x20:0x2F
         axiSlaveRegisterR(regCon, toSlv((4*i)+48, 8), 0, v.vcOverflowCnt(i));  -- 0x30:0x3F
      end loop;

      axiSlaveRegister(regCon, x"40", 0, v.config.runCode);
      axiSlaveRegister(regCon, x"44", 0, v.config.acceptCode);
      axiSlaveRegister(regCon, x"48", 0, v.config.enHeaderCheck);
      axiSlaveRegister(regCon, x"4C", 0, v.config.runDelay);

      axiSlaveRegister(regCon, x"50", 0, v.config.acceptDelay);
      axiSlaveRegister(regCon, x"54", 0, v.config.acceptCntRst);
      axiSlaveRegister(regCon, x"58", 0, v.config.evrOpCodeMask);
      axiSlaveRegister(regCon, x"5C", 0, v.config.evrSyncSel);

      axiSlaveRegister(regCon, x"60", 0, v.config.evrSyncEn);
      axiSlaveRegister(regCon, x"64", 0, v.config.evrSyncWord);
      axiSlaveRegister(regCon, x"68", 0, v.config.gtDrpOverride);
      axiSlaveRegister(regCon, x"6C", 0, v.config.txDiffCtrl);

      axiSlaveRegister(regCon, x"70", 0, v.config.txPreCursor);
      axiSlaveRegister(regCon, x"74", 0, v.config.txPostCursor);
      axiSlaveRegister(regCon, x"78", 0, v.config.qPllRxSelect);
      axiSlaveRegister(regCon, x"7C", 0, v.config.qPllTxSelect);

      axiSlaveRegister(regCon, x"80", 0, v.txUserRst);
      axiSlaveRegister(regCon, x"84", 0, v.rxUserRst);
      axiSlaveRegister(regCon, x"88", 0, v.config.enableTrig);

      axiSlaveRegisterR(regCon, x"90", 0, status.evrSyncStatus);
      axiSlaveRegisterR(regCon, x"94", 0, status.acceptCnt);

      axiSlaveRegister(regCon, x"FC", 0, v.cntRst);

      -- Closeout the transaction
      axiSlaveDefault(regCon, v.axilWriteSlave, v.axilReadSlave, AXI_ERROR_RESP_G);

      if (r.cntRst = '1') then
         v.lutDropCnt    := (others => (others => '0'));
         v.fifoErrorCnt  := (others => (others => '0'));
         v.vcPauseCnt    := (others => (others => '0'));
         v.vcOverflowCnt := (others => (others => '0'));
      else
         for i in 3 downto 0 loop
            if (status.lutDrop(i) = '1') and (r.lutDropCnt(i) /= CNT_MAX_C) then
               v.lutDropCnt(i) := r.lutDropCnt(i) + 1;
            end if;
            if (status.fifoError(i) = '1') and (r.fifoErrorCnt(i) /= CNT_MAX_C) then
               v.fifoErrorCnt(i) := r.fifoErrorCnt(i) + 1;
            end if;
            if (status.vcPause(i) = '1') and (r.vcPauseCnt(i) /= CNT_MAX_C) then
               v.vcPauseCnt(i) := r.vcPauseCnt(i) + 1;
            end if;
            if (status.vcOverflow(i) = '1') and (r.vcOverflowCnt(i) /= CNT_MAX_C) then
               v.vcOverflowCnt(i) := r.vcOverflowCnt(i) + 1;
            end if;
         end loop;
      end if;

      -- Synchronous Reset
      if (sysRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      config         <= r.config;

   end process comb;

   seq : process (sysClk) is
   begin
      if (rising_edge(sysClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_rxUserRst : entity work.PwrUpRst
      generic map (
         TPD_G       => TPD_G,
         USE_DSP48_G => "yes",
         DURATION_G  => 125000000)
      port map (
         arst   => r.rxUserRst,
         clk    => sysClk,
         rstOut => rxUserReset);

   U_RstRx : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClk,
         rstIn  => rxUserReset,
         rstOut => rxUserRst);

   U_txUserRst : entity work.PwrUpRst
      generic map (
         TPD_G       => TPD_G,
         USE_DSP48_G => "yes",
         DURATION_G  => 125000000)
      port map (
         arst   => r.txUserRst,
         clk    => sysClk,
         rstOut => txUserReset);

   U_RstTx : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => sysClk,
         rstIn  => txUserReset,
         rstOut => txUserRst);

end rtl;
