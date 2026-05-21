RTL Entity Reference
====================

This page documents the four top-level RTL entities in ``axi-pcie-core``:
``AxiPcieCore`` (the abstract board-core role), ``AxiPcieDma`` (the DMA
engine), ``AxiPipCore`` (PCIe Intercommunication Protocol), and
``AxiGpuAsyncCore`` (GPU-Direct async data path).  Per-board concrete
realisations of ``AxiPcieCore`` (e.g., ``XilinxKcu1500Core``,
``XilinxAlveoU200Core``) are listed in the supported-boards reference;
internal surf primitives referenced below are documented in the surf library
and are not expanded here.

AxiPcieCore
-----------

Purpose
~~~~~~~

``AxiPcieCore`` is the abstract name for the per-board top-level integration
entity — the single instantiation point for a given PCIe carrier board.
Concrete realisations are ``XilinxKcu1500Core``
(:repo:`hardware/XilinxKcu1500/rtl/XilinxKcu1500Core.vhd`) and
``XilinxAlveoU200Core``
(``hardware/XilinxAlveoU200/core/XilinxAlveoU200Core.vhd``), among others.
All ``<Board>Core`` entities share the same logical port surface — DMA
AXI-Stream arrays, PIP AXI4 write masters, application AXI-Lite master pair,
and board-specific I/O; only the board I/O section differs between boards.
See :doc:`/explanation/architecture` for the structural overview and
:doc:`/explanation/board_support` for the board layering rationale.

Generics
~~~~~~~~

.. list-table:: AxiPcieCore generics (representative — XilinxKcu1500Core)
   :header-rows: 1
   :widths: 30 20 20 30

   * - Name
     - Type
     - Default
     - Description
   * - ``TPD_G``
     - ``time``
     - ``1 ns``
     - Propagation delay for simulation.
   * - ``ROGUE_SIM_EN_G``
     - ``boolean``
     - ``false``
     - When ``true``, replaces all PCIe/DMA hardware with
       ``surf.RogueTcpStreamWrap`` / ``surf.RogueTcpMemoryWrap`` TCP-socket
       stubs, enabling software co-simulation without physical hardware.
   * - ``ROGUE_SIM_PORT_NUM_G``
     - ``natural range 1024 to 49151``
     - ``8000``
     - Base TCP port number used by the rogue simulation stubs.
   * - ``ROGUE_SIM_CH_COUNT_G``
     - ``natural range 1 to 256``
     - ``256``
     - Number of virtual DMA channels exposed in simulation.
   * - ``BUILD_INFO_G``
     - ``BuildInfoType``
     - *(required)*
     - Firmware build information record (version, timestamp, git hash)
       inserted into ``AxiVersion`` registers.
   * - ``DMA_AXIS_CONFIG_G``
     - ``AxiStreamConfigType``
     - *(required)*
     - AXI-Stream bus configuration for the application-facing DMA ports.
   * - ``DMA_SIZE_G``
     - ``positive range 1 to 8``
     - ``1``
     - Number of DMA lanes.  Range 1–8 is bounded by the 10-port AXI
       crossbar in ``AxiPcieCrossbar`` (1 descriptor port + up to 8 DMA
       lanes + 1 user GP port = 10).
   * - ``DMA_BURST_BYTES_G``
     - ``positive range 256 to 4096``
     - ``256``
     - Maximum DMA burst size in bytes.
   * - ``DRIVER_TYPE_ID_G``
     - ``slv(31 downto 0)``
     - ``x"00000000"``
     - Driver-type identifier exposed in ``PcieAxiVersion`` registers.
   * - ``DATAGPU_EN_G``
     - ``boolean``
     - ``false``
     - Enables the GPU-Direct async data path (``AxiGpuAsyncCore``).

``DMA_SIZE_G`` sets the width of the DMA stream arrays ``dmaObMasters``,
``dmaObSlaves``, ``dmaIbMasters``, ``dmaIbSlaves`` at the top level.  The
maximum value of 8 is a hard constraint: the ``AxiPcieCrossbar`` wraps a
pre-built Vivado AXI Interconnect DCP from
``shared/ip/AxiPcie{16,32,64}BCrossbarIpCore/`` that supports at most 10
slave ports (1 descriptor + up to 8 DMA lanes + 1 user GP), leaving no
room for additional lanes beyond 8.

