-------------------------------------------------------------------------------
-- File       : XilinxVcu1525Base.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-01-27
-- Last update: 2018-02-01
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-dev'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'axi-pcie-dev', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxVcu1525Base is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      ---------------------
      --  Application Ports
      ---------------------
      -- MIG[0] DDR Ports
      mig0DdrClkP  : in    sl;
      mig0DdrClkN  : in    sl;
      mig0DdrOut   : out   DdrOutType;
      mig0DdrInOut : inout DdrInOutType;
      -- MIG[2] DDR Ports
      mig2DdrClkP  : in    sl;
      mig2DdrClkN  : in    sl;
      mig2DdrOut   : out   DdrOutType;
      mig2DdrInOut : inout DdrInOutType;
      -- MIG[3] DDR Ports
      mig3DdrClkP  : in    sl;
      mig3DdrClkN  : in    sl;
      mig3DdrOut   : out   DdrOutType;
      mig3DdrInOut : inout DdrInOutType;
      -- QSFP[0] Ports
      qsfp0RefClkP : in    slv(1 downto 0);
      qsfp0RefClkN : in    slv(1 downto 0);
      qsfp0RxP     : in    slv(3 downto 0);
      qsfp0RxN     : in    slv(3 downto 0);
      qsfp0TxP     : out   slv(3 downto 0);
      qsfp0TxN     : out   slv(3 downto 0);
      -- QSFP[1] Ports
      qsfp1RefClkP : in    slv(1 downto 0);
      qsfp1RefClkN : in    slv(1 downto 0);
      qsfp1RxP     : in    slv(3 downto 0);
      qsfp1RxN     : in    slv(3 downto 0);
      qsfp1TxP     : out   slv(3 downto 0);
      qsfp1TxN     : out   slv(3 downto 0);
      --------------
      --  Core Ports
      --------------
      -- System Ports
      userClkP     : in    sl;
      userClkN     : in    sl;
      -- MIG[1] DDR Ports
      mig1DdrClkP  : in    sl;
      mig1DdrClkN  : in    sl;
      mig1DdrOut   : out   DdrOutType;
      mig1DdrInOut : inout DdrInOutType;
      -- QSFP[0] Ports
      qsfp0RstL    : out   sl;
      qsfp0LpMode  : out   sl;
      qsfp0ModSelL : out   sl;
      qsfp0ModPrsL : in    sl;
      -- QSFP[1] Ports
      qsfp1RstL    : out   sl;
      qsfp1LpMode  : out   sl;
      qsfp1ModSelL : out   sl;
      qsfp1ModPrsL : in    sl;
      -- PCIe Ports
      pciRstL      : in    sl;
      pciRefClkP   : in    sl;
      pciRefClkN   : in    sl;
      pciRxP       : in    slv(15 downto 0);
      pciRxN       : in    slv(15 downto 0);
      pciTxP       : out   slv(15 downto 0);
      pciTxN       : out   slv(15 downto 0));
end XilinxVcu1525Base;

