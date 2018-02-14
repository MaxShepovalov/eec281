`timescale 1ns/10ps

module fulladder(
	input a,
	input b,
	input cin,
	output cout,
	output s
);
	wire ci, si, ci2;
	halfadder ha1(
		.a (a),
		.b (b),
		.c (ci),
		.s (si)
	);
	halfadder ha2(
		.a (si),
		.b (cin),
		.c (ci2),
		.s (s)
	);

	//always @(ci or ci2)
	assign cout = ci | ci2;
endmodule 
