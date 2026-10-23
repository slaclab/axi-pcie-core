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

# Enforce script to be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run using sudo or root." >&2
  exit 1
fi

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

# Once the endpoint is removed its upstream bridge has no children, so runtime
# PM suspends the bridge to D3 and its link stays down; a bus rescan does not
# wake it. Keep the bridge in D0 until the endpoint is back.
BRIDGE=$(basename "$(dirname "$(readlink -f "/sys/bus/pci/devices/$PCI_ADDR")")")
BRIDGE_PM="/sys/bus/pci/devices/$BRIDGE/power/control"
BRIDGE_PM_ORIG=""
if [ -w "$BRIDGE_PM" ]; then
  BRIDGE_PM_ORIG=$(cat "$BRIDGE_PM")
  echo on > "$BRIDGE_PM"
  echo "[INFO] Holding upstream bridge $BRIDGE awake (power/control was '$BRIDGE_PM_ORIG')"
fi

echo "[INFO] Unbinding $PCI_ADDR..."
echo "$PCI_ADDR" > "/sys/bus/pci/devices/$PCI_ADDR/driver/unbind" 2>/dev/null

sleep 1

echo "[INFO] Removing $PCI_ADDR from PCI bus..."
echo 1 > "/sys/bus/pci/devices/$PCI_ADDR/remove" 2>/dev/null

sleep 1

echo "[INFO] Rescanning PCI bus..."
echo 1 > /sys/bus/pci/rescan 2>/dev/null

# Wait up to 30 s for the device node, rescanning again every 5 s
for i in $(seq 1 60); do
  [ -e "$1" ] && break
  if [ $((i % 10)) -eq 0 ]; then
    echo 1 > /sys/bus/pci/rescan 2>/dev/null
  fi
  sleep 0.5
done

if [ ! -e "$1" ]; then
  # Leave the bridge awake so a later manual rescan can still find the endpoint
  echo "[WARNING] $1 did not return after rescan. Try again with: sudo sh -c 'echo 1 > /sys/bus/pci/rescan'"
  exit 1
fi

if [ -n "$BRIDGE_PM_ORIG" ]; then
  echo "$BRIDGE_PM_ORIG" > "$BRIDGE_PM"
fi

echo "[INFO] PCIe reset sequence completed."
