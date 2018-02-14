//HW2 part 1
//3:2 adder using verilog "+"

`timescale 1ns/10ps

module block_c (
    input a,
    input b,
    input c,
    output carry,
    output sum
    );

    assign {carry, sum} = a + b + c;

endmodule