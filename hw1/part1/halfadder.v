//Half Adder

`timescale 1ns/10ps

module halfadder(
	input a,
	input b,
	output reg c,
	output reg s
);
	always @(a or b) begin
		s = a ^ b;
		c = a & b;
	end
endmodule
