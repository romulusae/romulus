module tk1 (/*AUTOARG*/
   // Outputs
   ko, lfsr,
   // Inputs
   domain, clk, se, ksch, chain, rst, correct_cnt
   ) ;
   output [7:0] ko;
   output [55:0] lfsr;   
   input  [7:0] domain;
   input 	clk, se, ksch, chain, rst, correct_cnt;

   reg [7:0] 	tk [7:0];

   wire [55:0] 	lfsrs, lfsrn;
   wire [63:0] 	tkc;

   assign ko = tk[7];  

   assign lfsr = correct_cnt ? {tk[1],
				tk[2],
				tk[3],
				tk[4],
				tk[5],
				tk[6],
				tk[7]
				} :
		 {tkc[15:8],
		  tkc[23:16],
		  tkc[31:24],
		  tkc[39:32],
		  tkc[47:40],
		  tkc[55:48],
		  tkc[63:56]};
   
   assign lfsrs = {lfsr[54:0],lfsr[55]};
   assign lfsrn = lfsrs ^ {lfsr[55],2'b0,lfsr[55],1'b0,lfsr[55],2'b0};

   always @ (posedge clk) begin
      if (se) begin
	 if (rst) begin
	    tk[7] <= 'h01;
	    tk[6] <= 'h00;
	    tk[5] <= 'h00;
	    tk[4] <= 'h00;
	    tk[3] <= 'h00;
	    tk[2] <= 'h00;
		 tk[1] <= 'h00;
	    tk[0] <= 'h00;
	 end
	 else if (chain) begin
	    tk[7] <= tk[6];
	    tk[6] <= tk[5];
	    tk[5] <= tk[4];
	    tk[4] <= tk[3];
	    tk[3] <= tk[2];
	    tk[2] <= tk[1];
	    tk[1] <= tk[0];
	    tk[0] <= tk[7];
	 end
	 else if (ksch) begin
	    tk[7] <= tk[6];
	    tk[6] <= tk[0];
	    tk[5] <= tk[7];
	    tk[4] <= tk[2];
	    tk[3] <= tk[5];
	    tk[2] <= tk[1];
	    tk[1] <= tk[3];
	    tk[0] <= tk[4];
	 end // else: !if(chain)
	 else begin
	    tk[7] <= lfsrn[7:0];
	    tk[6] <= lfsrn[15:8];
	    tk[5] <= lfsrn[23:16];
	    tk[4] <= lfsrn[31:24];
	    tk[3] <= lfsrn[39:32];
	    tk[2] <= lfsrn[47:40];
	    tk[1] <= lfsrn[55:48];
	    tk[0] <= domain;	 
	 end // else: !if(rst)
      end // if (se)      
   end // always @ (posedge clk)

   pt4 permC (.tk1o(tkc), .tk1i({tk[7],
				 tk[6],
				 tk[5],
				 tk[4],
				 tk[3],
				 tk[2],
				 tk[1],
				 tk[0]})
				 );
   
endmodule // tk1
