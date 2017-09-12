//TODO: add address check

module wb_leds(
   // Device reset
   input wb_reset_i,
   // Input clock
   input wb_clk_i,
   // input data to the device
   input [WB_BUS_WIDTH - 1:0] wb_data_i,
   // address on the bus
   /* verilator lint_off UNUSED */
   input [WB_ADDR_WIDTH - 1:0] wb_addr_i,
   // indicates that a valid bus cycle is in progress
   input wb_cyc_i,
   // indicates that the current bus cycle is uninterruptible
   /* verilator lint_off UNUSED */
   input wb_lock_i,
   // Access low or high bytes
   input [WB_SEL - 1:0] wb_sel_i,
   // indicates that the SLAVE is selected
   input wb_stb_i,
   // indicates whether the current local bus cycle is a READ or WRITE cycle
   input wb_we_i,
   // output data from the device
   output [WB_BUS_WIDTH - 1:0] wb_data_o,
   // indicates the termination of a normal bus cycle
   output wb_ack_o,
   // Slave can not accept additional transactions in its queue
   output wb_stall_o,
   // Abnormal cycle termination
   output wb_err_o,
   // indicates that the interface is not ready to accept or send data
   output wb_rty_o,
   output [LED_WIDTH - 1:0] leds_o
);
   parameter WB_BUS_WIDTH     = 16;
   parameter WB_ADDR_WIDTH    = 32;
   parameter WB_BUS_ADDR      = 32'h000000A0;
   parameter LED_WIDTH        = 16;
   localparam WB_SEL          = WB_BUS_WIDTH / 8;

   // assign unused signals
   assign wb_stall_o = 1'b0;
   assign wb_err_o = 1'b0;
   assign wb_rty_o = 1'b0;

   reg busy;
   assign wb_stall_o = busy;
   
   reg ack;
   assign wb_ack_o = ack;

   reg [LED_WIDTH - 1:0] leds;
   assign leds_o = leds;
  
   // never report error or retry
   assign wb_err_o = 0;
   assign wb_rty_o = 0;
   
   reg [WB_BUS_WIDTH - 1:0] output_data;
   assign wb_data_o = output_data;

   // data to write to the leds
   wire [WB_BUS_WIDTH - 1 : 0] data_w;

   wire addr_match;
   assign addr_match = (wb_addr_i == WB_BUS_ADDR);

   wire accessed;
   assign accessed = (wb_stb_i && wb_cyc_i && !wb_stall_o && addr_match);

   genvar i;
   generate
      for (i = 0; i < WB_SEL; i = i + 1) begin
         assign data_w[`ITH_BYTE(i)] = wb_sel_i[i] ? wb_data_i[`ITH_BYTE(i)] : leds[`ITH_BYTE(i)];
      end
   endgenerate

   always @ (posedge wb_clk_i) begin
      ack <= 0;
      output_data <= 0;
      // clear all data
      if (wb_reset_i) begin
         leds <= 0;
         output_data <= 0;
         busy <= 0;
      end
      else begin
         // if has strobe and cycle and doesn't have stall 
         if (accessed) begin
            // write leds to be lighten
            if (wb_we_i) begin
               leds <= data_w;
            end
            // read lighten leds
            else begin
               output_data <= leds;
            end
            // assert WB_ACK if it's not asserted
            if (!ack) begin
               ack <= 1;
            end
         end
      end
   end

endmodule
