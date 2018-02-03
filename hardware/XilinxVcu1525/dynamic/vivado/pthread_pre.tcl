##############################################################################
## This file is part of 'axi-pcie-core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'axi-pcie-core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Setup project messaging
source -quiet ${RUCKUS_DIR}/vivado_messages.tcl

# Bug fix for using MIG cores in Vivado 2017.3 (or later)
# https://forums.xilinx.com/t5/Synthesis/Vivado-2016-4-Linux-crash-during-Phase-7-Resynthesis/td-p/794884
# https://forums.xilinx.com/t5/Welcome-Join/Abnormal-program-termination-11-in-place-design-vivado-2016-1/td-p/802908
set_param general.maxThreads 1
