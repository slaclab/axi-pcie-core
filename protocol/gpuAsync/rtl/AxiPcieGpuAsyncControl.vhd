-------------------------------------------------------------------------------
-- File       : AxiPcieGpuAsyncControl.vhd
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

entity AxiPcieGpuAsyncControl is
   generic (
      TPD_G      : time                   := 1 ns;
      NUM_CHAN_G : positive range 1 to 4  := 1);
   port (
      axiClk            : in  sl;
      axiRst            : in  sl;

      -- Configuration
      remoteDmaAddr     : in  Slv32Array(NUM_CHAN_G-1 downto 0);
      remoteDmaSize     : in  Slv32Array(NUM_CHAN_G-1 downto 0);
      enableTx          : in  sl;
      enableRx          : in  sl;

      -- Status
      rxFrame           : out sl;
      txFrame           : out sl;
      txAxiError        : out sl;

      -- DMA Write Engine
      dmaWrDescReq      : in  AxiWriteDmaDescReqType;
      dmaWrDescAck      : out AxiWriteDmaDescAckType;
      dmaWrDescRet      : in  AxiWriteDmaDescRetType;
      dmaWrDescRetAck   : out sl);

end AxiPcieGpuAsyncControl;

architecture mapping of AxiPcieGpuAsyncControl is

   type StateType is ( IDLE_S, MOVE_S);

   type RegType is record
      state             : StateType;
      rxFrame           : sl;
      txFrame           : sl;
      txAxiError        : sl;
      dmaWrDescAck      : AxiWriteDmaDescAckType;
      dmaWrDescRetAck   : sl;
   end record;

   constant REG_INIT_C : RegType := (
      state             => IDLE_S,
      rxFrame           => '0',
      txFrame           => '0',
      txAxiError        => '0',
      dmaWrDescAck      => AXI_WRITE_DMA_DESC_ACK_INIT_C,
      dmaWrDescRetAck   => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   --------------------- 
   -- State Machine
   --------------------- 
   comb : process (axiRst, r, remoteDmaAddr, remoteDmaSize, enableTx, enableRx, dmaWrDescReq, dmaWrDescRet ) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.rxFrame    := '0';
      v.txFrame    := '0';
      v.txAxiError := '0';

      v.dmaWrDescAck.valid := '0';
      v.dmaWrDescRetAck := '0';

      -- State Machine
      case r.state is

         when IDLE_S =>

            if dmaWrDescReq.valid = '1' then
               v.state := MOVE_S;

               v.dmaWrDescAck.valid   := '1';
               v.dmaWrDescAck.address(31 downto 0) := remoteDmaAddr(0);
               v.dmaWrDescAck.dropEn  := not enableRx;
               v.dmaWrDescAck.maxSize := remoteDmaSize(0);
               v.dmaWrDescAck.contEn  := '0';
               v.dmaWrDescAck.buffId  := toSlv(0,32); -- Channel ID
            end if;

         when MOVE_S =>

            if dmaWrDescRet.valid = '1' then
               v.dmaWrDescRetAck := '1';

               -- act on buff id
               --dmaWrDescRet.buffId

               if dmaWrDescRet.result /= "000" then
                  v.txAxiError := '1';
               end if;

               v.rxFrame := '1';

               v.state := IDLE_S;
            end if;
      end case;

      -- Outputs
      rxFrame         <= r.rxFrame;
      txFrame         <= r.txFrame;
      txAxiError      <= r.txAxiError;
      dmaWrDescAck    <= r.dmaWrDescAck;
      dmaWrDescRetAck <= r.dmaWrDescRetAck;

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

