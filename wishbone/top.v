`include "wishbone.vh"

module top(
   input clk_i,
   input reset_i,
   input read_i,
   input write_i,
   input [`EXT_ADDR_WIDTH - 1:0] addr_i,
   input [`EXT_DATA_WIDTH - 1:0] data_i,
   output [`EXT_DATA_WIDTH - 1:0] data_o,
   output [`WB_DATA_WIDTH - 1:0] leds_1_o,
   output [`WB_DATA_WIDTH - 1:0] leds_2_o
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
   wire [`WB_DATA_WIDTH - 1:0] wb_data_from_slave_1;
   /* verilator lint_off UNUSED */
   wire [`WB_DATA_WIDTH - 1:0] wb_data_from_slave_2;
   wire wb_ack_1;
   wire wb_ack_2;
   wire wb_ack;
   wire wb_stall;
   wire wb_stall_1;
   wire wb_stall_2;
   wire wb_err;
   wire wb_err_1;
   wire wb_err_2;
   wire wb_rty;
   wire wb_rty_1;
   wire wb_rty_2;
   wire [`WB_DATA_WIDTH - 1:0] leds_1;
   wire [`WB_DATA_WIDTH - 1:0] leds_2;


   assign wb_ack = wb_ack_1 | wb_ack_2;
   assign wb_rty = wb_rty_1 | wb_rty_2;
   assign wb_err = wb_err_1 | wb_err_2;
   assign wb_stall = wb_stall_1 | wb_stall_2;
   assign wb_data_from_slave = wb_data_from_slave_1 | wb_data_from_slave_2;

   assign leds_1_o = leds_1;
   assign leds_2_o = leds_2;

   wb_leds #(.WB_BUS_WIDTH(`WB_DATA_WIDTH),
             .WB_ADDR_WIDTH(`WB_ADDR_WIDTH),
             .LED_WIDTH(`WB_DATA_WIDTH),
             .WB_BUS_ADDR(32'h00001000))
           WB_SLAVE_1(.wb_reset_i(reset_i),
                      .wb_clk_i(clk_i),
                      .wb_data_i(wb_data_to_slave),
                      .wb_addr_i(wb_addr),
                      .wb_cyc_i(wb_cyc),
                      .wb_lock_i(wb_lock),
                      .wb_sel_i(wb_sel),
                      .wb_stb_i(wb_stb),
                      .wb_we_i(wb_we),
                      .wb_data_o(wb_data_from_slave_1),
                      .wb_ack_o(wb_ack_1),
                      .wb_stall_o(wb_stall_1),
                      .wb_err_o(wb_err_1),
                      .wb_rty_o(wb_rty_1),
                      .leds_o(leds_1));

   wb_leds #(.WB_BUS_WIDTH(`WB_DATA_WIDTH),
             .WB_ADDR_WIDTH(`WB_ADDR_WIDTH),
             .LED_WIDTH(`WB_DATA_WIDTH),
             .WB_BUS_ADDR(32'h00002000))
           WB_SLAVE_2(.wb_reset_i(reset_i),
                      .wb_clk_i(clk_i),
                      .wb_data_i(wb_data_to_slave),
                      .wb_addr_i(wb_addr),
                      .wb_cyc_i(wb_cyc),
                      .wb_lock_i(wb_lock),
                      .wb_sel_i(wb_sel),
                      .wb_stb_i(wb_stb),
                      .wb_we_i(wb_we),
                      .wb_data_o(wb_data_from_slave_2),
                      .wb_ack_o(wb_ack_2),
                      .wb_stall_o(wb_stall_2),
                      .wb_err_o(wb_err_2),
                      .wb_rty_o(wb_rty_2),
                      .leds_o(leds_2));

   wb_master #(.WB_BUS_WIDTH(`WB_DATA_WIDTH),
               .WB_ADDR_WIDTH(`WB_ADDR_WIDTH),
               .EXT_BUS_WIDTH(`EXT_DATA_WIDTH),
               .EXT_ADDR_WIDTH(`EXT_ADDR_WIDTH),
               .LED_WIDTH(`WB_DATA_WIDTH))
             WB_MASTER(.ext_addr_i(addr_i),
                       .ext_data_i(data_i),
                       .ext_data_o(data_o),
                       .ext_write_i(write_i),
                       .ext_read_i(read_i),
                       .wb_reset_i(reset_i),
                       .wb_clk_i(clk_i),
                       .wb_data_i(wb_data_from_slave),
                       .wb_ack_i(wb_ack),
                       .wb_stall_i(wb_stall),
                       .wb_err_i(wb_err),
                       .wb_rty_i(wb_rty),
                       .wb_data_o(wb_data_to_slave),
                       .wb_addr_o(wb_addr),
                       .wb_cyc_o(wb_cyc),
                       .wb_lock_o(wb_lock),
                       .wb_sel_o(wb_sel),
                       .wb_stb_o(wb_stb),
                       .wb_we_o(wb_we));
   

endmodule
