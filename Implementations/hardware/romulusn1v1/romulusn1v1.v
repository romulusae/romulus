module romulusn1v1 (/*AUTOARG*/
   // Outputs
   pdo_data, pdi_ready, sdi_ready, pdo_valid,
   // Inputs
   pdi_data, sdi_data, pdi_valid, sdi_valid, pdo_ready, clk, rst
   ) ;
   output [31:0] pdo_data;
   output 	 pdi_ready, sdi_ready, pdo_valid;

   input [31:0]  pdi_data, sdi_data;
   input 	 pdi_valid, sdi_valid, pdo_ready;

   input 	 clk, rst;

   wire [31:0] 	 pdo, pdi;

   wire [7:0] domain;
   wire [3:0] decrypt;
   
   wire		     srst, senc, sse;
   wire		     xrst, xenc, xse;
   wire		     yrst, yenc, yse;
   wire		     zrst, zenc, zse;
   wire		     erst;
   wire 	     tk1s;   

   wire [55:0]      counter;
   wire [5:0] 	    constant;
   wire 	    correct_cnt;   

   mode_top datapath (
		      // Outputs
		      pdo, counter, constant,
		      // Inputs
		      pdi, sdi_data, domain, decrypt, clk, srst, senc, sse, xrst, xenc, xse,
		      yrst, yenc, yse, zrst, zenc, zse, erst, correct_cnt, tk1s
		      ) ;
   api control (
		// Outputs
		pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, domain,
		srst, senc, sse, xrst, xenc, xse, yrst, yenc, yse, zrst, zenc, zse,
		erst, decrypt, correct_cnt, tk1s,
		// Inputs
		counter, pdi_data, pdo, pdi_valid, sdi_valid, pdo_ready,
		clk, rst, constant
		) ;
   
   
endmodule // romulusn1v1

