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
    output reg [15:0] i,
    output reg ready
);

parameter IDLE = 2'b00;
parameter COS = 2'b01;
parameter SIN = 2'b10;

reg [1:0] mode = IDLE, mode_c = IDLE;
reg [11:0] angle_mem = 12'b0000_0000_0000;
reg [15:0] r_c = 16'b0000_0000_0000_0000, i_c = 16'b0000_0000_0000_0000;
wire [15:0] cos_val;// = 16'b0000_0000_0000_0000;
reg ready_c = 1'b0, cos_en = 1'b0;

cos cos_mem (.angle (angle), .cos_en(cos_en), .result(cos_val));

//State Machine
always @(angle or start or mode) begin
    mode_c = mode;
    case(mode)
        IDLE: begin
            if (start == 1'b1) begin
                ready_c = 1'b0;
                mode_c = COS;
                cos_en = 1'b1;
                angle_mem = angle;
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
            ready_c = 1'b1;
        end
        default: begin
            mode_c = IDLE;
        end
    endcase
end

//Mode FFlop
always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
        mode <= #1 IDLE;
    end else begin
        mode <= #1 mode_c;
    end
end

//output FFlop
always @(posedge clk or posedge reset) begin
    if (reset == 1'b1 || ready_c == 1'b0) begin
        r <= #1 16'b0000_0000_0000_0000;
        i <= #1 16'b0000_0000_0000_0000;
        ready <= #1 1'b0;
    end else begin
        r <= #1 r_c;
        i <= #1 i_c;
        ready <= #1 1'b1;
    end
end

endmodule