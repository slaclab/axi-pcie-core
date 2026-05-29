PyRogue API Reference
=====================

This page is a hand-written manual reference for all entries in the ``python/axipcie/``
package — nine device classes and the module-level connection helpers. It covers what
each class exposes to the PyRogue register tree and how to instantiate it.
Surf-provided base classes (``pr.Device``, ``pr.Root``, ``surf.axi.AxiVersion``) are
referenced by name only; their APIs are documented in the pyrogue and surf projects
respectively. This reference is written by hand, not auto-generated — per the project
decision recorded in ``PROJECT.md`` (section "Key Decisions":
*Manual RTL/PyRogue reference (no autodoc)*).

See :doc:`/explanation/architecture` for the BAR0 register-map overview that these
classes map to.

AxiPcieCore
-----------

``AxiPcieCore`` (subclasses ``pr.Device``; defined in :repo:`python/axipcie/_AxiPcieCore.py`) maps to ``shared/rtl/AxiPcieReg.vhd``. It
is the top-level PyRogue device tree for the PCIe BAR0 register space, instantiating
``PcieAxiVersion``, AXI-Stream monitors, optional PROM/SysMon/I2C/transceiver devices,
and optionally ``AxiGpuAsyncCore``. It does not declare ``pr.RemoteVariable`` instances
directly; instead it assembles a tree of sub-devices at fixed offsets.

.. code-block:: python

    class AxiPcieCore(pr.Device):
        def __init__(self,
                     description      = 'Base components of the PCIe firmware core',
                     useBpi           = False,
                     useGpu           = False,
                     useSpi           = False,
                     transceiverClass = [None],
                     numDmaLanes      = 1,
                     boardType        = None,
                     extended         = False,
                     sim              = False,
                     **kwargs):

.. list-table:: AxiPcieCore sub-devices
   :header-rows: 1
   :widths: 28 14 20 38

   * - Sub-device
     - BAR0 Offset
     - Condition
     - Description
   * - ``PcieAxiVersion``
     - ``0x20000``
     - Always
     - Build-info and board-type identification registers
   * - ``AxiStreamMonAxiL`` (DmaIbAxisMon)
     - ``0x60000``
     - Always
     - DMA inbound (host to FPGA) stream monitor; ``numberLanes=numDmaLanes``
   * - ``AxiStreamMonAxiL`` (DmaObAxisMon)
     - ``0x68000``
     - Always
     - DMA outbound (FPGA to host) stream monitor; ``numberLanes=numDmaLanes``
   * - ``xil.AxiPciePhy``
     - ``0x10000``
     - ``not sim``
     - PCIe PHY link-status registers
   * - ``AxiGpuAsyncCore``
     - ``0x28000``
     - ``useGpu=True``
     - GPU-Direct async data-path registers
   * - ``micron.AxiMicronMt28ew``
     - ``0x30000``
     - ``useBpi=True``
     - BPI PROM (Micron MT28 or Cypress S29GL)
   * - ``micron.AxiMicronN25Q[0]``
     - ``0x40000``
     - ``useSpi=True``
     - SPI PROM channel 0
   * - ``micron.AxiMicronN25Q[1]``
     - ``0x50000``
     - ``useSpi=True``
     - SPI PROM channel 1
   * - ``axi.AxiLiteMasterProxy`` (AxilBridge)
     - ``0x70000``
     - ``not extended``
     - I2C bridge proxy (prevents BAR0 stall on slow I2C transactions)
   * - ``xil.AxiSysMonUltraScale``
     - ``0x24000``
     - board-specific
     - UltraScale/UltraScale+ SysMon (temperature, VCC rails)
   * - Per-slot transceiver (QSFP/SFP)
     - varies
     - ``boardType`` set
     - ``xceiver.Qsfp`` / ``xceiver.Sfp`` instances routed via ``AxilBridge`` proxy