The per-board ``AXI_PCIE_CONFIG_C`` constant — defined in
``hardware/<Board>/rtl/AxiPciePkg.vhd`` — configures the shared RTL's AXI
bus width (typically 256-bit data, 64-bit address, 4-bit ID, 8-bit length).
The roadmap term "transceiverClass" maps to this constant paired with the
per-board PCIe IP variant (Gen3x8 / Gen3x16 / Gen4x8).

Ports
~~~~~

.. list-table:: AxiPcieCore ports (representative — XilinxKcu1500Core)
   :header-rows: 1
   :widths: 30 10 25 35

   * - Name
     - Dir
     - Type
     - Description
   * - **Clock / Reset (outputs)**
     -
     -
     -
   * - ``dmaClk``
     - out
     - ``sl``
     - 250 MHz DMA system clock (sourced from PCIe PHY recovered reference).
   * - ``dmaRst``
     - out
     - ``sl``
     - Synchronous reset on ``dmaClk`` domain.
   * - ``dmaBuffGrpPause``
     - out
     - ``slv(7 downto 0)``
     - Per-group buffer-full pause signals from the DMA engine.
   * - **DMA Streams (Outbound — FPGA to Host)**
     -
     -
     -
   * - ``dmaObMasters``
     - out
     - ``AxiStreamMasterArray(DMA_SIZE_G-1 downto 0)``
     - Outbound DMA stream masters (FPGA application to host).
   * - ``dmaObSlaves``
     - in
     - ``AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)``
     - Outbound DMA stream flow-control slaves.
   * - **DMA Streams (Inbound — Host to FPGA)**
     -
     -
     -
   * - ``dmaIbMasters``
     - in
     - ``AxiStreamMasterArray(DMA_SIZE_G-1 downto 0)``
     - Inbound DMA stream masters (host to FPGA application).
   * - ``dmaIbSlaves``
     - out
     - ``AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)``
     - Inbound DMA stream flow-control slaves.
   * - **PIP AXI4 Interface (dmaClk domain)**
     -
     -
     -
   * - ``pipIbMaster``
     - out
     - ``AxiWriteMasterType``
     - PIP inbound write master — peer FPGA write arriving over PCIe.
   * - ``pipIbSlave``
     - in
     - ``AxiWriteSlaveType``
     - PIP inbound write slave (application accepts writes).
   * - ``pipObMaster``
     - in
     - ``AxiWriteMasterType``
     - PIP outbound write master — local FPGA initiates write to peer.
   * - ``pipObSlave``
     - out
     - ``AxiWriteSlaveType``
     - PIP outbound write flow-control slave.
   * - **User General Purpose AXI4 (dmaClk domain)**
     -
     -
     -
   * - ``usrReadMaster``
     - in
     - ``AxiReadMasterType``
     - User GP AXI4 read master — optional application PCIe read path.
   * - ``usrReadSlave``
     - out
     - ``AxiReadSlaveType``
     - User GP AXI4 read slave.
   * - ``usrWriteMaster``
     - in
     - ``AxiWriteMasterType``
     - User GP AXI4 write master.
   * - ``usrWriteSlave``
     - out
     - ``AxiWriteSlaveType``
     - User GP AXI4 write slave.
   * - **Application AXI-Lite (appClk domain)**
     -
     -
     -
   * - ``appClk``
     - in
     - ``sl``
     - Application clock.  May differ from ``dmaClk``; decoupled via
       ``surf.AxiLiteAsync`` inside ``AxiPcieReg``.
   * - ``appRst``
     - in
     - ``sl``
     - Synchronous reset on ``appClk`` domain.
   * - ``appReadMaster``
     - out
     - ``AxiLiteReadMasterType``
     - Application-region AXI-Lite read master
       (BAR0 offset ``0x00100000``–``0x00FFFFFF``).
   * - ``appReadSlave``
     - in
     - ``AxiLiteReadSlaveType``
     - Application-region AXI-Lite read slave.
   * - ``appWriteMaster``
     - out
     - ``AxiLiteWriteMasterType``
     - Application-region AXI-Lite write master.
   * - ``appWriteSlave``
     - in
     - ``AxiLiteWriteSlaveType``
     - Application-region AXI-Lite write slave.
   * - **Board I/O (board-specific)**
     -
     -
     -
   * - ``pciRstL``
     - in
     - ``sl``
     - PCIe fundamental reset (active-low).
   * - ``pciRefClkP`` / ``pciRefClkN``
     - in
     - ``sl``
     - PCIe 100 MHz differential reference clock.
   * - ``pciRxP`` / ``pciRxN``
     - in
     - ``slv(N-1 downto 0)``
     - PCIe serial receive lanes (N = 8 or 16 depending on board).
   * - ``pciTxP`` / ``pciTxN``
     - out
     - ``slv(N-1 downto 0)``
     - PCIe serial transmit lanes.

