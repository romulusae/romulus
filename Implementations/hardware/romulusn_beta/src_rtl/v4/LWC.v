module LWC (/*AUTOARG*/
   // Outputs
   do_data, pdi_ready, sdi_ready, do_valid, do_last,
   // Inputs
   pdi_data, sdi_data, pdi_valid, sdi_valid, do_ready, clk, rst
   ) ;
   output [31:0] do_data;
   output 	 pdi_ready, sdi_ready, do_valid, do_last;

   input [31:0]  pdi_data, sdi_data;
   input 	 pdi_valid, sdi_valid, do_ready;

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
   wire [5:0] 	    constant, constant2, constant3, constant4;
   wire [5:0] 	    constant5, constant6, constant7, constant8;
   wire 	    correct_cnt;   

   mode_top datapath (
		      // Outputs
		      pdo, counter,
		      // Inputs
		      pdi, sdi_data, domain, decrypt, clk, srst, senc, sse, xrst, xenc, xse,
		      yrst, yenc, yse, zrst, zenc, zse, erst, correct_cnt, constant, constant2, constant3, constant4,
            constant5, constant6, constant7, constant8, tk1s
		      ) ;
   api control (
		// Outputs
		do_data, pdi, pdi_ready, sdi_ready, do_valid, do_last, domain,
		srst, senc, sse, xrst, xenc, xse, yrst, yenc, yse, zrst, zenc, zse,
		erst, decrypt, correct_cnt, constant, constant2, constant3, constant4,
		constant5, constant6, constant7, constant8, tk1s,
		// Inputs
		counter, pdi_data, pdo, sdi_data, pdi_valid, sdi_valid, do_ready,
		clk, rst
		) ;
   
   
endmodule // romulusn1v12rb