**Notes.** At ``_start()`` time, ``AxiPcieCore`` reads ``PCIE_HW_TYPE_G`` from
``PcieAxiVersion`` and raises ``ValueError`` if it does not match ``boardType``.
Pass ``boardType=None`` to skip this check. Pass ``sim=True`` to bypass all hardware
devices (PCIe PHY, PROM, I2C, SysMon, transceiver) for software co-simulation.
The ``transceiverClass`` argument accepts a per-slot list; valid string entries are
``'QSFP'``, ``'SFP'``, and ``'QSFP-DD'``.

AxiPcieRoot
-----------

``AxiPcieRoot`` (subclasses ``pr.Root``; defined in :repo:`python/axipcie/_AxiPcieRoot.py`) is a convenience wrapper that opens the PCIe
BAR0 memory map via ``rogue.hardware.axi.AxiMemMap`` and instantiates ``AxiPcieCore``
at the top of the device tree. It is intended for simple use-cases; production projects
typically build a custom ``pr.Root`` subclass.

.. code-block:: python

    class AxiPcieRoot(pr.Root):
        def __init__(self, dev, **kwargs):

.. list-table:: AxiPcieRoot sub-devices
   :header-rows: 1
   :widths: 30 70

   * - Sub-device
     - Description
   * - ``AxiPcieCore``
     - Full BAR0 register tree; constructed with ``useBpi=True``, ``useSpi=True``

**Notes.** ``dev`` is the Linux device-node path (e.g., ``'/dev/datadev_0'``). All
``**kwargs`` are forwarded to ``pr.Root.__init__``. For simulation or multi-device
scenarios, use ``createAxiPcieMemMap`` and ``createAxiPcieDmaStreams`` (see
`Module Helpers`_) and construct ``pr.Root`` directly.

AxiPcieDma
----------

The ``_AxiPcieDma`` module (:repo:`python/axipcie/_AxiPcieDma.py`) provides two module-level helper functions rather than a
device class. ``AxiPcieDma`` names a VHDL entity (the DMA engine in
``shared/rtl/AxiPcieDma.vhd``); there is no PyRogue ``AxiPcieDma`` class. DMA stream
monitoring is performed by ``surf.axi.AxiStreamMonAxiL`` instances added by
``AxiPcieCore`` (``DmaIbAxisMon`` at ``0x60000``, ``DmaObAxisMon`` at ``0x68000``).

The module-level helpers ``createAxiPcieMemMap`` and ``createAxiPcieDmaStreams`` are
exported from ``python/axipcie/__init__.py`` via wildcard import and are the primary
user-facing entry points for opening connections to hardware or simulation. See
`Module Helpers`_ for full signatures and ``driverPath`` mode documentation.

AxiPipCore
----------

``AxiPipCore`` (subclasses ``pr.Device``; defined in :repo:`python/axipcie/_AxiPipCore.py`) maps the register interface of the PCIe
Intercommunication Protocol (PIP) core. It monitors and controls cross-FPGA write
transactions from a peer FPGA over a shared PCIe root complex.

.. code-block:: python

    class AxiPipCore(pr.Device):
        def __init__(self,
                     numLane     = 1,
                     description = 'Container for the PIP core registers',
                     **kwargs):

.. list-table:: AxiPipCore RemoteVariables and RemoteCommands
   :header-rows: 1
   :widths: 32 16 10 42

   * - Name
     - Offset
     - Mode
     - Description
   * - ``REMOTE_BAR0_BASE_ADDRESS[i]``
     - ``0x000 + 8*i``
     - RW
     - Base address of peer FPGA BAR0 for lane ``i`` (one entry per ``numLane``)
   * - ``DepackEofeCnt[i]``
     - ``0x080 + 4*i``
     - RO
     - EOFE (end-of-frame error) depacketiser count for lane ``i``
   * - ``RxFrameCnt``
     - ``0x0E0``
     - RO
     - Total received frames
   * - ``RxDropFrameCnt``
     - ``0x0E4``
     - RO
     - Dropped received frames
   * - ``TxFrameCnt``
     - ``0x0E8``
     - RO
     - Total transmitted frames
   * - ``TxDropFrameCnt``
     - ``0x0EC``
     - RO
     - Dropped transmitted frames
   * - ``TxAxiErrorCnt``
     - ``0x0F0``
     - RO
     - AXI write error count on the transmit path
   * - ``NUM_AXIS_G``
     - ``0x0F4``
     - RO
     - Number of AXI-Stream lanes built into firmware
   * - ``EnableTx``
     - ``0x0F8 [numLane-1:0]``
     - RW
     - Per-lane transmit enable bitmask
   * - ``AxiWriteCache``
     - ``0x0F8 [27:24]``
     - RW
     - AXI write-cache attribute (4 bits, drives ``AWCACHE``)
   * - ``CountReset`` (command)
     - ``0x0FC``
     - WO
     - Pulse to clear all status counters

