First Build
===========

This tutorial walks you through building a real PCIe bitstream for the
**Xilinx Varium C1100** board using ``axi-pcie-core`` as a submodule of
``slaclab/pgp-pcie-apps``.

.. note::

   **Vivado 2024.2 or later is required for the XilinxVariumC1100 target**
   because the board's CMS block design and HBM2 IP are only available from
   2024.2 onwards.  At SLAC the current production toolchain is **Vivado
   2025.2** (see the SLAC sourcing step below); the build flow in this
   tutorial has been verified end-to-end on 2025.2.  See
   :doc:`/reference/supported_boards` for a full list of per-board Vivado
   version requirements.

The board is a Gen4x8 PCIe card with HBM2 on-board memory.  The end artifact
is a real ``.bit`` bitstream and ``.mcs`` programming file produced by
Vivado.  The tutorial stops at the build step; it does not cover driver
loading or hardware bring-up.

Prerequisites
-------------

You need the following on your workstation before you begin:

- **git** 2.x with **git-lfs** installed and initialized — ``axi-pcie-core``
  uses LFS for pre-compiled IP checkpoints (``.dcp``), so a clone without
  active LFS leaves placeholder files in place of binary IP and the build
  will fail.
- **Vivado 2024.2 or later** with the ``vivado`` executable on your
  ``PATH``.  At SLAC S3DF the standard activation step is::

     source /sdf/group/faders/tools/xilinx/<version>/Vivado/<version>/settings64.sh

  For example for 2025.2::

     source /sdf/group/faders/tools/xilinx/2025.2/Vivado/2025.2/settings64.sh

  Outside SLAC, run your site's equivalent ``settings64.sh``, or invoke
  ``vivado`` from a shell where ``which vivado`` already resolves.

A JTAG cable and Vivado Hardware Manager are *not* required to build the
bitstream — only to load it on a physical board afterwards.

Verify git-lfs is active before cloning:

.. code-block:: bash

   git lfs version

If git-lfs is not installed, follow the instructions at
https://git-lfs.com before proceeding.

Clone pgp-pcie-apps
-------------------

``axi-pcie-core`` is a firmware submodule library; it does not contain a
standalone top-level project.  The tutorial uses ``slaclab/pgp-pcie-apps``
as the downstream consumer.

.. code-block:: bash

   git clone https://github.com/slaclab/pgp-pcie-apps.git
   cd pgp-pcie-apps

Initialise Submodules
---------------------

``pgp-pcie-apps`` uses recursive git submodules — including ``axi-pcie-core``,
``surf``, and ``ruckus``.  Initialise them all in one step:

.. code-block:: bash

   git submodule update --init --recursive

This downloads the pinned versions of all submodules and pulls LFS-tracked
binary IP checkpoints.  On a first clone the step takes several minutes and
transfers approximately 1 GB.

Source the Vivado Environment
------------------------------

Make sure ``vivado`` is on your ``PATH`` (and licence is reachable).  At
SLAC S3DF:

.. code-block:: bash

   source /sdf/group/faders/tools/xilinx/2025.2/Vivado/2025.2/settings64.sh

You can confirm with:

.. code-block:: bash

   which vivado
   vivado -version | head -1
   # Expected:  Vivado v2025.2 (64-bit)

Navigate to the Build Target
-----------------------------

The XilinxVariumC1100 DMA loopback target is under:

.. code-block:: bash

   cd firmware/targets/XilinxVariumC1100/XilinxVariumC1100DmaLoopback

Build the Bitstream
-------------------

Run ``make`` to invoke Vivado in batch mode.  The ruckus build system
assembles the Vivado project, runs synthesis and implementation, and
generates the bitstream and MCS programming file:

.. code-block:: bash

   make

Vivado elaborates the CMS block design as part of the XilinxVariumC1100
build flow.  This is handled automatically by the ``ruckus.tcl`` chain; no
manual block-design configuration is needed.  See
:doc:`/explanation/architecture` for a description of the shared RTL modules
that ``axi-pcie-core`` contributes to this build.

A successful full build typically takes several hours on a modern
workstation.  Use ``make`` again later — incremental dependencies in
ruckus.tcl will skip steps that have not changed.

Where the Build Runs
~~~~~~~~~~~~~~~~~~~~

ruckus writes the Vivado project and per-run artefacts under:

.. code-block:: text

   firmware/build/XilinxVariumC1100DmaLoopback/

This is the working build tree (Vivado ``.xpr``, synth/impl runs,
checkpoints).  At SLAC the ruckus build location can be redirected to a
faster local scratch path via ``$TOP_DIR/build`` symlink convention; out of
the box it resolves to ``firmware/build/<TargetName>/``.

