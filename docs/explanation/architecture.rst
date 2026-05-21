Architecture
============

Overview
--------

Every board support module in ``axi-pcie-core`` follows the same structural
pattern.  The per-board entity ``<Board>Core`` instantiates three top-level
subsystems:

* a PCIe PHY wrapper (board-specific IP delivered as a pre-built ``.dcp``
  checkpoint),
* ``AxiPcieReg`` — the BAR0 AXI-to-AXI-Lite bridge and 15-slave register
  crossbar, and
* ``AxiPcieDma`` — the AXI-Stream data-plane DMA engine.

All DMA and register logic runs synchronously on a single 250 MHz system clock
(``DMA_CLK_FREQ_C``) sourced from the PCIe PHY's recovered reference clock.
Application logic on a separate ``appClk`` domain is decoupled via
``surf.AxiLiteAsync`` bridges inside ``AxiPcieReg``.

AXI-Lite Register Tree
----------------------

``AxiPcieReg`` bridges the AXI4 BAR0 register bus from the PCIe PHY down to a
15-slave AXI-Lite crossbar.  The bridge uses ``surf.AxiToAxiLite``; write
transactions are pre-filtered by ``AxiPcieRegWriteMux``, which separates PCIe
Intercommunication Protocol (PIP) writes from normal register writes before
the bridge.

The diagram below shows the BAR0 AXI-Lite crossbar fan-out.  Base addresses
are sourced from the ``AXI_CROSSBAR_MASTERS_CONFIG_C`` constant in
``AxiPcieReg.vhd``:

.. code-block:: text

    Host
      |  BAR0 (AXI4, 256-bit, 64-bit addr)
      v
    AxiPcieReg  (AXI4 -> AXI-Lite bridge, 15-slave crossbar)
      |
      +--[0x0000_0000]  DMA control         (AxiStreamDmaV2 descriptor engine)
      +--[0x0001_0000]  PCIe PHY CSR        (per-board PHY status / config)
      +--[0x0002_0000]  AxiVersion          (build info, device DNA, ICAP)
      +--[0x0002_4000]  Sysmon              (XADC: die temperature / voltage)
      +--[0x0002_8000]  GPU async           (AxiGpuAsyncCore, appClk domain)
      +--[0x0003_0000]  BPI flash           (AxiMicronMt28ewReg, boot PROM)
      +--[0x0004_0000]  SPI flash 0         (AxiMicronN25QCore, chip-select 0)
      +--[0x0005_0000]  SPI flash 1         (AxiMicronN25QCore, chip-select 1)
      +--[0x0006_0000]  IB stream monitor   (AXIS traffic monitor, inbound)
      +--[0x0006_8000]  OB stream monitor   (AXIS traffic monitor, outbound)
      +--[0x0007_0000]  I2C / I2C mux       (AxiLiteMasterProxy -> board I2C)
      +--[0x0010_0000]  App region 1        (appClk domain, 1 MB)
      +--[0x0020_0000]  App region 2        (appClk domain, 2 MB)
      +--[0x0040_0000]  App region 3        (appClk domain, 4 MB)
      +--[0x0080_0000]  App region 4        (appClk domain, 8 MB)

The four application region slaves (indices 11–14) are merged by a second
AXI-Lite crossbar inside ``AxiPcieReg`` and exposed as a single
``appReadMaster`` / ``appWriteMaster`` pair that crosses to the application
clock domain via ``surf.AxiLiteAsync``.  Unimplemented or unused crossbar
slots respond with ``AXI_RESP_DECERR``.

AXI-Stream DMA Channels
-----------------------

``AxiPcieDma`` instantiates surf's ``AxiStreamDmaV2`` engine and
``AxiPcieCrossbar``.  ``AxiPcieCrossbar`` presents ``DMA_SIZE_G + 2`` AXI4
slave ports feeding a single AXI4 master that connects to the PCIe PHY:
one descriptor port, up to eight DMA lane ports, and one user general-purpose
port.  Because the crossbar has a fixed budget of 10 slave ports, ``DMA_SIZE_G``
is bounded to 8.

Each DMA lane exposes two AXI-Stream channels to the application:

* **Inbound (IB)**: data flowing from the host into the FPGA application.
  The DMA engine reads host DMA buffers over PCIe and drives ``dmaObMasters``
  toward the application.
* **Outbound (OB)**: data flowing from the FPGA application to the host.
  The application drives ``dmaIbMasters`` into the DMA engine, which writes
  the data into host DMA buffers over PCIe.

The IB/OB FIFO depth, descriptor back-pressure, and the DMA IRQ path are
described in the ``PCIe DMA Model`` page.

Board Abstraction: AxiPciePkg and AxiPcieSharedPkg
---------------------------------------------------

``AxiPciePkg.vhd`` (one per board, under ``hardware/<board>/rtl/``) defines
two compile-time constants that the entire shared RTL parameterizes off:

* ``DMA_CLK_FREQ_C`` — the system clock frequency in Hz (250.0E+6 = 250 MHz
  on all current boards).
* ``AXI_PCIE_CONFIG_C`` — an ``AxiConfigType`` record with four fields:
  ``DATA_BYTES_C`` (bus width, e.g. 32 bytes = 256-bit for KCU1500),
  ``ADDR_WIDTH_C`` (64 bits on all boards), ``ID_BITS_C`` (4, meaning up to
  16 outstanding AXI IDs / DMA descriptors), and ``LEN_BITS_C`` (8, the AXI
  AWLEN/ARLEN field width).

A single shared RTL codebase under ``shared/rtl/`` serves boards with
different bus widths (16 B, 32 B, or 64 B data paths) without any
per-board conditional compilation: the ``AxiPciePkg`` constants drive all
width-dependent parameters at VHDL elaboration time.

``AxiPcieSharedPkg.vhd`` (shared, under ``shared/rtl/``) defines a 32-bit
``HW_TYPE_*`` constant for every supported board — for example
``HW_TYPE_XILINX_KCU1500_C`` (0x0D), ``HW_TYPE_XILINX_U200_C`` (0x07),
``HW_TYPE_BITTWARE_XUP_VV8_VU13P_C`` (0x02).  ``AxiPcieReg`` writes the
active board's ``HW_TYPE_*`` value into ``userValues(9)`` of the
``AxiVersion`` register block, allowing software (PyRogue /
``rogue.hardware.axi.AxiMemMap``) and downstream firmware to identify the
carrier at runtime without hard-coded magic numbers.

Together, ``AxiPciePkg`` (compile-time per-board bus sizing) and
``AxiPcieSharedPkg`` (compile-time cross-board identity taxonomy) form the
complete board abstraction layer.
