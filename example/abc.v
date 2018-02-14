// abc.v
//
// A very simple circuit
//
// Note that andwire1 and andwire2 do not affect the module's output,
// so the two AND gates will operate during verilog simulation, but will
// be removed during synthesis.

`timescale 1ns/10ps

module abc (
   data1,
   data2,
   clock,
   reset,
   out );

input   data1;
input   data2;
input   clock;
input   reset;
output  out;

//----- Declarations
// Misc "wires"
wire    r_data1;
wire    r_data2;
wire    andwire1;
reg     andwire2;
wire    c_out;
wire    out;


//----- Circuits
// Declare an instance of the dff module (named "d1") and connect signals 
dff d1 (
   .d           (data1),
   .clk         (clock),
   .reset       (reset),
   .q           (r_data1)
   );

// Declare an instance of the dff module (named "d2") and connect signals 
dff d2 (
   .d           (data2),
   .clk         (clock),
   .reset       (reset),
   .q           (r_data2)
   );

// An AND gate
assign  andwire1  = r_data1 & r_data2;

// An AND gate
always @(r_data1 or r_data2) begin
   andwire2 = r_data1 & r_data2;
end

// An OR gate
assign c_out = r_data1 | r_data2;

// Declare an instance of the dff module (named "d3") and connect signals 
dff d3 (
   .d           (c_out),
   .clk         (clock),
   .reset       (reset),
   .q           (out)
   );


endmodule

