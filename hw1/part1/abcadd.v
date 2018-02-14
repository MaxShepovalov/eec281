//Adder for 3 5-bit numbers
//A - 2's complement 2.3 format
//B - 2's complement 4.1 format
//C - unsigned 5.0 format

`timescale 1ns/10ps

module abcadd(
	input [4:0] a,   //2's comp 2.3
	input [4:0] b,   //2's comp 4.1
	input [4:0] c,   //unsigned 5.0
	output reg [9:0] out
);

wire [9:0] sum1,sum2; //carry-save output

//FIRST STAGE

fulladder FA3 (
	.a (a[3]),
	.b (b[1]),
	.cin (c[0]),
	.cout (sum1[4]),
	.s (sum1[3])
);

fulladder FA4 (
	.a (a[4]),
	.b (b[2]),
	.cin (c[1]),
	.cout (sum2[5]),
	.s (sum2[4])
);

fulladder FA5 (
	.a (a[4]),
	.b (b[3]),
	.cin (c[2]),
	.cout (sum1[6]),
	.s (sum1[5])
);

fulladder FA6 (
	.a (a[4]),
	.b (b[4]),
	.cin (c[3]),
	.cout (sum2[7]),
	.s (sum2[6])
);

fulladder FA7 (
	.a (a[4]),
	.b (b[4]),
	.cin (c[4]),
	.cout (sum1[8]),
	.s (sum1[7])
);

halfadder HA8 (
	.a (a[4]),
	.b (b[4]),
	.c (sum2[9]),
	.s (sum2[8])
);

assign sum1[2:0] = a[2:0];
assign sum2[3:0] = {1'b0, b[0], 2'b00};
assign sum1[9] = a[4] ^ b[4];

//SECOND STAGE

always @(sum1 or sum2)
	out = sum1 + sum2;

endmodule
