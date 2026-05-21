Register Map Reference
======================

This page documents the BAR0 AXI-Lite address map and the
``PcieAxiVersion`` register set.  Per-board application-region register maps
are owned by the downstream user project; this library defines the partition
boundaries but does not document application registers.

BAR0 AXI-Lite Crossbar
-----------------------

``AxiPcieReg`` (:repo:`shared/rtl/AxiPcieReg.vhd`) bridges the AXI4 BAR0 bus
from the PCIe PHY down to a 15-slave AXI-Lite crossbar.  The base addresses
are sourced from ``AXI_CROSSBAR_MASTERS_CONFIG_C`` in ``AxiPcieReg.vhd``.
See :doc:`/explanation/architecture` for the BAR0 crossbar diagram.

.. list-table:: BAR0 AXI-Lite crossbar slaves
   :header-rows: 1
   :widths: 10 15 25 50

   * - Index
     - Offset
     - Slave
     - Notes
   * - 0 (``DMA_INDEX_C``)
     - ``0x00000``
     - DMA descriptor engine
     - ``surf.AxiStreamDmaV2`` control and interrupt registers.
   * - 1 (``PHY_INDEX_C``)
     - ``0x10000``
     - PCIe PHY CSR
     - Per-board PCIe IP status and configuration registers.
   * - 2 (``VERSION_INDEX_C``)
     - ``0x20000``
     - PcieAxiVersion
     - Build info, device DNA, ICAP, and PCIe-core-specific fields.
       See the ``PcieAxiVersion Registers`` section below.
   * - 3 (``SYSMON_INDEX_C``)
     - ``0x24000``
     - Sysmon (XADC)
     - ``surf.AxiSysMonUltraScale`` — die temperature and voltage ADC.
   * - 4 (``GPU_INDEX_C``)
     - ``0x28000``
     - GPU async control
     - ``AxiPcieGpuAsyncCore`` AXI-Lite control/monitoring registers
       (appClk domain).
   * - 5 (``BPI_INDEX_C``)
     - ``0x30000``
     - BPI flash
     - ``surf.AxiMicronMt28ewReg`` — Micron MT28EW boot PROM access.
   * - 6 (``SPI0_INDEX_C``)
     - ``0x40000``
     - SPI flash 0
     - ``surf.AxiMicronN25QCore`` — chip-select 0.
   * - 7 (``SPI1_INDEX_C``)
     - ``0x50000``
     - SPI flash 1
     - ``surf.AxiMicronN25QCore`` — chip-select 1.
   * - 8 (``AXIS_MON_IB_C``)
     - ``0x60000``
     - IB stream monitor
     - ``surf.AxiStreamMonAxiL`` — inbound DMA traffic counters.
   * - 9 (``AXIS_MON_OB_C``)
     - ``0x68000``
     - OB stream monitor
     - ``surf.AxiStreamMonAxiL`` — outbound DMA traffic counters.
   * - 10 (``I2C_INDEX_C``)
     - ``0x70000``
     - I2C / I2C mux
     - ``surf.AxiLiteMasterProxy`` bridging to the board I2C bus.
   * - 11 (``APP1_INDEX_C``)
     - ``0x100000``
     - App region 1
     - Application AXI-Lite slave, appClk domain, 1 MB window.
       See :ref:`application-regions` below.
   * - 12 (``APP2_INDEX_C``)
     - ``0x200000``
     - App region 2
     - Application AXI-Lite slave, appClk domain, 2 MB window.
   * - 13 (``APP3_INDEX_C``)
     - ``0x400000``
     - App region 3
     - Application AXI-Lite slave, appClk domain, 4 MB window.
   * - 14 (``APP4_INDEX_C``)
     - ``0x800000``
     - App region 4
     - Application AXI-Lite slave, appClk domain, 8 MB window.

.. _application-regions:

PcieAxiVersion Registers
------------------------

``PcieAxiVersion`` (:repo:`python/axipcie/_PcieAxiVersion.py`) extends
``surf.axi.AxiVersion`` and is the canonical "build info" surface that user
code reads at startup to identify firmware version, PCIe configuration, and
runtime parameters.  It sits at BAR0 offset ``0x20000`` (``VERSION_INDEX_C``).

The ``surf.axi.AxiVersion`` parent class provides the standard firmware
identification fields; ``PcieAxiVersion`` adds PCIe-core-specific fields at
offset ``0x400`` and above.

