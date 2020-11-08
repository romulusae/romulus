module tkz_update_32b (/*AUTOARG*/
   // Outputs
   tkz,
   // Inputs
   skinny_tkz, skinny_tkz_revert, clk, rst, enc, se
   ) ;
	parameter clock_gate = 0;

   output [63:0] tkz;

   input [63:0]  skinny_tkz;
   input [63:0]  skinny_tkz_revert;   
   input 	  clk, rst, enc, se;

   wire [63:0]   si;
   
   assign si = skinny_tkz_revert;   

   generate
	if (clock_gate == 1) begin 
      state_reg_cg #(.initial_value(32'h00000000)) tkz0 (.so(tkz[31:0]),  .si(si[31:0]),  .skinnys(skinny_tkz[31:0]),  .clk(clk),.rst(rst),.enc(enc),.se(se));
      state_reg_cg #(.initial_value(32'h01000000)) tkz1 (.so(tkz[63:32]), .si(si[63:32]), .skinnys(skinny_tkz[63:32]), .clk(clk),.rst(rst),.enc(enc),.se(se));
   end
	else begin
	end
   	state_reg #(.initial_value(32'h00000000)) tkz0 (.so(tkz[31:0]),  .si(si[31:0]),  .skinnys(skinny_tkz[31:0]),  .clk(clk),.rst(rst),.enc(enc),.se(se));
      state_reg #(.initial_value(32'h01000000)) tkz1 (.so(tkz[63:32]), .si(si[63:32]), .skinnys(skinny_tkz[63:32]), .clk(clk),.rst(rst),.enc(enc),.se(se));
	endgenerate
	
endmodule // tkz_update_32b