**Notes.** The corresponding VHDL entity is ``AxiPciePipCore`` (note the ``Pcie``
infix), located at ``protocol/pip/rtl/AxiPciePipCore.vhd``. The PyRogue class drops
the ``Pcie`` infix: ``AxiPipCore`` != ``AxiPciePipCore``. Both names refer to the same
hardware block; when tracing register definitions in the RTL, search for
``AxiPciePipCore``.

PcieAxiVersion
--------------

``PcieAxiVersion`` (subclasses ``surf.axi.AxiVersion``; defined in :repo:`python/axipcie/_PcieAxiVersion.py`) extends the standard surf
version block with PCIe-specific build-info fields. It is instantiated by
``AxiPcieCore`` at BAR0 offset ``0x20000``.

.. code-block:: python

    class PcieAxiVersion(axi.AxiVersion):
        def __init__(self,
                     name             = 'AxiVersion',
                     description      = 'AXI-Lite Version Module',
                     numUserConstants = 0,
                     **kwargs):

The table below covers the PCIe-specific registers appended at base offset ``0x400``.
Inherited ``surf.axi.AxiVersion`` registers (firmware version, build timestamp, git
hash, DNA, uptime counter, ``UserRst`` command) are not listed here. See
:doc:`/reference/register_map` for the full bit-field table.

.. list-table:: PcieAxiVersion RemoteVariables (0x400 block, selected)
   :header-rows: 1
   :widths: 36 16 10 38

   * - Name
     - Offset
     - Mode
     - Description
   * - ``DMA_SIZE_G``
     - ``0x400``
     - RO
     - Number of DMA lanes compiled into firmware (1 to 8)
   * - ``DRIVER_TYPE_ID_G``
     - ``0x408``
     - RO
     - Driver type identifier constant
   * - ``XIL_DEVICE_G``
     - ``0x40C``
     - RO
     - FPGA family enum: 0=ULTRASCALE, 1=7SERIES
   * - ``DMA_CLK_FREQ_C``
     - ``0x410``
     - RO
     - DMA clock frequency in Hz (250 000 000 for all production boards)
   * - ``BOOT_PROM_G``
     - ``0x414``
     - RO
     - Boot PROM type enum: BPI / SPIx8 / SPIx4 / UNDEFINED
   * - ``DMA_AXIS_CONFIG_G_TDATA_BYTES_C``
     - ``0x418 [31:24]``
     - RO
     - DMA AXI-Stream data width in bytes (e.g., 32 for 256-bit bus)
   * - ``AppReset``
     - ``0x418 [0]``
     - RO
     - Application reset status; Boolean, polled every 1 s
   * - ``AXI_PCIE_CONFIG_C_ADDR_WIDTH_C``
     - ``0x41C [31:24]``
     - RO
     - AXI address width in bits (64 on all production boards)
   * - ``AXI_PCIE_CONFIG_C_DATA_BYTES_C``
     - ``0x41C [23:16]``
     - RO
     - AXI data bus width in bytes (32 for 256-bit bus)
   * - ``AppClkFreq``
     - ``0x420``
     - RO
     - Application clock frequency in Hz; polled every 1 s
   * - ``PCIE_HW_TYPE_G``
     - ``0x424``
     - RO
     - Board-type enum matching ``HW_TYPE_*`` from ``AxiPcieSharedPkg.vhd``
   * - ``DataGpuEn``
     - ``0x428``
     - RO
     - GPU-Direct async core present in firmware; Boolean

