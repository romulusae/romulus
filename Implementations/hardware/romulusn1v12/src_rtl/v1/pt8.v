module pt8 (/*AUTOARG*/
   // Outputs
   tk1o,
   // Inputs
   tk1i
   ) ;
   output [127:0] tk1o;
   input  [127:0] tk1i;

   wire [127:0]   tk1 [7:0];   

   Permutation p0 (.Y(tk1[0]),.X(tk1i));
   Permutation p1 (.Y(tk1[1]),.X(tk1[0]));
   Permutation p2 (.Y(tk1[2]),.X(tk1[1]));
   Permutation p3 (.Y(tk1[3]),.X(tk1[2]));
   Permutation p4 (.Y(tk1[4]),.X(tk1[3]));
   Permutation p5 (.Y(tk1[5]),.X(tk1[4]));
   Permutation p6 (.Y(tk1[6]),.X(tk1[5]));
   Permutation p7 (.Y(tk1[7]),.X(tk1[6]));

   assign tk1o = tk1[7];

 
   
endmodule // pt8lfsr228
