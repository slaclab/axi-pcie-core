-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Split the 512b DMA AXI into two 256b HBM AXI
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
use surf.AxiPkg.all;

entity HbmDmaBufferV2AxiSplit is
   generic (
      TPD_G      : time := 1 ns;
      CH_INDEX_G : natural range 0 to 1);
   port (
      -- AXI-Lite Interface (axilClk domain)
      clk             : in  sl;
      rst             : in  sl;
      -- DMA 512b AXI Interface
      axiWriteMaster  : in  AxiWriteMasterType;
      axiWriteSlave   : out AxiWriteSlaveType;
      axiReadMaster   : in  AxiReadMasterType;
      axiReadSlave    : out AxiReadSlaveType;
      -- HBM 256b AXI Interface
      hbmWriteMasters : out AxiWriteMasterArray(1 downto 0);
      hbmWriteSlaves  : in  AxiWriteSlaveArray(1 downto 0);
      hbmReadMasters  : out AxiReadMasterArray(1 downto 0);
      hbmReadSlaves   : in  AxiReadSlaveArray(1 downto 0));
end HbmDmaBufferV2AxiSplit;

architecture rtl of HbmDmaBufferV2AxiSplit is

   constant HBM_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 33,               -- 8GB HBM
      DATA_BYTES_C => (256/8),          -- 256-bit
      ID_BITS_C    => 1,                -- Unused
      LEN_BITS_C   => 4);               -- 4-bit awlen/arlen interface

   type RegType is record
      axiWriteSlave   : AxiWriteSlaveType;
      axiReadSlave    : AxiReadSlaveType;
      hbmWriteMasters : AxiWriteMasterArray(1 downto 0);
      hbmReadMasters  : AxiReadMasterArray(1 downto 0);
   end record RegType;
   constant REG_INIT_C : RegType := (
      axiWriteSlave   => AXI_WRITE_SLAVE_INIT_C,
      axiReadSlave    => AXI_READ_SLAVE_INIT_C,
      hbmWriteMasters => (others => axiWriteMasterInit(HBM_CONFIG_C, '1', "01", "0000")),
      hbmReadMasters  => (others => axiReadMasterInit(HBM_CONFIG_C, "01", "0000")));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axiReadMaster, axiWriteMaster, hbmReadSlaves,
                   hbmWriteSlaves, r, rst) is
      variable v : RegType;
      variable i : natural;
   begin
      -- Latch the current value
      v := r;

      ----------------------------------------------------------------------

      -- Write address channel Flow control
      v.axiWriteSlave.awready := '0';
      for i in 0 to 1 loop
         if (hbmWriteSlaves(i).awready = '1') then
            v.hbmWriteMasters(i).awvalid := '0';
         end if;
      end loop;

      -- Check for for Write Address channel
      if (axiWriteMaster.awvalid = '1') and (v.hbmWriteMasters(0).awvalid = '0') and (v.hbmWriteMasters(1).awvalid = '0') then

         -- Ack the inbound address TXN
         v.axiWriteSlave.awready := '1';

         -- Setup for the address TXN
         for i in 0 to 1 loop

            v.hbmWriteMasters(i).awvalid := '1';

            v.hbmWriteMasters(i).awaddr(30 downto 0)  := axiWriteMaster.awaddr(30 downto 0);
            v.hbmWriteMasters(i).awaddr(32 downto 31) := toSlv(2*CH_INDEX_G+i, 2);

            v.hbmWriteMasters(i).awlen := axiWriteMaster.awlen;

         end loop;

      end if;

      -- Write data channel Flow control
      v.axiWriteSlave.wready := '0';
      for i in 0 to 1 loop
         if (hbmWriteSlaves(i).wready = '1') then
            v.hbmWriteMasters(i).wvalid := '0';
         end if;
      end loop;

      -- Check for for Write data channel
      if (axiWriteMaster.wvalid = '1') and (v.hbmWriteMasters(0).wvalid = '0') and (v.hbmWriteMasters(1).wvalid = '0') then

         -- Ack the inbound data TXN
         v.axiWriteSlave.wready := '1';

         -- Setup for the data TXN
         for i in 0 to 1 loop

            v.hbmWriteMasters(i).wvalid := '1';
            v.hbmWriteMasters(i).wlast  := axiWriteMaster.wlast;

            v.hbmWriteMasters(i).wdata(255 downto 0) := axiWriteMaster.wdata(256*i+255 downto 256*i);

            v.hbmWriteMasters(i).wstrb := (others => '1');  -- Always write every byte and DMA read will correct for size

         end loop;

      end if;

      -- Write ack channel Flow control
      v.hbmWriteMasters(0).bready := '0';
      v.hbmWriteMasters(1).bready := '0';
      if (axiWriteMaster.bready = '1') then
         v.axiWriteSlave.bvalid := '0';
      end if;

      -- Check for for Write ack channel
      if (hbmWriteSlaves(0).bvalid = '1') and (hbmWriteSlaves(1).bvalid = '1') and (v.axiWriteSlave.bvalid = '0') then

         -- Ack the inbound ACK TXN
         v.hbmWriteMasters(0).bready := '1';
         v.hbmWriteMasters(1).bready := '1';

         -- Setup for the ACK TXN
         v.axiWriteSlave.bvalid := '1';

         v.axiWriteSlave.bresp(0) := hbmWriteSlaves(0).bresp(0) or hbmWriteSlaves(1).bresp(0);
         v.axiWriteSlave.bresp(1) := hbmWriteSlaves(0).bresp(1) or hbmWriteSlaves(1).bresp(1);

      end if;

      -- Outputs
      axiWriteSlave.awready <= v.axiWriteSlave.awready;  -- comb output
      axiWriteSlave.wready  <= v.axiWriteSlave.wready;   -- comb output
      axiWriteSlave.bresp   <= r.axiWriteSlave.bresp;
      axiWriteSlave.bvalid  <= r.axiWriteSlave.bvalid;
      axiWriteSlave.bid     <= r.axiWriteSlave.bid;

      -- More Outputs
      for i in 0 to 1 loop
         hbmWriteMasters(i).awvalid  <= r.hbmWriteMasters(i).awvalid;
         hbmWriteMasters(i).awaddr   <= r.hbmWriteMasters(i).awaddr;
         hbmWriteMasters(i).awid     <= r.hbmWriteMasters(i).awid;
         hbmWriteMasters(i).awlen    <= r.hbmWriteMasters(i).awlen;
         hbmWriteMasters(i).awsize   <= r.hbmWriteMasters(i).awsize;
         hbmWriteMasters(i).awburst  <= r.hbmWriteMasters(i).awburst;
         hbmWriteMasters(i).awlock   <= r.hbmWriteMasters(i).awlock;
         hbmWriteMasters(i).awprot   <= r.hbmWriteMasters(i).awprot;
         hbmWriteMasters(i).awcache  <= r.hbmWriteMasters(i).awcache;
         hbmWriteMasters(i).awqos    <= r.hbmWriteMasters(i).awqos;
         hbmWriteMasters(i).awregion <= r.hbmWriteMasters(i).awregion;
         hbmWriteMasters(i).wdata    <= r.hbmWriteMasters(i).wdata;
         hbmWriteMasters(i).wlast    <= r.hbmWriteMasters(i).wlast;
         hbmWriteMasters(i).wvalid   <= r.hbmWriteMasters(i).wvalid;
         hbmWriteMasters(i).wid      <= r.hbmWriteMasters(i).wid;
         hbmWriteMasters(i).wstrb    <= r.hbmWriteMasters(i).wstrb;
         hbmWriteMasters(i).bready   <= v.hbmWriteMasters(i).bready;  -- comb output
      end loop;

      ----------------------------------------------------------------------

      -- Read Address channel Flow control
      v.axiReadSlave.arready := '0';
      for i in 0 to 1 loop
         if (hbmReadSlaves(i).arready = '1') then
            v.hbmReadMasters(i).arvalid := '0';
         end if;
      end loop;

      -- Check for for Read Address channel
      if (axiReadMaster.arvalid = '1') and (v.hbmReadMasters(0).arvalid = '0') and (v.hbmReadMasters(1).arvalid = '0') then

         -- Ack the inbound address TXN
         v.axiReadSlave.arready := '1';

         -- Setup for the address TXN
         for i in 0 to 1 loop

            v.hbmReadMasters(i).arvalid := '1';

            v.hbmReadMasters(i).araddr(30 downto 0)  := axiReadMaster.araddr(30 downto 0);
            v.hbmReadMasters(i).araddr(32 downto 31) := toSlv(2*CH_INDEX_G+i, 2);

            v.hbmReadMasters(i).arlen := axiReadMaster.arlen;

         end loop;

      end if;

      -- Read data channel Flow control
      v.hbmReadMasters(0).rready := '0';
      v.hbmReadMasters(1).rready := '0';
      if (axiReadMaster.rready = '1') then
         v.axiReadSlave.rvalid := '0';
      end if;

      -- Check for for Read data channel
      if (hbmReadSlaves(0).rvalid = '1') and (hbmReadSlaves(1).rvalid = '1') and (v.axiReadSlave.rvalid = '0') then

         -- Ack the inbound data TXN
         v.hbmReadMasters(0).rready := '1';
         v.hbmReadMasters(1).rready := '1';

         -- Setup for the data TXN
         v.axiReadSlave.rvalid := '1';

         v.axiReadSlave.rlast := hbmReadSlaves(0).rlast;

         v.axiReadSlave.rresp(0) := hbmReadSlaves(0).rresp(0) or hbmReadSlaves(1).rresp(0);
         v.axiReadSlave.rresp(1) := hbmReadSlaves(0).rresp(1) or hbmReadSlaves(1).rresp(1);

         v.axiReadSlave.rdata(255 downto 0)   := hbmReadSlaves(0).rdata(255 downto 0);
         v.axiReadSlave.rdata(511 downto 256) := hbmReadSlaves(1).rdata(255 downto 0);

      end if;

      -- Outputs
      axiReadSlave.arready <= v.axiReadSlave.arready;  -- comb output
      axiReadSlave.rdata   <= r.axiReadSlave.rdata;
      axiReadSlave.rlast   <= r.axiReadSlave.rlast;
      axiReadSlave.rvalid  <= r.axiReadSlave.rvalid;
      axiReadSlave.rid     <= r.axiReadSlave.rid;
      axiReadSlave.rresp   <= r.axiReadSlave.rresp;

      -- More Outputs
      for i in 0 to 1 loop
         hbmReadMasters(i).arvalid  <= r.hbmReadMasters(i).arvalid;
         hbmReadMasters(i).araddr   <= r.hbmReadMasters(i).araddr;
         hbmReadMasters(i).arid     <= r.hbmReadMasters(i).arid;
         hbmReadMasters(i).arlen    <= r.hbmReadMasters(i).arlen;
         hbmReadMasters(i).arsize   <= r.hbmReadMasters(i).arsize;
         hbmReadMasters(i).arburst  <= r.hbmReadMasters(i).arburst;
         hbmReadMasters(i).arlock   <= r.hbmReadMasters(i).arlock;
         hbmReadMasters(i).arprot   <= r.hbmReadMasters(i).arprot;
         hbmReadMasters(i).arcache  <= r.hbmReadMasters(i).arcache;
         hbmReadMasters(i).arqos    <= r.hbmReadMasters(i).arqos;
         hbmReadMasters(i).arregion <= r.hbmReadMasters(i).arregion;
         hbmReadMasters(i).rready   <= v.hbmReadMasters(i).rready;  -- comb output
      end loop;

      ----------------------------------------------------------------------

      -- Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