architecture top_level of XilinxVcu1525Base is

   -- Declare the Reconfigurable RTL as a black box
   -- and don't include its RTL file (.vhd or .v) 
   -- during the initial synthesis process 
   component Application
      port (
         ------------------------      
         --  Top Level Interfaces
         ------------------------    
         -- AXI-Lite Interface (dmaClk domain)
         axilClk         : in    sl;
         axilRst         : in    sl;
         axilReadMaster  : in    AxiLiteReadMasterType;
         axilReadSlave   : out   AxiLiteReadSlaveType;
         axilWriteMaster : in    AxiLiteWriteMasterType;
         axilWriteSlave  : out   AxiLiteWriteSlaveType;
         -- DMA Interface (dmaClk domain)
         dmaClk          : in    sl;
         dmaRst          : in    sl;
         dmaObMasters    : in    AxiStreamMasterArray(7 downto 0);
         dmaObSlaves     : out   AxiStreamSlaveArray(7 downto 0);
         dmaIbMasters    : out   AxiStreamMasterArray(7 downto 0);
         dmaIbSlaves     : in    AxiStreamSlaveArray(7 downto 0);
         -- MIG[1] DDR AXI Interface (mig1Clk domain)
         mig1Clk         : in    sl;
         mig1Rst         : in    sl;
         mig1Ready       : in    sl;
         mig1WriteMaster : out   AxiWriteMasterType;
         mig1WriteSlave  : in    AxiWriteSlaveType;
         mig1ReadMaster  : out   AxiReadMasterType;
         mig1ReadSlave   : in    AxiReadSlaveType;
         ---------------------
         --  Application Ports
         ---------------------    
         -- MIG[0] DDR Ports
         mig0DdrClkP     : in    sl;
         mig0DdrClkN     : in    sl;
         mig0DdrOut      : out   DdrOutType;
         mig0DdrInOut    : inout DdrInOutType;
         -- MIG[2] DDR Ports
         mig2DdrClkP     : in    sl;
         mig2DdrClkN     : in    sl;
         mig2DdrOut      : out   DdrOutType;
         mig2DdrInOut    : inout DdrInOutType;
         -- MIG[3] DDR Ports
         mig3DdrClkP     : in    sl;
         mig3DdrClkN     : in    sl;
         mig3DdrOut      : out   DdrOutType;
         mig3DdrInOut    : inout DdrInOutType;
         -- QSFP[0] Ports
         qsfp0RefClkP    : in    slv(1 downto 0);
         qsfp0RefClkN    : in    slv(1 downto 0);
         qsfp0RxP        : in    slv(3 downto 0);
         qsfp0RxN        : in    slv(3 downto 0);
         qsfp0TxP        : out   slv(3 downto 0);
         qsfp0TxN        : out   slv(3 downto 0);
         -- QSFP[1] Ports
         qsfp1RefClkP    : in    slv(1 downto 0);
         qsfp1RefClkN    : in    slv(1 downto 0);
         qsfp1RxP        : in    slv(3 downto 0);
         qsfp1RxN        : in    slv(3 downto 0);
         qsfp1TxP        : out   slv(3 downto 0);
         qsfp1TxN        : out   slv(3 downto 0));
   end component;
   attribute BLACK_BOX                : string;
   attribute BLACK_BOX of Application : component is "TRUE";

   signal sysClk     : sl;
   signal sysRst     : sl;
   signal userClk156 : sl;

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal dmaObMasters : AxiStreamMasterArray(7 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(7 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(7 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(7 downto 0);

   signal mig1Clk         : sl;
   signal mig1Rst         : sl;
   signal mig1Ready       : sl;
   signal mig1WriteMaster : AxiWriteMasterType;
   signal mig1WriteSlave  : AxiWriteSlaveType;
   signal mig1ReadMaster  : AxiReadMasterType;
   signal mig1ReadSlave   : AxiReadSlaveType;

begin

   axilClk <= userClk156;

   U_axilRst : entity work.RstSync
      generic map (
         TPD_G => TPD_G)
      port map (
         clk      => axilClk,
         asyncRst => sysRst,
         syncRst  => axilRst);

   U_Core : entity work.XilinxVcu1525Core
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G)
      port map (
         ------------------------      
         --  Top Level Interfaces
         ------------------------        
         -- System Clock and Reset
         sysClk          => sysClk,
         sysRst          => sysRst,
         userClk156      => userClk156,
         -- DMA Interfaces (sysClk domain)
         dmaObMasters    => dmaObMasters,
         dmaObSlaves     => dmaObSlaves,
         dmaIbMasters    => dmaIbMasters,
         dmaIbSlaves     => dmaIbSlaves,
         -- AXI-Lite Interface (appClk domain)
         appClk          => axilClk,
         appRst          => axilRst,
         appReadMaster   => axilReadMaster,
         appReadSlave    => axilReadSlave,
         appWriteMaster  => axilWriteMaster,
         appWriteSlave   => axilWriteSlave,
         -- MIG[1] DDR AXI Interface (mig1Clk domain)
         mig1Clk         => mig1Clk,
         mig1Rst         => mig1Rst,
         mig1Ready       => mig1Ready,
         mig1WriteMaster => mig1WriteMaster,
         mig1WriteSlave  => mig1WriteSlave,
         mig1ReadMaster  => mig1ReadMaster,
         mig1ReadSlave   => mig1ReadSlave,
         --------------
         --  Core Ports
         --------------   
         -- System Ports
         userClkP        => userClkP,
         userClkN        => userClkN,
         -- MIG[1] DDR Ports
         mig1DdrClkP     => mig1DdrClkP,
         mig1DdrClkN     => mig1DdrClkN,
         mig1DdrOut      => mig1DdrOut,
         mig1DdrInOut    => mig1DdrInOut,
         -- QSFP[0] Ports
         qsfp0RstL       => qsfp0RstL,
         qsfp0LpMode     => qsfp0LpMode,
         qsfp0ModSelL    => qsfp0ModSelL,
         qsfp0ModPrsL    => qsfp0ModPrsL,
         -- QSFP[1] Ports
         qsfp1RstL       => qsfp1RstL,
         qsfp1LpMode     => qsfp1LpMode,
         qsfp1ModSelL    => qsfp1ModSelL,
         qsfp1ModPrsL    => qsfp1ModPrsL,
         -- PCIe Ports 
         pciRstL         => pciRstL,
         pciRefClkP      => pciRefClkP,
         pciRefClkN      => pciRefClkN,
         pciRxP          => pciRxP,
         pciRxN          => pciRxN,
         pciTxP          => pciTxP,
         pciTxN          => pciTxN);

   U_App : Application
      port map (
         ------------------------      
         --  Top Level Interfaces
         ------------------------         
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- DMA Interface (dmaClk domain)
         dmaClk          => sysClk,
         dmaRst          => sysRst,
         dmaObMasters    => dmaObMasters,
         dmaObSlaves     => dmaObSlaves,
         dmaIbMasters    => dmaIbMasters,
         dmaIbSlaves     => dmaIbSlaves,
         -- MIG[1] DDR AXI Interface (mig1Clk domain)
         mig1Clk         => mig1Clk,
         mig1Rst         => mig1Rst,
         mig1Ready       => mig1Ready,
         mig1WriteMaster => mig1WriteMaster,
         mig1WriteSlave  => mig1WriteSlave,
         mig1ReadMaster  => mig1ReadMaster,
         mig1ReadSlave   => mig1ReadSlave,
         ---------------------
         --  Application Ports
         ---------------------                  
         -- MIG[0] DDR Ports
         mig0DdrClkP     => mig0DdrClkP,
         mig0DdrClkN     => mig0DdrClkN,
         mig0DdrOut      => mig0DdrOut,
         mig0DdrInOut    => mig0DdrInOut,
         -- MIG[2] DDR Ports
         mig2DdrClkP     => mig2DdrClkP,
         mig2DdrClkN     => mig2DdrClkN,
         mig2DdrOut      => mig2DdrOut,
         mig2DdrInOut    => mig2DdrInOut,
         -- MIG[3] DDR Ports
         mig3DdrClkP     => mig3DdrClkP,
         mig3DdrClkN     => mig3DdrClkN,
         mig3DdrOut      => mig3DdrOut,
         mig3DdrInOut    => mig3DdrInOut,
         -- QSFP[0] Ports
         qsfp0RefClkP    => qsfp0RefClkP,
         qsfp0RefClkN    => qsfp0RefClkN,
         qsfp0RxP        => qsfp0RxP,
         qsfp0RxN        => qsfp0RxN,
         qsfp0TxP        => qsfp0TxP,
         qsfp0TxN        => qsfp0TxN,
         -- QSFP[1] Ports
         qsfp1RefClkP    => qsfp1RefClkP,
         qsfp1RefClkN    => qsfp1RefClkN,
         qsfp1RxP        => qsfp1RxP,
         qsfp1RxN        => qsfp1RxN,
         qsfp1TxP        => qsfp1TxP,
         qsfp1TxN        => qsfp1TxN);

end top_level;
