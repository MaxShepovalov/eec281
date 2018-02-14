//HW2 part 1
//An adder which adds 29 6-bit numbers using verilog "+" and produces a 6-bit sum

`timescale 1ns/10ps

module block_e (
    input [5:0] in0,
    input [5:0] in1,
    input [5:0] in2,
    input [5:0] in3,
    input [5:0] in4,
    input [5:0] in5,
    input [5:0] in6,
    input [5:0] in7,
    input [5:0] in8,
    input [5:0] in9,
    input [5:0] in10,
    input [5:0] in11,
    input [5:0] in12,
    input [5:0] in13,
    input [5:0] in14,
    input [5:0] in15,
    input [5:0] in16,
    input [5:0] in17,
    input [5:0] in18,
    input [5:0] in19,
    input [5:0] in20,
    input [5:0] in21,
    input [5:0] in22,
    input [5:0] in23,
    input [5:0] in24,
    input [5:0] in25,
    input [5:0] in26,
    input [5:0] in27,
    input [5:0] in28,
    output [5:0] sum
    );

    assign sum = in0 + in1 + in2 + in3 + in4 +
                 in5 + in6 + in7 + in8 + in9 +
                 in10 + in11 + in12 + in13 + in14 +
                 in15 + in16 + in17 + in18 + in19 +
                 in20 + in21 + in22 + in23 + in24 +
                 in25 + in26 + in27 + in28;

endmodule