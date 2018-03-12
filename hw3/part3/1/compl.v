/*
Top level for complex number generator
*/

`timescale 1ns/10ps

module compl(
    input [11:0] angle,
    input start,
    input clk,
    input reset,
    output reg [15:0] r,
    output reg [15:0] i
);

parameter IDLE = 2'b00;
parameter COS = 2'b01;
parameter SIN = 2'b10;

reg [1:0] mode, mode_c;
reg [11:0] angle_mem, angle_r;
reg [15:0] r_c, i_c;
wire [15:0] cos_val;
reg cos_en, start_r;

initial begin
    mode = IDLE;
    mode_c = IDLE;
    angle_mem = 12'b0000_0000_0000;
    angle_r = 12'b0000_0000_0000;
    r_c = 16'b0000_0000_0000_0000;
    i_c = 16'b0000_0000_0000_0000;
    cos_en = 1'b0;
    start_r = 1'b0;
end

cos cos_mem (.angle (angle_r), .cos_en(cos_en), .result(cos_val));

//State Machine
always @(angle_r or start_r or mode) begin
    mode_c = mode;
    case(mode)
        IDLE: begin
            if (start_r == 1'b1) begin
                mode_c = COS;
                cos_en = 1'b1;
                angle_mem = angle_r;
            end
        end
        COS: begin
            r_c = cos_val;
            mode_c = SIN;
            cos_en = 1'b0;
        end
        SIN: begin
            i_c = cos_val;
            mode_c = IDLE;
        end
        default: begin
            mode_c = IDLE;
        end
    endcase
end

//output FFlop
always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
        r <= #1 16'b0000_0000_0000_0000;
        i <= #1 16'b0000_0000_0000_0000;
        mode <= #1 IDLE;
        angle_r = 12'b0000_0000_0000;
        start_r = 1'b0;
    end else begin
        r <= #1 r_c;
        i <= #1 i_c;
        mode <= #1 mode_c;
        angle_r <= #1 angle;
        start_r <= #1 start;
    end
end

endmodule