module pt4 (/*AUTOARG*/
   // Outputs
   tk1o,
   // Inputs
   tk1i, ad
   ) ;
   output [63:0] tk1o;
   input [63:0]  tk1i;
   input ad;

   wire [63:0]   tk1 [5:0];   

   HPermutation p0 (.Y(tk1[0]),.X(tk1i));
   HPermutation p1 (.Y(tk1[1]),.X(tk1[0]));
   HPermutation p2 (.Y(tk1[2]),.X(tk1[1]));
   HPermutation p3 (.Y(tk1[3]),.X(tk1[2]));
   HPermutation p4 (.Y(tk1[4]),.X(tk1[3]));
   HPermutation p5 (.Y(tk1[5]),.X(tk1[4]));

   assign tk1o = (ad == 0) ? tk1[5] : tk1[3];

 
   
endmodule // pt8lfsr228
