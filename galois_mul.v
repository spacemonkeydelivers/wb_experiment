module galois_mul(
   input                  clk_i,
   input  [WIDTH - 1 : 0] first_op_i,
   input  [WIDTH - 1 : 0] second_op_i,
   input  [WIDTH - 1 : 0] poly_op_i,
   output [WIDTH - 1 : 0] result_o
);
   parameter WIDTH = 8;
   reg [WIDTH - 1 : 0] result;
   reg [WIDTH - 1 : 0] result_tmp;
   assign result_o = result;
   
   wire [WIDTH : 0] first_op_shifted [0 : WIDTH - 1];
   
   genvar i;
   generate
      for (i = 0; i < WIDTH; i = i + 1) begin
         // shift first operand by i
         assign first_op_shifted[i][WIDTH - 1 : 0] = { first_op_i[WIDTH - 1 : i], {i{1'b0}} };
      end
   endgenerate
   
   integer j;
   
   always @* begin
      result_tmp = { (WIDTH){1'b0} };
      for(j = 0; j < WIDTH; j = j + 1) begin
         result_tmp = result_tmp ^ first_op_shifted[j][WIDTH - 1 : 0] & { (WIDTH){second_op_i[j]} } ^ ((first_op_shifted[j][WIDTH - 1] & 1) ? poly_op_i : 0);
      end
   end
   
   always @ (posedge clk_i) begin
      result <= result_tmp;
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
