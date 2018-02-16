// def.v
//
// practice

`timescale 10ps/1ps
`celldefine
module def (
   in,
   out,
   clk
   );

   //----- Inputs/outputs
   input                in;
   output               out;

   input                clk;


   // declarations
   reg          c;
   reg          out;

   // FFs
   always @(posedge clk) begin
      c         <= #1 in;
      out       <= #1 c;
   end

endmodule   /* def */
`endcelldefine