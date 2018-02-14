//six-input adder

`timescale 1ns/10ps

module add6 (
  input [3:0] a,
  input [3:0] b,
  input [3:0] c,
  input [3:0] d,
  input [3:0] e,
  input [3:0] f,
  output reg [5:0] out
);

  //STAGE 1
  wire [3:0] st11, st12, st13, st14;

  fulladder FA1 (
    .a (a[0]),
    .b (b[0]),
    .cin (c[0]),
    .cout (st11[1]),
    .s (st11[0])
  );
  fulladder FA2 (
    .a (a[1]),
    .b (b[1]),
    .cin (c[1]),
    .cout (st13[1]),
    .s (st13[0])
  );
  fulladder FA3 (
    .a (a[2]),
    .b (b[2]),
    .cin (c[2]),
    .cout (st11[3]),
    .s (st11[2])
  );
  fulladder FA4 (
    .a (a[3]),
    .b (b[3]),
    .cin (c[3]),
    .cout (st13[3]),
    .s (st13[2])
  );
  fulladder FA5 (
    .a (d[0]),
    .b (e[0]),
    .cin (f[0]),
    .cout (st12[1]),
    .s (st12[0])
  );
  fulladder FA6 (
    .a (d[1]),
    .b (e[1]),
    .cin (f[1]),
    .cout (st14[1]),
    .s (st14[0])
  );
  fulladder FA7 (
    .a (d[2]),
    .b (e[2]),
    .cin (f[2]),
    .cout (st12[3]),
    .s (st12[2])
  );
  fulladder FA8 (
    .a (d[3]),
    .b (e[3]),
    .cin (f[3]),
    .cout (st14[3]),
    .s (st14[2])
  );

//STAGE 2
  wire [3:0] co; //carry between 4:2 adders
  wire [5:0] sm1; // stage 2 output
  wire [4:0] sm2; // stage 2 output
 
  halfadder HA1 (
    .a (st11[0]),
    .b (st12[0]),
    .c (sm1[1]),
    .s (sm1[0])
  );
  adder42 A1 (
    .a  (st11[1]),
    .b  (st12[1]),
    .c  (st13[0]),
    .d  (st14[0]),
    .ci (1'b0), //disconnect
    .co (co[0]),
    .c1 (sm2[1]),
    .s  (sm2[0])
  );
  adder42 A2 (
    .a  (st11[2]),
    .b  (st12[2]),
    .c  (st13[1]),
    .d  (st14[1]),
    .ci (co[0]),
    .co (co[1]),
    .c1 (sm1[3]),
    .s  (sm1[2])
  );
  adder42 A3 (
    .a  (st11[3]),
    .b  (st12[3]),
    .c  (st13[2]),
    .d  (st14[2]),
    .ci (co[1]),
    .co (co[2]),
    .c1 (sm2[3]),
    .s  (sm2[2])
  );
  adder42 A4 (
    .a  (st13[2]),
    .b  (st14[2]),
    .c  (st13[3]),
    .d  (st14[3]),
    .ci (co[2]),
    .co (co[3]),
    .c1 (sm1[5]),
    .s  (sm1[4])
  );
  adder42 A5 (
    .a  (st13[3]),
    .b  (st14[3]),
    .c  (st13[2]),
    .d  (st14[2]),
    .ci (co[3]),
    .co (),
    .c1 (),
    .s  (sm2[4])
  );

//STAGE 3
  always @(sm1 or sm2)
    out = sm1 + {sm2, 1'b0};

endmodule
