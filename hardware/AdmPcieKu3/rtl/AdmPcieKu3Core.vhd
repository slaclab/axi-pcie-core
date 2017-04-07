-------------------------------------------------------------------------------
-- File       : AdmPcieKu3Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-06
-- Last update: 2017-04-06
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for ADM-PCIE-KU3 board 
-- http://www.alpha-data.com/dcp/products.php?product=adm-pcie-ku3
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
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AdmPcieKu3Core is
   generic (
      TPD_G            : time                     := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      DRIVER_TYPE_ID_G : slv(31 downto 0)         := x"00000000";
      AXI_APP_BUS_EN_G : boolean                  := false;
      DMA_SIZE_G       : positive range 1 to 16   := 1);
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------    
      -- System Clock and Reset
      sysClk         : out   sl;        -- 250 MHz
      sysRst         : out   sl;
      -- DMA Interfaces  (sysClk domain)
      dmaObMasters   : out   AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaObSlaves    : in    AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      dmaIbMasters   : in    AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
      dmaIbSlaves    : out   AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
      -- (Optional) Application AXI-Lite Interface [0x00080000:0x000FFFFF] (sysClk domain)
      appReadMaster  : out   AxiLiteReadMasterType;
      appReadSlave   : in    AxiLiteReadSlaveType            := AXI_LITE_READ_SLAVE_INIT_C;
      appWriteMaster : out   AxiLiteWriteMasterType;
      appWriteSlave  : in    AxiLiteWriteSlaveType           := AXI_LITE_WRITE_SLAVE_INIT_C;
      -- (Optional) Application AXI Interface [0x000000000:0x1FFFFFFFF] (axiClk domain)
      memClk         : out   slv(1 downto 0);
      memRst         : out   slv(1 downto 0);
      memWriteMaster : in    AxiWriteMasterArray(1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
      memWriteSlave  : out   AxiWriteSlaveArray(1 downto 0);
      memReadMaster  : in    AxiReadMasterArray(1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);
      memReadSlave   : out   AxiReadSlaveArray(1 downto 0);
      -------------------
      --  Top Level Ports
      -------------------      
      -- DDR3 SO-DIMM Ports
      ddrClkP        : in    slv(1 downto 0);
      ddrClkN        : in    slv(1 downto 0);
      ddrDqsP        : inout Slv9Array(1 downto 0);
      ddrDqsN        : inout Slv9Array(1 downto 0);
      ddrDq          : inout Slv72Array(1 downto 0);
      ddrA           : out   Slv16Array(1 downto 0);
      ddrBa          : out   Slv3Array(1 downto 0);
      ddrCsL         : out   Slv2Array(1 downto 0);
      ddrOdt         : out   Slv2Array(1 downto 0);
      ddrCke         : out   Slv2Array(1 downto 0);
      ddrCkP         : out   Slv2Array(1 downto 0);
      ddrCkN         : out   Slv2Array(1 downto 0);
      ddrWeL         : out   slv(1 downto 0);
      ddrRasL        : out   slv(1 downto 0);
      ddrCasL        : out   slv(1 downto 0);
      ddrRstL        : out   slv(1 downto 0);
      -- Boot Memory Ports 
      flashAddr      : out   slv(25 downto 0);
      flashData      : inout slv(15 downto 4);
      flashAdv       : out   sl;
      flashOeL       : out   sl;
      flashWeL       : out   sl;
      -- PCIe Ports 
      pciRstL        : in    sl;
      pciRefClkP     : in    sl;
      pciRefClkN     : in    sl;
      pciRxP         : in    slv(7 downto 0);
      pciRxN         : in    slv(7 downto 0);
      pciTxP         : out   slv(7 downto 0);
      pciTxN         : out   slv(7 downto 0));
end AdmPcieKu3Core;

