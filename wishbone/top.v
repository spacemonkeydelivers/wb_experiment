`include "wishbone.vh"

module top(
   input clk_i,
   input reset_i,
   input read_i,
   input write_i,
   input [`EXT_ADDR_WIDTH - 1:0] addr_i,
   input [`EXT_DATA_WIDTH - 1:0] data_i,
   output [`EXT_DATA_WIDTH - 1:0] data_o,
   output [15 : 0] ll_o
);

   localparam WB_SEL        = `WB_DATA_WIDTH / 8;
   wire [`WB_DATA_WIDTH - 1:0] wb_data_to_slave;
   wire [`WB_ADDR_WIDTH - 1:0] wb_addr;
   wire wb_cyc;
   wire wb_lock;
   wire [WB_SEL - 1:0] wb_sel;
   wire wb_stb;
   wire wb_we;
  
   wire [`WB_DATA_WIDTH - 1:0] wb_data_from_slave;
   wire wb_ack;

   wire wb_stall;
   assign wb_stall = 0;

   wire wb_err;
   assign wb_err = 0;

   wire wb_rty;
   assign wb_rty = 0;

   /* verilator lint_off UNUSED */
   wire [3:0] wb_tgdi;
   assign wb_tgdi = 0;
   wire [3:0] wb_tgdo;
   assign wb_tgdo = 0;
   wire [3:0] wb_tgao;
   assign wb_tgao = 0;
   wire [3:0] wb_tgco;
   assign wb_tgco = 0;


   wire [15 : 0] l;
   assign ll_o = l;

   wb_leds #(.WB_BUS_WIDTH(`WB_DATA_WIDTH),
             .WB_ADDR_WIDTH(`WB_ADDR_WIDTH))
   WB_LEDS(.wb_reset_i(reset_i),
           .wb_clk_i(clk_i),
           .wb_addr_i(wb_addr),
           .wb_data_i(wb_data_to_slave),
           .wb_cyc_i(wb_cyc),
           .wb_lock_i(wb_lock),
           .wb_sel_i(wb_sel),
           .wb_stb_i(wb_stb),
           .wb_we_i(wb_we),
           .wb_data_o(wb_data_from_slave),
           .wb_ack_o(wb_ack),
           .wb_stall_o(wb_stall),
           .wb_err_o(wb_err),
           .wb_rty_o(wb_rty),
           .leds_o(l));

   wb_pipeline_master #(.WB_BUS_WIDTH(`WB_DATA_WIDTH),
                        .WB_ADDR_WIDTH(`WB_ADDR_WIDTH),
                        .EXT_BUS_WIDTH(`EXT_DATA_WIDTH),
                        .EXT_ADDR_WIDTH(`EXT_ADDR_WIDTH))
   WB_MASTER(.ext_addr_i(addr_i),
             .ext_data_i(data_i),
             .ext_data_o(data_o),
             .ext_write_i(write_i),
             .ext_read_i(read_i),
             .ext_clk_i(clk_i),
             .wb_reset_i(reset_i),
             .wb_clk_i(clk_i),
             .wb_data_i(wb_data_from_slave),
             .wb_ack_i(wb_ack),
             .wb_stall_i(wb_stall),
             .wb_err_i(wb_err),
             .wb_rty_i(wb_rty),
             .wb_tgd_i(wb_tgdi),
             .wb_data_o(wb_data_to_slave),
             .wb_addr_o(wb_addr),
             .wb_cyc_o(wb_cyc),
             .wb_lock_o(wb_lock),
             .wb_sel_o(wb_sel),
             .wb_stb_o(wb_stb),
             .wb_we_o(wb_we),
             .wb_tgd_o(wb_tgdo),
             .wb_tga_o(wb_tgao),
             .wb_tgc_o(wb_tgco));
   

endmodule
