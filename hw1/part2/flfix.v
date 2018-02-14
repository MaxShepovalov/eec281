//float to fixed point converter

`timescale 1ns/10ps

module flfix (
  input [5:0] m,
  input [2:0] e,
  output reg [12:0] fx
);

  always @(m or e)
    casez(e)
      3'b000: fx = {m[5],m[5],m[5],m,4'b0000};
      3'b001: fx = {m[5],m[5],m,5'b00000};
      3'b010: fx = {m[5],m,6'b000000};
      3'b011: fx = {m,7'b0000000};
      3'b100: fx = {m[5],m[5],m[5],m[5],m[5],m[5],m[5],m};
      3'b101: fx = {m[5],m[5],m[5],m[5],m[5],m[5],m,1'b0};
      3'b110: fx = {m[5],m[5],m[5],m[5],m[5],m,2'b00};
      3'b111: fx = {m[5],m[5],m[5],m[5],m,3'b000};
      default: fx = 13'b0000000000000;
    endcase

endmodule
