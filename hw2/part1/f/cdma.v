//adder for 11 single-bit numbers

`timescale 1ns/10ps


///////////////////////////////////////////////

module fulladder(
    input a,
    input b,
    input cin,
    output cout,
    output s
);

    wire ci, si, ci2;
    
    assign ci = a & b;
    assign si = a ^ b;
    assign ci2 = si & cin;
    assign s = si ^ cin;
    assign cout = ci | ci2;

endmodule

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

    wire so;
    fulladder FA1(.a (a),.b (b),.cin (c),.cout (co),.s (so));
    fulladder FA2(.a (so),.b (d),.cin (ci),.cout (c1),.s (s));

endmodule

///////////////////////////////////////////////

module cdma (
  input [10:0] num,
  output reg [4:0] out
);

wire GND; //ground pin
assign GND = 1'b0;

//STAGE 1
  wire [1:0] st11, st12, st13, st14; //stage output
  fulladder FA11 (
    .a (num[0]),
    .b (num[1]),
    .cin (num[2]),
    .cout (st11[1]),
    .s (st11[0])
  );
  fulladder FA12 (
    .a (num[3]),
    .b (num[4]),
    .cin (num[5]),
    .cout (st12[1]),
    .s (st12[0])
  );
  fulladder FA13 (
    .a (num[6]),
    .b (num[7]),
    .cin (num[8]),
    .cout (st13[1]),
    .s (st13[0])
  );
  //half adder
  assign st14 = {num[9] & num[10], num[9] ^ num[10]};

//STAGE 2
  wire [2:0] st21;
  wire [1:0] st22; //stage output
  wire co; //carry between 4:2 adders
  adder42 A21 (
    .a (st11[0]),
    .b (st12[0]),
    .c (st13[0]),
    .d (st14[0]),
    .ci (GND),
    .co (co),
    .c1 (st21[1]),
    .s (st21[0])
  );
  adder42 A22 (
    .a (st11[1]),
    .b (st12[1]),
    .c (st13[1]),
    .d (st14[1]),
    .ci (co),
    .co (st21[2]),
    .c1 (st22[1]),
    .s (st22[0])
  );

//STAGE 3 and 4
  reg [3:0] st3;
  always @(st21 or st22) begin
    st3 = st21 + {st22,1'b0};
//    out = 5'b10101 + {st3, 1'b0};
    case (st3)
      4'b0000: out = 5'b10101; //0  -11
      4'b0001: out = 5'b10111; //1  -9
      4'b0010: out = 5'b11001; //2  -7
      4'b0011: out = 5'b11011; //3  -5
      4'b0100: out = 5'b11101; //4  -3
      4'b0101: out = 5'b11111; //5  -1
      4'b0110: out = 5'b00001; //6  +1
      4'b0111: out = 5'b00011; //7  +3
      4'b1000: out = 5'b00101; //8  +5
      4'b1001: out = 5'b00111; //9  +7
      4'b1010: out = 5'b01001; //10 +9
      4'b1011: out = 5'b01011; //11 +11
      default: out = 5'b00000; //def 0
    endcase
  end

endmodule
