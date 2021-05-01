module tkx_update_32b (/*AUTOARG*/
   // Outputs
   tkx,
   // Inputs
   skinny_tkx, skinny_tkx_revert, sdi, clk, rst, enc, se
   ) ;
   output [127:0] tkx;

   input [127:0]  skinny_tkx;
   input [127:0]  skinny_tkx_revert;   
   input [31:0]   sdi;
   input 	  clk, rst, enc, se;

   wire [127:0]   si;
   
   assign si = skinny_tkx_revert;   
   
   key_reg_cg tkx0 (.so(tkx[31:0]),  .si(si[31:0]),  .skinnys(skinny_tkx[31:0]),  .sld(sdi),       .clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tkx1 (.so(tkx[63:32]), .si(si[63:32]), .skinnys(skinny_tkx[63:32]), .sld(tkx[31:0]), .clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tkx2 (.so(tkx[95:064]),.si(si[95:64]), .skinnys(skinny_tkx[95:64]), .sld(tkx[63:32]),.clk(clk),.rst(rst),.enc(enc),.se(se));
   key_reg_cg tkx3 (.so(tkx[127:96]),.si(si[127:96]),.skinnys(skinny_tkx[127:96]),.sld(tkx[95:64]),.clk(clk),.rst(rst),.enc(enc),.se(se));	 
   
endmodule // tkx_update_fn
