// Check if point b is on the line between points a and c. Makes no asumptions 
// regarding the relative locations of points a and c. Fully combinational, 
// includes two integer multipliers. Setting "in_segment" high checks whether 
// point b is between points a and c in X and Y, while setting it low only 
// checks for colinearity.
module on_line_detector #(parameter WIDTH = 5) (in_ax, in_ay, in_bx, in_by, in_cx, in_cy, in_segment, out_result);
	// Ports
	input [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	input in_segment;
	output out_result;
	
	// Check line steepness (High if > 45 degrees)
	wire steep;
	steep_checker #(.WIDTH(WIDTH)) line_steepness_checker (in_ax, in_ay, in_cx, in_cy, steep);
	
	// Store line distances
	wire [WIDTH * 2:0] dist_cur, dist_up_left, dist_down_right;
	
	// Use line steepness to determine up-down check or left-right check. If 
	// the line is steep, we check the pixels to the left and right of the
	// current pixel, since there can only be one pixel per y value. Otherwise,
	// There can only be one pixel per x value.
	wire [WIDTH - 1:0] x_ul, x_dr, y_ul, y_dr, offset;
	assign offset = {{(WIDTH - 1){1'b0}}, 1'b1};
	assign x_ul = steep ? (in_bx  - 5'b00001) : in_bx;
	assign x_dr = steep ? (in_bx  + 5'b00001) : in_bx;
	assign y_ul = steep ? in_by : (in_by  - 5'b00001);
	assign y_dr = steep ? in_by : (in_by  + 5'b00001);
	
	// Check pixel distances from the ideal line between a and c
	cross_product_length #(.WIDTH(WIDTH)) cpl_mid (in_ax, in_ay, in_bx, in_by, in_cx, in_cy, dist_cur);
	cross_product_length #(.WIDTH(WIDTH)) cpl_ul  (in_ax, in_ay, x_ul,  y_ul,  in_cx, in_cy, dist_up_left);
	cross_product_length #(.WIDTH(WIDTH)) cpl_dr  (in_ax, in_ay, x_dr,  y_dr,  in_cx, in_cy, dist_down_right);
	
	// Check if the center point is the closest, including exactly on the line.
	// Sign mismatch between the UL and DR points indicates that the line is 
	// between the two. If the two outer distances have matching signs, the 
	// center distance will never mismatch them.
	wire sign_mismatch, b_between_ac, b_exact, b_closest;
	assign sign_mismatch = dist_up_left[WIDTH - 1] ^ dist_down_right[WIDTH - 1];
	between #(.WIDTH(WIDTH)) in_bounds_checker (in_ax, in_ay, in_bx, in_by, in_cx, in_cy, b_between_ac);
	assign b_exact = (dist_cur == 0);
	
	// Compare distances. If the center point is the closest, we might draw 
	// this pixel.
	wire [WIDTH * 2 - 1:0] abs_dist_cur, abs_dist_up_left, abs_dist_down_right;
	abs #(.WIDTH(WIDTH * 2)) abs_cur (dist_cur, abs_dist_cur);
	abs #(.WIDTH(WIDTH * 2)) abs_ul (dist_up_left, abs_dist_up_left);
	abs #(.WIDTH(WIDTH * 2)) abs_dr (dist_down_right, abs_dist_down_right);
	assign b_closest = (abs_dist_cur < abs_dist_up_left) & (abs_dist_cur <= abs_dist_down_right);
	
	// Check if this point is on a boundary point. Likely redundant, but need 
	// to test.
	wire b_on_a, b_on_c;
	assign b_on_a = (in_bx == in_ax) && (in_by == in_ay);
	assign b_on_c = (in_bx == in_cx) && (in_by == in_cy);
	
	// Choose whether this point is on the line. If in_segment is choosen, the 
	// point will only be drawn if it falls between a and c.
	wire b_on_boundary, b_on_line, b_on_segment;
	assign b_on_boundary = (b_on_a | b_on_c);
	assign b_on_line = b_exact | (sign_mismatch & b_closest);
	assign b_on_segment = (b_on_line & b_between_ac);
	assign out_result = b_on_boundary | (in_segment  ? b_on_segment : b_on_line);

endmodule // on_line_detector

// Checks if point b is between a and c in both x and y
module between #(parameter WIDTH = 5) (in_ax, in_ay, in_bx, in_by, in_cx, in_cy, out_between);
	// Ports
	input [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	output out_between;
	
	// Check if B is between A and C
	wire x_abc, x_cba, y_abc, y_cba;
	assign x_abc = (in_ax <= in_bx) & (in_bx <= in_cx);
	assign x_cba = (in_ax >= in_bx) & (in_bx >= in_cx);
	assign y_abc = (in_ay <= in_by) & (in_by <= in_cy);
	assign y_cba = (in_ay >= in_by) & (in_by >= in_cy);
	
	// Determine output
	assign out_between = (x_abc | x_cba) & (y_abc | y_cba);
	
endmodule  // between

// True if dy > dx, or slope > 1.
module steep_checker #(parameter WIDTH = 5) (in_x0, in_y0, in_x1, in_y1, out_steep);
	// Ports
	input [WIDTH - 1:0] in_x0, in_y0, in_x1, in_y1;
	output out_steep;
	
	// Determine dx, dy
	wire [WIDTH - 1:0] dx, dy;
	abs #(.WIDTH(WIDTH)) abs_x (({1'b0, in_x1} - {1'b0, in_x0}), dx);
	abs #(.WIDTH(WIDTH)) abs_y (({1'b0, in_y1} - {1'b0, in_y0}), dy);
	
	// Determine line steepness
	assign out_steep = dy > dx;

endmodule // steep_checker

// Determines if there is a mix of 0 and 1 in the inputs. Good for two's
// complement sign (MSB) mismatch.
module mismatch (in_signs, out_mismatch);
	// Ports
	input [2:0] in_signs;
	output out_mismatch;
	
	// Check signs
	wire all_0, all_1;
	assign all_0 = ~|in_signs;
	assign all_1 = &in_signs;
	assign out_mismatch = ~(all_0 | all_1);

endmodule // mismatch

// The signed length of the cross product
// (ax - cx) * (cy - by) - (ay - cy) * (cx - bx)
// https://en.wikipedia.org/wiki/Cross_product#Computational_geometry
// Max value = +- ((2^WIDTH) - 1)^2. 5 bits -> Max = +- 961 -> 11 bits
module cross_product_length #(parameter WIDTH = 5) (in_ax, in_ay, in_bx, in_by, in_cx, in_cy, out_length);
	// Ports
	input [WIDTH - 1:0] in_ax, in_ay, in_bx, in_by, in_cx, in_cy;
	output [2 * WIDTH:0] out_length;
	
	// Intermediate difference terms
	wire [WIDTH:0] diff0, diff1, diff2, diff3;
	assign diff0 = {1'b0, in_ax} - {1'b0, in_cx};
	assign diff1 = {1'b0, in_cy} - {1'b0, in_by};
	assign diff2 = {1'b0, in_ay} - {1'b0, in_cy};
	assign diff3 = {1'b0, in_cx} - {1'b0, in_bx};
	
	// Products of differences
	wire [2 * WIDTH:0] product0, product1;
	assign product0 = diff0 * diff1;
	assign product1 = diff2 * diff3;
	
	// Difference of products
	assign out_length = product0 - product1;

endmodule // cross_product_length

// Absolute value. Input is one bit longer than output, assumes one bit of 
// zero padding for positive inputs.
module abs #(parameter WIDTH = 5) (in_signed, out_unsigned);
	// Ports
	input [WIDTH:0] in_signed;
	output [WIDTH - 1:0] out_unsigned;
	
	// Negate if negative
	wire [WIDTH:0] unsigned_result;
	assign unsigned_result = (in_signed[WIDTH] ? -in_signed : in_signed);
	assign out_unsigned = unsigned_result[WIDTH - 1:0];

endmodule // abs