-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation-only behavioral model of the HbmDmaBufferV2IpCore
--
-- Stands in for the Xilinx HBM IP, which GHDL cannot simulate. The entity has
-- the same name and ports as the component declared in HbmDmaBufferV2.vhd, so
-- the default component binding picks it up with no change to the RTL.
--
-- Model scope (matches how the IP is configured in HbmDmaBufferV2IpCore.xci):
--    * The four AXI3 ports share one sparse memory (global addressing)
--    * 256-bit full-width INCR bursts only, one burst at a time per port
--    * WSTRB is honored (the data mask is enabled in the IP)
--    * Never-written bytes read back as 0xEE
--    * Parity, ECC, temperature and catastrophic-trip behavior are not modeled
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
use ieee.numeric_std.all;

entity HbmDmaBufferV2IpCore is
   port (
      HBM_REF_CLK_0       : in  std_logic;
      HBM_REF_CLK_1       : in  std_logic;
      AXI_07_ACLK         : in  std_logic;
      AXI_07_ARESET_N     : in  std_logic;
      AXI_07_ARADDR       : in  std_logic_vector(32 downto 0);
      AXI_07_ARBURST      : in  std_logic_vector(1 downto 0);
      AXI_07_ARID         : in  std_logic_vector(5 downto 0);
      AXI_07_ARLEN        : in  std_logic_vector(3 downto 0);
      AXI_07_ARSIZE       : in  std_logic_vector(2 downto 0);
      AXI_07_ARVALID      : in  std_logic;
      AXI_07_AWADDR       : in  std_logic_vector(32 downto 0);
      AXI_07_AWBURST      : in  std_logic_vector(1 downto 0);
      AXI_07_AWID         : in  std_logic_vector(5 downto 0);
      AXI_07_AWLEN        : in  std_logic_vector(3 downto 0);
      AXI_07_AWSIZE       : in  std_logic_vector(2 downto 0);
      AXI_07_AWVALID      : in  std_logic;
      AXI_07_RREADY       : in  std_logic;
      AXI_07_BREADY       : in  std_logic;
      AXI_07_WDATA        : in  std_logic_vector(255 downto 0);
      AXI_07_WLAST        : in  std_logic;
      AXI_07_WSTRB        : in  std_logic_vector(31 downto 0);
      AXI_07_WDATA_PARITY : in  std_logic_vector(31 downto 0);
      AXI_07_WVALID       : in  std_logic;
      AXI_08_ACLK         : in  std_logic;
      AXI_08_ARESET_N     : in  std_logic;
      AXI_08_ARADDR       : in  std_logic_vector(32 downto 0);
      AXI_08_ARBURST      : in  std_logic_vector(1 downto 0);
      AXI_08_ARID         : in  std_logic_vector(5 downto 0);
      AXI_08_ARLEN        : in  std_logic_vector(3 downto 0);
      AXI_08_ARSIZE       : in  std_logic_vector(2 downto 0);
      AXI_08_ARVALID      : in  std_logic;
      AXI_08_AWADDR       : in  std_logic_vector(32 downto 0);
      AXI_08_AWBURST      : in  std_logic_vector(1 downto 0);
      AXI_08_AWID         : in  std_logic_vector(5 downto 0);
      AXI_08_AWLEN        : in  std_logic_vector(3 downto 0);
      AXI_08_AWSIZE       : in  std_logic_vector(2 downto 0);
      AXI_08_AWVALID      : in  std_logic;
      AXI_08_RREADY       : in  std_logic;
      AXI_08_BREADY       : in  std_logic;
      AXI_08_WDATA        : in  std_logic_vector(255 downto 0);
      AXI_08_WLAST        : in  std_logic;
      AXI_08_WSTRB        : in  std_logic_vector(31 downto 0);
      AXI_08_WDATA_PARITY : in  std_logic_vector(31 downto 0);
      AXI_08_WVALID       : in  std_logic;
      AXI_23_ACLK         : in  std_logic;
      AXI_23_ARESET_N     : in  std_logic;
      AXI_23_ARADDR       : in  std_logic_vector(32 downto 0);
      AXI_23_ARBURST      : in  std_logic_vector(1 downto 0);
      AXI_23_ARID         : in  std_logic_vector(5 downto 0);
      AXI_23_ARLEN        : in  std_logic_vector(3 downto 0);
      AXI_23_ARSIZE       : in  std_logic_vector(2 downto 0);
      AXI_23_ARVALID      : in  std_logic;
      AXI_23_AWADDR       : in  std_logic_vector(32 downto 0);
      AXI_23_AWBURST      : in  std_logic_vector(1 downto 0);
      AXI_23_AWID         : in  std_logic_vector(5 downto 0);
      AXI_23_AWLEN        : in  std_logic_vector(3 downto 0);
      AXI_23_AWSIZE       : in  std_logic_vector(2 downto 0);
      AXI_23_AWVALID      : in  std_logic;
      AXI_23_RREADY       : in  std_logic;
      AXI_23_BREADY       : in  std_logic;
      AXI_23_WDATA        : in  std_logic_vector(255 downto 0);
      AXI_23_WLAST        : in  std_logic;
      AXI_23_WSTRB        : in  std_logic_vector(31 downto 0);
      AXI_23_WDATA_PARITY : in  std_logic_vector(31 downto 0);
      AXI_23_WVALID       : in  std_logic;
      AXI_24_ACLK         : in  std_logic;
      AXI_24_ARESET_N     : in  std_logic;
      AXI_24_ARADDR       : in  std_logic_vector(32 downto 0);
      AXI_24_ARBURST      : in  std_logic_vector(1 downto 0);
      AXI_24_ARID         : in  std_logic_vector(5 downto 0);
      AXI_24_ARLEN        : in  std_logic_vector(3 downto 0);
      AXI_24_ARSIZE       : in  std_logic_vector(2 downto 0);
      AXI_24_ARVALID      : in  std_logic;
      AXI_24_AWADDR       : in  std_logic_vector(32 downto 0);
      AXI_24_AWBURST      : in  std_logic_vector(1 downto 0);
      AXI_24_AWID         : in  std_logic_vector(5 downto 0);
      AXI_24_AWLEN        : in  std_logic_vector(3 downto 0);
      AXI_24_AWSIZE       : in  std_logic_vector(2 downto 0);
      AXI_24_AWVALID      : in  std_logic;
      AXI_24_RREADY       : in  std_logic;
      AXI_24_BREADY       : in  std_logic;
      AXI_24_WDATA        : in  std_logic_vector(255 downto 0);
      AXI_24_WLAST        : in  std_logic;
      AXI_24_WSTRB        : in  std_logic_vector(31 downto 0);
      AXI_24_WDATA_PARITY : in  std_logic_vector(31 downto 0);
      AXI_24_WVALID       : in  std_logic;
      APB_0_PCLK          : in  std_logic;
      APB_0_PRESET_N      : in  std_logic;
      APB_1_PCLK          : in  std_logic;
      APB_1_PRESET_N      : in  std_logic;
      AXI_07_ARREADY      : out std_logic;
      AXI_07_AWREADY      : out std_logic;
      AXI_07_RDATA_PARITY : out std_logic_vector(31 downto 0);
      AXI_07_RDATA        : out std_logic_vector(255 downto 0);
      AXI_07_RID          : out std_logic_vector(5 downto 0);
      AXI_07_RLAST        : out std_logic;
      AXI_07_RRESP        : out std_logic_vector(1 downto 0);
      AXI_07_RVALID       : out std_logic;
      AXI_07_WREADY       : out std_logic;
      AXI_07_BID          : out std_logic_vector(5 downto 0);
      AXI_07_BRESP        : out std_logic_vector(1 downto 0);
      AXI_07_BVALID       : out std_logic;
      AXI_08_ARREADY      : out std_logic;
      AXI_08_AWREADY      : out std_logic;
      AXI_08_RDATA_PARITY : out std_logic_vector(31 downto 0);
      AXI_08_RDATA        : out std_logic_vector(255 downto 0);
      AXI_08_RID          : out std_logic_vector(5 downto 0);
      AXI_08_RLAST        : out std_logic;
      AXI_08_RRESP        : out std_logic_vector(1 downto 0);
      AXI_08_RVALID       : out std_logic;
      AXI_08_WREADY       : out std_logic;
      AXI_08_BID          : out std_logic_vector(5 downto 0);
      AXI_08_BRESP        : out std_logic_vector(1 downto 0);
      AXI_08_BVALID       : out std_logic;
      AXI_23_ARREADY      : out std_logic;
      AXI_23_AWREADY      : out std_logic;
      AXI_23_RDATA_PARITY : out std_logic_vector(31 downto 0);
      AXI_23_RDATA        : out std_logic_vector(255 downto 0);
      AXI_23_RID          : out std_logic_vector(5 downto 0);
      AXI_23_RLAST        : out std_logic;
      AXI_23_RRESP        : out std_logic_vector(1 downto 0);
      AXI_23_RVALID       : out std_logic;
      AXI_23_WREADY       : out std_logic;
      AXI_23_BID          : out std_logic_vector(5 downto 0);
      AXI_23_BRESP        : out std_logic_vector(1 downto 0);
      AXI_23_BVALID       : out std_logic;
      AXI_24_ARREADY      : out std_logic;
      AXI_24_AWREADY      : out std_logic;
      AXI_24_RDATA_PARITY : out std_logic_vector(31 downto 0);
      AXI_24_RDATA        : out std_logic_vector(255 downto 0);
      AXI_24_RID          : out std_logic_vector(5 downto 0);
      AXI_24_RLAST        : out std_logic;
      AXI_24_RRESP        : out std_logic_vector(1 downto 0);
      AXI_24_RVALID       : out std_logic;
      AXI_24_WREADY       : out std_logic;
      AXI_24_BID          : out std_logic_vector(5 downto 0);
      AXI_24_BRESP        : out std_logic_vector(1 downto 0);
      AXI_24_BVALID       : out std_logic;
      apb_complete_0      : out std_logic;
      apb_complete_1      : out std_logic;
      DRAM_0_STAT_CATTRIP : out std_logic;
      DRAM_0_STAT_TEMP    : out std_logic_vector(6 downto 0);
      DRAM_1_STAT_CATTRIP : out std_logic;
      DRAM_1_STAT_TEMP    : out std_logic_vector(6 downto 0)
      );
