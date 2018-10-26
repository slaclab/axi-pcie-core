#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : KCU1500 Prom Update
#-----------------------------------------------------------------------------
# File       : updateKcu1500.py
# Created    : 2018-06-22
#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'axi-pcie-core', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import sys
import glob
import argparse
import pyrogue as pr
import rogue.hardware.axi
import axipcie as pcie
from collections import OrderedDict as odict
    
# Set the argument parser
parser = argparse.ArgumentParser()

# Add arguments
parser.add_argument(
    "--dev", 
    type     = str,
    required = False,
    default  = "/dev/datadev_0",
    help     = "path to device",
)  

parser.add_argument(
    "--path", 
    type     = str,
    required = True,
    help     = "path to images",
)  

# Get the arguments
args = parser.parse_args()
    
# Set base
base = pr.Root(name='PcieTop',description='')

# Create the stream interface
memMap = rogue.hardware.axi.AxiMemMap(args.dev)

# Add Base Device
base.add(pcie.AxiPcieCore(memBase=memMap,useSpi=True))

# Start the system
base.start(pollEn=False)

# Create useful pointers
AxiVersion = base.AxiPcieCore.AxiVersion
PROM_PRI   = base.AxiPcieCore.AxiMicronN25Q[0]
PROM_SEC   = base.AxiPcieCore.AxiMicronN25Q[1]

# Printout Current AxiVersion status
print('#########################################')
print('Current Firmware Loaded on the PCIe card:')
print('#########################################')
AxiVersion.printStatus()
print('#########################################')

# Get a list of images, using .mcs first
imgLst = odict()

rawLst = glob.glob('{}/*.mcs*'.format(args.path))
for l in rawLst:

    # Determine suffix
    if '.mcs.gz' in l:
        suff = 'mcs.gz'
    else:
        suff = 'mcs'

    # Get basename
    l = l.replace('_primary.mcs.gz','')
    l = l.replace('_secondary.mcs.gz','')
    l = l.replace('_primary.mcs','')
    l = l.replace('_secondary.mcs','')

    # Store entry
    imgLst[l] = suff

# Sort list
imgLst = odict(sorted(imgLst.items(), key=lambda x: x[0]))

for i,l in enumerate(imgLst.items()):
    print('{} : {}'.format(i,l[0]))

idx = int(input('Enter image to program into the PCIe card\'s PROM: '))

ent = list(imgLst.items())[idx]
pri = ent[0] + '_primary.' + ent[1]
sec = ent[0] + '_seconday.' + ent[1]

# Load the primary MCS file to QSPI[0]
print('Loading primary image: {}'.format(pri))
PROM_PRI.LoadMcsFile(pri)  

# Load the secondary MCS file to QSPI[1]
print('Loading secondary image: {}'.format(sec))
PROM_SEC.LoadMcsFile(sec)  

if(PROM_PRI._progDone and PROM_SEC._progDone):
    print('\nReloading FPGA firmware from PROM ....')
    AxiVersion.FpgaReload()
    print('\nPlease reboot the computer')
else:
    print('Failed to program FPGA')
    
# Close out
base.stop()
exit()
