Add a New Board
===============

This guide walks through every step needed to port ``axi-pcie-core`` to a new
PCIe carrier board.  It is a procedural checklist; for a conceptual overview of
the board-support directory structure and the ruckus build chain, see
:doc:`/explanation/board_support`.  For the complete list of boards already
supported, see :doc:`/reference/supported_boards`.

Each step includes a copy-pasteable skeleton snippet derived from the canonical
reference board ``XilinxKcu1500`` (PCIe Gen3x8, DDR4,
:repo:`hardware/XilinxKcu1500/`).

Step 1: Create the directory layout
------------------------------------

Under ``hardware/``, create a subtree named after your board using the standard
layout:

.. code-block:: text

    hardware/<NewBoard>/
        ruckus.tcl                         # board entry-point (Step 7)
        rtl/
            <NewBoard>Core.vhd             # top-level integration entity (Step 2)
            AxiPciePkg.vhd                 # board-specific constants (Step 3)
        pcie/                              # PCIe PHY IP wrapper + .dcp (Step 4)
            ip/
                <NewBoard>PciePhy.xci      # Vivado IP source (regen if needed)
                <NewBoard>PciePhy.dcp      # pre-compiled checkpoint (preferred)
                <NewBoard>PciePhy.xdc      # IP-scoped timing constraints
            rtl/
                <NewBoard>PciePhyWrapper.vhd
            ruckus.tcl
        ddr/                               # optional, for boards with DDR4 (Step 8)
        hbm/                               # optional, for boards with HBM (Step 8)
        xdc/
            <NewBoard>Core.xdc             # pin-location + board-level timing (Step 5)
            <NewBoard>App.xdc              # optional application-area constraints

Boards without on-board memory omit the ``ddr/`` or ``hbm/`` subtree.  Some
boards with multiple PCIe lane configurations split the PCIe subtree into
``pcie-<variant>/`` directories (e.g., ``pcie-3x16/``, ``pcie-4x8/``).

Reference: :repo:`hardware/XilinxKcu1500/` shows the full directory tree for a
board with PCIe, DDR4, and a PCIe-extended optional variant.

Step 2: Write ``<NewBoard>Core.vhd``
--------------------------------------

``<NewBoard>Core.vhd`` is the single instantiation point that downstream
projects use.  It wires the PCIe PHY IP, the shared ``AxiPcieReg`` and
``AxiPcieDma`` modules, and all board I/O together.  Every ``*Core`` entity
shares the same DMA and register port list; only board-specific I/O ports differ.

See :repo:`hardware/XilinxKcu1500/rtl/XilinxKcu1500Core.vhd` for the full
reference implementation.  The skeleton below shows the mandatory library
imports, generic list, and port-group structure (replace ``NewBoardCore``
with your actual entity name):