AxiPcieDma
----------

Purpose
~~~~~~~

``AxiPcieDma`` is the board-agnostic AXI-Stream DMA engine at
:repo:`shared/rtl/AxiPcieDma.vhd`.  It wraps ``surf.AxiStreamDmaV2`` (scatter-
gather descriptor engine), an AXI4 crossbar (``AxiPcieCrossbar``), per-lane
inbound and outbound AXI-Stream FIFOs, and ``surf.AxiStreamMonAxiL`` traffic
monitors for both directions.  See :doc:`/explanation/pcie_dma_model` for the
full data-flow narrative.

Generics
~~~~~~~~

.. list-table:: AxiPcieDma generics
   :header-rows: 1
   :widths: 35 25 20 20

   * - Name
     - Type
     - Default
     - Description
   * - ``TPD_G``
     - ``time``
     - ``1 ns``
     - Propagation delay for simulation.
   * - ``ROGUE_SIM_EN_G``
     - ``boolean``
     - ``false``
     - When ``true``, replaces the PCIe crossbar and DMA core with
       ``surf.RogueTcpStreamWrap`` stubs for software co-simulation.
   * - ``ROGUE_SIM_PORT_NUM_G``
     - ``positive range 1024 to 49151``
     - ``8000``
     - Base TCP port for rogue simulation; per-lane offset is
       ``ROGUE_SIM_PORT_NUM_G + lane*512 + 2``.
   * - ``ROGUE_SIM_CH_COUNT_G``
     - ``positive range 1 to 256``
     - ``256``
     - Virtual channel count per DMA lane in simulation.
   * - ``SIMULATION_G``
     - ``boolean``
     - ``false``
     - Enables simulation-mode timing relaxations in sub-components.
   * - ``DMA_BURST_BYTES_G``
     - ``positive range 256 to 4096``
     - ``256``
     - Maximum AXI4 burst size in bytes issued by the descriptor engine.
   * - ``DMA_SIZE_G``
     - ``positive range 1 to 8``
     - ``1``
     - Number of DMA lanes.  See the constraint note below.
   * - ``DMA_AXIS_CONFIG_G``
     - ``AxiStreamConfigType``
     - ``ssiAxiStreamConfig(16)``
     - AXI-Stream configuration for the application-facing DMA ports.
   * - ``INT_PIPE_STAGES_G``
     - ``natural range 0 to 16``
     - ``1``
     - Internal pipeline stages in the IB/OB FIFOs.
   * - ``PIPE_STAGES_G``
     - ``natural range 0 to 16``
     - ``1``
     - Output pipeline stages in the IB/OB FIFOs.
   * - ``DESC_SYNTH_MODE_G``
     - ``string``
     - ``"inferred"``
     - Descriptor RAM synthesis mode passed to ``AxiStreamDmaV2``.
   * - ``DESC_MEMORY_TYPE_G``
     - ``string``
     - ``"block"``
     - Descriptor RAM memory type (``"block"`` or ``"distributed"``).
   * - ``DESC_ARB_G``
     - ``boolean``
     - ``false``
     - Descriptor arbitration policy; ``false`` = round-robin (default,
       preferred for timing).

``DMA_SIZE_G`` sets the width of the DMA stream arrays exposed at the
entity boundary.  The maximum of 8 is imposed by
``AxiPcieCrossbar``, which wraps a pre-built Vivado AXI Interconnect DCP
(``shared/ip/AxiPcie{16,32,64}BCrossbarIpCore/``) with a fixed
10-slave-port topology: 1 descriptor + up to 8 DMA lanes + 1 user GP =
10.  Instantiating more than 8 DMA lanes is not possible without a new
DCP.  The descriptor engine (``surf.AxiStreamDmaV2``) supports host
addresses up to 40 bits wide; the crossbar uses 64-bit addresses
internally (required for the GPU-Direct and PIP paths) with resizing at
the crossbar boundary.