.. list-table:: PcieAxiVersion registers
   :header-rows: 1
   :widths: 12 30 12 8 38

   * - Offset
     - Field
     - Bits
     - Mode
     - Description
   * - ``0x000``
     - ``FpgaVersion``
     - 31:0
     - RO
     - Firmware version word (from ``surf.axi.AxiVersion``).
   * - ``0x004``
     - ``ScratchPad``
     - 31:0
     - RW
     - Read/write scratch register for software testing
       (from ``surf.axi.AxiVersion``).
   * - ``0x008``
     - ``UpTimeCnt``
     - 31:0
     - RO
     - Free-running 1 Hz up-time counter in seconds
       (from ``surf.axi.AxiVersion``).
   * - ``0x010``
     - ``DeviceDna``
     - 63:0
     - RO
     - Xilinx Device DNA (64-bit unique ID from EFUSE_DNA primitive;
       from ``surf.axi.AxiVersion``).
   * - ``0x020``
     - ``FdSerial``
     - 63:0
     - RO
     - DS2411 1-wire silicon serial number (board-level, when present;
       from ``surf.axi.AxiVersion``).
   * - ``0x030``
     - ``DnaValue``
     - 127:0
     - RO
     - Extended DNA / UID register (128-bit;
       from ``surf.axi.AxiVersion``).
   * - ``0x200``
     - ``BuildStamp``
     - 2047:0
     - RO
     - 256-byte null-terminated ASCII build string encoding git hash,
       date, and tool versions (from ``surf.axi.AxiVersion``).
   * - ``0x400``
     - ``DMA_SIZE_G``
     - 31:0
     - RO
     - Number of DMA lanes instantiated (value of ``DMA_SIZE_G`` generic).
   * - ``0x404``
     - ``Reserved``
     - 31:0
     - RO
     - Reserved, reads zero.
   * - ``0x408``
     - ``DRIVER_TYPE_ID_G``
     - 31:0
     - RO
     - Driver-type identifier set at synthesis by ``DRIVER_TYPE_ID_G``
       generic.
   * - ``0x40C``
     - ``XIL_DEVICE_G``
     - 31:0
     - RO
     - Device family: 0 = UltraScale, 1 = 7-Series.
   * - ``0x410``
     - ``DMA_CLK_FREQ_C``
     - 31:0
     - RO
     - DMA system clock frequency in Hz (typically 250000000).
   * - ``0x414``
     - ``BOOT_PROM_G``
     - 31:0
     - RO
     - Boot PROM type: 0 = BPI, 1 = SPIx8, 2 = SPIx4.
   * - ``0x418``
     - ``DMA_AXIS_CONFIG_G`` (packed)
     - 31:0
     - RO
     - Packed DMA stream config: bits[31:24] TDATA_BYTES_C,
       [23:20] TDEST_BITS_C, [19:16] TUSER_BITS_C,
       [15:12] TID_BITS_C, [11:8] TKEEP_MODE_C,
       [7:4] TUSER_MODE_C, [1] TSTRB_EN_C, [0] AppReset.
   * - ``0x41C``
     - ``AXI_PCIE_CONFIG_C`` (packed)
     - 31:0
     - RO
     - Packed AXI config: bits[31:24] ADDR_WIDTH_C,
       [23:16] DATA_BYTES_C, [15:8] ID_BITS_C, [7:0] LEN_BITS_C.
   * - ``0x420``
     - ``AppClkFreq``
     - 31:0
     - RO
     - Application clock frequency in Hz (live measurement).
   * - ``0x424``
     - ``PCIE_HW_TYPE_G``
     - 31:0
     - RO
     - Board hardware type identifier (see ``AxiPcieSharedPkg.vhd``
       ``HW_TYPE_*`` constants; e.g., 0x0D = XilinxKcu1500).
   * - ``0x428``
     - ``DataGpuEn``
     - 0
     - RO
     - ``'1'`` when ``DATAGPU_EN_G`` was set at synthesis (GPU-Direct
       async path enabled).

Application Regions
-------------------

The four application-region crossbar slaves are defined in
:repo:`shared/rtl/AxiPcieCommonPkg.vhd` (``APP_BAR0_XBAR_CONFIG_C``) and
indexed as ``APP1_INDEX_C`` through ``APP4_INDEX_C`` (the
``APP_INDEX_C``-series) in ``shared/rtl/AxiPcieReg.vhd``.  Their BAR0 base addresses are:

- ``APP1_INDEX_C`` — ``0x100000`` (1 MB window, 20-bit address space)
- ``APP2_INDEX_C`` — ``0x200000`` (2 MB window, 21-bit address space)
- ``APP3_INDEX_C`` — ``0x400000`` (4 MB window, 22-bit address space)
- ``APP4_INDEX_C`` — ``0x800000`` (8 MB window, 23-bit address space)

These four slaves are merged by a second AXI-Lite crossbar inside
``AxiPcieReg`` and exposed as a single ``appReadMaster`` / ``appWriteMaster``
pair that crosses via ``surf.AxiLiteAsync`` to the ``appClk`` domain.
This library defines only the partition; the downstream project is responsible
for routing ``appReadMaster`` / ``appWriteMaster`` to its own register tree.