architecture mapping of AdmPcieKu3Core is

   constant AXI_ERROR_RESP_C : slv(1 downto 0) := AXI_RESP_OK_C;  -- Always return OK to a MMAP()

   signal dmaReadMaster  : AxiReadMasterType;
   signal dmaReadSlave   : AxiReadSlaveType;
   signal dmaWriteMaster : AxiWriteMasterType;
   signal dmaWriteSlave  : AxiWriteSlaveType;

   signal regReadMaster  : AxiReadMasterType;
   signal regReadSlave   : AxiReadSlaveType;
   signal regWriteMaster : AxiWriteMasterType;
   signal regWriteSlave  : AxiWriteSlaveType;

   signal dmaCtrlReadMaster  : AxiLiteReadMasterType;
   signal dmaCtrlReadSlave   : AxiLiteReadSlaveType;
   signal dmaCtrlWriteMaster : AxiLiteWriteMasterType;
   signal dmaCtrlWriteSlave  : AxiLiteWriteSlaveType;

   signal phyReadMaster  : AxiLiteReadMasterType;
   signal phyReadSlave   : AxiLiteReadSlaveType;
   signal phyWriteMaster : AxiLiteWriteMasterType;
   signal phyWriteSlave  : AxiLiteWriteSlaveType;

   signal flashAddress : slv(28 downto 0);
   signal flashDin     : slv(15 downto 0);
   signal flashDout    : slv(15 downto 0);
   signal flashTri     : sl;

   signal sysClock : sl;
   signal sysReset : sl;
   signal dmaIrq   : sl;
   signal flashCeL : sl;

