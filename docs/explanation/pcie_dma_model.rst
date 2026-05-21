PCIe DMA Model
==============

This page explains how ``axi-pcie-core`` moves data between host memory and
the FPGA application over PCIe.  The central entity is ``AxiPcieDma``, which
wraps surf's ``AxiStreamDmaV2`` engine and presents per-lane AXI-Stream
interfaces to the application.

Inbound and Outbound FIFOs
--------------------------

**Inbound (IB)** refers to data flowing from the host into the FPGA
application.  **Outbound (OB)** refers to data flowing from the FPGA
application back to the host.

``AxiPcieDma`` instantiates one ``AxiStreamDmaV2`` lane for each DMA channel.
Each lane contains a dedicated IB FIFO (host → FPGA application) and a
dedicated OB FIFO (FPGA application → host).  The number of lanes is set by
the ``DMA_SIZE_G`` generic (maximum 8), which is bounded by the
``AxiPcieCrossbar`` slave-port budget: the crossbar provides 10 AXI4 slave
ports — one descriptor port, up to eight DMA lane ports, and one user
general-purpose port.

Descriptor Rings
----------------

Each ``AxiStreamDmaV2`` lane uses a descriptor ring: a host-resident circular
buffer whose entries each point to a host DMA buffer (physical address + byte
count).  The DMA engine fetches descriptors from the ring over PCIe using the
descriptor AXI4 slave port on ``AxiPcieCrossbar``.  After the transfer
completes, the engine writes a completion status word back to the descriptor
entry, signalling the driver that the buffer is ready.

The descriptor address space is at most 40 bits wide, even though the internal
AXI4 bus uses 64-bit addresses (``ADDR_WIDTH_C = 64`` in ``AXI_PCIE_CONFIG_C``).
This 40-bit limit is an architectural constraint of ``AxiStreamDmaV2``;
software must ensure descriptor ring memory is allocated within the low 1 TB
of host physical address space.

Back-Pressure via tReady
------------------------

``tReady`` is the AXI-Stream handshake signal asserted by a slave to accept a
data beat from its upstream master.  When a downstream application sink
de-asserts ``tReady`` it stalls ``AxiStreamDmaV2`` IB delivery on that lane,
which in turn stalls ``AxiPcieDma``, and ultimately stalls PCIe completion
scheduling for that DMA channel.  Conversely, when an application source has
no data to send it simply de-asserts ``tValid``; this produces no OB beats and
does not affect other lanes.

This is the canonical SLAC AXI-Stream back-pressure model: the FPGA
application must keep its IB sink draining fast enough to absorb the expected
PCIe throughput, or it must accept that the IB FIFO will fill and PCIe
transfers will stall on that lane.  Per-lane IB/OB traffic monitors (accessible
at BAR0 offsets ``0x0006_0000`` and ``0x0006_8000``) can be used to observe
stall conditions.

DMA IRQ Flow
------------

When ``AxiStreamDmaV2`` completes one or more transfers it asserts the
``dmaIrq`` output of ``AxiPcieDma``.  ``AxiPcieUltrascalePlusIrqFsm``
receives this level-sensitive signal and converts it to a rising-edge MSI
request for the PCIe PHY IP (``usrIrqReq``).  The FSM waits for the PHY's
``usrIrqAck`` handshake before de-asserting the request and returning to
idle.  This ensures that a new interrupt cannot collide with one that is still
being serviced.

The PCIe PHY delivers the MSI to the host.  The host driver (PyRogue /
``rogue.hardware.axi.AxiStreamDma``) handles the interrupt, reads the
completion status words from the descriptor ring, recycles completed
descriptors, and schedules new transfers.

End-to-End Data-Flow Diagram
----------------------------

The diagram below traces both the IB path (host → FPGA application) and the
OB path (FPGA application → host), including the descriptor and IRQ paths:

.. code-block:: text

    Host (DMA buffers + descriptor ring in host physical memory)
      |
      |  PCIe lanes (Gen3 x16 or Gen4 x8, board-dependent)
      |
      v
    PCIe PHY (per-board .dcp wrapper, 250 MHz recovered clock)
      |
      |  AXI4 (256-bit data, 64-bit addr, ID_BITS=4)
      |
      v
    AxiPcieCrossbar  (DMA_SIZE_G + 2 slaves -> 1 master -> PCIe PHY)
      |
      +---> AxiPcieReg  (register path -> BAR0 AXI-Lite slaves)
      |
      +---> AxiPcieDma  (AxiStreamDmaV2 engine, DMA_SIZE_G lanes)
               |
               |  IB path (host -> FPGA application)
               +--- IB FIFO 0 --> appAxisMasters[0]  -> application lane 0
               +--- IB FIFO 1 --> appAxisMasters[1]  -> application lane 1
               +--- ...
               +--- IB FIFO N --> appAxisMasters[N]  -> application lane N
               |
               |  OB path (FPGA application -> host)
               +--- OB FIFO 0 <-- appAxisSlaves[0]   <- application lane 0
               +--- OB FIFO 1 <-- appAxisSlaves[1]   <- application lane 1
               +--- ...
               +--- OB FIFO N <-- appAxisSlaves[N]   <- application lane N
               |
               |  Descriptor path (one AXI4 slave port on AxiPcieCrossbar)
               +--- descriptor read/write <-> host descriptor ring (<=40-bit addr)
               |
               |  IRQ path
               +--- dmaIrq -> AxiPcieUltrascalePlusIrqFsm -> usrIrqReq (MSI)
                                                                  |
                                                                  v
                                                            PCIe PHY -> host MSI