.. code-block:: text

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_unsigned.all;

    library surf;
    use surf.StdRtlPkg.all;
    use surf.AxiLitePkg.all;
    use surf.AxiStreamPkg.all;
    use surf.AxiPkg.all;

    library axi_pcie_core;
    use axi_pcie_core.AxiPciePkg.all;
    use axi_pcie_core.AxiPcieSharedPkg.all;

    entity NewBoardCore is
       generic (
          TPD_G                : time                        := 1 ns;
          ROGUE_SIM_EN_G       : boolean                     := false;
          ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 8000;
          ROGUE_SIM_CH_COUNT_G : natural range 1 to 256      := 256;
          BUILD_INFO_G         : BuildInfoType;
          DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
          DRIVER_TYPE_ID_G     : slv(31 downto 0)            := x"00000000";
          DMA_BURST_BYTES_G    : positive range 256 to 4096  := 256;
          DMA_SIZE_G           : positive range 1 to 8       := 1);
       port (
          -------------------------
          --  Top-Level Interfaces
          -------------------------
          -- DMA Interfaces  (dmaClk domain)
          dmaClk          : out   sl;
          dmaRst          : out   sl;
          dmaBuffGrpPause : out   slv(7 downto 0);
          dmaObMasters    : out   AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
          dmaObSlaves     : in    AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
          dmaIbMasters    : in    AxiStreamMasterArray(DMA_SIZE_G-1 downto 0);
          dmaIbSlaves     : out   AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0);
          -- Application AXI-Lite Interfaces (appClk domain)
          appClk          : in    sl                    := '0';
          appRst          : in    sl                    := '1';
          appReadMaster   : out   AxiLiteReadMasterType;
          appReadSlave    : in    AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
          appWriteMaster  : out   AxiLiteWriteMasterType;
          appWriteSlave   : in    AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
          -------------------------
          --  Top-Level Ports
          -------------------------
          -- PCIe Ports
          pciRstL         : in    sl;
          pciRefClkP      : in    sl;
          pciRefClkN      : in    sl;
          pciRxP          : in    slv(7 downto 0);  -- adjust lane count
          pciRxN          : in    slv(7 downto 0);
          pciTxP          : out   slv(7 downto 0);
          pciTxN          : out   slv(7 downto 0));
    end NewBoardCore;

    architecture mapping of NewBoardCore is

       signal sysClock    : sl;
       signal sysReset    : sl;
       signal systemReset : sl;
       -- AXI4 buses between PHY and REG/DMA
       signal dmaReadMaster  : AxiReadMasterType;
       signal dmaReadSlave   : AxiReadSlaveType;
       signal dmaWriteMaster : AxiWriteMasterType;
       signal dmaWriteSlave  : AxiWriteSlaveType;
       signal regReadMaster  : AxiReadMasterType;
       signal regReadSlave   : AxiReadSlaveType;
       signal regWriteMaster : AxiWriteMasterType;
       signal regWriteSlave  : AxiWriteSlaveType;
       signal dmaIrq         : sl;

    begin

       dmaClk <= sysClock;
       -- PHY, REG, DMA instantiations follow ...

    end mapping;

The ``architecture mapping of`` convention applies to all ``*Core`` entities;
they are pure structural modules that only instantiate sub-components and connect
signals.  The internal signals ``sysClock`` and ``sysReset`` carry the 250 MHz
PCIe PHY recovered clock and its synchronous active-high reset.

Step 3: Define ``AxiPciePkg.vhd`` constants
--------------------------------------------

Every board must supply its own ``AxiPciePkg.vhd`` in
``hardware/<NewBoard>/rtl/``.  Two constants are mandatory:

.. code-block:: vhdl

    library ieee;
    use ieee.std_logic_1164.all;

    library surf;
    use surf.StdRtlPkg.all;
    use surf.AxiLitePkg.all;
    use surf.AxiStreamPkg.all;
    use surf.AxiPkg.all;

    package AxiPciePkg is

       -- System Clock Frequency
       constant DMA_CLK_FREQ_C : real := 250.0E+6;  -- units of Hz

       -- PCIe PHY AXI Configuration
       constant AXI_PCIE_CONFIG_C : AxiConfigType := (
          ADDR_WIDTH_C => 64,              -- 64-bit address interface
          DATA_BYTES_C => 32,              -- 256-bit data bus (PCIe Gen3x8/Gen4x8)
          ID_BITS_C    => 4,               -- up to 16 DMA IDs
          LEN_BITS_C   => 8);              -- 8-bit AWLEN/ARLEN interface

    end package AxiPciePkg;

``DATA_BYTES_C`` encodes the PCIe data-bus width in bytes: 16 for 128-bit
(Gen3x4), 32 for 256-bit (Gen3x8 or Gen4x8), 64 for 512-bit (Gen3x16 or
Gen4x16).  All other fields are fixed across all supported boards.

Reference: :repo:`hardware/XilinxKcu1500/rtl/AxiPciePkg.vhd`.

Step 4: Provision the PCIe IP ``.xci``
---------------------------------------

Generate the PCIe endpoint IP from the Vivado IP catalog:

* For **PCIe Gen3** targets (``xilinx.com:ip:axi_pcie3:3.0``): run the IP
  customisation wizard, configure lane count, reference-clock frequency, and
  AXI data width, then export the ``.xci``.
