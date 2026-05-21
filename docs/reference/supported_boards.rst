Supported Boards
================

This page is the lookup table for all 14 supported boards under ``hardware/``. The
table has one row per **variant** — boards with multiple FPGA variants (BittWare
XUP-VV8 with VU9P/VU13P, Abaco PC821 with KU085/KU115) each get two rows — so the
total row count is 16 for 14 boards. See :doc:`/explanation/board_support` for an
explanation of the per-board directory layout and the ``ruckus.tcl`` chain used by
downstream firmware projects.

Board Reference Table
---------------------

.. list-table::
   :header-rows: 1
   :widths: 22 12 10 13 18 25

   * - Board
     - PCIe gen/lanes
     - Memory
     - Transceiver class
     - Top-level entity
     - Path
   * - Xilinx Alveo U200
     - PCIe 3, x16
     - DDR4 (4ch)
     - Gen3x16
     - ``XilinxAlveoU200Core``
     - ``hardware/XilinxAlveoU200/core/XilinxAlveoU200Core.vhd``
   * - Xilinx Alveo U250
     - PCIe 3, x16
     - DDR4 (4ch)
     - Gen3x16
     - ``XilinxAlveoU250Core``
     - ``hardware/XilinxAlveoU250/core/XilinxAlveoU250Core.vhd``
   * - Xilinx Alveo U280
     - PCIe 3, x16
     - DDR4 (2ch)
     - Gen3x16
     - ``XilinxAlveoU280Core``
     - ``hardware/XilinxAlveoU280/pcie-3x16/rtl/XilinxAlveoU280Core.vhd``
   * - Xilinx Alveo U50
     - PCIe 3, x16
     - none
     - Gen3x16
     - ``XilinxAlveoU50Core``
     - ``hardware/XilinxAlveoU50/pcie-3x16/rtl/XilinxAlveoU50Core.vhd``
   * - Xilinx Alveo U55c
     - PCIe 4, x8
     - HBM
     - Gen4x8
     - ``XilinxAlveoU55cCore``
     - ``hardware/XilinxAlveoU55c/pcie-4x8/rtl/XilinxAlveoU55cCore.vhd``
   * - Xilinx KCU105
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``XilinxKcu105Core``
     - ``hardware/XilinxKcu105/rtl/XilinxKcu105Core.vhd``
   * - Xilinx KCU116
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``XilinxKcu116Core``
     - ``hardware/XilinxKcu116/rtl/XilinxKcu116Core.vhd``
   * - Xilinx KCU1500
     - PCIe 3, x8
     - DDR4 (4ch)
     - Gen3x8
     - ``XilinxKcu1500Core``
     - ``hardware/XilinxKcu1500/rtl/XilinxKcu1500Core.vhd``
   * - Xilinx VCU128
     - PCIe 3, x16
     - none
     - Gen3x16
     - ``XilinxVcu128Core``
     - ``hardware/XilinxVcu128/pcie-3x16/rtl/XilinxVcu128Core.vhd``
   * - Xilinx Varium C1100
     - PCIe 4, x8
     - HBM
     - Gen4x8
     - ``XilinxVariumC1100Core``
     - ``hardware/XilinxVariumC1100/pcie-4x8/rtl/XilinxVariumC1100Core.vhd``
   * - BittWare XUP-VV8 (VU9P)
     - PCIe 3, x16
     - DDR4
     - Gen3x16
     - ``BittWareXupVv8Core``
     - ``hardware/BittWareXupVv8/core/BittWareXupVv8Core.vhd``
   * - BittWare XUP-VV8 (VU13P)
     - PCIe 3, x16
     - DDR4
     - Gen3x16
     - ``BittWareXupVv8Core``
     - ``hardware/BittWareXupVv8/core/BittWareXupVv8Core.vhd``
   * - Abaco PC821 (KU085)
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``AbacoPc821Core``
     - ``hardware/AbacoPc821/rtl/AbacoPc821Core.vhd``
   * - Abaco PC821 (KU115)
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``AbacoPc821Core``
     - ``hardware/AbacoPc821/rtl/AbacoPc821Core.vhd``
   * - AlphaData KU3
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``AlphaDataKu3Core``
     - ``hardware/AlphaDataKu3/rtl/AlphaDataKu3Core.vhd``
   * - SLAC PgpCard G4
     - PCIe 3, x8
     - none
     - Gen3x8
     - ``SlacPgpCardG4Core``
     - ``hardware/SlacPgpCardG4/rtl/SlacPgpCardG4Core.vhd``

Notes
-----

* :repo:`shared/rtl/AxiPcieSharedPkg.vhd` defines ``HW_TYPE_*`` integer constants for every
  supported board (e.g., ``HW_TYPE_XILINX_KCU1500_C``, ``HW_TYPE_BITT_WARE_XUP_VV8_C``).
  These are the canonical board taxonomy; the ``PCIE_HW_TYPE_G`` register in
  ``PcieAxiVersion`` returns the ``HW_TYPE_*`` value burned into firmware, and
  ``AxiPcieCore`` validates it at startup against the ``boardType`` constructor argument.

* Vivado version requirements: Vivado 2020.1 or later is required for all boards except
  ``XilinxAlveoU55c`` and ``XilinxVariumC1100``, which require Vivado 2024.2 or later
  due to their CMS block-design and HBM IP dependencies.

* See :doc:`/explanation/board_support` for the per-board directory layout
  (``hardware/<Board>/ruckus.tcl`` chain, PCIe variant subdirectories, DDR/HBM optional
  modules) and the ruckus build integration guide.
