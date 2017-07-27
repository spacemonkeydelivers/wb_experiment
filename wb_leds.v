module wb_leds(
   //parameter BUS_WIDTH = 16,
   //parameter ADDRESS_WIDTH = 32,
   //parameter BUS_ADDRESS = 16'hA0,
   // Device reset
   input wb_reset_i,
   // Input clock
   input wb_clk_i,
   // input data to the device
   input [16-1:0] wb_data_i,
   // address on the bus
   input [32-1:0] wb_addr_i,
   // indicates that a valid bus cycle is in progress
   input wb_cyc_i,
   // indicates that the current bus cycle is uninterruptible
   input wb_lock_i,
   // Access low or high bytes
   input [1:0] wb_sel_i,
   // indicates that the SLAVE is selected
   input wb_stb_i,
   // indicates whether the current local bus cycle is a READ or WRITE cycle
   input wb_we_i,
   // output data from the device
   output [16-1:0] wb_data_o,
   // indicates the termination of a normal bus cycle
   output wb_ack_o,
   // Slave can not accept additional transactions in its queue
   output wb_stall_o,
   // Abnormal cycle termination
   output wb_err_o,
   // indicates that the interface is not ready to accept or send data
   output wb_rty_o,
   output [7:0] leds_o
);

   reg busy;
   assign wb_stall_o = busy;
   
   reg ack;
   assign wb_ack_o = ack;

   reg [7:0] leds;
   assign leds_o = leds;
   
   assign wb_err_o = 0;
   assign wb_rty_o = 0;
   
   reg [16-1:0] output_data;
   assign wb_data_o = output_data;

   always @ (posedge wb_clk_i) begin
      // clear all data
      if (wb_reset_i) begin
         leds <= 0;
         output_data <= 0;
         busy <= 0;
         ack <= 0;
      end
      else begin         
         if (wb_stb_i && wb_cyc_i && !wb_stall_o) begin
            // write leds to be lighten
            if (wb_we_i) begin
               leds <= wb_data_i[7:0];
            end
            // read lighten leds
            else begin
               output_data <= leds;
            end
            // assert WB_ACK
            ack <= 1;
         end
         // deassert WB_ACK
         ack <= 0;
      end
   end

endmodule

enum {
   STATUS,
   DATA,
   ADDRESS_L,
   ADDRESS_H,
   RESULT
};

enum {
   ERROR_READ,
   ERROR_WRITE,
   DO_READ,
   DO_WRITE,
   RUN_WB,
   BUSY
} status_bits;

module wb_master(
   input [25:0] address_i,
   input [15:0] data_i,
   input write_i,
   input read_i,
   
   output [15:0] data_o,
   
   input wb_reset_i,
   input wb_clk_i,
   input wb_data_i,
   input wb_ack_i,
   input wb_stall_i,
   input wb_err_i,
   input wb_rty_i,
   
   output wb_data_o,
   output [31:0] wb_addr_o,
   output wb_cyc_o,
   output wb_lock_o,
   output [1:0] wb_sel_o,
   output wb_stb_o,
   output wb_we_o
);
   // store address to access WB with
   reg [31:0] address;
   // store data to put on WB
   reg [15:0] data;
   // data to put on the out bus
   reg [15:0] out;
   // result of WB read
   reg [15:0] result;
   // status register of the master
   reg [7:0] status;

   always @ (posedge wb_clk_i) begin
      if (wb_reset_i) begin
         data <= 0;
         status <= 0;
         result <= 0;
         out <= 0;
         address <= 0;
      end
      else begin
         if (write_i) begin
            case (address_i[7:0])
               // set operation type and run status
               8'dSTATUS: begin
                  // Do not clear busy flag
                  // May be don't clear ERR READ/WRITE
                  status[RUN_WB] <= data_i[RUN_WB];
                  status[DO_READ] <= data_i[DO_READ];
                  status[DO_WRITE] <= data_i[DO_WRITE];
                  status[ERROR_WRITE] <= data[ERROR_WRITE];
                  status[ERROR_READ] <= data[ERROR_READ];
               end
               // save data to write to wb
               8'dDATA: data <= data_i;
               // save low address part
               8'dADDRESS_L: address[15:0] <= data_i;
               // save high address part
               8'dADDRESS_H: address[31:16] <= data_i;
               // wrong address write, set error
               default: status[ERROR_WRITE] <= 1;
            endcase
         end
         if (read_i) begin
            case (address_i[7:0])
               // read status register
               8'dSTATUS: out[7:0] <= status;
               // read data value
               8'dDATA: out <= data;
               // read low address part
               8'dADDRESS_L: out <= address[15:0];
               // read high address part
               8'dADDRESS_H: out <= address[31:16];
               // read result
               8'dRESULT: out <= result;
               // put error on out bus
               default: out <= 16'hE550;
            endcase
         end
         if (status[RUN_WB]) begin
            // set busy flag
            status[BUSY] <= 1;
            // clear run wb flag
            status[RUN_WB] <= 0;
            // assert wb write
            wb_we_o <= status[DO_WRITE];
            // assert WB_CYC_O wire
            wb_cyc_o <= 1;
            // assert WB_STB_O wire
            wb_stb_o <= 1;
            // set WB address
            wb_addr_o <= address;
            // on WB_WRITE put data to slave
            if (status[DO_WRITE]) begin
               wb_data_o <= data;
            end
         end
         // do based on WB behaviour
         if (status[BUSY] && wb_ack_i) begin
            status[BUSY] <= 0;
            // clear wb write wire
            wb_we_o <= 0;
            // deassert WB_CYC_O wire
            wb_cyc_o <= 0;
            // deassert WB_STB_O wire
            wb_stb_o <= 0;
            // on WB_READ latch data from slave
            if (status[DO_READ]) begin
               result <= wb_data_i;
            end
         end
      end
   end

endmodule
