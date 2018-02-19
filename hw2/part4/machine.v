//hw2 p4

module machine (
    input reset,
    input clk,
    input skip,
    output reg shutter,
    output reg [2:0] state
);

    parameter IDLE = 2'b00;
    parameter CAMERA_ON = 2'b01;
    parameter PROCESS = 2'b10;

    reg [2:0] state_c;
    reg [2:0] count, count_c;
    reg shutter_c;

    always @(state or count or reset or clk or skip) begin
        //default
        count_c = count;
        state_c = state;
        shutter_c = shutter;
        case(state)
            IDLE: begin
                if (count == 3'b000) begin
                    state_c = CAMERA_ON;
                    count_c = 3'b101; //6 cycles
                    shutter_c = 1'b1;
                end else
                    count_c = count - 3'b001;
            end
            CAMERA_ON: begin
                if (count == 3'b000) begin
                    state_c = PROCESS;
                    count_c = 3'b011; // 4 cycles
                    shutter_c = 1'b0;
                end else begin
                    shutter_c = (count == 3'b011);
                    count_c = count - 3'b001;
                end
            end
            PROCESS: begin
                if (skip == 1'b1 || count == 3'b000) begin
                    state_c = IDLE;
                    count_c = 3'b010;
                end else begin
                    count_c = count - 3'b001;
                end
            end

            default: begin
                count_c = 3'b010;
                state_c = IDLE;
                shutter_c = 1'b0;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            count <= #1 3'b010;
            state <= #1 IDLE;
            shutter <= #1 1'b0;
        end
        else begin
            count <= #1 count_c;
            state <= #1 state_c;
            shutter <= #1 shutter_c;
        end
    end

endmodule
