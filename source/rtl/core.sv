/*
    Filename: core.sv
    Author: zlagpacan
    Description: RTL for CPU Core
    Spec: LOROF/spec/design/core.md
*/

`include "core_types_pkg.vh"
import core_types_pkg::*;

`include "system_types_pkg.vh"
import system_types_pkg::*;

module core #(
    parameter FETCH_UNIT_WAIT_FOR_RESTART_STATE = 1'b1,
    parameter ROB_RESTART_ON_RESET = 1'b1,

    parameter INIT_PC = 32'h00000000,
    parameter INIT_ASID = 9'h000,
    parameter INIT_EXEC_MODE = M_MODE,
    parameter INIT_VIRTUAL_MODE = 1'b0,
    parameter INIT_MXR = 1'b0,
    parameter INIT_SUM = 1'b0,
	parameter INIT_TRAP_SFENCE = 1'b0,
	parameter INIT_TRAP_WFI = 1'b0,
	parameter INIT_TRAP_SRET = 1'b0,
    parameter INIT_TVEC_BASE_PC = 32'h0000F000
) (
    // seq
    input logic CLK,
    input logic nRST,

    // itlb req
    output logic                    itlb_req_valid,
    output logic [1:0]              itlb_req_exec_mode,
    output logic                    itlb_req_virtual_mode,
    output logic [ASID_WIDTH-1:0]   itlb_req_ASID,
    output logic [VPN_WIDTH-1:0]    itlb_req_VPN,

    // itlb resp
    input logic                     itlb_resp_valid,
    input logic [PPN_WIDTH-1:0]     itlb_resp_PPN,
    input logic                     itlb_resp_page_fault,
    input logic                     itlb_resp_access_fault,

    // icache req
    output logic                                        icache_req_valid,
    output logic [ICACHE_FETCH_BLOCK_OFFSET_WIDTH-1:0]  icache_req_block_offset,
    output logic [ICACHE_INDEX_WIDTH-1:0]               icache_req_index,

    // icache resp
    input logic [1:0]                                   icache_resp_valid_by_way,
    input logic [1:0][ICACHE_TAG_WIDTH-1:0]             icache_resp_tag_by_way,
    input logic [1:0][ICACHE_FETCH_WIDTH-1:0][7:0]      icache_resp_instr_16B_by_way,

    // icache resp feedback
    output logic                                        icache_resp_hit_valid,
    output logic                                        icache_resp_hit_way,
    output logic                                        icache_resp_miss_valid,
    output logic [ICACHE_TAG_WIDTH-1:0]                 icache_resp_miss_tag,

    // dtlb req
    output logic                    dtlb_req_bank0_valid,
    output logic [1:0]              dtlb_req_bank0_exec_mode,
    output logic                    dtlb_req_bank0_virtual_mode,
    output logic [ASID_WIDTH-1:0]   dtlb_req_bank0_ASID,
    output logic                    dtlb_req_bank0_MXR,
    output logic                    dtlb_req_bank0_SUM,
    output logic [VPN_WIDTH-1:0]    dtlb_req_bank0_VPN,
    output logic                    dtlb_req_bank0_is_read,
    output logic                    dtlb_req_bank0_is_write,
    
    output logic                    dtlb_req_bank1_valid,
    output logic [1:0]              dtlb_req_bank1_exec_mode,
    output logic                    dtlb_req_bank1_virtual_mode,
    output logic [ASID_WIDTH-1:0]   dtlb_req_bank1_ASID,
    output logic                    dtlb_req_bank1_MXR,
    output logic                    dtlb_req_bank1_SUM,
    output logic [VPN_WIDTH-1:0]    dtlb_req_bank1_VPN,
    output logic                    dtlb_req_bank1_is_read,
    output logic                    dtlb_req_bank1_is_write,

    // dtlb req feedback
    input logic                     dtlb_req_bank0_ready,

    input logic                     dtlb_req_bank1_ready,

    // dtlb resp
    input logic                     dtlb_resp_bank0_hit,
    input logic [PPN_WIDTH-1:0]     dtlb_resp_bank0_PPN,
    input logic                     dtlb_resp_bank0_is_mem,
    input logic                     dtlb_resp_bank0_page_fault,
    input logic                     dtlb_resp_bank0_access_fault,
    
    input logic                     dtlb_resp_bank1_hit,
    input logic [PPN_WIDTH-1:0]     dtlb_resp_bank1_PPN,
    input logic                     dtlb_resp_bank1_is_mem,
    input logic                     dtlb_resp_bank1_page_fault,
    input logic                     dtlb_resp_bank1_access_fault,

    // dcache req
    output logic                                    dcache_req_bank0_valid,
    output logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]    dcache_req_bank0_block_offset,
    output logic [DCACHE_INDEX_WIDTH-1:0]           dcache_req_bank0_index,
    output logic                                    dcache_req_bank0_is_ldu,
    output logic [LOG_LDU_CQ_ENTRIES-1:0]           dcache_req_bank0_cq_index,
    output logic                                    dcache_req_bank0_is_mq,
    output logic [LOG_LDU_MQ_ENTRIES-1:0]           dcache_req_bank0_mq_index,
    
    output logic                                    dcache_req_bank1_valid,
    output logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]    dcache_req_bank1_block_offset,
    output logic [DCACHE_INDEX_WIDTH-1:0]           dcache_req_bank1_index,
    output logic                                    dcache_req_bank1_is_ldu,
    output logic [LOG_LDU_CQ_ENTRIES-1:0]           dcache_req_bank1_cq_index,
    output logic                                    dcache_req_bank1_is_mq,
    output logic [LOG_LDU_MQ_ENTRIES-1:0]           dcache_req_bank1_mq_index,

    // dcache req feedback
    input logic                                     dcache_req_bank0_ready,
    
    input logic                                     dcache_req_bank1_ready,

    // dcache resp
    input logic [1:0]                               dcache_resp_bank0_valid_by_way,
    input logic [1:0]                               dcache_resp_bank0_exclusive_by_way,
    input logic [1:0][DCACHE_TAG_WIDTH-1:0]         dcache_resp_bank0_tag_by_way,
    input logic [1:0][31:0]                         dcache_resp_bank0_data_by_way,
    
    input logic [1:0]                               dcache_resp_bank1_valid_by_way,
    input logic [1:0]                               dcache_resp_bank1_exclusive_by_way,
    input logic [1:0][DCACHE_TAG_WIDTH-1:0]         dcache_resp_bank1_tag_by_way,
    input logic [1:0][31:0]                         dcache_resp_bank1_data_by_way,
    
    // dcache resp feedback
    output logic                            dcache_resp_bank0_hit_valid,
    output logic                            dcache_resp_bank0_hit_exclusive,
    output logic                            dcache_resp_bank0_hit_way,
    output logic                            dcache_resp_bank0_miss_valid,
    output logic                            dcache_resp_bank0_miss_prefetch,
    output logic                            dcache_resp_bank0_miss_exclusive,
    output logic [DCACHE_TAG_WIDTH-1:0]     dcache_resp_bank0_miss_tag,
    
    output logic                            dcache_resp_bank1_hit_valid,
    output logic                            dcache_resp_bank1_hit_exclusive,
    output logic                            dcache_resp_bank1_hit_way,
    output logic                            dcache_resp_bank1_miss_valid,
    output logic                            dcache_resp_bank1_miss_prefetch,
    output logic                            dcache_resp_bank1_miss_exclusive,
    output logic [DCACHE_TAG_WIDTH-1:0]     dcache_resp_bank1_miss_tag,

    // write buffer WB data to PRF
    input logic                         wr_buf_WB_valid,
    input logic [31:0]                  wr_buf_WB_data,
    input logic [LOG_PR_COUNT-1:0]      wr_buf_WB_PR,
        // don't need ROB_index as WB_send_complete = 1'b0

    // write buffer WB feedback from PRF
    output logic                        wr_buf_WB_ready,

    // hardware failure
    output logic unrecoverable_fault
);
    // Modules:

        // Front End
            // fetch_unit
            // istream
            // decode_unit

        // Central
            // prf
            // rob

        // Back End

            // alu_reg_mdu
                // alu_reg_mdu_dq
                // alu_reg_mdu_iq_single
                // alu_reg_pipeline_fast
                // mdu_pipeline

            // alu_imm
                // alu_imm_dq
                // alu_imm_iq
                // alu_imm_pipeline_fast

            // bru
                // bru_dq
                // bru_iq
                // bru_pipeline_fast

            // lsu

                // ldu
                    // ldu_dq
                    // ldu_iq
                    // ldu_addr_pipeline
                    // 2x ldu_launch_pipeline
                    // ldu_cq
                    // ldu_mq

                // stamofu
                    // stamofu_dq
                    // stamofu_iq
                    // stamofu_aq
                    // stamofu_addr_pipeline
                    // 2x stamofu_lq
                    // 2x stamofu_launch_pipeline
                    // stamofu_cq
                    // stamofu_mq

                // ssu

            // sysu
                // sysu_dq
                // sysu_pipeline
                // csrf

    // ----------------------------------------------------------------
    // Signals:

    // dtlb req
    logic                           ldu_launch_pipeline_dtlb_req_bank0_valid;
    logic [VPN_WIDTH-1:0]           ldu_launch_pipeline_dtlb_req_bank0_VPN;

    logic                           ldu_launch_pipeline_dtlb_req_bank1_valid;
    logic [VPN_WIDTH-1:0]           ldu_launch_pipeline_dtlb_req_bank1_VPN;
    
    logic                           stamofu_launch_pipeline_dtlb_req_bank0_valid;
    logic [VPN_WIDTH-1:0]           stamofu_launch_pipeline_dtlb_req_bank0_VPN;
    logic                           stamofu_launch_pipeline_dtlb_req_bank0_is_read;
    logic                           stamofu_launch_pipeline_dtlb_req_bank0_is_write;

    logic                           stamofu_launch_pipeline_dtlb_req_bank1_valid;
    logic [VPN_WIDTH-1:0]           stamofu_launch_pipeline_dtlb_req_bank1_VPN;
    logic                           stamofu_launch_pipeline_dtlb_req_bank1_is_read;
    logic                           stamofu_launch_pipeline_dtlb_req_bank1_is_write;

    // dtlb req feedback
    logic                           ldu_launch_pipeline_dtlb_req_bank0_ready;

    logic                           ldu_launch_pipeline_dtlb_req_bank1_ready;
    
    logic                           stamofu_launch_pipeline_dtlb_req_bank0_ready;

    logic                           stamofu_launch_pipeline_dtlb_req_bank1_ready;
    
    // dcache req
    logic                                   ldu_launch_pipeline_dcache_req_bank0_valid;
    logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]   ldu_launch_pipeline_dcache_req_bank0_block_offset;
    logic [DCACHE_INDEX_WIDTH-1:0]          ldu_launch_pipeline_dcache_req_bank0_index;
    logic [LOG_LDU_CQ_ENTRIES-1:0]          ldu_launch_pipeline_dcache_req_bank0_cq_index;
    logic                                   ldu_launch_pipeline_dcache_req_bank0_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]          ldu_launch_pipeline_dcache_req_bank0_mq_index;

    logic                                   ldu_launch_pipeline_dcache_req_bank1_valid;
    logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]   ldu_launch_pipeline_dcache_req_bank1_block_offset;
    logic [DCACHE_INDEX_WIDTH-1:0]          ldu_launch_pipeline_dcache_req_bank1_index;
    logic [LOG_LDU_CQ_ENTRIES-1:0]          ldu_launch_pipeline_dcache_req_bank1_cq_index;
    logic                                   ldu_launch_pipeline_dcache_req_bank1_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]          ldu_launch_pipeline_dcache_req_bank1_mq_index;
    
    logic                                   stamofu_launch_pipeline_dcache_req_bank0_valid;
    logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]   stamofu_launch_pipeline_dcache_req_bank0_block_offset;
    logic [DCACHE_INDEX_WIDTH-1:0]          stamofu_launch_pipeline_dcache_req_bank0_index;
    logic [LOG_LDU_CQ_ENTRIES-1:0]          stamofu_launch_pipeline_dcache_req_bank0_cq_index;
    logic                                   stamofu_launch_pipeline_dcache_req_bank0_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]          stamofu_launch_pipeline_dcache_req_bank0_mq_index;

    logic                                   stamofu_launch_pipeline_dcache_req_bank1_valid;
    logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]   stamofu_launch_pipeline_dcache_req_bank1_block_offset;
    logic [DCACHE_INDEX_WIDTH-1:0]          stamofu_launch_pipeline_dcache_req_bank1_index;
    logic [LOG_LDU_CQ_ENTRIES-1:0]          stamofu_launch_pipeline_dcache_req_bank1_cq_index;
    logic                                   stamofu_launch_pipeline_dcache_req_bank1_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]          stamofu_launch_pipeline_dcache_req_bank1_mq_index;

    // dcache req feedback
    logic                                   ldu_launch_pipeline_dcache_req_bank0_ready;

    logic                                   ldu_launch_pipeline_dcache_req_bank1_ready;

    logic                                   stamofu_launch_pipeline_dcache_req_bank0_ready;

    logic                                   stamofu_launch_pipeline_dcache_req_bank1_ready;

    // dcache resp feedback
    logic                           ldu_launch_pipeline_dcache_resp_bank0_hit_valid;
    logic                           ldu_launch_pipeline_dcache_resp_bank0_hit_way;
    logic                           ldu_launch_pipeline_dcache_resp_bank0_miss_valid;
    logic [DCACHE_TAG_WIDTH-1:0]    ldu_launch_pipeline_dcache_resp_bank0_miss_tag;
    
    logic                           ldu_launch_pipeline_dcache_resp_bank1_hit_valid;
    logic                           ldu_launch_pipeline_dcache_resp_bank1_hit_way;
    logic                           ldu_launch_pipeline_dcache_resp_bank1_miss_valid;
    logic [DCACHE_TAG_WIDTH-1:0]    ldu_launch_pipeline_dcache_resp_bank1_miss_tag;

    logic                           stamofu_launch_pipeline_dcache_resp_bank0_hit_valid;
    logic                           stamofu_launch_pipeline_dcache_resp_bank0_hit_exclusive;
    logic                           stamofu_launch_pipeline_dcache_resp_bank0_hit_way;
    logic                           stamofu_launch_pipeline_dcache_resp_bank0_miss_valid;
    logic                           stamofu_launch_pipeline_dcache_resp_bank0_miss_prefetch;
    logic                           stamofu_launch_pipeline_dcache_resp_bank0_miss_exclusive;
    logic [DCACHE_TAG_WIDTH-1:0]    stamofu_launch_pipeline_dcache_resp_bank0_miss_tag;
    
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_hit_valid;
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_hit_exclusive;
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_hit_way;
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_miss_valid;
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_miss_prefetch;
    logic                           stamofu_launch_pipeline_dcache_resp_bank1_miss_exclusive;
    logic [DCACHE_TAG_WIDTH-1:0]    stamofu_launch_pipeline_dcache_resp_bank1_miss_tag;

    // output to istream
    logic                                   istream_valid_SENQ;
    logic [7:0]                             istream_valid_by_fetch_2B_SENQ;
    logic [7:0]                             istream_one_hot_redirect_by_fetch_2B_SENQ;
    logic [7:0][15:0]                       istream_instr_2B_by_fetch_2B_SENQ;
    logic [7:0][BTB_PRED_INFO_WIDTH-1:0]    istream_pred_info_by_fetch_2B_SENQ;
    logic [7:0]                             istream_pred_lru_by_fetch_2B_SENQ;
    logic [7:0][MDPT_INFO_WIDTH-1:0]        istream_mdp_info_by_fetch_2B_SENQ;
    logic [31:0]                            istream_after_PC_SENQ;
    logic [LH_LENGTH-1:0]                   istream_LH_SENQ;
    logic [GH_LENGTH-1:0]                   istream_GH_SENQ;
    logic [RAS_INDEX_WIDTH-1:0]             istream_ras_index_SENQ;
    logic                                   istream_page_fault_SENQ;
    logic                                   istream_access_fault_SENQ;

    // istream feedback
    logic istream_stall_SENQ;

    // restart from ROB
    logic                   rob_restart_valid;
    logic [31:0]            rob_restart_PC;
    logic [ASID_WIDTH-1:0]  rob_restart_ASID;
    logic [1:0]             rob_restart_exec_mode;
    logic                   rob_restart_virtual_mode;
    logic                   rob_restart_MXR;
    logic                   rob_restart_SUM;
    logic                   rob_restart_trap_sfence;
    logic                   rob_restart_trap_wfi;
    logic                   rob_restart_trap_sret;

    // decode unit control
    logic           decode_unit_restart_valid;
    logic [31:0]    decode_unit_restart_PC;

    logic           decode_unit_trigger_wait_for_restart;

    // branch update from decode unit
    logic                               decode_unit_branch_update_valid;
    logic                               decode_unit_branch_update_has_checkpoint;
    logic                               decode_unit_branch_update_is_mispredict;
    logic                               decode_unit_branch_update_is_taken;
    logic                               decode_unit_branch_update_is_complex;
    logic                               decode_unit_branch_update_use_upct;
    logic [BTB_PRED_INFO_WIDTH-1:0]     decode_unit_branch_update_intermediate_pred_info;
    logic                               decode_unit_branch_update_pred_lru;
    logic [31:0]                        decode_unit_branch_update_start_PC;
    logic [31:0]                        decode_unit_branch_update_target_PC;
    logic [LH_LENGTH-1:0]               decode_unit_branch_update_LH;
    logic [GH_LENGTH-1:0]               decode_unit_branch_update_GH;
    logic [RAS_INDEX_WIDTH-1:0]         decode_unit_branch_update_ras_index;

    // mdpt update
    logic                           fetch_unit_mdpt_update_valid;
    logic [31:0]                    fetch_unit_mdpt_update_start_full_PC;
    logic [ASID_WIDTH-1:0]          fetch_unit_mdpt_update_ASID;
    logic [MDPT_INFO_WIDTH-1:0]     fetch_unit_mdpt_update_mdp_info;

    // input from istream
    logic                                       istream_valid_SDEQ;
    logic [3:0]                                 istream_valid_by_way_SDEQ;
    logic [3:0]                                 istream_uncompressed_by_way_SDEQ;
    logic [3:0][1:0][15:0]                      istream_instr_2B_by_way_by_chunk_SDEQ;
    logic [3:0][1:0][BTB_PRED_INFO_WIDTH-1:0]   istream_pred_info_by_way_by_chunk_SDEQ;
    logic [3:0][1:0]                            istream_pred_lru_by_way_by_chunk_SDEQ;
    logic [3:0][1:0][31:0]                      istream_pred_PC_by_way_by_chunk_SDEQ;
    logic [3:0][1:0]                            istream_page_fault_by_way_by_chunk_SDEQ;
    logic [3:0][1:0]                            istream_access_fault_by_way_by_chunk_SDEQ;
    logic [3:0][MDPT_INFO_WIDTH-1:0]            istream_mdp_info_by_way_SDEQ;
    logic [3:0][31:0]                           istream_PC_by_way_SDEQ;
    logic [3:0][LH_LENGTH-1:0]                  istream_LH_by_way_SDEQ;
    logic [3:0][GH_LENGTH-1:0]                  istream_GH_by_way_SDEQ;
    logic [3:0][RAS_INDEX_WIDTH-1:0]            istream_ras_index_by_way_SDEQ;

    // feedback to istream
    logic istream_stall_SDEQ;

    // op dispatch by way:

    // 4-way ROB entry
    logic dispatch_rob_enq_valid;
	logic dispatch_rob_enq_killed;

    // ROB dispatch feedback
    logic                               dispatch_rob_enq_ready;
    logic [3:0][LOG_ROB_ENTRIES-1:0]    dispatch_rob_enq_ROB_index_by_way;

    // general instr info
    logic [3:0]                             dispatch_valid_by_way;
    logic [3:0]                             dispatch_uncompressed_by_way;
    logic [3:0][31:0]                       dispatch_PC_by_way;
    logic [3:0][31:0]                       dispatch_pred_PC_by_way;
    logic [3:0]                             dispatch_is_rename_by_way;
    logic [3:0][BTB_PRED_INFO_WIDTH-1:0]    dispatch_pred_info_by_way;
    logic [3:0]                             dispatch_pred_lru_by_way;
    logic [3:0][MDPT_INFO_WIDTH-1:0]        dispatch_mdp_info_by_way;
    logic [3:0][3:0]                        dispatch_op_by_way;
    logic [3:0][19:0]                       dispatch_imm20_by_way;

    logic [3:0][11:0]                       dispatch_imm12_by_way;

    // ordering
    logic [3:0]                             dispatch_mem_aq_by_way;
    logic [3:0]                             dispatch_io_aq_by_way;
    logic [3:0]                             dispatch_mem_rl_by_way;
    logic [3:0]                             dispatch_io_rl_by_way;

    // exception info
    logic                                   dispatch_is_page_fault;
    logic                                   dispatch_is_access_fault;
    logic                                   dispatch_is_illegal_instr;
	logic 							        dispatch_exception_present;
	logic [1:0]						        dispatch_exception_index;
    logic [31:0]                            dispatch_illegal_instr32;

	// checkpoint info
	logic								    dispatch_has_checkpoint;
	logic [CHECKPOINT_INDEX_WIDTH-1:0]	    dispatch_checkpoint_index;

    // instr IQ attempts
    logic [3:0]                             dispatch_attempt_alu_reg_mdu_dq_by_way;
    logic [3:0]                             dispatch_attempt_alu_imm_dq_by_way;
    logic [3:0]                             dispatch_attempt_bru_dq_by_way;
	logic [3:0]					            dispatch_attempt_ldu_dq_by_way;
    logic [3:0]                             dispatch_attempt_stamofu_dq_by_way;
    logic [3:0]                             dispatch_attempt_sysu_dq_by_way;

    // instr FU valids
    logic [3:0]                             dispatch_valid_alu_reg_by_way;
    logic [3:0]                             dispatch_valid_mdu_by_way;
    logic [3:0]                             dispatch_valid_alu_imm_by_way;
    logic [3:0]                             dispatch_valid_bru_by_way;
    logic [3:0]                             dispatch_valid_ldu_by_way;
    logic [3:0]                             dispatch_valid_store_by_way;
    logic [3:0]                             dispatch_valid_amo_by_way;
    logic [3:0]                             dispatch_valid_fence_by_way;
    logic [3:0]                             dispatch_valid_sysu_by_way;

    // operand A
    logic [3:0][LOG_PR_COUNT-1:0]           dispatch_A_PR_by_way;
    logic [3:0]                             dispatch_A_ready_by_way;
	logic [3:0]						        dispatch_A_is_zero_by_way;
    logic [3:0]                             dispatch_A_unneeded_or_is_zero_by_way;
    logic [3:0]                             dispatch_A_is_ret_ra_by_way;

    // operand B
    logic [3:0][LOG_PR_COUNT-1:0]           dispatch_B_PR_by_way;
    logic [3:0]                             dispatch_B_ready_by_way;
	logic [3:0]						        dispatch_B_is_zero_by_way;
    logic [3:0]                             dispatch_B_unneeded_or_is_zero_by_way;

    // dest operand
    logic [3:0][4:0]            		    dispatch_dest_AR_by_way;
    logic [3:0][LOG_PR_COUNT-1:0]           dispatch_dest_old_PR_by_way;
    logic [3:0][LOG_PR_COUNT-1:0]           dispatch_dest_new_PR_by_way;
    logic [3:0]                             dispatch_dest_is_link_ra_by_way;

    // instr IQ acks
    logic [3:0] dispatch_ack_alu_reg_mdu_dq_by_way;
    logic [3:0] dispatch_ack_alu_imm_dq_by_way;
    logic [3:0] dispatch_ack_bru_dq_by_way;
    logic [3:0] dispatch_ack_ldu_dq_by_way;
    logic [3:0] dispatch_ack_stamofu_dq_by_way;
    logic [3:0] dispatch_ack_sysu_dq_by_way;

    // writeback bus by bank
    logic [PRF_BANK_COUNT-1:0]                                          WB_bus_valid_by_bank;
    logic [PRF_BANK_COUNT-1:0][LOG_PR_COUNT-LOG_PRF_BANK_COUNT-1:0]     WB_bus_upper_PR_by_bank;

    // ROB kill
    logic                           rob_kill_valid;
    logic [LOG_ROB_ENTRIES-1:0]     rob_kill_abs_head_index;
    logic [LOG_ROB_ENTRIES-1:0]     rob_kill_rel_kill_younger_index;

    // branch update from ROB
    logic                               rob_branch_update_valid;
    logic                               rob_branch_update_has_checkpoint;
	logic [CHECKPOINT_INDEX_WIDTH-1:0]  rob_branch_update_checkpoint_index;
    logic                               rob_branch_update_is_mispredict;
    logic                               rob_branch_update_is_taken;
    logic                               rob_branch_update_use_upct;
    logic [BTB_PRED_INFO_WIDTH-1:0]     rob_branch_update_intermediate_pred_info;
    logic                               rob_branch_update_pred_lru;
    logic [31:0]                        rob_branch_update_start_PC;
    logic [31:0]                        rob_branch_update_target_PC;

    // ROB control of rename
    logic                             	rob_controlling_rename;

    logic                               rob_checkpoint_map_table_restore_valid;
    logic [CHECKPOINT_INDEX_WIDTH-1:0]  rob_checkpoint_map_table_restore_index;

    logic                               rob_checkpoint_clear_valid;
    logic [CHECKPOINT_INDEX_WIDTH-1:0]  rob_checkpoint_clear_index;

    logic [3:0]                       	rob_map_table_write_valid_by_port;
    logic [3:0][LOG_AR_COUNT-1:0]     	rob_map_table_write_AR_by_port;
    logic [3:0][LOG_PR_COUNT-1:0]     	rob_map_table_write_PR_by_port;

	// ROB physical register freeing
	logic [3:0]                     rob_PR_free_req_valid_by_bank;
	logic [3:0][LOG_PR_COUNT-1:0]   rob_PR_free_req_PR_by_bank;
	logic [3:0]						rob_PR_free_resp_ack_by_bank;

    // read req info by read requester
    logic [PRF_RR_COUNT-1:0]                    prf_read_req_valid_by_rr;
    logic [PRF_RR_COUNT-1:0][LOG_PR_COUNT-1:0]  prf_read_req_PR_by_rr;

    logic ldu_PRF_req_A_valid;
    logic alu_reg_mdu_PRF_req_A_valid;
    logic alu_reg_mdu_PRF_req_B_valid;
    logic alu_imm_PRF_req_A_valid;
    logic bru_PRF_req_A_valid;
    logic bru_PRF_req_B_valid;
    logic stamofu_PRF_req_A_valid;
    logic stamofu_PRF_req_B_valid;
    logic sysu_PRF_req_A_valid;

    logic ldu_PRF_req_A_PR;
    logic alu_reg_mdu_PRF_req_A_PR;
    logic alu_reg_mdu_PRF_req_B_PR;
    logic alu_imm_PRF_req_A_PR;
    logic bru_PRF_req_A_PR;
    logic bru_PRF_req_B_PR;
    logic stamofu_PRF_req_A_PR;
    logic stamofu_PRF_req_B_PR;
    logic sysu_PRF_req_A_PR;

    // read resp info by read requestor
    logic [PRF_RR_COUNT-1:0]    prf_read_resp_ack_by_rr;
    logic [PRF_RR_COUNT-1:0]    prf_read_resp_port_by_rr;

    logic ldu_PRF_A_reg_read_ack;
    logic alu_reg_mdu_PRF_A_reg_read_ack;
    logic alu_reg_mdu_PRF_B_reg_read_ack;
    logic alu_imm_PRF_A_reg_read_ack;
    logic bru_PRF_A_reg_read_ack;
    logic bru_PRF_B_reg_read_ack;
    logic stamofu_PRF_A_reg_read_ack;
    logic stamofu_PRF_B_reg_read_ack;
    logic sysu_PRF_A_reg_read_ack;

    logic ldu_PRF_A_reg_read_port;
    logic alu_reg_mdu_PRF_A_reg_read_port;
    logic alu_reg_mdu_PRF_B_reg_read_port;
    logic alu_imm_PRF_A_reg_read_port;
    logic bru_PRF_A_reg_read_port;
    logic bru_PRF_B_reg_read_port;
    logic stamofu_PRF_A_reg_read_port;
    logic stamofu_PRF_B_reg_read_port;
    logic sysu_PRF_A_reg_read_port;

    // read data by bank
    logic [PRF_BANK_COUNT-1:0][1:0][31:0] prf_read_data_by_bank_by_port;

    // writeback info by write requestor
    logic [PRF_WR_COUNT-1:0]                        WB_valid_by_wr;
    logic [PRF_WR_COUNT-1:0]                        WB_send_complete_by_wr;
    logic [PRF_WR_COUNT-1:0][31:0]                  WB_data_by_wr;
    logic [PRF_WR_COUNT-1:0][LOG_PR_COUNT-1:0]      WB_PR_by_wr;
    logic [PRF_WR_COUNT-1:0][LOG_ROB_ENTRIES-1:0]   WB_ROB_index_by_wr;

    // logic wr_buf_WB_valid; // in core IO
    logic ldu_bank0_WB_valid;
    logic ldu_bank1_WB_valid;
    logic alu_reg_WB_valid;
    logic mdu_WB_valid;
    logic alu_imm_WB_valid;
    logic bru_WB_valid;
    logic sysu_WB_valid;

    logic wr_buf_WB_send_complete;
    logic ldu_bank0_WB_send_complete;
    logic ldu_bank1_WB_send_complete;
    logic alu_reg_WB_send_complete;
    logic mdu_WB_send_complete;
    logic alu_imm_WB_send_complete;
    logic bru_WB_send_complete;
    logic sysu_WB_send_complete;

    // logic [31:0] wr_buf_WB_data; // in core IO
    logic [31:0] ldu_bank0_WB_data;
    logic [31:0] ldu_bank1_WB_data;
    logic [31:0] alu_reg_WB_data;
    logic [31:0] mdu_WB_data;
    logic [31:0] alu_imm_WB_data;
    logic [31:0] bru_WB_data;
    logic [31:0] sysu_WB_data;

    // logic [PRF_WR_COUNT-1:0] wr_buf_WB_PR; // in core IO
    logic [PRF_WR_COUNT-1:0] ldu_bank0_WB_PR;
    logic [PRF_WR_COUNT-1:0] ldu_bank1_WB_PR;
    logic [PRF_WR_COUNT-1:0] alu_reg_WB_PR;
    logic [PRF_WR_COUNT-1:0] mdu_WB_PR;
    logic [PRF_WR_COUNT-1:0] alu_imm_WB_PR;
    logic [PRF_WR_COUNT-1:0] bru_WB_PR;
    logic [PRF_WR_COUNT-1:0] sysu_WB_PR;

    logic [LOG_PR_COUNT-1:0] wr_buf_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] ldu_bank0_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] ldu_bank1_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] alu_reg_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] mdu_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] alu_imm_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] bru_WB_ROB_index;
    logic [LOG_PR_COUNT-1:0] sysu_WB_ROB_index;

    // writeback feedback by write requestor
    logic [PRF_WR_COUNT-1:0] WB_ready_by_wr;

    // logic wr_buf_WB_ready; // in core IO
    logic ldu_bank0_WB_ready;
    logic ldu_bank1_WB_ready;
    logic alu_reg_WB_ready;
    logic mdu_WB_ready;
    logic alu_imm_WB_ready;
    logic bru_WB_ready;
    logic sysu_WB_ready;

    // forward data by bank
    logic [PRF_BANK_COUNT-1:0][31:0] prf_forward_data_bus_by_bank;

    // complete bus by bank
    logic [PRF_BANK_COUNT-1:0]                          prf_complete_bus_valid_by_bank;
    logic [PRF_BANK_COUNT-1:0][LOG_ROB_ENTRIES-1:0]     prf_complete_bus_ROB_index_by_bank;

    // LDU complete notif
    logic                           ldu_complete_valid;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_complete_ROB_index;

    // STAMOFU complete notif
    logic                           stamofu_complete_valid;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_complete_ROB_index;

    // branch notification to ROB
    logic                               branch_notif_valid;
    logic [LOG_ROB_ENTRIES-1:0]         branch_notif_ROB_index;
    logic                               branch_notif_is_mispredict;
    logic                               branch_notif_is_taken;
    logic                               branch_notif_use_upct;
    logic [BTB_PRED_INFO_WIDTH-1:0]     branch_notif_updated_pred_info;
    logic                               branch_notif_pred_lru;
    logic [31:0]                        branch_notif_start_PC;
    logic [31:0]                        branch_notif_target_PC;

    // branch notification backpressure from ROB
    logic                               branch_notif_ready;

    // LDU misprediction notification to ROB
    logic                           ldu_mispred_notif_valid;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_mispred_notif_ROB_index;

    logic                           ldu_mispred_notif_bank0_valid;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_mispred_notif_bank0_ROB_index;

    logic                           ldu_mispred_notif_bank1_valid;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_mispred_notif_bank1_ROB_index;

    // LDU misprediction notification backpressure from ROB
    logic                           ldu_mispred_notif_ready;
    
    logic                           ldu_mispred_notif_bank0_ready;

    logic                           ldu_mispred_notif_bank1_ready;

    // fence restart notification to ROB
    logic                           fence_restart_notif_valid;
    logic [LOG_ROB_ENTRIES-1:0]     fence_restart_notif_ROB_index;

    // fence restart notification backpressure from ROB
    logic                           fence_restart_notif_ready;

    // LDU exception to ROB
    logic                           ldu_exception_valid;
    logic [VA_WIDTH-1:0]            ldu_exception_VA;
    logic                           ldu_exception_page_fault;
    logic                           ldu_exception_access_fault;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_exception_ROB_index;

    // LDU exception backpressure from ROB
    logic                           ldu_exception_ready;

    // STAMOFU exception to ROB
    logic                           stamofu_exception_valid;
    logic [VA_WIDTH-1:0]            stamofu_exception_VA;
    logic                           stamofu_exception_is_lr;
    logic                           stamofu_exception_page_fault;
    logic                           stamofu_exception_access_fault;
    logic                           stamofu_exception_misaligned_exception;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_exception_ROB_index;

    // STAMOFU exception backpressure from ROB
    logic                           stamofu_exception_ready;

    // mdp update to ROB
    logic                           ssu_mdp_update_valid;
    logic [MDPT_INFO_WIDTH-1:0]     ssu_mdp_update_mdp_info;
    logic [LOG_ROB_ENTRIES-1:0]     ssu_mdp_update_ROB_index;

    // mdp update feedback from ROB
    logic                           ssu_mdp_update_ready;

    // ROB commit
    logic [LOG_ROB_ENTRIES-3:0]     rob_commit_upper_index;
    logic [3:0]                     rob_commit_lower_index_valid_mask;

    // op enqueue to issue queue
    logic                           alu_reg_mdu_iq_enq_valid;
    logic                           alu_reg_mdu_iq_enq_is_alu_reg;
    logic                           alu_reg_mdu_iq_enq_is_mdu;
    logic [3:0]                     alu_reg_mdu_iq_enq_op;
    logic [LOG_PR_COUNT-1:0]        alu_reg_mdu_iq_enq_A_PR;
    logic                           alu_reg_mdu_iq_enq_A_ready;
    logic                           alu_reg_mdu_iq_enq_A_is_zero;
    logic [LOG_PR_COUNT-1:0]        alu_reg_mdu_iq_enq_B_PR;
    logic                           alu_reg_mdu_iq_enq_B_ready;
    logic                           alu_reg_mdu_iq_enq_B_is_zero;
    logic [LOG_PR_COUNT-1:0]        alu_reg_mdu_iq_enq_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     alu_reg_mdu_iq_enq_ROB_index;

    // issue queue enqueue feedback
    logic                           alu_reg_mdu_iq_enq_ready;

    // ALU reg pipeline issue
    logic                           alu_reg_issue_valid;

    // MDU pipeline issue
    logic                           mdu_issue_valid;

    // shared ALU reg / MDU issue info
    logic [3:0]                     alu_reg_mdu_issue_op;
    logic                           alu_reg_mdu_issue_A_forward;
    logic                           alu_reg_mdu_issue_A_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]  alu_reg_mdu_issue_A_bank;
    logic                           alu_reg_mdu_issue_B_forward;
    logic                           alu_reg_mdu_issue_B_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]  alu_reg_mdu_issue_B_bank;
    logic [LOG_PR_COUNT-1:0]        alu_reg_mdu_issue_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     alu_reg_mdu_issue_ROB_index;

    // ALU reg pipeline feedback
    logic                           alu_reg_issue_ready;

    // MDU pipeline feedback
    logic                           mdu_issue_ready;

    // op enqueue to issue queue
    logic                           alu_imm_iq_enq_valid;
    logic [3:0]                     alu_imm_iq_enq_op;
    logic [11:0]                    alu_imm_iq_enq_imm12;
    logic [LOG_PR_COUNT-1:0]        alu_imm_iq_enq_A_PR;
    logic                           alu_imm_iq_enq_A_ready;
    logic                           alu_imm_iq_enq_A_is_zero;
    logic [LOG_PR_COUNT-1:0]        alu_imm_iq_enq_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     alu_imm_iq_enq_ROB_index;

    // issue queue enqueue feedback
    logic                           alu_imm_iq_enq_ready;

    // pipeline issue
    logic                           alu_imm_issue_valid;
    logic [3:0]                     alu_imm_issue_op;
    logic [11:0]                    alu_imm_issue_imm12;
    logic                           alu_imm_issue_A_forward;
    logic                           alu_imm_issue_A_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]  alu_imm_issue_A_bank;
    logic [LOG_PR_COUNT-1:0]        alu_imm_issue_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     alu_imm_issue_ROB_index;

    // pipeline feedback
    logic                           alu_imm_issue_ready;

    // op enqueue to issue queue
    logic                               bru_iq_enq_valid;
    logic [3:0]                         bru_iq_enq_op;
    logic [BTB_PRED_INFO_WIDTH-1:0]     bru_iq_enq_pred_info;
    logic                               bru_iq_enq_pred_lru;
    logic                               bru_iq_enq_is_link_ra;
    logic                               bru_iq_enq_is_ret_ra;
    logic [31:0]                        bru_iq_enq_PC;
    logic [31:0]                        bru_iq_enq_pred_PC;
    logic [19:0]                        bru_iq_enq_imm20;
    logic [LOG_PR_COUNT-1:0]            bru_iq_enq_A_PR;
    logic                               bru_iq_enq_A_ready;
    logic                               bru_iq_enq_A_unneeded_or_is_zero;
    logic [LOG_PR_COUNT-1:0]            bru_iq_enq_B_PR;
    logic                               bru_iq_enq_B_ready;
    logic                               bru_iq_enq_B_unneeded_or_is_zero;
    logic [LOG_PR_COUNT-1:0]            bru_iq_enq_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]         bru_iq_enq_ROB_index;

    // issue queue enqueue feedback
    logic                               bru_iq_enq_ready;

    // pipeline issue
    logic                               bru_issue_valid;
    logic [3:0]                         bru_issue_op;
    logic [BTB_PRED_INFO_WIDTH-1:0]     bru_issue_pred_info;
    logic                               bru_issue_pred_lru;
    logic                               bru_issue_is_link_ra;
    logic                               bru_issue_is_ret_ra;
    logic [31:0]                        bru_issue_PC;
    logic [31:0]                        bru_issue_pred_PC;
    logic [19:0]                        bru_issue_imm20;
    logic                               bru_issue_A_forward;
    logic                               bru_issue_A_unneeded_or_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]      bru_issue_A_bank;
    logic                               bru_issue_B_forward;
    logic                               bru_issue_B_unneeded_or_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]      bru_issue_B_bank;
    logic [LOG_PR_COUNT-1:0]            bru_issue_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]         bru_issue_ROB_index;

    // pipeline feedback
    logic                               bru_issue_ready;

    // op enqueue to central queue
    logic                           ldu_cq_enq_valid;
    logic                           ldu_cq_enq_killed;
    logic [3:0]                     ldu_cq_enq_op;
    logic [MDPT_INFO_WIDTH-1:0]     ldu_cq_enq_mdp_info;
    logic [LOG_PR_COUNT-1:0]        ldu_cq_enq_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_cq_enq_ROB_index;
    
    // central queue enqueue feedback
    logic                           ldu_cq_enq_ready;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_cq_enq_index;

    // op enqueue to issue queue
    logic                           ldu_iq_enq_valid;
    logic [3:0]                     ldu_iq_enq_op;
    logic [11:0]                    ldu_iq_enq_imm12;
    logic [LOG_PR_COUNT-1:0]        ldu_iq_enq_A_PR;
    logic                           ldu_iq_enq_A_ready;
    logic                           ldu_iq_enq_A_is_zero;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_iq_enq_cq_index;
    
    // issue queue enqueue feedback
    logic                           ldu_iq_enq_ready;

    // pipeline issue
    logic                           ldu_issue_valid;
    logic [3:0]                     ldu_issue_op;
    logic [11:0]                    ldu_issue_imm12;
    logic                           ldu_issue_A_forward;
    logic                           ldu_issue_A_is_zero;
    logic [LOG_PRF_BANK_COUNT-1:0]  ldu_issue_A_bank;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_issue_cq_index;

    // pipeline feedback
    logic                           ldu_issue_ready;

    // first try
    logic                           ldu_launch_pipeline_first_try_bank0_valid;
    logic                           ldu_launch_pipeline_first_try_bank1_valid;

    logic                           ldu_launch_pipeline_first_try_is_mq;
    logic                           ldu_launch_pipeline_first_try_misaligned;
    logic [VPN_WIDTH-1:0]           ldu_launch_pipeline_first_try_VPN;
    logic [PO_WIDTH-3:0]            ldu_launch_pipeline_first_try_PO_word;
    logic [3:0]                     ldu_launch_pipeline_first_try_byte_mask;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_launch_pipeline_first_try_cq_index;

    // first try feedback
    logic                           ldu_launch_pipeline_first_try_bank0_early_ready;
    logic                           ldu_launch_pipeline_first_try_bank1_early_ready;

    // op enqueue to misaligned queue
    logic                           ldu_mq_enq_valid;

    logic                           ldu_launch_pipeline_bank0_ldu_mq_enq_valid;
    logic                           ldu_launch_pipeline_bank1_ldu_mq_enq_valid;

    // misaligned queue enqueue feedback
    logic                           ldu_mq_enq_ready;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  ldu_mq_enq_index;

    logic                           ldu_launch_pipeline_bank0_ldu_mq_enq_ready;
    logic                           ldu_launch_pipeline_bank1_ldu_mq_enq_ready;

    // acquire advertisement
    logic                           stamofu_aq_mem_aq_active;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_aq_mem_aq_oldest_abs_ROB_index;
    logic                           stamofu_aq_io_aq_active;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_aq_io_aq_oldest_abs_ROB_index;

    // second try
    logic                           ldu_launch_pipeline_second_try_bank0_valid;
    logic                           ldu_launch_pipeline_second_try_bank1_valid;

    logic                           ldu_launch_pipeline_second_try_do_mispred;
    logic                           ldu_launch_pipeline_second_try_is_mq;
    logic                           ldu_launch_pipeline_second_try_misaligned;
    logic                           ldu_launch_pipeline_second_try_page_fault;
    logic                           ldu_launch_pipeline_second_try_access_fault;
    logic                           ldu_launch_pipeline_second_try_is_mem;
    logic [PPN_WIDTH-1:0]           ldu_launch_pipeline_second_try_PPN;
    logic [PO_WIDTH-3:0]            ldu_launch_pipeline_second_try_PO_word;
    logic [3:0]                     ldu_launch_pipeline_second_try_byte_mask;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_launch_pipeline_second_try_cq_index;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  ldu_launch_pipeline_second_try_mq_index;

    // second try feedback
    logic                           ldu_launch_pipeline_second_try_bank0_ack;
    logic                           ldu_launch_pipeline_second_try_bank1_ack;

    // data try
    logic                           ldu_launch_pipeline_data_try_bank0_valid;    
    logic                           ldu_launch_pipeline_data_try_bank1_valid;

    logic                           ldu_launch_pipeline_data_try_do_mispred;
    logic [31:0]                    ldu_launch_pipeline_data_try_data;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_launch_pipeline_data_try_cq_index;

    // data try feedback
    logic                           ldu_launch_pipeline_data_try_bank0_ack;
    logic                           ldu_launch_pipeline_data_try_bank1_ack;

    // stamofu CAM launch
    logic                           stamofu_CAM_launch_bank0_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  stamofu_CAM_launch_bank0_cq_index;
    logic                           stamofu_CAM_launch_bank0_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  stamofu_CAM_launch_bank0_mq_index;
    logic [PA_WIDTH-2-1:0]          stamofu_CAM_launch_bank0_PA_word;
    logic [3:0]                     stamofu_CAM_launch_bank0_byte_mask;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_CAM_launch_bank0_ROB_index;
    logic [MDPT_INFO_WIDTH-1:0]     stamofu_CAM_launch_bank0_mdp_info;
    
    logic                           stamofu_CAM_launch_bank1_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  stamofu_CAM_launch_bank1_cq_index;
    logic                           stamofu_CAM_launch_bank1_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  stamofu_CAM_launch_bank1_mq_index;
    logic [PA_WIDTH-2-1:0]          stamofu_CAM_launch_bank1_PA_word;
    logic [3:0]                     stamofu_CAM_launch_bank1_byte_mask;
    logic [LOG_ROB_ENTRIES-1:0]     stamofu_CAM_launch_bank1_ROB_index;
    logic [MDPT_INFO_WIDTH-1:0]     stamofu_CAM_launch_bank1_mdp_info;

    // stamofu CAM return
    logic                               stamofu_CAM_return_bank0_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]      stamofu_CAM_return_bank0_cq_index;
    logic                               stamofu_CAM_return_bank0_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]      stamofu_CAM_return_bank0_mq_index;
    logic                               stamofu_CAM_return_bank0_stall;
    logic [LOG_STAMOFU_CQ_ENTRIES-1:0]  stamofu_CAM_return_bank0_stall_count;
    logic [3:0]                         stamofu_CAM_return_bank0_forward;
    logic                               stamofu_CAM_return_bank0_nasty_forward;
    logic [LOG_ROB_ENTRIES-1:0]         stamofu_CAM_return_bank0_forward_ROB_index;
    logic [31:0]                        stamofu_CAM_return_bank0_forward_data;

    logic                               stamofu_CAM_return_bank1_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]      stamofu_CAM_return_bank1_cq_index;
    logic                               stamofu_CAM_return_bank1_is_mq;
    logic [LOG_LDU_MQ_ENTRIES-1:0]      stamofu_CAM_return_bank1_mq_index;
    logic                               stamofu_CAM_return_bank1_stall;
    logic [LOG_STAMOFU_CQ_ENTRIES-1:0]  stamofu_CAM_return_bank1_stall_count;
    logic [3:0]                         stamofu_CAM_return_bank1_forward;
    logic                               stamofu_CAM_return_bank1_nasty_forward;
    logic [LOG_ROB_ENTRIES-1:0]         stamofu_CAM_return_bank1_forward_ROB_index;
    logic [31:0]                        stamofu_CAM_return_bank1_forward_data;

    // ldu CAM launch
    logic                               ldu_CAM_launch_valid;
    logic [LOG_STAMOFU_CQ_ENTRIES-1:0]  ldu_CAM_launch_cq_index;
    logic                               ldu_CAM_launch_is_mq;
    logic [LOG_STAMOFU_MQ_ENTRIES-1:0]  ldu_CAM_launch_mq_index;
    logic                               ldu_CAM_launch_is_amo;
    logic [PA_WIDTH-2-1:0]              ldu_CAM_launch_PA_word;
    logic [3:0]                         ldu_CAM_launch_byte_mask;
    logic [31:0]                        ldu_CAM_launch_write_data;
    logic [MDPT_INFO_WIDTH-1:0]         ldu_CAM_launch_mdp_info;
    logic [LOG_ROB_ENTRIES-1:0]         ldu_CAM_launch_ROB_index;

    // ldu CAM return
    logic                               ldu_CAM_return_valid;
    logic [LOG_STAMOFU_CQ_ENTRIES-1:0]  ldu_CAM_return_cq_index;
    logic                               ldu_CAM_return_is_mq;
    logic [LOG_STAMOFU_MQ_ENTRIES-1:0]  ldu_CAM_return_mq_index;
    logic                               ldu_CAM_return_forward;

    // central queue info grab
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_cq_info_grab_bank0_cq_index;
    logic [3:0]                     ldu_cq_info_grab_bank0_op;
    logic [MDPT_INFO_WIDTH-1:0]     ldu_cq_info_grab_bank0_mdp_info;
    logic [LOG_PR_COUNT-1:0]        ldu_cq_info_grab_bank0_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_cq_info_grab_bank0_ROB_index;

    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_cq_info_grab_bank1_cq_index;
    logic [3:0]                     ldu_cq_info_grab_bank1_op;
    logic [MDPT_INFO_WIDTH-1:0]     ldu_cq_info_grab_bank1_mdp_info;
    logic [LOG_PR_COUNT-1:0]        ldu_cq_info_grab_bank1_dest_PR;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_cq_info_grab_bank1_ROB_index;

    // central queue info ret
    logic                           ldu_cq_info_ret_bank0_valid;
    logic                           ldu_cq_info_ret_bank0_WB_sent;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_cq_info_ret_bank0_cq_index;
    logic                           ldu_cq_info_ret_bank0_misaligned;
    logic                           ldu_cq_info_ret_bank0_dtlb_hit;
    logic                           ldu_cq_info_ret_bank0_page_fault;
    logic                           ldu_cq_info_ret_bank0_access_fault;
    logic                           ldu_cq_info_ret_bank0_dcache_hit;
    logic                           ldu_cq_info_ret_bank0_is_mem;
    logic                           ldu_cq_info_ret_bank0_aq_blocking;
    logic [PA_WIDTH-2-1:0]          ldu_cq_info_ret_bank0_PA_word;
    logic [3:0]                     ldu_cq_info_ret_bank0_byte_mask;
    logic [31:0]                    ldu_cq_info_ret_bank0_data;
    
    logic                           ldu_cq_info_ret_bank1_valid;
    logic                           ldu_cq_info_ret_bank1_WB_sent;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_cq_info_ret_bank1_cq_index;
    logic                           ldu_cq_info_ret_bank1_misaligned;
    logic                           ldu_cq_info_ret_bank1_dtlb_hit;
    logic                           ldu_cq_info_ret_bank1_page_fault;
    logic                           ldu_cq_info_ret_bank1_access_fault;
    logic                           ldu_cq_info_ret_bank1_dcache_hit;
    logic                           ldu_cq_info_ret_bank1_is_mem;
    logic                           ldu_cq_info_ret_bank1_aq_blocking;
    logic [PA_WIDTH-2-1:0]          ldu_cq_info_ret_bank1_PA_word;
    logic [3:0]                     ldu_cq_info_ret_bank1_byte_mask;
    logic [31:0]                    ldu_cq_info_ret_bank1_data;

    // misaligned queue info ret
    logic                           ldu_mq_info_ret_bank0_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_mq_info_ret_bank0_cq_index;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  ldu_mq_info_ret_bank0_mq_index;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_mq_info_ret_bank0_ROB_index;
    logic                           ldu_mq_info_ret_bank0_WB_sent;
    logic                           ldu_mq_info_ret_bank0_dtlb_hit;
    logic                           ldu_mq_info_ret_bank0_page_fault;
    logic                           ldu_mq_info_ret_bank0_access_fault;
    logic                           ldu_mq_info_ret_bank0_dcache_hit;
    logic                           ldu_mq_info_ret_bank0_is_mem;
    logic                           ldu_mq_info_ret_bank0_aq_blocking;
    logic [PA_WIDTH-2-1:0]          ldu_mq_info_ret_bank0_PA_word;
    logic [3:0]                     ldu_mq_info_ret_bank0_byte_mask;
    logic [31:0]                    ldu_mq_info_ret_bank0_data;
    
    logic                           ldu_mq_info_ret_bank1_valid;
    logic [LOG_LDU_CQ_ENTRIES-1:0]  ldu_mq_info_ret_bank1_cq_index;
    logic [LOG_LDU_MQ_ENTRIES-1:0]  ldu_mq_info_ret_bank1_mq_index;
    logic [LOG_ROB_ENTRIES-1:0]     ldu_mq_info_ret_bank1_ROB_index;
    logic                           ldu_mq_info_ret_bank1_WB_sent;
    logic                           ldu_mq_info_ret_bank1_dtlb_hit;
    logic                           ldu_mq_info_ret_bank1_page_fault;
    logic                           ldu_mq_info_ret_bank1_access_fault;
    logic                           ldu_mq_info_ret_bank1_dcache_hit;
    logic                           ldu_mq_info_ret_bank1_is_mem;
    logic                           ldu_mq_info_ret_bank1_aq_blocking;
    logic [PA_WIDTH-2-1:0]          ldu_mq_info_ret_bank1_PA_word;
    logic [3:0]                     ldu_mq_info_ret_bank1_byte_mask;
    logic [31:0]                    ldu_mq_info_ret_bank1_data;

    // ----------------------------------------------------------------
    // Front End Modules:

    // fetch unit
    fetch_unit #(
        .INIT_PC(INIT_PC),
        .INIT_ASID(INIT_ASID),
        .INIT_EXEC_MODE(INIT_EXEC_MODE),
        .INIT_VIRTUAL_MODE(INIT_VIRTUAL_MODE),
        .FETCH_UNIT_WAIT_FOR_RESTART_STATE(FETCH_UNIT_WAIT_FOR_RESTART_STATE) 
    ) FETCH_UNIT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

	    // itlb req
		.itlb_req_valid(itlb_req_valid),
		.itlb_req_exec_mode(itlb_req_exec_mode),
		.itlb_req_virtual_mode(itlb_req_virtual_mode),
		.itlb_req_VPN(itlb_req_VPN),
		.itlb_req_ASID(itlb_req_ASID),

	    // itlb resp
		.itlb_resp_valid(itlb_resp_valid),
		.itlb_resp_PPN(itlb_resp_PPN),
		.itlb_resp_page_fault(itlb_resp_page_fault),
		.itlb_resp_access_fault(itlb_resp_access_fault),

	    // icache req
		.icache_req_valid(icache_req_valid),
		.icache_req_block_offset(icache_req_block_offset),
		.icache_req_index(icache_req_index),

	    // icache resp
		.icache_resp_valid_by_way(icache_resp_valid_by_way),
		.icache_resp_tag_by_way(icache_resp_tag_by_way),
		.icache_resp_instr_16B_by_way(icache_resp_instr_16B_by_way),

	    // icache resp feedback
		.icache_resp_hit_valid(icache_resp_hit_valid),
		.icache_resp_hit_way(icache_resp_hit_way),
		.icache_resp_miss_valid(icache_resp_miss_valid),
		.icache_resp_miss_tag(icache_resp_miss_tag),

	    // output to istream
		.istream_valid_SENQ(istream_valid_SENQ),
		.istream_valid_by_fetch_2B_SENQ(istream_valid_by_fetch_2B_SENQ),
		.istream_one_hot_redirect_by_fetch_2B_SENQ(istream_one_hot_redirect_by_fetch_2B_SENQ),
		.istream_instr_2B_by_fetch_2B_SENQ(istream_instr_2B_by_fetch_2B_SENQ),
		.istream_pred_info_by_fetch_2B_SENQ(istream_pred_info_by_fetch_2B_SENQ),
		.istream_pred_lru_by_fetch_2B_SENQ(istream_pred_lru_by_fetch_2B_SENQ),
		.istream_mdp_info_by_fetch_2B_SENQ(istream_mdp_info_by_fetch_2B_SENQ),
		.istream_after_PC_SENQ(istream_after_PC_SENQ),
		.istream_LH_SENQ(istream_LH_SENQ),
		.istream_GH_SENQ(istream_GH_SENQ),
		.istream_ras_index_SENQ(istream_ras_index_SENQ),
		.istream_page_fault_SENQ(istream_page_fault_SENQ),
		.istream_access_fault_SENQ(istream_access_fault_SENQ),

	    // istream feedback
		.istream_stall_SENQ(istream_stall_SENQ),

	    // fetch + decode restart from ROB
		.rob_restart_valid(rob_restart_valid),
		.rob_restart_PC(rob_restart_PC),
		.rob_restart_ASID(rob_restart_ASID),
		.rob_restart_exec_mode(rob_restart_exec_mode),
		.rob_restart_virtual_mode(rob_restart_virtual_mode),

	    // decode unit control
		.decode_unit_restart_valid(decode_unit_restart_valid),
		.decode_unit_restart_PC(decode_unit_restart_PC),
		.decode_unit_trigger_wait_for_restart(decode_unit_trigger_wait_for_restart),

	    // branch update from decode unit
		.decode_unit_branch_update_valid(decode_unit_branch_update_valid),
		.decode_unit_branch_update_has_checkpoint(decode_unit_branch_update_has_checkpoint),
		.decode_unit_branch_update_is_mispredict(decode_unit_branch_update_is_mispredict),
		.decode_unit_branch_update_is_taken(decode_unit_branch_update_is_taken),
		.decode_unit_branch_update_is_complex(decode_unit_branch_update_is_complex),
		.decode_unit_branch_update_use_upct(decode_unit_branch_update_use_upct),
		.decode_unit_branch_update_intermediate_pred_info(decode_unit_branch_update_intermediate_pred_info),
		.decode_unit_branch_update_pred_lru(decode_unit_branch_update_pred_lru),
		.decode_unit_branch_update_start_PC(decode_unit_branch_update_start_PC),
		.decode_unit_branch_update_target_PC(decode_unit_branch_update_target_PC),
		.decode_unit_branch_update_LH(decode_unit_branch_update_LH),
		.decode_unit_branch_update_GH(decode_unit_branch_update_GH),
		.decode_unit_branch_update_ras_index(decode_unit_branch_update_ras_index),

	    // mdpt update
		.mdpt_update_valid(fetch_unit_mdpt_update_valid),
		.mdpt_update_start_full_PC(fetch_unit_mdpt_update_start_full_PC),
		.mdpt_update_ASID(fetch_unit_mdpt_update_ASID),
		.mdpt_update_mdp_info(fetch_unit_mdpt_update_mdp_info)
    );

    // istream
	istream #(
		.ISTREAM_SETS(ISTREAM_SETS),
		.INIT_PC(INIT_PC)
	) ISTREAM (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // SENQ stage
		.valid_SENQ(istream_valid_SENQ),
		.valid_by_fetch_2B_SENQ(istream_valid_by_fetch_2B_SENQ),
		.one_hot_redirect_by_fetch_2B_SENQ(istream_one_hot_redirect_by_fetch_2B_SENQ),
		.instr_2B_by_fetch_2B_SENQ(istream_instr_2B_by_fetch_2B_SENQ),
		.pred_info_by_fetch_2B_SENQ(istream_pred_info_by_fetch_2B_SENQ),
		.pred_lru_by_fetch_2B_SENQ(istream_pred_lru_by_fetch_2B_SENQ),
		.mdp_info_by_fetch_2B_SENQ(istream_mdp_info_by_fetch_2B_SENQ),
		.after_PC_SENQ(istream_after_PC_SENQ),
		.LH_SENQ(istream_LH_SENQ),
		.GH_SENQ(istream_GH_SENQ),
		.ras_index_SENQ(istream_ras_index_SENQ),
		.page_fault_SENQ(istream_page_fault_SENQ),
		.access_fault_SENQ(istream_access_fault_SENQ),

	    // SENQ feedback
		.stall_SENQ(istream_stall_SENQ),

	    // SDEQ stage
		.valid_SDEQ(istream_valid_SDEQ),
		.valid_by_way_SDEQ(istream_valid_by_way_SDEQ),
		.uncompressed_by_way_SDEQ(istream_uncompressed_by_way_SDEQ),
		.instr_2B_by_way_by_chunk_SDEQ(istream_instr_2B_by_way_by_chunk_SDEQ),
		.pred_info_by_way_by_chunk_SDEQ(istream_pred_info_by_way_by_chunk_SDEQ),
		.pred_lru_by_way_by_chunk_SDEQ(istream_pred_lru_by_way_by_chunk_SDEQ),
		// .redirect_by_way_by_chunk_SDEQ(), // unused
		.pred_PC_by_way_by_chunk_SDEQ(istream_pred_PC_by_way_by_chunk_SDEQ),
		.page_fault_by_way_by_chunk_SDEQ(istream_page_fault_by_way_by_chunk_SDEQ),
		.access_fault_by_way_by_chunk_SDEQ(istream_access_fault_by_way_by_chunk_SDEQ),
		.mdp_info_by_way_SDEQ(istream_mdp_info_by_way_SDEQ),
		.PC_by_way_SDEQ(istream_PC_by_way_SDEQ),
		.LH_by_way_SDEQ(istream_LH_by_way_SDEQ),
		.GH_by_way_SDEQ(istream_GH_by_way_SDEQ),
		.ras_index_by_way_SDEQ(istream_ras_index_by_way_SDEQ),

	    // SDEQ feedback
		.stall_SDEQ(istream_stall_SDEQ),

	    // control
		.restart(rob_restart_valid),
		.restart_PC(rob_restart_PC)
	);

    // decode_unit
    always_comb begin
        for (int way = 0; way < 4; way++) begin
            dispatch_imm12_by_way[way] = dispatch_imm20_by_way[way][11:0];
        end
    end
    decode_unit #(
		.INIT_EXEC_MODE(INIT_EXEC_MODE),
		.INIT_TRAP_SFENCE(INIT_TRAP_SFENCE),
		.INIT_TRAP_WFI(INIT_TRAP_WFI),
		.INIT_TRAP_SRET(INIT_TRAP_SRET)
	) DECODE_UNIT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // input from istream
		.istream_valid_SDEQ(istream_valid_SDEQ),
		.istream_valid_by_way_SDEQ(istream_valid_by_way_SDEQ),
		.istream_uncompressed_by_way_SDEQ(istream_uncompressed_by_way_SDEQ),
		.istream_instr_2B_by_way_by_chunk_SDEQ(istream_instr_2B_by_way_by_chunk_SDEQ),
		.istream_pred_info_by_way_by_chunk_SDEQ(istream_pred_info_by_way_by_chunk_SDEQ),
		.istream_pred_lru_by_way_by_chunk_SDEQ(istream_pred_lru_by_way_by_chunk_SDEQ),
		.istream_pred_PC_by_way_by_chunk_SDEQ(istream_pred_PC_by_way_by_chunk_SDEQ),
		.istream_page_fault_by_way_by_chunk_SDEQ(istream_page_fault_by_way_by_chunk_SDEQ),
		.istream_access_fault_by_way_by_chunk_SDEQ(istream_access_fault_by_way_by_chunk_SDEQ),
		.istream_mdp_info_by_way_SDEQ(istream_mdp_info_by_way_SDEQ),
		.istream_PC_by_way_SDEQ(istream_PC_by_way_SDEQ),
		.istream_LH_by_way_SDEQ(istream_LH_by_way_SDEQ),
		.istream_GH_by_way_SDEQ(istream_GH_by_way_SDEQ),
		.istream_ras_index_by_way_SDEQ(istream_ras_index_by_way_SDEQ),

	    // feedback to istream
		.istream_stall_SDEQ(istream_stall_SDEQ),

	    // op dispatch by way:

	    // 4-way ROB entry
		.dispatch_rob_enq_valid(dispatch_rob_enq_valid),
		.dispatch_rob_enq_killed(dispatch_rob_enq_killed),
		.dispatch_rob_enq_ready(dispatch_rob_enq_ready),

	    // general instr info
		.dispatch_valid_by_way(dispatch_valid_by_way),
		.dispatch_uncompressed_by_way(dispatch_uncompressed_by_way),
		.dispatch_PC_by_way(dispatch_PC_by_way),
		.dispatch_pred_PC_by_way(dispatch_pred_PC_by_way),
		.dispatch_is_rename_by_way(dispatch_is_rename_by_way),
		.dispatch_pred_info_by_way(dispatch_pred_info_by_way),
		.dispatch_pred_lru_by_way(dispatch_pred_lru_by_way),
		.dispatch_mdp_info_by_way(dispatch_mdp_info_by_way),
		.dispatch_op_by_way(dispatch_op_by_way),
		.dispatch_imm20_by_way(dispatch_imm20_by_way),

	    // ordering
		.dispatch_mem_aq_by_way(dispatch_mem_aq_by_way),
		.dispatch_io_aq_by_way(dispatch_io_aq_by_way),
		.dispatch_mem_rl_by_way(dispatch_mem_rl_by_way),
		.dispatch_io_rl_by_way(dispatch_io_rl_by_way),

	    // exception info
		.dispatch_is_page_fault(dispatch_is_page_fault),
		.dispatch_is_access_fault(dispatch_is_access_fault),
		.dispatch_is_illegal_instr(dispatch_is_illegal_instr),
		.dispatch_exception_present(dispatch_exception_present),
		.dispatch_exception_index(dispatch_exception_index),
		.dispatch_illegal_instr32(dispatch_illegal_instr32),

		// checkpoint info
		.dispatch_has_checkpoint(dispatch_has_checkpoint),
		.dispatch_checkpoint_index(dispatch_checkpoint_index),

	    // instr IQ attempts
		.dispatch_attempt_alu_reg_mdu_dq_by_way(dispatch_attempt_alu_reg_mdu_dq_by_way),
		.dispatch_attempt_alu_imm_dq_by_way(dispatch_attempt_alu_imm_dq_by_way),
		.dispatch_attempt_bru_dq_by_way(dispatch_attempt_bru_dq_by_way),
		.dispatch_attempt_ldu_dq_by_way(dispatch_attempt_ldu_dq_by_way),
		.dispatch_attempt_stamofu_dq_by_way(dispatch_attempt_stamofu_dq_by_way),
		.dispatch_attempt_sysu_dq_by_way(dispatch_attempt_sysu_dq_by_way),

	    // instr FU valids
		.dispatch_valid_alu_reg_by_way(dispatch_valid_alu_reg_by_way),
		.dispatch_valid_mdu_by_way(dispatch_valid_mdu_by_way),
		.dispatch_valid_alu_imm_by_way(dispatch_valid_alu_imm_by_way),
		.dispatch_valid_bru_by_way(dispatch_valid_bru_by_way),
		.dispatch_valid_ldu_by_way(dispatch_valid_ldu_by_way),
		.dispatch_valid_store_by_way(dispatch_valid_store_by_way),
		.dispatch_valid_amo_by_way(dispatch_valid_amo_by_way),
		.dispatch_valid_fence_by_way(dispatch_valid_fence_by_way),
		.dispatch_valid_sysu_by_way(dispatch_valid_sysu_by_way),

	    // operand A
		.dispatch_A_PR_by_way(dispatch_A_PR_by_way),
		.dispatch_A_ready_by_way(dispatch_A_ready_by_way),
		.dispatch_A_is_zero_by_way(dispatch_A_is_zero_by_way),
		.dispatch_A_unneeded_or_is_zero_by_way(dispatch_A_unneeded_or_is_zero_by_way),
		.dispatch_A_is_ret_ra_by_way(dispatch_A_is_ret_ra_by_way),

	    // operand B
		.dispatch_B_PR_by_way(dispatch_B_PR_by_way),
		.dispatch_B_ready_by_way(dispatch_B_ready_by_way),
		.dispatch_B_is_zero_by_way(dispatch_B_is_zero_by_way),
		.dispatch_B_unneeded_or_is_zero_by_way(dispatch_B_unneeded_or_is_zero_by_way),

	    // dest operand
		.dispatch_dest_AR_by_way(dispatch_dest_AR_by_way),
		.dispatch_dest_old_PR_by_way(dispatch_dest_old_PR_by_way),
		.dispatch_dest_new_PR_by_way(dispatch_dest_new_PR_by_way),
		.dispatch_dest_is_link_ra_by_way(dispatch_dest_is_link_ra_by_way),

	    // instr IQ acks
		.dispatch_ack_alu_reg_mdu_dq_by_way(dispatch_ack_alu_reg_mdu_dq_by_way),
		.dispatch_ack_alu_imm_dq_by_way(dispatch_ack_alu_imm_dq_by_way),
		.dispatch_ack_bru_dq_by_way(dispatch_ack_bru_dq_by_way),
		.dispatch_ack_ldu_dq_by_way(dispatch_ack_ldu_dq_by_way),
		.dispatch_ack_stamofu_dq_by_way(dispatch_ack_stamofu_dq_by_way),
		.dispatch_ack_sysu_dq_by_way(dispatch_ack_sysu_dq_by_way),

	    // writeback bus by bank
		.WB_bus_valid_by_bank(WB_bus_valid_by_bank),
		.WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

	    // fetch + decode restart from ROB
		.rob_restart_valid(rob_restart_valid),
		.rob_restart_exec_mode(rob_restart_exec_mode),
		.rob_restart_trap_sfence(rob_restart_trap_sfence),
		.rob_restart_trap_wfi(rob_restart_trap_wfi),
		.rob_restart_trap_sret(rob_restart_trap_sret),

		// kill from ROB
		.rob_kill_valid(rob_kill_valid),

	    // branch update from ROB
		.rob_branch_update_valid(rob_branch_update_valid),
		.rob_branch_update_has_checkpoint(rob_branch_update_has_checkpoint),
		.rob_branch_update_checkpoint_index(rob_branch_update_checkpoint_index),
		.rob_branch_update_is_mispredict(rob_branch_update_is_mispredict),
		.rob_branch_update_is_taken(rob_branch_update_is_taken),
		.rob_branch_update_use_upct(rob_branch_update_use_upct),
		.rob_branch_update_intermediate_pred_info(rob_branch_update_intermediate_pred_info),
		.rob_branch_update_pred_lru(rob_branch_update_pred_lru),
		.rob_branch_update_start_PC(rob_branch_update_start_PC),
		.rob_branch_update_target_PC(rob_branch_update_target_PC),

	    // ROB control of rename
		.rob_controlling_rename(rob_controlling_rename),

		.rob_checkpoint_map_table_restore_valid(rob_checkpoint_map_table_restore_valid),
		.rob_checkpoint_map_table_restore_index(rob_checkpoint_map_table_restore_index),

		.rob_checkpoint_clear_valid(rob_checkpoint_clear_valid),
		.rob_checkpoint_clear_index(rob_checkpoint_clear_index),

		.rob_map_table_write_valid_by_port(rob_map_table_write_valid_by_port),
		.rob_map_table_write_AR_by_port(rob_map_table_write_AR_by_port),
		.rob_map_table_write_PR_by_port(rob_map_table_write_PR_by_port),

		// ROB physical register freeing
		.rob_PR_free_req_valid_by_bank(rob_PR_free_req_valid_by_bank),
		.rob_PR_free_req_PR_by_bank(rob_PR_free_req_PR_by_bank),
		.rob_PR_free_resp_ack_by_bank(rob_PR_free_resp_ack_by_bank),

	    // branch update to fetch unit
		.decode_unit_branch_update_valid(decode_unit_branch_update_valid),
		.decode_unit_branch_update_has_checkpoint(decode_unit_branch_update_has_checkpoint),
		.decode_unit_branch_update_is_mispredict(decode_unit_branch_update_is_mispredict),
		.decode_unit_branch_update_is_taken(decode_unit_branch_update_is_taken),
		.decode_unit_branch_update_is_complex(decode_unit_branch_update_is_complex),
		.decode_unit_branch_update_use_upct(decode_unit_branch_update_use_upct),
		.decode_unit_branch_update_intermediate_pred_info(decode_unit_branch_update_intermediate_pred_info),
		.decode_unit_branch_update_pred_lru(decode_unit_branch_update_pred_lru),
		.decode_unit_branch_update_start_PC(decode_unit_branch_update_start_PC),
		.decode_unit_branch_update_target_PC(decode_unit_branch_update_target_PC),
		.decode_unit_branch_update_LH(decode_unit_branch_update_LH),
		.decode_unit_branch_update_GH(decode_unit_branch_update_GH),
		.decode_unit_branch_update_ras_index(decode_unit_branch_update_ras_index),

	    // decode unit control
		.decode_unit_restart_valid(decode_unit_restart_valid),
		.decode_unit_restart_PC(decode_unit_restart_PC),

		.decode_unit_trigger_wait_for_restart(decode_unit_trigger_wait_for_restart),

		// hardware failure
		.unrecoverable_fault(unrecoverable_fault)
	);

    // ----------------------------------------------------------------
    // Central Modules:

    // prf
    always_comb begin
        // hardwired prf inputs:

        // hardwire send_complete's
        wr_buf_WB_send_complete = 1'b0;
        ldu_bank0_WB_send_complete = 1'b0;
        ldu_bank1_WB_send_complete = 1'b0;
        alu_reg_WB_send_complete = 1'b1;
        mdu_WB_send_complete = 1'b1;
        alu_imm_WB_send_complete = 1'b1;
        bru_WB_send_complete = 1'b1; // LUI and AUIPC don't send branch notif
        sysu_WB_send_complete = 1'b0;

        // wr buf ROB_index hardwired
        wr_buf_WB_ROB_index = 0;

        // sysu PRF req's hardwired for now
        sysu_PRF_req_A_valid = 1'b0;
        sysu_PRF_req_A_PR = 0;

        sysu_WB_valid = 1'b0;
        sysu_WB_data = 32'h0;
        sysu_WB_PR = 0;
        sysu_WB_ROB_index = 0;
    end
    always_comb begin

        // read priority:
            // LDU A
            // ALU Reg-Reg / MDU A
            // ALU Reg-Reg / MDU B
            // ALU Reg-Imm A
            // BRU A
            // BRU B
            // STAMOFU A
            // STAMOFU B
            // SYSU A
        prf_read_req_valid_by_rr = {
            sysu_PRF_req_A_valid,
            stamofu_PRF_req_B_valid,
            stamofu_PRF_req_A_valid,
            bru_PRF_req_B_valid,
            bru_PRF_req_A_valid,
            alu_imm_PRF_req_A_valid,
            alu_reg_mdu_PRF_req_B_valid,
            alu_reg_mdu_PRF_req_A_valid,
            ldu_PRF_req_A_valid
        };
        prf_read_req_PR_by_rr = {
            sysu_PRF_req_A_PR,
            stamofu_PRF_req_B_PR,
            stamofu_PRF_req_A_PR,
            bru_PRF_req_B_PR,
            bru_PRF_req_A_PR,
            alu_imm_PRF_req_A_PR,
            alu_reg_mdu_PRF_req_B_PR,
            alu_reg_mdu_PRF_req_A_PR,
            ldu_PRF_req_A_PR
        };

        ldu_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[0];
        alu_reg_mdu_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[1];
        alu_reg_mdu_PRF_B_reg_read_ack = prf_read_resp_ack_by_rr[2];
        alu_imm_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[3];
        bru_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[4];
        bru_PRF_B_reg_read_ack = prf_read_resp_ack_by_rr[5];
        stamofu_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[6];
        stamofu_PRF_B_reg_read_ack = prf_read_resp_ack_by_rr[7];
        sysu_PRF_A_reg_read_ack = prf_read_resp_ack_by_rr[8];

        ldu_PRF_A_reg_read_port = prf_read_resp_port_by_rr[0];
        alu_reg_mdu_PRF_A_reg_read_port = prf_read_resp_port_by_rr[1];
        alu_reg_mdu_PRF_B_reg_read_port = prf_read_resp_port_by_rr[2];
        alu_imm_PRF_A_reg_read_port = prf_read_resp_port_by_rr[3];
        bru_PRF_A_reg_read_port = prf_read_resp_port_by_rr[4];
        bru_PRF_B_reg_read_port = prf_read_resp_port_by_rr[5];
        stamofu_PRF_A_reg_read_port = prf_read_resp_port_by_rr[6];
        stamofu_PRF_B_reg_read_port = prf_read_resp_port_by_rr[7];
        sysu_PRF_A_reg_read_port = prf_read_resp_port_by_rr[8];
        
        // write priority:
            // STAMOFU
            // LDU bank 0
            // LDU bank 1
            // ALU Reg-Reg
            // MDU
            // ALU Reg-Imm
            // BRU
            // SYSU
        WB_valid_by_wr = {
            sysu_WB_valid,
            bru_WB_valid,
            alu_imm_WB_valid,
            mdu_WB_valid,
            alu_reg_WB_valid,
            ldu_bank1_WB_valid,
            ldu_bank0_WB_valid,
            wr_buf_WB_valid
        };
        WB_send_complete_by_wr = {
            sysu_WB_send_complete,
            bru_WB_send_complete,
            alu_imm_WB_send_complete,
            mdu_WB_send_complete,
            alu_reg_WB_send_complete,
            ldu_bank1_WB_send_complete,
            ldu_bank0_WB_send_complete,
            wr_buf_WB_send_complete
        };
        WB_data_by_wr = {
            sysu_WB_data,
            bru_WB_data,
            alu_imm_WB_data,
            mdu_WB_data,
            alu_reg_WB_data,
            ldu_bank1_WB_data,
            ldu_bank0_WB_data,
            wr_buf_WB_data
        };
        WB_PR_by_wr = {
            sysu_WB_PR,
            bru_WB_PR,
            alu_imm_WB_PR,
            mdu_WB_PR,
            alu_reg_WB_PR,
            ldu_bank1_WB_PR,
            ldu_bank0_WB_PR,
            wr_buf_WB_PR
        };
        WB_ROB_index_by_wr = {
            sysu_WB_ROB_index,
            bru_WB_ROB_index,
            alu_imm_WB_ROB_index,
            mdu_WB_ROB_index,
            alu_reg_WB_ROB_index,
            ldu_bank1_WB_ROB_index,
            ldu_bank0_WB_ROB_index,
            wr_buf_WB_ROB_index
        };

        wr_buf_WB_ready = WB_ready_by_wr[0];
        ldu_bank0_WB_ready = WB_ready_by_wr[1];
        ldu_bank1_WB_ready = WB_ready_by_wr[2];
        alu_reg_WB_ready = WB_ready_by_wr[3];
        mdu_WB_ready = WB_ready_by_wr[4];
        alu_imm_WB_ready = WB_ready_by_wr[5];
        bru_WB_ready = WB_ready_by_wr[6];
        sysu_WB_ready = WB_ready_by_wr[7];
    end
    prf #(
        .PR_COUNT(PR_COUNT),
        .PRF_BANK_COUNT(PRF_BANK_COUNT),
        .PRF_RR_COUNT(9),
        .PRF_WR_COUNT(7),
        .USE_BRAM(0)
    ) PRF (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // reg read req by read requester
		.read_req_valid_by_rr(prf_read_req_valid_by_rr),
		.read_req_PR_by_rr(prf_read_req_PR_by_rr),

	    // reg read info by read requestor
		.read_resp_ack_by_rr(prf_read_resp_ack_by_rr),
		.read_resp_port_by_rr(prf_read_resp_port_by_rr),

	    // reg read data by bank
		.read_data_by_bank_by_port(prf_read_data_by_bank_by_port),

	    // writeback data by write requestor
		.WB_valid_by_wr(WB_valid_by_wr),
		.WB_send_complete_by_wr(WB_send_complete_by_wr),
		.WB_data_by_wr(WB_data_by_wr),
		.WB_PR_by_wr(WB_PR_by_wr),
		.WB_ROB_index_by_wr(WB_ROB_index_by_wr),

	    // writeback backpressure by write requestor
		.WB_ready_by_wr(WB_ready_by_wr),

	    // writeback bus by bank
		.WB_bus_valid_by_bank(WB_bus_valid_by_bank),
		.WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

	    // forward data from PRF
		.forward_data_bus_by_bank(prf_forward_data_bus_by_bank),

		// complete bus by bank
		.complete_bus_valid_by_bank(prf_complete_bus_valid_by_bank),
		.complete_bus_ROB_index_by_bank(prf_complete_bus_ROB_index_by_bank)
    );

    // rob
    rob #(
		.ROB_ENTRIES(ROB_ENTRIES),
		.LOG_ROB_ENTRIES(LOG_ROB_ENTRIES),
		.ROB_MISPRED_Q_ENTRIES(ROB_MISPRED_Q_ENTRIES),
		.ROB_PR_FREE_Q_ENTRIES(ROB_PR_FREE_Q_ENTRIES),
		.ROB_RESTART_ON_RESET(ROB_RESTART_ON_RESET),
		.INIT_PC(INIT_PC),
		.INIT_ASID(INIT_ASID),
		.INIT_EXEC_MODE(INIT_EXEC_MODE),
		.INIT_VIRTUAL_MODE(INIT_VIRTUAL_MODE),
		.INIT_MXR(INIT_MXR),
		.INIT_SUM(INIT_SUM),
		.INIT_TRAP_SFENCE(INIT_TRAP_SFENCE),
		.INIT_TRAP_WFI(INIT_TRAP_WFI),
		.INIT_TRAP_SRET(INIT_TRAP_SRET),
		.INIT_TVEC_BASE_PC(INIT_TVEC_BASE_PC)
    ) ROB (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // 4-way ROB dispatch:
		.dispatch_enq_valid(dispatch_rob_enq_valid),
		.dispatch_enq_killed(dispatch_rob_enq_killed),
	    // general instr info
		.dispatch_valid_by_way(dispatch_valid_by_way),
		.dispatch_uncompressed_by_way(dispatch_uncompressed_by_way),
		.dispatch_PC_by_way(dispatch_PC_by_way),
		.dispatch_is_rename_by_way(dispatch_is_rename_by_way),
	    // exception info
		.dispatch_is_page_fault(dispatch_is_page_fault),
		.dispatch_is_access_fault(dispatch_is_access_fault),
		.dispatch_is_illegal_instr(dispatch_is_illegal_instr),
		.dispatch_exception_present(dispatch_exception_present),
		.dispatch_exception_index(dispatch_exception_index),
		.dispatch_illegal_instr32(dispatch_illegal_instr32),
		// checkpoint info
		.dispatch_has_checkpoint(dispatch_has_checkpoint),
		.dispatch_checkpoint_index(dispatch_checkpoint_index),
	    // dest operand
		.dispatch_dest_AR_by_way(dispatch_dest_AR_by_way),
		.dispatch_dest_old_PR_by_way(dispatch_dest_old_PR_by_way),
		.dispatch_dest_new_PR_by_way(dispatch_dest_new_PR_by_way),

	    // ROB dispatch feedback
		.dispatch_enq_ready(dispatch_rob_enq_ready),
		.dispatch_enq_ROB_index_by_way(dispatch_rob_enq_ROB_index_by_way),

	    // writeback bus complete notif by bank
		.complete_bus_valid_by_bank(prf_complete_bus_valid_by_bank),
		.complete_bus_ROB_index_by_bank(prf_complete_bus_ROB_index_by_bank),

	    // LDU complete notif
		.ldu_complete_valid(ldu_complete_valid),
		.ldu_complete_ROB_index(ldu_complete_ROB_index),

	    // STAMOFU complete notif
		.stamofu_complete_valid(stamofu_complete_valid),
		.stamofu_complete_ROB_index(stamofu_complete_ROB_index),

	    // branch notification to ROB
		.branch_notif_valid(branch_notif_valid),
		.branch_notif_ROB_index(branch_notif_ROB_index),
		.branch_notif_is_mispredict(branch_notif_is_mispredict),
		.branch_notif_is_taken(branch_notif_is_taken),
		.branch_notif_use_upct(branch_notif_use_upct),
		.branch_notif_updated_pred_info(branch_notif_updated_pred_info),
		.branch_notif_pred_lru(branch_notif_pred_lru),
		.branch_notif_start_PC(branch_notif_start_PC),
		.branch_notif_target_PC(branch_notif_target_PC),

	    // branch notification backpressure from ROB
		.branch_notif_ready(branch_notif_ready),

	    // LDU misprediction notification to ROB
		.ldu_mispred_notif_valid(ldu_mispred_notif_valid),
		.ldu_mispred_notif_ROB_index(ldu_mispred_notif_ROB_index),

	    // LDU misprediction notification backpressure from ROB
		.ldu_mispred_notif_ready(ldu_mispred_notif_ready),

	    // fence restart notification to ROB
		.fence_restart_notif_valid(fence_restart_notif_valid),
		.fence_restart_notif_ROB_index(fence_restart_notif_ROB_index),

	    // fence restart notification backpressure from ROB
		.fence_restart_notif_ready(fence_restart_notif_ready),

	    // LDU exception to ROB
		.ldu_exception_valid(ldu_exception_valid),
		.ldu_exception_VA(ldu_exception_VA),
		.ldu_exception_page_fault(ldu_exception_page_fault),
		.ldu_exception_access_fault(ldu_exception_access_fault),
		.ldu_exception_ROB_index(ldu_exception_ROB_index),

	    // LDU exception backpressure from ROB
		.ldu_exception_ready(ldu_exception_ready),

	    // STAMOFU exception to ROB
		.stamofu_exception_valid(stamofu_exception_valid),
		.stamofu_exception_VA(stamofu_exception_VA),
		.stamofu_exception_is_lr(stamofu_exception_is_lr),
		.stamofu_exception_page_fault(stamofu_exception_page_fault),
		.stamofu_exception_access_fault(stamofu_exception_access_fault),
		.stamofu_exception_misaligned_exception(stamofu_exception_misaligned_exception),
		.stamofu_exception_ROB_index(stamofu_exception_ROB_index),

	    // STAMOFU exception backpressure from ROB
		.stamofu_exception_ready(stamofu_exception_ready),

	    // mdp update to ROB
		.ssu_mdp_update_valid(ssu_mdp_update_valid),
		.ssu_mdp_update_mdp_info(ssu_mdp_update_mdp_info),
		.ssu_mdp_update_ROB_index(ssu_mdp_update_ROB_index),

	    // mdp update feedback from ROB
		.ssu_mdp_update_ready(ssu_mdp_update_ready),

	    // mdpt update to fetch unit
		.fetch_unit_mdpt_update_valid(fetch_unit_mdpt_update_valid),
		.fetch_unit_mdpt_update_start_full_PC(fetch_unit_mdpt_update_start_full_PC),
		.fetch_unit_mdpt_update_ASID(fetch_unit_mdpt_update_ASID),
		.fetch_unit_mdpt_update_mdp_info(fetch_unit_mdpt_update_mdp_info),

	    // ROB commit
		.rob_commit_upper_index(rob_commit_upper_index),
		.rob_commit_lower_index_valid_mask(rob_commit_lower_index_valid_mask),

	    // restart from ROB
		.rob_restart_valid(rob_restart_valid),
		.rob_restart_PC(rob_restart_PC),
		.rob_restart_ASID(rob_restart_ASID),
		.rob_restart_exec_mode(rob_restart_exec_mode),
		.rob_restart_virtual_mode(rob_restart_virtual_mode),
		.rob_restart_MXR(rob_restart_MXR),
		.rob_restart_SUM(rob_restart_SUM),
		.rob_restart_trap_sfence(rob_restart_trap_sfence),
		.rob_restart_trap_wfi(rob_restart_trap_wfi),
		.rob_restart_trap_sret(rob_restart_trap_sret),

	    // ROB kill
		.rob_kill_valid(rob_kill_valid),
		.rob_kill_abs_head_index(rob_kill_abs_head_index),
		.rob_kill_rel_kill_younger_index(rob_kill_rel_kill_younger_index),

	    // branch update from ROB
		.rob_branch_update_valid(rob_branch_update_valid),
		.rob_branch_update_has_checkpoint(rob_branch_update_has_checkpoint),
		.rob_branch_update_checkpoint_index(rob_branch_update_checkpoint_index),
		.rob_branch_update_is_mispredict(rob_branch_update_is_mispredict),
		.rob_branch_update_is_taken(rob_branch_update_is_taken),
		.rob_branch_update_use_upct(rob_branch_update_use_upct),
		.rob_branch_update_intermediate_pred_info(rob_branch_update_intermediate_pred_info),
		.rob_branch_update_pred_lru(rob_branch_update_pred_lru),
		.rob_branch_update_start_PC(rob_branch_update_start_PC),
		.rob_branch_update_target_PC(rob_branch_update_target_PC),

	    // ROB control of rename
		.rob_controlling_rename(rob_controlling_rename),

		.rob_checkpoint_map_table_restore_valid(rob_checkpoint_map_table_restore_valid),
		.rob_checkpoint_map_table_restore_index(rob_checkpoint_map_table_restore_index),

		.rob_checkpoint_clear_valid(rob_checkpoint_clear_valid),
		.rob_checkpoint_clear_index(rob_checkpoint_clear_index),

		.rob_map_table_write_valid_by_port(rob_map_table_write_valid_by_port),
		.rob_map_table_write_AR_by_port(rob_map_table_write_AR_by_port),
		.rob_map_table_write_PR_by_port(rob_map_table_write_PR_by_port),

		// ROB physical register freeing
		.rob_PR_free_req_valid_by_bank(rob_PR_free_req_valid_by_bank),
		.rob_PR_free_req_PR_by_bank(rob_PR_free_req_PR_by_bank),
		.rob_PR_free_resp_ack_by_bank(rob_PR_free_resp_ack_by_bank)
	);

    // ----------------------------------------------------------------
    // Backend Modules:

    // ----------------------------------------------------------------
    // alu_reg_mdu:

    // alu_reg_mdu_dq
    alu_reg_mdu_dq #(
        .ALU_REG_MDU_DQ_ENTRIES(ALU_REG_MDU_DQ_ENTRIES)
    ) ALU_REG_MDU_DQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),
        
        // op dispatch by way
        .dispatch_attempt_by_way(dispatch_attempt_alu_reg_mdu_dq_by_way),
        .dispatch_valid_alu_reg_by_way(dispatch_valid_alu_reg_by_way),
        .dispatch_valid_mdu_by_way(dispatch_valid_mdu_by_way),
        .dispatch_op_by_way(dispatch_op_by_way),
        .dispatch_A_PR_by_way(dispatch_A_PR_by_way),
        .dispatch_A_ready_by_way(dispatch_A_ready_by_way),
        .dispatch_A_is_zero_by_way(dispatch_A_is_zero_by_way),
        .dispatch_B_PR_by_way(dispatch_B_PR_by_way),
        .dispatch_B_ready_by_way(dispatch_B_ready_by_way),
        .dispatch_B_is_zero_by_way(dispatch_B_is_zero_by_way),
        .dispatch_dest_PR_by_way(dispatch_dest_new_PR_by_way),
        .dispatch_enq_ROB_index_by_way(dispatch_rob_enq_ROB_index_by_way),

        // op dispatch feedback
        .dispatch_ack_by_way(dispatch_ack_alu_reg_mdu_dq_by_way),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // op enqueue to issue queue
        .iq_enq_valid(alu_reg_mdu_iq_enq_valid),
        .iq_enq_is_alu_reg(alu_reg_mdu_iq_enq_is_alu_reg),
        .iq_enq_is_mdu(alu_reg_mdu_iq_enq_is_mdu),
        .iq_enq_op(alu_reg_mdu_iq_enq_op),
        .iq_enq_A_PR(alu_reg_mdu_iq_enq_A_PR),
        .iq_enq_A_ready(alu_reg_mdu_iq_enq_A_ready),
        .iq_enq_A_is_zero(alu_reg_mdu_iq_enq_A_is_zero),
        .iq_enq_B_PR(alu_reg_mdu_iq_enq_B_PR),
        .iq_enq_B_ready(alu_reg_mdu_iq_enq_B_ready),
        .iq_enq_B_is_zero(alu_reg_mdu_iq_enq_B_is_zero),
        .iq_enq_dest_PR(alu_reg_mdu_iq_enq_dest_PR),
        .iq_enq_ROB_index(alu_reg_mdu_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(alu_reg_mdu_iq_enq_ready)
    );

    // alu_reg_mdu_iq_single
    alu_reg_mdu_iq_single #(
        .ALU_REG_MDU_IQ_ENTRIES(ALU_REG_MDU_IQ_ENTRIES)
    ) ALU_REG_MDU_IQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op enqueue to issue queue
        .iq_enq_valid(alu_reg_mdu_iq_enq_valid),
        .iq_enq_is_alu_reg(alu_reg_mdu_iq_enq_is_alu_reg),
        .iq_enq_is_mdu(alu_reg_mdu_iq_enq_is_mdu),
        .iq_enq_op(alu_reg_mdu_iq_enq_op),
        .iq_enq_A_PR(alu_reg_mdu_iq_enq_A_PR),
        .iq_enq_A_ready(alu_reg_mdu_iq_enq_A_ready),
        .iq_enq_A_is_zero(alu_reg_mdu_iq_enq_A_is_zero),
        .iq_enq_B_PR(alu_reg_mdu_iq_enq_B_PR),
        .iq_enq_B_ready(alu_reg_mdu_iq_enq_B_ready),
        .iq_enq_B_is_zero(alu_reg_mdu_iq_enq_B_is_zero),
        .iq_enq_dest_PR(alu_reg_mdu_iq_enq_dest_PR),
        .iq_enq_ROB_index(alu_reg_mdu_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(alu_reg_mdu_iq_enq_ready),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // ALU reg pipeline issue
        .alu_reg_issue_valid(alu_reg_issue_valid),

        // MDU pipeline issue
        .mdu_issue_valid(mdu_issue_valid),
        
        // shared issue info
        .issue_op(alu_reg_mdu_issue_op),
        .issue_A_forward(alu_reg_mdu_issue_A_forward),
        .issue_A_is_zero(alu_reg_mdu_issue_A_is_zero),
        .issue_A_bank(alu_reg_mdu_issue_A_bank),
        .issue_B_forward(alu_reg_mdu_issue_B_forward),
        .issue_B_is_zero(alu_reg_mdu_issue_B_is_zero),
        .issue_B_bank(alu_reg_mdu_issue_B_bank),
        .issue_dest_PR(alu_reg_mdu_issue_dest_PR),
        .issue_ROB_index(alu_reg_mdu_issue_ROB_index),

        // ALU reg pipeline feedback
        .alu_reg_issue_ready(alu_reg_issue_ready),

        // MDU pipeline feedback
        .mdu_issue_ready(mdu_issue_ready),

        // reg read req to PRF
        .PRF_req_A_valid(alu_reg_mdu_PRF_req_A_valid),
        .PRF_req_A_PR(alu_reg_mdu_PRF_req_A_PR),
        .PRF_req_B_valid(alu_reg_mdu_PRF_req_B_valid),
        .PRF_req_B_PR(alu_reg_mdu_PRF_req_B_PR)
    );

    // alu_reg_pipeline_fast
    alu_reg_pipeline_fast ALU_REG_PIPELINE (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // ALU reg op issue from IQ
        .issue_valid(alu_reg_issue_valid),
        .issue_op(alu_reg_mdu_issue_op),
        .issue_A_forward(alu_reg_mdu_issue_A_forward),
        .issue_A_is_zero(alu_reg_mdu_issue_A_is_zero),
        .issue_A_bank(alu_reg_mdu_issue_A_bank),
        .issue_B_forward(alu_reg_mdu_issue_B_forward),
        .issue_B_is_zero(alu_reg_mdu_issue_B_is_zero),
        .issue_B_bank(alu_reg_mdu_issue_B_bank),
        .issue_dest_PR(alu_reg_mdu_issue_dest_PR),
        .issue_ROB_index(alu_reg_mdu_issue_ROB_index),

        // ready feedback to IQ
        .issue_ready(alu_reg_issue_ready),

        // reg read info and data from PRF
        .A_reg_read_ack(alu_reg_mdu_PRF_A_reg_read_ack),
        .A_reg_read_port(alu_reg_mdu_PRF_A_reg_read_port),
        .B_reg_read_ack(alu_reg_mdu_PRF_B_reg_read_ack),
        .B_reg_read_port(alu_reg_mdu_PRF_B_reg_read_port),
        .reg_read_data_by_bank_by_port(prf_read_data_by_bank_by_port),

        // forward data from PRF
        .forward_data_by_bank(prf_forward_data_bus_by_bank),

        // writeback data to PRF
        .WB_valid(alu_reg_WB_valid),
        .WB_data(alu_reg_WB_data),
        .WB_PR(alu_reg_WB_PR),
        .WB_ROB_index(alu_reg_WB_ROB_index),

        // writeback feedback from PRF
        .WB_ready(alu_reg_WB_ready)
    );

    // mdu_pipeline
        // TODO: implement module
        // hardwired outputs for now
    always_comb begin
        mdu_issue_ready = 1'b0;

        mdu_WB_valid = 1'b0;
        mdu_WB_data = 32'h0;
        mdu_WB_PR = 0;
        mdu_WB_ROB_index = 0;
    end

    // ----------------------------------------------------------------
    // alu_imm:

    // alu_imm_dq
    alu_imm_dq #(
        .ALU_IMM_DQ_ENTRIES(ALU_IMM_DQ_ENTRIES)
    ) ALU_IMM_DQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op dispatch by way
        .dispatch_attempt_by_way(dispatch_attempt_alu_imm_dq_by_way),
        .dispatch_valid_by_way(dispatch_valid_alu_imm_by_way),
        .dispatch_op_by_way(dispatch_op_by_way),
        .dispatch_imm12_by_way(dispatch_imm12_by_way),
        .dispatch_A_PR_by_way(dispatch_A_PR_by_way),
        .dispatch_A_ready_by_way(dispatch_A_ready_by_way),
        .dispatch_A_is_zero_by_way(dispatch_A_is_zero_by_way),
        .dispatch_dest_PR_by_way(dispatch_dest_new_PR_by_way),
        .dispatch_ROB_index_by_way(dispatch_rob_enq_ROB_index_by_way),

        // op dispatch feedback
        .dispatch_ack_by_way(dispatch_ack_alu_imm_dq_by_way),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // op enqueue to issue queue
        .iq_enq_valid(alu_imm_iq_enq_valid),
        .iq_enq_op(alu_imm_iq_enq_op),
        .iq_enq_imm12(alu_imm_iq_enq_imm12),
        .iq_enq_A_PR(alu_imm_iq_enq_A_PR),
        .iq_enq_A_ready(alu_imm_iq_enq_A_ready),
        .iq_enq_A_is_zero(alu_imm_iq_enq_A_is_zero),
        .iq_enq_dest_PR(alu_imm_iq_enq_dest_PR),
        .iq_enq_ROB_index(alu_imm_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(alu_imm_iq_enq_ready)
    );

    // alu_imm_iq
    alu_imm_iq #(
        .ALU_IMM_IQ_ENTRIES(ALU_IMM_IQ_ENTRIES)
    ) ALU_IMM_IQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op enqueue to issue queue
        .iq_enq_valid(alu_imm_iq_enq_valid),
        .iq_enq_op(alu_imm_iq_enq_op),
        .iq_enq_imm12(alu_imm_iq_enq_imm12),
        .iq_enq_A_PR(alu_imm_iq_enq_A_PR),
        .iq_enq_A_ready(alu_imm_iq_enq_A_ready),
        .iq_enq_A_is_zero(alu_imm_iq_enq_A_is_zero),
        .iq_enq_dest_PR(alu_imm_iq_enq_dest_PR),
        .iq_enq_ROB_index(alu_imm_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(alu_imm_iq_enq_ready),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // pipeline issue
        .issue_valid(alu_imm_issue_valid),
        .issue_op(alu_imm_issue_op),
        .issue_imm12(alu_imm_issue_imm12),
        .issue_A_forward(alu_imm_issue_A_forward),
        .issue_A_is_zero(alu_imm_issue_A_is_zero),
        .issue_A_bank(alu_imm_issue_A_bank),
        .issue_dest_PR(alu_imm_issue_dest_PR),
        .issue_ROB_index(alu_imm_issue_ROB_index),

        // pipeline feedback
        .issue_ready(alu_imm_issue_ready),

        // reg read req to PRF
        .PRF_req_A_valid(alu_imm_PRF_req_A_valid),
        .PRF_req_A_PR(alu_imm_PRF_req_A_PR)
    );

    // alu_imm_pipeline_fast
    alu_imm_pipeline_fast ALU_IMM_PIPELINE (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // ALU imm op issue from IQ
        .issue_valid(alu_imm_issue_valid),
        .issue_op(alu_imm_issue_op),
        .issue_imm12(alu_imm_issue_imm12),
        .issue_A_forward(alu_imm_issue_A_forward),
        .issue_A_is_zero(alu_imm_issue_A_is_zero),
        .issue_A_bank(alu_imm_issue_A_bank),
        .issue_dest_PR(alu_imm_issue_dest_PR),
        .issue_ROB_index(alu_imm_issue_ROB_index),

        // ready feedback to IQ
        .issue_ready(alu_imm_issue_ready),

        // reg read info and data from PRF
        .A_reg_read_ack(alu_imm_PRF_A_reg_read_ack),
        .A_reg_read_port(alu_imm_PRF_A_reg_read_port),
        .reg_read_data_by_bank_by_port(prf_read_data_by_bank_by_port),

        // forward data from PRF
        .forward_data_by_bank(prf_forward_data_bus_by_bank),

        // writeback data to PRF
        .WB_valid(alu_imm_WB_valid),
        .WB_data(alu_imm_WB_data),
        .WB_PR(alu_imm_WB_PR),
        .WB_ROB_index(alu_imm_WB_ROB_index),

        // writeback backpressure from PRF
        .WB_ready(alu_imm_WB_ready)
    );

    // ----------------------------------------------------------------
    // bru:

    // bru_dq
    bru_dq #(
        .BRU_DQ_ENTRIES(BRU_DQ_ENTRIES)
    ) BRU_DQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op dispatch by way
        .dispatch_attempt_by_way(dispatch_attempt_bru_dq_by_way),
        .dispatch_valid_by_way(dispatch_valid_bru_by_way),
        .dispatch_op_by_way(dispatch_op_by_way),
        .dispatch_pred_info_by_way(dispatch_pred_info_by_way),
        .dispatch_pred_lru_by_way(dispatch_pred_lru_by_way),
        .dispatch_is_link_ra_by_way(dispatch_dest_is_link_ra_by_way),
        .dispatch_is_ret_ra_by_way(dispatch_A_is_ret_ra_by_way),
        .dispatch_PC_by_way(dispatch_PC_by_way),
        .dispatch_pred_PC_by_way(dispatch_pred_PC_by_way),
        .dispatch_imm20_by_way(dispatch_imm20_by_way),
        .dispatch_A_PR_by_way(dispatch_A_PR_by_way),
        .dispatch_A_ready_by_way(dispatch_A_ready_by_way),
        .dispatch_A_unneeded_or_is_zero_by_way(dispatch_A_unneeded_or_is_zero_by_way),
        .dispatch_B_PR_by_way(dispatch_B_PR_by_way),
        .dispatch_B_ready_by_way(dispatch_B_ready_by_way),
        .dispatch_B_unneeded_or_is_zero_by_way(dispatch_B_unneeded_or_is_zero_by_way),
        .dispatch_dest_PR_by_way(dispatch_dest_new_PR_by_way),
        .dispatch_ROB_index_by_way(dispatch_rob_enq_ROB_index_by_way),

        // op dispatch feedback
        .dispatch_ack_by_way(dispatch_ack_bru_dq_by_way),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // op enqueue to issue queue
        .iq_enq_valid(bru_iq_enq_valid),
        .iq_enq_op(bru_iq_enq_op),
        .iq_enq_pred_info(bru_iq_enq_pred_info),
        .iq_enq_pred_lru(bru_iq_enq_pred_lru),
        .iq_enq_is_link_ra(bru_iq_enq_is_link_ra),
        .iq_enq_is_ret_ra(bru_iq_enq_is_ret_ra),
        .iq_enq_PC(bru_iq_enq_PC),
        .iq_enq_pred_PC(bru_iq_enq_pred_PC),
        .iq_enq_imm20(bru_iq_enq_imm20),
        .iq_enq_A_PR(bru_iq_enq_A_PR),
        .iq_enq_A_ready(bru_iq_enq_A_ready),
        .iq_enq_A_unneeded_or_is_zero(bru_iq_enq_A_unneeded_or_is_zero),
        .iq_enq_B_PR(bru_iq_enq_B_PR),
        .iq_enq_B_ready(bru_iq_enq_B_ready),
        .iq_enq_B_unneeded_or_is_zero(bru_iq_enq_B_unneeded_or_is_zero),
        .iq_enq_dest_PR(bru_iq_enq_dest_PR),
        .iq_enq_ROB_index(bru_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(bru_iq_enq_ready)
    );

    // bru_iq
    bru_iq #(
        .BRU_IQ_ENTRIES(BRU_IQ_ENTRIES)
    ) BRU_IQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op enqueue to issue queue
        .iq_enq_valid(bru_iq_enq_valid),
        .iq_enq_op(bru_iq_enq_op),
        .iq_enq_pred_info(bru_iq_enq_pred_info),
        .iq_enq_pred_lru(bru_iq_enq_pred_lru),
        .iq_enq_is_link_ra(bru_iq_enq_is_link_ra),
        .iq_enq_is_ret_ra(bru_iq_enq_is_ret_ra),
        .iq_enq_PC(bru_iq_enq_PC),
        .iq_enq_pred_PC(bru_iq_enq_pred_PC),
        .iq_enq_imm20(bru_iq_enq_imm20),
        .iq_enq_A_PR(bru_iq_enq_A_PR),
        .iq_enq_A_ready(bru_iq_enq_A_ready),
        .iq_enq_A_unneeded_or_is_zero(bru_iq_enq_A_unneeded_or_is_zero),
        .iq_enq_B_PR(bru_iq_enq_B_PR),
        .iq_enq_B_ready(bru_iq_enq_B_ready),
        .iq_enq_B_unneeded_or_is_zero(bru_iq_enq_B_unneeded_or_is_zero),
        .iq_enq_dest_PR(bru_iq_enq_dest_PR),
        .iq_enq_ROB_index(bru_iq_enq_ROB_index),

        // issue queue enqueue feedback
        .iq_enq_ready(bru_iq_enq_ready),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // pipeline issue
        .issue_valid(bru_issue_valid),
        .issue_op(bru_issue_op),
        .issue_pred_info(bru_issue_pred_info),
        .issue_pred_lru(bru_issue_pred_lru),
        .issue_is_link_ra(bru_issue_is_link_ra),
        .issue_is_ret_ra(bru_issue_is_ret_ra),
        .issue_PC(bru_issue_PC),
        .issue_pred_PC(bru_issue_pred_PC),
        .issue_imm20(bru_issue_imm20),
        .issue_A_forward(bru_issue_A_forward),
        .issue_A_unneeded_or_is_zero(bru_issue_A_unneeded_or_is_zero),
        .issue_A_bank(bru_issue_A_bank),
        .issue_B_forward(bru_issue_B_forward),
        .issue_B_unneeded_or_is_zero(bru_issue_B_unneeded_or_is_zero),
        .issue_B_bank(bru_issue_B_bank),
        .issue_dest_PR(bru_issue_dest_PR),
        .issue_ROB_index(bru_issue_ROB_index),

        // pipeline feedback
        .issue_ready(bru_issue_ready),

        // reg read req to PRF
        .PRF_req_A_valid(bru_PRF_req_A_valid),
        .PRF_req_A_PR(bru_PRF_req_A_PR),
        .PRF_req_B_valid(bru_PRF_req_B_valid),
        .PRF_req_B_PR(bru_PRF_req_B_PR)
    );

    // bru_pipeline_fast
    bru_pipeline_fast BRU_PIPELINE (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // BRU op issue from BRU IQ
        .issue_valid(bru_issue_valid),
        .issue_op(bru_issue_op),
        .issue_pred_info(bru_issue_pred_info),
        .issue_pred_lru(bru_issue_pred_lru),
        .issue_is_link_ra(bru_issue_is_link_ra),
        .issue_is_ret_ra(bru_issue_is_ret_ra),
        .issue_PC(bru_issue_PC),
        .issue_pred_PC(bru_issue_pred_PC),
        .issue_imm20(bru_issue_imm20),
        .issue_A_forward(bru_issue_A_forward),
        .issue_A_unneeded_or_is_zero(bru_issue_A_unneeded_or_is_zero),
        .issue_A_bank(bru_issue_A_bank),
        .issue_B_forward(bru_issue_B_forward),
        .issue_B_unneeded_or_is_zero(bru_issue_B_unneeded_or_is_zero),
        .issue_B_bank(bru_issue_B_bank),
        .issue_dest_PR(bru_issue_dest_PR),
        .issue_ROB_index(bru_issue_ROB_index),

        // output feedback to BRU IQ
        .issue_ready(bru_issue_ready),

        // reg read info and data from PRF
        .A_reg_read_ack(bru_PRF_A_reg_read_ack),
        .A_reg_read_port(bru_PRF_A_reg_read_port),
        .B_reg_read_ack(bru_PRF_B_reg_read_ack),
        .B_reg_read_port(bru_PRF_B_reg_read_port),
        .reg_read_data_by_bank_by_port(prf_read_data_by_bank_by_port),

        // forward data from PRF
        .forward_data_by_bank(prf_forward_data_bus_by_bank),

        // writeback data to PRF
        .WB_valid(bru_WB_valid),
        .WB_data(bru_WB_data),
        .WB_PR(bru_WB_PR),
        .WB_ROB_index(bru_WB_ROB_index),

        // writeback backpressure from PRF
        .WB_ready(bru_WB_ready),

        // branch notification to ROB
		.branch_notif_valid(branch_notif_valid),
		.branch_notif_ROB_index(branch_notif_ROB_index),
		.branch_notif_is_mispredict(branch_notif_is_mispredict),
		.branch_notif_is_taken(branch_notif_is_taken),
		.branch_notif_use_upct(branch_notif_use_upct),
		.branch_notif_updated_pred_info(branch_notif_updated_pred_info),
		.branch_notif_pred_lru(branch_notif_pred_lru),
		.branch_notif_start_PC(branch_notif_start_PC),
		.branch_notif_target_PC(branch_notif_target_PC),

	    // branch notification backpressure from ROB
		.branch_notif_ready(branch_notif_ready)
    );

    // ----------------------------------------------------------------
    // lsu:

    // ----------------------------------------------------------------
    // ldu:

    // ldu_dq
    ldu_dq #(
        .LDU_DQ_ENTRIES(LDU_DQ_ENTRIES)
    ) LDU_DQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op dispatch by way
        .dispatch_attempt_by_way(dispatch_attempt_ldu_dq_by_way),
        .dispatch_valid_by_way(dispatch_valid_ldu_by_way),
        .dispatch_op_by_way(dispatch_op_by_way),
        .dispatch_imm12_by_way(dispatch_imm12_by_way),
        .dispatch_mdp_info_by_way(dispatch_mdp_info_by_way),
        .dispatch_A_PR_by_way(dispatch_A_PR_by_way),
        .dispatch_A_ready_by_way(dispatch_A_ready_by_way),
        .dispatch_A_is_zero_by_way(dispatch_A_is_zero_by_way),
        .dispatch_dest_PR_by_way(dispatch_dest_new_PR_by_way),
        .dispatch_ROB_index_by_way(dispatch_rob_enq_ROB_index_by_way),

        // op dispatch feedback
        .dispatch_ack_by_way(dispatch_ack_ldu_dq_by_way),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // op enqueue to central queue
        .ldu_cq_enq_valid(ldu_cq_enq_valid),
        .ldu_cq_enq_killed(ldu_cq_enq_killed),
        .ldu_cq_enq_op(ldu_cq_enq_op),
        .ldu_cq_enq_mdp_info(ldu_cq_enq_mdp_info),
        .ldu_cq_enq_dest_PR(ldu_cq_enq_dest_PR),
        .ldu_cq_enq_ROB_index(ldu_cq_enq_ROB_index),
    
        // central queue enqueue feedback
        .ldu_cq_enq_ready(ldu_cq_enq_ready),
        .ldu_cq_enq_index(ldu_cq_enq_index),

        // op enqueue to issue queue
        .ldu_iq_enq_valid(ldu_iq_enq_valid),
        .ldu_iq_enq_op(ldu_iq_enq_op),
        .ldu_iq_enq_imm12(ldu_iq_enq_imm12),
        .ldu_iq_enq_A_PR(ldu_iq_enq_A_PR),
        .ldu_iq_enq_A_ready(ldu_iq_enq_A_ready),
        .ldu_iq_enq_A_is_zero(ldu_iq_enq_A_is_zero),
        .ldu_iq_enq_cq_index(ldu_iq_enq_cq_index),

        // issue queue enqueue feedback
        .ldu_iq_enq_ready(ldu_iq_enq_ready),

	    // ROB kill
		.rob_kill_valid(rob_kill_valid),
		.rob_kill_abs_head_index(rob_kill_abs_head_index),
		.rob_kill_rel_kill_younger_index(rob_kill_rel_kill_younger_index)
    );

    // ldu_iq
    ldu_iq #(
        .LDU_IQ_ENTRIES(LDU_IQ_ENTRIES)
    ) LDU_IQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op enqueue to issue queue
        .ldu_iq_enq_valid(ldu_iq_enq_valid),
        .ldu_iq_enq_op(ldu_iq_enq_op),
        .ldu_iq_enq_imm12(ldu_iq_enq_imm12),
        .ldu_iq_enq_A_PR(ldu_iq_enq_A_PR),
        .ldu_iq_enq_A_ready(ldu_iq_enq_A_ready),
        .ldu_iq_enq_A_is_zero(ldu_iq_enq_A_is_zero),
        .ldu_iq_enq_cq_index(ldu_iq_enq_cq_index),

        // issue queue enqueue feedback
        .ldu_iq_enq_ready(ldu_iq_enq_ready),

        // writeback bus by bank
        .WB_bus_valid_by_bank(WB_bus_valid_by_bank),
        .WB_bus_upper_PR_by_bank(WB_bus_upper_PR_by_bank),

        // pipeline issue
        .issue_valid(ldu_issue_valid),
        .issue_op(ldu_issue_op),
        .issue_imm12(ldu_issue_imm12),
        .issue_A_forward(ldu_issue_A_forward),
        .issue_A_is_zero(ldu_issue_A_is_zero),
        .issue_A_bank(ldu_issue_A_bank),
        .issue_cq_index(ldu_issue_cq_index),

        // reg read req to PRF
        .PRF_req_A_valid(ldu_PRF_req_A_valid),
        .PRF_req_A_PR(ldu_PRF_req_A_PR),

        // pipeline feedback
        .pipeline_ready(ldu_issue_ready)
    );

    // ldu_addr_pipeline
    ldu_addr_pipeline LDU_ADDR_PIPELINE (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op issue from IQ
        .issue_valid(ldu_issue_valid),
        .issue_op(ldu_issue_op),
        .issue_imm12(ldu_issue_imm12),
        .issue_A_forward(ldu_issue_A_forward),
        .issue_A_is_zero(ldu_issue_A_is_zero),
        .issue_A_bank(ldu_issue_A_bank),
        .issue_cq_index(ldu_issue_cq_index),

        // output feedback to IQ
        .issue_ready(ldu_issue_ready),

        // reg read info and data from PRF
        .A_reg_read_ack(ldu_PRF_A_reg_read_ack),
        .A_reg_read_port(ldu_PRF_A_reg_read_port),
        .reg_read_data_by_bank_by_port(prf_read_data_by_bank_by_port),

        // forward data from PRF
        .forward_data_by_bank(prf_forward_data_bus_by_bank),

        // REQ stage info
        .REQ_bank0_valid(ldu_launch_pipeline_first_try_bank0_valid),
        .REQ_bank1_valid(ldu_launch_pipeline_first_try_bank1_valid),
        
        .REQ_is_mq(ldu_launch_pipeline_first_try_is_mq),
        .REQ_misaligned(ldu_launch_pipeline_first_try_misaligned),
        .REQ_VPN(ldu_launch_pipeline_first_try_VPN),
        .REQ_PO_word(ldu_launch_pipeline_first_try_PO_word),
        .REQ_byte_mask(ldu_launch_pipeline_first_try_byte_mask),
        .REQ_cq_index(ldu_launch_pipeline_first_try_cq_index),

        // REQ stage feedback
        .REQ_bank0_early_ready(ldu_launch_pipeline_first_try_bank0_early_ready),
        .REQ_bank1_early_ready(ldu_launch_pipeline_first_try_bank1_early_ready)
    );

    // ldu_launch_pipeline bank 0
    ldu_launch_pipeline #(
        .INIT_ASID(INIT_ASID),
        .INIT_EXEC_MODE(INIT_EXEC_MODE),
        .INIT_VIRTUAL_MODE(INIT_VIRTUAL_MODE),
        .INIT_MXR(INIT_MXR),
        .INIT_SUM(INIT_SUM)
    ) LDU_LAUNCH_PIPELINE_BANK0 (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // first try
        .first_try_valid(ldu_launch_pipeline_first_try_bank0_valid),
        .first_try_is_mq(ldu_launch_pipeline_first_try_is_mq),
        .first_try_misaligned(ldu_launch_pipeline_first_try_misaligned),
        .first_try_VPN(ldu_launch_pipeline_first_try_VPN),
        .first_try_PO_word(ldu_launch_pipeline_first_try_PO_word),
        .first_try_byte_mask(ldu_launch_pipeline_first_try_byte_mask),
        .first_try_cq_index(ldu_launch_pipeline_first_try_cq_index),

        // first try feedback
        .first_try_early_ready(ldu_launch_pipeline_first_try_bank0_early_ready),

        // op enqueue to misaligned queue
        .ldu_mq_enq_valid(ldu_launch_pipeline_bank0_ldu_mq_enq_valid),

        // misaligned queue enqueue feedback
        .ldu_mq_enq_ready(ldu_launch_pipeline_bank0_ldu_mq_enq_ready),
        .ldu_mq_enq_index(ldu_mq_enq_index),

        // ROB info
        .rob_abs_head_index(rob_kill_abs_head_index),

        // acquire advertisement
        .stamofu_aq_mem_aq_active(stamofu_aq_mem_aq_active),
        .stamofu_aq_mem_aq_oldest_abs_ROB_index(stamofu_aq_mem_aq_oldest_abs_ROB_index),
        .stamofu_aq_io_aq_active(stamofu_aq_io_aq_active),
        .stamofu_aq_io_aq_oldest_abs_ROB_index(stamofu_aq_io_aq_oldest_abs_ROB_index),

        // second try
        .second_try_valid(ldu_launch_pipeline_second_try_bank0_valid),
        .second_try_do_mispred(ldu_launch_pipeline_second_try_do_mispred),
        .second_try_is_mq(ldu_launch_pipeline_second_try_is_mq),
        .second_try_misaligned(ldu_launch_pipeline_second_try_misaligned),
        .second_try_page_fault(ldu_launch_pipeline_second_try_page_fault),
        .second_try_access_fault(ldu_launch_pipeline_second_try_access_fault),
        .second_try_is_mem(ldu_launch_pipeline_second_try_is_mem),
        .second_try_PPN(ldu_launch_pipeline_second_try_PPN),
        .second_try_PO_word(ldu_launch_pipeline_second_try_PO_word),
        .second_try_byte_mask(ldu_launch_pipeline_second_try_byte_mask),
        .second_try_cq_index(ldu_launch_pipeline_second_try_cq_index),
        .second_try_mq_index(ldu_launch_pipeline_second_try_mq_index),

        // second try feedback
        .second_try_ack(ldu_launch_pipeline_second_try_bank0_ack),

        // data try
        .data_try_valid(ldu_launch_pipeline_data_try_bank0_valid),
        .data_try_do_mispred(ldu_launch_pipeline_data_try_do_mispred),
        .data_try_data(ldu_launch_pipeline_data_try_data),
        .data_try_cq_index(ldu_launch_pipeline_data_try_cq_index),

        // data try feedback
        .data_try_ack(ldu_launch_pipeline_data_try_bank0_ack),

        // dtlb req
        .dtlb_req_valid(dtlb_req_bank0_valid),
        .dtlb_req_exec_mode(dtlb_req_bank0_exec_mode),
        .dtlb_req_virtual_mode(dtlb_req_bank0_virtual_mode),
        .dtlb_req_ASID(dtlb_req_bank0_ASID),
        .dtlb_req_MXR(dtlb_req_bank0_MXR),
        .dtlb_req_SUM(dtlb_req_bank0_SUM),
        .dtlb_req_VPN(dtlb_req_bank0_VPN),

        // dtlb req feedback
        .dtlb_req_ready(dtlb_req_bank0_ready),

        // dtlb resp
        .dtlb_resp_hit(dtlb_resp_bank0_hit),
        .dtlb_resp_PPN(dtlb_resp_bank0_PPN),
        .dtlb_resp_is_mem(dtlb_resp_bank0_is_mem),
        .dtlb_resp_page_fault(dtlb_resp_bank0_page_fault),
        .dtlb_resp_access_fault(dtlb_resp_bank0_access_fault),

        // dcache req
        .dcache_req_valid(dcache_req_bank0_valid),
        .dcache_req_block_offset(dcache_req_bank0_block_offset),
        .dcache_req_index(dcache_req_bank0_index),
        .dcache_req_cq_index(dcache_req_bank0_cq_index),
        .dcache_req_is_mq(dcache_req_bank0_is_mq),
        .dcache_req_mq_index(dcache_req_bank0_mq_index),

        // dcache req feedback
        .dcache_req_ready(dcache_req_bank0_ready),

        // dcache resp
        .dcache_resp_valid_by_way(dcache_resp_bank0_valid_by_way),
        .dcache_resp_tag_by_way(dcache_resp_bank0_tag_by_way),
        .dcache_resp_data_by_way(dcache_resp_bank0_data_by_way),

        // dcache resp feedback
        .dcache_resp_hit_valid(dcache_resp_bank0_hit_valid),
        .dcache_resp_hit_way(dcache_resp_bank0_hit_way),
        .dcache_resp_miss_valid(dcache_resp_bank0_miss_valid),
        .dcache_resp_miss_tag(dcache_resp_bank0_miss_tag),

        // writeback data to PRF
        .WB_valid(ldu_bank0_WB_valid),
        .WB_data(ldu_bank0_WB_data),
        .WB_PR(ldu_bank0_WB_PR),
        .WB_ROB_index(ldu_bank0_WB_ROB_index),

        // writeback backpressure from PRF
        .WB_ready(ldu_bank0_WB_ready),

        // CAM launch
        .stamofu_CAM_launch_valid(stamofu_CAM_launch_bank0_valid),
        .stamofu_CAM_launch_cq_index(stamofu_CAM_launch_bank0_cq_index),
        .stamofu_CAM_launch_is_mq(stamofu_CAM_launch_bank0_is_mq),
        .stamofu_CAM_launch_mq_index(stamofu_CAM_launch_bank0_mq_index),
        .stamofu_CAM_launch_PA_word(stamofu_CAM_launch_bank0_PA_word),
        .stamofu_CAM_launch_byte_mask(stamofu_CAM_launch_bank0_byte_mask),
        .stamofu_CAM_launch_ROB_index(stamofu_CAM_launch_bank0_ROB_index),
        .stamofu_CAM_launch_mdp_info(stamofu_CAM_launch_bank0_mdp_info),

        // central queue info grab
        .ldu_cq_info_grab_cq_index(ldu_cq_info_grab_bank0_cq_index),
        .ldu_cq_info_grab_op(ldu_cq_info_grab_bank0_op),
        .ldu_cq_info_grab_mdp_info(ldu_cq_info_grab_bank0_mdp_info),
        .ldu_cq_info_grab_dest_PR(ldu_cq_info_grab_bank0_dest_PR),
        .ldu_cq_info_grab_ROB_index(ldu_cq_info_grab_bank0_ROB_index),

        // central queue info ret
        .ldu_cq_info_ret_valid(ldu_cq_info_ret_bank0_valid),
        .ldu_cq_info_ret_cq_index(ldu_cq_info_ret_bank0_WB_sent),
        .ldu_cq_info_ret_WB_sent(ldu_cq_info_ret_bank0_cq_index),
        .ldu_cq_info_ret_misaligned(ldu_cq_info_ret_bank0_misaligned),
        .ldu_cq_info_ret_dtlb_hit(ldu_cq_info_ret_bank0_dtlb_hit),
        .ldu_cq_info_ret_page_fault(ldu_cq_info_ret_bank0_page_fault),
        .ldu_cq_info_ret_access_fault(ldu_cq_info_ret_bank0_access_fault),
        .ldu_cq_info_ret_dcache_hit(ldu_cq_info_ret_bank0_dcache_hit),
        .ldu_cq_info_ret_is_mem(ldu_cq_info_ret_bank0_is_mem),
        .ldu_cq_info_ret_aq_blocking(ldu_cq_info_ret_bank0_aq_blocking),
        .ldu_cq_info_ret_PA_word(ldu_cq_info_ret_bank0_PA_word),
        .ldu_cq_info_ret_byte_mask(ldu_cq_info_ret_bank0_byte_mask),
        .ldu_cq_info_ret_data(ldu_cq_info_ret_bank0_data),

        // misaligned queue info ret
        .ldu_mq_info_ret_valid(ldu_mq_info_ret_bank0_valid),
        .ldu_mq_info_ret_cq_index(ldu_mq_info_ret_bank0_cq_index),
        .ldu_mq_info_ret_mq_index(ldu_mq_info_ret_bank0_mq_index),
        .ldu_mq_info_ret_ROB_index(ldu_mq_info_ret_bank0_ROB_index),
        .ldu_mq_info_ret_WB_sent(ldu_mq_info_ret_bank0_WB_sent),
        .ldu_mq_info_ret_dtlb_hit(ldu_mq_info_ret_bank0_dtlb_hit),
        .ldu_mq_info_ret_page_fault(ldu_mq_info_ret_bank0_page_fault),
        .ldu_mq_info_ret_access_fault(ldu_mq_info_ret_bank0_access_fault),
        .ldu_mq_info_ret_dcache_hit(ldu_mq_info_ret_bank0_dcache_hit),
        .ldu_mq_info_ret_is_mem(ldu_mq_info_ret_bank0_is_mem),
        .ldu_mq_info_ret_aq_blocking(ldu_mq_info_ret_bank0_aq_blocking),
        .ldu_mq_info_ret_PA_word(ldu_mq_info_ret_bank0_PA_word),
        .ldu_mq_info_ret_byte_mask(ldu_mq_info_ret_bank0_byte_mask),
        .ldu_mq_info_ret_data(ldu_mq_info_ret_bank0_data),

        // misprediction notification to ROB
        .mispred_notif_valid(ldu_mispred_notif_bank0_valid),
        .mispred_notif_ROB_index(ldu_mispred_notif_bank0_ROB_index),

        // misprediction notification backpressure from ROB
        .mispred_notif_ready(ldu_mispred_notif_bank0_ready),

        // excpetion to ROB
        .rob_exception_valid(ldu_exception_valid),
        .rob_exception_VA(ldu_exception_VA),
        .rob_exception_page_fault(ldu_exception_page_fault),
        .rob_exception_access_fault(ldu_exception_access_fault),
        .rob_exception_ROB_index(ldu_exception_ROB_index),

        // exception backpressure from ROB
        .rob_exception_ready(ldu_exception_ready),

        // restart from ROB
        .rob_restart_valid(rob_restart_valid),
        .rob_restart_ASID(rob_restart_ASID),
        .rob_restart_exec_mode(rob_restart_exec_mode),
        .rob_restart_virtual_mode(rob_restart_virtual_mode),
        .rob_restart_MXR(rob_restart_MXR),
        .rob_restart_SUM(rob_restart_SUM)
    );

    // ldu_launch_pipeline bank 1
    ldu_launch_pipeline #(
        .INIT_ASID(INIT_ASID),
        .INIT_EXEC_MODE(INIT_EXEC_MODE),
        .INIT_VIRTUAL_MODE(INIT_VIRTUAL_MODE),
        .INIT_MXR(INIT_MXR),
        .INIT_SUM(INIT_SUM)
    ) LDU_LAUNCH_PIPELINE_BANK1 (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // first try
        .first_try_valid(ldu_launch_pipeline_first_try_bank1_valid),
        .first_try_is_mq(ldu_launch_pipeline_first_try_is_mq),
        .first_try_misaligned(ldu_launch_pipeline_first_try_misaligned),
        .first_try_VPN(ldu_launch_pipeline_first_try_VPN),
        .first_try_PO_word(ldu_launch_pipeline_first_try_PO_word),
        .first_try_byte_mask(ldu_launch_pipeline_first_try_byte_mask),
        .first_try_cq_index(ldu_launch_pipeline_first_try_cq_index),

        // first try feedback
        .first_try_early_ready(ldu_launch_pipeline_first_try_bank1_early_ready),

        // op enqueue to misaligned queue
        .ldu_mq_enq_valid(ldu_launch_pipeline_bank1_ldu_mq_enq_valid),

        // misaligned queue enqueue feedback
        .ldu_mq_enq_ready(ldu_launch_pipeline_bank1_ldu_mq_enq_ready),
        .ldu_mq_enq_index(ldu_mq_enq_index),

        // ROB info
        .rob_abs_head_index(rob_kill_abs_head_index),

        // acquire advertisement
        .stamofu_aq_mem_aq_active(stamofu_aq_mem_aq_active),
        .stamofu_aq_mem_aq_oldest_abs_ROB_index(stamofu_aq_mem_aq_oldest_abs_ROB_index),
        .stamofu_aq_io_aq_active(stamofu_aq_io_aq_active),
        .stamofu_aq_io_aq_oldest_abs_ROB_index(stamofu_aq_io_aq_oldest_abs_ROB_index),

        // second try
        .second_try_valid(ldu_launch_pipeline_second_try_bank1_valid),
        .second_try_do_mispred(ldu_launch_pipeline_second_try_do_mispred),
        .second_try_is_mq(ldu_launch_pipeline_second_try_is_mq),
        .second_try_misaligned(ldu_launch_pipeline_second_try_misaligned),
        .second_try_page_fault(ldu_launch_pipeline_second_try_page_fault),
        .second_try_access_fault(ldu_launch_pipeline_second_try_access_fault),
        .second_try_is_mem(ldu_launch_pipeline_second_try_is_mem),
        .second_try_PPN(ldu_launch_pipeline_second_try_PPN),
        .second_try_PO_word(ldu_launch_pipeline_second_try_PO_word),
        .second_try_byte_mask(ldu_launch_pipeline_second_try_byte_mask),
        .second_try_cq_index(ldu_launch_pipeline_second_try_cq_index),
        .second_try_mq_index(ldu_launch_pipeline_second_try_mq_index),

        // second try feedback
        .second_try_ack(ldu_launch_pipeline_second_try_bank1_ack),

        // data try
        .data_try_valid(ldu_launch_pipeline_data_try_bank1_valid),
        .data_try_do_mispred(ldu_launch_pipeline_data_try_do_mispred),
        .data_try_data(ldu_launch_pipeline_data_try_data),
        .data_try_cq_index(ldu_launch_pipeline_data_try_cq_index),

        // data try feedback
        .data_try_ack(ldu_launch_pipeline_data_try_bank1_ack),

        // dtlb req
        .dtlb_req_valid(dtlb_req_bank1_valid),
        .dtlb_req_exec_mode(dtlb_req_bank1_exec_mode),
        .dtlb_req_virtual_mode(dtlb_req_bank1_virtual_mode),
        .dtlb_req_ASID(dtlb_req_bank1_ASID),
        .dtlb_req_MXR(dtlb_req_bank1_MXR),
        .dtlb_req_SUM(dtlb_req_bank1_SUM),
        .dtlb_req_VPN(dtlb_req_bank1_VPN),

        // dtlb req feedback
        .dtlb_req_ready(dtlb_req_bank1_ready),

        // dtlb resp
        .dtlb_resp_hit(dtlb_resp_bank1_hit),
        .dtlb_resp_PPN(dtlb_resp_bank1_PPN),
        .dtlb_resp_is_mem(dtlb_resp_bank1_is_mem),
        .dtlb_resp_page_fault(dtlb_resp_bank1_page_fault),
        .dtlb_resp_access_fault(dtlb_resp_bank1_access_fault),

        // dcache req
        .dcache_req_valid(dcache_req_bank1_valid),
        .dcache_req_block_offset(dcache_req_bank1_block_offset),
        .dcache_req_index(dcache_req_bank1_index),
        .dcache_req_cq_index(dcache_req_bank1_cq_index),
        .dcache_req_is_mq(dcache_req_bank1_is_mq),
        .dcache_req_mq_index(dcache_req_bank1_mq_index),

        // dcache req feedback
        .dcache_req_ready(dcache_req_bank1_ready),

        // dcache resp
        .dcache_resp_valid_by_way(dcache_resp_bank1_valid_by_way),
        .dcache_resp_tag_by_way(dcache_resp_bank1_tag_by_way),
        .dcache_resp_data_by_way(dcache_resp_bank1_data_by_way),

        // dcache resp feedback
        .dcache_resp_hit_valid(dcache_resp_bank1_hit_valid),
        .dcache_resp_hit_way(dcache_resp_bank1_hit_way),
        .dcache_resp_miss_valid(dcache_resp_bank1_miss_valid),
        .dcache_resp_miss_tag(dcache_resp_bank1_miss_tag),

        // writeback data to PRF
        .WB_valid(ldu_bank1_WB_valid),
        .WB_data(ldu_bank1_WB_data),
        .WB_PR(ldu_bank1_WB_PR),
        .WB_ROB_index(ldu_bank1_WB_ROB_index),

        // writeback backpressure from PRF
        .WB_ready(ldu_bank1_WB_ready),

        // CAM launch
        .stamofu_CAM_launch_valid(stamofu_CAM_launch_bank1_valid),
        .stamofu_CAM_launch_cq_index(stamofu_CAM_launch_bank1_cq_index),
        .stamofu_CAM_launch_is_mq(stamofu_CAM_launch_bank1_is_mq),
        .stamofu_CAM_launch_mq_index(stamofu_CAM_launch_bank1_mq_index),
        .stamofu_CAM_launch_PA_word(stamofu_CAM_launch_bank1_PA_word),
        .stamofu_CAM_launch_byte_mask(stamofu_CAM_launch_bank1_byte_mask),
        .stamofu_CAM_launch_ROB_index(stamofu_CAM_launch_bank1_ROB_index),
        .stamofu_CAM_launch_mdp_info(stamofu_CAM_launch_bank1_mdp_info),

        // central queue info grab
        .ldu_cq_info_grab_cq_index(ldu_cq_info_grab_bank1_cq_index),
        .ldu_cq_info_grab_op(ldu_cq_info_grab_bank1_op),
        .ldu_cq_info_grab_mdp_info(ldu_cq_info_grab_bank1_mdp_info),
        .ldu_cq_info_grab_dest_PR(ldu_cq_info_grab_bank1_dest_PR),
        .ldu_cq_info_grab_ROB_index(ldu_cq_info_grab_bank1_ROB_index),

        // central queue info ret
        .ldu_cq_info_ret_valid(ldu_cq_info_ret_bank1_valid),
        .ldu_cq_info_ret_cq_index(ldu_cq_info_ret_bank1_WB_sent),
        .ldu_cq_info_ret_WB_sent(ldu_cq_info_ret_bank1_cq_index),
        .ldu_cq_info_ret_misaligned(ldu_cq_info_ret_bank1_misaligned),
        .ldu_cq_info_ret_dtlb_hit(ldu_cq_info_ret_bank1_dtlb_hit),
        .ldu_cq_info_ret_page_fault(ldu_cq_info_ret_bank1_page_fault),
        .ldu_cq_info_ret_access_fault(ldu_cq_info_ret_bank1_access_fault),
        .ldu_cq_info_ret_dcache_hit(ldu_cq_info_ret_bank1_dcache_hit),
        .ldu_cq_info_ret_is_mem(ldu_cq_info_ret_bank1_is_mem),
        .ldu_cq_info_ret_aq_blocking(ldu_cq_info_ret_bank1_aq_blocking),
        .ldu_cq_info_ret_PA_word(ldu_cq_info_ret_bank1_PA_word),
        .ldu_cq_info_ret_byte_mask(ldu_cq_info_ret_bank1_byte_mask),
        .ldu_cq_info_ret_data(ldu_cq_info_ret_bank1_data),

        // misaligned queue info ret
        .ldu_mq_info_ret_valid(ldu_mq_info_ret_bank1_valid),
        .ldu_mq_info_ret_cq_index(ldu_mq_info_ret_bank1_cq_index),
        .ldu_mq_info_ret_mq_index(ldu_mq_info_ret_bank1_mq_index),
        .ldu_mq_info_ret_ROB_index(ldu_mq_info_ret_bank1_ROB_index),
        .ldu_mq_info_ret_WB_sent(ldu_mq_info_ret_bank1_WB_sent),
        .ldu_mq_info_ret_dtlb_hit(ldu_mq_info_ret_bank1_dtlb_hit),
        .ldu_mq_info_ret_page_fault(ldu_mq_info_ret_bank1_page_fault),
        .ldu_mq_info_ret_access_fault(ldu_mq_info_ret_bank1_access_fault),
        .ldu_mq_info_ret_dcache_hit(ldu_mq_info_ret_bank1_dcache_hit),
        .ldu_mq_info_ret_is_mem(ldu_mq_info_ret_bank1_is_mem),
        .ldu_mq_info_ret_aq_blocking(ldu_mq_info_ret_bank1_aq_blocking),
        .ldu_mq_info_ret_PA_word(ldu_mq_info_ret_bank1_PA_word),
        .ldu_mq_info_ret_byte_mask(ldu_mq_info_ret_bank1_byte_mask),
        .ldu_mq_info_ret_data(ldu_mq_info_ret_bank1_data),

        // misprediction notification to ROB
        .mispred_notif_valid(ldu_mispred_notif_bank1_valid),
        .mispred_notif_ROB_index(ldu_mispred_notif_bank1_ROB_index),

        // misprediction notification backpressure from ROB
        .mispred_notif_ready(ldu_mispred_notif_bank1_ready),

        // excpetion to ROB
        .rob_exception_valid(ldu_exception_valid),
        .rob_exception_VA(ldu_exception_VA),
        .rob_exception_page_fault(ldu_exception_page_fault),
        .rob_exception_access_fault(ldu_exception_access_fault),
        .rob_exception_ROB_index(ldu_exception_ROB_index),

        // exception backpressure from ROB
        .rob_exception_ready(ldu_exception_ready),

        // restart from ROB
        .rob_restart_valid(rob_restart_valid),
        .rob_restart_ASID(rob_restart_ASID),
        .rob_restart_exec_mode(rob_restart_exec_mode),
        .rob_restart_virtual_mode(rob_restart_virtual_mode),
        .rob_restart_MXR(rob_restart_MXR),
        .rob_restart_SUM(rob_restart_SUM)
    );

    // ldu_cq
    ldu_cq #(
        .LDU_CQ_ENTRIES(LDU_CQ_ENTRIES)
    ) LDU_CQ (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // op enqueue to central queue
        .ldu_cq_enq_valid(ldu_cq_enq_valid),
        .ldu_cq_enq_killed(ldu_cq_enq_killed),
        .ldu_cq_enq_op(ldu_cq_enq_op),
        .ldu_cq_enq_mdp_info(ldu_cq_enq_mdp_info),
        .ldu_cq_enq_dest_PR(ldu_cq_enq_dest_PR),
        .ldu_cq_enq_ROB_index(ldu_cq_enq_ROB_index),
    
        // central queue enqueue feedback
        .ldu_cq_enq_ready(ldu_cq_enq_ready),
        .ldu_cq_enq_index(ldu_cq_enq_index),

        // second try
        .second_try_bank0_valid(ldu_launch_pipeline_second_try_bank0_valid),
        .second_try_bank1_valid(ldu_launch_pipeline_second_try_bank1_valid),

        .second_try_do_mispred(ldu_launch_pipeline_second_try_do_mispred),
        .second_try_is_mq(ldu_launch_pipeline_second_try_is_mq),
        .second_try_misaligned(ldu_launch_pipeline_second_try_misaligned),
        .second_try_page_fault(ldu_launch_pipeline_second_try_page_fault),
        .second_try_access_fault(ldu_launch_pipeline_second_try_access_fault),
        .second_try_is_mem(ldu_launch_pipeline_second_try_is_mem),
        .second_try_PPN(ldu_launch_pipeline_second_try_PPN),
        .second_try_PO_word(ldu_launch_pipeline_second_try_PO_word),
        .second_try_byte_mask(ldu_launch_pipeline_second_try_byte_mask),
        .second_try_cq_index(ldu_launch_pipeline_second_try_cq_index),
        .second_try_mq_index(ldu_launch_pipeline_second_try_mq_index),

        // second try feedback
        .second_try_bank0_ack(ldu_launch_pipeline_second_try_bank0_ack),
        .second_try_bank1_ack(ldu_launch_pipeline_second_try_bank1_ack)
    );
    
    // ldu_mq


    always_comb begin
        // static priority ldu launch pipeline bank 0 > bank 1
        ldu_mq_enq_valid = ldu_launch_pipeline_bank0_ldu_mq_enq_valid | ldu_launch_pipeline_bank1_ldu_mq_enq_valid;

        ldu_launch_pipeline_bank0_ldu_mq_enq_ready = ldu_mq_enq_ready;
        ldu_launch_pipeline_bank1_ldu_mq_enq_ready = ldu_mq_enq_ready & ~ldu_launch_pipeline_bank0_ldu_mq_enq_valid;

        // static priority ldu mispred notif bank 0 > bank 1
        ldu_mispred_notif_valid = ldu_mispred_notif_bank0_valid | ldu_mispred_notif_bank1_valid;

        ldu_mispred_notif_bank0_ready = ldu_mispred_notif_ready;
        ldu_mispred_notif_bank1_ready = ldu_mispred_notif_ready & ~ldu_mispred_notif_bank0_valid;
        
        if (ldu_mispred_notif_bank0_valid & ldu_mispred_notif_bank0_ready) begin
            ldu_mispred_notif_ROB_index = ldu_mispred_notif_bank0_ROB_index;
        end
        else begin
            ldu_mispred_notif_ROB_index = ldu_mispred_notif_bank1_ROB_index;
        end
    end

    // ----------------------------------------------------------------
    // stamofu:

    // stamofu_dq
    // stamofu_iq
    // stamofu_aq
    // stamofu_addr_pipeline
    // stamofu_lq bank 0
    // stamofu_lq bank 1
    // stamofu_launch_pipeline bank 0
    // stamofu_launch_pipeline bank 1
    // stamofu_cq
    // stamofu_mq

    // ssu

    always_comb begin
        // static priority ldu launch pipeline > stamofu launch pipeline
            // d$ can internally choose what dcache_req_ready looks like at core based on write buffer

        dtlb_req_bank0_valid = ldu_launch_pipeline_dtlb_req_bank0_valid | stamofu_launch_pipeline_dtlb_req_bank0_valid;
        if (ldu_launch_pipeline_dtlb_req_bank0_valid) begin
            dtlb_req_bank0_VPN = ldu_launch_pipeline_dtlb_req_bank0_VPN;
            dtlb_req_bank0_is_read = 1'b1;
            dtlb_req_bank0_is_write = 1'b0;
        end
        else begin
            dtlb_req_bank0_VPN = stamofu_launch_pipeline_dtlb_req_bank0_VPN;
            dtlb_req_bank0_is_read = stamofu_launch_pipeline_dtlb_req_bank0_is_read;
            dtlb_req_bank0_is_write = stamofu_launch_pipeline_dtlb_req_bank0_is_write;
        end

        dtlb_req_bank1_valid = ldu_launch_pipeline_dtlb_req_bank1_valid | stamofu_launch_pipeline_dtlb_req_bank1_valid;
        if (ldu_launch_pipeline_dtlb_req_bank1_valid) begin
            dtlb_req_bank1_VPN = ldu_launch_pipeline_dtlb_req_bank1_VPN;
            dtlb_req_bank1_is_read = 1'b1;
            dtlb_req_bank1_is_write = 1'b0;
        end
        else begin
            dtlb_req_bank1_VPN = stamofu_launch_pipeline_dtlb_req_bank1_VPN;
            dtlb_req_bank1_is_read = stamofu_launch_pipeline_dtlb_req_bank1_is_read;
            dtlb_req_bank1_is_write = stamofu_launch_pipeline_dtlb_req_bank1_is_write;
        end

        ldu_launch_pipeline_dtlb_req_bank0_ready = dtlb_req_bank0_ready;
        stamofu_launch_pipeline_dtlb_req_bank0_ready = dtlb_req_bank0_ready & ~ldu_launch_pipeline_dtlb_req_bank0_valid;

        ldu_launch_pipeline_dtlb_req_bank1_ready = dtlb_req_bank1_ready;
        stamofu_launch_pipeline_dtlb_req_bank1_ready = dtlb_req_bank1_ready & ~ldu_launch_pipeline_dtlb_req_bank1_valid;

        dcache_req_bank0_valid = ldu_launch_pipeline_dcache_req_bank0_valid | stamofu_launch_pipeline_dcache_req_bank0_valid;
        if (ldu_launch_pipeline_dcache_req_bank0_valid) begin
            dcache_req_bank0_block_offset = ldu_launch_pipeline_dcache_req_bank0_block_offset;
            dcache_req_bank0_index = ldu_launch_pipeline_dcache_req_bank0_index;
            dcache_req_bank0_is_ldu = 1'b1;
            dcache_req_bank0_cq_index = ldu_launch_pipeline_dcache_req_bank0_cq_index; // assuming LOG_LDU_CQ_ENTRIES >= LOG_STAMOFU_CQ_ENTRIES
            dcache_req_bank0_is_mq = ldu_launch_pipeline_dcache_req_bank0_is_mq;
            dcache_req_bank0_mq_index = ldu_launch_pipeline_dcache_req_bank0_mq_index; // assuming LOG_LDU_MQ_ENTRIES >= LOG_STAMOFU_MQ_ENTRIES
        end
        else begin
            dcache_req_bank0_block_offset = stamofu_launch_pipeline_dcache_req_bank0_block_offset;
            dcache_req_bank0_index = stamofu_launch_pipeline_dcache_req_bank0_index;
            dcache_req_bank0_is_ldu = 1'b0;
            dcache_req_bank0_cq_index = stamofu_launch_pipeline_dcache_req_bank0_cq_index; // assuming LOG_LDU_CQ_ENTRIES >= LOG_STAMOFU_CQ_ENTRIES
            dcache_req_bank0_is_mq = stamofu_launch_pipeline_dcache_req_bank0_is_mq;
            dcache_req_bank0_mq_index = stamofu_launch_pipeline_dcache_req_bank0_mq_index; // assuming LOG_LDU_MQ_ENTRIES >= LOG_STAMOFU_MQ_ENTRIES
        end

        dcache_req_bank1_valid = ldu_launch_pipeline_dcache_req_bank1_valid | stamofu_launch_pipeline_dcache_req_bank1_valid;
        if (ldu_launch_pipeline_dcache_req_bank1_valid) begin
            dcache_req_bank1_block_offset = ldu_launch_pipeline_dcache_req_bank1_block_offset;
            dcache_req_bank1_index = ldu_launch_pipeline_dcache_req_bank1_index;
            dcache_req_bank1_is_ldu = 1'b1;
            dcache_req_bank1_cq_index = ldu_launch_pipeline_dcache_req_bank1_cq_index; // assuming LOG_LDU_CQ_ENTRIES >= LOG_STAMOFU_CQ_ENTRIES
            dcache_req_bank1_is_mq = ldu_launch_pipeline_dcache_req_bank1_is_mq;
            dcache_req_bank1_mq_index = ldu_launch_pipeline_dcache_req_bank1_mq_index; // assuming LOG_LDU_MQ_ENTRIES >= LOG_STAMOFU_MQ_ENTRIES
        end
        else begin
            dcache_req_bank1_block_offset = stamofu_launch_pipeline_dcache_req_bank1_block_offset;
            dcache_req_bank1_index = stamofu_launch_pipeline_dcache_req_bank1_index;
            dcache_req_bank1_is_ldu = 1'b0;
            dcache_req_bank1_cq_index = stamofu_launch_pipeline_dcache_req_bank1_cq_index; // assuming LOG_LDU_CQ_ENTRIES >= LOG_STAMOFU_CQ_ENTRIES
            dcache_req_bank1_is_mq = stamofu_launch_pipeline_dcache_req_bank1_is_mq;
            dcache_req_bank1_mq_index = stamofu_launch_pipeline_dcache_req_bank1_mq_index; // assuming LOG_LDU_MQ_ENTRIES >= LOG_STAMOFU_MQ_ENTRIES
        end

        ldu_launch_pipeline_dcache_req_bank0_ready = dcache_req_bank0_ready;
        stamofu_launch_pipeline_dcache_req_bank0_ready = dcache_req_bank0_ready & ~ldu_launch_pipeline_dcache_req_bank0_valid;

        ldu_launch_pipeline_dcache_req_bank1_ready = dcache_req_bank1_ready;
        stamofu_launch_pipeline_dcache_req_bank1_ready = dcache_req_bank1_ready & ~ldu_launch_pipeline_dcache_req_bank1_valid;

        dcache_resp_bank0_hit_valid = ldu_launch_pipeline_dcache_resp_bank0_hit_valid | stamofu_launch_pipeline_dcache_resp_bank0_hit_valid;
        if (ldu_launch_pipeline_dcache_resp_bank0_hit_valid) begin
            dcache_resp_bank0_hit_exclusive = 1'b0;
            dcache_resp_bank0_hit_way = ldu_launch_pipeline_dcache_resp_bank0_hit_way;
        end
        else begin
            dcache_resp_bank0_hit_exclusive = stamofu_launch_pipeline_dcache_resp_bank0_hit_exclusive;
            dcache_resp_bank0_hit_way = stamofu_launch_pipeline_dcache_resp_bank0_hit_way;
        end

        dcache_resp_bank1_hit_valid = ldu_launch_pipeline_dcache_resp_bank1_hit_valid | stamofu_launch_pipeline_dcache_resp_bank1_hit_valid;
        if (ldu_launch_pipeline_dcache_resp_bank1_hit_valid) begin
            dcache_resp_bank1_hit_exclusive = 1'b0;
            dcache_resp_bank1_hit_way = ldu_launch_pipeline_dcache_resp_bank1_hit_way;
        end
        else begin
            dcache_resp_bank1_hit_exclusive = stamofu_launch_pipeline_dcache_resp_bank1_hit_exclusive;
            dcache_resp_bank1_hit_way = stamofu_launch_pipeline_dcache_resp_bank1_hit_way;
        end
        
        dcache_resp_bank0_miss_valid = ldu_launch_pipeline_dcache_resp_bank0_miss_valid | stamofu_launch_pipeline_dcache_resp_bank0_miss_valid;
        if (stamofu_launch_pipeline_dcache_resp_bank0_miss_valid) begin
            dcache_resp_bank0_miss_prefetch = 1'b0;
            dcache_resp_bank0_miss_exclusive = 1'b0;
            dcache_resp_bank0_miss_tag = ldu_launch_pipeline_dcache_resp_bank0_miss_tag;
        end
        else begin
            dcache_resp_bank0_miss_prefetch = stamofu_launch_pipeline_dcache_resp_bank0_miss_prefetch;
            dcache_resp_bank0_miss_exclusive = stamofu_launch_pipeline_dcache_resp_bank0_miss_exclusive;
            dcache_resp_bank0_miss_tag = stamofu_launch_pipeline_dcache_resp_bank0_miss_tag;
        end
        
        dcache_resp_bank1_miss_valid = ldu_launch_pipeline_dcache_resp_bank1_miss_valid | stamofu_launch_pipeline_dcache_resp_bank1_miss_valid;
        if (stamofu_launch_pipeline_dcache_resp_bank1_miss_valid) begin
            dcache_resp_bank1_miss_prefetch = 1'b0;
            dcache_resp_bank1_miss_exclusive = 1'b0;
            dcache_resp_bank1_miss_tag = ldu_launch_pipeline_dcache_resp_bank1_miss_tag;
        end
        else begin
            dcache_resp_bank1_miss_prefetch = stamofu_launch_pipeline_dcache_resp_bank1_miss_prefetch;
            dcache_resp_bank1_miss_exclusive = stamofu_launch_pipeline_dcache_resp_bank1_miss_exclusive;
            dcache_resp_bank1_miss_tag = stamofu_launch_pipeline_dcache_resp_bank1_miss_tag;
        end
    end

    // ----------------------------------------------------------------
    // sysu:
    
    // sysu_dq
    // sysu_pipeline
    // csrf


endmodule