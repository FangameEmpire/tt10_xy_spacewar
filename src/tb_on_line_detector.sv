// Testbench  designed for Quartus and ModelSim
`timescale 1ns/10ps
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
	localparam RUNS_FIXED = 5;
	localparam RUNS_RANDOM = 20;
	localparam DELAY = 1;
	string CURRENT_TEST = "RESET";
	
	// ALU tests
	initial begin
		// TBD
	end // initial
	
endmodule // on_line_detector_testbench

