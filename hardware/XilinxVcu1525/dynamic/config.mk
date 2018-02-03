
# Define target output
target: bin

# Define the file path to the static checkpoint
export RECONFIG_DCP_DIR    = $(MODULES)/axi-pcie-core/hardware/XilinxVcu1525/static-release
export RECONFIG_CHECKPOINT = $(RECONFIG_DCP_DIR)/XilinxVcu1525Base-0x00000001-20180203000906-ruckman-ae1af400-static.dcp

# Define hierarchical path to dynamic module
export RECONFIG_ENDPOINT = U_App

# Define the PBLOCK name
export RECONFIG_PBLOCK = PB_APP

# Define the Hardware Type in the axi-pcie-core
export PCIE_HW_TYPE = XilinxVcu1525

# Define target part
export PRJ_PART = xcvu9p-fsgd2104-2-i