* For **PCIe Gen4 / XDMA** targets (``xilinx.com:ip:xdma:4.1``): same
  procedure using the XDMA catalog entry.

Once the IP is customised, the preferred delivery method is to **pre-compile it
to a ``.dcp`` checkpoint** (see :doc:`/explanation/architecture` for rationale).
Commit the ``.dcp`` and ``.xci`` together in
``hardware/<NewBoard>/pcie/ip/``.

The thin VHDL wrapper
``hardware/<NewBoard>/pcie/rtl/<NewBoard>PciePhyWrapper.vhd`` presents a
uniform AXI4 interface (``dmaReadMaster``, ``dmaWriteMaster``,
``regReadMaster``, ``regWriteMaster``, ``phyReadMaster``) to
``<NewBoard>Core``.

Reference: :repo:`hardware/XilinxKcu1500/pcie/ip/XilinxKcu1500PciePhy.xci`.

Step 5: Add ``.xdc`` constraints
----------------------------------

Two constraint files are typically needed:

1. **``xdc/<NewBoard>Core.xdc``** — pin-location assignments for PCIe lanes,
   reference-clock differential pairs, and board-specific I/O (I2C, QSFP
   control, flash chip-select).  Also include ``set_false_path`` or
   ``set_max_delay -datapath_only`` entries for user-defined
   clock-domain-crossing paths.

2. **``pcie/ip/<NewBoard>PciePhy.xdc``** — IP-scoped timing constraints
   generated by Vivado's PCIe IP customisation wizard.  These are consumed when
   the ``.xci`` is re-synthesised; the ``.dcp`` delivery makes this file
   effectively a reference document.

References:

* :repo:`hardware/XilinxKcu1500/xdc/XilinxKcu1500Core.xdc` — board-level pin
  and timing constraints.
* :repo:`hardware/XilinxKcu1500/pcie/ip/XilinxKcu1500PciePhy.xdc` — IP-scoped
  timing constraints.

Step 6: Register a ``HW_TYPE_*`` constant
------------------------------------------

Add a new board-identity constant to
:repo:`shared/rtl/AxiPcieSharedPkg.vhd`.  Every supported board has a unique
32-bit ``slv`` literal in the format ``x"00_00_00_XX"``:

.. code-block:: vhdl

    -- existing entries (excerpt from AxiPcieSharedPkg.vhd)
    constant HW_TYPE_XILINX_KCU1500_C      : slv(31 downto 0) := x"00_00_00_0D";
    constant HW_TYPE_XILINX_U55C_C         : slv(31 downto 0) := x"00_00_00_0F";
    constant HW_TYPE_XILINX_C1100_C        : slv(31 downto 0) := x"00_00_00_10";
    constant HW_TYPE_BITTWARE_XUP_VV8_VU9P_C : slv(31 downto 0) := x"00_00_00_13";

    -- add your new board at the next available value
    constant HW_TYPE_MY_NEW_BOARD_C        : slv(31 downto 0) := x"00_00_00_14";

Then pass the new constant to ``AxiPcieReg`` as ``PCIE_HW_TYPE_G`` in
``<NewBoard>Core.vhd``:

.. code-block:: vhdl

    U_REG : entity axi_pcie_core.AxiPcieReg
       generic map (
          -- ...
          PCIE_HW_TYPE_G => HW_TYPE_MY_NEW_BOARD_C,
          -- ...
       )
       port map ( ... );

**Important:** ``AxiPcieSharedPkg.vhd`` is shared RTL that every downstream
project and every supported board compiles into the ``axi_pcie_core`` VHDL
library.  Adding a new ``HW_TYPE_*`` constant **modifies this shared file**,
which means all downstream projects that use ``axi-pcie-core`` as a submodule
must merge the change.  Coordinate the merge with downstream project owners
before opening a pull request.

Step 7: Write the board-level ``ruckus.tcl``
---------------------------------------------

The board-level ``ruckus.tcl`` is the entry point that downstream project
``ruckus.tcl`` files source via ``loadRuckusTcl``.  It must:

