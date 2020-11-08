module mode_top (/*AUTOARG*/
   // Outputs
		 pdo, counter,
   // Inputs
   pdi, sdi, con, clk, sen, sdec, schain, smxc, smode, srst, domain,
   tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n, tk2ksch,
   tk2in, tk2chain, tk2correct, tk3ksch, tk3in, tk3chain, tk3correct
   ) ;
   output [7:0] pdo;
   output [55:0] 	counter;   
   input [7:0] 	pdi, sdi, con;
   input 	clk;

   input [3:0] 	sen;
   input 	sdec, schain, smxc, smode, srst;
   input [7:0] 	domain;   
   input 	tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n;
   input 	tk2ksch, tk2in, tk2chain, tk2correct;	
   input 	tk3ksch, tk3in, tk3chain, tk3correct;	

   wire [7:0] ski, tk1o, tk2o, tk3o;	

   assign ski = tk1s ? (tk1n ? tk2o^tk3o : tk1o^tk2o^tk3o) : 8'h00;
   state_serial skinny (pdo, pdi, ski, con, sen, sdec, clk, schain, smxc, smode, srst);
   tk1 blockcounter (tk1o, counter, domain, clk, tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt);
   tk2 nonce (tk2o, pdi, clk, tk2ksch, tk2in, tk2chain, tk2correct);
   tk3 key (tk3o, sdi, clk, tk3ksch, tk3in, tk3chain, tk3correct);
   
   
endmodule // mode_top
