/*
    Filename: decoder_tb.sv
    Author: zlagpacan
    Description: Testbench for decoder module. 
    Spec: LOROF/spec/design/decoder.md
*/

`timescale 1ns/100ps

`include "core_types_pkg.vh"
import core_types_pkg::*;

module decoder_tb ();

    // ----------------------------------------------------------------
    // TB setup:

    // parameters
    parameter PERIOD = 10;

    // TB signals:
    logic CLK = 1'b1, nRST;
    string test_case;
    string sub_test_case;
    int test_num = 0;
    int num_errors = 0;
    logic tb_error = 1'b0;

    // clock gen
    always begin #(PERIOD/2); CLK = ~CLK; end

    // ----------------------------------------------------------------
    // DUT signals:

    // environment info
    logic [1:0] tb_env_exec_mode;
    logic tb_env_trap_sfence;
    logic tb_env_trap_wfi;
    logic tb_env_trap_sret;

    // instr input
	logic tb_uncompressed;
	logic [31:0] tb_instr32;
	logic [BTB_PRED_INFO_WIDTH-1:0] tb_pred_info_chunk0;
	logic [BTB_PRED_INFO_WIDTH-1:0] tb_pred_info_chunk1;

    // FU select
	logic DUT_is_alu_reg, expected_is_alu_reg;
	logic DUT_is_alu_imm, expected_is_alu_imm;
	logic DUT_is_bru, expected_is_bru;
	logic DUT_is_mdu, expected_is_mdu;
	logic DUT_is_ldu, expected_is_ldu;
	logic DUT_is_store, expected_is_store;
	logic DUT_is_amo, expected_is_amo;
	logic DUT_is_fence, expected_is_fence;
	logic DUT_is_sysu, expected_is_sysu;
	logic DUT_is_illegal_instr, expected_is_illegal_instr;

    // op
	logic [3:0] DUT_op, expected_op;
	logic DUT_is_reg_write, expected_is_reg_write;

    // A operand
	logic [4:0] DUT_A_AR, expected_A_AR;
	logic DUT_A_unneeded, expected_A_unneeded;
	logic DUT_A_is_zero, expected_A_is_zero;
	logic DUT_A_is_ret_ra, expected_A_is_ret_ra;

    // B operand
	logic [4:0] DUT_B_AR, expected_B_AR;
	logic DUT_B_unneeded, expected_B_unneeded;
	logic DUT_B_is_zero, expected_B_is_zero;

    // dest operand
	logic [4:0] DUT_dest_AR, expected_dest_AR;
	logic DUT_dest_is_zero, expected_dest_is_zero;
	logic DUT_dest_is_link_ra, expected_dest_is_link_ra;

    // imm
	logic [19:0] DUT_imm20, expected_imm20;

    // pred info out
	logic [BTB_PRED_INFO_WIDTH-1:0] DUT_pred_info_out, expected_pred_info_out;
	logic DUT_missing_pred, expected_missing_pred;

    // ordering
    logic DUT_wait_for_restart, expected_wait_for_restart;
    logic DUT_mem_aq, expected_mem_aq;
    logic DUT_io_aq, expected_io_aq;
    logic DUT_mem_rl, expected_mem_rl;
    logic DUT_io_rl, expected_io_rl;

    // faults
	logic DUT_instr_yield, expected_instr_yield;
	logic DUT_non_branch_notif_chunk0, expected_non_branch_notif_chunk0;
	logic DUT_non_branch_notif_chunk1, expected_non_branch_notif_chunk1;
	logic DUT_restart_on_chunk0, expected_restart_on_chunk0;
	logic DUT_restart_after_chunk0, expected_restart_after_chunk0;
	logic DUT_restart_after_chunk1, expected_restart_after_chunk1;
	logic DUT_unrecoverable_fault, expected_unrecoverable_fault;

    // ----------------------------------------------------------------
    // DUT instantiation:

	decoder DUT (

    	// environment info
		.env_exec_mode(tb_env_exec_mode),
		.env_trap_sfence(tb_env_trap_sfence),
		.env_trap_wfi(tb_env_trap_wfi),
		.env_trap_sret(tb_env_trap_sret),

	    // instr info
		.uncompressed(tb_uncompressed),
		.instr32(tb_instr32),
		.pred_info_chunk0(tb_pred_info_chunk0),
		.pred_info_chunk1(tb_pred_info_chunk1),

	    // FU select
		.is_alu_reg(DUT_is_alu_reg),
		.is_alu_imm(DUT_is_alu_imm),
		.is_bru(DUT_is_bru),
		.is_mdu(DUT_is_mdu),
		.is_ldu(DUT_is_ldu),
		.is_store(DUT_is_store),
		.is_amo(DUT_is_amo),
		.is_fence(DUT_is_fence),
		.is_sysu(DUT_is_sysu),
		.is_illegal_instr(DUT_is_illegal_instr),

	    // op
		.op(DUT_op),
		.is_reg_write(DUT_is_reg_write),

	    // A operand
		.A_AR(DUT_A_AR),
		.A_unneeded(DUT_A_unneeded),
		.A_is_zero(DUT_A_is_zero),
		.A_is_ret_ra(DUT_A_is_ret_ra),

	    // B operand
		.B_AR(DUT_B_AR),
		.B_unneeded(DUT_B_unneeded),
		.B_is_zero(DUT_B_is_zero),

	    // dest operand
		.dest_AR(DUT_dest_AR),
		.dest_is_zero(DUT_dest_is_zero),
		.dest_is_link_ra(DUT_dest_is_link_ra),

	    // imm
		.imm20(DUT_imm20),

	    // pred info out
		.pred_info_out(DUT_pred_info_out),
		.missing_pred(DUT_missing_pred),

	    // ordering
		.wait_for_restart(DUT_wait_for_restart),
		.mem_aq(DUT_mem_aq),
		.io_aq(DUT_io_aq),
		.mem_rl(DUT_mem_rl),
		.io_rl(DUT_io_rl),

	    // faults
		.instr_yield(DUT_instr_yield),
		.non_branch_notif_chunk0(DUT_non_branch_notif_chunk0),
		.non_branch_notif_chunk1(DUT_non_branch_notif_chunk1),
		.restart_on_chunk0(DUT_restart_on_chunk0),
		.restart_after_chunk0(DUT_restart_after_chunk0),
		.restart_after_chunk1(DUT_restart_after_chunk1),
		.unrecoverable_fault(DUT_unrecoverable_fault)
	);

    // ----------------------------------------------------------------
    // tasks:

    task check_outputs();
    begin
		if (expected_is_alu_reg !== DUT_is_alu_reg) begin
			$display("TB ERROR: expected_is_alu_reg (%h) != DUT_is_alu_reg (%h)",
				expected_is_alu_reg, DUT_is_alu_reg);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_alu_imm !== DUT_is_alu_imm) begin
			$display("TB ERROR: expected_is_alu_imm (%h) != DUT_is_alu_imm (%h)",
				expected_is_alu_imm, DUT_is_alu_imm);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_bru !== DUT_is_bru) begin
			$display("TB ERROR: expected_is_bru (%h) != DUT_is_bru (%h)",
				expected_is_bru, DUT_is_bru);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_mdu !== DUT_is_mdu) begin
			$display("TB ERROR: expected_is_mdu (%h) != DUT_is_mdu (%h)",
				expected_is_mdu, DUT_is_mdu);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_ldu !== DUT_is_ldu) begin
			$display("TB ERROR: expected_is_ldu (%h) != DUT_is_ldu (%h)",
				expected_is_ldu, DUT_is_ldu);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_store !== DUT_is_store) begin
			$display("TB ERROR: expected_is_store (%h) != DUT_is_store (%h)",
				expected_is_store, DUT_is_store);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_amo !== DUT_is_amo) begin
			$display("TB ERROR: expected_is_amo (%h) != DUT_is_amo (%h)",
				expected_is_amo, DUT_is_amo);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_fence !== DUT_is_fence) begin
			$display("TB ERROR: expected_is_fence (%h) != DUT_is_fence (%h)",
				expected_is_fence, DUT_is_fence);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_sysu !== DUT_is_sysu) begin
			$display("TB ERROR: expected_is_sysu (%h) != DUT_is_sysu (%h)",
				expected_is_sysu, DUT_is_sysu);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_illegal_instr !== DUT_is_illegal_instr) begin
			$display("TB ERROR: expected_is_illegal_instr (%h) != DUT_is_illegal_instr (%h)",
				expected_is_illegal_instr, DUT_is_illegal_instr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_op !== DUT_op) begin
			$display("TB ERROR: expected_op (%h) != DUT_op (%h)",
				expected_op, DUT_op);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_is_reg_write !== DUT_is_reg_write) begin
			$display("TB ERROR: expected_is_reg_write (%h) != DUT_is_reg_write (%h)",
				expected_is_reg_write, DUT_is_reg_write);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_A_AR !== DUT_A_AR) begin
			$display("TB ERROR: expected_A_AR (%h) != DUT_A_AR (%h)",
				expected_A_AR, DUT_A_AR);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_A_unneeded !== DUT_A_unneeded) begin
			$display("TB ERROR: expected_A_unneeded (%h) != DUT_A_unneeded (%h)",
				expected_A_unneeded, DUT_A_unneeded);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_A_is_zero !== DUT_A_is_zero) begin
			$display("TB ERROR: expected_A_is_zero (%h) != DUT_A_is_zero (%h)",
				expected_A_is_zero, DUT_A_is_zero);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_A_is_ret_ra !== DUT_A_is_ret_ra) begin
			$display("TB ERROR: expected_A_is_ret_ra (%h) != DUT_A_is_ret_ra (%h)",
				expected_A_is_ret_ra, DUT_A_is_ret_ra);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_B_AR !== DUT_B_AR) begin
			$display("TB ERROR: expected_B_AR (%h) != DUT_B_AR (%h)",
				expected_B_AR, DUT_B_AR);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_B_unneeded !== DUT_B_unneeded) begin
			$display("TB ERROR: expected_B_unneeded (%h) != DUT_B_unneeded (%h)",
				expected_B_unneeded, DUT_B_unneeded);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_B_is_zero !== DUT_B_is_zero) begin
			$display("TB ERROR: expected_B_is_zero (%h) != DUT_B_is_zero (%h)",
				expected_B_is_zero, DUT_B_is_zero);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dest_AR !== DUT_dest_AR) begin
			$display("TB ERROR: expected_dest_AR (%h) != DUT_dest_AR (%h)",
				expected_dest_AR, DUT_dest_AR);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dest_is_zero !== DUT_dest_is_zero) begin
			$display("TB ERROR: expected_dest_is_zero (%h) != DUT_dest_is_zero (%h)",
				expected_dest_is_zero, DUT_dest_is_zero);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dest_is_link_ra !== DUT_dest_is_link_ra) begin
			$display("TB ERROR: expected_dest_is_link_ra (%h) != DUT_dest_is_link_ra (%h)",
				expected_dest_is_link_ra, DUT_dest_is_link_ra);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imm20 !== DUT_imm20) begin
			$display("TB ERROR: expected_imm20 (%h) != DUT_imm20 (%h)",
				expected_imm20, DUT_imm20);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_pred_info_out !== DUT_pred_info_out) begin
			$display("TB ERROR: expected_pred_info_out (%h) != DUT_pred_info_out (%h)",
				expected_pred_info_out, DUT_pred_info_out);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_missing_pred !== DUT_missing_pred) begin
			$display("TB ERROR: expected_missing_pred (%h) != DUT_missing_pred (%h)",
				expected_missing_pred, DUT_missing_pred);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_wait_for_restart !== DUT_wait_for_restart) begin
			$display("TB ERROR: expected_wait_for_restart (%h) != DUT_wait_for_restart (%h)",
				expected_wait_for_restart, DUT_wait_for_restart);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_mem_aq !== DUT_mem_aq) begin
			$display("TB ERROR: expected_mem_aq (%h) != DUT_mem_aq (%h)",
				expected_mem_aq, DUT_mem_aq);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_io_aq !== DUT_io_aq) begin
			$display("TB ERROR: expected_io_aq (%h) != DUT_io_aq (%h)",
				expected_io_aq, DUT_io_aq);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_mem_rl !== DUT_mem_rl) begin
			$display("TB ERROR: expected_mem_rl (%h) != DUT_mem_rl (%h)",
				expected_mem_rl, DUT_mem_rl);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_io_rl !== DUT_io_rl) begin
			$display("TB ERROR: expected_io_rl (%h) != DUT_io_rl (%h)",
				expected_io_rl, DUT_io_rl);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_instr_yield !== DUT_instr_yield) begin
			$display("TB ERROR: expected_instr_yield (%h) != DUT_instr_yield (%h)",
				expected_instr_yield, DUT_instr_yield);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_non_branch_notif_chunk0 !== DUT_non_branch_notif_chunk0) begin
			$display("TB ERROR: expected_non_branch_notif_chunk0 (%h) != DUT_non_branch_notif_chunk0 (%h)",
				expected_non_branch_notif_chunk0, DUT_non_branch_notif_chunk0);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_non_branch_notif_chunk1 !== DUT_non_branch_notif_chunk1) begin
			$display("TB ERROR: expected_non_branch_notif_chunk1 (%h) != DUT_non_branch_notif_chunk1 (%h)",
				expected_non_branch_notif_chunk1, DUT_non_branch_notif_chunk1);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restart_on_chunk0 !== DUT_restart_on_chunk0) begin
			$display("TB ERROR: expected_restart_on_chunk0 (%h) != DUT_restart_on_chunk0 (%h)",
				expected_restart_on_chunk0, DUT_restart_on_chunk0);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restart_after_chunk0 !== DUT_restart_after_chunk0) begin
			$display("TB ERROR: expected_restart_after_chunk0 (%h) != DUT_restart_after_chunk0 (%h)",
				expected_restart_after_chunk0, DUT_restart_after_chunk0);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restart_after_chunk1 !== DUT_restart_after_chunk1) begin
			$display("TB ERROR: expected_restart_after_chunk1 (%h) != DUT_restart_after_chunk1 (%h)",
				expected_restart_after_chunk1, DUT_restart_after_chunk1);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_unrecoverable_fault !== DUT_unrecoverable_fault) begin
			$display("TB ERROR: expected_unrecoverable_fault (%h) != DUT_unrecoverable_fault (%h)",
				expected_unrecoverable_fault, DUT_unrecoverable_fault);
			num_errors++;
			tb_error = 1'b1;
		end

        #(PERIOD / 10);
        tb_error = 1'b0;
    end
    endtask

    // ----------------------------------------------------------------
    // initial block:

    initial begin

        // ------------------------------------------------------------
        // reset:
        test_case = "reset";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

        // inputs:
        sub_test_case = "assert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b0;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = 32'h0;
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(posedge CLK); #(PERIOD/10);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'h0;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = 32'h0;
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(posedge CLK); #(PERIOD/10);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'h0;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

        // ------------------------------------------------------------
        // unCompressed cases:
        test_case = "unCompressed cases";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "all 1's";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = '1;
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1111;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h1F;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1F;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1F;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hFFFFF;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LUI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'h555AA, 5'h0, 5'b01101, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h15;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h15;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hAA555;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "Compressed AUIPC";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {20'h333CC, 5'h1, 5'b00101, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b0;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b1;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AUIPC";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'h333CC, 5'h1, 5'b00101, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h19;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h13;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'hcc333;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 JAL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'h12345, 5'h2, 5'b11011, 2'b11};
		tb_pred_info_chunk0 = 8'b10101010;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h8;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h3;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h45123;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b0;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b1;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "JAL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'h12345, 5'h2, 5'b11011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h8;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h3;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h45123;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 1 JALR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'hfed, 5'h3, 3'b000, 5'h4, 5'b11001, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'b01010101;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h18fed;
	    // pred info out
		expected_pred_info_out = 8'b01010101;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 1 bad funct3 JALR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {20'hfed, 5'h3, 3'b101, 5'h4, 5'b11001, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'b01010101;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h1dfed;
	    // pred info out
		expected_pred_info_out = 8'b01010101;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b1;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b1;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "BEQ";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1000001, 5'h6, 5'h5, 3'b000, 5'b10001, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h6;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h11;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b00101000100000110001;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 BNE";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0111110, 5'h8, 5'h7, 3'b001, 5'b01110, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'b11001100;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1001;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h7;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'he;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b00111001011111001110;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b0;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b1;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad branch";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1001001, 5'ha, 5'h9, 3'b010, 5'b10101, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h15;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4a935;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 1 BLT";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1001001, 5'ha, 5'h9, 3'b100, 5'b10101, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'b10000001;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1100;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h15;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01001100100100110101;
	    // pred info out
		expected_pred_info_out = 8'b10000001;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "BGE";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0110110, 5'hc, 5'hb, 3'b101, 5'b01010, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hb;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hc;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01011101011011001010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "BLTU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0110110, 5'he, 5'hd, 3'b110, 5'b01010, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01101110011011001010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "BGEU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0110110, 5'h0, 5'hf, 3'b111, 5'b01010, 5'b11000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1111;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b0;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01111111011011001010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'ha98, 5'h1, 3'b000, 5'h2, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h18;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h08a98;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 1 LB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'ha98, 5'h1, 3'b000, 5'h2, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'b01000000;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h18;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h08a98;
	    // pred info out
		expected_pred_info_out = 8'b01000000;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b1;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b1;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LH";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hfff, 5'h3, 3'b001, 5'h4, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1f;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h19fff;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 and 1 LH";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hfff, 5'h3, 3'b001, 5'h4, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'b11110000;
		tb_pred_info_chunk1 = 8'b10000100;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1f;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h19fff;
	    // pred info out
		expected_pred_info_out = 8'b10000100;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b0;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b1;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h5a5, 5'h5, 3'b010, 5'h6, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2a5a5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad load";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h5a5, 5'h5, 3'b011, 5'h6, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1011;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2b5a5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LBU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'ha5a, 5'h7, 3'b100, 5'h8, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h7;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1a;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h3ca5a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LHU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h345, 5'h9, 3'b101, 5'ha, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4d345;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad load 110";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h678, 5'h9, 3'b110, 5'ha, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h18;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4e678;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad load 111";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h9ab, 5'h9, 3'b111, 5'ha, 5'b00000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hb;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4f9ab;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0101010, 5'hc, 5'hb, 3'b000, 5'b10101, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b1;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hb;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hc;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h15;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01011000010101010101;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SH";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1010101, 5'he, 5'hd, 3'b001, 5'b01010, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b1;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01101001101010101010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1111000, 5'h0, 5'hf, 3'b010, 5'b11100, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b1;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1c;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'b01111010111100011100;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad store 011";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000111, 5'h0, 5'hf, 3'b011, 5'b00011, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7b0e3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad store 100";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000111, 5'h0, 5'hf, 3'b100, 5'b00011, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7c0e3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad store 101";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000111, 5'h0, 5'hf, 3'b101, 5'b00011, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7d0e3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad store 110";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000111, 5'h0, 5'hf, 3'b110, 5'b00011, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7e0e3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad store 111";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000111, 5'h0, 5'hf, 3'b111, 5'b00011, 5'b01000, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7f0e3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "ADDI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h210, 5'h1, 3'b000, 5'h2, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h10;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h08210;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLLI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'b10101, 5'h3, 3'b001, 5'h4, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h15;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h19015;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad SLLI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'b10101, 5'h3, 3'b001, 5'h4, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h15;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h19035;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLTI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h876, 5'h5, 3'b010, 5'h6, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h16;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2a876;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLTIU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hba9, 5'h7, 3'b011, 5'h8, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h7;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h3bba9;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "XORI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hedc, 5'h9, 3'b100, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1c;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4cedc;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRLI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h11, 5'h9, 3'b101, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4d011;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRAI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0100000, 5'h11, 5'h9, 3'b101, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4d411;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad SRLI/SRAI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'h11, 5'h9, 3'b101, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4d111;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "ORI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hfff, 5'h9, 3'b110, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1f;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4efff;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "ANDI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'haaa, 5'h9, 3'b111, 5'ha, 5'b00100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4faaa;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "ADD";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h4, 5'h2, 3'b000, 5'h6, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h4;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h10004;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SUB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0100000, 5'ha, 5'h8, 3'b000, 5'hc, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h8;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hc;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4040a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad ADD/SUB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1111111, 5'h3, 5'h1, 3'b000, 5'h5, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h3;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h08fe3;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h9, 5'h7, 3'b001, 5'hb, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h7;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hb;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h39009;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLT";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'hf, 5'hd, 3'b010, 5'h1, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h6a00f;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SLTU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'hf, 5'hd, 3'b011, 5'h1, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h6b00f;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "XOR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h4, 5'h0, 3'b100, 5'h8, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h4;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h04004;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h5, 5'h1, 3'b101, 5'h9, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h9;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0d005;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRA";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0100000, 5'h6, 5'h2, 3'b101, 5'ha, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h6;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h15406;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "OR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h7, 5'h3, 3'b110, 5'hb, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h7;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hb;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h1e007;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AND";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'h8, 5'h4, 3'b111, 5'hc, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h4;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hc;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h27008;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0000,1111";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0000, 4'b1111, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h5000f;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE.TSO 0001,1110";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b1000, 4'b0001, 4'b1110, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1e;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h5081e;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad FENCE/FENCE.TSO 0010,1101";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0100, 4'b0010, 4'b1101, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h5042d;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 1001,0110";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b1001, 4'b0110, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h16;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50096;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0110,1001";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0110, 4'b1001, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50069;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0010,0100";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0010, 4'b0100, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h4;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50024;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 1000,0001";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b1000, 4'b0001, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50081;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE.TSO 0100,1000";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b1000, 4'b0100, 4'b1000, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50848;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE.TSO 0001,0010";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b1000, 4'b0001, 4'b0010, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h12;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50812;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0001,0000";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0001, 4'b0000, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h10;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0100,0101";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0100, 4'b0101, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50045;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 0000,1000";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b0000, 4'b1000, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h50008;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE 1010,1010";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {4'b0000, 4'b1010, 4'b1010, 5'ha, 3'b000, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h500aa;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "FENCE.I";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h5a5, 5'ha, 3'b001, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1001;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h515a5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad fence 1010,0101";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h5a5, 5'ha, 3'b110, 5'h5, 5'b00011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h5;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h565a5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "ECALL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'b00000, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00000;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "EBREAK";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'b00001, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00001;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad ECALL/EBREAK";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000000, 5'b01000, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00008;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRET U-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00102;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRET S-mode, TSR = 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00102;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRET S-mode, TSR = 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00102;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SRET M-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00102;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "WFI U-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00101, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00105;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "WFI S-mode, TW = 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00101, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00105;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "WFI S-mode, TW = 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00101, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00105;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "WFI M-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00101, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00105;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad SRET/WFI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001000, 5'b00000, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00100;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SFENCE.VMA U-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001001, 5'ha, 5'h5, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2812a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SFENCE.VMA S-mode TVM = 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001001, 5'ha, 5'h5, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2812a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SFENCE.VMA S-mode TVM = 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001001, 5'ha, 5'h5, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2812a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SFENCE.VMA M-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0001001, 5'ha, 5'h5, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b1;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2812a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MRET U-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0011000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00302;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MRET S-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0011000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00302;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MRET M-mode";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b1;
		tb_env_trap_wfi = 1'b1;
		tb_env_trap_sret = 1'b1;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0011000, 5'b00010, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00302;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad MRET";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0011000, 5'b11101, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1d;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0031d;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad sysu 000";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b1000001, 5'b10001, 5'h0, 3'b000, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00831;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h246, 5'h1, 3'b001, 5'h3, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h6;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h09246;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRS";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h8ac, 5'h5, 3'b010, 5'h7, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h5;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'hc;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h7;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h2a8ac;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRC";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'he02, 5'h9, 3'b011, 5'hb, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hb;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h4be02;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad CSRRW/S/C/WI/SI/CI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'h468, 5'hd, 3'b100, 5'hf, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b1100;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hf;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h6c468;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRWI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hace, 5'h2, 3'b101, 5'h0, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h15ace;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRSI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hfed, 5'h3, 3'b110, 5'h1, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h1efed;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "CSRRCI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {12'hcba, 5'h4, 3'b111, 5'h2, 5'b11100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h4;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h1a;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h27cba;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MUL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'hf, 5'he, 3'b000, 5'h0, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'he;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h7002f;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MULH";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'h2, 5'h1, 3'b001, 5'h3, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h2;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h09022;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MULHSU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'h5, 5'h4, 3'b010, 5'h6, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h4;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h22025;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "MULHU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'h8, 5'h7, 3'b011, 5'h9, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h7;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h8;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h9;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h3b028;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "DIV";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'hb, 5'ha, 3'b100, 5'hc, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hb;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hc;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h5402b;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "DIVU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'he, 5'hd, 3'b101, 5'hf, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hf;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h6d02e;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "REM";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'h0, 5'h0, 3'b110, 5'h0, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h06020;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "REMU";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {7'b0000001, 5'h3, 5'h3, 3'b111, 5'h3, 5'b01100, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b1;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h3;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h3;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h1f023;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "LR.W";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00010, 1'b0, 1'b0, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a100;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad AMO funct5 rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b11111, 1'b0, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7afa0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad AMO funct3 aq";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00010, 1'b1, 1'b0, 5'h0, 5'hf, 3'b101, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7d140;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "SC.W rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00011, 1'b0, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a1a0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOSWAP.W aq rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00001, 1'b1, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a0e0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOADD.W";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00000, 1'b0, 1'b0, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a000;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOXOR.W aq";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b00100, 1'b1, 1'b0, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a240;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOAND.W rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b01100, 1'b0, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a620;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOOR.W aq rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b01000, 1'b1, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a460;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOMIN.W";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b10000, 1'b0, 1'b0, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7a800;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOMAX.W rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b11;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b10100, 1'b0, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7aa20;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOMINU.W aq rl";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b11000, 1'b1, 1'b1, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7ac60;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b1;
		expected_io_rl = 1'b1;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "AMOMAXU.W aq";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b01;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {5'b11100, 1'b1, 1'b0, 5'h0, 5'hf, 3'b010, 5'h1, 5'b01011, 2'b11};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b1;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h7ae40;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b1;
		expected_io_aq = 1'b1;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

        // ------------------------------------------------------------
        // Compressed cases:
        test_case = "Compressed cases";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.ADDI4SPN";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'habcd, 3'b000, 8'b10011001, 3'b001, 2'b00};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h9;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h001a8;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.ADDI4SPN";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b000, 8'b01000101, 3'b110, 2'b00};
		tb_pred_info_chunk0 = 8'b10000000;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'he;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00058;
	    // pred info out
		expected_pred_info_out = 8'h80;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b1;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad C 00";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b001, 8'b01000101, 3'b110, 2'b00};
		tb_pred_info_chunk0 = 8'b10000000;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h11;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'he;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0000e;
	    // pred info out
		expected_pred_info_out = 8'h80;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b1;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.LW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'hf0f0, 3'b010, 3'b110, 3'b101, 2'b01, 3'b010, 2'b00};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hd;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00070;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "unC C.LW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b1;
		tb_instr32 = {16'h5a5a, 3'b010, 3'b010, 3'b101, 2'b10, 3'b010, 2'b00};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h14;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h15;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'ha45a5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b0;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b1;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SW";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b110, 3'b010, 3'b100, 2'b10, 3'b111, 2'b00};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b1;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hc;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hf;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00014;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.NOP";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b000, 1'b0, 5'h0, 5'b00000, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00000;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.ADDI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b000, 1'b1, 5'h13, 5'b01101, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h13;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h13;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffed;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.JAL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b001, 11'b10100110010, 2'b01};
		tb_pred_info_chunk0 = 8'b00111111;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h12;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'hffac3;
	    // pred info out
		expected_pred_info_out = 8'h3f;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.JAL";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b001, 11'b01110111000, 2'b01};
		tb_pred_info_chunk0 = 8'b10010010;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1d;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h18;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'h003d8;
	    // pred info out
		expected_pred_info_out = 8'h92;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.LI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b010, 1'b1, 5'h1e, 5'b10111, 2'b01};
		tb_pred_info_chunk0 = 8'b10010010;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h17;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1e;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hffff7;
	    // pred info out
		expected_pred_info_out = 8'h92;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b1;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b1;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.ADDI16SP";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b011, 1'b0, 5'b00010, 5'b11001, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h19;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00070;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "another C.ADDI16SP";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b011, 1'b1, 5'b00010, 5'b01111, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hf;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h2;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffe0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.LUI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b011, 1'b1, 5'h19, 5'b00011, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h19;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h3;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h19;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'he3fff;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SRLI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 2'b00, 3'b000, 5'b01010, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h8;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0002a;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SRAI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 2'b01, 3'b011, 5'b10101, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1101;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hb;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hb;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00015;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.ANDI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 2'b10, 3'b100, 5'b01001, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hc;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hc;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffe9;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SUB";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 2'b11, 3'b010, 2'b00, 3'b001, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00001;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.XOR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 2'b11, 3'b110, 2'b01, 3'b101, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'he;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hd;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'he;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0000d;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.OR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 2'b11, 3'b001, 2'b10, 3'b010, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h9;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'ha;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h9;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00012;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.AND";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 2'b11, 3'b011, 2'b11, 3'b011, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0111;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'hb;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'hb;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'hb;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0001b;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.J";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b101, 11'b01110101110, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'b10101010;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h1d;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1d;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h0035e;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.J";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b101, 11'b10010010001, 2'b01};
		tb_pred_info_chunk0 = 8'b10101010;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0100;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h4;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hff9a1;
	    // pred info out
		expected_pred_info_out = 8'haa;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.BEQZ";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b110, 3'b100, 3'b011, 5'b10101, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hb;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h15;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h3;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffa5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.BEQZ";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b110, 3'b001, 3'b000, 5'b11000, 2'b01};
		tb_pred_info_chunk0 = 8'b01101001;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h8;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h18;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h8;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h000c8;
	    // pred info out
		expected_pred_info_out = 8'h69;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.BNEZ";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b111, 3'b011, 3'b111, 5'b01110, 2'b01};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1011;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'hf;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'he;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h1f;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h5e;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.BNEZ";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b111, 3'b110, 3'b110, 5'b00111, 2'b01};
		tb_pred_info_chunk0 = 8'b11111111;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b1011;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'he;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h7;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h16;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfff37;
	    // pred info out
		expected_pred_info_out = 8'hff;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SLLI";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b000, 1'b0, 5'h12, 5'b10001, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b1;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h12;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h12;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00011;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "bad C 10";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b001, 1'b0, 5'h12, 5'b10001, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h12;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h11;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h12;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00011;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.LWSP";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b010, 1'b1, 5'h4, 5'b01001, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b1;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0010;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h9;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h4;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00068;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.JR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 5'h6, 5'h0, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h6;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00000;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.JR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 5'h1f, 5'h0, 2'b10};
		tb_pred_info_chunk0 = 8'b10000000;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0101;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h1f;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1f;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00000;
	    // pred info out
		expected_pred_info_out = 8'h80;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.MV";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b0, 5'h7, 5'h10, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h10;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h7;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00010;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.EBREAK";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 5'h0, 5'h0, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b1;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h0;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b1;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h0;
		expected_dest_is_zero = 1'b1;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h00001;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b1;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.JALR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 5'h1a, 5'h0, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1a;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'hfffe0;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b1;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "pred chunk 0 C.JALR";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 5'h1, 5'h0, 2'b10};
		tb_pred_info_chunk0 = 8'b11100000;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b1;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0001;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'h1;
		expected_A_unneeded = 1'b0;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b1;
	    // B operand
		expected_B_AR = 5'h0;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b1;
	    // dest operand
		expected_dest_AR = 5'h1;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b1;
	    // imm
		expected_imm20 = 20'hfffe0;
	    // pred info out
		expected_pred_info_out = 8'he0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.ADD";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b100, 1'b1, 5'ha, 5'h5, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b1;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0000;
		expected_is_reg_write = 1'b1;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffe5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "another bad C 10";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b101, 1'b1, 5'ha, 5'h5, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b0;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b1;
	    // op
		expected_op = 4'b0011;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'ha;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h5;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'ha;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'hfffe5;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "C.SWSP";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		// environment info
		tb_env_exec_mode = 2'b00;
		tb_env_trap_sfence = 1'b0;
		tb_env_trap_wfi = 1'b0;
		tb_env_trap_sret = 1'b0;
	    // instr info
		tb_uncompressed = 1'b0;
		tb_instr32 = {16'h0123, 3'b110, 6'h26, 5'h17, 2'b10};
		tb_pred_info_chunk0 = 8'h0;
		tb_pred_info_chunk1 = 8'h0;
	    // FU select
	    // op
	    // A operand
	    // B operand
	    // dest operand
	    // imm
	    // pred info out
	    // ordering
	    // faults

		@(negedge CLK);

		// outputs:

	    // instr info
	    // FU select
		expected_is_alu_reg = 1'b0;
		expected_is_alu_imm = 1'b0;
		expected_is_bru = 1'b0;
		expected_is_mdu = 1'b0;
		expected_is_ldu = 1'b0;
		expected_is_store = 1'b1;
		expected_is_amo = 1'b0;
		expected_is_fence = 1'b0;
		expected_is_sysu = 1'b0;
		expected_is_illegal_instr = 1'b0;
	    // op
		expected_op = 4'b0110;
		expected_is_reg_write = 1'b0;
	    // A operand
		expected_A_AR = 5'h2;
		expected_A_unneeded = 1'b1;
		expected_A_is_zero = 1'b0;
		expected_A_is_ret_ra = 1'b0;
	    // B operand
		expected_B_AR = 5'h17;
		expected_B_unneeded = 1'b1;
		expected_B_is_zero = 1'b0;
	    // dest operand
		expected_dest_AR = 5'h6;
		expected_dest_is_zero = 1'b0;
		expected_dest_is_link_ra = 1'b0;
	    // imm
		expected_imm20 = 20'h000a4;
	    // pred info out
		expected_pred_info_out = 8'h0;
		expected_missing_pred = 1'b0;
	    // ordering
		expected_wait_for_restart = 1'b0;
		expected_mem_aq = 1'b0;
		expected_io_aq = 1'b0;
		expected_mem_rl = 1'b0;
		expected_io_rl = 1'b0;
	    // faults
		expected_instr_yield = 1'b1;
		expected_non_branch_notif_chunk0 = 1'b0;
		expected_non_branch_notif_chunk1 = 1'b0;
		expected_restart_on_chunk0 = 1'b0;
		expected_restart_after_chunk0 = 1'b0;
		expected_restart_after_chunk1 = 1'b0;
		expected_unrecoverable_fault = 1'b0;

		check_outputs();

        // ------------------------------------------------------------
        // finish:
        @(posedge CLK); #(PERIOD/10);
        
        test_case = "finish";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK); #(PERIOD/10);

        $display();
        if (num_errors) begin
            $display("FAIL: %d tests fail", num_errors);
        end
        else begin
            $display("SUCCESS: all tests pass");
        end
        $display();

        $finish();
    end

endmodule