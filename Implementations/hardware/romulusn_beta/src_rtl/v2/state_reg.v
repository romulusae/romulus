module state_reg (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si, skinnys, clk, rst, enc, se
   ) ;
   parameter initial_value = 0;
   parameter width = 32;   
   
   output reg [width-1:0] so;

   input [width-1:0]      si, skinnys;
   input 	     clk, rst, enc, se;
   
   always @ (posedge clk) begin
	   if (enc) begin
			if (se) so <= (rst) ? initial_value : si;
			else so <= skinnys;
		end
		else begin
		   so <= so;
		end
   end
   
endmodule // state_reg
