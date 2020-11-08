module lfsr_gf56 (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si, domain
   ) ;
   output [63:0] so;
   input [55:0]  si;
   input [7:0] 	  domain;

   wire [55:0] 	  lfsr, lfsrs, lfsrn;

   assign lfsr = {si[7:0],
		  si[15:8],
		  si[23:16],
		  si[31:24],
		  si[39:32],
		  si[47:40],
		  si[55:48]
		  };
   
   assign lfsrs = {lfsr[54:0],lfsr[55]};
   assign lfsrn = lfsrs ^ {lfsr[55],2'b0,lfsr[55],1'b0,lfsr[55],2'b0};   
   
   assign so = {lfsrn[7:0],
		lfsrn[15:8],
		lfsrn[23:16],
		lfsrn[31:24],
		lfsrn[39:32],
		lfsrn[47:40],
		lfsrn[55:48],
		domain};   

   
endmodule // lfsr_gf56

