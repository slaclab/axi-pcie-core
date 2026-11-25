-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for the AXI PCIe Core (CPM5 QDMA descriptor-bypass).
--
-- Instantiates the regenerated CPM5 QDMA block design and the PL-side QDMA
-- glue: QdmaCtxtInit (programs queue contexts over dma1_mgmt), QdmaBypassAdapter
-- (turns AxisG2 descriptor submissions into QDMA bypass-in descriptors and moves
-- the AXI-Stream payload over dma1_m_axis_h2c / dma1_s_axis_c2h), and
-- AxisG2RegShim (reproduces the datadev BAR0 register map, fed from the host
-- BAR0 user window mAxi, passed to the Core's AxiPcieReg as an AXI4 reg master;
-- the AGEN2 crossbar slot comes back as the shim's AXI-Lite). The user
-- AXI-Stream (dmaOb/dmaIb) is exposed to the Core so top-levels are unchanged.
--
-- NOTE (interface change vs. the old bridge wrapper): the DMA engine now lives
-- here, so this wrapper exposes the user AXIS (dmaObMaster/dmaIbMaster + the
-- AxisG2 reg/version AXI-Lite) instead of the old dma/reg AXI4 record ports.
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'axi-pcie-core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;
use axi_pcie_core.QdmaCtxtPkg.all;
use axi_pcie_core.AxisG2ShimPkg.all;
use axi_pcie_core.XilinxAlveoV80CpmManagerPkg.all;


entity XilinxAlveoV80PciePhyWrapper is
   generic (
      TPD_G             : time               := 1 ns;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      userClk        : in    sl;
      -- Clocks/resets out
      axiClk         : out   sl;
      axiRst         : out   sl;
      -- User AXI-Stream (QDMA H2C -> user, user -> QDMA C2H)
      dmaObMaster    : out   AxiStreamMasterType;
      dmaObSlave     : in    AxiStreamSlaveType;
      dmaIbMaster    : in    AxiStreamMasterType;
      dmaIbSlave     : out   AxiStreamSlaveType;
      -- BAR0 register AXI4 path (mAxi = CPM_PCIE_NOC_0->PL window) to the Core's
      -- AxiPcieReg (which owns the full SLAC BAR0 map incl. AxiVersion@0x20000).
      regReadMaster  : out   AxiReadMasterType;
      regReadSlave   : in    AxiReadSlaveType;
      regWriteMaster : out   AxiWriteMasterType;
      regWriteSlave  : in    AxiWriteSlaveType;
      -- AGEN2/DMA crossbar slot (AxiPcieReg dmaCtrl(0)) that drives the AxisG2
      -- register shim living in this wrapper.
      dmaCtrlReadMaster  : in  AxiLiteReadMasterType;
      dmaCtrlReadSlave   : out AxiLiteReadSlaveType;
      dmaCtrlWriteMaster : in  AxiLiteWriteMasterType;
      dmaCtrlWriteSlave  : out AxiLiteWriteSlaveType;
      -- Interrupt (legacy dmaIrq input; QDMA MSI-X is driven via adapter sdi)
      dmaIrq         : in    sl;
      -- PS DDR Ports
      psDdrDq        : inout slv(71 downto 0);
      psDdrDqsT      : inout slv(8 downto 0);
      psDdrDqsC      : inout slv(8 downto 0);
      psDdrAdr       : out   slv(16 downto 0);
      psDdrBa        : out   slv(1 downto 0);
      psDdrBg        : out   slv(0 to 0);
      psDdrActN      : out   slv(0 to 0);
      psDdrResetN    : out   slv(0 to 0);
      psDdrCkT       : out   slv(0 to 0);
      psDdrCkC       : out   slv(0 to 0);
      psDdrCke       : out   slv(0 to 0);
      psDdrCsN       : out   slv(0 to 0);
      psDdrDmN       : inout slv(8 downto 0);
      psDdrOdt       : out   slv(0 to 0);
      psDdrClkP      : in    slv(0 to 0);
      psDdrClkN      : in    slv(0 to 0);
      -- PCIe Ports
      pciRefClkP     : in    sl;
      pciRefClkN     : in    sl;
      pciRxP         : in    slv(7 downto 0);
      pciRxN         : in    slv(7 downto 0);
      pciTxP         : out   slv(7 downto 0);
      pciTxN         : out   slv(7 downto 0));
end XilinxAlveoV80PciePhyWrapper;

architecture mapping of XilinxAlveoV80PciePhyWrapper is

   component XilinxAlveoV80PcieBlockDesign is
      port (
      dma1_axis_c2h_dmawr_cmp              : out   std_logic;
      dma1_axis_c2h_dmawr_port_id          : out   std_logic_vector (2 downto 0);
      dma1_axis_c2h_dmawr_target_vch       : out   std_logic;
      dma1_axis_c2h_status_drop            : out   std_logic;
      dma1_axis_c2h_status_error           : out   std_logic;
      dma1_axis_c2h_status_last            : out   std_logic;
      dma1_axis_c2h_status_qid             : out   std_logic_vector (11 downto 0);
      dma1_axis_c2h_status_status_cmp      : out   std_logic;
      dma1_axis_c2h_status_valid           : out   std_logic;
      dma1_c2h_byp_in_st_csh_addr          : in    std_logic_vector (63 downto 0);
      dma1_c2h_byp_in_st_csh_error         : in    std_logic;
      dma1_c2h_byp_in_st_csh_func          : in    std_logic_vector (11 downto 0);
      dma1_c2h_byp_in_st_csh_pfch_tag      : in    std_logic_vector (6 downto 0);
      dma1_c2h_byp_in_st_csh_port_id       : in    std_logic_vector (2 downto 0);
      dma1_c2h_byp_in_st_csh_qid           : in    std_logic_vector (11 downto 0);
      dma1_c2h_byp_in_st_csh_ready         : out   std_logic;
      dma1_c2h_byp_in_st_csh_valid         : in    std_logic;
      dma1_c2h_byp_out_cidx                : out   std_logic_vector (15 downto 0);
      dma1_c2h_byp_out_dsc                 : out   std_logic_vector (255 downto 0);
      dma1_c2h_byp_out_dsc_sz              : out   std_logic_vector (1 downto 0);
      dma1_c2h_byp_out_error               : out   std_logic;
      dma1_c2h_byp_out_fmt                 : out   std_logic_vector (2 downto 0);
      dma1_c2h_byp_out_func                : out   std_logic_vector (11 downto 0);
      dma1_c2h_byp_out_mm_chn              : out   std_logic;
      dma1_c2h_byp_out_pfch_tag            : out   std_logic_vector (6 downto 0);
      dma1_c2h_byp_out_port_id             : out   std_logic_vector (2 downto 0);
      dma1_c2h_byp_out_qid                 : out   std_logic_vector (11 downto 0);
      dma1_c2h_byp_out_ready               : in    std_logic;
      dma1_c2h_byp_out_st_mm               : out   std_logic;
      dma1_c2h_byp_out_valid               : out   std_logic;
      dma1_dsc_crdt_in_crdt                : in    std_logic_vector (15 downto 0);
      dma1_dsc_crdt_in_dir                 : in    std_logic;
      dma1_dsc_crdt_in_fence               : in    std_logic;
      dma1_dsc_crdt_in_qid                 : in    std_logic_vector (11 downto 0);
      dma1_dsc_crdt_in_rdy                 : out   std_logic;
      dma1_dsc_crdt_in_valid               : in    std_logic;
      dma1_h2c_byp_in_st_addr              : in    std_logic_vector (63 downto 0);
      dma1_h2c_byp_in_st_cidx              : in    std_logic_vector (15 downto 0);
      dma1_h2c_byp_in_st_eop               : in    std_logic;
      dma1_h2c_byp_in_st_error             : in    std_logic;
      dma1_h2c_byp_in_st_func              : in    std_logic_vector (11 downto 0);
      dma1_h2c_byp_in_st_len               : in    std_logic_vector (15 downto 0);
      dma1_h2c_byp_in_st_mrkr_req          : in    std_logic;
      dma1_h2c_byp_in_st_no_dma            : in    std_logic;
      dma1_h2c_byp_in_st_port_id           : in    std_logic_vector (2 downto 0);
      dma1_h2c_byp_in_st_qid               : in    std_logic_vector (11 downto 0);
      dma1_h2c_byp_in_st_ready             : out   std_logic;
      dma1_h2c_byp_in_st_sdi               : in    std_logic;
      dma1_h2c_byp_in_st_sop               : in    std_logic;
      dma1_h2c_byp_in_st_valid             : in    std_logic;
      dma1_h2c_byp_out_cidx                : out   std_logic_vector (15 downto 0);
      dma1_h2c_byp_out_dsc                 : out   std_logic_vector (255 downto 0);
      dma1_h2c_byp_out_dsc_sz              : out   std_logic_vector (1 downto 0);
      dma1_h2c_byp_out_error               : out   std_logic;
      dma1_h2c_byp_out_fmt                 : out   std_logic_vector (2 downto 0);
      dma1_h2c_byp_out_func                : out   std_logic_vector (11 downto 0);
      dma1_h2c_byp_out_mm_chn              : out   std_logic;
      dma1_h2c_byp_out_port_id             : out   std_logic_vector (2 downto 0);
      dma1_h2c_byp_out_qid                 : out   std_logic_vector (11 downto 0);
      dma1_h2c_byp_out_ready               : in    std_logic;
      dma1_h2c_byp_out_st_mm               : out   std_logic;
      dma1_h2c_byp_out_valid               : out   std_logic;
      dma1_m_axis_h2c_err                  : out   std_logic;
      dma1_m_axis_h2c_mdata                : out   std_logic_vector (31 downto 0);
      dma1_m_axis_h2c_mty                  : out   std_logic_vector (5 downto 0);
      dma1_m_axis_h2c_port_id              : out   std_logic_vector (2 downto 0);
      dma1_m_axis_h2c_qid                  : out   std_logic_vector (11 downto 0);
      dma1_m_axis_h2c_tcrc                 : out   std_logic_vector (31 downto 0);
      dma1_m_axis_h2c_tdata                : out   std_logic_vector (511 downto 0);
      dma1_m_axis_h2c_tlast                : out   std_logic;
      dma1_m_axis_h2c_tready               : in    std_logic;
      dma1_m_axis_h2c_tvalid               : out   std_logic;
      dma1_m_axis_h2c_zero_byte            : out   std_logic;
      dma1_mgmt_cpl_dat                    : out   std_logic_vector (31 downto 0);
      dma1_mgmt_cpl_rdy                    : in    std_logic;
      dma1_mgmt_cpl_sts                    : out   std_logic_vector (1 downto 0);
      dma1_mgmt_cpl_vld                    : out   std_logic;
      dma1_mgmt_req_adr                    : in    std_logic_vector (31 downto 0);
      dma1_mgmt_req_cmd                    : in    std_logic_vector (1 downto 0);
      dma1_mgmt_req_dat                    : in    std_logic_vector (31 downto 0);
      dma1_mgmt_req_fnc                    : in    std_logic_vector (12 downto 0);
      dma1_mgmt_req_msc                    : in    std_logic_vector (5 downto 0);
      dma1_mgmt_req_rdy                    : out   std_logic;
      dma1_mgmt_req_vld                    : in    std_logic;
      dma1_qsts_out_data                   : out   std_logic_vector (63 downto 0);
      dma1_qsts_out_op                     : out   std_logic_vector (7 downto 0);
      dma1_qsts_out_port_id                : out   std_logic_vector (2 downto 0);
      dma1_qsts_out_qid                    : out   std_logic_vector (12 downto 0);
      dma1_qsts_out_rdy                    : in    std_logic;
      dma1_qsts_out_vld                    : out   std_logic;
      dma1_s_axis_c2h_cmpt_cmpt_type       : in    std_logic_vector (1 downto 0);
      dma1_s_axis_c2h_cmpt_col_idx         : in    std_logic_vector (2 downto 0);
      dma1_s_axis_c2h_cmpt_data            : in    std_logic_vector (511 downto 0);
      dma1_s_axis_c2h_cmpt_dpar            : in    std_logic_vector (15 downto 0);
      dma1_s_axis_c2h_cmpt_err_idx         : in    std_logic_vector (2 downto 0);
      dma1_s_axis_c2h_cmpt_marker          : in    std_logic;
      dma1_s_axis_c2h_cmpt_no_wrb_marker   : in    std_logic;
      dma1_s_axis_c2h_cmpt_port_id         : in    std_logic_vector (2 downto 0);
      dma1_s_axis_c2h_cmpt_qid             : in    std_logic_vector (12 downto 0);
      dma1_s_axis_c2h_cmpt_size            : in    std_logic_vector (1 downto 0);
      dma1_s_axis_c2h_cmpt_tready          : out   std_logic;
      dma1_s_axis_c2h_cmpt_tvalid          : in    std_logic;
      dma1_s_axis_c2h_cmpt_user_trig       : in    std_logic;
      dma1_s_axis_c2h_cmpt_wait_pld_pkt_id : in    std_logic_vector (15 downto 0);
      dma1_s_axis_c2h_ctrl_has_cmpt        : in    std_logic;
      dma1_s_axis_c2h_ctrl_len             : in    std_logic_vector (15 downto 0);
      dma1_s_axis_c2h_ctrl_marker          : in    std_logic;
      dma1_s_axis_c2h_ctrl_port_id         : in    std_logic_vector (2 downto 0);
      dma1_s_axis_c2h_ctrl_qid             : in    std_logic_vector (11 downto 0);
      dma1_s_axis_c2h_ecc                  : in    std_logic_vector (6 downto 0);
      dma1_s_axis_c2h_mty                  : in    std_logic_vector (5 downto 0);
      dma1_s_axis_c2h_tcrc                 : in    std_logic_vector (31 downto 0);
      dma1_s_axis_c2h_tdata                : in    std_logic_vector (511 downto 0);
      dma1_s_axis_c2h_tlast                : in    std_logic;
      dma1_s_axis_c2h_tready               : out   std_logic;
      dma1_s_axis_c2h_tvalid               : in    std_logic;
      dma1_st_rx_msg_tdata                 : out   std_logic_vector (31 downto 0);
      dma1_st_rx_msg_tlast                 : out   std_logic;
      dma1_st_rx_msg_tready                : in    std_logic;
      dma1_st_rx_msg_tvalid                : out   std_logic;
      dma1_tm_dsc_sts_avl                  : out   std_logic_vector (15 downto 0);
      dma1_tm_dsc_sts_byp                  : out   std_logic;
      dma1_tm_dsc_sts_dir                  : out   std_logic;
      dma1_tm_dsc_sts_error                : out   std_logic;
      dma1_tm_dsc_sts_irq_arm              : out   std_logic;
      dma1_tm_dsc_sts_mm                   : out   std_logic;
      dma1_tm_dsc_sts_pidx                 : out   std_logic_vector (15 downto 0);
      dma1_tm_dsc_sts_port_id              : out   std_logic_vector (2 downto 0);
      dma1_tm_dsc_sts_qen                  : out   std_logic;
      dma1_tm_dsc_sts_qid                  : out   std_logic_vector (11 downto 0);
      dma1_tm_dsc_sts_qinv                 : out   std_logic;
      dma1_tm_dsc_sts_rdy                  : in    std_logic;
      dma1_tm_dsc_sts_valid                : out   std_logic;
      dma1_usr_irq_ack                     : out   std_logic;
      dma1_usr_irq_fail                    : out   std_logic;
      dma1_usr_irq_fnc                     : in    std_logic_vector (12 downto 0);
      dma1_usr_irq_valid                   : in    std_logic;
      dma1_usr_irq_vec                     : in    std_logic_vector (10 downto 0);
      dmaClk                               : in    std_logic;
      dmaRstN                              : in    std_logic;
      gtPcieRefClk_clk_n                   : in    std_logic;
      gtPcieRefClk_clk_p                   : in    std_logic;
      gtPcie_grx_n                         : in    std_logic_vector (7 downto 0);
      gtPcie_grx_p                         : in    std_logic_vector (7 downto 0);
      gtPcie_gtx_n                         : out   std_logic_vector (7 downto 0);
      gtPcie_gtx_p                         : out   std_logic_vector (7 downto 0);
      mAxi_araddr                          : out   std_logic_vector (63 downto 0);
      mAxi_arburst                         : out   std_logic_vector (1 downto 0);
      mAxi_arcache                         : out   std_logic_vector (3 downto 0);
      mAxi_arid                            : out   std_logic_vector (1 downto 0);
      mAxi_arlen                           : out   std_logic_vector (7 downto 0);
      mAxi_arlock                          : out   std_logic_vector (0 downto 0);
      mAxi_arprot                          : out   std_logic_vector (2 downto 0);
      mAxi_arqos                           : out   std_logic_vector (3 downto 0);
      mAxi_arready                         : in    std_logic_vector (0 downto 0);
      mAxi_arregion                        : out   std_logic_vector (3 downto 0);
      mAxi_arsize                          : out   std_logic_vector (2 downto 0);
      mAxi_aruser                          : out   std_logic_vector (17 downto 0);
      mAxi_arvalid                         : out   std_logic_vector (0 downto 0);
      mAxi_awaddr                          : out   std_logic_vector (63 downto 0);
      mAxi_awburst                         : out   std_logic_vector (1 downto 0);
      mAxi_awcache                         : out   std_logic_vector (3 downto 0);
      mAxi_awid                            : out   std_logic_vector (1 downto 0);
      mAxi_awlen                           : out   std_logic_vector (7 downto 0);
      mAxi_awlock                          : out   std_logic_vector (0 downto 0);
      mAxi_awprot                          : out   std_logic_vector (2 downto 0);
      mAxi_awqos                           : out   std_logic_vector (3 downto 0);
      mAxi_awready                         : in    std_logic_vector (0 downto 0);
      mAxi_awregion                        : out   std_logic_vector (3 downto 0);
      mAxi_awsize                          : out   std_logic_vector (2 downto 0);
      mAxi_awuser                          : out   std_logic_vector (17 downto 0);
      mAxi_awvalid                         : out   std_logic_vector (0 downto 0);
      mAxi_bid                             : in    std_logic_vector (1 downto 0);
      mAxi_bready                          : out   std_logic_vector (0 downto 0);
      mAxi_bresp                           : in    std_logic_vector (1 downto 0);
      mAxi_bvalid                          : in    std_logic_vector (0 downto 0);
      mAxi_rdata                           : in    std_logic_vector (511 downto 0);
      mAxi_rid                             : in    std_logic_vector (1 downto 0);
      mAxi_rlast                           : in    std_logic_vector (0 downto 0);
      mAxi_rready                          : out   std_logic_vector (0 downto 0);
      mAxi_rresp                           : in    std_logic_vector (1 downto 0);
      mAxi_rvalid                          : in    std_logic_vector (0 downto 0);
      mAxi_wdata                           : out   std_logic_vector (511 downto 0);
      mAxi_wlast                           : out   std_logic_vector (0 downto 0);
      mAxi_wready                          : in    std_logic_vector (0 downto 0);
      mAxi_wstrb                           : out   std_logic_vector (63 downto 0);
      mAxi_wvalid                          : out   std_logic_vector (0 downto 0);
      plRefClk                             : out   std_logic;
      plRstN                               : out   std_logic;
      pciRstN                              : out   std_logic;
      psDDR_act_n                          : out   std_logic_vector (0 downto 0);
      psDDR_adr                            : out   std_logic_vector (16 downto 0);
      psDDR_ba                             : out   std_logic_vector (1 downto 0);
      psDDR_bg                             : out   std_logic_vector (0 downto 0);
      psDDR_ck_c                           : out   std_logic_vector (0 downto 0);
      psDDR_ck_t                           : out   std_logic_vector (0 downto 0);
      psDDR_cke                            : out   std_logic_vector (0 downto 0);
      psDDR_cs_n                           : out   std_logic_vector (0 downto 0);
      psDDR_dm_n                           : inout std_logic_vector (8 downto 0);
      psDDR_dq                             : inout std_logic_vector (71 downto 0);
      psDDR_dqs_c                          : inout std_logic_vector (8 downto 0);
      psDDR_dqs_t                          : inout std_logic_vector (8 downto 0);
      psDDR_odt                            : out   std_logic_vector (0 downto 0);
      psDDR_reset_n                        : out   std_logic_vector (0 downto 0);
      psDdrClk_clk_n                       : in    std_logic_vector (0 downto 0);
      psDdrClk_clk_p                       : in    std_logic_vector (0 downto 0);
      sAxiLpd_araddr                       : in    std_logic_vector (48 downto 0);
      sAxiLpd_arburst                      : in    std_logic_vector (1 downto 0);
      sAxiLpd_arcache                      : in    std_logic_vector (3 downto 0);
      sAxiLpd_arlen                        : in    std_logic_vector (7 downto 0);
      sAxiLpd_arlock                       : in    std_logic;
      sAxiLpd_arprot                       : in    std_logic_vector (2 downto 0);
      sAxiLpd_arqos                        : in    std_logic_vector (3 downto 0);
      sAxiLpd_arready                      : out   std_logic;
      sAxiLpd_arsize                       : in    std_logic_vector (2 downto 0);
      sAxiLpd_arvalid                      : in    std_logic;
      sAxiLpd_awaddr                       : in    std_logic_vector (48 downto 0);
      sAxiLpd_awburst                      : in    std_logic_vector (1 downto 0);
      sAxiLpd_awcache                      : in    std_logic_vector (3 downto 0);
      sAxiLpd_awlen                        : in    std_logic_vector (7 downto 0);
      sAxiLpd_awlock                       : in    std_logic;
      sAxiLpd_awprot                       : in    std_logic_vector (2 downto 0);
      sAxiLpd_awqos                        : in    std_logic_vector (3 downto 0);
      sAxiLpd_awready                      : out   std_logic;
      sAxiLpd_awsize                       : in    std_logic_vector (2 downto 0);
      sAxiLpd_awvalid                      : in    std_logic;
      sAxiLpd_bready                       : in    std_logic;
      sAxiLpd_bresp                        : out   std_logic_vector (1 downto 0);
      sAxiLpd_bvalid                       : out   std_logic;
      sAxiLpd_rdata                        : out   std_logic_vector (31 downto 0);
      sAxiLpd_rlast                        : out   std_logic;
      sAxiLpd_rready                       : in    std_logic;
      sAxiLpd_rresp                        : out   std_logic_vector (1 downto 0);
      sAxiLpd_rvalid                       : out   std_logic;
      sAxiLpd_wdata                        : in    std_logic_vector (31 downto 0);
      sAxiLpd_wlast                        : in    std_logic;
      sAxiLpd_wready                       : out   std_logic;
      sAxiLpd_wstrb                        : in    std_logic_vector (3 downto 0);
      sAxiLpd_wvalid                       : in    std_logic      );
   end component;

   signal clk    : sl;
   signal rstL   : sl;
   signal plRstN : sl;
   signal pciRstN : sl;               -- CPM5 PCIe reset (cips/dma1_axi_aresetn)
   signal cmbRstN : sl;               -- plRstN and pciRstN (PCIe link-down gated)
   signal hostAccess : sl;            -- first host BAR0 access (gates BDF programming)

   -- QDMA mgmt (QdmaCtxtInit <-> dma1_mgmt)
   signal mgmtMaster : QdmaMgmtReqMasterType;
   signal mgmtSlave  : QdmaMgmtReqSlaveType;

   -- AxisG2 shim <-> adapter
   signal txSub       : AxisG2TxSubType;
   signal txSubReady  : sl;
   signal rxFree      : AxisG2RxFreeType;
   signal rxFreeReady : sl;
   signal addrRdIndex : slv(AXISG2_INDEX_BITS_C-1 downto 0);
   signal addrRdData  : slv(63 downto 0);

   -- mAxi (BAR0 user window) as AXI4 record, converted to AXI-Lite for the shim
   signal mAxiWriteMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal mAxiWriteSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
   signal mAxiReadMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal mAxiReadSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;

   -- QdmaCtxtInit start trigger (deferred until past reset)
   signal ctxtStart : sl := '0';
   signal startCnt  : slv(27 downto 0) := (others => '0');

   -- BD boundary signals (dma1_* QDMA + mAxi AXI4 master), auto-declared:
   signal dma1_axis_c2h_dmawr_cmp              : sl;
   signal dma1_axis_c2h_dmawr_port_id          : slv(2 downto 0);
   signal dma1_axis_c2h_dmawr_target_vch       : sl;
   signal dma1_axis_c2h_status_drop            : sl;
   signal dma1_axis_c2h_status_error           : sl;
   signal dma1_axis_c2h_status_last            : sl;
   signal dma1_axis_c2h_status_qid             : slv(11 downto 0);
   signal dma1_axis_c2h_status_status_cmp      : sl;
   signal dma1_axis_c2h_status_valid           : sl;
   signal dma1_c2h_byp_in_st_csh_addr          : slv(63 downto 0);
   signal dma1_c2h_byp_in_st_csh_error         : sl;
   signal dma1_c2h_byp_in_st_csh_func          : slv(11 downto 0);
   signal dma1_c2h_byp_in_st_csh_pfch_tag      : slv(6 downto 0);
   signal dma1_c2h_byp_in_st_csh_port_id       : slv(2 downto 0);
   signal dma1_c2h_byp_in_st_csh_qid           : slv(11 downto 0);
   signal dma1_c2h_byp_in_st_csh_ready         : sl;
   signal dma1_c2h_byp_in_st_csh_valid         : sl;
   signal dma1_c2h_byp_out_cidx                : slv(15 downto 0);
   signal dma1_c2h_byp_out_dsc                 : slv(255 downto 0);
   signal dma1_c2h_byp_out_dsc_sz              : slv(1 downto 0);
   signal dma1_c2h_byp_out_error               : sl;
   signal dma1_c2h_byp_out_fmt                 : slv(2 downto 0);
   signal dma1_c2h_byp_out_func                : slv(11 downto 0);
   signal dma1_c2h_byp_out_mm_chn              : sl;
   signal dma1_c2h_byp_out_pfch_tag            : slv(6 downto 0);
   signal dma1_c2h_byp_out_port_id             : slv(2 downto 0);
   signal dma1_c2h_byp_out_qid                 : slv(11 downto 0);
   signal dma1_c2h_byp_out_ready               : sl;
   signal dma1_c2h_byp_out_st_mm               : sl;
   signal dma1_c2h_byp_out_valid               : sl;
   signal dma1_dsc_crdt_in_crdt                : slv(15 downto 0);
   signal dma1_dsc_crdt_in_dir                 : sl;
   signal dma1_dsc_crdt_in_fence               : sl;
   signal dma1_dsc_crdt_in_qid                 : slv(11 downto 0);
   signal dma1_dsc_crdt_in_rdy                 : sl;
   signal dma1_dsc_crdt_in_valid               : sl;
   signal dma1_h2c_byp_in_st_addr              : slv(63 downto 0);
   signal dma1_h2c_byp_in_st_cidx              : slv(15 downto 0);
   signal dma1_h2c_byp_in_st_eop               : sl;
   signal dma1_h2c_byp_in_st_error             : sl;
   signal dma1_h2c_byp_in_st_func              : slv(11 downto 0);
   signal dma1_h2c_byp_in_st_len               : slv(15 downto 0);
   signal dma1_h2c_byp_in_st_mrkr_req          : sl;
   signal dma1_h2c_byp_in_st_no_dma            : sl;
   signal dma1_h2c_byp_in_st_port_id           : slv(2 downto 0);
   signal dma1_h2c_byp_in_st_qid               : slv(11 downto 0);
   signal dma1_h2c_byp_in_st_ready             : sl;
   signal dma1_h2c_byp_in_st_sdi               : sl;
   signal dma1_h2c_byp_in_st_sop               : sl;
   signal dma1_h2c_byp_in_st_valid             : sl;
   signal dma1_h2c_byp_out_cidx                : slv(15 downto 0);
   signal dma1_h2c_byp_out_dsc                 : slv(255 downto 0);
   signal dma1_h2c_byp_out_dsc_sz              : slv(1 downto 0);
   signal dma1_h2c_byp_out_error               : sl;
   signal dma1_h2c_byp_out_fmt                 : slv(2 downto 0);
   signal dma1_h2c_byp_out_func                : slv(11 downto 0);
   signal dma1_h2c_byp_out_mm_chn              : sl;
   signal dma1_h2c_byp_out_port_id             : slv(2 downto 0);
   signal dma1_h2c_byp_out_qid                 : slv(11 downto 0);
   signal dma1_h2c_byp_out_ready               : sl;
   signal dma1_h2c_byp_out_st_mm               : sl;
   signal dma1_h2c_byp_out_valid               : sl;
   signal dma1_m_axis_h2c_err                  : sl;
   signal dma1_m_axis_h2c_mdata                : slv(31 downto 0);
   signal dma1_m_axis_h2c_mty                  : slv(5 downto 0);
   signal dma1_m_axis_h2c_port_id              : slv(2 downto 0);
   signal dma1_m_axis_h2c_qid                  : slv(11 downto 0);
   signal dma1_m_axis_h2c_tcrc                 : slv(31 downto 0);
   signal dma1_m_axis_h2c_tdata                : slv(511 downto 0);
   signal dma1_m_axis_h2c_tlast                : sl;
   signal dma1_m_axis_h2c_tready               : sl;
   signal dma1_m_axis_h2c_tvalid               : sl;
   signal dma1_m_axis_h2c_zero_byte            : sl;
   signal dma1_mgmt_cpl_dat                    : slv(31 downto 0);
   signal dma1_mgmt_cpl_rdy                    : sl;
   signal dma1_mgmt_cpl_sts                    : slv(1 downto 0);
   signal dma1_mgmt_cpl_vld                    : sl;
   signal dma1_mgmt_req_adr                    : slv(31 downto 0);
   signal dma1_mgmt_req_cmd                    : slv(1 downto 0);
   signal dma1_mgmt_req_dat                    : slv(31 downto 0);
   signal dma1_mgmt_req_fnc                    : slv(12 downto 0);
   signal dma1_mgmt_req_msc                    : slv(5 downto 0);
   signal dma1_mgmt_req_rdy                    : sl;
   signal dma1_mgmt_req_vld                    : sl;
   signal dma1_qsts_out_data                   : slv(63 downto 0);
   signal dma1_qsts_out_op                     : slv(7 downto 0);
   signal dma1_qsts_out_port_id                : slv(2 downto 0);
   signal dma1_qsts_out_qid                    : slv(12 downto 0);
   signal dma1_qsts_out_rdy                    : sl;
   signal dma1_qsts_out_vld                    : sl;
   signal dma1_s_axis_c2h_cmpt_cmpt_type       : slv(1 downto 0);
   signal dma1_s_axis_c2h_cmpt_col_idx         : slv(2 downto 0);
   signal dma1_s_axis_c2h_cmpt_data            : slv(511 downto 0);
   signal dma1_s_axis_c2h_cmpt_dpar            : slv(15 downto 0);
   signal dma1_s_axis_c2h_cmpt_err_idx         : slv(2 downto 0);
   signal dma1_s_axis_c2h_cmpt_marker          : sl;
   signal dma1_s_axis_c2h_cmpt_no_wrb_marker   : sl;
   signal dma1_s_axis_c2h_cmpt_port_id         : slv(2 downto 0);
   signal dma1_s_axis_c2h_cmpt_qid             : slv(12 downto 0);
   signal dma1_s_axis_c2h_cmpt_size            : slv(1 downto 0);
   signal dma1_s_axis_c2h_cmpt_tready          : sl;
   signal dma1_s_axis_c2h_cmpt_tvalid          : sl;
   signal dma1_s_axis_c2h_cmpt_user_trig       : sl;
   signal dma1_s_axis_c2h_cmpt_wait_pld_pkt_id : slv(15 downto 0);
   signal dma1_s_axis_c2h_ctrl_has_cmpt        : sl;
   signal dma1_s_axis_c2h_ctrl_len             : slv(15 downto 0);
   signal dma1_s_axis_c2h_ctrl_marker          : sl;
   signal dma1_s_axis_c2h_ctrl_port_id         : slv(2 downto 0);
   signal dma1_s_axis_c2h_ctrl_qid             : slv(11 downto 0);
   signal dma1_s_axis_c2h_ecc                  : slv(6 downto 0);
   signal dma1_s_axis_c2h_mty                  : slv(5 downto 0);
   signal dma1_s_axis_c2h_tcrc                 : slv(31 downto 0);
   signal dma1_s_axis_c2h_tdata                : slv(511 downto 0);
   signal dma1_s_axis_c2h_tlast                : sl;
   signal dma1_s_axis_c2h_tready               : sl;
   signal dma1_s_axis_c2h_tvalid               : sl;
   signal dma1_st_rx_msg_tdata                 : slv(31 downto 0);
   signal dma1_st_rx_msg_tlast                 : sl;
   signal dma1_st_rx_msg_tready                : sl;
   signal dma1_st_rx_msg_tvalid                : sl;
   signal dma1_tm_dsc_sts_avl                  : slv(15 downto 0);
   signal dma1_tm_dsc_sts_byp                  : sl;
   signal dma1_tm_dsc_sts_dir                  : sl;
   signal dma1_tm_dsc_sts_error                : sl;
   signal dma1_tm_dsc_sts_irq_arm              : sl;
   signal dma1_tm_dsc_sts_mm                   : sl;
   signal dma1_tm_dsc_sts_pidx                 : slv(15 downto 0);
   signal dma1_tm_dsc_sts_port_id              : slv(2 downto 0);
   signal dma1_tm_dsc_sts_qen                  : sl;
   signal dma1_tm_dsc_sts_qid                  : slv(11 downto 0);
   signal dma1_tm_dsc_sts_qinv                 : sl;
   signal dma1_tm_dsc_sts_rdy                  : sl;
   signal dma1_tm_dsc_sts_valid                : sl;
   signal dma1_usr_irq_ack                     : sl;
   signal dma1_usr_irq_fail                    : sl;
   signal dma1_usr_irq_fnc                     : slv(12 downto 0);
   signal dma1_usr_irq_valid                   : sl;
   signal dma1_usr_irq_vec                     : slv(10 downto 0);

   -- Shim interrupt -> MSI
   signal shimInterrupt : sl;
   signal ctxtDone      : sl;         -- QdmaCtxtInit done (exposed for debug)
   signal ctxtStatus    : slv(31 downto 0);  -- QdmaCtxtInit FSM status (debug)
   signal ctxtPfchTag   : slv(6 downto 0);   -- reserved C2H simple-bypass prefetch tag
   -- Shim config routed to the adapter / context-init (C2H completion path)
   signal shimOnline    : slv(31 downto 0);  -- AxisG2 online reg (0x2C)
   signal shimOnlineSl  : sl;                -- online /= 0 (re-program trigger)
   signal shimMaxSize   : slv(31 downto 0);  -- AxisG2 maxSize reg (0x28)
   signal shimWrBase    : slv(63 downto 0);  -- AxisG2 completion-ring base (0x10/0x14)
   signal cmptDoneInt   : sl;                -- adapter C2H-completion -> shim IRQ engine
   signal cpmStartupDone: sl;                -- CpmManager startup done (IRQ service armed)

   -- PL AXI-Lite master that writes the CPM5_DMA1 TX_IRQ_CSR over S_AXI_LPD to
   -- raise the PCIe MSI (XilinxAlveoV80CpmManager). This is the proven IRQ path
   -- (the native QDMA usr_irq interface did not deliver on hardware); the
   -- CpmManager replays STARTUP_WRITES_G (NoC cache config + BDF table) on the
   -- first host access, then does the TX_IRQ_CSR write on each interrupt.
   signal msiWriteMaster : AxiLiteWriteMasterType;
   signal msiWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal msiReadMaster  : AxiLiteReadMasterType;
   signal msiReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_INIT_C;
   signal mAxi_araddr                          : slv(63 downto 0);
   signal mAxi_arburst                         : slv(1 downto 0);
   signal mAxi_arcache                         : slv(3 downto 0);
   signal mAxi_arid                            : slv(1 downto 0);
   signal mAxi_arlen                           : slv(7 downto 0);
   signal mAxi_arlock                          : slv(0 downto 0);
   signal mAxi_arprot                          : slv(2 downto 0);
   signal mAxi_arqos                           : slv(3 downto 0);
   signal mAxi_arready                         : slv(0 downto 0);
   signal mAxi_arregion                        : slv(3 downto 0);
   signal mAxi_arsize                          : slv(2 downto 0);
   signal mAxi_aruser                          : slv(17 downto 0);
   signal mAxi_arvalid                         : slv(0 downto 0);
   signal mAxi_awaddr                          : slv(63 downto 0);
   signal mAxi_awburst                         : slv(1 downto 0);
   signal mAxi_awcache                         : slv(3 downto 0);
   signal mAxi_awid                            : slv(1 downto 0);
   signal mAxi_awlen                           : slv(7 downto 0);
   signal mAxi_awlock                          : slv(0 downto 0);
   signal mAxi_awprot                          : slv(2 downto 0);
   signal mAxi_awqos                           : slv(3 downto 0);
   signal mAxi_awready                         : slv(0 downto 0);
   signal mAxi_awregion                        : slv(3 downto 0);
   signal mAxi_awsize                          : slv(2 downto 0);
   signal mAxi_awuser                          : slv(17 downto 0);
   signal mAxi_awvalid                         : slv(0 downto 0);
   signal mAxi_bid                             : slv(1 downto 0);
   signal mAxi_bready                          : slv(0 downto 0);
   signal mAxi_bresp                           : slv(1 downto 0);
   signal mAxi_bvalid                          : slv(0 downto 0);
   signal mAxi_rdata                           : slv(511 downto 0);
   signal mAxi_rid                             : slv(1 downto 0);
   signal mAxi_rlast                           : slv(0 downto 0);
   signal mAxi_rready                          : slv(0 downto 0);
   signal mAxi_rresp                           : slv(1 downto 0);
   signal mAxi_rvalid                          : slv(0 downto 0);
   signal mAxi_wdata                           : slv(511 downto 0);
   signal mAxi_wlast                           : slv(0 downto 0);
   signal mAxi_wready                          : slv(0 downto 0);
   signal mAxi_wstrb                           : slv(63 downto 0);
   signal mAxi_wvalid                          : slv(0 downto 0);
begin

   axiClk <= clk;

   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => clk,
         rstIn  => rstL,
         rstOut => axiRst);

   -- PCIe link-down -> PL reset: hold the PL in reset whenever either the PS PL
   -- reset (plRstN) or the CPM5 PCIe reset (pciRstN = cips/dma1_axi_aresetn,
   -- which deasserts on a PCIe link-down) is asserted.
   cmbRstN <= pciRstN and plRstN;

   U_PwrUpRst : entity surf.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '0',
         DURATION_G     => getTimeRatio(250.0E+6, 100.0))  -- 10 ms reset (250e6/100 = 2.5e6 cycles)
      port map(
         clk    => clk,
         arst   => cmbRstN,
         rstOut => rstL);

   -- Deferred one-shot start for QdmaCtxtInit: wait ~some cycles after reset
   -- release so the CPM5 is past boot before programming contexts (mirrors the
   -- deferred BDF programming rationale in the old CpmManager).
   process (clk) is
   begin
      if rising_edge(clk) then
         if (rstL = '0') then
            startCnt  <= (others => '0') after TPD_G;
            ctxtStart <= '0'             after TPD_G;
         elsif (startCnt = x"3FFFFFF") then
            ctxtStart <= '1' after TPD_G;
         else
            startCnt <= startCnt + 1 after TPD_G;
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- QDMA queue-context auto-init (drives dma1_mgmt req/cpl)
   ----------------------------------------------------------------------------
   -- Driver online request (AxisG2 0x2C /= 0): rising edge re-programs the CMPT
   -- context so its baddr tracks the driver's just-written completion-ring base.
   shimOnlineSl <= '0' when (shimOnline = 0) else '1';

   U_QdmaCtxtInit : entity axi_pcie_core.QdmaCtxtInit
      generic map (
         TPD_G => TPD_G)
      port map (
         clk        => clk,
         rstL       => rstL,
         start        => ctxtStart,
         online       => shimOnlineSl,
         wrBase       => shimWrBase,
         ctxtDone     => ctxtDone,
         dbgStatus    => ctxtStatus,
         pfchTag      => ctxtPfchTag,
         pfchTagValid => open,
         mgmtMaster   => mgmtMaster,
         mgmtSlave    => mgmtSlave);

   -- mgmt record <-> flat dma1_mgmt pins
   dma1_mgmt_req_adr <= mgmtMaster.reqAdr;
   dma1_mgmt_req_dat <= mgmtMaster.reqDat;
   dma1_mgmt_req_cmd <= mgmtMaster.reqCmd;
   dma1_mgmt_req_fnc <= mgmtMaster.reqFnc;
   dma1_mgmt_req_msc <= mgmtMaster.reqMsc;
   dma1_mgmt_req_vld <= mgmtMaster.reqVld;
   dma1_mgmt_cpl_rdy <= mgmtMaster.cplRdy;
   mgmtSlave.reqRdy  <= dma1_mgmt_req_rdy;
   mgmtSlave.cplDat  <= dma1_mgmt_cpl_dat;
   mgmtSlave.cplSts  <= dma1_mgmt_cpl_sts;
   mgmtSlave.cplVld  <= dma1_mgmt_cpl_vld;

   ----------------------------------------------------------------------------
   -- Host BAR0 user window: mAxi (AXI4 512b) -> regRead/WriteMaster -> Core's
   -- AxiPcieReg (owns AxiVersion@0x20000 + the REG_AXIS_GEN2 offset table +
   -- internal AXI4->AXI-Lite crossbar) -> dmaCtrl(0) -> AxisG2RegShim. This
   -- preserves the datadev discovery path (probe reads AxiVersion, then uses
   -- its offset table to locate the AxisG2 window = the shim on dmaCtrl(0)).
   -- mAxi is a BD *output* (CPM masters into PL), so it drives mAxiWriteMaster/
   -- mAxiReadMaster here.
   ----------------------------------------------------------------------------
   mAxiWriteMaster.awvalid <= mAxi_awvalid(0);
   mAxiWriteMaster.awaddr  <= mAxi_awaddr;
   mAxiWriteMaster.awid(1 downto 0) <= mAxi_awid;
   mAxiWriteMaster.awlen   <= mAxi_awlen;
   mAxiWriteMaster.awsize  <= mAxi_awsize;
   mAxiWriteMaster.awburst <= mAxi_awburst;
   mAxiWriteMaster.awcache <= mAxi_awcache;
   mAxiWriteMaster.awprot  <= mAxi_awprot;
   mAxiWriteMaster.awqos   <= mAxi_awqos;
   mAxiWriteMaster.awregion<= mAxi_awregion;
   mAxiWriteMaster.wdata(511 downto 0) <= mAxi_wdata;
   mAxiWriteMaster.wlast   <= mAxi_wlast(0);
   mAxiWriteMaster.wvalid  <= mAxi_wvalid(0);
   mAxiWriteMaster.wstrb(63 downto 0) <= mAxi_wstrb;
   mAxiWriteMaster.bready  <= mAxi_bready(0);
   mAxi_awready(0) <= mAxiWriteSlave.awready;
   mAxi_wready(0)  <= mAxiWriteSlave.wready;
   mAxi_bvalid(0)  <= mAxiWriteSlave.bvalid;
   mAxi_bresp      <= mAxiWriteSlave.bresp;
   mAxi_bid        <= mAxiWriteSlave.bid(1 downto 0);
   mAxiReadMaster.arvalid <= mAxi_arvalid(0);
   mAxiReadMaster.araddr  <= mAxi_araddr;
   mAxiReadMaster.arid(1 downto 0) <= mAxi_arid;
   mAxiReadMaster.arlen   <= mAxi_arlen;
   mAxiReadMaster.arsize  <= mAxi_arsize;
   mAxiReadMaster.arburst <= mAxi_arburst;
   mAxiReadMaster.arcache <= mAxi_arcache;
   mAxiReadMaster.arprot  <= mAxi_arprot;
   mAxiReadMaster.arqos   <= mAxi_arqos;
   mAxiReadMaster.arregion<= mAxi_arregion;
   mAxiReadMaster.rready  <= mAxi_rready(0);
   mAxi_arready(0) <= mAxiReadSlave.arready;
   mAxi_rvalid(0)  <= mAxiReadSlave.rvalid;
   mAxi_rdata      <= mAxiReadSlave.rdata(511 downto 0);
   mAxi_rlast(0)   <= mAxiReadSlave.rlast;
   mAxi_rresp      <= mAxiReadSlave.rresp;
   mAxi_rid        <= mAxiReadSlave.rid(1 downto 0);

   -- BAR0 AXI4 reg path to the Core's AxiPcieReg (full SLAC BAR0 map: AGEN2
   -- @0x0, AxiVersion @0x20000 with the offset-discovery table datadev needs,
   -- PHY, PROM). AxiPcieReg takes AXI4 reg masters directly (NO AxiToAxiLite),
   -- converting to its internal AXI-Lite crossbar. The AGEN2/DMA slot comes
   -- back down as the shim AXI-Lite below.
   regReadMaster  <= mAxiReadMaster;
   mAxiReadSlave  <= regReadSlave;
   regWriteMaster <= mAxiWriteMaster;
   mAxiWriteSlave <= regWriteSlave;

   -- First host BAR0 register access (PCIe link up + CPM5 enumerated). This
   -- gates the CpmManager BDF-table programming (see IDLE_S). qdma-test left
   -- this CpmManager input unconnected; restore the commit da066b5 intent
   -- ("BDF table set on first BAR0 access") on the QDMA-mode register path.
   hostAccess <= mAxiWriteMaster.awvalid or mAxiReadMaster.arvalid;

   ----------------------------------------------------------------------------
   -- AxisG2 BAR0 register shim (datadev-compatible AGEN2 register map). Its
   -- AXI-Lite slave is the AGEN2/DMA crossbar slot (dmaCtrl(0)) routed down
   -- from AxiPcieReg in the Core, so datadev reaches it via AxiVersion's
   -- REG_AXIS_GEN2 offset-table entry exactly as before.
   ----------------------------------------------------------------------------
   U_AxisG2RegShim : entity axi_pcie_core.AxisG2RegShim
      generic map (
         TPD_G => TPD_G)
      port map (
         clk             => clk,
         rstL            => rstL,
         axilReadMaster  => dmaCtrlReadMaster,
         axilReadSlave   => dmaCtrlReadSlave,
         axilWriteMaster => dmaCtrlWriteMaster,
         axilWriteSlave  => dmaCtrlWriteSlave,
         txSub           => txSub,
         txSubReady      => txSubReady,
         rxFree          => rxFree,
         rxFreeReady     => rxFreeReady,
         addrRdIndex     => addrRdIndex,
         addrRdData      => addrRdData,
         online          => shimOnline,
         intEnable       => open,
         contEnable      => open,
         dropEnable      => open,
         maxSize         => shimMaxSize,
         wrBase          => shimWrBase,
         hwIntReq        => cmptDoneInt,
         fifoReset       => open,
         acknowledge     => open,
         forceInt        => open,
         irqHoldOff      => open,
         interrupt       => shimInterrupt,
         -- Debug observability (host-readable counters @ BAR0 0x90..0xB0)
         dbgCtxtDone     => ctxtDone,
         dbgC2hBypValid  => dma1_c2h_byp_in_st_csh_valid,
         dbgC2hBypReady  => dma1_c2h_byp_in_st_csh_ready,
         dbgC2hStValid   => dma1_s_axis_c2h_tvalid,
         dbgC2hStReady   => dma1_s_axis_c2h_tready,
         dbgTmDscValid   => dma1_tm_dsc_sts_valid,
         dbgStartupDone  => cpmStartupDone,
         dbgCtxtState    => ctxtStatus);

   ----------------------------------------------------------------------------
   -- QDMA descriptor-bypass datapath adapter
   ----------------------------------------------------------------------------
   U_QdmaBypassAdapter : entity axi_pcie_core.QdmaBypassAdapter
      generic map (
         TPD_G             => TPD_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         clk          => clk,
         rstL         => rstL,
         pfchTag      => ctxtPfchTag,
         maxSize      => shimMaxSize,
         txSub        => txSub,
         txSubReady   => txSubReady,
         rxFree       => rxFree,
         rxFreeReady  => rxFreeReady,
         addrRdIndex  => addrRdIndex,
         addrRdData   => addrRdData,
         mAxisMaster  => dmaObMaster,
         mAxisSlave   => dmaObSlave,
         sAxisMaster  => dmaIbMaster,
         sAxisSlave   => dmaIbSlave,
         -- H2C bypass-in
         h2cBypAddr    => dma1_h2c_byp_in_st_addr,
         h2cBypLen     => dma1_h2c_byp_in_st_len,
         h2cBypCidx    => dma1_h2c_byp_in_st_cidx,
         h2cBypQid     => dma1_h2c_byp_in_st_qid,
         h2cBypFunc    => dma1_h2c_byp_in_st_func,
         h2cBypPortId  => dma1_h2c_byp_in_st_port_id,
         h2cBypSop     => dma1_h2c_byp_in_st_sop,
         h2cBypEop     => dma1_h2c_byp_in_st_eop,
         h2cBypSdi     => dma1_h2c_byp_in_st_sdi,
         h2cBypMrkrReq => dma1_h2c_byp_in_st_mrkr_req,
         h2cBypNoDma   => dma1_h2c_byp_in_st_no_dma,
         h2cBypError   => dma1_h2c_byp_in_st_error,
         h2cBypValid   => dma1_h2c_byp_in_st_valid,
         h2cBypReady   => dma1_h2c_byp_in_st_ready,
         -- C2H bypass-in
         c2hBypAddr    => dma1_c2h_byp_in_st_csh_addr,
         c2hBypQid     => dma1_c2h_byp_in_st_csh_qid,
         c2hBypFunc    => dma1_c2h_byp_in_st_csh_func,
         c2hBypPfchTag => dma1_c2h_byp_in_st_csh_pfch_tag,
         c2hBypPortId  => dma1_c2h_byp_in_st_csh_port_id,
         c2hBypError   => dma1_c2h_byp_in_st_csh_error,
         c2hBypValid   => dma1_c2h_byp_in_st_csh_valid,
         c2hBypReady   => dma1_c2h_byp_in_st_csh_ready,
         -- H2C stream data out
         h2cStData     => dma1_m_axis_h2c_tdata,
         h2cStMty      => dma1_m_axis_h2c_mty,
         h2cStLast     => dma1_m_axis_h2c_tlast,
         h2cStValid    => dma1_m_axis_h2c_tvalid,
         h2cStReady    => dma1_m_axis_h2c_tready,
         -- C2H stream data in
         c2hStData        => dma1_s_axis_c2h_tdata,
         c2hStCtrlLen     => dma1_s_axis_c2h_ctrl_len,
         c2hStCtrlQid     => dma1_s_axis_c2h_ctrl_qid,
         c2hStCtrlHasCmpt => dma1_s_axis_c2h_ctrl_has_cmpt,
         c2hStMty         => dma1_s_axis_c2h_mty,
         c2hStLast        => dma1_s_axis_c2h_tlast,
         c2hStValid       => dma1_s_axis_c2h_tvalid,
         c2hStReady       => dma1_s_axis_c2h_tready,
         -- C2H completion
         cmptData         => dma1_s_axis_c2h_cmpt_data,
         cmptSize         => dma1_s_axis_c2h_cmpt_size,
         cmptQid          => dma1_s_axis_c2h_cmpt_qid,
         cmptType         => dma1_s_axis_c2h_cmpt_cmpt_type,
         cmptWaitPldPktId => dma1_s_axis_c2h_cmpt_wait_pld_pkt_id,
         cmptColIdx       => dma1_s_axis_c2h_cmpt_col_idx,
         cmptErrIdx       => dma1_s_axis_c2h_cmpt_err_idx,
         cmptValid        => dma1_s_axis_c2h_cmpt_tvalid,
         cmptReady        => dma1_s_axis_c2h_cmpt_tready,
         cmptDone         => cmptDoneInt,
         -- Traffic manager status
         tmDscStsValid  => dma1_tm_dsc_sts_valid,
         tmDscStsQid    => dma1_tm_dsc_sts_qid,
         tmDscStsIrqArm => dma1_tm_dsc_sts_irq_arm,
         tmDscStsDir    => dma1_tm_dsc_sts_dir);


   -- Tie-offs for QDMA interfaces not driven by the adapter (PG347: unused
   -- *_ready/*_rdy inputs must be tied high; unused valids low):
   dma1_s_axis_c2h_ctrl_marker   <= '0';
   dma1_s_axis_c2h_ctrl_port_id  <= (others => '0');
   -- ctrl_has_cmpt is now driven per-chunk by the adapter (R3 fake-descriptor
   -- scheme): 0 on intermediate 4 KiB chunks, 1 only on a buffer-closing chunk.
   dma1_s_axis_c2h_ecc           <= (others => '0');
   dma1_s_axis_c2h_tcrc          <= (others => '0');
   -- cmpt_type / col_idx / err_idx / wait_pld_pkt_id are driven by the adapter
   -- (HAS_PLD, no color/error insert, per-packet pld_pkt_id).
   dma1_s_axis_c2h_cmpt_dpar          <= (others => '0');
   dma1_s_axis_c2h_cmpt_marker        <= '0';
   dma1_s_axis_c2h_cmpt_no_wrb_marker <= '0';
   dma1_s_axis_c2h_cmpt_port_id       <= (others => '0');
   dma1_s_axis_c2h_cmpt_user_trig     <= '0';
   dma1_tm_dsc_sts_rdy  <= '1';
   dma1_qsts_out_rdy    <= '1';
   dma1_st_rx_msg_tready <= '1';
   dma1_h2c_byp_out_ready <= '1';
   dma1_c2h_byp_out_ready <= '1';
   dma1_dsc_crdt_in_crdt  <= (others => '0');
   dma1_dsc_crdt_in_dir   <= '0';
   dma1_dsc_crdt_in_fence <= '0';
   dma1_dsc_crdt_in_qid   <= (others => '0');
   dma1_dsc_crdt_in_valid <= '0';
   -- Native QDMA user-interrupt interface is NOT used (did not deliver MSI on
   -- hardware). Tie it off; the IRQ is raised via the CpmManager -> S_AXI_LPD ->
   -- TX_IRQ_CSR path below.
   dma1_usr_irq_fnc   <= (others => '0');
   dma1_usr_irq_vec   <= (others => '0');
   dma1_usr_irq_valid <= '0';

   -------------------------------------------------------------------------
   -- PL MSI generator: on each shim interrupt, the payload-agnostic CpmManager
   -- writes int_set to the CPM5_DMA1 TX_IRQ_CSR (0xFCEA0E7C) over S_AXI_LPD,
   -- raising the PCIe MSI. This is the datadev-required interrupt (driver pushes
   -- descriptors only from its IRQ handler).
   --
   -- STARTUP_WRITES_G is composed here, where the meaning lives:
   --   1) NOC_CACHE_CONF_C : set the CPM5 NoC AxCACHE behavior on the PCIe BAR2 ->
   --      NOC_PMC_AXI_0 path (now routed through the NoC, not the AXI smartconnect).
   --   2) the flattened default BDF address-translation table (identity mapping).
   -- They are applied in this order (NoC cache config first, then BDF). Although
   -- QDMA addressing is descriptor-based and the bridge-mode BDF table looks like
   -- it should be skippable, direct testing showed the BDF writes are still needed
   -- for interrupt generation, so they are retained here.
   --
   -- NOTE: the NOC_CACHE_CONF_C values are specific to the current PCIe BAR2
   -- aperture / steering in the block design. If BAR2 changes, those register
   -- writes must be updated to match (see XilinxAlveoV80CpmManagerPkg).
   -------------------------------------------------------------------------
   U_CpmManager : entity axi_pcie_core.XilinxAlveoV80CpmManager
      generic map (
         TPD_G            => TPD_G,
         -- NoC cache-config writes ONLY. The bridge-mode BDF address-translation
         -- table (0xFCEA2420) is NOT required for MSI (the TX_IRQ_CSR path does not
         -- use it; a manual CSR poke delivers MSI with the BDF table zeroed), and in
         -- QDMA functional mode those writes do not ack -> they kept startupDone=0,
         -- which gates dmaIrq so the shim interrupt was never turned into an MSI.
         STARTUP_WRITES_G => NOC_CACHE_CONF_C)
      port map (
         clk             => clk,
         rstL            => rstL,
         dmaIrq          => shimInterrupt,
         startupDone     => cpmStartupDone,
         hostAccess      => hostAccess,
         axilWriteMaster => msiWriteMaster,
         axilWriteSlave  => msiWriteSlave,
         axilReadMaster  => msiReadMaster,
         axilReadSlave   => msiReadSlave);

   -------------------
   -- AXI PCIe IP Core
   -------------------
   U_AxiPcie : XilinxAlveoV80PcieBlockDesign
      port map (
         dma1_axis_c2h_dmawr_cmp              => dma1_axis_c2h_dmawr_cmp,
         dma1_axis_c2h_dmawr_port_id          => dma1_axis_c2h_dmawr_port_id,
         dma1_axis_c2h_dmawr_target_vch       => dma1_axis_c2h_dmawr_target_vch,
         dma1_axis_c2h_status_drop            => dma1_axis_c2h_status_drop,
         dma1_axis_c2h_status_error           => dma1_axis_c2h_status_error,
         dma1_axis_c2h_status_last            => dma1_axis_c2h_status_last,
         dma1_axis_c2h_status_qid             => dma1_axis_c2h_status_qid,
         dma1_axis_c2h_status_status_cmp      => dma1_axis_c2h_status_status_cmp,
         dma1_axis_c2h_status_valid           => dma1_axis_c2h_status_valid,
         dma1_c2h_byp_in_st_csh_addr          => dma1_c2h_byp_in_st_csh_addr,
         dma1_c2h_byp_in_st_csh_error         => dma1_c2h_byp_in_st_csh_error,
         dma1_c2h_byp_in_st_csh_func          => dma1_c2h_byp_in_st_csh_func,
         dma1_c2h_byp_in_st_csh_pfch_tag      => dma1_c2h_byp_in_st_csh_pfch_tag,
         dma1_c2h_byp_in_st_csh_port_id       => dma1_c2h_byp_in_st_csh_port_id,
         dma1_c2h_byp_in_st_csh_qid           => dma1_c2h_byp_in_st_csh_qid,
         dma1_c2h_byp_in_st_csh_ready         => dma1_c2h_byp_in_st_csh_ready,
         dma1_c2h_byp_in_st_csh_valid         => dma1_c2h_byp_in_st_csh_valid,
         dma1_c2h_byp_out_cidx                => dma1_c2h_byp_out_cidx,
         dma1_c2h_byp_out_dsc                 => dma1_c2h_byp_out_dsc,
         dma1_c2h_byp_out_dsc_sz              => dma1_c2h_byp_out_dsc_sz,
         dma1_c2h_byp_out_error               => dma1_c2h_byp_out_error,
         dma1_c2h_byp_out_fmt                 => dma1_c2h_byp_out_fmt,
         dma1_c2h_byp_out_func                => dma1_c2h_byp_out_func,
         dma1_c2h_byp_out_mm_chn              => dma1_c2h_byp_out_mm_chn,
         dma1_c2h_byp_out_pfch_tag            => dma1_c2h_byp_out_pfch_tag,
         dma1_c2h_byp_out_port_id             => dma1_c2h_byp_out_port_id,
         dma1_c2h_byp_out_qid                 => dma1_c2h_byp_out_qid,
         dma1_c2h_byp_out_ready               => dma1_c2h_byp_out_ready,
         dma1_c2h_byp_out_st_mm               => dma1_c2h_byp_out_st_mm,
         dma1_c2h_byp_out_valid               => dma1_c2h_byp_out_valid,
         dma1_dsc_crdt_in_crdt                => dma1_dsc_crdt_in_crdt,
         dma1_dsc_crdt_in_dir                 => dma1_dsc_crdt_in_dir,
         dma1_dsc_crdt_in_fence               => dma1_dsc_crdt_in_fence,
         dma1_dsc_crdt_in_qid                 => dma1_dsc_crdt_in_qid,
         dma1_dsc_crdt_in_rdy                 => dma1_dsc_crdt_in_rdy,
         dma1_dsc_crdt_in_valid               => dma1_dsc_crdt_in_valid,
         dma1_h2c_byp_in_st_addr              => dma1_h2c_byp_in_st_addr,
         dma1_h2c_byp_in_st_cidx              => dma1_h2c_byp_in_st_cidx,
         dma1_h2c_byp_in_st_eop               => dma1_h2c_byp_in_st_eop,
         dma1_h2c_byp_in_st_error             => dma1_h2c_byp_in_st_error,
         dma1_h2c_byp_in_st_func              => dma1_h2c_byp_in_st_func,
         dma1_h2c_byp_in_st_len               => dma1_h2c_byp_in_st_len,
         dma1_h2c_byp_in_st_mrkr_req          => dma1_h2c_byp_in_st_mrkr_req,
         dma1_h2c_byp_in_st_no_dma            => dma1_h2c_byp_in_st_no_dma,
         dma1_h2c_byp_in_st_port_id           => dma1_h2c_byp_in_st_port_id,
         dma1_h2c_byp_in_st_qid               => dma1_h2c_byp_in_st_qid,
         dma1_h2c_byp_in_st_ready             => dma1_h2c_byp_in_st_ready,
         dma1_h2c_byp_in_st_sdi               => dma1_h2c_byp_in_st_sdi,
         dma1_h2c_byp_in_st_sop               => dma1_h2c_byp_in_st_sop,
         dma1_h2c_byp_in_st_valid             => dma1_h2c_byp_in_st_valid,
         dma1_h2c_byp_out_cidx                => dma1_h2c_byp_out_cidx,
         dma1_h2c_byp_out_dsc                 => dma1_h2c_byp_out_dsc,
         dma1_h2c_byp_out_dsc_sz              => dma1_h2c_byp_out_dsc_sz,
         dma1_h2c_byp_out_error               => dma1_h2c_byp_out_error,
         dma1_h2c_byp_out_fmt                 => dma1_h2c_byp_out_fmt,
         dma1_h2c_byp_out_func                => dma1_h2c_byp_out_func,
         dma1_h2c_byp_out_mm_chn              => dma1_h2c_byp_out_mm_chn,
         dma1_h2c_byp_out_port_id             => dma1_h2c_byp_out_port_id,
         dma1_h2c_byp_out_qid                 => dma1_h2c_byp_out_qid,
         dma1_h2c_byp_out_ready               => dma1_h2c_byp_out_ready,
         dma1_h2c_byp_out_st_mm               => dma1_h2c_byp_out_st_mm,
         dma1_h2c_byp_out_valid               => dma1_h2c_byp_out_valid,
         dma1_m_axis_h2c_err                  => dma1_m_axis_h2c_err,
         dma1_m_axis_h2c_mdata                => dma1_m_axis_h2c_mdata,
         dma1_m_axis_h2c_mty                  => dma1_m_axis_h2c_mty,
         dma1_m_axis_h2c_port_id              => dma1_m_axis_h2c_port_id,
         dma1_m_axis_h2c_qid                  => dma1_m_axis_h2c_qid,
         dma1_m_axis_h2c_tcrc                 => dma1_m_axis_h2c_tcrc,
         dma1_m_axis_h2c_tdata                => dma1_m_axis_h2c_tdata,
         dma1_m_axis_h2c_tlast                => dma1_m_axis_h2c_tlast,
         dma1_m_axis_h2c_tready               => dma1_m_axis_h2c_tready,
         dma1_m_axis_h2c_tvalid               => dma1_m_axis_h2c_tvalid,
         dma1_m_axis_h2c_zero_byte            => dma1_m_axis_h2c_zero_byte,
         dma1_mgmt_cpl_dat                    => dma1_mgmt_cpl_dat,
         dma1_mgmt_cpl_rdy                    => dma1_mgmt_cpl_rdy,
         dma1_mgmt_cpl_sts                    => dma1_mgmt_cpl_sts,
         dma1_mgmt_cpl_vld                    => dma1_mgmt_cpl_vld,
         dma1_mgmt_req_adr                    => dma1_mgmt_req_adr,
         dma1_mgmt_req_cmd                    => dma1_mgmt_req_cmd,
         dma1_mgmt_req_dat                    => dma1_mgmt_req_dat,
         dma1_mgmt_req_fnc                    => dma1_mgmt_req_fnc,
         dma1_mgmt_req_msc                    => dma1_mgmt_req_msc,
         dma1_mgmt_req_rdy                    => dma1_mgmt_req_rdy,
         dma1_mgmt_req_vld                    => dma1_mgmt_req_vld,
         dma1_qsts_out_data                   => dma1_qsts_out_data,
         dma1_qsts_out_op                     => dma1_qsts_out_op,
         dma1_qsts_out_port_id                => dma1_qsts_out_port_id,
         dma1_qsts_out_qid                    => dma1_qsts_out_qid,
         dma1_qsts_out_rdy                    => dma1_qsts_out_rdy,
         dma1_qsts_out_vld                    => dma1_qsts_out_vld,
         dma1_s_axis_c2h_cmpt_cmpt_type       => dma1_s_axis_c2h_cmpt_cmpt_type,
         dma1_s_axis_c2h_cmpt_col_idx         => dma1_s_axis_c2h_cmpt_col_idx,
         dma1_s_axis_c2h_cmpt_data            => dma1_s_axis_c2h_cmpt_data,
         dma1_s_axis_c2h_cmpt_dpar            => dma1_s_axis_c2h_cmpt_dpar,
         dma1_s_axis_c2h_cmpt_err_idx         => dma1_s_axis_c2h_cmpt_err_idx,
         dma1_s_axis_c2h_cmpt_marker          => dma1_s_axis_c2h_cmpt_marker,
         dma1_s_axis_c2h_cmpt_no_wrb_marker   => dma1_s_axis_c2h_cmpt_no_wrb_marker,
         dma1_s_axis_c2h_cmpt_port_id         => dma1_s_axis_c2h_cmpt_port_id,
         dma1_s_axis_c2h_cmpt_qid             => dma1_s_axis_c2h_cmpt_qid,
         dma1_s_axis_c2h_cmpt_size            => dma1_s_axis_c2h_cmpt_size,
         dma1_s_axis_c2h_cmpt_tready          => dma1_s_axis_c2h_cmpt_tready,
         dma1_s_axis_c2h_cmpt_tvalid          => dma1_s_axis_c2h_cmpt_tvalid,
         dma1_s_axis_c2h_cmpt_user_trig       => dma1_s_axis_c2h_cmpt_user_trig,
         dma1_s_axis_c2h_cmpt_wait_pld_pkt_id => dma1_s_axis_c2h_cmpt_wait_pld_pkt_id,
         dma1_s_axis_c2h_ctrl_has_cmpt        => dma1_s_axis_c2h_ctrl_has_cmpt,
         dma1_s_axis_c2h_ctrl_len             => dma1_s_axis_c2h_ctrl_len,
         dma1_s_axis_c2h_ctrl_marker          => dma1_s_axis_c2h_ctrl_marker,
         dma1_s_axis_c2h_ctrl_port_id         => dma1_s_axis_c2h_ctrl_port_id,
         dma1_s_axis_c2h_ctrl_qid             => dma1_s_axis_c2h_ctrl_qid,
         dma1_s_axis_c2h_ecc                  => dma1_s_axis_c2h_ecc,
         dma1_s_axis_c2h_mty                  => dma1_s_axis_c2h_mty,
         dma1_s_axis_c2h_tcrc                 => dma1_s_axis_c2h_tcrc,
         dma1_s_axis_c2h_tdata                => dma1_s_axis_c2h_tdata,
         dma1_s_axis_c2h_tlast                => dma1_s_axis_c2h_tlast,
         dma1_s_axis_c2h_tready               => dma1_s_axis_c2h_tready,
         dma1_s_axis_c2h_tvalid               => dma1_s_axis_c2h_tvalid,
         dma1_st_rx_msg_tdata                 => dma1_st_rx_msg_tdata,
         dma1_st_rx_msg_tlast                 => dma1_st_rx_msg_tlast,
         dma1_st_rx_msg_tready                => dma1_st_rx_msg_tready,
         dma1_st_rx_msg_tvalid                => dma1_st_rx_msg_tvalid,
         dma1_tm_dsc_sts_avl                  => dma1_tm_dsc_sts_avl,
         dma1_tm_dsc_sts_byp                  => dma1_tm_dsc_sts_byp,
         dma1_tm_dsc_sts_dir                  => dma1_tm_dsc_sts_dir,
         dma1_tm_dsc_sts_error                => dma1_tm_dsc_sts_error,
         dma1_tm_dsc_sts_irq_arm              => dma1_tm_dsc_sts_irq_arm,
         dma1_tm_dsc_sts_mm                   => dma1_tm_dsc_sts_mm,
         dma1_tm_dsc_sts_pidx                 => dma1_tm_dsc_sts_pidx,
         dma1_tm_dsc_sts_port_id              => dma1_tm_dsc_sts_port_id,
         dma1_tm_dsc_sts_qen                  => dma1_tm_dsc_sts_qen,
         dma1_tm_dsc_sts_qid                  => dma1_tm_dsc_sts_qid,
         dma1_tm_dsc_sts_qinv                 => dma1_tm_dsc_sts_qinv,
         dma1_tm_dsc_sts_rdy                  => dma1_tm_dsc_sts_rdy,
         dma1_tm_dsc_sts_valid                => dma1_tm_dsc_sts_valid,
         dma1_usr_irq_ack                     => dma1_usr_irq_ack,
         dma1_usr_irq_fail                    => dma1_usr_irq_fail,
         dma1_usr_irq_fnc                     => dma1_usr_irq_fnc,
         dma1_usr_irq_valid                   => dma1_usr_irq_valid,
         dma1_usr_irq_vec                     => dma1_usr_irq_vec,
         dmaClk                               => clk,
         dmaRstN                              => plRstN,
         gtPcieRefClk_clk_n                   => pciRefClkN,
         gtPcieRefClk_clk_p                   => pciRefClkP,
         gtPcie_grx_n                         => pciRxN,
         gtPcie_grx_p                         => pciRxP,
         gtPcie_gtx_n                         => pciTxN,
         gtPcie_gtx_p                         => pciTxP,
         mAxi_araddr                          => mAxi_araddr,
         mAxi_arburst                         => mAxi_arburst,
         mAxi_arcache                         => mAxi_arcache,
         mAxi_arid                            => mAxi_arid,
         mAxi_arlen                           => mAxi_arlen,
         mAxi_arlock                          => mAxi_arlock,
         mAxi_arprot                          => mAxi_arprot,
         mAxi_arqos                           => mAxi_arqos,
         mAxi_arready                         => mAxi_arready,
         mAxi_arregion                        => mAxi_arregion,
         mAxi_arsize                          => mAxi_arsize,
         mAxi_aruser                          => mAxi_aruser,
         mAxi_arvalid                         => mAxi_arvalid,
         mAxi_awaddr                          => mAxi_awaddr,
         mAxi_awburst                         => mAxi_awburst,
         mAxi_awcache                         => mAxi_awcache,
         mAxi_awid                            => mAxi_awid,
         mAxi_awlen                           => mAxi_awlen,
         mAxi_awlock                          => mAxi_awlock,
         mAxi_awprot                          => mAxi_awprot,
         mAxi_awqos                           => mAxi_awqos,
         mAxi_awready                         => mAxi_awready,
         mAxi_awregion                        => mAxi_awregion,
         mAxi_awsize                          => mAxi_awsize,
         mAxi_awuser                          => mAxi_awuser,
         mAxi_awvalid                         => mAxi_awvalid,
         mAxi_bid                             => mAxi_bid,
         mAxi_bready                          => mAxi_bready,
         mAxi_bresp                           => mAxi_bresp,
         mAxi_bvalid                          => mAxi_bvalid,
         mAxi_rdata                           => mAxi_rdata,
         mAxi_rid                             => mAxi_rid,
         mAxi_rlast                           => mAxi_rlast,
         mAxi_rready                          => mAxi_rready,
         mAxi_rresp                           => mAxi_rresp,
         mAxi_rvalid                          => mAxi_rvalid,
         mAxi_wdata                           => mAxi_wdata,
         mAxi_wlast                           => mAxi_wlast,
         mAxi_wready                          => mAxi_wready,
         mAxi_wstrb                           => mAxi_wstrb,
         mAxi_wvalid                          => mAxi_wvalid,
         -- plRefClk is the BD's GENERATED PL reference clock OUTPUT; it must
         -- feed back into the internal clk that drives the PL (adapter, shim,
         -- ctxt-init, and axiClk -> the whole app). Leaving it 'open' left clk
         -- undriven -> no clock -> all PL logic (incl. the PRBS app) optimized
         -- away, no netlist, no timing. (Matches the original bridge wiring.)
         plRefClk                             => clk,
         plRstN                               => plRstN,
         pciRstN                              => pciRstN,
         psDDR_act_n                          => psDdrActN,
         psDDR_adr                            => psDdrAdr,
         psDDR_ba                             => psDdrBa,
         psDDR_bg                             => psDdrBg,
         psDDR_ck_c                           => psDdrCkC,
         psDDR_ck_t                           => psDdrCkT,
         psDDR_cke                            => psDdrCke,
         psDDR_cs_n                           => psDdrCsN,
         psDDR_dm_n                           => psDdrDmN,
         psDDR_dq                             => psDdrDq,
         psDDR_dqs_c                          => psDdrDqsC,
         psDDR_dqs_t                          => psDdrDqsT,
         psDDR_odt                            => psDdrOdt,
         psDDR_reset_n                        => psDdrResetN,
         psDdrClk_clk_n                       => psDdrClkN,
         psDdrClk_clk_p                       => psDdrClkP,
         -- S_AXI_LPD slave driven by CpmManager's AXI-Lite master (single-beat
         -- 32-bit writes to the CPM5 TX_IRQ_CSR to raise the MSI).
         sAxiLpd_araddr(31 downto 0)          => msiReadMaster.araddr(31 downto 0),
         sAxiLpd_araddr(48 downto 32)         => (others => '0'),
         sAxiLpd_arburst                      => "01",
         sAxiLpd_arcache                      => "0011",
         sAxiLpd_arlen                        => (others => '0'),
         sAxiLpd_arlock                       => '0',
         sAxiLpd_arprot                       => msiReadMaster.arprot,
         sAxiLpd_arqos                        => (others => '0'),
         sAxiLpd_arready                      => msiReadSlave.arready,
         sAxiLpd_arsize                       => "010",
         sAxiLpd_arvalid                      => msiReadMaster.arvalid,
         sAxiLpd_awaddr(31 downto 0)          => msiWriteMaster.awaddr(31 downto 0),
         sAxiLpd_awaddr(48 downto 32)         => (others => '0'),
         sAxiLpd_awburst                      => "01",
         sAxiLpd_awcache                      => "0011",
         sAxiLpd_awlen                        => (others => '0'),
         sAxiLpd_awlock                       => '0',
         sAxiLpd_awprot                       => msiWriteMaster.awprot,
         sAxiLpd_awqos                        => (others => '0'),
         sAxiLpd_awready                      => msiWriteSlave.awready,
         sAxiLpd_awsize                       => "010",
         sAxiLpd_awvalid                      => msiWriteMaster.awvalid,
         sAxiLpd_bready                       => msiWriteMaster.bready,
         sAxiLpd_bresp                        => msiWriteSlave.bresp,
         sAxiLpd_bvalid                       => msiWriteSlave.bvalid,
         sAxiLpd_rdata                        => msiReadSlave.rdata(31 downto 0),
         sAxiLpd_rlast                        => open,
         sAxiLpd_rready                       => msiReadMaster.rready,
         sAxiLpd_rresp                        => msiReadSlave.rresp,
         sAxiLpd_rvalid                       => msiReadSlave.rvalid,
         sAxiLpd_wdata                        => msiWriteMaster.wdata(31 downto 0),
         sAxiLpd_wlast                        => '1',
         sAxiLpd_wready                       => msiWriteSlave.wready,
         sAxiLpd_wstrb                        => msiWriteMaster.wstrb(3 downto 0),
         sAxiLpd_wvalid                       => msiWriteMaster.wvalid      );

end mapping;
