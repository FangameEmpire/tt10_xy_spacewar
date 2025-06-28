// Testbench  designed for Quartus and ModelSim
`timescale 1ns/10ps
`default_nettype none
module on_line_detector_testbench();
	// Choose a width
	localparam WIDTH = 5;
	localparam MIN_WIDTH_INT = 0;					localparam MIN_WIDTH = MIN_WIDTH_INT[WIDTH - 1:0];
	localparam MID_WIDTH_INT = 2**(WIDTH - 1) - 1;	localparam MID_WIDTH = MID_WIDTH_INT[WIDTH - 1:0];
	localparam MAX_WIDTH_INT = 2**(WIDTH) - 1;		localparam MAX_WIDTH = MAX_WIDTH_INT[WIDTH - 1:0];
	
	// Module ports
	logic [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	logic in_segment;
	logic out_result;
	
	// Device under test
	on_line_detector dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 30;
	localparam RUNS_RANDOM_SPECIAL = 10;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// Boundary tests
		current_test = "BOUNDARY LINES";
		in_segment = 1'b1;
		{in_ax, in_ay, in_bx, in_by, in_cx, in_cy} = {6{MIN_WIDTH}};	#DELAY;
		
		// Top line
		current_test = "BOUND: TOP";
		in_cx = MAX_WIDTH;												#DELAY;
		for (int i = 0; i < MAX_WIDTH + 1; i++) begin
			for (int j = -1; j < 2; j++) begin
				in_bx = i; in_by = j;									#DELAY;
			end // for j
		end // for i
		
		// Right line
		current_test = "BOUND: RIGHT";
		{in_ax, in_ay} = {2{MAX_WIDTH}};								#DELAY;
		for (int i = 0; i < MAX_WIDTH + 1; i++) begin
			for (int j = -1; j < 2; j++) begin
				in_by = i; in_bx = MAX_WIDTH + j;						#DELAY;
			end // for j
		end // for i
		
		// Bottom line
		current_test = "BOUND: BOTTOM";
		in_cx = MIN_WIDTH; in_cy = MAX_WIDTH;							#DELAY;
		for (int i = 0; i < MAX_WIDTH + 1; i++) begin
			for (int j = -1; j < 2; j++) begin
				in_bx = i; in_by = MAX_WIDTH + j;						#DELAY;
			end // for j
		end // for i
		
		// Left line
		current_test = "BOUND: LEFT";
		{in_ax, in_ay} = {2{MIN_WIDTH}};								#DELAY;
		for (int i = 0; i < MAX_WIDTH + 1; i++) begin
			for (int j = -1; j < 2; j++) begin
				in_by = i; in_bx = j;									#DELAY;
			end // for j
		end // for i
		
		// 8x8 Sweep
		current_test = "SWEEP (SEGMENT)";
		in_ax = 5'd3; in_ay = 5'd6; in_cx = 5'd5; in_cy = 5'd2;
		for (int i = 0; i < 8; i++) begin
			for (int j = 0; j < 8; j++) begin
				in_bx = i; in_by = j;									#DELAY;
			end // for j
		end // for i
		
		current_test = "SWEEP (COLINEAR)";
		in_segment = 1'b0;
		for (int i = 0; i < 8; i++) begin
			for (int j = 0; j < 8; j++) begin
				in_bx = i; in_by = j;									#DELAY;
			end // for j
		end // for i
		
		// A = C, Line undefined
		current_test = "A = C (COLINEAR)";
		{in_ax, in_ay, in_cx, in_cy} = {4{5'd4}};
		for (int i = 0; i < 8; i++) begin
			for (int j = 0; j < 8; j++) begin
				in_bx = i; in_by = j;									#DELAY;
			end // for j
		end // for i
		
		// Random tests
		current_test = "RANDOM INPUTS (SEGMENT)"; in_segment = 1'b1;
		for (int i = 0; i < RUNS_RANDOM; i++) begin
			in_ax = ($urandom % 8); in_ay = ($urandom % 8); 
			in_bx = ($urandom % 8); in_by = ($urandom % 8); 
			in_cx = ($urandom % 8); in_cy = ($urandom % 8);				#DELAY;
		end // for i
		
		current_test = "RANDOM INPUTS (COLINEAR)"; in_segment = 1'b0;
		for (int i = 0; i < RUNS_RANDOM; i++) begin
			in_ax = ($urandom % 8); in_ay = ($urandom % 8); 
			in_bx = ($urandom % 8); in_by = ($urandom % 8); 
			in_cx = ($urandom % 8); in_cy = ($urandom % 8);				#DELAY;
		end // for i
		
		// End the simulation
		$stop;
		
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
		
		// End the simulation
		$stop;
		
	end // initial
	
endmodule // steep_checker_testbench

module mismatch_testbench();
	// Choose a width
	localparam WIDTH = 3;
	
	// Module ports
	logic [WIDTH - 1:0] in_signs;
	logic out_mismatch;
	
	// Device under test
	mismatch #(.WIDTH(WIDTH)) dut (.*);
	
	// Simulation parameters
	localparam RUNS_RANDOM = 30;
	localparam RUNS_RANDOM_SPECIAL = 10;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// All input combinations
		current_test = "ALL VALUES";
		for (int i = 0; i < (2**WIDTH); i++) begin
			in_signs = i; #DELAY;
		end // for i
		
		// End the simulation
		$stop;
		
	end // initial

endmodule // mismatch_testbench

module cross_product_length_testbench();
	// Choose a width
	localparam WIDTH = 5;
	localparam MIN_WIDTH_INT = 0;					localparam MIN_WIDTH = MIN_WIDTH_INT[WIDTH - 1:0];
	localparam MID_WIDTH_INT = 2**(WIDTH - 1) - 1;	localparam MID_WIDTH = MID_WIDTH_INT[WIDTH - 1:0];
	localparam MAX_WIDTH_INT = 2**(WIDTH) - 1;		localparam MAX_WIDTH = MAX_WIDTH_INT[WIDTH - 1:0];
	
	// Module ports
	logic unsigned [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	logic signed [2 * WIDTH:0] out_length;
	
	// Device under test
	cross_product_length #(.WIDTH(WIDTH)) dut (.*);
	
	// Simulation-only results
	logic signed [WIDTH:0] ideal_diff0, ideal_diff1, ideal_diff2, ideal_diff3;
	logic signed [2 * WIDTH:0] ideal_prod0, ideal_prod1;
	logic [2 * WIDTH:0] ideal_length;
	
	always_comb begin
		// Differences
		ideal_diff0 = in_ax - in_cx;
		ideal_diff1 = in_cy - in_by;
		ideal_diff2 = in_ay - in_cy;
		ideal_diff3 = in_cx - in_bx;
		
		// Products
		ideal_prod0 = ideal_diff0 * ideal_diff1;
		ideal_prod1 = ideal_diff2 * ideal_diff3;
		
		// End result
		ideal_length = ideal_prod0 - ideal_prod1;
		
	end // always_comb
	
	// Simulation parameters
	localparam RUNS_RANDOM = 30;
	localparam RUNS_RANDOM_SPECIAL = 10;
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// Boundary lines
		current_test = "BOUNDARY LINES";
		{in_ax, in_ay, in_bx, in_by, in_cx, in_cy} = {6{MIN_WIDTH}};	#DELAY;
		in_bx = MAX_WIDTH;												#DELAY;
		{in_cx, in_cy} = {2{MAX_WIDTH}};								#DELAY;
		in_ay = MAX_WIDTH;												#DELAY;
		in_ay = MIN_WIDTH; in_bx = MIN_WIDTH; in_by = MAX_WIDTH;		#DELAY;
		in_bx = MAX_WIDTH;												#DELAY;
		
		// Zero length
		current_test = "ZERO LENGTH";
		for (int i = 0; i < RUNS_RANDOM_SPECIAL; i++) begin
			in_bx = $random; in_by = in_bx;					#DELAY;
		end // for i
		in_cy = MIN_WIDTH; in_by = MIN_WIDTH;				#DELAY;
		for (int i = 0; i < RUNS_RANDOM_SPECIAL; i++) begin
			in_bx = $random; 								#DELAY;
		end // for i
		
		// Sweeps
		current_test = "SWEEP (HORIZONTAL LINE)";
		in_ax = MIN_WIDTH; in_cx = MAX_WIDTH; {in_ay, in_cy} = {2{MID_WIDTH}};
		for (int i = MIN_WIDTH; i < MAX_WIDTH + 1; i++) begin
			in_bx = MID_WIDTH; in_by = i; #DELAY;
		end // for i
		
		current_test = "SWEEP (VERTICAL LINE)";
		{in_ax, in_cx} = {2{MID_WIDTH}}; in_ay = MIN_WIDTH; in_cy = MAX_WIDTH;
		for (int i = MIN_WIDTH; i < MAX_WIDTH + 1; i++) begin
			in_bx = i; in_by = MID_WIDTH; #DELAY;
		end // for i
		
		current_test = "SWEEP (SLOPE = 1)";
		{in_ax, in_cy} = {2{MIN_WIDTH}}; {in_ay, in_cx} = {2{MAX_WIDTH}};
		for (int i = MIN_WIDTH; i < MAX_WIDTH + 1; i++) begin
			in_bx = i; in_by = i; #DELAY;
		end // for i
		
		current_test = "SWEEP (SLOPE = -1)";
		{in_ax, in_ay} = {2{MIN_WIDTH}}; {in_cy, in_cx} = {2{MAX_WIDTH}};
		for (int i = MIN_WIDTH; i < MAX_WIDTH + 1; i++) begin
			in_bx = i; in_by = MAX_WIDTH - i; #DELAY;
		end // for i
		
		// Max length
		current_test = "MAX LENGTH";
		{in_ax, in_by} = {2{MIN_WIDTH}}; {in_ay, in_cx, in_cy} = {3{MAX_WIDTH}};
		for (int i = 0; i < RUNS_RANDOM_SPECIAL; i++) begin
			in_bx = $random; 								#DELAY;
		end // for i
		in_ax = MAX_WIDTH; in_ay = MIN_WIDTH; in_bx = MIN_WIDTH;
		for (int i = 0; i < RUNS_RANDOM_SPECIAL; i++) begin
			in_by = $random; 								#DELAY;
		end // for i
		
		// Random input
		current_test = "RANDOM INPUTS";
		for (int i = 0; i < RUNS_RANDOM; i++) begin
			{in_ax, in_ay, in_bx, in_by, in_cx, in_cy} = {6{$random}}; #DELAY;
		end // for i
		
		// End the simulation
		$stop;
		
	end // initial
	
endmodule // cross_product_length_testbench

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
		
		// End the simulation
		$stop;
		
	end // initial

endmodule // abs_testbench

