Use the PyRogue Device Tree
===========================

This guide shows how to open the ``axi-pcie-core`` BAR0 register map, configure
DMA channels, instantiate the device tree, and read firmware build information
from ``PcieAxiVersion``.

For per-class API details, see :doc:`/reference/pyrogue_api`.  For the
register-tree concept and BAR0 crossbar layout, see
:doc:`/explanation/architecture`.

Open the BAR0 Memory Map
------------------------

``createAxiPcieMemMap`` (defined in :repo:`python/axipcie/_AxiPcieDma.py`)
opens BAR0 access to the PCIe register space.  On real hardware, pass the
Linux device-node path:

.. code-block:: python

    import axipcie as pcie

    # Real hardware: opens rogue.hardware.axi.AxiMemMap to /dev/data_dev0
    memMap = pcie.createAxiPcieMemMap('/dev/data_dev0')

The function signature is:

.. code-block:: python

    def createAxiPcieMemMap(driverPath, host='localhost', port=8000):

When ``driverPath != 'sim'``, the function opens and returns a
``rogue.hardware.axi.AxiMemMap`` backed by the Linux device node at
``driverPath``.  Pass ``memMap`` as the ``memBase`` argument to
``AxiPcieCore`` (or any ``pr.Device`` subclass that maps the BAR0 space).

Configure DMA Streams
---------------------

``createAxiPcieDmaStreams`` (defined in :repo:`python/axipcie/_AxiPcieDma.py`)
opens DMA stream channels for one or more (lane, destination) pairs:

.. code-block:: python

    # Open lane 0, destinations 0 and 1
    dmaStreams = pcie.createAxiPcieDmaStreams(
        '/dev/data_dev0',
        streamMap={0: [0, 1]},
    )

    # dmaStreams[0][0] is a rogue.hardware.axi.AxiStreamDma instance
    stream = dmaStreams[0][0]

The function signature is:

.. code-block:: python

    def createAxiPcieDmaStreams(driverPath, streamMap, host='localhost', basePort=8000):

``streamMap`` is a ``{lane: [dest, ...]}`` dict specifying which (lane,
destination) pairs to open.  When ``driverPath != 'sim'``, each channel is
backed by ``rogue.hardware.axi.AxiStreamDma`` with channel number encoded as
``(0x100 * lane) | dest``.  The returned value is a nested
``defaultdict(dict)`` keyed as ``dmaStreams[lane][dest]``.

Instantiate ``AxiPcieRoot`` and Start the Tree
-----------------------------------------------

For simple single-device use cases, ``AxiPcieRoot``
(:repo:`python/axipcie/_AxiPcieRoot.py`) is a convenience wrapper that opens
BAR0 internally and instantiates ``AxiPcieCore`` at the top of the device tree:

.. code-block:: python

    import axipcie as pcie

    root = pcie.AxiPcieRoot(dev='/dev/data_dev0', name='PCIeDevice')
    root.start()

For production projects that need to wire DMA streams alongside the register
tree, build a custom ``pr.Root`` subclass using the helpers above:

.. code-block:: python

    import pyrogue as pr
    import axipcie as pcie

    memMap = pcie.createAxiPcieMemMap('/dev/data_dev0')
    dmaStreams = pcie.createAxiPcieDmaStreams(
        '/dev/data_dev0',
        streamMap={0: [0, 1]},
    )

    class MyRoot(pr.Root):
        def __init__(self, memMap, **kwargs):
            super().__init__(**kwargs)
            self.add(pcie.AxiPcieCore(
                memBase     = memMap,
                numDmaLanes = 1,
            ))

    root = MyRoot(memMap=memMap, name='PCIeDevice')
    root.start()

    # dmaStreams[0][0] and dmaStreams[0][1] are now ready for use

Read ``PcieAxiVersion`` Build Info
------------------------------------

After ``root.start()``, access ``PcieAxiVersion`` registers through the device
tree.  ``AxiPcieCore`` instantiates ``PcieAxiVersion`` as a sub-device named
``AxiVersion`` at BAR0 offset ``0x20000``.  ``PcieAxiVersion`` extends
``surf.axi.AxiVersion``, inheriting ``UpTimeCnt`` and ``BuildStamp`` from the
parent class:

.. code-block:: python

    av = root.AxiPcieCore.AxiVersion

    # Seconds since last power-on or reset (from surf.axi.AxiVersion)
    uptime = av.UpTimeCnt.get()
    print(f'Uptime: {uptime} s')

    # Null-terminated ASCII build-stamp string: date, git hash, user
    stamp = av.BuildStamp.get()
    print(f'BuildStamp: {stamp}')

    # PCIe-specific: board hardware type (from PcieAxiVersion)
    hw_type = av.PCIE_HW_TYPE_G.getDisp()
    print(f'Board type: {hw_type}')

When using ``AxiPcieRoot`` directly, the same path applies:
``root.AxiPcieCore.AxiVersion.UpTimeCnt.get()``.  For the full list of
``PcieAxiVersion`` register fields, see :doc:`/reference/pyrogue_api`.

Simulation: ``driverPath='sim'``
---------------------------------

Pass the literal string ``'sim'`` as ``driverPath`` to switch both helpers to
TCP socket back-ends, allowing software co-simulation against a VHDL testbench
or rogue simulation server without physical hardware:

.. code-block:: python

    # Simulation back-ends: TCP sockets instead of /dev/* nodes
    memMap = pcie.createAxiPcieMemMap('sim', host='localhost', port=8000)
    dmaStreams = pcie.createAxiPcieDmaStreams(
        'sim',
        streamMap={0: [0]},
        host='localhost',
        basePort=8000,
    )

``createAxiPcieMemMap('sim', ...)`` returns a
``rogue.interfaces.memory.TcpClient(host, port)``.

``createAxiPcieDmaStreams('sim', ...)`` returns
``rogue.interfaces.stream.TcpClient`` connections; the port for each
(lane, dest) pair is computed as
``(basePort + 2) + (512 * lane) + 2 * dest``.

The firmware-side TCP server is started by enabling
``ROGUE_SIM_EN_G => true`` in the ``<Board>Core`` generics and setting
``ROGUE_SIM_PORT_NUM_G`` to match ``basePort``.  The ``host`` and ``port``
defaults (``'localhost'``, ``8000``) match the firmware defaults.

See Also
--------

* :doc:`/reference/pyrogue_api` — per-class details for ``AxiPcieCore``,
  ``AxiPcieRoot``, ``PcieAxiVersion``, and the module-level helper functions.
* :doc:`/explanation/architecture` — register-tree concept and BAR0 crossbar
  layout that the device tree maps to.
* :doc:`/reference/register_map` — BAR0 offsets for all ``PcieAxiVersion``
  fields, including the ``UpTimeCnt`` and ``BuildStamp`` registers inherited
  from ``surf.axi.AxiVersion``.