**Notes.** ``PCIE_HW_TYPE_G`` is cross-checked by ``AxiPcieCore._start()`` against the
``boardType`` constructor argument. Additional packing sub-fields
(``DMA_AXIS_CONFIG_G_TDEST_BITS_C``, ``_TUSER_BITS_C``, ``_TID_BITS_C``,
``_TKEEP_MODE_C``, ``_TUSER_MODE_C``, ``_TSTRB_EN_C``) are packed into ``0x418`` and
``AXI_PCIE_CONFIG_C_ID_BITS_C`` / ``_LEN_BITS_C`` into ``0x41C``; see the source file
for full bit-field layout.

CmsProxy
--------

The ``_CmsProxy`` module (:repo:`python/axipcie/_CmsProxy.py`) defines the Xilinx CMS (Card Management Subsystem) interface
for ``XilinxAlveoU55c`` and ``XilinxVariumC1100`` boards. The primary user-facing class
is ``CmsSubsystem`` (subclasses ``pr.Device``). The module also exports
``CmsLowSpeedIo`` and ``Status``, which are accessed as sub-devices of
``CmsSubsystem``.

.. code-block:: python

    class CmsSubsystem(pr.Device):
        def __init__(self,
                     pollPeriod  = 0.0,
                     moduleType  = None,
                     numCages    = 1,
                     **kwargs):

.. list-table:: CmsSubsystem RemoteVariables
   :header-rows: 1
   :widths: 28 14 10 48

   * - Name
     - Offset
     - Mode
     - Description
   * - ``MB_RESETN_REG``
     - ``0x20000``
     - RW
     - MicroBlaze reset register; active-low, default 0x0 (reset active)

**Notes.** ``CmsSubsystem`` instantiates a ``Status`` sub-device at offset ``0x28000``
exposing board telemetry (voltages, currents, temperatures, fan speed) and a ``Mailbox``
sub-device that implements the CMS mailbox protocol (AMD PG348). A ``_ProxySlave``
wraps the mailbox to relay I2C-over-CMS transactions for QSFP management. Pass
``moduleType='QSFP'`` and ``numCages=2`` to enable QSFP presence, interrupt, and
low-power GPIO (``CmsLowSpeedIo``). ``AxiPcieCore`` adds a ``CmsSubsystem`` instance
named ``CmsBridge`` when ``boardType`` is ``'XilinxAlveoU55c'`` or
``'XilinxVariumC1100'``.

AxiGpuAsyncCore
---------------

``AxiGpuAsyncCore`` (subclasses ``pr.Device``; defined in :repo:`python/axipcie/_AxiGpuAsyncCore.py`) maps the GPU-Direct async data-path
registers. It controls write/read buffer counts and enables, and exposes frame counters
and DMA latency measurements for the GPU-direct bypass pipeline.

.. code-block:: python

    class AxiGpuAsyncCore(pr.Device):
        def __init__(self,
                     showBuffers   = False,
                     showErrorCnt  = False,
                     description   = 'Container for the GPUAsync core registers',
                     **kwargs):

