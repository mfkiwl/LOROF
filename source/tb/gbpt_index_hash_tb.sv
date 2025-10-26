/*
    Filename: gbpt_index_hash_tb.sv
    Author: zlagpacan
    Description: Testbench for gbpt_index_hash module. 
    Spec: LOROF/spec/design/gbpt_index_hash.md
*/

`timescale 1ns/100ps

`include "core_types_pkg.vh"
import core_types_pkg::*;

module gbpt_index_hash_tb ();

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
	logic [31:0] tb_PC;
	logic [GH_LENGTH-1:0] tb_GH;
	logic [ASID_WIDTH-1:0] tb_ASID;
	logic [GBPT_INDEX_WIDTH-1:0] DUT_index, expected_index;

    // ----------------------------------------------------------------
    // DUT instantiation:

	gbpt_index_hash DUT (
		.PC(tb_PC),
		.GH(tb_GH),
		.ASID(tb_ASID),
		.index(DUT_index)
	);

    // ----------------------------------------------------------------
    // tasks:

    task check_outputs();
    begin
		if (expected_index !== DUT_index) begin
			$display("TB ERROR: expected_index (%h) != DUT_index (%h)",
				expected_index, DUT_index);
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
		tb_PC = 32'h0;
		tb_GH = 12'h0;
		tb_ASID = 9'h0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

		expected_index = 12'h0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = 32'h0;
		tb_GH = 12'h0;
		tb_ASID = 9'h0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

		expected_index = 12'h0;

		check_outputs();

        // ------------------------------------------------------------
        // simple chain:
        test_case = "simple chain";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "0 ^ 0 ^ 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b000000000000, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b000000000000;
		tb_ASID = 9'b000000000;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b000000000000;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "0 ^ 0 ^ 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b111111111111, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b000000000000;
		tb_ASID = 9'b000000000;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b111111111111;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "0 ^ 1 ^ 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b000000000000, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b111111111111;
		tb_ASID = 9'b000000000;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b111111111111;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "0 ^ 1 ^ 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b111111111111, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b111111111111;
		tb_ASID = 9'b000000000;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b000000000000;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "1 ^ 0 ^ 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b000000000000, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b000000000000;
		tb_ASID = 9'b111111111;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b000111111111;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "1 ^ 0 ^ 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b111111111111, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b000000000000;
		tb_ASID = 9'b111111111;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b111000000000;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "1 ^ 1 ^ 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b000000000000, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b111111111111;
		tb_ASID = 9'b111111111;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b111000000000;

		check_outputs();

		@(posedge CLK); #(PERIOD/10);

		// inputs
		sub_test_case = "1 ^ 1 ^ 1";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_PC = {
            19'h0, // untouched bits
            12'b111111111111, // index bits
            1'b0 // 2B offset
        };
		tb_GH = 12'b111111111111;
		tb_ASID = 9'b111111111;

		@(negedge CLK);

		// outputs:

		expected_index = 12'b000111111111;

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