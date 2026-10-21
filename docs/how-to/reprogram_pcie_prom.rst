Reprogram the PCIe Card PROM
============================

**Goal:** Write a new firmware image into the boot PROM of an ``axi-pcie-core``
based PCIe card, reload the FPGA, and bring the endpoint back on the PCIe bus
without rebooting the host.

Two scripts cover this flow:

- :repo:`scripts/updatePcieFpga` programs the PROM over BAR0, triggers an FPGA
  reload, and then re-enumerates the card.
- :repo:`scripts/rescanPcieFpga.sh` is a standalone recovery tool for an
  endpoint whose PCIe link was already lost (for example, after a reload done
  outside ``updatePcieFpga``).

Prerequisites
-------------

- The ``aes-stream-drivers`` ``datadev`` kernel driver is loaded and the card
  appears as ``/dev/datadev_<N>`` with a matching ``/proc/datadev_<N>`` entry.
- For the automatic post-reload rescan, the driver must be
  ``aes-stream-drivers`` v6.7.1 or later. Older drivers do not report the
  ``PCIe[BUS:NUM:SLOT.FUNC]`` line in ``/proc/datadev_<N>``, so the rescan is
  skipped and a reboot is required instead.
- Root access (``sudo``) when the rescan is enabled, because it writes to
  ``/sys/bus/pci``.
- A directory of PROM images (``.mcs`` or ``.mcs.gz``) built for this card.

Install the Tool
----------------

**Debian package (recommended for operators):** each ``vX.Y.Z`` release
attaches ``fpga-pcie-reprogram-vX.Y.Z_amd64.deb``, a self-contained build of
:repo:`scripts/updatePcieFpga` with its rogue, pyrogue, ``axipcie``, and
``surf`` runtime (see :doc:`/how-to/release_flow`).

.. code-block:: bash

   sudo dpkg -i fpga-pcie-reprogram-vX.Y.Z_amd64.deb

The package installs to ``/opt/fpga-pcie-reprogram`` and provides the
``/usr/local/bin/fpga-pcie-reprogram`` launcher, which forwards all arguments
to ``updatePcieFpga``.

**From a source checkout:** run the script with a Python environment that has
``rogue`` installed. If ``axipcie`` is not importable, the script falls back to
``../python`` and ``../../surf/python`` relative to ``scripts/``, which matches
the standard layout where ``axi-pcie-core`` and ``surf`` are sibling
submodules.

Prepare the Image Directory
---------------------------

The file naming depends on the card's boot PROM type, which the script reads
from the ``BOOT_PROM_G`` register in ``AxiVersion`` (offset ``0x414``):

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - PROM type
     - Required files per image
   * - ``BPI``
     - ``<Image>.mcs`` or ``<Image>.mcs.gz``
   * - ``SPIx4``
     - ``<Image>.mcs`` or ``<Image>.mcs.gz``
   * - ``SPIx8``
     - ``<Image>_primary.mcs[.gz]`` and ``<Image>_secondary.mcs[.gz]``

Each image appears once in the selection menu, with the ``_primary`` and
``_secondary`` suffixes stripped. Keep only one format (``.mcs`` or
``.mcs.gz``) per image in the directory so the menu entry maps to a single
file set.

Run the Update
--------------

Debian package:

.. code-block:: bash

   sudo fpga-pcie-reprogram --dev /dev/datadev_0 --path /path/to/images

Source checkout (``sudo`` does not inherit your conda environment, so pass the
interpreter explicitly):

.. code-block:: bash

   sudo $(which python) scripts/updatePcieFpga --dev /dev/datadev_0 --path /path/to/images

The script then:

1. Prints the ``AxiVersion`` status of the firmware currently loaded.
2. Lists the images in ``--path`` in reverse alphabetical order (newest first
   for date-stamped image names), followed by an ``Exit`` entry.
3. Prompts for an image number. An empty line, the ``Exit`` entry, or an
   out-of-range number programs nothing. Non-numeric input re-prompts.
4. If the selected image name does not start with the currently loaded
   ``ImageName``, asks ``Are you sure? (y/n)``. Any answer other than ``y``
   returns to the image list.
5. Programs the PROM (both PROMs for ``SPIx8``) and calls
   ``AxiVersion.FpgaReload()``.
6. Re-enumerates the card (see :ref:`rescan-sequence`) and prints the
   ``AxiVersion`` status of the newly loaded firmware.

If programming fails, the script raises ``Failed to program FPGA`` and does
not reload the FPGA, so the card keeps running its current image.

