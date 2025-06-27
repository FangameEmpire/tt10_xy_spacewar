// Testbench  designed for Quartus and ModelSim
`timescale 1ns/10ps
`default_nettype none
module on_line_detector_testbench();
	// Choose a width
	localparam WIDTH = 5;
	
	// Module ports
	logic [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	logic in_segment;
	logic out_result;
	
	// Device under test
	on_line_detector dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 20;
	localparam DELAY = 1;
	string CURRENT_TEST;
	
	// Module tests
	initial begin
		// TBD
	end // initial
	
endmodule // on_line_detector_testbench

module between_testbench();
	// Choose a width
	localparam WIDTH = 5;
	MIN_WIDTH_INT = 0;				MIN_WIDTH = MIN_WIDTH_INT[WIDTH - 1:0];
	MID_WIDTH_INT = 2**(WIDTH - 1);	MID_WIDTH = MID_WIDTH_INT[WIDTH - 1:0];
	MAX_WIDTH_INT = 2**(WIDTH);		MAX_WIDTH = MAX_WIDTH_INT[WIDTH - 1:0];
	
	// Module ports
	logic [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	logic out_between;
	
	// Device under test
	between #(.WIDTH(WIDTH)) dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 20;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// BOUNDS
		current_test = "BOUNDARY LINES";
		
	end // initial
	
endmodule // between_testbench

// steep_checker
// mismatch
// cross_product_length

module abs_testbench();
	// Choose a width
	localparam WIDTH = 3;
	
	// Module ports
	logic [WIDTH:0] in_signed;
	logic [WIDTH - 1:0] out_unsigned;
	
	// Device under test
	abs #(.WIDTH(WIDTH)) dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 20;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// All input combinations
		current_test = "ALL VALUES";
		for (int i = 0; i < (2**(WIDTH + 1)); i++) begin
			in_signed = i; #DELAY;
		end // for i
	end // initial

endmodule // abs_testbench