1. Source the shared ruckus library, which enforces submodule version locks
   (ruckus ≥ 4.24.2, surf ≥ 2.71.0) and loads all of ``shared/rtl/`` and
   ``shared/ip/`` into the ``axi_pcie_core`` VHDL library.
2. Validate the Vivado part number for the target device.
3. Load board-specific RTL sources and constraints.
4. Source the PCIe PHY subtree ruckus.

.. code-block:: tcl

    # Load RUCKUS environment and library
    source $::env(RUCKUS_PROC_TCL)

    # Load shared source code (enforces ruckus >= 4.24.2, surf >= 2.71.0)
    loadRuckusTcl "$::DIR_PATH/../../shared"

    # Set the target language for Verilog (suppresses PCIe IP core warnings)
    set_property target_language Verilog [current_project]

    # Check for valid FPGA part number
    if { $::env(PRJ_PART) != "xc<device>-<speed>-<package>" } {
       puts "\n\nERROR: PRJ_PART was not defined correctly\n\n"; exit -1
    }

    # Load local RTL sources and constraints
    loadSource -lib axi_pcie_core -dir  "$::DIR_PATH/rtl"
    loadConstraints -path "$::DIR_PATH/xdc/<NewBoard>Core.xdc"

    # Load the PCIe PHY subtree
    loadRuckusTcl "$::DIR_PATH/pcie"

    # Optionally load DDR4 or HBM (see Step 8)
    # loadRuckusTcl "$::DIR_PATH/ddr"

Reference: :repo:`hardware/XilinxKcu1500/ruckus.tcl`.

The ``shared/ruckus.tcl`` performs three actions when sourced: it calls
``SubmoduleCheck`` to verify the ruckus and surf submodule version locks; it
asserts Vivado version ≥ 2020.1 (boards using CMS block-design or HBM IP
require 2024.2+); and it loads all of ``shared/rtl/`` and ``shared/ip/`` into
the ``axi_pcie_core`` VHDL library before any board-specific sources.

Step 8: Optional DDR4 or HBM memory buffer
--------------------------------------------

Boards with on-board DDR4 SDRAM or HBM can add a memory-backed DMA buffer
between the application AXIS streams and the DMA engine.

**DDR4 (MIG):** add ``hardware/<NewBoard>/ddr/`` containing the MIG IP
``.xci``/``.dcp`` and the ``MigDmaBuffer.vhd`` wrapper.  Source the DDR
subtree conditionally from ``hardware/<NewBoard>/ruckus.tcl`` when the
downstream project opts in:

.. code-block:: tcl

    loadRuckusTcl "$::DIR_PATH/ddr"

Reference: :repo:`hardware/XilinxKcu1500/ddr/` shows the DDR4 path with MIG
IP, multiple DIMM channels, and the ``MigDmaBuffer`` instantiation.

**HBM:** add ``hardware/<NewBoard>/hbm/`` containing the HBM IP ``.xci`` and
``HbmDmaBuffer.vhd``.  Boards requiring HBM also typically require Vivado
2024.2 due to HBM IP dependencies.

Reference: :repo:`hardware/XilinxVariumC1100/hbm/` shows the HBM path.

In both cases, the downstream project includes the memory subtree by adding
``loadRuckusTcl "$::DIR_PATH/<board>/ddr"`` (or ``hbm``) to its own
``ruckus.tcl``; the buffer module is wired to the application AXIS interfaces
in the top-level wrapper, not inside ``<NewBoard>Core`` itself.

See Also
--------

* :doc:`/reference/rtl_entities` — full port and generic list for shared RTL
  entities (``AxiPcieDma``, ``AxiPcieReg``, ``AxiPcieCrossbar``).
* :doc:`/reference/supported_boards` — table of all 14 supported boards with
  PCIe generation, memory type, and entity paths.
* :doc:`/explanation/board_support` — conceptual overview of the
  ``hardware/<board>/`` directory layout and the ruckus.tcl chain.
* :doc:`/explanation/architecture` — description of the PCIe PHY, REG, and DMA
  subsystem relationships and ``AxiPciePkg`` constants.
