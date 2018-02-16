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

////////////////////////////////////////////////////////////////////////////////
//main module
module mult (
    input [7:0] a,
    input [7:0] b,
    input clk,
    output reg [15:0] out
);

// input clk sync
    reg [7:0] a_r, b_r;
    always @(posedge clk) begin
        a_r <= #1 a;
        b_r <= #1 b;
    end

// stage 1. encoding
    //stage's output
    wire [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
    //always @(a_r or b_r) begin
    assign p0 = a_r & {b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0], b_r[0]};
    assign p1 = a_r & {b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1], b_r[1]};
    assign p2 = a_r & {b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2], b_r[2]};
    assign p3 = a_r & {b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3], b_r[3]};
    assign p4 = a_r & {b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4], b_r[4]};
    assign p5 = a_r & {b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5], b_r[5]};
    assign p6 = a_r & {b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6], b_r[6]};
    assign p7 = a_r & {b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7], b_r[7]};
    //end

// stage 2. CSA
    //stage's output
    wire [11:0] st2_p0;
    wire [12:2] st2_p1;
    wire [15:4] st2_p2;
    wire [15:6] st2_p3;
    wire [7:0] st2_c1; //carry between top 4:2 adders
    wire [7:0] st2_c2; //carry between bottom 4:2 adders 

    assign st2_p0[0] = p0[0];
    assign st2_p2[4] = p4[0];

    //top row
    ha    st2_t_col1  (.a (p0[1]), .b (p1[0]),                                                           .c  (st2_p1[2]),  .s (st2_p0[1]));
    fa    st2_t_col2  (.a (p0[2]), .b (p1[1]), .c (p2[0]),                                            .carry (st2_p1[3]), .sum (st2_p0[2]));
    add42 st2_t_col3  (.a (p0[3]), .b (p1[2]), .c (p2[1]), .d (p3[0]), .ci (1'b0),      .cc (st2_c1[0]), .co (st2_p1[4]),  .s (st2_p0[3]));
    add42 st2_t_col4  (.a (p0[4]), .b (p1[3]), .c (p2[2]), .d (p3[1]), .ci (st2_c1[0]), .cc (st2_c1[1]), .co (st2_p1[5]),  .s (st2_p0[4]));
    add42 st2_t_col5  (.a (p0[5]), .b (p1[4]), .c (p2[3]), .d (p3[2]), .ci (st2_c1[1]), .cc (st2_c1[2]), .co (st2_p1[6]),  .s (st2_p0[5]));
    add42 st2_t_col6  (.a (p0[6]), .b (p1[5]), .c (p2[4]), .d (p3[3]), .ci (st2_c1[2]), .cc (st2_c1[3]), .co (st2_p1[7]),  .s (st2_p0[6]));
    add42 st2_t_col7  (.a (p0[7]), .b (p1[6]), .c (p2[5]), .d (p3[4]), .ci (st2_c1[3]), .cc (st2_c1[4]), .co (st2_p1[8]),  .s (st2_p0[7]));
    add42 st2_t_col8  (.a (p0[7]), .b (p1[7]), .c (p2[6]), .d (p3[5]), .ci (st2_c1[4]), .cc (st2_c1[5]), .co (st2_p1[9]),  .s (st2_p0[8]));
    add42 st2_t_col9  (.a (p0[7]), .b (p1[7]), .c (p2[7]), .d (p3[6]), .ci (st2_c1[5]), .cc (st2_c1[6]), .co (st2_p1[10]), .s (st2_p0[9]));
    add42 st2_t_col10 (.a (p0[7]), .b (p1[7]), .c (p2[7]), .d (p3[7]), .ci (st2_c1[6]), .cc (st2_c1[7]), .co (st2_p1[11]), .s (st2_p0[10]));
    add42 st2_t_col11 (.a (p0[7]), .b (p1[7]), .c (p2[7]), .d (p3[7]), .ci (st2_c1[7]), .cc (),          .co (st2_p1[12]), .s (st2_p0[11]));

    //bottom row
    ha st2_b_col5     (.a (p4[1]), .b (p5[0]),                                                           .c  (st2_p3[6]),  .s (st2_p2[5]));
    fa st2_b_col6     (.a (p4[2]), .b (p5[1]), .c (p6[0]),                                            .carry (st2_p3[7]), .sum (st2_p2[6]));
    add42 st2_b_col7  (.a (p4[3]), .b (p5[2]), .c (p6[1]), .d (p7[0]), .ci (1'b0),      .cc (st2_c2[0]), .co (st2_p3[8]),  .s (st2_p2[7]));
    add42 st2_b_col8  (.a (p4[4]), .b (p5[3]), .c (p6[2]), .d (p7[1]), .ci (st2_c2[0]), .cc (st2_c2[1]), .co (st2_p3[9]),  .s (st2_p2[8]));
    add42 st2_b_col9  (.a (p4[5]), .b (p5[4]), .c (p6[3]), .d (p7[2]), .ci (st2_c2[1]), .cc (st2_c2[2]), .co (st2_p3[10]), .s (st2_p2[9]));
    add42 st2_b_col10 (.a (p4[6]), .b (p5[5]), .c (p6[4]), .d (p7[3]), .ci (st2_c2[2]), .cc (st2_c2[3]), .co (st2_p3[11]), .s (st2_p2[10]));
    add42 st2_b_col11 (.a (p4[7]), .b (p5[6]), .c (p6[5]), .d (p7[4]), .ci (st2_c2[3]), .cc (st2_c2[4]), .co (st2_p3[12]), .s (st2_p2[11]));
    add42 st2_b_col12 (.a (p4[7]), .b (p5[7]), .c (p6[6]), .d (p7[5]), .ci (st2_c2[4]), .cc (st2_c2[5]), .co (st2_p3[13]), .s (st2_p2[12]));
    add42 st2_b_col13 (.a (p4[7]), .b (p5[7]), .c (p6[7]), .d (p7[6]), .ci (st2_c2[5]), .cc (st2_c2[6]), .co (st2_p3[14]), .s (st2_p2[13]));
    add42 st2_b_col14 (.a (p4[7]), .b (p5[7]), .c (p6[7]), .d (p7[7]), .ci (st2_c2[6]), .cc (st2_c2[7]), .co (st2_p3[15]), .s (st2_p2[14]));
    add42 st2_b_col15 (.a (p4[7]), .b (p5[7]), .c (p6[7]), .d (p7[7]), .ci (st2_c2[7]), .cc (),          .co (),           .s (st2_p2[15]));

// stage 3. CSA cont
    //stage output
    wire [15:0] st3_p0; //row 0
    wire [15:3] st3_p1; //row 1
    wire [8:0] st3_c;  //carry between 4:2 adders

    //pass through bits
    assign st3_p0[1:0] = st2_p0[1:0];

    ha st_b_col2     (.a (st2_p0[2]),  .b (st2_p1[2]),                                                                    .c  (st3_p1[3]),  .s (st3_p0[2]));
    ha st_b_col3     (.a (st2_p0[3]),  .b (st2_p1[3]),                                                                    .c  (st3_p1[4]),  .s (st3_p0[3]));
    fa st_b_col4     (.a (st2_p0[4]),  .b (st2_p1[4]),  .c (st2_p2[4]),                                                .carry (st3_p1[5]), .sum (st3_p0[4]));
    fa st_b_col5     (.a (st2_p0[5]),  .b (st2_p1[5]),  .c (st2_p2[5]),                                                .carry (st3_p1[6]), .sum (st3_p0[5]));
    add42 st_b_col6  (.a (st2_p0[6]),  .b (st2_p1[6]),  .c (st2_p2[6]),  .d (st2_p3[6]),  .ci (1'b0),     .cc (st3_c[0]), .co (st3_p1[7]),  .s (st3_p0[6]));
    add42 st_b_col7  (.a (st2_p0[7]),  .b (st2_p1[7]),  .c (st2_p2[7]),  .d (st2_p3[7]),  .ci (st3_c[0]), .cc (st3_c[1]), .co (st3_p1[8]),  .s (st3_p0[7]));
    add42 st_b_col8  (.a (st2_p0[8]),  .b (st2_p1[8]),  .c (st2_p2[8]),  .d (st2_p3[8]),  .ci (st3_c[1]), .cc (st3_c[2]), .co (st3_p1[9]),  .s (st3_p0[8]));
    add42 st_b_col9  (.a (st2_p0[9]),  .b (st2_p1[9]),  .c (st2_p2[9]),  .d (st2_p3[9]),  .ci (st3_c[2]), .cc (st3_c[3]), .co (st3_p1[10]), .s (st3_p0[9]));
    add42 st_b_col10 (.a (st2_p0[10]), .b (st2_p1[10]), .c (st2_p2[10]), .d (st2_p3[10]), .ci (st3_c[3]), .cc (st3_c[4]), .co (st3_p1[11]), .s (st3_p0[10]));
    add42 st_b_col11 (.a (st2_p0[11]), .b (st2_p1[11]), .c (st2_p2[11]), .d (st2_p3[11]), .ci (st3_c[4]), .cc (st3_c[5]), .co (st3_p1[12]), .s (st3_p0[11]));
    add42 st_b_col12 (.a (st2_p0[11]), .b (st2_p1[12]), .c (st2_p2[12]), .d (st2_p3[12]), .ci (st3_c[5]), .cc (st3_c[6]), .co (st3_p1[13]), .s (st3_p0[12]));
    add42 st_b_col13 (.a (st2_p0[11]), .b (st2_p1[12]), .c (st2_p2[13]), .d (st2_p3[13]), .ci (st3_c[6]), .cc (st3_c[7]), .co (st3_p1[14]), .s (st3_p0[13]));
    add42 st_b_col14 (.a (st2_p0[11]), .b (st2_p1[12]), .c (st2_p2[14]), .d (st2_p3[14]), .ci (st3_c[7]), .cc (st3_c[8]), .co (st3_p1[15]), .s (st3_p0[14]));
    add42 st_b_col15 (.a (st2_p0[11]), .b (st2_p1[12]), .c (st2_p2[15]), .d (st2_p3[15]), .ci (st3_c[8]), .cc (),         .co (),           .s (st3_p0[15]));

// stage 5. CPA
    reg [15:0] out_c;

    always @(st3_p0 or st3_p1) begin
        out_c = st3_p0 + {st3_p1, 3'b000};
    end

// output clk sync
    always @(posedge clk) begin
        out <= #1 out_c;
    end

endmodule
