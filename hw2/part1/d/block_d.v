//HW2 part 1
//10-bit adder (11-bit output). Use "+" in verilog

`timescale 1ns/10ps

module block_d (
    input [9:0] a,
    input [9:0] b,
    output [10:0] sum
    );

    assign sum = a + b;

endmodule