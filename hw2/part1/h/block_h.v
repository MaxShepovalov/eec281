//HW2 part 1
// 16-bit x 16bit usigned multiplyer (32-bit output). Use "*" in verilog

module block_h (
    input [15:0] a,
    input [15:0] b,
    output [31:0] out
    );

    assign out = a * b;

endmodule // block_h