end entity HbmDmaBufferV2IpCore;

architecture sim of HbmDmaBufferV2IpCore is

   constant TPD_C : time := 1 ns;

   subtype WordType is std_logic_vector(255 downto 0);
   subtype StrbType is std_logic_vector(31 downto 0);

   -- Sparse memory of 32B words, shared by all AXI ports
   type MemType is protected
      procedure write (word : in natural; strb : in StrbType; data : in WordType);
      impure function read (word : natural) return WordType;
   end protected MemType;

   type MemType is protected body

      constant SIZE_C : positive := 2**16;

      type KeyArray is array (0 to SIZE_C-1) of integer;
      type DataArray is array (0 to SIZE_C-1) of WordType;

      variable keys : KeyArray := (others => -1);
      variable mem  : DataArray;

      -- Hash table lookup with linear probing (returns -1 if missing and not created)
      impure function find (word : natural; create : boolean) return integer is
         variable idx : natural;
      begin
         idx := (word + (word/16384)*4099) mod SIZE_C;
         for k in 0 to SIZE_C-1 loop
            if (keys(idx) = word) then
               return idx;
            elsif (keys(idx) = -1) then
               if create then
                  keys(idx) := word;
                  for b in 0 to 31 loop
                     mem(idx)(8*b+7 downto 8*b) := x"EE";
                  end loop;
                  return idx;
               else
                  return -1;
               end if;
            end if;
            idx := (idx + 1) mod SIZE_C;
         end loop;
         report "HbmDmaBufferV2IpCore: sparse memory model is full" severity failure;
         return -1;
      end function;

      procedure write (word : in natural; strb : in StrbType; data : in WordType) is
         variable idx : integer;
      begin
         idx := find(word, true);
         for b in 0 to 31 loop
            if (strb(b) = '1') then
               mem(idx)(8*b+7 downto 8*b) := data(8*b+7 downto 8*b);
            end if;
         end loop;
      end procedure;

      impure function read (word : natural) return WordType is
         variable idx : integer;
         variable ret : WordType;
      begin
         idx := find(word, false);
         if (idx < 0) then
            for b in 0 to 31 loop
               ret(8*b+7 downto 8*b) := x"EE";
            end loop;
         else
            ret := mem(idx);
         end if;
         return ret;
      end function;

   end protected body MemType;

   shared variable hbm : MemType;

   type AddrArray is array (3 downto 0) of std_logic_vector(32 downto 0);
   type IdArray is array (3 downto 0) of std_logic_vector(5 downto 0);
   type LenArray is array (3 downto 0) of std_logic_vector(3 downto 0);
   type SizeArray is array (3 downto 0) of std_logic_vector(2 downto 0);
   type BurstArray is array (3 downto 0) of std_logic_vector(1 downto 0);
   type WordArray is array (3 downto 0) of WordType;
   type StrbArray is array (3 downto 0) of StrbType;

   type WrStateType is (W_ADDR_S, W_DATA_S, W_RESP_S);
   type RdStateType is (R_ADDR_S, R_DATA_S);

   signal aclk    : std_logic_vector(3 downto 0);
   signal aresetN : std_logic_vector(3 downto 0);

   signal awaddr  : AddrArray;
   signal awburst : BurstArray;
   signal awid    : IdArray;
   signal awlen   : LenArray;
   signal awsize  : SizeArray;
   signal awvalid : std_logic_vector(3 downto 0);
   signal awready : std_logic_vector(3 downto 0) := (others => '0');
   signal wdata   : WordArray;
   signal wstrb   : StrbArray;
   signal wlast   : std_logic_vector(3 downto 0);
   signal wvalid  : std_logic_vector(3 downto 0);
   signal wready  : std_logic_vector(3 downto 0) := (others => '0');
   signal bid     : IdArray                      := (others => (others => '0'));
   signal bvalid  : std_logic_vector(3 downto 0) := (others => '0');
   signal bready  : std_logic_vector(3 downto 0);

   signal araddr  : AddrArray;
   signal arburst : BurstArray;
   signal arid    : IdArray;
   signal arlen   : LenArray;
   signal arsize  : SizeArray;
   signal arvalid : std_logic_vector(3 downto 0);
   signal arready : std_logic_vector(3 downto 0) := (others => '0');
   signal rdata   : WordArray                    := (others => (others => '0'));
   signal rid     : IdArray                      := (others => (others => '0'));
   signal rlast   : std_logic_vector(3 downto 0) := (others => '0');
   signal rvalid  : std_logic_vector(3 downto 0) := (others => '0');
   signal rready  : std_logic_vector(3 downto 0);

   signal apbDone : std_logic_vector(1 downto 0) := (others => '0');