.. list-table:: AxiGpuAsyncCore RemoteVariables and RemoteCommands
   :header-rows: 1
   :widths: 32 16 10 42

   * - Name
     - Offset
     - Mode
     - Description
   * - ``MaxBuffers``
     - ``0x00 [10:0]``
     - RO
     - Maximum DMA buffer count compiled into firmware
   * - ``AxiBusWidth``
     - ``0x04 [31:16]``
     - RO
     - AXI data bus width in bytes
   * - ``WriteCount``
     - ``0x08 [9:0]``
     - RO
     - Number of active write buffers; kernel-managed
   * - ``WriteEnable``
     - ``0x08 [15]``
     - RO
     - Write path enable; Boolean, kernel-managed
   * - ``ReadCount``
     - ``0x08 [25:16]``
     - RO
     - Number of active read buffers; kernel-managed
   * - ``ReadEnable``
     - ``0x08 [31]``
     - RO
     - Read path enable; Boolean, kernel-managed
   * - ``RxFrameCnt``
     - ``0x10``
     - RO
     - Received frame count; polled every 1 s
   * - ``TxFrameCnt``
     - ``0x14``
     - RO
     - Transmitted frame count; polled every 1 s
   * - ``WriteAxiErrorCnt``
     - ``0x18``
     - RO
     - Write AXI error count; visible when ``showErrorCnt=True``
   * - ``ReadAxiErrorCnt``
     - ``0x1C``
     - RO
     - Read AXI error count; visible when ``showErrorCnt=True``
   * - ``CountReset`` (command)
     - ``0x20``
     - WO
     - Clear all status counters plus IB/OB stream monitors
   * - ``AxisDeMuxSelect``
     - ``0x38``
     - RW
     - Stream routing: 0=CPU_path (debug), 1=GPU_path (normal operation)
   * - ``MinWriteFreeList``
     - ``0x3C``
     - RO
     - Minimum write free-list depth since last ``CountReset``
   * - ``MaxReadQueueList``
     - ``0x40``
     - RO
     - Maximum read queue depth since last ``CountReset``
   * - ``RemoteWriteMaxSize``
     - ``0x60``
     - RO
     - Configured maximum write buffer size in bytes; kernel-managed
   * - ``TotLatency``
     - ``0xC0``
     - RO
     - End-to-end latency: DMA write start to DMA read complete (axiClk cycles)
   * - ``GpuLatency``
     - ``0xD0``
     - RO
     - GPU processing latency: DMA write done to buffer returned (axiClk cycles)

**Notes.** The corresponding VHDL entity is ``AxiPcieGpuAsyncCore`` (note the ``Pcie``
infix), at ``protocol/gpuAsync/rtl/AxiPcieGpuAsyncCore.vhd``. The PyRogue class drops
the ``Pcie`` infix: ``AxiGpuAsyncCore`` != ``AxiPcieGpuAsyncCore``. Variables marked
"kernel-managed" (``WriteCount``, ``WriteEnable``, ``ReadCount``, ``ReadEnable``,
``RemoteWriteMaxSize``) are written by the ``aes-stream-drivers`` kernel module, not
userspace. Per-buffer ``RemoteWriteAddress``, ``RemoteReadAddress``, and
``RemoteReadSize`` sub-fields (``AxiGpuAsyncBuffer`` sub-devices) are visible only when
``showBuffers=True``. Each latency metric (``TotLatency``, ``GpuLatency``,
``WrDmaLatency``, ``RdDmaLatency``) also has ``*Max`` and ``*Min`` variants at
``base+0x4`` and ``base+0x8``; see the source for the full variable list.

BittWareXupVv8QsfpGpio
-----------------------

``BittWareXupVv8QsfpGpio`` (subclasses ``pr.Device``; defined in :repo:`python/axipcie/_BittWareXupVv8QsfpGpio.py`) maps the PCA9555 I/O expander
that drives QSFP presence, interrupt, low-power, and reset signals on BittWare XUP-VV8
boards (VU9P and VU13P variants). Each RemoteVariable encodes four QSFP slots using a
multi-offset packed representation.

.. code-block:: python

    class BittWareXupVv8QsfpGpio(pr.Device):
        def __init__(self, **kwargs):