Ports
~~~~~

.. list-table:: AxiPcieDma ports
   :header-rows: 1
   :widths: 30 10 30 30

   * - Name
     - Dir
     - Type
     - Description
   * - **Clock / Reset**
     -
     -
     -
   * - ``axiClk``
     - in
     - ``sl``
     - 250 MHz DMA system clock.
   * - ``axiRst``
     - in
     - ``sl``
     - Synchronous active-high reset.
   * - **PCIe AXI4 (axiClk domain)**
     -
     -
     -
   * - ``axiReadMaster``
     - out
     - ``AxiReadMasterType``
     - AXI4 read master to PCIe PHY (DMA host read).
   * - ``axiReadSlave``
     - in
     - ``AxiReadSlaveType``
     - AXI4 read slave from PCIe PHY.
   * - ``axiWriteMaster``
     - out
     - ``AxiWriteMasterType``
     - AXI4 write master to PCIe PHY (DMA host write).
   * - ``axiWriteSlave``
     - in
     - ``AxiWriteSlaveType``
     - AXI4 write slave from PCIe PHY.
   * - **PIP AXI4 (axiClk domain)**
     -
     -
     -
   * - ``pipObMaster``
     - in
     - ``AxiWriteMasterType``
     - PIP outbound write master (peer FPGA write, routed through
       crossbar slot 0).
   * - ``pipObSlave``
     - out
     - ``AxiWriteSlaveType``
     - PIP outbound write flow-control slave.
   * - **User GP AXI4 (axiClk domain)**
     -
     -
     -
   * - ``usrReadMaster``
     - in
     - ``AxiReadMasterType``
     - User general-purpose AXI4 read master (crossbar slot DMA_SIZE_G+1).
   * - ``usrReadSlave``
     - out
     - ``AxiReadSlaveType``
     - User GP read slave.
   * - ``usrWriteMaster``
     - in
     - ``AxiWriteMasterType``
     - User GP AXI4 write master.
   * - ``usrWriteSlave``
     - out
     - ``AxiWriteSlaveType``
     - User GP write slave.
   * - **AXI4-Lite Control (axiClk domain)**
     -
     -
     -
   * - ``axilReadMasters``
     - in
     - ``AxiLiteReadMasterArray(2 downto 0)``
     - AXI-Lite read masters: [0] DMA descriptor engine, [1] IB monitor,
       [2] OB monitor.
   * - ``axilReadSlaves``
     - out
     - ``AxiLiteReadSlaveArray(2 downto 0)``
     - AXI-Lite read slaves (same indexing).
   * - ``axilWriteMasters``
     - in
     - ``AxiLiteWriteMasterArray(2 downto 0)``
     - AXI-Lite write masters.
   * - ``axilWriteSlaves``
     - out
     - ``AxiLiteWriteSlaveArray(2 downto 0)``
     - AXI-Lite write slaves.
   * - **DMA Streams (axiClk domain)**
     -
     -
     -
   * - ``dmaIrq``
     - out
     - ``sl``
     - Level-triggered DMA interrupt; the PCIe PHY asserts MSI on the
       rising edge.
   * - ``dmaBuffGrpPause``
     - out
     - ``slv(7 downto 0)``
     - Per-group buffer-full pause from ``AxiStreamDmaV2``.
   * - ``dmaObMasters``
     - out
     - ``AxiStreamMasterArray(DMA_SIZE_G-1 downto 0)``
     - Outbound DMA stream masters (FPGA to host).
   * - ``dmaObSlaves``
     - in
     - ``AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)``
     - Outbound DMA stream flow-control slaves.
   * - ``dmaIbMasters``
     - in
     - ``AxiStreamMasterArray(DMA_SIZE_G-1 downto 0)``
     - Inbound DMA stream masters (host to FPGA).
   * - ``dmaIbSlaves``
     - out
     - ``AxiStreamSlaveArray(DMA_SIZE_G-1 downto 0)``
     - Inbound DMA stream flow-control slaves.

AxiPipCore
----------

Purpose
~~~~~~~

VHDL entity name: ``AxiPciePipCore`` (in file
:repo:`protocol/pip/rtl/AxiPciePipCore.vhd`); the PyRogue class drops the
``Pcie`` infix to ``AxiPipCore``.

