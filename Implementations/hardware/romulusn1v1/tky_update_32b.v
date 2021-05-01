module tky_update_32b (/*AUTOARG*/
   // Outputs
   tky,
   // Inputs
   skinny_tky, skinny_tky_revert, pdi, clk, rst, enc, se
   ) ;
   output [127:0] tky;

   input [127:0]  skinny_tky;
   input [127:0]  skinny_tky_revert;   
   input [31:0]   pdi;
   input 	  clk, rst, enc, se;

   wire [127:0]   si;
   
   assign si = skinny_tky_revert;   
   
   key_reg_cg tky0 (.so(tky[31:0]),  .si(si[31:0]),  .skinnys(skinny_tky[31:0]),  .sld(pdi),       .clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tky1 (.so(tky[63:32]), .si(si[63:32]), .skinnys(skinny_tky[63:32]), .sld(tky[31:0]), .clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tky2 (.so(tky[95:064]),.si(si[95:64]), .skinnys(skinny_tky[95:64]), .sld(tky[63:32]),.clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tky3 (.so(tky[127:96]),.si(si[127:96]),.skinnys(skinny_tky[127:96]),.sld(tky[95:64]),.clk(clk),.rst(rst),.enc(enc),.se(se));	 
   
endmodule // tky_update_fn
