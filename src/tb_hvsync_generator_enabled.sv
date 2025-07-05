`timescale 1ns/10ps
`default_nettype none

// Enumerate states and flags
typedef enum bit[1:0] {Active = 2'b01, FP = 2'b10, SYNC = 2'b11, BP = 2'b0} state_meaning;
typedef enum bit[1:0] {MAX = 2'b10, MIN = 2'b01, NONE = 2'b00, INVALID_2b11 = 2'b11} flag_meaning;

module hvsync_generator_enabled_testbench();
	// Generator ports
	logic clk, reset, en;
	logic hsync, vsync, display_on;
	logic [9:0] hpos, vpos;
	
	// Decoder ports
	logic [3:0] state, flags;
	
	// Meanings of states and flags
	state_meaning v_state_meaning, h_state_meaning;
	flag_meaning v_flag_meaning, h_flag_meaning;
	always_comb begin
		v_state_meaning = state_meaning'(state[3:2]);
		h_state_meaning = state_meaning'(state[1:0]);
		v_flag_meaning = flag_meaning'(flags[3:2]);
		h_flag_meaning = flag_meaning'(flags[1:0]);
	end // always_comb
	
	// Device(s) Under Test
	hvsync_generator_enabled dut_0 (.*);
	hvsync_generator_decoder dut_1 (.*);
	
	// Clock
	parameter CLOCK_PERIOD=20;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Declarations for TV-simulator sync parameters
	// Horizontal constants
	parameter H_DISPLAY       = 640; // horizontal display width
	parameter H_BACK          =  48; // horizontal left border (back porch)
	parameter H_FRONT         =  16; // horizontal right border (front porch)
	parameter H_SYNC          =  96; // horizontal sync width
	// Vertical constants
	parameter V_DISPLAY       = 480; // vertical display height
	parameter V_TOP           =  33; // vertical top border
	parameter V_BOTTOM        =  10; // vertical bottom border
	parameter V_SYNC          =   2; // vertical sync # lines
	// Derived constants
	parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
	parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC - 1;
	parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
	parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
	parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
	parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;
	
	// Simulation parameters
	localparam CYCLES_PER_FRAME = (H_MAX + 1) * (V_MAX + 1);
	localparam CYCLES_0 = 8;
	localparam CYCLES_1 = 32;
	string current_test;
	
	// Test enabled version
	initial begin
		// Reset
		current_test = "RESET";
		reset = 1; en = 0; 	repeat(01) @(posedge clk);
		
		// Test enable and reset
		current_test = "ENABLE + RESET";
		reset = 0;			repeat(CYCLES_0) @(posedge clk);
		en = 1;				repeat(CYCLES_1) @(posedge clk);
		
		for (int i = 0; i < CYCLES_1; i++) begin
			en = ~en;		repeat(01);	@(posedge clk);
		end // for i
		
		en = 0; reset = 1;	repeat(CYCLES_0) @(posedge clk);
		reset = 0; en = 1;	repeat(CYCLES_0) @(posedge clk);
		reset = 1;			repeat(CYCLES_0) @(posedge clk);
		reset = 0;			repeat(CYCLES_0) @(posedge clk);
		en = 0;				repeat(CYCLES_0) @(posedge clk);
		reset = 1;			repeat(CYCLES_0) @(posedge clk);
		
		// Full sweep, state and flags from decoder
		current_test = "ONE FRAME + SOME OF FRAME 2";
		//reset = 0; en = 1; 	repeat(CYCLES_PER_FRAME + CYCLES_1); 	@(posedge clk);
		for (int i = 0; i < (V_MAX + 1); i++) begin
			for (int j = 0; j < (H_MAX + 1); j++) begin
				reset = 0; en = 1;			repeat(01) @(posedge clk);
			end // for j
		end // for i
		
		/* Let the counters roll over */	repeat(CYCLES_1) @(posedge clk);
		reset = 1;							repeat(CYCLES_0) @(posedge clk);
		
		// End the simulation
		$stop;
		
	end // initial
	
endmodule // hvsync_generator_enabled

// Macros for H, V transitions
`define H_Active_FP \
hpos = 10'd639;	#DELAY; \
hpos = 10'd640;	#DELAY;

`define H_FP_HSYNC \
hpos = 10'd655;	#DELAY; \
hpos = 10'd656;	#DELAY;

`define H_HSYNC_BP \
hpos = 10'd751;	#DELAY; \
hpos = 10'd752;	#DELAY;

`define H_BP_Active \
hpos = 10'd799;	#DELAY; \
hpos = 10'd000;	#DELAY;

`define V_Active_FP \
vpos = 10'd479;	#DELAY; \
vpos = 10'd480;	#DELAY;

`define V_FP_HSYNC \
vpos = 10'd489;	#DELAY; \
vpos = 10'd490;	#DELAY;

`define V_HSYNC_BP \
vpos = 10'd491;	#DELAY; \
vpos = 10'd492;	#DELAY;

`define V_BP_Active \
vpos = 10'd524;	#DELAY; \
vpos = 10'd000;	#DELAY;

module hvsync_generator_decoder_testbench();
	// Module ports
	logic [9:0] hpos, vpos;
	logic [3:0] state, flags;
	
	// Device Under Test
	hvsync_generator_decoder dut (.*);
	
	// Meanings of states and flags
	state_meaning v_state_meaning, h_state_meaning;
	flag_meaning v_flag_meaning, h_flag_meaning;
	always_comb begin
		v_state_meaning = state_meaning'(state[3:2]);
		h_state_meaning = state_meaning'(state[1:0]);
		v_flag_meaning = flag_meaning'(flags[3:2]);
		h_flag_meaning = flag_meaning'(flags[1:0]);
	end // always_comb
	
	// Simulation parameters
	localparam DELAY = 1;
	string current_test;
	
	// Module tests
	initial begin
		// Reset
		current_test = "RESET";
		hpos = 10'd0; vpos = 10'd0;	#DELAY;
		
		// H Checks
		current_test = "H TRANSITIONS";
		`H_Active_FP;
		`H_FP_HSYNC;
		`H_HSYNC_BP;
		`H_BP_Active;
		
		// V Checks
		current_test = "V TRANSITIONS";
		`V_Active_FP;
		`V_FP_HSYNC;
		`V_HSYNC_BP;
		`V_BP_Active;
		
		// Full Frame
		current_test = " ONE FRAME + NEXT CYCLE";
		for (int i = 0; i < 525; i++) begin
			for (int j = 0; j < 800; j++) begin
				hpos = j; vpos = i; #DELAY;
			end // for j
		end // for i
		hpos = 10'd0; vpos = 10'd0;	#DELAY;
		
		// End the simulation
		$stop;
		
	end // initial
	
endmodule // hvsync_generator_decoder_testbench