``AxiPciePipCore`` implements the PCIe Intercommunication Protocol (PIP),
which allows one FPGA to write directly into a peer FPGA's address space over
PCIe without CPU involvement.  The core packetises outbound AXI-Stream frames
into 256-byte AXI4 write bursts via ``surf.AxiStreamPacketizer2`` and
reconstructs inbound AXI4 write bursts back into AXI-Stream via
``surf.AxiStreamDepacketizer2``.

Generics
~~~~~~~~

.. list-table:: AxiPciePipCore generics
   :header-rows: 1
   :widths: 30 25 20 25

   * - Name
     - Type
     - Default
     - Description
   * - ``TPD_G``
     - ``time``
     - ``1 ns``
     - Propagation delay for simulation.
   * - ``NUM_AXIS_G``
     - ``positive range 1 to 16``
     - ``1``
     - Number of independent AXI-Stream channels multiplexed over the
       single PIP AXI4 write path.
   * - ``DMA_AXIS_CONFIG_G``
     - ``AxiStreamConfigType``
     - *(required)*
     - AXI-Stream configuration for the application-facing PIP stream
       ports; must match the board ``DMA_AXIS_CONFIG_G``.

Ports
~~~~~

.. list-table:: AxiPciePipCore ports
   :header-rows: 1
   :widths: 30 10 30 30

   * - Name
     - Dir
     - Type
     - Description
   * - **AXI4-Lite Control (axilClk domain)**
     -
     -
     -
   * - ``axilClk``
     - in
     - ``sl``
     - AXI-Lite clock.
   * - ``axilRst``
     - in
     - ``sl``
     - AXI-Lite reset.
   * - ``axilReadMaster``
     - in
     - ``AxiLiteReadMasterType``
     - AXI-Lite read master for PIP control/monitoring registers.
   * - ``axilReadSlave``
     - out
     - ``AxiLiteReadSlaveType``
     - AXI-Lite read slave.
   * - ``axilWriteMaster``
     - in
     - ``AxiLiteWriteMasterType``
     - AXI-Lite write master.
   * - ``axilWriteSlave``
     - out
     - ``AxiLiteWriteSlaveType``
     - AXI-Lite write slave.
   * - ``enableTx``
     - out
     - ``slv(NUM_AXIS_G-1 downto 0)``
     - Per-channel transmit enable, controlled via AXI-Lite registers.
   * - **AXI-Stream Interface (axisClk domain)**
     -
     -
     -
   * - ``axisClk``
     - in
     - ``sl``
     - AXI-Stream clock.
   * - ``axisRst``
     - in
     - ``sl``
     - AXI-Stream reset.
   * - ``sAxisMasters``
     - in
     - ``AxiStreamMasterArray(NUM_AXIS_G-1 downto 0)``
     - Outbound stream masters (application writes to peer FPGA).
   * - ``sAxisSlaves``
     - out
     - ``AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0)``
     - Outbound stream flow-control slaves.
   * - ``mAxisMasters``
     - out
     - ``AxiStreamMasterArray(NUM_AXIS_G-1 downto 0)``
     - Inbound stream masters (data received from peer FPGA).
   * - ``mAxisSlaves``
     - in
     - ``AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0)``
     - Inbound stream flow-control slaves.
   * - **AXI4 PCIe Interface (axiClk domain)**
     -
     -
     -
   * - ``axiClk``
     - in
     - ``sl``
     - AXI4 clock (typically same as ``dmaClk``).
   * - ``axiRst``
     - in
     - ``sl``
     - AXI4 reset.
   * - ``axiReady``
     - out
     - ``sl``
     - PIP transmit-path ready status.
   * - ``sAxiWriteMaster``
     - in
     - ``AxiWriteMasterType``
     - Inbound AXI4 write master — peer FPGA write arriving from PCIe.
   * - ``sAxiWriteSlave``
     - out
     - ``AxiWriteSlaveType``
     - Inbound write flow-control slave.
   * - ``mAxiWriteMaster``
     - out
     - ``AxiWriteMasterType``
     - Outbound AXI4 write master — local FPGA write to peer over PCIe.
   * - ``mAxiWriteSlave``
     - in
     - ``AxiWriteSlaveType``
     - Outbound write flow-control slave.

AxiGpuAsyncCore
---------------

Purpose
~~~~~~~

VHDL entity name: ``AxiPcieGpuAsyncCore`` (in file
:repo:`protocol/gpuAsync/rtl/AxiPcieGpuAsyncCore.vhd`); the PyRogue class drops
the ``Pcie`` infix to ``AxiGpuAsyncCore``.

