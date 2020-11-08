module LWC (/*AUTOARG*/
   // Outputs
   do_data, pdi_ready, sdi_ready, do_valid, do_last,
   // Inputs
   pdi_data, sdi_data, pdi_valid, sdi_valid, do_ready, clk, rst
   ) ;
   output [7:0] do_data;
   output 	 pdi_ready, sdi_ready, do_valid, do_last;

   input [7:0]  pdi_data, sdi_data;
   input 	 pdi_valid, sdi_valid, do_ready;

   input 	 clk, rst;

   wire [7:0] 	 pdo, pdi;
   wire [55:0] 	counter;   
   wire [7:0] 	con;

   wire [3:0] 	sen;
   wire 	sdec, schain, smxc, smode, srst;
   wire [7:0] 	domain;   
   wire 	tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n;
   wire 	tk2ksch, tk2in, tk2chain, tk2correct;	
   wire 	tk3ksch, tk3in, tk3chain, tk3correct;	

   mode_top datapath (pdo, counter,
		      pdi, sdi_data, con, clk, sen, sdec, schain, smxc, smode, srst, 
		      domain,
		      tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n,
		      tk2ksch,
		      tk2in, tk2chain, tk2correct, tk3ksch, tk3in, tk3chain, 
		      tk3correct
		      ) ;

   api cu (do_data, pdi, pdi_ready, sdi_ready, do_valid, do_last, domain,
	   con, sen, sdec, schain, smxc, smode, srst, tk1se, tk1ksch,
	   tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n, tk2ksch, tk2in, tk2chain,
	   tk2correct, tk3ksch, tk3in, tk3chain, tk3correct,
	   counter, pdi_data, pdo, sdi_data, pdi_valid, sdi_valid, do_ready,
	   clk, rst
	   ) ;

   
endmodule // LWC
