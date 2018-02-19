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


module booth2 (
    input [2:0] section,
    input [7:0] number,
    output reg [8:0] code,
    output reg invert
    );

    always @(section or number) begin
        case (section)
            3'b000: {code, invert} = 10'b0;
            3'b001: {code, invert} = {number[7], number, 1'b0};
            3'b010: {code, invert} = {number[7], number, 1'b0};
            3'b011: {code, invert} = {number, 2'b0};
            3'b100: {code, invert} = {~number, 2'b11};
            3'b101: {code, invert} = {~number[7], ~number, 1'b1};
            3'b110: {code, invert} = {~number[7], ~number, 1'b1};
            3'b111: {code, invert} = 10'b0;
        endcase
    end

endmodule

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
    wire [8:0] p0,p1,p2,p3; //partial products
    wire [3:0] p4;          //invert bits for PPs
    booth2 B0 (.section ({b_r[1:0], 1'b0}), .number (a_r), .code (p0), .invert (p4[0]));
    booth2 B1 (.section (b_r[3:1]),         .number (a_r), .code (p1), .invert (p4[1]));
    booth2 B2 (.section (b_r[5:3]),         .number (a_r), .code (p2), .invert (p4[2]));
    booth2 B3 (.section (b_r[7:5]),         .number (a_r), .code (p3), .invert (p4[3]));

// stage 2. CSA
    //stage's output
    wire [15:0] st2_p0;
    wire [15:3] st2_p1;
    wire [2:0] st2_p2; //columns 1, 5, 6
    wire [8:0] st2_c; //carry between 4:2 adders

    //pass through
    assign st2_p2[0] = p0[1]; //column 1
    assign st2_p2[2] = p4[3]; //column 6

    //top row
    ha    st2_t_col0  (.a (p0[0]), .b (p4[0]),                                                          .c  (st2_p0[1]),  .s (st2_p0[0]));
    fa    st2_t_col2  (.a (p0[2]), .b (p1[0]), .c (p4[1]),                                           .carry (st2_p0[3]), .sum (st2_p0[2]));
    ha    st2_t_col3  (.a (p0[3]), .b (p1[1]),                                                          .c  (st2_p0[4]),  .s (st2_p1[3]));
    add42 st2_t_col4  (.a (p0[4]), .b (p1[2]), .c (p2[0]), .d (p4[2]), .ci (1'b0),     .cc (st2_p0[5]), .co (st2_p1[5]),  .s (st2_p1[4]));
    fa    st2_t_col5  (.a (p0[5]), .b (p1[3]), .c (p2[1]),                                           .carry (st2_p0[6]),  .s (st2_p2[1]));
    add42 st2_t_col6  (.a (p0[6]), .b (p1[4]), .c (p2[2]), .d (p3[0]), .ci (1'b0),     .cc (st2_c[0]),  .co (st2_p0[7]),  .s (st2_p1[6]));
    add42 st2_t_col7  (.a (p0[7]), .b (p1[5]), .c (p2[3]), .d (p3[1]), .ci (st2_c[0]), .cc (st2_c[1]), .co (st2_p0[8]),  .s (st2_p1[7]));
    add42 st2_t_col8  (.a (p0[8]), .b (p1[6]), .c (p2[4]), .d (p3[2]), .ci (st2_c[1]), .cc (st2_c[2]), .co (st2_p0[9]),  .s (st2_p1[8]));
    add42 st2_t_col9  (.a (p0[8]), .b (p1[7]), .c (p2[5]), .d (p3[3]), .ci (st2_c[2]), .cc (st2_c[3]), .co (st2_p0[10]), .s (st2_p1[9]));
    add42 st2_t_col10 (.a (p0[8]), .b (p1[8]), .c (p2[6]), .d (p3[4]), .ci (st2_c[3]), .cc (st2_c[4]), .co (st2_p0[11]), .s (st2_p1[10]));
    add42 st2_t_col11 (.a (p0[8]), .b (p1[8]), .c (p2[7]), .d (p3[5]), .ci (st2_c[4]), .cc (st2_c[5]), .co (st2_p0[12]), .s (st2_p1[11]));
    add42 st2_t_col12 (.a (p0[8]), .b (p1[8]), .c (p2[8]), .d (p3[6]), .ci (st2_c[5]), .cc (st2_c[6]), .co (st2_p0[13]), .s (st2_p1[12]));
    add42 st2_t_col13 (.a (p0[8]), .b (p1[8]), .c (p2[8]), .d (p3[7]), .ci (st2_c[6]), .cc (st2_c[7]), .co (st2_p0[14]), .s (st2_p1[13]));
    add42 st2_t_col14 (.a (p0[8]), .b (p1[8]), .c (p2[8]), .d (p3[8]), .ci (st2_c[7]), .cc (st2_c[8]), .co (st2_p0[15]), .s (st2_p1[14]));
    add42 st2_t_col15 (.a (p0[8]), .b (p1[8]), .c (p2[8]), .d (p3[8]), .ci (st2_c[8]), .cc (),         .co (),           .s (st2_p1[15]));

// stage 3. CSA cont
    //stage output
    wire [15:0] st3_p0;
    wire [15:6] st3_p1;
    wire [4:2]  st3_p2; //part of st3_p1 at column 4,3,2

    //pass through bits
    assign st3_p0[0] = st2_p0[0];
    assign st3_p0[2] = st2_p0[2];
    assign st3_p0[3] = st2_p0[3];
    assign st3_p0[4] = st2_p0[4];
    assign st3_p2[3] = st2_p1[3];
    assign st3_p2[4] = st2_p1[4];

    ha st_b_col1  (.a (st2_p0[1]), .b (st2_p2[0]),                     .c (st3_p2[2]),   .s (st3_p0[1]));
    fa st_b_col5  (.a (st2_p0[5]), .b (st2_p1[5]), .c (st2_p2[1]), .carry (st3_p0[6]),   .s (st3_p0[5]));
    fa st_b_col6  (.a (st2_p0[6]), .b (st2_p1[6]), .c (st2_p2[2]), .carry (st3_p0[7]), .sum (st3_p1[6]));
    ha st_b_col7  (.a (st2_p0[7]), .b (st2_p1[7]),                     .c (st3_p0[8]),   .s (st3_p1[7]));
    ha st_b_col8  (.a (st2_p0[8]), .b (st2_p1[8]),                     .c (st3_p0[9]),   .s (st3_p1[8]));
    ha st_b_col9  (.a (st2_p0[9]), .b (st2_p1[9]),                     .c (st3_p0[10]),  .s (st3_p1[9]));
    ha st_b_col10  (.a (st2_p0[10]), .b (st2_p1[10]),                  .c (st3_p0[11]),  .s (st3_p1[10]));
    ha st_b_col11  (.a (st2_p0[11]), .b (st2_p1[11]),                  .c (st3_p0[12]),  .s (st3_p1[11]));
    ha st_b_col12  (.a (st2_p0[12]), .b (st2_p1[12]),                  .c (st3_p0[13]),  .s (st3_p1[12]));
    ha st_b_col13  (.a (st2_p0[13]), .b (st2_p1[13]),                  .c (st3_p0[14]),  .s (st3_p1[13]));
    ha st_b_col14  (.a (st2_p0[14]), .b (st2_p1[14]),                  .c (st3_p0[15]),  .s (st3_p1[14]));
    ha st_b_col15  (.a (st2_p0[15]), .b (st2_p1[15]),                  .c (),            .s (st3_p1[15]));

// stage 5. CPA
    reg [15:0] out_c;

    always @(st3_p0 or st3_p1) begin
        out_c = st3_p0 + {st3_p1, 1'b0, st3_p2, 2'b00};
    end

// output clk sync
    always @(posedge clk) begin
        out <= #1 out_c;
    end

endmodule
