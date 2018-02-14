//Full Adder

`timescale 1ns/10ps

module fulladder(
	input a,
	input b,
	input cin,
	output cout,
	output s
);
	wire ci, si, ci2;

	assign ci = a & b; //c_out for HA1
	assign si = a ^ b; //s_out for HA1
	assign ci2 = si & cin; //c_out for HA2
	assign s = si ^ cin;   //s_out for HA2 = output sum for Full Adder
	assign cout = ci | ci2; //carry out for Full Adder

endmodule 
