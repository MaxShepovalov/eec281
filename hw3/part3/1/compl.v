/*
Top level for complex number generator
          |                        |                        |
          | CM_angle     CM_result |     r_1                |     r
angle  #-[V]--------[cos]---------[V]----------------------[V]------
-------#  |                        |                        |
       |  | angle_r      sin_angle | CM_angle     CM_result |     i
       #-[V]--------[   ]---------[V]--------[cos]---------[V]------
          |         [ - ]          |                        |
          |    90 --[   ]          |                        |
          |                        |                        |

*/
`timescale 1ns/10ps

module compl(
    input angle,
    input clk,
    output r,
    output i
);

//input/output
wire [11:0] angle;
reg [11:0] sin_angle, angle_r;
reg [15:0] r, r_1, i;

//cos module
reg [11:0] CM_angle;
wire [15:0] CM_result;
cos cos_mem (.angle (CM_angle), .result (CM_result));

always @(posedge clk) begin
    CM_angle <= #1 angle;
    angle_r <= #1 angle;
end

//stage 1. real [cos()] and sin_angle
always @(angle_r) begin
    // sin(a) = cos(90 - a)
    sin_angle = 12'b010000000000 - angle_r;
end

//stage 2. imag [sin()]
always @(posedge clk) begin
    CM_angle <= #1 sin_angle;
    r_1 <= #1 CM_result;
end

//output result
always @(posedge clk) begin
    r <= #1 r_1;
    i <= #1 CM_result;
end

endmodule;