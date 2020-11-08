module pt4 (/*AUTOARG*/
   // Outputs
   tk1o,
   // Inputs
   tk1i
   ) ;
   output [63:0] tk1o;
   input  [63:0] tk1i;

   wire [63:0]   tk1 [3:0];   

   HPermutation p0 (.Y(tk1[0]),.X(tk1i));
   HPermutation p1 (.Y(tk1[1]),.X(tk1[0]));
   HPermutation p2 (.Y(tk1[2]),.X(tk1[1]));
   HPermutation p3 (.Y(tk1[3]),.X(tk1[2]));

   assign tk1o = tk1[3];

 
   
endmodule // pt8lfsr228
