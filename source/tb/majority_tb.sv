/*
    Filename: majority_tb.sv
    Author: zlagpacan
    Description: Testbench for majority module. 
    Spec: LOROF/spec/design/majority.md
*/

`timescale 1ns/100ps

`include "core_types_pkg.vh"
import core_types_pkg::*;

module majority_tb ();

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

    parameter WIDTH = 8;
    parameter THRESHOLD = 4;

	logic [WIDTH-1:0] tb_vec;
	logic DUT_above_threshold, expected_above_threshold;

    // ----------------------------------------------------------------
    // DUT instantiation:

	majority #(
        .WIDTH(WIDTH),
        .THRESHOLD(THRESHOLD)
	) DUT (
		.vec(tb_vec),
		.above_threshold(DUT_above_threshold)
	);

    // ----------------------------------------------------------------
    // tasks:

    task check_outputs();
    begin
		if (expected_above_threshold !== DUT_above_threshold) begin
			$display("TB ERROR: expected_above_threshold (%h) != DUT_above_threshold (%h)",
				expected_above_threshold, DUT_above_threshold);
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
		tb_vec = '0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

		expected_above_threshold = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
		tb_vec = '0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

		expected_above_threshold = 1'b0;

		check_outputs();

        // ------------------------------------------------------------
        // fully enumerate:
        test_case = "fully enumerate";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

        for (int i = 0; i < 2**WIDTH; i++) begin

            @(posedge CLK); #(PERIOD/10);

            // inputs
            sub_test_case = $sformatf("vec = %h", i[WIDTH-1:0]);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            tb_vec = i[WIDTH-1:0];

            @(negedge CLK);

            // outputs:

            expected_above_threshold = $countones(i[WIDTH-1:0]) >= THRESHOLD;

    		check_outputs();
        end

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