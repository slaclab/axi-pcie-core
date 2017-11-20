#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : Data Dev test
#-----------------------------------------------------------------------------
# File       : dataDev.py
# Created    : 2017-03-22
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
import axipcie.core
import glob

# Declare a generic Kcu1500Root
class Kcu1500Root(pr.Root):
    def __init__(dev, path):
        super().__init__(name='Kcu1500Root', description='')

        # Create the stream interface
        coreMap = rogue.hardware.data.DataMap(dev)

        # Add Base Device
        self.add(axipcie.core.AxiPcieCore(memBase=coreMap,useSpi=True))
        self.start(pollEn=False)


if __name__ == '__main__':
    
    # Set the argument parser
    parser = argparse.ArgumentParser()

    # Add arguments
    parser.add_argument(
        ["--dev", '-d'], 
        type     = str,
        default  = '/dev/datadev_0',
        help     = "path to device",
    )  

    parser.add_argument(
        ["--path", '-p'], 
        type     = str,
        required = True,
        help     = "path to images",
    )  

    # Get the arguments
    args = parser.parse_args()
    
    # Get a list of images
    images = glob.glob('{}/primary*.mcs'.format(args.path))
    images = [i.replace('_primary.mcs','') for i in images]

    with Kcu1500Root(args.dev, args.path) as root:

        for i, l in enumerate(reversed(sorted(images))):
            print('{} : {}'.format(i, l))

        idx = int(input('Enter image: '))
        image = images[idx]
        pri = '{}_primary.mcs'.format(image)
        sec = '{}_secondary.mcs'.format(image)

        print('Loading primary image: {}'.format(pri))
        root.AxiPcieCore.AxiMicronN25Q[0].LoadMcsFile(pri)  
        
        print('Loading secondary image: {}'.format(sec))
        root.AxiPcieCore.AxiMicronN25Q[1].LoadMcsFile(sec)  

    exit()
