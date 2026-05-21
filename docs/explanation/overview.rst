Overview
========

What axi-pcie-core Is
---------------------

``axi-pcie-core`` is a SLAC FPGA firmware submodule library providing AXI-Lite/AXI-Stream
interconnect and DMA infrastructure for PCIe carrier boards.  Downstream firmware projects
consume it as a ``git submodule``, integrating support for boards such as ``XilinxKcu1500``,
``XilinxAlveoU200``, and ``XilinxAlveoU55c`` among the fourteen supported PCIe carriers.

Audience
--------

This library targets two groups of engineers.  FPGA engineers integrate ``axi-pcie-core``
as a submodule into a downstream firmware project, wiring board I/O, DMA channels, and
application AXI-Lite slaves through the board's top-level ``<Board>Core`` entity.  Software
engineers use the PyRogue device-driver layer under ``python/axipcie/`` to enumerate the
BAR0 register map, configure DMA channels, and stream data through ``rogue`` transport
backends.

Scope
-----

``axi-pcie-core`` provides:

* PCIe PHY wrapping (pre-compiled Vivado ``.dcp`` per board)
* AXI-Lite register crossbar (``AxiPcieReg``)
* AXI-Stream DMA engine (``AxiPcieDma``)
* DDR4 and HBM DMA buffers (``MigDmaBuffer``, ``HbmDmaBuffer``)
* Optional PIP peer-FPGA and GPU-direct async protocols
* PyRogue Python driver layer (``python/axipcie/``)

It does not cover:

* Board bring-up or hardware validation procedures
* Vivado or toolchain installation guides
* Kernel-driver development — that is tracked in the ``aes-stream-drivers`` repository

Relationship to ruckus and surf
-------------------------------

``ruckus`` is the TCL build framework that drives Vivado project assembly.  The minimum
version is v4.24.2, enforced in ``shared/ruckus.tcl`` via ``SubmoduleCheck``; downstream
projects are free to track a newer ruckus revision.  Each supported board ships a
``ruckus.tcl`` that a downstream project sources via ``loadRuckusTcl``, pulling in all
board-specific RTL, IP, and constraints without any manual Vivado project setup.

``surf`` is the SLAC FPGA RTL common library; the minimum version is v2.71.0 (same
enforcement mechanism as ruckus).  It supplies the primitives that every file under
``shared/rtl/`` depends on: ``AxiLitePkg``, ``AxiStreamPkg``, ``AxiStreamDmaV2``,
synchronisation primitives, and peripheral device drivers.  Both submodule version locks
are enforced at build time, so a downstream project built against a mismatched ``surf`` or
``ruckus`` revision receives a hard error rather than a silent ABI mismatch.  Set the
environment variable ``OVERRIDE_SUBMODULE_LOCKS=1`` before invoking ``make`` to bypass
the check during development.
