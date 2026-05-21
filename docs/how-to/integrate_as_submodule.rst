Integrate axi-pcie-core as a Git Submodule
===========================================

This page covers the bare integration recipe: adding ``axi-pcie-core`` to a
downstream firmware project as a git submodule and wiring it into the ruckus
build system.  For an end-to-end build walkthrough that shows the result in
action, see :doc:`/tutorial/first_build`.

Add the Submodule
-----------------

Add ``axi-pcie-core`` at the conventional path used by SLAC firmware projects:

.. code-block:: bash

   git submodule add https://github.com/slaclab/axi-pcie-core firmware/submodules/axi-pcie-core
   git submodule update --init --recursive

The ``git submodule update --init --recursive`` step also initialises the
transitive submodules that ``axi-pcie-core`` depends on (``surf``,
``ruckus``).

Wire it into ruckus.tcl
-----------------------

In your project's board-level ``ruckus.tcl``, source the ruckus environment
then load ``axi-pcie-core`` for the target board.  The snippet below follows
the pattern used by existing board targets (see
:repo:`hardware/XilinxKcu1500/ruckus.tcl` for a worked example):

.. code-block:: tcl

   # Load RUCKUS environment and library
   source $::env(RUCKUS_PROC_TCL)

   # Load axi-pcie-core shared RTL, protocol, and board support
   loadRuckusTcl "$::DIR_PATH/../submodules/axi-pcie-core/hardware/<BoardName>"

   # Load your project's top-level RTL into the axi_pcie_core library
   loadSource -lib axi_pcie_core -dir "$::DIR_PATH/rtl"

Replace ``<BoardName>`` with the directory name matching your PCIe carrier
(for example ``XilinxKcu1500``, ``XilinxVariumC1100``, ``XilinxAlveoU200``).
The full list of supported board directory names is in
:doc:`/reference/supported_boards`.

The ``loadRuckusTcl`` call chains into
``hardware/<BoardName>/ruckus.tcl``, which in turn sources
``shared/ruckus.tcl`` (:repo:`shared/ruckus.tcl`).  That shared script loads
all board-agnostic RTL (``AxiPcieDma``, ``AxiPcieReg``, ``AxiPcieCrossbar``,
and related modules) into the ``axi_pcie_core`` VHDL library.  Your
project's ``loadSource -lib axi_pcie_core`` line then adds your board-level
wrapper on top.

Submodule Version Locks
-----------------------

:repo:`shared/ruckus.tcl` calls ``SubmoduleCheck`` to enforce minimum versions
of the other SLAC firmware submodules:

- ``surf >= 2.71.0``
- ``ruckus >= 4.24.2``

If your project's pinned submodule revisions do not satisfy these constraints,
the build will exit with an error from ``SubmoduleCheck``.  To bypass the
check during development, set the environment variable
``OVERRIDE_SUBMODULE_LOCKS=1`` before invoking ``make``.  This override is
not recommended for production builds.

See Also
--------

- :doc:`/tutorial/first_build` — end-to-end build walkthrough on
  ``XilinxVariumC1100`` using ``pgp-pcie-apps`` as the downstream consumer
- :doc:`/explanation/board_support` — explanation of the per-board directory
  layout (``hardware/<Board>/ruckus.tcl`` chain, PCIe variant subdirectories,
  DDR/HBM optional modules) and the ruckus integration pattern
