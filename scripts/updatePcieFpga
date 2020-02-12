#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : BPI/SPIx4/SPIx8 Prom Update
#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'axi-pcie-core', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr
import os
import importlib

baseDir = os.path.dirname(os.path.realpath(__file__))

print(f"Basedir = {baseDir}")

# First see if surf and axipcie are already in the python path
try:
    import surf
    import axipcie

# Otherwise assume it is relative in a standard development directory structure
except:
    pr.addLibraryPath(baseDir + '/../python')
    pr.addLibraryPath(baseDir + '/../../surf/python')

import sys
import glob
import argparse
import rogue.hardware.axi
import axipcie as pcie
from collections import OrderedDict as odict

if __name__ == "__main__": 

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
        "--package", 
        type     = str,
        default  = None,
        required = False,
        help     = "path to images",
    )  

    parser.add_argument(
        "--path", 
        type     = str,
        default  = None,
        required = False,
        help     = "path to images",
    )  

    parser.add_argument(
        "--type", 
        type     = str,
        default  = None,
        required = False,
        help     = "prom type",
    )  

    # Get the arguments
    args = parser.parse_args()

    if args.package is not None:
        BasePackage = importlib.import_module(args.package)
        args.path = BasePackage.ImageDir

    if args.path is None:
        print("\nInvalid images directory, use --path or --package args\n")
        parser.print_help()
        exit()

    # Set base
    base = pr.Root(name='PcieTop',description='',pollEn=False)

    # Create the stream interface
    memMap = rogue.hardware.axi.AxiMemMap(args.dev)

    # Add Base Device
    base.add(pcie.AxiPcieCore(
        memBase = memMap,
        useBpi  = True,
        useSpi  = True,
    ))

    # Start the system
    base.start()

    # Read all the variables
    base.ReadAll()

    # Create useful pointers
    AxiVersion = base.AxiPcieCore.AxiVersion

    if args.type is None:
        promType   = AxiVersion.BOOT_PROM_G.getDisp()
    else:
        promType   = args.type

    # Case on PROM type
    if (promType == 'BPI'):
        PROM_PRI = base.AxiPcieCore.AxiMicronP30
    elif (promType == 'SPIx8') or (promType == 'SPIx4'):
        PROM_PRI = base.AxiPcieCore.AxiMicronN25Q[0]
        if (promType == 'SPIx8'):
            PROM_SEC = base.AxiPcieCore.AxiMicronN25Q[1]
    else:
        raise ValueError('Invalid promType')

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
        l = l.replace('.mcs.gz','')    
        l = l.replace('.mcs','')

        # Store entry
        imgLst[l] = suff

    # Sort list
    imgLst = odict(sorted(imgLst.items(), key=lambda x: x[0]))

    for i,l in enumerate(imgLst.items()):
        print('{} : {}'.format(i,l[0]))

    idx = int(input('Enter image to program into the PCIe card\'s PROM: '))

    ent = list(imgLst.items())[idx]
    if (promType == 'SPIx8'):
        pri = ent[0] + '_primary.' + ent[1]
        sec = ent[0] + '_secondary.' + ent[1]
    else:
        pri = ent[0] + '.' + ent[1]
        
    # Load the primary MCS file
    PROM_PRI.LoadMcsFile(pri)  

    # Update the programing done flag
    progDone = PROM_PRI._progDone

    # Check for secondary PROM
    if (promType == 'SPIx8'):
        # Check if the primary MCS failed
        if PROM_PRI._progDone: 
            # Load the secondary MCS file
            PROM_SEC.LoadMcsFile(sec)  
        # Update the programing done flag
        progDone = PROM_PRI._progDone and PROM_SEC._progDone

    # Check if programming was successful
    if (progDone):
        print('\nReloading FPGA firmware from PROM ....')
        AxiVersion.FpgaReload()
        print('\nPlease reboot the computer')
    else:
        print('Failed to program FPGA')
        
    # Close out
    base.stop()
    exit()
