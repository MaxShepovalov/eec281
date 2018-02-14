//HW2 part 1
// 8-bit x 8-bit usigned multiplyer (16-bit output). Use "*" in verilog

module block_g (
    input [7:0] a,
    input [7:0] b,
    output [15:0] out
    );

    assign out = a * b;

endmodule // block_g