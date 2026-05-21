Board Support
=============

Directory Convention
--------------------

Every supported board lives under ``hardware/<BoardName>/`` and follows the same internal
layout.  Using ``XilinxKcu1500`` as the worked example, the skeleton looks like this:

.. code-block:: text

    hardware/<BoardName>/
        ruckus.tcl              # board entry-point
        rtl/
            <BoardName>Core.vhd # top-level integration
            AxiPciePkg.vhd      # board-specific constants
        pcie/                   # PCIe PHY IP wrapper + .dcp
        ddr/  or  hbm/          # optional MIG / HBM buffer
        xdc/                    # board pin/timing constraints

The ``pcie/`` subtree holds the pre-compiled Vivado ``.dcp`` checkpoint and the thin VHDL
wrapper that presents a uniform AXI4 interface to the rest of the design.  The ``ddr/`` or
``hbm/`` subtrees are optional; boards without on-board memory omit them.

Shared vs. Board-Specific Layering
-----------------------------------

``shared/rtl/`` holds board-agnostic logic compiled into the ``axi_pcie_core`` VHDL library.
This includes ``AxiPcieDma``, ``AxiPcieReg``, ``AxiPcieCrossbar``, ``AxiPcieRegWriteDeMux``,
and ``AxiPcieSharedPkg`` (which defines the ``HW_TYPE_*`` board identifiers).  Every
``<Board>Core`` entity instantiates these same shared modules, so a bug fix or enhancement
in shared logic benefits all fourteen supported boards simultaneously.

``hardware/<board>/`` holds the board-specific RTL: ``<Board>Core.vhd`` (the top-level
integration entity that downstream projects instantiate), ``AxiPciePkg.vhd`` (per-board
constants including ``DMA_CLK_FREQ_C`` set to 250 MHz and ``AXI_PCIE_CONFIG_C`` encoding
data width, address width, and ID bits), the PCIe PHY IP ``.dcp``, and board-specific
``.xdc`` constraint files.  ``AxiPciePkg`` is the abstraction point: the shared RTL
references only the constants it defines, keeping ``shared/rtl/`` free of board-specific
magic numbers.

The ruckus.tcl Entry-Point Chain
----------------------------------

The build system chains from the downstream project inward through four levels:

1. The downstream project's top-level ``ruckus.tcl`` sources
   ``hardware/<BoardName>/ruckus.tcl`` via ``loadRuckusTcl``.
2. The board ``ruckus.tcl`` sources ``shared/ruckus.tcl`` as its first action.
3. ``shared/ruckus.tcl`` calls ``SubmoduleCheck`` to enforce ruckus ≥ v4.24.2 and
   surf ≥ v2.71.0, verifies Vivado version ≥ 2020.1, then loads all of ``shared/rtl/``
   and ``shared/ip/`` into the ``axi_pcie_core`` VHDL library.
4. The board ``ruckus.tcl`` loads its own ``rtl/`` sources, the PCIe PHY ``.dcp``,
   the ``.xdc`` constraints, and — conditionally — the ``ddr/`` or ``hbm/`` subtree
   depending on the board's optional memory configuration.

Some boards impose additional constraints.  ``XilinxAlveoU55c``, for example, requires
Vivado 2024.2 and sources a block-design subtree (``bd/``) before loading the shared
library.  These variations are handled inside each board's own ``ruckus.tcl``; the
downstream project's entry point remains unchanged.

Adding a New Board (overview)
------------------------------

Full step-by-step instructions will appear in ``how-to/add_new_board.rst``.  At a high
level, adding a board requires four touchpoints: create ``hardware/<BoardName>/`` with
the standard subtree layout described above; write ``<BoardName>Core.vhd`` wiring the
PCIe PHY, shared REG/DMA modules, and board I/O; supply ``AxiPciePkg.vhd`` with the
board's ``DMA_CLK_FREQ_C`` and ``AXI_PCIE_CONFIG_C`` constants; and register a new
``HW_TYPE_*`` identifier in ``shared/rtl/AxiPcieSharedPkg.vhd`` so the firmware can
report its board type at runtime.
