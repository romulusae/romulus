module tk2 (/*AUTOARG*/
   // Outputs
   ko,
   // Inputs
   ki, clk, ksch, in, chain, correct
   ) ;
   output [7:0] ko;
   input  [7:0] ki;
   
   input 	clk, ksch, in, chain, correct;   

   reg [7:0] 	tk [15:0];
   wire [127:0] tkb,tk1;   
   wire [7:0] 	fb;

   assign fb = in ? ki : ko;  

   always @ (posedge clk) begin
      if (ksch) begin
	 tk[15] <= {tk[6][6:0],tk[6][7]^tk[6][5]};
	 tk[14] <= {tk[0][6:0],tk[0][7]^tk[0][5]};
	 tk[13] <= {tk[7][6:0],tk[7][7]^tk[7][5]};
	 tk[12] <= {tk[2][6:0],tk[2][7]^tk[2][5]};
	 tk[11] <= {tk[5][6:0],tk[5][7]^tk[5][5]};
	 tk[10] <= {tk[1][6:0],tk[1][7]^tk[1][5]};
	 tk[9]	<= {tk[3][6:0],tk[3][7]^tk[3][5]};
	 tk[8]	<= {tk[4][6:0],tk[4][7]^tk[4][5]};
	 tk[7]  <= tk[15];
	 tk[6]  <= tk[14];
	 tk[5]  <= tk[13];
	 tk[4]  <= tk[12];
	 tk[3]  <= tk[11];
	 tk[2]  <= tk[10];
	 tk[1]  <= tk[9];
	 tk[0]  <= tk[8];
      end
      else if (chain) begin
	 tk[15] <= tk[14]; 
	 tk[14] <= tk[13]; 
	 tk[13] <= tk[12]; 
	 tk[12] <= tk[11]; 
	 tk[11] <= tk[10]; 
	 tk[10] <= tk[9]; 
	 tk[9]	<= tk[8]; 
	 tk[8]	<= tk[7]; 
	 tk[7]  <= tk[6]; 
	 tk[6]  <= tk[5]; 
	 tk[5]  <= tk[4]; 
	 tk[4]  <= tk[3]; 
	 tk[3]  <= tk[2]; 
	 tk[2]  <= tk[1]; 
	 tk[1]  <= tk[0]; 
	 tk[0]  <= fb; 
      end
      else if (correct) begin
	 tk[15] <= tk1[127:120];
	 tk[14] <= tk1[119:112];
	 tk[13] <= tk1[111:104];
	 tk[12] <= tk1[103:96];
	 tk[11] <= tk1[95:88];
	 tk[10] <= tk1[87:80]; 
	 tk[9]	<= tk1[79:72]; 
	 tk[8]	<= tk1[71:64]; 
	 tk[7]	<= tk1[63:56]; 
	 tk[6]	<= tk1[55:48]; 
	 tk[5]	<= tk1[47:40]; 
	 tk[4]	<= tk1[39:32]; 
	 tk[3]	<= tk1[31:24]; 
	 tk[2]	<= tk1[23:16]; 
	 tk[1]	<= tk1[15:8]; 
	 tk[0]  <= tk1[7:0];    	 
      end
   end

   pt8 correction (tkb, {tk[15],
			 tk[14],
			 tk[13],
			 tk[12],
			 tk[11],
			 tk[10],
			 tk[9],
			 tk[8],
			 tk[7],
			 tk[6],
			 tk[5],
			 tk[4],
			 tk[3],
			 tk[2],
			 tk[1],
			 tk[0]
			 });
   lfsr3_28 LFSR2 (.so(tk1), .si(tkb));
   
   assign ko = tk[15];   
   
   
endmodule // tk2