.. note::

   On a card with more than one PCIe endpoint, only the primary endpoint
   reports a defined ``BOOT_PROM_G``. Pointing ``--dev`` at a secondary
   endpoint stops with ``No PROM type detected!!!``. Use the primary
   ``/dev/datadev_<N>`` for that card instead.

Command-Line Options
--------------------

.. list-table::
   :header-rows: 1
   :widths: 25 20 55

   * - Option
     - Default
     - Description
   * - ``--dev``
     - ``/dev/datadev_0``
     - Device node of the card's primary PCIe endpoint.
   * - ``--path``
     - none
     - Directory containing the ``.mcs`` / ``.mcs.gz`` images.
   * - ``--package``
     - none
     - Importable Python module that defines ``ImageDir``. Overrides
       ``--path`` with that module's ``ImageDir``.
   * - ``--rescan``
     - ``true``
     - Re-enumerate the card after the FPGA reload. Takes a value:
       ``true``/``t``/``yes``/``1`` enable it, anything else disables it.
       With ``--rescan false`` the script does not require root and ends by
       asking for a reboot.
   * - ``--bypass_reprogramming``
     - ``false``
     - Debug only. Skips image selection and PROM programming, and only
       runs ``FpgaReload()`` plus the rescan. Useful for testing the rescan
       path quickly.

.. _rescan-sequence:

Post-Reload Rescan
------------------

``FpgaReload()`` drops the PCIe link while the FPGA reconfigures. With
``--rescan true`` and a driver that reports the PCIe address, the script
recovers the card without a reboot:

1. Records the ``/dev/datadev*`` list before opening the card.
2. After the reload, waits up to 30 s for that device list to come back. On
   hosts with hotplug-capable slots (for example behind a PCIe switch running
   ``pciehp``), the kernel removes and re-adds the endpoint on its own during
   this window.
3. For every ``datadev`` whose ``/proc`` entry shows
   ``Up Time Count`` of ``4294967295`` (all ones, meaning BAR reads are
   failing), unbinds the driver, removes the device from the PCI bus, and
   rescans the bus through ``/sys/bus/pci``, then waits for the ``/dev`` node
   to return.
4. Waits again for the full device list if any manual rescan ran.
5. Reopens ``--dev`` and prints the new ``AxiVersion`` status.

The script exits non-zero and asks for a reboot if a device node does not
return, if ``--dev`` cannot be read after the reload, or if the device list
after the rescan differs from the list before it.

Recover a Lost PCIe Link
------------------------

If ``/proc/datadev_<N>`` already shows ``Up Time Count`` of ``4294967295``
when ``updatePcieFpga`` starts, the script refuses to program the card
(``Unable to reprogram FPGA as lost of PCIe link``) and points to
:repo:`scripts/rescanPcieFpga.sh`. Run it as root with the device node:

.. code-block:: bash

   sudo scripts/rescanPcieFpga.sh /dev/datadev_0

The script reads the ``PCIe[BUS:NUM:SLOT.FUNC]`` address from
``/proc/datadev_0``, then unbinds the driver, removes the device, and rescans
the PCI bus, with a 1 s pause between steps. It requires the same
``aes-stream-drivers`` v6.7.1 or later as the automatic rescan.

``rescanPcieFpga.sh`` discards errors from the ``sysfs`` writes and does not
verify the result, so confirm recovery afterwards:

.. code-block:: bash

   cat /proc/datadev_0

A sane ``Up Time Count`` means the link is back. If the endpoint does not
return, reboot the host.

.. note::

   The Debian package installs only ``updatePcieFpga``. Use
   ``rescanPcieFpga.sh`` from a source checkout of ``axi-pcie-core``.

Troubleshooting
---------------

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Message
     - Meaning and action
   * - ``This script must be run as root (sudo).``
     - The rescan is enabled and needs ``/sys/bus/pci`` access. Rerun with
       ``sudo`` or pass ``--rescan false`` and reboot afterwards.
   * - ``Programming (.mcs, .mcs.gz) files NOT detected``
     - ``--path`` has no image files, or root cannot read them. Check with
       ``sudo ls -lath <path>``.
   * - ``No PROM type detected!!!``
     - ``--dev`` is not the card's primary endpoint. Use the primary one.
   * - ``Unable to do rescan due to older driver``
     - The driver predates v6.7.1. The PROM was still programmed; reboot to
       load the new firmware, and update ``aes-stream-drivers``.
   * - ``Mismatch between list of datadev devices before and after rescan``
     - A device did not re-enumerate within the timeout. The new firmware
       status is still printed above this warning. Reboot the host.
