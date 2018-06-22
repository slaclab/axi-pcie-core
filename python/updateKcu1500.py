#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : KCU1500 Prom Update
#-----------------------------------------------------------------------------
# File       : updateKcu1500.py
# Created    : 2018-06-22
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import sys
import argparse
import pyrogue as pr
from axipcie import AxiPcieCore
import glob
    
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
progTop = pr.Root(name='progTop',description='')

# Create the stream interface
coreMap = rogue.hardware.axi.AxiMemMap(args.dev)

# Add Base Device
progTop.add(AxiPcieCore(memBase=coreMap,useSpi=True))

# Start the system
progTop.start(pollEn=False)

# Get a list of images
outLst = []
inLst = glob.glob('{}/*.mcs'.format(args.path))
for l in inLst:
    l = l.replace('_primary.mcs','')
    l = l.replace('_secondary.mcs','')
    if not l in outLst:
        outLst.append(l)

for i,l in enumerate(outLst):
    print('{} : {}'.format(i,l))

idx = int(input('Enter image: '))
pri = '{}_primary.mcs'.format(outLst[idx])
sec = '{}_secondary.mcs'.format(outLst[idx])

print('Loading primary image: {}'.format(pri))
progTop.AxiPcieCore.AxiMicronN25Q[0].LoadMcsFile(pri)  

print('Loading secondary image: {}'.format(sec))
progTop.AxiPcieCore.AxiMicronN25Q[1].LoadMcsFile(sec)  

# Close out
devTop.stop()
exit()