begin

   -- AXI_07 port
   aclk(0)    <= AXI_07_ACLK;
   aresetN(0) <= AXI_07_ARESET_N;
   awaddr(0)  <= AXI_07_AWADDR;
   awburst(0) <= AXI_07_AWBURST;
   awid(0)    <= AXI_07_AWID;
   awlen(0)   <= AXI_07_AWLEN;
   awsize(0)  <= AXI_07_AWSIZE;
   awvalid(0) <= AXI_07_AWVALID;
   wdata(0)   <= AXI_07_WDATA;
   wstrb(0)   <= AXI_07_WSTRB;
   wlast(0)   <= AXI_07_WLAST;
   wvalid(0)  <= AXI_07_WVALID;
   bready(0)  <= AXI_07_BREADY;
   araddr(0)  <= AXI_07_ARADDR;
   arburst(0) <= AXI_07_ARBURST;
   arid(0)    <= AXI_07_ARID;
   arlen(0)   <= AXI_07_ARLEN;
   arsize(0)  <= AXI_07_ARSIZE;
   arvalid(0) <= AXI_07_ARVALID;
   rready(0)  <= AXI_07_RREADY;
   AXI_07_AWREADY      <= awready(0);
   AXI_07_WREADY       <= wready(0);
   AXI_07_BID          <= bid(0);
   AXI_07_BVALID       <= bvalid(0);
   AXI_07_ARREADY      <= arready(0);
   AXI_07_RDATA        <= rdata(0);
   AXI_07_RID          <= rid(0);
   AXI_07_RLAST        <= rlast(0);
   AXI_07_RVALID       <= rvalid(0);
   AXI_07_BRESP        <= "00";
   AXI_07_RRESP        <= "00";
   AXI_07_RDATA_PARITY <= (others => '0');

   -- AXI_08 port
   aclk(1)    <= AXI_08_ACLK;
   aresetN(1) <= AXI_08_ARESET_N;
   awaddr(1)  <= AXI_08_AWADDR;
   awburst(1) <= AXI_08_AWBURST;
   awid(1)    <= AXI_08_AWID;
   awlen(1)   <= AXI_08_AWLEN;
   awsize(1)  <= AXI_08_AWSIZE;
   awvalid(1) <= AXI_08_AWVALID;
   wdata(1)   <= AXI_08_WDATA;
   wstrb(1)   <= AXI_08_WSTRB;
   wlast(1)   <= AXI_08_WLAST;
   wvalid(1)  <= AXI_08_WVALID;
   bready(1)  <= AXI_08_BREADY;
   araddr(1)  <= AXI_08_ARADDR;
   arburst(1) <= AXI_08_ARBURST;
   arid(1)    <= AXI_08_ARID;
   arlen(1)   <= AXI_08_ARLEN;
   arsize(1)  <= AXI_08_ARSIZE;
   arvalid(1) <= AXI_08_ARVALID;
   rready(1)  <= AXI_08_RREADY;
   AXI_08_AWREADY      <= awready(1);
   AXI_08_WREADY       <= wready(1);
   AXI_08_BID          <= bid(1);
   AXI_08_BVALID       <= bvalid(1);
   AXI_08_ARREADY      <= arready(1);
   AXI_08_RDATA        <= rdata(1);
   AXI_08_RID          <= rid(1);
   AXI_08_RLAST        <= rlast(1);
   AXI_08_RVALID       <= rvalid(1);
   AXI_08_BRESP        <= "00";
   AXI_08_RRESP        <= "00";
   AXI_08_RDATA_PARITY <= (others => '0');

   -- AXI_23 port
   aclk(2)    <= AXI_23_ACLK;
   aresetN(2) <= AXI_23_ARESET_N;
   awaddr(2)  <= AXI_23_AWADDR;
   awburst(2) <= AXI_23_AWBURST;
   awid(2)    <= AXI_23_AWID;
   awlen(2)   <= AXI_23_AWLEN;
   awsize(2)  <= AXI_23_AWSIZE;
   awvalid(2) <= AXI_23_AWVALID;
   wdata(2)   <= AXI_23_WDATA;
   wstrb(2)   <= AXI_23_WSTRB;
   wlast(2)   <= AXI_23_WLAST;
   wvalid(2)  <= AXI_23_WVALID;
   bready(2)  <= AXI_23_BREADY;
   araddr(2)  <= AXI_23_ARADDR;
   arburst(2) <= AXI_23_ARBURST;
   arid(2)    <= AXI_23_ARID;
   arlen(2)   <= AXI_23_ARLEN;
   arsize(2)  <= AXI_23_ARSIZE;
   arvalid(2) <= AXI_23_ARVALID;
   rready(2)  <= AXI_23_RREADY;
   AXI_23_AWREADY      <= awready(2);
   AXI_23_WREADY       <= wready(2);
   AXI_23_BID          <= bid(2);
   AXI_23_BVALID       <= bvalid(2);
   AXI_23_ARREADY      <= arready(2);
   AXI_23_RDATA        <= rdata(2);
   AXI_23_RID          <= rid(2);
   AXI_23_RLAST        <= rlast(2);
   AXI_23_RVALID       <= rvalid(2);
   AXI_23_BRESP        <= "00";
   AXI_23_RRESP        <= "00";
   AXI_23_RDATA_PARITY <= (others => '0');

   -- AXI_24 port
   aclk(3)    <= AXI_24_ACLK;
   aresetN(3) <= AXI_24_ARESET_N;
   awaddr(3)  <= AXI_24_AWADDR;
   awburst(3) <= AXI_24_AWBURST;
   awid(3)    <= AXI_24_AWID;
   awlen(3)   <= AXI_24_AWLEN;
   awsize(3)  <= AXI_24_AWSIZE;
   awvalid(3) <= AXI_24_AWVALID;
   wdata(3)   <= AXI_24_WDATA;
   wstrb(3)   <= AXI_24_WSTRB;
   wlast(3)   <= AXI_24_WLAST;
   wvalid(3)  <= AXI_24_WVALID;
   bready(3)  <= AXI_24_BREADY;
   araddr(3)  <= AXI_24_ARADDR;
   arburst(3) <= AXI_24_ARBURST;
   arid(3)    <= AXI_24_ARID;
   arlen(3)   <= AXI_24_ARLEN;
   arsize(3)  <= AXI_24_ARSIZE;
   arvalid(3) <= AXI_24_ARVALID;
   rready(3)  <= AXI_24_RREADY;
   AXI_24_AWREADY      <= awready(3);
   AXI_24_WREADY       <= wready(3);
   AXI_24_BID          <= bid(3);
   AXI_24_BVALID       <= bvalid(3);
   AXI_24_ARREADY      <= arready(3);
   AXI_24_RDATA        <= rdata(3);
   AXI_24_RID          <= rid(3);
   AXI_24_RLAST        <= rlast(3);
   AXI_24_RVALID       <= rvalid(3);
   AXI_24_BRESP        <= "00";
   AXI_24_RRESP        <= "00";
   AXI_24_RDATA_PARITY <= (others => '0');

   GEN_PORT : for i in 3 downto 0 generate

      process (aclk(i)) is
         variable wrState : WrStateType := W_ADDR_S;
         variable rdState : RdStateType := R_ADDR_S;
         variable wrWord  : natural     := 0;
         variable wrBeat  : natural     := 0;
         variable wrLen   : natural     := 0;
         variable rdWord  : natural     := 0;
         variable rdBeat  : natural     := 0;
         variable rdLen   : natural     := 0;
      begin
         if rising_edge(aclk(i)) then
            if (aresetN(i) = '0') then
               wrState    := W_ADDR_S;
               rdState    := R_ADDR_S;
               awready(i) <= '0' after TPD_C;
               wready(i)  <= '0' after TPD_C;
               bvalid(i)  <= '0' after TPD_C;
               arready(i) <= '0' after TPD_C;
               rvalid(i)  <= '0' after TPD_C;
               rlast(i)   <= '0' after TPD_C;
            else

               -------------------------------------------------------------
               -- Write channels
               -------------------------------------------------------------
               case wrState is
                  when W_ADDR_S =>
                     awready(i) <= '1' after TPD_C;
                     if (awvalid(i) = '1') and (awready(i) = '1') then
                        assert (awsize(i) = "101")
                           report "HbmDmaBufferV2IpCore: AWSIZE is not 32 bytes" severity failure;
                        assert (awburst(i) = "01")
                           report "HbmDmaBufferV2IpCore: AWBURST is not INCR" severity failure;
                        assert (awaddr(i)(4 downto 0) = "00000")
                           report "HbmDmaBufferV2IpCore: AWADDR is not 32 byte aligned" severity failure;
                        wrWord := to_integer(unsigned(awaddr(i)(32 downto 5)));
                        wrLen  := to_integer(unsigned(awlen(i)));
                        wrBeat := 0;
                        assert ((to_integer(unsigned(awaddr(i)(11 downto 0))) + 32*(wrLen+1)) <= 4096)
                           report "HbmDmaBufferV2IpCore: write burst crosses a 4kB boundary" severity failure;
                        bid(i)     <= awid(i) after TPD_C;
                        awready(i) <= '0'     after TPD_C;
                        wready(i)  <= '1'     after TPD_C;
                        wrState    := W_DATA_S;
                     end if;
                  when W_DATA_S =>
                     if (wvalid(i) = '1') and (wready(i) = '1') then
                        hbm.write(wrWord + wrBeat, wstrb(i), wdata(i));
                        if (wrBeat = wrLen) then
                           assert (wlast(i) = '1')
                              report "HbmDmaBufferV2IpCore: WLAST missing on the last beat" severity failure;
                           wready(i) <= '0' after TPD_C;
                           bvalid(i) <= '1' after TPD_C;
                           wrState   := W_RESP_S;
                        else
                           assert (wlast(i) = '0')
                              report "HbmDmaBufferV2IpCore: WLAST before the last beat" severity failure;
                           wrBeat := wrBeat + 1;
                        end if;
                     end if;
                  when W_RESP_S =>
                     if (bready(i) = '1') and (bvalid(i) = '1') then
                        bvalid(i) <= '0' after TPD_C;
                        wrState   := W_ADDR_S;
                     end if;
               end case;

               -------------------------------------------------------------
               -- Read channels
               -------------------------------------------------------------
               case rdState is
                  when R_ADDR_S =>
                     arready(i) <= '1' after TPD_C;
                     if (arvalid(i) = '1') and (arready(i) = '1') then
                        assert (arsize(i) = "101")
                           report "HbmDmaBufferV2IpCore: ARSIZE is not 32 bytes" severity failure;
                        assert (arburst(i) = "01")
                           report "HbmDmaBufferV2IpCore: ARBURST is not INCR" severity failure;
                        assert (araddr(i)(4 downto 0) = "00000")
                           report "HbmDmaBufferV2IpCore: ARADDR is not 32 byte aligned" severity failure;
                        rdWord := to_integer(unsigned(araddr(i)(32 downto 5)));
                        rdLen  := to_integer(unsigned(arlen(i)));
                        rdBeat := 0;
                        assert ((to_integer(unsigned(araddr(i)(11 downto 0))) + 32*(rdLen+1)) <= 4096)
                           report "HbmDmaBufferV2IpCore: read burst crosses a 4kB boundary" severity failure;
                        rid(i)     <= arid(i) after TPD_C;
                        arready(i) <= '0'     after TPD_C;
                        rdState    := R_DATA_S;
                     end if;
                  when R_DATA_S =>
                     if (rvalid(i) = '0') or (rready(i) = '1') then
                        if (rvalid(i) = '1') and (rlast(i) = '1') then
                           -- The last beat was just accepted
                           rvalid(i) <= '0' after TPD_C;
                           rlast(i)  <= '0' after TPD_C;
                           rdState   := R_ADDR_S;
                        else
                           rdata(i)  <= hbm.read(rdWord + rdBeat) after TPD_C;
                           rvalid(i) <= '1'                       after TPD_C;
                           if (rdBeat = rdLen) then
                              rlast(i) <= '1' after TPD_C;
                           else
                              rlast(i) <= '0' after TPD_C;
                           end if;
                           rdBeat := rdBeat + 1;
                        end if;
                     end if;
               end case;

            end if;
         end if;
      end process;

   end generate GEN_PORT;

   -- APB initialization complete a few cycles after the APB reset releases
   process (APB_0_PCLK) is
      variable cnt : natural range 0 to 15 := 0;
   begin
      if rising_edge(APB_0_PCLK) then
         if (APB_0_PRESET_N = '0') then
            cnt        := 0;
            apbDone(0) <= '0' after TPD_C;
         elsif (cnt = 15) then
            apbDone(0) <= '1' after TPD_C;
         else
            cnt := cnt + 1;
         end if;
      end if;
   end process;

   process (APB_1_PCLK) is
      variable cnt : natural range 0 to 15 := 0;
   begin
      if rising_edge(APB_1_PCLK) then
         if (APB_1_PRESET_N = '0') then
            cnt        := 0;
            apbDone(1) <= '0' after TPD_C;
         elsif (cnt = 15) then
            apbDone(1) <= '1' after TPD_C;
         else
            cnt := cnt + 1;
         end if;
      end if;
   end process;

   apb_complete_0      <= apbDone(0);
   apb_complete_1      <= apbDone(1);
   DRAM_0_STAT_CATTRIP <= '0';
   DRAM_1_STAT_CATTRIP <= '0';
   DRAM_0_STAT_TEMP    <= "0101000";    -- 40 degC
   DRAM_1_STAT_TEMP    <= "0101000";    -- 40 degC

end architecture sim;
