//hw2 p4

module machine (
    input reset,
    input clk,
    input skip,
    output reg shutter
);

    parameter IDLE = 2'b00;
    parameter CAMERA_ON = 2'b01;
    parameter PROCESS = 2'b10;

    reg [2:0] state, state_c;
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
                    count_c = 3'b110; //7 cycles
                end else
                    count_c = count - 3'b001;
            end
            CAMERA_ON: begin
                if (count == 3'b000) begin
                    state_c = PROCESS;
                    count_c = 3'b100; // 4 cycles
                end else begin
                    shutter_c = (count == 3'b110) || (count == 3'b011);
                    count_c = count - 3'b001;
                end
                /*case(count)
                    3'b000: begin             //cycle 7
                        state_c = PROCESS;
                        count_c = 3'b100; // 4 cycles
                    end
                    3'b110: begin             //cycle 1
                        shutter_c = 1'b1;
                        count_c = count - 3'b001;
                    end
                    3'b101: begin             //cycle 2
                        shutter_c = 1'b0;
                        count_c = count - 3'b001;
                    end
                    3'b100: begin             //cycle 3
                        shutter_c = 1'b0;
                        count_c = count - 3'b001;
                    end
                    3'b011: begin             //cycle 4
                        shutter_c = 1'b1;
                        count_c = count - 3'b001;
                    end
                    3'b010: begin             //cycle 5
                        shutter_c = 1'b0;
                        count_c = count - 3'b001;
                    end
                    3'b001: begin             //cycle 6
                        shutter_c = 1'b0;
                        count_c = count - 3'b001;
                    end
                    default: shutter_c = 1'b0;
                endcase*/
            end
            PROCESS: begin
                if (skip == 1'b1 || count == 3'b000) begin
                    state_c = IDLE;
                    count = 3'b011;
                end else begin
                    count_c = count - 3'b001;
                end
            end

            default: begin
                count_c = 3'b011;
                state_c = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            count <= #1 3'b011;
            state <= #1 IDLE;
        end
        else begin
            count <= #1 count_c;
            state <= #1 state_c;
            shutter <= #1 shutter_c;
        end
    end

endmodule