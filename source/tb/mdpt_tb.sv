/*
    Filename: mdpt_tb.sv
    Author: zlagpacan
    Description: Testbench for mdpt module. 
    Spec: LOROF/spec/design/mdpt.md
*/

`timescale 1ns/100ps

`include "core_types_pkg.vh"
import core_types_pkg::*;

module mdpt_tb ();

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


    // REQ stage
	logic tb_valid_REQ;
	logic [31:0] tb_full_PC_REQ;
	logic [ASID_WIDTH-1:0] tb_ASID_REQ;

    // RESP stage
	logic [MDPT_ENTRIES_PER_BLOCK-1:0][MDPT_INFO_WIDTH-1:0] DUT_mdp_info_by_instr_RESP, expected_mdp_info_by_instr_RESP;

    // MDPT Update 0 stage
	logic tb_mdpt_update0_valid;
	logic [31:0] tb_mdpt_update0_start_full_PC;
	logic [ASID_WIDTH-1:0] tb_mdpt_update0_ASID;
	logic [MDPT_INFO_WIDTH-1:0] tb_mdpt_update0_mdp_info;

    // ----------------------------------------------------------------
    // DUT instantiation:

	mdpt DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // REQ stage
		.valid_REQ(tb_valid_REQ),
		.full_PC_REQ(tb_full_PC_REQ),
		.ASID_REQ(tb_ASID_REQ),

	    // RESP stage
		.mdp_info_by_instr_RESP(DUT_mdp_info_by_instr_RESP),

	    // MDPT Update 0 stage
		.mdpt_update0_valid(tb_mdpt_update0_valid),
		.mdpt_update0_start_full_PC(tb_mdpt_update0_start_full_PC),
		.mdpt_update0_ASID(tb_mdpt_update0_ASID),
		.mdpt_update0_mdp_info(tb_mdpt_update0_mdp_info)
	);

    // ----------------------------------------------------------------
    // tasks:

    task check_outputs();
    begin
		if (expected_mdp_info_by_instr_RESP !== DUT_mdp_info_by_instr_RESP) begin
			$display("TB ERROR: expected_mdp_info_by_instr_RESP (%h) != DUT_mdp_info_by_instr_RESP (%h)",
				expected_mdp_info_by_instr_RESP, DUT_mdp_info_by_instr_RESP);
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
	    // REQ stage
		tb_valid_REQ = 1'b0;
		tb_full_PC_REQ = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
		tb_ASID_REQ = 9'h0;
	    // RESP stage
	    // MDPT Update 0 stage
		tb_mdpt_update0_valid = 1'b0;
		tb_mdpt_update0_start_full_PC = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
		tb_mdpt_update0_ASID = 9'h0;
		tb_mdpt_update0_mdp_info = 8'h0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

	    // REQ stage
	    // RESP stage
		expected_mdp_info_by_instr_RESP = {
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0
        };
	    // MDPT Update 0 stage

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // REQ stage
		tb_valid_REQ = 1'b0;
		tb_full_PC_REQ = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
		tb_ASID_REQ = 9'h0;
	    // RESP stage
	    // MDPT Update 0 stage
		tb_mdpt_update0_valid = 1'b0;
		tb_mdpt_update0_start_full_PC = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
		tb_mdpt_update0_ASID = 9'h0;
		tb_mdpt_update0_mdp_info = 8'h0;

		@(posedge CLK); #(PERIOD/10);

		// outputs:

	    // REQ stage
	    // RESP stage
		expected_mdp_info_by_instr_RESP = {
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0
        };
	    // MDPT Update 0 stage

		check_outputs();

        // ------------------------------------------------------------
        // update chain:
        test_case = "update chain";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

        for (int i = 0; i < MDPT_ENTRIES; i++) begin

            @(posedge CLK); #(PERIOD/10);

            // inputs
            sub_test_case = $sformatf("update 0x%3h", i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // REQ stage
            tb_valid_REQ = 1'b0;
            tb_full_PC_REQ = {
                19'h0,
                9'h0,
                3'h0,
                1'b0
            };
            tb_ASID_REQ = 9'h0;
            // RESP stage
            // MDPT Update 0 stage
            tb_mdpt_update0_valid = 1'b1;
            tb_mdpt_update0_start_full_PC = {
                19'h0,
                ~i[11:3],
                i[2:0],
                1'b0
            };
            tb_mdpt_update0_ASID = 9'b111111111;
            tb_mdpt_update0_mdp_info = i[7:0];

            @(negedge CLK);

            // outputs:

            // REQ stage
            // RESP stage
            expected_mdp_info_by_instr_RESP = {
                8'h0,
                8'h0,
                8'h0,
                8'h0,
                8'h0,
                8'h0,
                8'h0,
                8'h0
            };
            // MDPT Update 0 stage

            check_outputs();
        end

        // ------------------------------------------------------------
        // read chain:
        test_case = "read chain";
        $display("\ntest %0d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK); #(PERIOD/10);

        // inputs
        sub_test_case = $sformatf("REQ: 0x000, RESP: NOP");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // REQ stage
        tb_valid_REQ = 1'b1;
        tb_full_PC_REQ = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
        tb_ASID_REQ = 9'h0;
        // RESP stage
        // MDPT Update 0 stage
        tb_mdpt_update0_valid = 1'b0;
        tb_mdpt_update0_start_full_PC = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
        tb_mdpt_update0_ASID = 9'h0;
        tb_mdpt_update0_mdp_info = 8'h0;

        @(negedge CLK);

        // outputs:

        // REQ stage
        // RESP stage
		expected_mdp_info_by_instr_RESP = {
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0,
            8'h0
        };
        // MDPT Update 0 stage

        check_outputs();

        for (int i = 8; i < MDPT_ENTRIES; i+=8) begin

            @(posedge CLK); #(PERIOD/10);

            // inputs
            sub_test_case = $sformatf("REQ: 0x%3h, RESP: 0x%3h", i, i-8);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // REQ stage
            tb_valid_REQ = 1'b1;
            tb_full_PC_REQ = {
                19'h0,
                9'h0,
                i[2:0],
                1'b0
            };
            tb_ASID_REQ = i[11:3];
            // RESP stage
            // MDPT Update 0 stage
            tb_mdpt_update0_valid = 1'b0;
            tb_mdpt_update0_start_full_PC = {
                19'h0,
                9'h0,
                3'h0,
                1'b0
            };
            tb_mdpt_update0_ASID = 9'h0;
            tb_mdpt_update0_mdp_info = 8'h0;

            @(negedge CLK);

            // outputs:

            // REQ stage
            // RESP stage
            expected_mdp_info_by_instr_RESP = {
                {i - 8 + 7}[7:0],
                {i - 8 + 6}[7:0],
                {i - 8 + 5}[7:0],
                {i - 8 + 4}[7:0],
                {i - 8 + 3}[7:0],
                {i - 8 + 2}[7:0],
                {i - 8 + 1}[7:0],
                {i - 8 + 0}[7:0]
            };
            // MDPT Update 0 stage

            check_outputs();
        end

        @(posedge CLK); #(PERIOD/10);

        // inputs
        sub_test_case = $sformatf("REQ: NOP, RESP: 0xff8");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // REQ stage
        tb_valid_REQ = 1'b1;
        tb_full_PC_REQ = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
        tb_ASID_REQ = 9'h0;
        // RESP stage
        // MDPT Update 0 stage
        tb_mdpt_update0_valid = 1'b0;
        tb_mdpt_update0_start_full_PC = {
            19'h0,
            9'h0,
            3'h0,
            1'b0
        };
        tb_mdpt_update0_ASID = 9'h0;
        tb_mdpt_update0_mdp_info = 8'h0;

        @(negedge CLK);

        // outputs:

        // REQ stage
        // RESP stage
        expected_mdp_info_by_instr_RESP = {
            8'hff,
            8'hfe,
            8'hfd,
            8'hfc,
            8'hfb,
            8'hfa,
            8'hf9,
            8'hf8
        };
        // MDPT Update 0 stage

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