/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_spacewar (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[6:0] = 0;
  assign uio_oe[6:0]  = 0;
  assign uio_oe[7]  = 1;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Tiny VGA Pmod
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Slowdown counter
  reg [13:0] counter;
  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  // Convenient constants
  parameter X_MAX = (640 - 1);
  parameter Y_MAX = (480 - 1);
  parameter WIDTH = 16;

  // Moving square
  wire do_square;
  assign do_square = ((pix_x >= square_x) && (pix_x < square_x + WIDTH)) && 
                     ((pix_y >= square_y) && (pix_y < square_y + WIDTH));

  // Square location
  reg [9:0] square_x, square_y;
  always @(posedge clk) begin
    if (~rst_n) begin
      square_x <= 0;
      square_y <= 0;
    end else begin
      if ((counter == 0) & ~video_active) begin
      if (inp_left && inp_right) begin
        square_x <= square_x;
      end else if (inp_left & (square_x > 0)) begin
          square_x <= square_x - 1;
        end else if (inp_right & (square_x < (X_MAX - WIDTH + 1))) begin
          square_x <= square_x + 1;
        end else begin
          square_x <= square_x;
        end
        
        if (inp_up && inp_down) begin
          square_y <= square_y;
        end else if (inp_up & (square_y > 0)) begin
          square_y <= square_y - 1;
        end else if (inp_down & (square_y < Y_MAX - WIDTH + 1)) begin
          square_y <= square_y + 1;
        end else begin
          square_y <= square_y;
        end
      end else begin
        square_x <= square_x;
        square_y <= square_y;
      end
    end
  end

  hvsync_generator vga_sync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  // Audio data
  reg[3:0] current_note;
  reg[6:0] current_position;
  reg[21:0] next_note_timer;
  reg[17:0] PWM_timer, PWM_timer_limit;

  // Note timing
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      next_note_timer <= 0;
      current_position <= 0;
    end else begin
      if (next_note_timer == 3375000) begin
        next_note_timer <= 0;
        current_position <= current_position + 1;
      end else begin
        next_note_timer <= next_note_timer + 1;
        current_position <= current_position;
      end
    end
  end

  // PWM timing
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      PWM_timer <= 0;
    end else begin
      if (PWM_timer == PWM_timer_limit) PWM_timer <= 0;
      else PWM_timer <= PWM_timer + 1;
    end
  end

  // Convert notes to PWM frequencies
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      PWM_timer_limit <= 0;
    end else begin
      case (current_note) 
        4'h0: PWM_timer_limit <= 41667;
        4'h1: PWM_timer_limit <= 43748;
        4'h2: PWM_timer_limit <= 45455;
        4'h3: PWM_timer_limit <= 50000;
        4'h4: PWM_timer_limit <= 55556;
        4'h5: PWM_timer_limit <= 62500;
        4'h6: PWM_timer_limit <= 71429;
        4'h7: PWM_timer_limit <= 83333;
        default: PWM_timer_limit <= 0;
      endcase
    end
  end

  // Determine current note
  wire[7:0] do_note;
  assign do_note[0] = (current_position == 7'd70) || (current_position == 7'd71) || (current_position == 7'd86) || (current_position == 7'd102) || (current_position == 7'd103);
  assign do_note[1] = (current_position == 7'd69) || (current_position == 7'd76) || (current_position == 7'd77) || (current_position == 7'd85) || (current_position == 7'd101) || (current_position == 7'd108) || (current_position == 7'd109) || (current_position == 7'd126) || (current_position == 7'd127);
  assign do_note[2] = (current_position == 7'd6) || (current_position == 7'd7) || (current_position == 7'd22) || (current_position == 7'd38) || (current_position == 7'd39) || (current_position == 7'd68) || (current_position == 7'd75) || (current_position == 7'd78) || (current_position == 7'd79) || (current_position == 7'd84) || (current_position == 7'd100) || (current_position == 7'd107) || (current_position == 7'd110) || (current_position == 7'd111) || (current_position == 7'd125);
  assign do_note[3] = (current_position == 7'd5) || (current_position == 7'd12) || (current_position == 7'd13) || (current_position == 7'd21) || (current_position == 7'd37) || (current_position == 7'd44) || (current_position == 7'd45) || (current_position == 7'd62) || (current_position == 7'd63) || (current_position == 7'd74) || (current_position == 7'd80) || (current_position == 7'd87) || (current_position == 7'd90) || (current_position == 7'd96) || (current_position == 7'd106) || (current_position == 7'd112) || (current_position == 7'd118) || (current_position == 7'd122) || (current_position == 7'd124);
  assign do_note[4] = (current_position == 7'd4) || (current_position == 7'd11) || (current_position == 7'd14) || (current_position == 7'd15) || (current_position == 7'd20) || (current_position == 7'd36) || (current_position == 7'd43) || (current_position == 7'd46) || (current_position == 7'd47) || (current_position == 7'd61) || (current_position == 7'd65) || (current_position == 7'd66) || (current_position == 7'd67) || (current_position == 7'd72) || (current_position == 7'd73) || (current_position == 7'd81) || (current_position == 7'd82) || (current_position == 7'd83) || (current_position == 7'd88) || (current_position == 7'd89) || (current_position == 7'd91) || (current_position == 7'd92) || (current_position == 7'd93) || (current_position == 7'd94) || (current_position == 7'd95) || (current_position == 7'd97) || (current_position == 7'd98) || (current_position == 7'd99) || (current_position == 7'd104) || (current_position == 7'd105) || (current_position == 7'd113) || (current_position == 7'd116) || (current_position == 7'd117) || (current_position == 7'd119) || (current_position == 7'd120) || (current_position == 7'd121) || (current_position == 7'd123);
  assign do_note[5] = (current_position == 7'd0) || (current_position == 7'd10) || (current_position == 7'd16) || (current_position == 7'd23) || (current_position == 7'd26) || (current_position == 7'd32) || (current_position == 7'd42) || (current_position == 7'd48) || (current_position == 7'd53) || (current_position == 7'd58) || (current_position == 7'd60) || (current_position == 7'd64) || (current_position == 7'd114) || (current_position == 7'd115);
  assign do_note[6] = (current_position == 7'd1) || (current_position == 7'd2) || (current_position == 7'd3) || (current_position == 7'd8) || (current_position == 7'd9) || (current_position == 7'd17) || (current_position == 7'd18) || (current_position == 7'd19) || (current_position == 7'd24) || (current_position == 7'd25) || (current_position == 7'd27) || (current_position == 7'd28) || (current_position == 7'd29) || (current_position == 7'd30) || (current_position == 7'd31) || (current_position == 7'd33) || (current_position == 7'd34) || (current_position == 7'd35) || (current_position == 7'd40) || (current_position == 7'd41) || (current_position == 7'd49) || (current_position == 7'd52) || (current_position == 7'd54) || (current_position == 7'd55) || (current_position == 7'd56) || (current_position == 7'd57) || (current_position == 7'd59);
  assign do_note[7] = (current_position == 7'd50) || (current_position == 7'd51);

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      current_note <= 0;
    end else begin
      if (do_note[0]) begin
        current_note <= 4'h0;
      end else if (do_note[1]) begin
        current_note <= 4'h1;
      end else if (do_note[2]) begin
        current_note <= 4'h2;
      end else if (do_note[3]) begin
        current_note <= 4'h3;
      end else if (do_note[4]) begin
        current_note <= 4'h4;
      end else if (do_note[5]) begin
        current_note <= 4'h5;
      end else if (do_note[6]) begin
        current_note <= 4'h6;
      end else if (do_note[7]) begin
        current_note <= 4'h7;
      end else begin
        current_note <= 4'h8;
      end
    end
  end

  // Play audio
  reg PWM_audio;
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      PWM_audio <= 0;
    end else begin
      if (PWM_timer == PWM_timer_limit) PWM_audio <= ~PWM_audio;
      else PWM_audio <= PWM_audio;
    end
  end
  assign uio_out[7] = PWM_audio;

  // Gamepad Pmod
  wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r, gamepad_is_present;

  gamepad_pmod_single driver (
      // Inputs:
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in[6]),
      .pmod_clk(ui_in[5]),
      .pmod_latch(ui_in[4]),
      // Outputs:
      .b(inp_b),
      .y(inp_y),
      .select(inp_select),
      .start(inp_start),
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .a(inp_a),
      .x(inp_x),
      .l(inp_l),
      .r(inp_r),
      .is_present(gamepad_is_present)
  );

  // Colors
  localparam [5:0] BLACK = {2'b00, 2'b00, 2'b00};
  localparam [5:0] GREEN = {2'b00, 2'b11, 2'b00};
  localparam [5:0] WHITE = {2'b11, 2'b11, 2'b11};

  // Glyph definitions (8x8)
  localparam [63:0] LEFT_GLYPH = {
      8'b00010000,
      8'b00110000,
      8'b01110000,
      8'b11111111,
      8'b01110000,
      8'b00110000,
      8'b00010000,
      8'b00000000
  };
  localparam [63:0] RIGHT_GLYPH = {
      8'b00001000,
      8'b00001100,
      8'b00001110,
      8'b11111111,
      8'b00001110,
      8'b00001100,
      8'b00001000,
      8'b00000000
  };
  localparam [63:0] UP_GLYPH = {
      8'b00010000,
      8'b00111000,
      8'b01111100,
      8'b11111110,
      8'b00010000,
      8'b00010000,
      8'b00010000,
      8'b00010000
  };
  localparam [63:0] DOWN_GLYPH = {
      8'b00010000,
      8'b00010000,
      8'b00010000,
      8'b00010000,
      8'b11111110,
      8'b01111100,
      8'b00111000,
      8'b00010000
  };
  localparam [63:0] A_GLYPH = {
      8'b00111100,
      8'b01100110,
      8'b01100110,
      8'b01111110,
      8'b01100110,
      8'b01100110,
      8'b01100110,
      8'b00000000
  };
  localparam [63:0] B_GLYPH = {
      8'b01111100,
      8'b01100110,
      8'b01100110,
      8'b01111100,
      8'b01100110,
      8'b01100110,
      8'b01111100,
      8'b00000000
  };
  localparam [63:0] X_GLYPH = {
      8'b11000011,
      8'b01100110,
      8'b00111100,
      8'b00011000,
      8'b00011000,
      8'b00111100,
      8'b01100110,
      8'b11000011
  };
  localparam [63:0] Y_GLYPH = {
      8'b11000011,
      8'b01100110,
      8'b00111100,
      8'b00011000,
      8'b00011000,
      8'b00011000,
      8'b00011000,
      8'b00011000
  };
  localparam [63:0] L_GLYPH = {
      8'b11100000,
      8'b11100000,
      8'b11100000,
      8'b11100000,
      8'b11100000,
      8'b11111110,
      8'b11111110,
      8'b00000000
  };
  localparam [63:0] R_GLYPH = {
      8'b11111100,
      8'b11100110,
      8'b11100110,
      8'b11111100,
      8'b11111000,
      8'b11111100,
      8'b11101110,
      8'b00000000
  };
  localparam [63:0] SELECT_GLYPH = {
      8'b00011000,
      8'b00100100,
      8'b01000010,
      8'b10000001,
      8'b10000001,
      8'b01000010,
      8'b00100100,
      8'b00011000
  };
  localparam [63:0] START_GLYPH = {
      8'b00011000,
      8'b01011010,
      8'b10011001,
      8'b10011001,
      8'b10011001,
      8'b10000001,
      8'b01000010,
      8'b00111100
  };

  // Glyph positions
  localparam LEFT_X = 64, LEFT_Y = 240;
  localparam RIGHT_X = 128, RIGHT_Y = 240;
  localparam UP_X = 96, UP_Y = 200;
  localparam DOWN_X = 96, DOWN_Y = 280;
  localparam A_X = 544, A_Y = 240;
  localparam B_X = 512, B_Y = 280;
  localparam X_X = 512, X_Y = 200;
  localparam Y_X = 480, Y_Y = 240;
  localparam L_X = 32, L_Y = 100;
  localparam R_X = 592, R_Y = 100;
  localparam SEL_X = 264, SEL_Y = 240;
  localparam STRT_X = 328, STRT_Y = 240;

  // Glyph activation logic
  wire left_act = glyph_active(LEFT_X, LEFT_Y, LEFT_GLYPH);
  wire right_act = glyph_active(RIGHT_X, RIGHT_Y, RIGHT_GLYPH);
  wire up_act = glyph_active(UP_X, UP_Y, UP_GLYPH);
  wire down_act = glyph_active(DOWN_X, DOWN_Y, DOWN_GLYPH);
  wire a_act = glyph_active(A_X, A_Y, A_GLYPH);
  wire b_act = glyph_active(B_X, B_Y, B_GLYPH);
  wire x_act = glyph_active(X_X, X_Y, X_GLYPH);
  wire y_act = glyph_active(Y_X, Y_Y, Y_GLYPH);
  wire l_act = glyph_active(L_X, L_Y, L_GLYPH);
  wire r_act = glyph_active(R_X, R_Y, R_GLYPH);
  wire sel_act = glyph_active(SEL_X, SEL_Y, SELECT_GLYPH);
  wire strt_act = glyph_active(STRT_X, STRT_Y, START_GLYPH);

  // Pressed state logic
  wire any_active = left_act | right_act | up_act | down_act | a_act | b_act |
                   x_act | y_act | l_act | r_act | sel_act | strt_act;
  wire any_pressed = (left_act & inp_left) | (right_act & inp_right) | 
                    (up_act & inp_up) | (down_act & inp_down) |
                    (a_act & inp_a) | (b_act & inp_b) |
                    (x_act & inp_x) | (y_act & inp_y) |
                    (l_act & inp_l) | (r_act & inp_r) |
                    (sel_act & inp_select) | (strt_act & inp_start);

  // RGB output logic
  always @(posedge clk) begin
    if (~rst_n) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      if (video_active) begin
        {R, G, B} <= (any_pressed ? GREEN : any_active ? WHITE : BLACK) | {2'b00, {2{do_square}}, 2'b00};
      end else begin
        {R, G, B} <= 0;
      end
    end
  end

  // Scaled glyph activation function (2x size)
  function glyph_active;
    input [9:0] x0, y0;
    input [63:0] glyph;
    reg [63:0] glyph_shifted;
    reg [9:0] x_rel, y_rel;
    reg [7:0] row;
    begin
      if ((pix_x >= x0) && (pix_x < x0 + 16) && (pix_y >= y0) && (pix_y < y0 + 16)) begin
        x_rel = (pix_x - x0) >> 1;  // Scale coordinates
        y_rel = (pix_y - y0) >> 1;
        // Copied from edits by Urish, edits are needed to make this work on an FPGA
        glyph_shifted = glyph >> ((7 - y_rel) << 3);
        row = glyph_shifted[7:0];
        glyph_active = row[7-x_rel];
      end else begin
        glyph_active = 0;
      end
    end
  endfunction

endmodule

/*
 * Copyright (c) 2025 Pat Deegan, https://psychogenic.com
 * SPDX-License-Identifier: Apache-2.0
 * Version: 1.0.0
 *
 * Interfacing code for the Gamepad Pmod from Psycogenic Technologies,
 * designed for Tiny Tapeout.
 *
 * There are two high-level modules that most users will be interested in:
 * - gamepad_pmod_single: for a single controller;
 * - gamepad_pmod_dual: for two controllers.
 * 
 * There are also two lower-level modules that you can use if you want to
 * handle the interfacing yourself:
 * - gamepad_pmod_driver: interfaces with the Pmod and provides the raw data;
 * - gamepad_pmod_decoder: decodes the raw data into button states.
 *
 * The docs, schematics, PCB files, and firmware code for the Gamepad Pmod
 * are available at https://github.com/psychogenic/gamepad-pmod.
 */

/**
 * gamepad_pmod_driver -- Serial interface for the Gamepad Pmod.
 *
 * This module reads raw data from the Gamepad Pmod *serially*
 * and stores it in a shift register. When the latch signal is received, 
 * the data is transferred into `data_reg` for further processing.
 *
 * Functionality:
 *   - Synchronizes the `pmod_data`, `pmod_clk`, and `pmod_latch` signals 
 *     to the system clock domain.
 *   - Captures serial data on each falling edge of `pmod_clk`.
 *   - Transfers the shifted data into `data_reg` when `pmod_latch` goes low.
 *
 * Parameters:
 *   - `BIT_WIDTH`: Defines the width of `data_reg` (default: 24 bits).
 *
 * Inputs:
 *   - `rst_n`: Active-low reset.
 *   - `clk`: System clock.
 *   - `pmod_data`: Serial data input from the Pmod.
 *   - `pmod_clk`: Serial clock from the Pmod.
 *   - `pmod_latch`: Latch signal indicating the end of data transmission.
 *
 * Outputs:
 *   - `data_reg`: Captured parallel data after shifting is complete.
 */
module gamepad_pmod_driver #(
    parameter BIT_WIDTH = 24
) (
    input wire rst_n,
    input wire clk,
    input wire pmod_data,
    input wire pmod_clk,
    input wire pmod_latch,
    output reg [BIT_WIDTH-1:0] data_reg
);

  reg pmod_clk_prev;
  reg pmod_latch_prev;
  reg [BIT_WIDTH-1:0] shift_reg;

  // Sync Pmod signals to the clk domain:
  reg [1:0] pmod_data_sync;
  reg [1:0] pmod_clk_sync;
  reg [1:0] pmod_latch_sync;

  always @(posedge clk) begin
    if (~rst_n) begin
      pmod_data_sync  <= 2'b0;
      pmod_clk_sync   <= 2'b0;
      pmod_latch_sync <= 2'b0;
    end else begin
      pmod_data_sync  <= {pmod_data_sync[0], pmod_data};
      pmod_clk_sync   <= {pmod_clk_sync[0], pmod_clk};
      pmod_latch_sync <= {pmod_latch_sync[0], pmod_latch};
    end
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      /* Initialize data and shift registers to all 1s so they're detected as "not present".
       * This accounts for cases where we have:
       *  - setup for 2 controllers;
       *  - only a single controller is connected; and
       *  - the driver in those cases only sends bits for a single controller.
       */
      data_reg <= {BIT_WIDTH{1'b1}};
      shift_reg <= {BIT_WIDTH{1'b1}};
      pmod_clk_prev <= 1'b0;
      pmod_latch_prev <= 1'b0;
    end
    begin
      pmod_clk_prev   <= pmod_clk_sync[1];
      pmod_latch_prev <= pmod_latch_sync[1];

      // Capture data on rising edge of pmod_latch:
      if (pmod_latch_sync[1] & ~pmod_latch_prev) begin
        data_reg <= shift_reg;
      end

      // Sample data on rising edge of pmod_clk:
      if (pmod_clk_sync[1] & ~pmod_clk_prev) begin
        shift_reg <= {shift_reg[BIT_WIDTH-2:0], pmod_data_sync[1]};
      end
    end
  end

endmodule


/**
 * gamepad_pmod_decoder -- Decodes raw data from the Gamepad Pmod.
 *
 * This module takes a 12-bit parallel data register (`data_reg`) 
 * and decodes it into individual button states. It also determines
 * whether a controller is connected.
 *
 * Functionality:
 *   - If `data_reg` contains all `1's` (`0xFFF`), it indicates that no controller is connected.
 *   - Otherwise, it extracts individual button states from `data_reg`.
 *
 * Inputs:
 *   - `data_reg [11:0]`: Captured button state data from the gamepad.
 *
 * Outputs:
 *   - `b, y, select, start, up, down, left, right, a, x, l, r`: Individual button states (`1` = pressed, `0` = released).
 *   - `is_present`: Indicates whether a controller is connected (`1` = connected, `0` = not connected).
 */
module gamepad_pmod_decoder (
    input wire [11:0] data_reg,
    output wire b,
    output wire y,
    output wire select,
    output wire start,
    output wire up,
    output wire down,
    output wire left,
    output wire right,
    output wire a,
    output wire x,
    output wire l,
    output wire r,
    output wire is_present
);

  // When the controller is not connected, the data register will be all 1's
  wire reg_empty = (data_reg == 12'hfff);
  assign is_present = reg_empty ? 0 : 1'b1;
  assign {b, y, select, start, up, down, left, right, a, x, l, r} = reg_empty ? 0 : data_reg;

endmodule


/**
 * gamepad_pmod_single -- Main interface for a single Gamepad Pmod controller.
 * 
 * This module provides button states for a **single controller**, reducing 
 * resource usage (fewer flip-flops) compared to a dual-controller version.
 * 
 * Inputs:
 *   - `pmod_data`, `pmod_clk`, and `pmod_latch` are the signals from the PMOD interface.
 * 
 * Outputs:
 *   - Each button's state is provided as a single-bit wire (e.g., `start`, `up`, etc.).
 *   - `is_present` indicates whether the controller is connected (`1` = connected, `0` = not detected).
 */
module gamepad_pmod_single (
    input wire rst_n,
    input wire clk,
    input wire pmod_data,
    input wire pmod_clk,
    input wire pmod_latch,

    output wire b,
    output wire y,
    output wire select,
    output wire start,
    output wire up,
    output wire down,
    output wire left,
    output wire right,
    output wire a,
    output wire x,
    output wire l,
    output wire r,
    output wire is_present
);

  wire [11:0] gamepad_pmod_data;

  gamepad_pmod_driver #(
      .BIT_WIDTH(12)
  ) driver (
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(pmod_data),
      .pmod_clk(pmod_clk),
      .pmod_latch(pmod_latch),
      .data_reg(gamepad_pmod_data)
  );

  gamepad_pmod_decoder decoder (
      .data_reg(gamepad_pmod_data),
      .b(b),
      .y(y),
      .select(select),
      .start(start),
      .up(up),
      .down(down),
      .left(left),
      .right(right),
      .a(a),
      .x(x),
      .l(l),
      .r(r),
      .is_present(is_present)
  );

endmodule


/**
 * gamepad_pmod_dual -- Main interface for the Pmod gamepad.
 * This module provides button states for two controllers using
 * 2-bit vectors for each button (e.g., start[1:0], up[1:0], etc.).
 * 
 * Each button state is represented as a 2-bit vector:
 *   - Index 0 corresponds to the first controller (e.g., up[0], y[0], etc.).
 *   - Index 1 corresponds to the second controller (e.g., up[1], y[1], etc.).
 *
 * The `is_present` signal indicates whether a controller is connected:
 *   - `is_present[0] == 1` when the first controller is connected.
 *   - `is_present[1] == 1` when the second controller is connected.
 *
 * Inputs:
 *   - `pmod_data`, `pmod_clk`, and `pmod_latch` are the 3 wires coming from the Pmod interface.
 *
 * Outputs:
 *   - Button state vectors for each controller.
 *   - Presence detection via `is_present`.
 */
module gamepad_pmod_dual (
    input wire rst_n,
    input wire clk,
    input wire pmod_data,
    input wire pmod_clk,
    input wire pmod_latch,

    output wire [1:0] b,
    output wire [1:0] y,
    output wire [1:0] select,
    output wire [1:0] start,
    output wire [1:0] up,
    output wire [1:0] down,
    output wire [1:0] left,
    output wire [1:0] right,
    output wire [1:0] a,
    output wire [1:0] x,
    output wire [1:0] l,
    output wire [1:0] r,
    output wire [1:0] is_present
);

  wire [23:0] gamepad_pmod_data;

  gamepad_pmod_driver driver (
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(pmod_data),
      .pmod_clk(pmod_clk),
      .pmod_latch(pmod_latch),
      .data_reg(gamepad_pmod_data)
  );

  gamepad_pmod_decoder decoder1 (
      .data_reg(gamepad_pmod_data[11:0]),
      .b(b[0]),
      .y(y[0]),
      .select(select[0]),
      .start(start[0]),
      .up(up[0]),
      .down(down[0]),
      .left(left[0]),
      .right(right[0]),
      .a(a[0]),
      .x(x[0]),
      .l(l[0]),
      .r(r[0]),
      .is_present(is_present[0])
  );

  gamepad_pmod_decoder decoder2 (
      .data_reg(gamepad_pmod_data[23:12]),
      .b(b[1]),
      .y(y[1]),
      .select(select[1]),
      .start(start[1]),
      .up(up[1]),
      .down(down[1]),
      .left(left[1]),
      .right(right[1]),
      .a(a[1]),
      .x(x[1]),
      .l(l[1]),
      .r(r[1]),
      .is_present(is_present[1])
  );

endmodule
