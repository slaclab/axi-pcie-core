#!/bin/bash
#-----------------------------------------------------------------------------
# Company    : SLAC National Accelerator Laboratory
#-----------------------------------------------------------------------------
#  Description: PCIe Device Reinitialization Script
#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

# Check if device path argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 /dev/datadev_0"
  exit 1
fi

# Validate that the provided device path exists
if [ ! -e "$1" ]; then
  echo "Error: Device path '$1' does not exist."
  exit 1
fi

# Extract context name (e.g., datadev_0)
context=$(basename "$1")

# Construct the corresponding /proc path
proc_path="/proc/${context}"

# Check if the /proc file exists
if [ ! -f "$proc_path" ]; then
  echo "Error: Corresponding /proc entry '$proc_path' does not exist."
  exit 1
fi

# Extract the PCIe address
PCI_ADDR=$(grep "PCIe\[BUS:NUM:SLOT.FUNC\]" "$proc_path" | awk '{print $NF}')

# Check if the pattern was found
if [ -z "$PCI_ADDR" ]; then
  echo "Error: PCIe[BUS:NUM:SLOT.FUNC] was not detected in the output of cat $proc_path"
  exit 1
fi

echo "[INFO] Unbinding $PCI_ADDR..."
echo "$PCI_ADDR" > "/sys/bus/pci/devices/$PCI_ADDR/driver/unbind" 2>/dev/null

sleep 1

echo "[INFO] Removing $PCI_ADDR from PCI bus..."
echo 1 > "/sys/bus/pci/devices/$PCI_ADDR/remove" 2>/dev/null

sleep 1

echo "[INFO] Rescanning PCI bus..."
echo 1 > /sys/bus/pci/rescan 2>/dev/null

echo "[INFO] PCIe reset sequence completed."
