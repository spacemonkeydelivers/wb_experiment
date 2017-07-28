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
   
   wire [WIDTH - 1: 0] first_op_shifted [0 : WIDTH];
   wire [WIDTH - 1: 0] result_tmp [0 : WIDTH * 2];
  
   genvar i;
   generate
      // get x
      for (i = 0; i < WIDTH; i = i + 1) begin
         assign first_op_shifted[i] = (i == 0) ? first_op_i : (first_op_shifted[i - 1] << 1) ^ (first_op_shifted[i - 1] & (1 << (WIDTH - 1)) ? poly_op_i : 0);
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


module xor_squash(
   input clk_i,
   input [TOTAL_WIDTH / 2 - 1 : 0] first_op_i,
   input [TOTAL_WIDTH / 2 - 1 : 0] second_op_i,
   input [SQUASH_WIDTH - 1 : 0]    result_o
);
   parameter TOTAL_WIDTH = 128;
   parameter SQUASH_WIDTH = 8;
   
   reg [SQUASH_WIDTH - 1 : 0] result;
   reg [SQUASH_WIDTH - 1 : 0] result_tmp;
   assign result_o = result;

   integer j;
   wire [SQUASH_WIDTH - 1 : 0] squashed_op [0 : TOTAL_WIDTH / SQUASH_WIDTH * 2 - 1];
   
   // save each SQUASH_WIDTH data to the array
   localparam n = TOTAL_WIDTH / SQUASH_WIDTH / 2;
   genvar i;
   generate
      for (i = 0; i < n; i = i + 1) begin
         assign squashed_op[i + n - 1] = first_op_i[SQUASH_WIDTH * (i + 1) - 1 : SQUASH_WIDTH * i] ^ second_op_i[SQUASH_WIDTH * (i + 1) - 1 : SQUASH_WIDTH * i];
      end      
      for (i = 0; i < n - 1; i = i + 1) begin
         assign squashed_op[i] = squashed_op[i * 2 + 1] ^ squashed_op[i * 2 + 2];
      end
   endgenerate   
   
   always @ (posedge clk_i) begin
      result <= squashed_op[0];
   end

endmodule


//1. ld.simd[] + replace -> res[63:0]
//2. galois.mul[63:0]    -> res[63:0]
//3. xor[63:0], [63:0]   -> res[7:0]
//4. shift[63:0], [63:0], [7:0] -> res[63:0], [63:0]
