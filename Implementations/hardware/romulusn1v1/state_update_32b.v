module state_update_32b (/*AUTOARG*/
   // Outputs
   state, pdo,
   // Inputs
   skinny_state, pdi, clk, rst, enc, se, decrypt
   ) ;
   output [127:0] state;
   output [31:0]  pdo;   

   input  [127:0] skinny_state;
   input [31:0]   pdi;
   input 	  clk, rst, enc, se;
   input [3:0]	  decrypt;   

   wire [127:0]   si;
   wire [31:0]   gofs;
   wire [31:0] 	  state_buf;   
   wire [31:0] 	  pdi_eff;

   assign pdi_eff[7:0] = decrypt[0]   ? pdo[7:0] : pdi[7:0];
   assign pdi_eff[15:8] = decrypt[1]  ? pdo[15:8] : pdi[15:8];
   assign pdi_eff[23:16] = decrypt[2] ? pdo[23:16] : pdi[23:16];
   assign pdi_eff[31:24] = decrypt[3] ? pdo[31:24] : pdi[31:24];
   
   assign si = {state[95:0], pdi_eff^state[127:96]};

   assign state_buf = state[127:96];
   assign gofs[7:0] = {state_buf[0]^state_buf[7],state_buf[7:1]};
   assign gofs[15:8] = {state_buf[8]^state_buf[15],state_buf[15:9]};
   assign gofs[23:16] = {state_buf[16]^state_buf[23],state_buf[23:17]};
   assign gofs[31:24] = {state_buf[24]^state_buf[31],state_buf[31:25]};
   assign pdo = pdi ^ gofs;   

   state_reg_cg s0 (.so(state[31:0])  ,.si(si[31:0])  ,.skinnys(skinny_state[31:0])  ,.clk(clk),.rst(rst),.enc(enc),.se(se));
   state_reg_cg s1 (.so(state[63:32]) ,.si(si[63:32]) ,.skinnys(skinny_state[63:32]) ,.clk(clk),.rst(rst),.enc(enc),.se(se));
   state_reg_cg s2 (.so(state[95:64]) ,.si(si[95:64]) ,.skinnys(skinny_state[95:64]) ,.clk(clk),.rst(rst),.enc(enc),.se(se));
   state_reg_cg s3 (.so(state[127:96]),.si(si[127:96]),.skinnys(skinny_state[127:96]),.clk(clk),.rst(rst),.enc(enc),.se(se));
   
   
endmodule // state_update_fn
