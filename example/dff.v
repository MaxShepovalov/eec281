// dff.v
//
// Positive edge triggered D flip-flop with reset
//
// Declare the timescale time unit / precision.
// Delays in the programs are based on the time unit but the simulator 
// steps are based on the precision. 
`timescale 1ns/10 ps

// module declaration - list input and output parameters
module dff (
   d,
   clk,
   reset,
   q);

   // specify inputs and outputs
   input      d;
   input      clk;
   input      reset;
   output     q;

   // q ff is type reg because it holds its value between assignments
   reg        q;

   // positive edge triggered flip-flop.  Enter always block only on 
   // posedge of clk signal
   always @(posedge clk) begin
      // check for synchronous reset
      if (reset) begin
         q   <= #1 1'b0;
      end

      // otherwise use d
      else begin
         q   <= #1 d;
      end 
   end   

endmodule