.. list-table:: BittWareXupVv8QsfpGpio RemoteVariables
   :header-rows: 1
   :widths: 22 28 10 40

   * - Name
     - Offsets (slots 0-3)
     - Mode
     - Description
   * - ``QSFP_PRSNT_L``
     - ``[0x00, 0x00, 0x04, 0x04]``
     - RO
     - Module presence per slot (0=present, 1=absent)
   * - ``QSFP_INT_L``
     - ``[0x00, 0x00, 0x04, 0x04]``
     - RO
     - Interrupt active per slot (0=asserted, 1=clear)
   * - ``QSFP_LP``
     - ``[0x08, 0x08, 0x0C, 0x0C]``
     - RW
     - Low-power mode per slot (1=low-power, 0=normal)
   * - ``QSFP_RST_L``
     - ``[0x08, 0x08, 0x0C, 0x0C]``
     - RW
     - Reset per slot (0=reset asserted, 1=de-asserted)

**Notes.** Four additional pairs of hidden variables (``POL_*`` polarity inversion
registers at ``0x10``/``0x14`` and ``CFG_*`` direction configuration registers at
``0x18``/``0x1C``) are present but hidden in the PyRogue GUI. Each variable encodes one
bit per QSFP slot using pyrogue's multi-value ``offset``/``bitOffset`` list feature for
packing non-contiguous bits into a single logical variable.

TerminateQsfp
-------------

``TerminateQsfp`` (subclasses ``pr.Device``; defined in :repo:`python/axipcie/_TerminateQsfp.py`) reads the reference clock frequencies
delivered to QSFP cage transceivers. It is used on boards that share reference clocks
between the PCIe PHY and the QSFP cages.

.. code-block:: python

    class TerminateQsfp(pr.Device):
        def __init__(self, numRefClk=4, **kwargs):

.. list-table:: TerminateQsfp RemoteVariables
   :header-rows: 1
   :widths: 28 20 10 42

   * - Name
     - Offset
     - Mode
     - Description
   * - ``RefClkFreq[0..numRefClk-1]``
     - ``0x00 + 4*n``
     - RO
     - Reference clock frequency in Hz for clock ``n``; polled every 1 s

**Notes.** ``TerminateQsfp`` uses ``addRemoteVariables`` with ``number=numRefClk`` and
``stride=4`` to create an array of ``numRefClk`` frequency-readback variables. The
default is four reference clocks. Instances appear in boards that derive QSFP reference
clocks from the system 156.25 MHz oscillator.

Module Helpers
--------------

The :repo:`python/axipcie/__init__.py` package re-exports all nine device classes via
wildcard imports (``from axipcie._AxiPcieCore import *``, etc.). Two module-level
helper functions defined in ``_AxiPcieDma`` are the primary user-facing entry points
for opening hardware or simulation connections:

createAxiPcieMemMap
~~~~~~~~~~~~~~~~~~~

.. code-block:: python

    def createAxiPcieMemMap(driverPath, host='localhost', port=8000):

Opens BAR0 memory-map access to ``AxiPcieCore``. When ``driverPath != 'sim'``, opens a
``rogue.hardware.axi.AxiMemMap`` to the Linux device node at ``driverPath`` (e.g.,
``'/dev/datadev_0'``). When ``driverPath == 'sim'``, returns a
``rogue.interfaces.memory.TcpClient(host, port)`` that connects to a simulation server.
The returned object is passed as ``memBase`` to ``AxiPcieCore``.

createAxiPcieDmaStreams
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: python

    def createAxiPcieDmaStreams(driverPath, streamMap,
                                host='localhost', basePort=8000):

Opens DMA stream channels. ``streamMap`` is a ``{lane: [dest, ...]}`` dict specifying
which (lane, destination) pairs to open. When ``driverPath != 'sim'``, opens
``rogue.hardware.axi.AxiStreamDma`` for each (lane, dest) pair, encoding the channel
number as ``(0x100 * lane) | dest``. When ``driverPath == 'sim'``, opens
``rogue.interfaces.stream.TcpClient`` connections with port computed as
``(basePort + 2) + (512 * lane) + 2 * dest``. Returns a nested dict
``{lane: {dest: stream_object}}``.

These two functions are the primary integration point between the PyRogue device tree
and the ``rogue`` hardware/simulation I/O layer.
