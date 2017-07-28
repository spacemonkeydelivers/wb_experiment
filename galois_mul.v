module galois_mul(
   input                  clk_i,
   input  [WIDTH - 1 : 0] first_op_i,
   input  [WIDTH - 1 : 0] second_op_i,
   input  [WIDTH - 1 : 0] poly_op_i,
   output [WIDTH - 1 : 0] result_o
);
   parameter WIDTH = 8;
   reg [WIDTH - 1 : 0] result;
   assign result_o = result;
  
   /* verilator lint_off UNOPTFLAT */ 
   wire [WIDTH - 1: 0] first_op_shifted [0 : WIDTH];
   /* verilator lint_off UNOPTFLAT */ 
   wire [WIDTH - 1: 0] result_tmp [0 : WIDTH * 2];
  
   genvar i;
   generate
      // get x
      for (i = 0; i < WIDTH; i = i + 1) begin
         assign first_op_shifted[i] = (i == 0) ? first_op_i : (first_op_shifted[i - 1] << 1) ^ (first_op_shifted[i - 1][WIDTH - 1] ? poly_op_i : 0);
      end
      // x & y
      for (i = 0; i < WIDTH; i = i + 1) begin
         assign result_tmp[i + WIDTH - 1] = { (WIDTH){second_op_i[i]} } & first_op_shifted[i];
      end
      // xor all x to result 
      for (i = 0; i < WIDTH - 1; i = i + 1) begin
         assign result_tmp[i] = result_tmp[i * 2 + 1] ^ result_tmp[i * 2 + 2];
      end
   endgenerate
 
   always @ (posedge clk_i) begin
      result <= result_tmp[0];
   end

endmodule