The final shipping artefacts are copied to a separate directory under the
target itself — see `Build Artefacts`_ below.

Expected Critical Warnings
~~~~~~~~~~~~~~~~~~~~~~~~~~

The XilinxVariumC1100 build emits two non-fatal ``CRITICAL_WARNING`` lines
that are expected and safe to ignore:

* ``[Designutils 20-1280] Could not find module
  'XilinxVariumC1100PciePhyGen4x8_pcie4c_ip'. The XDC file ...
  _late.xdc will not be read for any cell of this module.``

  The PCIe PHY is delivered as a pre-compiled ``.dcp`` checkpoint, so its
  inner module is not visible to the late XDC pass.  Vivado applies the
  constraints when the DCP is linked in.

* ``[Project 1-498] One or more constraints failed evaluation while
  reading constraint file [.../pcie-4x8/xdc/XilinxVariumC1100Timing.xdc]
  and the design contains unresolved black boxes.``

  Same root cause as above — the PHY is a black box at this point of
  elaboration; Vivado re-reads and applies these timing constraints
  post-synthesis.

Other Useful Targets
~~~~~~~~~~~~~~~~~~~~

The Makefile inherits standard ruckus targets:

.. code-block:: bash

   make gui      # open the Vivado project in the GUI for debugging
   make bit      # build only the .bit file
   make prom     # build the .bit + .mcs PROM image (same as default)
   make clean    # remove the build/ tree

Build Artefacts
---------------

On a successful build, output files are placed under:

.. code-block:: text

   firmware/targets/XilinxVariumC1100/XilinxVariumC1100DmaLoopback/images/

By default (``GEN_BIT_IMAGE=1``, ``GEN_MCS_IMAGE=1``, gzip flags off) the
directory will contain a ``.bit`` and a ``.mcs`` whose basename is
ruckus's ``IMAGENAME``:

.. code-block:: text

   XilinxVariumC1100DmaLoopback-0x03030000-20260521094121-ruckman-b94c4a7.bit   # ~21 MB
   XilinxVariumC1100DmaLoopback-0x03030000-20260521094121-ruckman-b94c4a7.mcs   # ~57 MB, SPIx4 PROM

ruckus defines ``IMAGENAME`` in
``ruckus/system_shared.mk`` as
``$(PROJECT)-$(PRJ_VERSION)-$(BUILD_TIME)-$(USER)-$(GIT_HASH_SHORT)``,
so the filename embeds the full build provenance:

.. list-table::
   :header-rows: 1
   :widths: 22 16 18 44

   * - Field
     - Make variable
     - Example
     - Source
   * - target name
     - ``$(PROJECT)``
     - ``XilinxVariumC1100DmaLoopback``
     - target directory name
   * - firmware version
     - ``$(PRJ_VERSION)``
     - ``0x03030000``
     - downstream project's ``shared_config.mk``
   * - build timestamp
     - ``$(BUILD_TIME)``
     - ``20260521094121``
     - ``date +%Y%m%d%H%M%S`` at build start; can be overridden via env var
   * - user
     - ``$(USER)``
     - ``ruckman``
     - the Unix user that ran ``make``
   * - git hash
     - ``$(GIT_HASH_SHORT)``
     - ``b94c4a7``
     - ``git rev-parse --short HEAD`` of the downstream project

If the working tree is dirty (``git update-index --refresh`` reports
unstaged changes), the trailing git-hash segment is replaced with the
literal string ``dirty`` so an inadvertent uncommitted build is
immediately recognisable from the filename.

For partial-reconfiguration flows (``RECONFIG_STATIC_HASH != 0``), an
additional ``_<RECONFIG_STATIC_HASH>`` suffix is appended after the
git hash.

Set ``GEN_BIT_IMAGE_GZIP=1`` and/or ``GEN_MCS_IMAGE_GZIP=1`` in the
environment before invoking ``make`` to also produce gzipped copies
(``.bit.gz``, ``.mcs.gz``).

Use the ``.bit`` file to program the board over JTAG with Vivado Hardware
Manager.  Use the ``.mcs`` file to program the SPI configuration PROM for
persistent storage.

Next Steps
----------

- To add ``axi-pcie-core`` as a submodule in your own downstream project,
  see :doc:`/how-to/integrate_as_submodule`.
- For a complete list of supported boards and their Vivado version
  requirements, see :doc:`/reference/supported_boards`.
- For the in-hardware PRBS test variant of the same XilinxVariumC1100
  flow (a second target that pulls in ``common/PrbsTester`` and the board
  ``ddr`` subtree), see ``firmware/targets/XilinxVariumC1100/XilinxVariumC1100PrbsTester/``
  in ``pgp-pcie-apps``.  The build invocation is identical (``cd`` into the
  target directory and run ``make``).
