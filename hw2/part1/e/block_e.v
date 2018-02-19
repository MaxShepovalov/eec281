//HW2 part 1 e
//An adder which adds 11 5-bit numbers using verilog "+" and produces a 5-bit sum

`timescale 1ns/10ps

module block_e (
    input [4:0] in0,
    input [4:0] in1,
    input [4:0] in2,
    input [4:0] in3,
    input [4:0] in4,
    input [4:0] in5,
    input [4:0] in6,
    input [4:0] in7,
    input [4:0] in8,
    input [4:0] in9,
    input [4:0] in10,
    output [4:0] sum
    );

    assign sum = in0 + in1 + in2 + in3 + in4 +
                 in5 + in6 + in7 + in8 + in9 + in10;

endmodule
