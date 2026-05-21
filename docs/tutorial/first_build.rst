First Build
===========

This tutorial walks you through building a real PCIe bitstream for the
**Xilinx Varium C1100** board using ``axi-pcie-core`` as a submodule of
``slaclab/pgp-pcie-apps``.

.. note::

   **Vivado 2024.2 or later is required.**  The ``XilinxVariumC1100`` target
   uses the CMS block design and HBM2 IP, both of which require Vivado 2024.2+.
   See :doc:`/reference/supported_boards` for a full list of per-board Vivado
   version requirements.

The board is a Gen4x8 PCIe card with HBM2 on-board memory.  The end artifact
is a real ``.bit`` bitstream and ``.mcs`` programming file produced by
Vivado.  The tutorial stops at the build step; it does not cover driver
loading or hardware bring-up.

Prerequisites
-------------

Before you begin, ensure the following are installed and available on your
``PATH``:

- **git** 2.x with **git-lfs** installed and initialized (required for
  ``.dcp``, ``.mcs``, and ``.bit`` assets tracked in LFS)
- **Vivado 2024.2** or later (the ``vivado`` executable must be on your
  ``PATH`` or sourced via the Vivado settings script)
- **JTAG cable** and Vivado Hardware Manager (required for loading the
  bitstream to the board after the build; not needed for the build itself)

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

This downloads the pinned versions of all submodules.  On a first clone the
step takes several minutes and transfers several hundred megabytes.

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

A successful full build takes approximately two to four hours depending on
your workstation.

Build Artefacts
---------------

On a successful build, output files are placed under:

.. code-block:: text

   firmware/targets/XilinxVariumC1100/XilinxVariumC1100DmaLoopback/images/

The directory will contain:

.. code-block:: text

   XilinxVariumC1100DmaLoopback-<version>.bit   # Vivado bitstream
   XilinxVariumC1100DmaLoopback-<version>.mcs   # MCS programming file

Use the ``.bit`` file to program the board over JTAG with Vivado Hardware
Manager.  Use the ``.mcs`` file to program the SPI configuration PROM for
persistent storage.

Next Steps
----------

- To add ``axi-pcie-core`` as a submodule in your own downstream project,
  see :doc:`/how-to/integrate_as_submodule`.
- For a complete list of supported boards and their Vivado version
  requirements, see :doc:`/reference/supported_boards`.
