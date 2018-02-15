//HW2 P2
//

`timescale 1ns/10ps

//add necessary simple adders
module ha (
    input a,
    input b,
    output c,
    output s
    );
    assign s = a ^ b;
    assign c = a & b;
endmodule //ha

module fa (
    input a,
    input b,
    input c,
    output carry,
    output sum
    );
    assign carry = (a & b) | ( (a ^ b) & c);
    assign sum = a ^ b ^ c;
endmodule //fa

module add42(
    input a,
    input b,
    input c,
    input d,
    input ci,
    output co, //carry out
    output cc, //carry to next add42
    output s
    );
    wire s_internal;
    fa abc (.a (a), .b (b), .c (c), .carry(cc), .sum (s_internal));
    fa scc (.a (s_internal), .b (d), .c (ci), .carry(co), .sum (s));
endmodule //add42


//main module
module mult (
    input reg [7:0] a,
    input reg [7:0] b,
    input clk,
    output reg [15:0] out
);

//clk sync
    reg [7:0] a_r, b_r;
    always @(posedge clk) begin
        a_r <= #1 a;
        b_r <= #1 b;
    end

//stage 1. encoding
    //stage's output
    reg [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
    always @(a_r or b_r) begin
        p0 = {~a_r[7],a_r[6:0]} & {b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0]};
        p1 = {~a_r[7],a_r[6:0]} & {b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1]};
        p2 = {~a_r[7],a_r[6:0]} & {b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2]};
        p3 = {~a_r[7],a_r[6:0]} & {b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3]};
        p4 = {~a_r[7],a_r[6:0]} & {b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4]};
        p5 = {~a_r[7],a_r[6:0]} & {b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5]};
        p6 = {~a_r[7],a_r[6:0]} & {b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6]};
        p7 = {~a_r[7],a_r[6:0]} & {b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7]};
    end

//clk sync
    reg [7:0] p0_r,p1_r,p2_r,p3_r,p4_r,p5_r,p6_r,p7_r;
    always @(posedge clk) begin
        p0_r <= #1 p0;
        p1_r <= #1 p1;
        p2_r <= #1 p2;
        p3_r <= #1 p3;
        p4_r <= #1 p4;
        p5_r <= #1 p5;
        p6_r <= #1 p6;
        p7_r <= #1 p7;
    end

//stage 2. CSA
    //stage's output
    reg [14:0] st2_p0;
    reg [14:2] st2_p1;
    reg [11:4] st2_p2;
    reg [10:6] st2_p3;
    reg st2_p4;
    reg [3:0] st2_c1; //carry between top 4:2 adders
    reg [3:0] st2_c2; //carry between bottom 4:2 adders 
    always @(p0_r or p3_r or p7_r or p4_r) //pass through bits
        st2_p0[0] = p0_r[0];
        st2_p2[10] = p3_r[7];
        st2_p1[14] = p7_r[7];
        st2_p2[4] = p4_r[0];
    //top row
    ha st2_ha11 (.a (p0_r[1]), .b (p1_r[0]), .c(st2_p0[2]), .s(st2_p0[1]));
    fa st2_fa11 (.a (p0_r[2]), .b (p1_r[1]), .c (p2_r[0]), .carry (st2_p0[3]), .sum (st2_p1[2]));
    add42 st2_a11 (.a (p0_r[3]), .b (p1_r[2]), .c (p2_r[1]), .d (p3_r[0]), .ci (1'b0), .cc (st2_c1[0]), .co (st2_p0[4]), .s (st2_p1[3]));
    add42 st2_a12 (.a (p0_r[4]), .b (p1_r[3]), .c (p2_r[2]), .d (p3_r[1]), .ci (st2_c1[0]), .cc (st2_c1[1]), .co (st2_p0[5]), .s (st2_p1[4]));
    add42 st2_a13 (.a (p0_r[5]), .b (p1_r[4]), .c (p2_r[3]), .d (p3_r[2]), .ci (st2_c1[1]), .cc (st2_c1[2]), .co (st2_p0[6]), .s (st2_p1[5]));
    add42 st2_a14 (.a (p0_r[6]), .b (p1_r[5]), .c (p2_r[4]), .d (p3_r[3]), .ci (st2_c1[2]), .cc (st2_c1[3]), .co (st2_p0[7]), .s (st2_p1[6]));
    add42 st2_a15 (.a (p0_r[7]), .b (p1_r[6]), .c (p2_r[5]), .d (p3_r[4]), .ci (st2_c1[3]), .cc (st2_p1[8]), .co (st2_p0[8]), .s (st2_p1[7]));
    fa st2_fa12 (.a (p1_r[7]), .b (p2_r[6]), .c (p3_r[5]), .carry (st2_p0[9]), .sum (st2_p2[8]));
    ha st2_ha12 (.a (p2_r[7]), .b (p3_r[6]), .c (st2_p0[10]), .s (st2_p1[9]));
    //bottom row
    ha st2_ha21 (.a (p4_r[1]), .b (p5_r[0]), .c (st2_p2[6]), .s (st2_p2[5]));
    fa st2_fa21 (.a (p4_r[2]), .b (p5_r[1]), .c (p6_r[0]), .carry (st2_p2[7]), .sum (st2_p3[6]));
    add42 st2_a21 (.a (p4_r[3]), .b (p5_r[2]), .c (p6_r[1]), .d (p7_r[0]), .ci (1'b0), .cc (st2_c2[0]), .co (st2_p3[8]), .s (st2_p3[7]));
    add42 st2_a22 (.a (p4_r[4]), .b (p5_r[3]), .c (p6_r[2]), .d (p7_r[1]), .ci (st2_c2[0]), .cc (st2_c2[1]), .co (st2_p3[9]), .s (st2_p4));
    add42 st2_a23 (.a (p4_r[5]), .b (p5_r[4]), .c (p6_r[3]), .d (p7_r[2]), .ci (st2_c2[1]), .cc (st2_c2[2]), .co (st2_p1[10]), .s (st2_p2[9]));
    add42 st2_a24 (.a (p4_r[6]), .b (p5_r[5]), .c (p6_r[4]), .d (p7_r[3]), .ci (st2_c2[2]), .cc (st2_c2[3]), .co (st2_p0[11]), .s (st2_p3[10]));
    add42 st2_a25 (.a (p4_r[7]), .b (p5_r[6]), .c (p6_r[5]), .d (p7_r[4]), .ci (st2_c2[3]), .cc (st2_p0[12]), .co (st2_p1[12]), .s (st2_p1[11]));
    fa st2_fa22 (.a (p5_r[7]), .b (p6_r[6]), .c (p7_r[5]), .carry (st2_p0[13]), .sum (st2_p2[11]));
    ha st2_ha22 (.a (p6_r[7]), .b (p7_r[6]), .c (st2_p0[14]), .s (st2_p1[13]));

//clk sync
    reg [14:0] st2_p0_r;
    reg [14:2] st2_p1_r;
    reg [11:4] st2_p2_r;
    reg [10:6] st2_p3_r;
    reg st2_p4_r;
    always @(posedge clk) begin
        st2_p0_r <= #1 st2_p0;
        st2_p1_r <= #1 st2_p1;
        st2_p2_r <= #1 st2_p2;
        st2_p3_r <= #1 st2_p3;
        st2_p4_r <= #1 st2_p4;
    end

//stage 3. CSA cont
    //stage output
    reg [15:0] st3_p0; //row 0
    reg [14:3] st3_p1; //row 1
    reg [1:0] st3_p2;  //row 2 column 11 and 8
    reg [3:0] st3_c;  //carry between 4:2 adders

    //pass through bits
    always @(st2_p0_r or st2_p4_r) begin
        st3_p0[1:0] = st2_p0_r[1:0];
        st3_p2[0] = st2_p4_r;
    end

    ha st3_ha1   (.a (st2_p0_r[2]),  .b (st2_p1_r[2]),  .c (st3_p0[3]), .s (st3_p0[2]));
    ha st3_ha2   (.a (st2_p0_r[3]),  .b (st2_p1_r[3]),  .c (st3_p0[4]), .s (st3_p1[3]));
    fa st3_fa1   (.a (st2_p0_r[4]),  .b (st2_p1_r[4]),  .c (st2_p2_r[4]), .carry (st3_p0[5]), .sum (st3_p1[4]));
    fa st3_fa2   (.a (st2_p0_r[5]),  .b (st2_p1_r[5]),  .c (st2_p2_r[5]), .carry (st3_p0[6]), .sum (st3_p1[5]));
    add42 st3_a1 (.a (st2_p0_r[6]),  .b (st2_p1_r[6]),  .c (st2_p2_r[6]),  .d (st2_p3_r[6]),  .ci (1'b0),     .cc (st3_c[0]), .co (st3_p0[7]), .s (st3_p1[6]));
    add42 st3_a2 (.a (st2_p0_r[7]),  .b (st2_p1_r[7]),  .c (st2_p2_r[7]),  .d (st2_p3_r[7]),  .ci (st3_c[0]), .cc (st3_c[1]), .co (st3_p0[8]), .s (st3_p1[7]));
    add42 st3_a3 (.a (st2_p0_r[8]),  .b (st2_p1_r[8]),  .c (st2_p2_r[8]),  .d (st2_p3_r[8]),  .ci (st3_c[1]), .cc (st3_c[2]), .co (st3_p0[9]), .s (st3_p1[8]));
    add42 st3_a4 (.a (st2_p0_r[9]),  .b (st2_p1_r[9]),  .c (st2_p2_r[9]),  .d (st2_p3_r[9]),  .ci (st3_c[2]), .cc (st3_c[3]), .co (st3_p0[10]), .s (st3_p1[9]));
    add42 st3_a5 (.a (st2_p0_r[10]), .b (st2_p1_r[10]), .c (st2_p2_r[10]), .d (st2_p3_r[10]), .ci (st3_c[3]), .cc (st3_p1[11]), .co (st3_p0[11]), .s (st3_p1[10]));
    ha st3_ha3   (.a (st2_p0_r[11]), .b (st2_p1_r[11]), .c (st3_p0[12]), .s (st3_p3[1]));
    fa st3_fa3   (.a (st2_p0_r[12]), .b (st2_p1_r[12]), .c (st2_p2_r[11]), .carry (st3_p0[13]), .sum (st3_p1[12]));
    ha st3_ha4   (.a (st2_p0_r[13]), .b (st2_p1_r[13]), .c (st3_p0[14]), .s (st3_p1[13]));
    ha st3_ha5   (.a (st2_p0_r[14]), .b (st2_p1_r[14]), .c (st3_p0[15]), .s (st3_p1[14]));

//clk sync
    reg [15:0] st3_p0_r;
    reg [14:3] st3_p1_r;
    reg [1:0] st3_p2_r;
    always @(posedge clk) begin
        st3_p0_r <= #1 st3_p0;
        st3_p1_r <= #1 st3_p1;
        st3_p2_r <= #1 st3_p2;
    end

//stage 4. CSA end
    reg [15:0] st4_p0;
    reg [15:3] st4_p1;

    //pass though bits and add constant
    always @() begin
        st4_p0[7:0] = st3_p0_r[7:0];
        st4_p1[7:3] = st3_p1_r[7:3];
        //add constant
        st4_p1[8] = 1'b1;
        //add constant (to cut half adder)
        st4_p1[15] = ~st3_p0[15];
    end

    fa st4_fa1 (.a (st3_p0_r[8]), .b (st3_p1_r[8]), .c (st3_p2_r[0]), .carry (st4_p0[9]), .sum (st4_p0[8]));
    ha st4_ha1 (.a (st3_p0_r[9]), .b (st3_p1_r[9]), .c (st4_p0[10]), .s (st4_p1[9]));
    ha st4_ha2 (.a (st3_p0_r[10]), .b (st3_p1_r[10]), .c (st4_p0[11]), .s (st4_p1[10]));
    fa st4_fa2 (.a (st3_p0_r[11]), .b (st3_p1_r[11]), .c (st3_p2_r[1]), .carry (st4_p0[12]), .sum (st4_p1[11]));
    ha st4_ha3 (.a (st3_p0_r[12]), .b (st3_p1_r[12]), .c (st4_p0[13]), .s (st4_p1[12]));
    ha st4_ha4 (.a (st3_p0_r[13]), .b (st3_p1_r[13]), .c (st4_p0[14]), .s (st4_p1[13]));
    ha st4_ha5 (.a (st3_p0_r[14]), .b (st3_p1_r[14]), .c (st4_p0[15]), .s (st4_p1[14]));

//clk sync
    reg [15:0] st4_p0_r;
    reg [15:3] st4_p1_r;
    always @(posedge clk) begin
        st4_p0_r <= #1 st4_p0;
        st4_p0_r <= #1 st4_p1;
    end

//stage 5. CPA
    always @(st4_p0_r or st4_p1_r) begin
        out = st4_p0_r + {st4_p1_r, 2'b00};
    end

endmodule
