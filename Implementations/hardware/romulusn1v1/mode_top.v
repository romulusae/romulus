module mode_top (/*AUTOARG*/
   // Outputs
   pdo, counter, constant,
   // Inputs
   pdi, sdi, domain, decrypt, clk, srst, senc, sse, xrst, xenc, xse,
   yrst, yenc, yse, zrst, zenc, zse, erst, correct_cnt, tk1s
   ) ;
   output [31:0] pdo;
   output [55:0] counter;   
   output [5:0]  constant;

   input [31:0]  pdi;
   input [31:0]  sdi;
   input [7:0] 	 domain;
   input [3:0] 	 decrypt;   
   input 	 clk;
   input 	 srst, senc, sse;
   input 	 xrst, xenc, xse;
   input 	 yrst, yenc, yse;
   input 	 zrst, zenc, zse;
   input 	 erst;  
   input 	 correct_cnt;
   input 	 tk1s;

   wire [127:0]  tk1, tk2;
   wire [63:0] 	 tk3;
   wire [127:0]  tka, tkb;
   wire [63:0] 	 tkc;
   wire [127:0]  skinnyS;
   wire [127:0]  skinnyX, skinnyY;
   wire [63:0] 	 skinnyZ;
   wire [127:0]  S, TKX, TKY, TKZZ;
   wire [63:0] 	 TKZ, TKZN;   
   wire [55:0]  cin;   

   assign counter = TKZ[63:8];
   
   state_update_32b STATE (.state(S), .pdo(pdo), .skinny_state(skinnyS), .pdi(pdi),
			   .clk(clk), .rst(srst), .enc(senc), .se(sse), .decrypt(decrypt));
   
   tkx_update_32b TKEYX (.tkx(TKX), .skinny_tkx(skinnyX), .skinny_tkx_revert(tk2), .sdi(sdi),
			 .clk(clk), .rst(xrst), .enc(xenc), .se(xse));
   
   tky_update_32b TKEYY (.tky(TKY), .skinny_tky(skinnyY), .skinny_tky_revert(tk1), .pdi(pdi),
			 .clk(clk), .rst(yrst), .enc(yenc), .se(yse));
   
   tkz_update_32b TKEYZ (.tkz(TKZ), .skinny_tkz(TKZN), .skinny_tkz_revert(tk3),
			 .clk(clk), .rst(zrst), .enc(zenc), .se(zse));

   assign cin = correct_cnt ? TKZ[63:8] : tkc[63:8];
   assign TKZZ = tk1s ? {TKZ, 64'h0} : 128'h0;
   assign TKZN = skinnyZ;   

   pt8 permA (.tk1o(tka), .tk1i(TKX));
   pt8 permB (.tk1o(tkb), .tk1i(TKY));
   pt4 permC (.tk1o(tkc), .tk1i(TKZ));

   lfsr_gf56 CNT (.so(tk3), .si(cin), .domain(domain));
   lfsr3_28 LFSR2 (.so(tk1), .si(tkb));
   lfsr2_28 LFSR3 (.so(tk2), .si(tka));

   RoundFunction SKINNY (.CLK(clk), .INIT(erst), .ROUND_KEY({TKZZ, TKY, TKX}), 
			 .ROUND_IN(S), .ROUND_OUT(skinnyS), .CONST_OUT(constant));
   KeyExpansion KEYEXP (.ROUND_KEY({skinnyZ, skinnyY, skinnyX}), .KEY({TKZ,TKY,TKX}));
   
   
   
   
   
   
endmodule // mode_top
