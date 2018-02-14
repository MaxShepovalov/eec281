//4:2 adder

`timescale 1ns/10ps

module adder42(
  input a,
  input b,
  input c,
  input d,
  input ci,
  output co,
  output c1,
  output s
);

wire so; //output from FA1(a,b,c)

fulladder FA1(
  .a (a),
  .b (b),
  .cin (c),
  .cout (co),
  .s (so)
);

fulladder FA2(
  .a (so),
  .b (d),
  .cin (ci),
  .cout (c1),
  .s (s)
);

endmodule
