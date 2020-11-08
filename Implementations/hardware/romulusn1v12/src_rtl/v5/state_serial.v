module state_serial (/*AUTOARG*/
   // Outputs
   pdo,
   // Inputs
   pdi, a, con, en, dec, clk, chain, mxc, mode, rst
   ) ;
   output [7:0] pdo;
   input  [7:0] pdi, a, con;
   input [3:0] 	en;
   input 	dec;   
   input 	clk, chain, mxc, mode, rst;

   reg [7:0] 	s [15:0];
   wire [7:0] 	gs, satk, smode, sb; 
   wire [7:0] 	m [3:0];
   wire [7:0] 	pdi_eff;   

   always @ (posedge clk) begin
      if (en[3]) s[15] <= s[14];
      if (en[3]) s[14] <= s[13];
      if (en[3]) s[13] <= s[12];
      if (en[3]) s[12] <= chain ? s[11] : m[0];
      if (en[2]) s[11] <= s[10];
      if (en[2]) s[10] <= s[9];
      if (en[2]) s[9]  <= s[8];
      if (en[2]) s[8]  <= chain ? s[7] : mxc ? m[1] : s[11];
      if (en[1]) s[7]  <= s[6];
      if (en[1]) s[6]  <= s[5];
      if (en[1]) s[5]  <= s[4];
      if (en[1]) s[4]  <= chain ? s[3] : mxc ? m[2] : s[7];
      if (en[0]) s[3]  <= s[2];
      if (en[0]) s[2]  <= s[1];
      if (en[0]) s[1]  <= s[0];
      if (en[0]) s[0]  <= chain ? smode : mxc ? m[3] : s[3];
   end // always @ (posedge clk)

   assign pdi_eff = dec ? pdo : pdi;   
   assign gs = {s[15][7]^s[15][0],s[15][7:1]};
   assign smode = mode ? (rst ? 8'h0 : pdi_eff ^ s[15]) : satk;
   assign pdo = gs ^ pdi;

   sbox Sbox (s[15],sb);
   assign satk = sb ^ a ^ con;

   assign m[0] = m[3] ^ s[3];
   assign m[1] = s[15];
   assign m[2] = s[11] ^ s[7];   
   assign m[3] = s[15] ^ s[7];
   
endmodule // state
