module state_reg_cg (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si, skinnys, clk, rst, enc, se
   ) ;
   parameter initial_value = 0;
   parameter width = 32;   
   
   output reg [width-1:0] so;

   input [width-1:0]      si, skinnys;
   input 	     clk, rst, enc, se;

   wire 	     clki, enci;
   wire [width-1:0]  sr;

   assign enci = (clk == 0) ? enc : enci;   
   assign clki = enci & clk;
   assign sr = rst ? initial_value : si;   
   
   always @ (posedge clki) begin
      if (se) so <= sr;
      else so <= skinnys;
   end
   
endmodule // state_reg