begin

   sysClk <= sysClock;
   sysRst <= sysReset;

   ---------------
   -- AXI PCIe PHY
   ---------------   
   U_AxiPciePhy : entity work.AdmPcieKu3PciePhyWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI4 Interfaces
         axiClk         => sysClock,
         axiRst         => sysReset,
         dmaReadMaster  => dmaReadMaster,
         dmaReadSlave   => dmaReadSlave,
         dmaWriteMaster => dmaWriteMaster,
         dmaWriteSlave  => dmaWriteSlave,
         regReadMaster  => regReadMaster,
         regReadSlave   => regReadSlave,
         regWriteMaster => regWriteMaster,
         regWriteSlave  => regWriteSlave,
         phyReadMaster  => phyReadMaster,
         phyReadSlave   => phyReadSlave,
         phyWriteMaster => phyWriteMaster,
         phyWriteSlave  => phyWriteSlave,
         -- Interrupt Interface
         dmaIrq         => dmaIrq,
         -- PCIe Ports 
         pciRstL        => pciRstL,
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   ---------------
   -- AXI PCIe REG
   --------------- 
   U_REG : entity work.AxiPcieReg
      generic map (
         TPD_G            => TPD_G,
         BUILD_INFO_G     => BUILD_INFO_G,
         DRIVER_TYPE_ID_G => DRIVER_TYPE_ID_G,
         AXI_APP_BUS_EN_G => AXI_APP_BUS_EN_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_C,
         DMA_SIZE_G       => DMA_SIZE_G)
      port map (
         -- AXI4 Interfaces
         axiClk             => sysClock,
         axiRst             => sysReset,
         regReadMaster      => regReadMaster,
         regReadSlave       => regReadSlave,
         regWriteMaster     => regWriteMaster,
         regWriteSlave      => regWriteSlave,
         -- DMA AXI-Lite Interfaces
         dmaCtrlReadMaster  => dmaCtrlReadMaster,
         dmaCtrlReadSlave   => dmaCtrlReadSlave,
         dmaCtrlWriteMaster => dmaCtrlWriteMaster,
         dmaCtrlWriteSlave  => dmaCtrlWriteSlave,
         -- PHY AXI-Lite Interfaces
         phyReadMaster      => phyReadMaster,
         phyReadSlave       => phyReadSlave,
         phyWriteMaster     => phyWriteMaster,
         phyWriteSlave      => phyWriteSlave,
         -- (Optional) Application AXI-Lite Interfaces
         appReadMaster      => appReadMaster,
         appReadSlave       => appReadSlave,
         appWriteMaster     => appWriteMaster,
         appWriteSlave      => appWriteSlave,
         -- Boot Memory Ports 
         flashAddr          => flashAddress,
         flashAdv           => flashAdv,
         flashCeL           => flashCeL,
         flashOeL           => flashOeL,
         flashWeL           => flashWeL,
         flashDin           => flashDin,
         flashDout          => flashDout,
         flashTri           => flashTri);

   flashAddr <= flashAddress(25 downto 0);

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => flashDout(3 downto 0),  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output         
         DO        => flashDin(3 downto 0),  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => (others => flashTri),  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => flashCeL,  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => '1',              -- 1-bit input: User CCLK input
         USRCCLKTS => '1',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => '1',  -- 1-bit input: User DONE pin output control
         USRDONETS => '1');  -- 1-bit input: User DONE 3-state enable output              

   GEN_IOBUF :
   for i in 15 downto 4 generate
      IOBUF_inst : IOBUF
         port map (
            O  => flashDout(i),         -- Buffer output
            IO => flashData(i),  -- Buffer inout port (connect directly to top-level port)
            I  => flashDin(i),          -- Buffer input
            T  => flashTri);  -- 3-state enable input, high=input, low=output     
   end generate GEN_IOBUF;

   ---------------
   -- AXI PCIe DMA
   ---------------   
   U_AxiPcieDma : entity work.AxiPcieDma
      generic map (
         TPD_G            => TPD_G,
         DMA_SIZE_G       => DMA_SIZE_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_C)
      port map (
         -- Clock and reset
         axiClk          => sysClock,
         axiRst          => sysReset,
         -- AXI4 Interfaces
         axiReadMaster   => dmaReadMaster,
         axiReadSlave    => dmaReadSlave,
         axiWriteMaster  => dmaWriteMaster,
         axiWriteSlave   => dmaWriteSlave,
         -- AXI4-Lite Interfaces
         axilReadMaster  => dmaCtrlReadMaster,
         axilReadSlave   => dmaCtrlReadSlave,
         axilWriteMaster => dmaCtrlWriteMaster,
         axilWriteSlave  => dmaCtrlWriteSlave,
         -- Interrupts
         dmaIrq          => dmaIrq,
         -- DMA Interfaces
         dmaObMasters    => dmaObMasters,
         dmaObSlaves     => dmaObSlaves,
         dmaIbMasters    => dmaIbMasters,
         dmaIbSlaves     => dmaIbSlaves);

   ---------------
   -- AXI DDR MIG
   ---------------   
   GEN_VEC :
   for i in 1 downto 0 generate
      U_DDR : entity work.AdmPcieKu3MigPhyWrapper
         generic map (
            TPD_G           => TPD_G)
         port map (
            -- System Clock and reset
            sysClk         => sysClock,
            sysRst         => sysReset,
            -- AXI MEM Interface  (axiClk domain)
            axiClk         => memClk(i),
            axiRst         => memRst(i),
            axiWriteMaster => memWriteMaster(i),
            axiWriteSlave  => memWriteSlave(i),
            axiReadMaster  => memReadMaster(i),
            axiReadSlave   => memReadSlave(i),
            -- DDR3 SO-DIMM Ports
            ddrClkP        => ddrClkP(i),
            ddrClkN        => ddrClkN(i),
            ddrDqsP        => ddrDqsP(i),
            ddrDqsN        => ddrDqsN(i),
            ddrDq          => ddrDq(i),
            ddrA           => ddrA(i),
            ddrBa          => ddrBa(i),
            ddrCsL         => ddrCsL(i),
            ddrOdt         => ddrOdt(i),
            ddrCke         => ddrCke(i),
            ddrCkP         => ddrCkP(i),
            ddrCkN         => ddrCkN(i),
            ddrWeL         => ddrWeL(i),
            ddrRasL        => ddrRasL(i),
            ddrCasL        => ddrCasL(i),
            ddrRstL        => ddrRstL(i));
   end generate GEN_VEC;

end mapping;