``AxiPcieGpuAsyncCore`` implements a GPU-Direct async data path that bypasses
the CPU for FPGA-to-GPU memory transfers.  It wraps
``surf.AxiStreamDmaV2Write`` and ``surf.AxiStreamDmaV2Read`` engines,
dynamically demultiplexing inbound streams between the GPU path and the
standard CPU DMA path.  An AXI-Lite register block controls path selection
and provides frame-level traffic monitoring.

Generics
~~~~~~~~

.. list-table:: AxiPcieGpuAsyncCore generics
   :header-rows: 1
   :widths: 30 30 20 20

   * - Name
     - Type
     - Default
     - Description
   * - ``TPD_G``
     - ``time``
     - ``1 ns``
     - Propagation delay for simulation.
   * - ``DEFAULT_DEMUX_SEL_G``
     - ``sl``
     - ``'1'``
     - Power-on demux routing: ``'1'`` = GPU path, ``'0'`` = CPU path.
   * - ``BURST_BYTES_G``
     - ``integer range 1 to 4096``
     - ``4096``
     - AXI4 burst size (bytes) for DMA write and read engines.
   * - ``DMA_AXIS_CONFIG_G``
     - ``AxiStreamConfigType``
     - *(required)*
     - AXI-Stream configuration for the application-facing stream ports.

Ports
~~~~~

.. list-table:: AxiPcieGpuAsyncCore ports
   :header-rows: 1
   :widths: 30 10 30 30

   * - Name
     - Dir
     - Type
     - Description
   * - **AXI4-Lite Control (axilClk domain)**
     -
     -
     -
   * - ``axilClk``
     - in
     - ``sl``
     - AXI-Lite clock.
   * - ``axilRst``
     - in
     - ``sl``
     - AXI-Lite reset.
   * - ``axilReadMaster``
     - in
     - ``AxiLiteReadMasterType``
     - AXI-Lite read master for GPU async control registers.
   * - ``axilReadSlave``
     - out
     - ``AxiLiteReadSlaveType``
     - AXI-Lite read slave.
   * - ``axilWriteMaster``
     - in
     - ``AxiLiteWriteMasterType``
     - AXI-Lite write master.
   * - ``axilWriteSlave``
     - out
     - ``AxiLiteWriteSlaveType``
     - AXI-Lite write slave.
   * - **AXI-Stream Interface (axisClk domain)**
     -
     -
     -
   * - ``axisClk``
     - in
     - ``sl``
     - AXI-Stream clock.
   * - ``axisRst``
     - in
     - ``sl``
     - AXI-Stream reset.
   * - ``sAxisMaster``
     - in
     - ``AxiStreamMasterType``
     - Inbound stream from application (GPU write source).
   * - ``sAxisSlave``
     - out
     - ``AxiStreamSlaveType``
     - Inbound stream flow-control slave.
   * - ``mAxisMaster``
     - out
     - ``AxiStreamMasterType``
     - Outbound stream to application (GPU read destination).
   * - ``mAxisSlave``
     - in
     - ``AxiStreamSlaveType``
     - Outbound stream flow-control slave.
   * - ``bypassMaster``
     - out
     - ``AxiStreamMasterType``
     - CPU bypass stream — frames routed to CPU DMA path when demux
       selects ``'0'``.
   * - ``bypassSlave``
     - in
     - ``AxiStreamSlaveType``
     - Bypass stream flow-control slave.
   * - **AXI4 PCIe Interface (axiClk domain)**
     -
     -
     -
   * - ``axiClk``
     - in
     - ``sl``
     - AXI4 clock (typically same as ``dmaClk``).
   * - ``axiRst``
     - in
     - ``sl``
     - AXI4 reset.
   * - ``axiWriteMaster``
     - out
     - ``AxiWriteMasterType``
     - AXI4 write master to PCIe host memory (GPU write path).
   * - ``axiWriteSlave``
     - in
     - ``AxiWriteSlaveType``
     - AXI4 write slave.
   * - ``axiReadMaster``
     - out
     - ``AxiReadMasterType``
     - AXI4 read master from PCIe host memory (GPU read path).
   * - ``axiReadSlave``
     - in
     - ``AxiReadSlaveType``
     - AXI4 read slave.
