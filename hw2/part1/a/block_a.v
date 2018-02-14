//HW2 part 1
// bitwise AND of two 10-bit numbers (10-bit output)

`timescale 1ns/10ps

module block_a (
    input [9:0] a,
    input [9:0] b,
    output [9:0] out
    );

    assign out = a & b;

endmodule