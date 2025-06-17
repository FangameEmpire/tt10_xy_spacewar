// Check if point 2 is on the line between points 1 and 3. Makes no asumptions 
// regarding the relative locations of points 1 and 3. Fully combinational, 
// includes two integer multipliers. "on_line_segment" checks whether point 2 
// is between points 1 and 3 in X and Y.
module on_line_checker(en, reset, x_0, x_1, x_2, y_2, x_3, y_3, on_line, on_line_segment);
	// Ports
	input en, reset;
	input [4:0] x_0, x_1, x_2, y_2, x_3, y_3;
	output on_line, between_bounds;	
	
	// Store distances
	wire [10:0] dist_cur, dist_up_left, dist_down_right;
	
	// Calculate slope of line
	
endmodule // on_line_checker

// Determines if there is a mix of 0 and 1 in the inputs. Good for two's
// complement sign (MSB) mismatch.
module mismatch(en, reset, in_bits, mismatch);
	// Ports
	input [2:0] in_bits;
	
	// Not all 0 AND not all 1
	assign mismatch = |(in_bits) & ~&(in_bits);

endmodule // sign_mismatch

module abs(en, reset, signed_in, magnitude_out);
	// Ports
	input en, reset;
	input [10:0] signed_in;
	output [10:0] magnitude_out;
	
	// Absolute value
	assign magnitude_out = signed_in[10] ? -signed_in : signed_in;
	
endmodule // abs

// length = (x1 - x3) * (y3 - y2) - (y1 - y3) * (x3 - x2)
// Max value = +- ((2^WIDTH) - 1)^2. 5 bits -> Max = +- 961 -> 11 bits
module cross_product_length(en, reset, x_0, x_1, x_2, y_2, x_3, y_3, length);
	// Ports
	input en, reset;
	input [4:0] x_0, x_1, x_2, y_2, x_3, y_3;
	output [10:0] length;
	
	// Store caculations
	wire [10:0] term_A, term_B;
	wire [4:0] diff_A1, diff_A2, diff_B1, diff_B2;
	
	// Make calculations
	assign diff_A1 = x1 - x3;
	assign diff_A2 = y3 - y2;
	assign diff_B1 = y1 - y3;
	assign diff_B2 = x3 - x2;
	assign term_A = diff_A1 * diff_A2;
	assign term_B = diff_B1 * diff_B2;
	assign length = term_A - term_B;

endmodule // cross_product_length