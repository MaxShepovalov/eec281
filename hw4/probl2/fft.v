//FFT butterfly
//X = A + B
//Y = (A - B) * W

/*

           a[0]           a[1]       a[2]     a[3]
                      | ApB_r   | ApB_r1   |
A=========[ A + B]====|=========|==========|===X
          [      ]    |         |          |
B=========[ A - B]====|=========|====[   ] |
                      |_________|    [ x ]=|===Y
Wn_exp----------------[ compl   ]====[   ] |
                      [_________] Wn       |
*/

////////////////////////////////////////////////////////////
//From Homework 3

//cos function lookup table
//full precision and [0 .. 45) degrees
`timescale 1ns/10ps

module addr_selector(
    input [11:0] angle,
    input angle_shift,
    input cos_en,
    output reg [8:0] mem_address,
    output reg do_except,
    output reg select_cos_mem,
    output reg select_positive
);

//logic variables
reg [11:0] angle_output, angle_mem_full;

always @(angle or cos_en) begin
    //cos/sin selection for output
    if (cos_en == 1'b1)
        //compute cos(angle)
        angle_output = angle + angle[0]*angle_shift;
    else
        //compute sin(angle) = cos (pi/2 - angle)
        angle_output = 11'b100_0000_0000 - angle - angle[0]*angle_shift;

    //choose cos/sin mem bank
    case (angle_output[11:9])
        3'b000: begin //0 - 45
            angle_mem_full = angle_output;
            select_cos_mem = 1'b1;
            select_positive = 1'b1;
        end
        3'b001: begin //45 - 90
            angle_mem_full = 12'h400 - angle_output;
            select_cos_mem = 1'b0;
            select_positive = 1'b1;
        end
        3'b010: begin //90 - 135
            angle_mem_full = angle_output[9:0] - 12'h400;
            select_cos_mem = 1'b0;
            select_positive = 1'b0;
        end
        3'b011: begin //135 - 180
            angle_mem_full = 12'h800 - angle_output;
            select_cos_mem = 1'b1;
            select_positive = 1'b0;
        end
        3'b100: begin //180 - 225
            angle_mem_full = angle_output - 12'h800;
            select_cos_mem = 1'b1;
            select_positive = 1'b0;
        end
        3'b101: begin //225 - 270
            angle_mem_full = 12'hC00 - angle_output;
            select_cos_mem = 1'b0;
            select_positive = 1'b0;
        end
        3'b110: begin //270 - 315
            angle_mem_full = angle_output - 12'hC00;
            select_cos_mem = 1'b0;
            select_positive = 1'b1;
        end
        3'b111: begin //315 - 360
            angle_mem_full = 13'h1000 - angle_output;
            select_cos_mem = 1'b1;
            select_positive = 1'b1;
        end
    endcase

    //exception (when need to return +1.0)
    mem_address = angle_mem_full[9:1];
    do_except = (mem_address == 10'b00_0000_0000);
    do_except = do_except || (mem_address == 10'b00_0000_0001);
    do_except = do_except || (mem_address == 10'b00_0000_0010);
    //except only work for cos bank near angle 0
    do_except = do_except & select_cos_mem;
end

endmodule

//////////////////////////////////////////////////////////////////
//From Homework3

module cos(
    input cos_en,
    input [11:0] angle,
    output reg [15:0] result
);

reg [15:0] result0, result1;
reg [16:0] result2x;
reg [14:0] cos_mem [256:0];
reg [14:0] sin_mem [256:0];

reg [14:0] mem_val0, mem_val1;
wire [8:0] mem_adr0, mem_adr1;
wire select_cos_mem0, select_cos_mem1, select_positive0, select_positive1, except0, except1;

initial begin
    //defaults
    result = 16'b0000_0000_0000_0000;
    mem_val0 = 15'b000_0000_0000_0000;
    mem_val1 = 15'b000_0000_0000_0000;
    //load values to memory;
    cos_mem[9'b000000000] = 15'b000000000000000; sin_mem[9'b000000000] = 15'b000000000000000;
    cos_mem[9'b000000001] = 15'b000000000000000; sin_mem[9'b000000001] = 15'b000000000110010;
    cos_mem[9'b000000010] = 15'b000000000000000; sin_mem[9'b000000010] = 15'b000000001100101;
    cos_mem[9'b000000011] = 15'b011111111111111; sin_mem[9'b000000011] = 15'b000000010010111;
    cos_mem[9'b000000100] = 15'b011111111111111; sin_mem[9'b000000100] = 15'b000000011001001;
    cos_mem[9'b000000101] = 15'b011111111111110; sin_mem[9'b000000101] = 15'b000000011111011;
    cos_mem[9'b000000110] = 15'b011111111111101; sin_mem[9'b000000110] = 15'b000000100101110;
    cos_mem[9'b000000111] = 15'b011111111111100; sin_mem[9'b000000111] = 15'b000000101100000;
    cos_mem[9'b000001000] = 15'b011111111111011; sin_mem[9'b000001000] = 15'b000000110010010;
    cos_mem[9'b000001001] = 15'b011111111111010; sin_mem[9'b000001001] = 15'b000000111000100;
    cos_mem[9'b000001010] = 15'b011111111111000; sin_mem[9'b000001010] = 15'b000000111110111;
    cos_mem[9'b000001011] = 15'b011111111110111; sin_mem[9'b000001011] = 15'b000001000101001;
    cos_mem[9'b000001100] = 15'b011111111110101; sin_mem[9'b000001100] = 15'b000001001011011;
    cos_mem[9'b000001101] = 15'b011111111110011; sin_mem[9'b000001101] = 15'b000001010001101;
    cos_mem[9'b000001110] = 15'b011111111110001; sin_mem[9'b000001110] = 15'b000001011000000;
//cut here ----------------------------------------------------------------------------------
    cos_mem[9'b000001111] = 15'b011111111101111; sin_mem[9'b000001111] = 15'b000001011110010;
    cos_mem[9'b000010000] = 15'b011111111101100; sin_mem[9'b000010000] = 15'b000001100100100;
    cos_mem[9'b000010001] = 15'b011111111101010; sin_mem[9'b000010001] = 15'b000001101010110;
    cos_mem[9'b000010010] = 15'b011111111100111; sin_mem[9'b000010010] = 15'b000001110001000;
    cos_mem[9'b000010011] = 15'b011111111100100; sin_mem[9'b000010011] = 15'b000001110111011;
    cos_mem[9'b000010100] = 15'b011111111100001; sin_mem[9'b000010100] = 15'b000001111101101;
    cos_mem[9'b000010101] = 15'b011111111011110; sin_mem[9'b000010101] = 15'b000010000011111;
    cos_mem[9'b000010110] = 15'b011111111011011; sin_mem[9'b000010110] = 15'b000010001010001;
    cos_mem[9'b000010111] = 15'b011111111010111; sin_mem[9'b000010111] = 15'b000010010000011;
    cos_mem[9'b000011000] = 15'b011111111010100; sin_mem[9'b000011000] = 15'b000010010110101;
    cos_mem[9'b000011001] = 15'b011111111010000; sin_mem[9'b000011001] = 15'b000010011100111;
    cos_mem[9'b000011010] = 15'b011111111001100; sin_mem[9'b000011010] = 15'b000010100011010;
    cos_mem[9'b000011011] = 15'b011111111001000; sin_mem[9'b000011011] = 15'b000010101001100;
    cos_mem[9'b000011100] = 15'b011111111000100; sin_mem[9'b000011100] = 15'b000010101111110;
    cos_mem[9'b000011101] = 15'b011111110111111; sin_mem[9'b000011101] = 15'b000010110110000;
    cos_mem[9'b000011110] = 15'b011111110111011; sin_mem[9'b000011110] = 15'b000010111100010;
    cos_mem[9'b000011111] = 15'b011111110110110; sin_mem[9'b000011111] = 15'b000011000010100;
    cos_mem[9'b000100000] = 15'b011111110110001; sin_mem[9'b000100000] = 15'b000011001000110;
    cos_mem[9'b000100001] = 15'b011111110101100; sin_mem[9'b000100001] = 15'b000011001111000;
    cos_mem[9'b000100010] = 15'b011111110100111; sin_mem[9'b000100010] = 15'b000011010101010;
    cos_mem[9'b000100011] = 15'b011111110100010; sin_mem[9'b000100011] = 15'b000011011011100;
    cos_mem[9'b000100100] = 15'b011111110011100; sin_mem[9'b000100100] = 15'b000011100001110;
    cos_mem[9'b000100101] = 15'b011111110010111; sin_mem[9'b000100101] = 15'b000011101000000;
    cos_mem[9'b000100110] = 15'b011111110010001; sin_mem[9'b000100110] = 15'b000011101110010;
    cos_mem[9'b000100111] = 15'b011111110001011; sin_mem[9'b000100111] = 15'b000011110100100;
    cos_mem[9'b000101000] = 15'b011111110000101; sin_mem[9'b000101000] = 15'b000011111010110;
    cos_mem[9'b000101001] = 15'b011111101111111; sin_mem[9'b000101001] = 15'b000100000000111;
    cos_mem[9'b000101010] = 15'b011111101111000; sin_mem[9'b000101010] = 15'b000100000111001;
    cos_mem[9'b000101011] = 15'b011111101110010; sin_mem[9'b000101011] = 15'b000100001101011;
    cos_mem[9'b000101100] = 15'b011111101101011; sin_mem[9'b000101100] = 15'b000100010011101;
    cos_mem[9'b000101101] = 15'b011111101100100; sin_mem[9'b000101101] = 15'b000100011001111;
    cos_mem[9'b000101110] = 15'b011111101011101; sin_mem[9'b000101110] = 15'b000100100000001;
    cos_mem[9'b000101111] = 15'b011111101010110; sin_mem[9'b000101111] = 15'b000100100110010;
    cos_mem[9'b000110000] = 15'b011111101001111; sin_mem[9'b000110000] = 15'b000100101100100;
    cos_mem[9'b000110001] = 15'b011111101000111; sin_mem[9'b000110001] = 15'b000100110010110;
    cos_mem[9'b000110010] = 15'b011111101000000; sin_mem[9'b000110010] = 15'b000100111000111;
    cos_mem[9'b000110011] = 15'b011111100111000; sin_mem[9'b000110011] = 15'b000100111111001;
    cos_mem[9'b000110100] = 15'b011111100110000; sin_mem[9'b000110100] = 15'b000101000101011;
    cos_mem[9'b000110101] = 15'b011111100101000; sin_mem[9'b000110101] = 15'b000101001011100;
    cos_mem[9'b000110110] = 15'b011111100100000; sin_mem[9'b000110110] = 15'b000101010001110;
    cos_mem[9'b000110111] = 15'b011111100010111; sin_mem[9'b000110111] = 15'b000101011000000;
    cos_mem[9'b000111000] = 15'b011111100001111; sin_mem[9'b000111000] = 15'b000101011110001;
    cos_mem[9'b000111001] = 15'b011111100000110; sin_mem[9'b000111001] = 15'b000101100100011;
    cos_mem[9'b000111010] = 15'b011111011111101; sin_mem[9'b000111010] = 15'b000101101010100;
    cos_mem[9'b000111011] = 15'b011111011110100; sin_mem[9'b000111011] = 15'b000101110000101;
    cos_mem[9'b000111100] = 15'b011111011101011; sin_mem[9'b000111100] = 15'b000101110110111;
    cos_mem[9'b000111101] = 15'b011111011100010; sin_mem[9'b000111101] = 15'b000101111101000;
    cos_mem[9'b000111110] = 15'b011111011011000; sin_mem[9'b000111110] = 15'b000110000011010;
    cos_mem[9'b000111111] = 15'b011111011001111; sin_mem[9'b000111111] = 15'b000110001001011;
    cos_mem[9'b001000000] = 15'b011111011000101; sin_mem[9'b001000000] = 15'b000110001111100;
    cos_mem[9'b001000001] = 15'b011111010111011; sin_mem[9'b001000001] = 15'b000110010101110;
    cos_mem[9'b001000010] = 15'b011111010110001; sin_mem[9'b001000010] = 15'b000110011011111;
    cos_mem[9'b001000011] = 15'b011111010100111; sin_mem[9'b001000011] = 15'b000110100010000;
    cos_mem[9'b001000100] = 15'b011111010011101; sin_mem[9'b001000100] = 15'b000110101000001;
    cos_mem[9'b001000101] = 15'b011111010010010; sin_mem[9'b001000101] = 15'b000110101110010;
    cos_mem[9'b001000110] = 15'b011111010001000; sin_mem[9'b001000110] = 15'b000110110100100;
    cos_mem[9'b001000111] = 15'b011111001111101; sin_mem[9'b001000111] = 15'b000110111010101;
    cos_mem[9'b001001000] = 15'b011111001110010; sin_mem[9'b001001000] = 15'b000111000000110;
    cos_mem[9'b001001001] = 15'b011111001100111; sin_mem[9'b001001001] = 15'b000111000110111;
    cos_mem[9'b001001010] = 15'b011111001011100; sin_mem[9'b001001010] = 15'b000111001101000;
    cos_mem[9'b001001011] = 15'b011111001010000; sin_mem[9'b001001011] = 15'b000111010011001;
    cos_mem[9'b001001100] = 15'b011111001000101; sin_mem[9'b001001100] = 15'b000111011001010;
    cos_mem[9'b001001101] = 15'b011111000111001; sin_mem[9'b001001101] = 15'b000111011111011;
    cos_mem[9'b001001110] = 15'b011111000101101; sin_mem[9'b001001110] = 15'b000111100101011;
    cos_mem[9'b001001111] = 15'b011111000100001; sin_mem[9'b001001111] = 15'b000111101011100;
    cos_mem[9'b001010000] = 15'b011111000010101; sin_mem[9'b001010000] = 15'b000111110001101;
    cos_mem[9'b001010001] = 15'b011111000001001; sin_mem[9'b001010001] = 15'b000111110111110;
    cos_mem[9'b001010010] = 15'b011110111111100; sin_mem[9'b001010010] = 15'b000111111101110;
    cos_mem[9'b001010011] = 15'b011110111110000; sin_mem[9'b001010011] = 15'b001000000011111;
    cos_mem[9'b001010100] = 15'b011110111100011; sin_mem[9'b001010100] = 15'b001000001010000;
    cos_mem[9'b001010101] = 15'b011110111010110; sin_mem[9'b001010101] = 15'b001000010000000;
    cos_mem[9'b001010110] = 15'b011110111001001; sin_mem[9'b001010110] = 15'b001000010110001;
    cos_mem[9'b001010111] = 15'b011110110111100; sin_mem[9'b001010111] = 15'b001000011100001;
    cos_mem[9'b001011000] = 15'b011110110101111; sin_mem[9'b001011000] = 15'b001000100010010;
    cos_mem[9'b001011001] = 15'b011110110100001; sin_mem[9'b001011001] = 15'b001000101000010;
    cos_mem[9'b001011010] = 15'b011110110010011; sin_mem[9'b001011010] = 15'b001000101110011;
    cos_mem[9'b001011011] = 15'b011110110000110; sin_mem[9'b001011011] = 15'b001000110100011;
    cos_mem[9'b001011100] = 15'b011110101111000; sin_mem[9'b001011100] = 15'b001000111010011;
    cos_mem[9'b001011101] = 15'b011110101101010; sin_mem[9'b001011101] = 15'b001001000000100;
    cos_mem[9'b001011110] = 15'b011110101011011; sin_mem[9'b001011110] = 15'b001001000110100;
    cos_mem[9'b001011111] = 15'b011110101001101; sin_mem[9'b001011111] = 15'b001001001100100;
    cos_mem[9'b001100000] = 15'b011110100111111; sin_mem[9'b001100000] = 15'b001001010010100;
    cos_mem[9'b001100001] = 15'b011110100110000; sin_mem[9'b001100001] = 15'b001001011000100;
    cos_mem[9'b001100010] = 15'b011110100100001; sin_mem[9'b001100010] = 15'b001001011110100;
    cos_mem[9'b001100011] = 15'b011110100010010; sin_mem[9'b001100011] = 15'b001001100100100;
    cos_mem[9'b001100100] = 15'b011110100000011; sin_mem[9'b001100100] = 15'b001001101010100;
    cos_mem[9'b001100101] = 15'b011110011110100; sin_mem[9'b001100101] = 15'b001001110000100;
    cos_mem[9'b001100110] = 15'b011110011100100; sin_mem[9'b001100110] = 15'b001001110110100;
    cos_mem[9'b001100111] = 15'b011110011010101; sin_mem[9'b001100111] = 15'b001001111100100;
    cos_mem[9'b001101000] = 15'b011110011000101; sin_mem[9'b001101000] = 15'b001010000010011;
    cos_mem[9'b001101001] = 15'b011110010110101; sin_mem[9'b001101001] = 15'b001010001000011;
    cos_mem[9'b001101010] = 15'b011110010100101; sin_mem[9'b001101010] = 15'b001010001110011;
    cos_mem[9'b001101011] = 15'b011110010010101; sin_mem[9'b001101011] = 15'b001010010100010;
    cos_mem[9'b001101100] = 15'b011110010000101; sin_mem[9'b001101100] = 15'b001010011010010;
    cos_mem[9'b001101101] = 15'b011110001110100; sin_mem[9'b001101101] = 15'b001010100000001;
    cos_mem[9'b001101110] = 15'b011110001100100; sin_mem[9'b001101110] = 15'b001010100110001;
    cos_mem[9'b001101111] = 15'b011110001010011; sin_mem[9'b001101111] = 15'b001010101100000;
    cos_mem[9'b001110000] = 15'b011110001000010; sin_mem[9'b001110000] = 15'b001010110010000;
    cos_mem[9'b001110001] = 15'b011110000110001; sin_mem[9'b001110001] = 15'b001010110111111;
    cos_mem[9'b001110010] = 15'b011110000100000; sin_mem[9'b001110010] = 15'b001010111101110;
    cos_mem[9'b001110011] = 15'b011110000001111; sin_mem[9'b001110011] = 15'b001011000011101;
    cos_mem[9'b001110100] = 15'b011101111111101; sin_mem[9'b001110100] = 15'b001011001001100;
    cos_mem[9'b001110101] = 15'b011101111101100; sin_mem[9'b001110101] = 15'b001011001111100;
    cos_mem[9'b001110110] = 15'b011101111011010; sin_mem[9'b001110110] = 15'b001011010101011;
    cos_mem[9'b001110111] = 15'b011101111001000; sin_mem[9'b001110111] = 15'b001011011011010;
    cos_mem[9'b001111000] = 15'b011101110110110; sin_mem[9'b001111000] = 15'b001011100001001;
    cos_mem[9'b001111001] = 15'b011101110100100; sin_mem[9'b001111001] = 15'b001011100110111;
    cos_mem[9'b001111010] = 15'b011101110010010; sin_mem[9'b001111010] = 15'b001011101100110;
    cos_mem[9'b001111011] = 15'b011101101111111; sin_mem[9'b001111011] = 15'b001011110010101;
    cos_mem[9'b001111100] = 15'b011101101101101; sin_mem[9'b001111100] = 15'b001011111000100;
    cos_mem[9'b001111101] = 15'b011101101011010; sin_mem[9'b001111101] = 15'b001011111110010;
    cos_mem[9'b001111110] = 15'b011101101000111; sin_mem[9'b001111110] = 15'b001100000100001;
    cos_mem[9'b001111111] = 15'b011101100110100; sin_mem[9'b001111111] = 15'b001100001001111;
    cos_mem[9'b010000000] = 15'b011101100100001; sin_mem[9'b010000000] = 15'b001100001111110;
    cos_mem[9'b010000001] = 15'b011101100001110; sin_mem[9'b010000001] = 15'b001100010101100;
    cos_mem[9'b010000010] = 15'b011101011111010; sin_mem[9'b010000010] = 15'b001100011011011;
    cos_mem[9'b010000011] = 15'b011101011100110; sin_mem[9'b010000011] = 15'b001100100001001;
    cos_mem[9'b010000100] = 15'b011101011010011; sin_mem[9'b010000100] = 15'b001100100110111;
    cos_mem[9'b010000101] = 15'b011101010111111; sin_mem[9'b010000101] = 15'b001100101100101;
    cos_mem[9'b010000110] = 15'b011101010101011; sin_mem[9'b010000110] = 15'b001100110010011;
    cos_mem[9'b010000111] = 15'b011101010010111; sin_mem[9'b010000111] = 15'b001100111000001;
    cos_mem[9'b010001000] = 15'b011101010000010; sin_mem[9'b010001000] = 15'b001100111101111;
    cos_mem[9'b010001001] = 15'b011101001101110; sin_mem[9'b010001001] = 15'b001101000011101;
    cos_mem[9'b010001010] = 15'b011101001011001; sin_mem[9'b010001010] = 15'b001101001001011;
    cos_mem[9'b010001011] = 15'b011101001000101; sin_mem[9'b010001011] = 15'b001101001111001;
    cos_mem[9'b010001100] = 15'b011101000110000; sin_mem[9'b010001100] = 15'b001101010100111;
    cos_mem[9'b010001101] = 15'b011101000011011; sin_mem[9'b010001101] = 15'b001101011010100;
    cos_mem[9'b010001110] = 15'b011101000000110; sin_mem[9'b010001110] = 15'b001101100000010;
    cos_mem[9'b010001111] = 15'b011100111110000; sin_mem[9'b010001111] = 15'b001101100110000;
    cos_mem[9'b010010000] = 15'b011100111011011; sin_mem[9'b010010000] = 15'b001101101011101;
    cos_mem[9'b010010001] = 15'b011100111000101; sin_mem[9'b010010001] = 15'b001101110001010;
    cos_mem[9'b010010010] = 15'b011100110110000; sin_mem[9'b010010010] = 15'b001101110111000;
    cos_mem[9'b010010011] = 15'b011100110011010; sin_mem[9'b010010011] = 15'b001101111100101;
    cos_mem[9'b010010100] = 15'b011100110000100; sin_mem[9'b010010100] = 15'b001110000010010;
    cos_mem[9'b010010101] = 15'b011100101101110; sin_mem[9'b010010101] = 15'b001110000111111;
    cos_mem[9'b010010110] = 15'b011100101011000; sin_mem[9'b010010110] = 15'b001110001101100;
    cos_mem[9'b010010111] = 15'b011100101000001; sin_mem[9'b010010111] = 15'b001110010011001;
    cos_mem[9'b010011000] = 15'b011100100101011; sin_mem[9'b010011000] = 15'b001110011000110;
    cos_mem[9'b010011001] = 15'b011100100010100; sin_mem[9'b010011001] = 15'b001110011110011;
    cos_mem[9'b010011010] = 15'b011100011111101; sin_mem[9'b010011010] = 15'b001110100100000;
    cos_mem[9'b010011011] = 15'b011100011100110; sin_mem[9'b010011011] = 15'b001110101001101;
    cos_mem[9'b010011100] = 15'b011100011001111; sin_mem[9'b010011100] = 15'b001110101111001;
    cos_mem[9'b010011101] = 15'b011100010111000; sin_mem[9'b010011101] = 15'b001110110100110;
    cos_mem[9'b010011110] = 15'b011100010100001; sin_mem[9'b010011110] = 15'b001110111010011;
    cos_mem[9'b010011111] = 15'b011100010001001; sin_mem[9'b010011111] = 15'b001110111111111;
    cos_mem[9'b010100000] = 15'b011100001110001; sin_mem[9'b010100000] = 15'b001111000101011;
    cos_mem[9'b010100001] = 15'b011100001011010; sin_mem[9'b010100001] = 15'b001111001011000;
    cos_mem[9'b010100010] = 15'b011100001000010; sin_mem[9'b010100010] = 15'b001111010000100;
    cos_mem[9'b010100011] = 15'b011100000101010; sin_mem[9'b010100011] = 15'b001111010110000;
    cos_mem[9'b010100100] = 15'b011100000010010; sin_mem[9'b010100100] = 15'b001111011011100;
    cos_mem[9'b010100101] = 15'b011011111111001; sin_mem[9'b010100101] = 15'b001111100001000;
    cos_mem[9'b010100110] = 15'b011011111100001; sin_mem[9'b010100110] = 15'b001111100110100;
    cos_mem[9'b010100111] = 15'b011011111001000; sin_mem[9'b010100111] = 15'b001111101100000;
    cos_mem[9'b010101000] = 15'b011011110110000; sin_mem[9'b010101000] = 15'b001111110001100;
    cos_mem[9'b010101001] = 15'b011011110010111; sin_mem[9'b010101001] = 15'b001111110110111;
    cos_mem[9'b010101010] = 15'b011011101111110; sin_mem[9'b010101010] = 15'b001111111100011;
    cos_mem[9'b010101011] = 15'b011011101100101; sin_mem[9'b010101011] = 15'b010000000001111;
    cos_mem[9'b010101100] = 15'b011011101001011; sin_mem[9'b010101100] = 15'b010000000111010;
    cos_mem[9'b010101101] = 15'b011011100110010; sin_mem[9'b010101101] = 15'b010000001100101;
    cos_mem[9'b010101110] = 15'b011011100011000; sin_mem[9'b010101110] = 15'b010000010010001;
    cos_mem[9'b010101111] = 15'b011011011111111; sin_mem[9'b010101111] = 15'b010000010111100;
    cos_mem[9'b010110000] = 15'b011011011100101; sin_mem[9'b010110000] = 15'b010000011100111;
    cos_mem[9'b010110001] = 15'b011011011001011; sin_mem[9'b010110001] = 15'b010000100010010;
    cos_mem[9'b010110010] = 15'b011011010110001; sin_mem[9'b010110010] = 15'b010000100111101;
    cos_mem[9'b010110011] = 15'b011011010010111; sin_mem[9'b010110011] = 15'b010000101101000;
    cos_mem[9'b010110100] = 15'b011011001111101; sin_mem[9'b010110100] = 15'b010000110010011;
    cos_mem[9'b010110101] = 15'b011011001100010; sin_mem[9'b010110101] = 15'b010000110111110;
    cos_mem[9'b010110110] = 15'b011011001001000; sin_mem[9'b010110110] = 15'b010000111101000;
    cos_mem[9'b010110111] = 15'b011011000101101; sin_mem[9'b010110111] = 15'b010001000010011;
    cos_mem[9'b010111000] = 15'b011011000010010; sin_mem[9'b010111000] = 15'b010001000111101;
    cos_mem[9'b010111001] = 15'b011010111110111; sin_mem[9'b010111001] = 15'b010001001101000;
    cos_mem[9'b010111010] = 15'b011010111011100; sin_mem[9'b010111010] = 15'b010001010010010;
    cos_mem[9'b010111011] = 15'b011010111000001; sin_mem[9'b010111011] = 15'b010001010111100;
    cos_mem[9'b010111100] = 15'b011010110100101; sin_mem[9'b010111100] = 15'b010001011100111;
    cos_mem[9'b010111101] = 15'b011010110001010; sin_mem[9'b010111101] = 15'b010001100010001;
    cos_mem[9'b010111110] = 15'b011010101101110; sin_mem[9'b010111110] = 15'b010001100111011;
    cos_mem[9'b010111111] = 15'b011010101010011; sin_mem[9'b010111111] = 15'b010001101100101;
    cos_mem[9'b011000000] = 15'b011010100110111; sin_mem[9'b011000000] = 15'b010001110001110;
    cos_mem[9'b011000001] = 15'b011010100011011; sin_mem[9'b011000001] = 15'b010001110111000;
    cos_mem[9'b011000010] = 15'b011010011111111; sin_mem[9'b011000010] = 15'b010001111100010;
    cos_mem[9'b011000011] = 15'b011010011100010; sin_mem[9'b011000011] = 15'b010010000001011;
    cos_mem[9'b011000100] = 15'b011010011000110; sin_mem[9'b011000100] = 15'b010010000110101;
    cos_mem[9'b011000101] = 15'b011010010101010; sin_mem[9'b011000101] = 15'b010010001011110;
    cos_mem[9'b011000110] = 15'b011010010001101; sin_mem[9'b011000110] = 15'b010010010001000;
    cos_mem[9'b011000111] = 15'b011010001110000; sin_mem[9'b011000111] = 15'b010010010110001;
    cos_mem[9'b011001000] = 15'b011010001010011; sin_mem[9'b011001000] = 15'b010010011011010;
    cos_mem[9'b011001001] = 15'b011010000110110; sin_mem[9'b011001001] = 15'b010010100000011;
    cos_mem[9'b011001010] = 15'b011010000011001; sin_mem[9'b011001010] = 15'b010010100101100;
    cos_mem[9'b011001011] = 15'b011001111111100; sin_mem[9'b011001011] = 15'b010010101010101;
    cos_mem[9'b011001100] = 15'b011001111011111; sin_mem[9'b011001100] = 15'b010010101111110;
    cos_mem[9'b011001101] = 15'b011001111000001; sin_mem[9'b011001101] = 15'b010010110100110;
    cos_mem[9'b011001110] = 15'b011001110100011; sin_mem[9'b011001110] = 15'b010010111001111;
    cos_mem[9'b011001111] = 15'b011001110000110; sin_mem[9'b011001111] = 15'b010010111111000;
    cos_mem[9'b011010000] = 15'b011001101101000; sin_mem[9'b011010000] = 15'b010011000100000;
    cos_mem[9'b011010001] = 15'b011001101001010; sin_mem[9'b011010001] = 15'b010011001001000;
    cos_mem[9'b011010010] = 15'b011001100101100; sin_mem[9'b011010010] = 15'b010011001110001;
    cos_mem[9'b011010011] = 15'b011001100001101; sin_mem[9'b011010011] = 15'b010011010011001;
    cos_mem[9'b011010100] = 15'b011001011101111; sin_mem[9'b011010100] = 15'b010011011000001;
    cos_mem[9'b011010101] = 15'b011001011010000; sin_mem[9'b011010101] = 15'b010011011101001;
    cos_mem[9'b011010110] = 15'b011001010110010; sin_mem[9'b011010110] = 15'b010011100010001;
    cos_mem[9'b011010111] = 15'b011001010010011; sin_mem[9'b011010111] = 15'b010011100111000;
    cos_mem[9'b011011000] = 15'b011001001110100; sin_mem[9'b011011000] = 15'b010011101100000;
    cos_mem[9'b011011001] = 15'b011001001010101; sin_mem[9'b011011001] = 15'b010011110001000;
    cos_mem[9'b011011010] = 15'b011001000110110; sin_mem[9'b011011010] = 15'b010011110101111;
    cos_mem[9'b011011011] = 15'b011001000010111; sin_mem[9'b011011011] = 15'b010011111010110;
    cos_mem[9'b011011100] = 15'b011000111111000; sin_mem[9'b011011100] = 15'b010011111111110;
    cos_mem[9'b011011101] = 15'b011000111011000; sin_mem[9'b011011101] = 15'b010100000100101;
    cos_mem[9'b011011110] = 15'b011000110111001; sin_mem[9'b011011110] = 15'b010100001001100;
    cos_mem[9'b011011111] = 15'b011000110011001; sin_mem[9'b011011111] = 15'b010100001110011;
    cos_mem[9'b011100000] = 15'b011000101111001; sin_mem[9'b011100000] = 15'b010100010011010;
    cos_mem[9'b011100001] = 15'b011000101011001; sin_mem[9'b011100001] = 15'b010100011000001;
    cos_mem[9'b011100010] = 15'b011000100111001; sin_mem[9'b011100010] = 15'b010100011100111;
    cos_mem[9'b011100011] = 15'b011000100011001; sin_mem[9'b011100011] = 15'b010100100001110;
    cos_mem[9'b011100100] = 15'b011000011111001; sin_mem[9'b011100100] = 15'b010100100110101;
    cos_mem[9'b011100101] = 15'b011000011011000; sin_mem[9'b011100101] = 15'b010100101011011;
    cos_mem[9'b011100110] = 15'b011000010111000; sin_mem[9'b011100110] = 15'b010100110000001;
    cos_mem[9'b011100111] = 15'b011000010010111; sin_mem[9'b011100111] = 15'b010100110100111;
    cos_mem[9'b011101000] = 15'b011000001110110; sin_mem[9'b011101000] = 15'b010100111001110;
    cos_mem[9'b011101001] = 15'b011000001010101; sin_mem[9'b011101001] = 15'b010100111110100;
    cos_mem[9'b011101010] = 15'b011000000110100; sin_mem[9'b011101010] = 15'b010101000011010;
    cos_mem[9'b011101011] = 15'b011000000010011; sin_mem[9'b011101011] = 15'b010101000111111;
    cos_mem[9'b011101100] = 15'b010111111110010; sin_mem[9'b011101100] = 15'b010101001100101;
    cos_mem[9'b011101101] = 15'b010111111010000; sin_mem[9'b011101101] = 15'b010101010001011;
    cos_mem[9'b011101110] = 15'b010111110101111; sin_mem[9'b011101110] = 15'b010101010110000;
    cos_mem[9'b011101111] = 15'b010111110001101; sin_mem[9'b011101111] = 15'b010101011010110;
    cos_mem[9'b011110000] = 15'b010111101101100; sin_mem[9'b011110000] = 15'b010101011111011;
    cos_mem[9'b011110001] = 15'b010111101001010; sin_mem[9'b011110001] = 15'b010101100100000;
//cut here ----------------------------------------------------------------------------------
    cos_mem[9'b011110010] = 15'b010111100101000; sin_mem[9'b011110010] = 15'b010101101000101;
    cos_mem[9'b011110011] = 15'b010111100000110; sin_mem[9'b011110011] = 15'b010101101101010;
    cos_mem[9'b011110100] = 15'b010111011100100; sin_mem[9'b011110100] = 15'b010101110001111;
    cos_mem[9'b011110101] = 15'b010111011000010; sin_mem[9'b011110101] = 15'b010101110110100;
    cos_mem[9'b011110110] = 15'b010111010011111; sin_mem[9'b011110110] = 15'b010101111011000;
    cos_mem[9'b011110111] = 15'b010111001111101; sin_mem[9'b011110111] = 15'b010101111111101;
    cos_mem[9'b011111000] = 15'b010111001011010; sin_mem[9'b011111000] = 15'b010110000100001;
    cos_mem[9'b011111001] = 15'b010111000110111; sin_mem[9'b011111001] = 15'b010110001000110;
    cos_mem[9'b011111010] = 15'b010111000010101; sin_mem[9'b011111010] = 15'b010110001101010;
    cos_mem[9'b011111011] = 15'b010110111110010; sin_mem[9'b011111011] = 15'b010110010001110;
    cos_mem[9'b011111100] = 15'b010110111001111; sin_mem[9'b011111100] = 15'b010110010110010;
    cos_mem[9'b011111101] = 15'b010110110101011; sin_mem[9'b011111101] = 15'b010110011010110;
    cos_mem[9'b011111110] = 15'b010110110001000; sin_mem[9'b011111110] = 15'b010110011111010;
    cos_mem[9'b011111111] = 15'b010110101100101; sin_mem[9'b011111111] = 15'b010110100011110;
    cos_mem[9'b100000000] = 15'b010110101000001; sin_mem[9'b100000000] = 15'b010110101000001;
end

//address calculation for bottom value
addr_selector ADS0 (
    .angle (angle),
    .angle_shift (1'b0),
    .cos_en (cos_en),
    .mem_address (mem_adr0),
    .do_except (except0),
    .select_cos_mem (select_cos_mem0),
    .select_positive (select_positive0)
);

//address calculation for upper value
addr_selector ADS1 (
    .angle (angle),
    .angle_shift (1'b1),
    .cos_en (cos_en),
    .mem_address (mem_adr1),
    .do_except (except1),
    .select_cos_mem (select_cos_mem1),
    .select_positive (select_positive1)
);

//calculate upper value
always @(mem_adr1 or mem_adr1 or select_cos_mem1 or select_positive1) begin
    //read memory
    if (select_cos_mem1 == 1'b1) begin
        mem_val1 = cos_mem[mem_adr1];
    end else begin
        mem_val1 = sin_mem[mem_adr1];
    end
    if (select_positive1 == 1'b1) begin
        result1 = {mem_val1[14], mem_val1[14] | except1, mem_val1[13:0]};
    end else begin
        result1 = -{mem_val1[14], mem_val1[14] | except1, mem_val1[13:0]};
    end
end

//calculate bottom value
always @(mem_adr0 or mem_adr0 or select_cos_mem0 or select_positive0) begin
    //read memory
    if (select_cos_mem0 == 1'b1) begin
        mem_val0 = cos_mem[mem_adr0];
    end else begin
        mem_val0 = sin_mem[mem_adr0];
    end
    if (select_positive0 == 1'b1) begin
        result0 = {mem_val0[14], mem_val0[14] | except0, mem_val0[13:0]};
    end else begin
        result0 = -{mem_val0[14], mem_val0[14] | except0, mem_val0[13:0]};
    end
end

//write output
always @(result1 or result0) begin
    result2x = {result1[15], result1} + {result0[15], result0};
    result = result2x[16:1]; //devide by 2
end

endmodule

////////////////////////////////////////////////////////////////////////
//From Homework 3. Modified

module compl(
    input [11:0] angle,
    //input start,
    input clk,
    input rst,
    output reg [15:0] r,
    output reg [15:0] i
);

reg [11:0] angle_r;
reg [15:0] r_mem;
wire [15:0] cos_val;//, sin_val;
reg cos_en;

//cos on posedge clk
//sin on negedge clk

cos cos_mem (.angle (angle_r), .cos_en(cos_en), .result(cos_val));

always @(posedge clk or negedge clk or posedge rst) begin
    if (rst == 1) begin
        i <= #1 16'b0000_0000_0000_0000;
        r <= #1 16'b0000_0000_0000_0000;
        angle_r <= #1 12'b0000_0000_0000;
        r_mem <= #1 16'b0000_0000_0000_0000;
    end else begin
        if (clk == 1) begin //posedge clk
            i <= #1 cos_val;
            r <= #1 r_mem;
            cos_en <= #1 1'b1;
            angle_r <= #1 angle;
        end else begin      //negedge clk
            cos_en <= #1 1'b0;
            r_mem <= #1 cos_val;
        end
    end
end

endmodule


/*

clk     ____/------\______/------\______/------\______/------\_____
angle   ____x0000000000000x1111111111111x2222222222222x333333333333

angle_r _____x0000000000000x1111111111111x2222222222222x33333333333
cos_en  _____/------\______/------\______/------\______/------\____
cos_val _____x000000x111111x222222x333333x444444x555555x666666x7777

r_c     ____________x0000000000000x2222222222222x4444444444444x6666

r       ___________________x0000000000000x2222222222222x44444444444
i       ___________________x1111111111111x3333333333333x66666666666

*/

module fftbtf (
    input clk,
    input rst,
    input [11:0] wn_exp,
    input [15:0] A_R,
    input [15:0] A_I,
    input [15:0] B_R,
    input [15:0] B_I,
    output reg [15:0] X_R,
    output reg [15:0] X_I,
    output reg [15:0] Y_R,
    output reg [15:0] Y_I
    );

//stage 1. A+B and A-B
wire [16:0] ApB_R, ApB_I, AmB_R, AmB_I;
assign ApB_R = A_R + B_R;
assign ApB_I = A_I + B_I;
assign AmB_R = A_R - B_R;
assign AmB_I = A_I - B_I;

reg [16:0] ApB_R_r, ApB_I_r, AmB_R_r, AmB_I_r;
always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
        ApB_R_r <= #1 16'b0000_0000_0000_0000;
        ApB_I_r <= #1 16'b0000_0000_0000_0000;
        AmB_R_r <= #1 16'b0000_0000_0000_0000;
        AmB_I_r <= #1 16'b0000_0000_0000_0000;
    end else begin
        ApB_R_r <= #1 ApB_R;
        ApB_I_r <= #1 ApB_I;
        AmB_R_r <= #1 AmB_R;
        AmB_I_r <= #1 AmB_I;
    end
end

//stage 2. get Wn
reg [16:0] ApB_R_r1, ApB_I_r1, AmB_R_r1, AmB_I_r1;
wire [15:0] Wn_R, Wn_I;
//compl already has clk for output
compl C1 (.angle (wn_exp), .clk (clk), .rst (rst), .r (Wn_R), .i (Wn_I));
always @(posedge clk) begin
    ApB_R_r1 <= #1 ApB_R_r;
    ApB_I_r1 <= #1 ApB_I_r;
    AmB_R_r1 <= #1 AmB_R_r;
    AmB_I_r1 <= #1 AmB_I_r;
end

//stage 3. multiply by Wn
reg [32:0] Y_R_0, Y_R_1, Y_I_0, Y_I_1;
reg [16:0] Y_R_c, Y_I_c;
//(A-B)*Wn = (AmB_R + i*AmB_I) * (Wn_R + i*Wn_I) = AmB_R*Wn_R - AmB_I*Wn_I + i*[AmB_R * Wn_I + AmB_I * Wn_R]
//15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
//32 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16
always @(AmB_R or AmB_I or Wn_R or Wn_I) begin
    Y_R_0 = AmB_R * Wn_R;
    Y_R_1 = AmB_I * Wn_I;
    Y_I_0 = AmB_R * Wn_I;
    Y_I_1 = AmB_I * Wn_R;
    Y_R_c = {Y_R_0[32],Y_R_0[32:18]} - {Y_R_1[32],Y_R_1[32:18]};
    Y_I_c = {Y_I_0[32],Y_I_0[32:18]} - {Y_I_1[32],Y_I_1[32:18]};
end

always @(posedge clk) begin
    Y_R <= #1 Y_R_c;
    Y_I <= #1 Y_I_c;
    X_R <= #1 ApB_R_r1;
    X_I <= #1 ApB_I_r1;
end

endmodule