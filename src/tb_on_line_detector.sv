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
	localparam MIN_WIDTH_INT = 0;					localparam MIN_WIDTH = MIN_WIDTH_INT[WIDTH - 1:0];
	localparam MID_WIDTH_INT = 2**(WIDTH - 1) - 1;	localparam MID_WIDTH = MID_WIDTH_INT[WIDTH - 1:0];
	localparam MAX_WIDTH_INT = 2**(WIDTH) - 1;		localparam MAX_WIDTH = MAX_WIDTH_INT[WIDTH - 1:0];
	
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
		{in_ax, in_ay, in_bx, in_by, in_cx, in_cy} = {6{MIN_WIDTH}};	#DELAY;
		{in_cx, in_cy} = {2{MAX_WIDTH}};								#DELAY;
		{in_ax, in_ay} = {2{MID_WIDTH}};								#DELAY;
		{in_cx, in_cy} = {2{MIN_WIDTH}};								#DELAY;
		{in_ax, in_ay, in_bx, in_by, in_cx, in_cy} = {6{MAX_WIDTH}};	#DELAY;
		
		// RANDOM INPUTS
		current_test = "RANDOM INPUTS";
		for (int i = 0; i < RUNS_RANDOM; i++) begin
			in_ax = $random; in_ay = $random; in_bx = $random; in_by = $random; in_cx = $random; in_cy = $random; #DELAY;
		end // for i
		
	end // initial
	
endmodule // between_testbench

module steep_checker_testbench();
	// Choose a width
	localparam WIDTH = 5;
	localparam MIN_WIDTH_INT = 0;					localparam MIN_WIDTH = MIN_WIDTH_INT[WIDTH - 1:0];
	localparam MID_WIDTH_INT = 2**(WIDTH - 1) - 1;	localparam MID_WIDTH = MID_WIDTH_INT[WIDTH - 1:0];
	localparam MAX_WIDTH_INT = 2**(WIDTH) - 1;		localparam MAX_WIDTH = MAX_WIDTH_INT[WIDTH - 1:0];
	
	// Module ports
	logic [WIDTH - 1:0] in_x0, in_y0, in_x1, in_y1;
	logic out_steep;
	
	// Device under test
	steep_checker #(.WIDTH(WIDTH)) dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 20;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// Slopes = 0, 1, INF
		current_test = "SLOPES 0, 1, INF";
		
		// Corners
		{in_x0, in_y0, in_x1, in_y1} = {4{MIN_WIDTH}};	#DELAY;
		{in_x1, in_y1} = {2{MAX_WIDTH}};				#DELAY;
		in_x0 = MAX_WIDTH; in_x1 = MIN_WIDTH;			#DELAY;
		in_y0 = MAX_WIDTH;								#DELAY;
		in_x0 = MIN_WIDTH; in_x1 = MAX_WIDTH;			#DELAY;
		in_x0 = MAX_WIDTH; in_y0 = MIN_WIDTH;			#DELAY;
		{in_x0, in_x1} = {2{MIN_WIDTH}};				#DELAY;
		
		// Centers
		current_test = "CENTERS, SLOPE = 1";
		in_x0 = MID_WIDTH; in_y0 = MIN_WIDTH; in_x1 = MAX_WIDTH; in_y1 = MID_WIDTH; #DELAY;
		in_y0 = MAX_WIDTH;															#DELAY;
		in_x1 = MIN_WIDTH;															#DELAY;
		in_y0 = MIN_WIDTH;															#DELAY;
		
		// Slopes = 0.5, 2
		current_test = "SLOPES 0.5, 2";
		
		// Center-left fixed
		in_x0 = MIN_WIDTH; in_y0 = MID_WIDTH; in_x1 = MAX_WIDTH; in_y1 = MIN_WIDTH; #DELAY;
		in_y1 = MID_WIDTH;															#DELAY;
		in_y1 = MAX_WIDTH;															#DELAY;
		
		// Center-top fixed
		in_x0 = MID_WIDTH; in_y0 = MIN_WIDTH; in_x1 = MIN_WIDTH; in_y1 = MAX_WIDTH; #DELAY;
		in_x1 = MID_WIDTH;															#DELAY;
		in_x1 = MAX_WIDTH;															#DELAY;
		
		// Center-right fixed
		in_x0 = MAX_WIDTH; in_y0 = MID_WIDTH; in_x1 = MIN_WIDTH; in_y1 = MIN_WIDTH; #DELAY;
		in_y1 = MID_WIDTH;															#DELAY;
		in_y1 = MAX_WIDTH;															#DELAY;
		
		// Bottom-right fixed
		in_x0 = MID_WIDTH; in_y0 = MAX_WIDTH; in_x1 = MIN_WIDTH; in_y1 = MIN_WIDTH; #DELAY;
		in_x1 = MID_WIDTH;															#DELAY;
		in_x1 = MAX_WIDTH;															#DELAY;
		
		// Random inputs
		current_test = "RANDOM INPUTS";
		for (int i = 0; i < RUNS_RANDOM; i++) begin
			in_x0 = $random; in_y0 = $random; in_x1 = $random; in_y1 = $random; #DELAY;
		end // for i
		
	end // initial
	
endmodule // steep_checker_testbench

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

