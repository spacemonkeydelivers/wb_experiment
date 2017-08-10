module wb_master(
   /* verilator lint_off UNUSED */
   input [EXT_ADDR_WIDTH - 1:0]  ext_addr_i,
   input [EXT_BUS_WIDTH - 1:0]   ext_data_i,
   output [EXT_BUS_WIDTH - 1:0]  ext_data_o,
   input ext_write_i,
   input ext_read_i,
   
   input wb_reset_i,
   input wb_clk_i,
   input [WB_BUS_WIDTH - 1:0] wb_data_i,
   input wb_ack_i,
   /* verilator lint_off UNUSED */
   input wb_stall_i,
   /* verilator lint_off UNUSED */
   input wb_err_i,
   /* verilator lint_off UNUSED */
   input wb_rty_i,
   
   output [WB_BUS_WIDTH - 1:0] wb_data_o,
   output [WB_ADDR_WIDTH - 1:0] wb_addr_o,
   output reg wb_cyc_o,
   output wb_lock_o,
   output [WB_SEL - 1:0] wb_sel_o,
   output reg wb_stb_o,
   output reg wb_we_o
);
   parameter WB_BUS_WIDTH   = 16;
   parameter WB_ADDR_WIDTH  = 32;
   parameter EXT_BUS_WIDTH  = 16;
   parameter EXT_ADDR_WIDTH = 26;
   parameter LED_WIDTH      = 16;
   localparam WB_SEL        = WB_BUS_WIDTH / 8;

   // enums
   localparam STATUS = 0;
   localparam DATA = 1;
   localparam ADDRESS_L = 2;
   localparam ADDRESS_H = 3;
   localparam RESULT = 4;
   localparam WB_SELECT = 5;
 
   localparam ERROR_READ = 0;
   localparam ERROR_WRITE = 1;
   localparam DO_READ = 2;
   localparam DO_WRITE = 3;
   localparam RUN_WB = 4;
   localparam BUSY = 5;
  
   // assign unused signals
   assign wb_lock_o = 1'b0;

   // store address to access WB with
   reg [WB_ADDR_WIDTH - 1:0] wb_addr;
   assign wb_addr_o = wb_addr;
   // store data to put on WB
   reg [WB_BUS_WIDTH - 1:0] wb_data;
   assign wb_data_o = wb_data;
   // result of WB read
   reg [WB_BUS_WIDTH - 1:0] wb_result;
   // wb select bits
   reg [WB_SEL - 1:0] wb_sel;
   assign wb_sel_o = wb_sel;
   
   // data to put on the external bus
   reg [EXT_BUS_WIDTH - 1:0] ext_data;
   assign ext_data_o = ext_data;
   // status register of the master
   reg [7:0] status;

   always @ (posedge wb_clk_i) begin
      if (wb_reset_i) begin
         wb_addr <= 0;
         wb_data <= 0;
         ext_data <= 0;
         wb_result <= 0;
         status <= 0;
         wb_sel <= 0;
      end
      else begin
         if (ext_write_i) begin
            // check external address
            case (ext_addr_i[7:0])
               // set operation type and run status
               STATUS: begin
                  // Do not clear busy flag
                  // May be don't clear ERR READ/WRITE
                  status[RUN_WB] <= ext_data_i[RUN_WB];
                  status[DO_READ] <= ext_data_i[DO_READ];
                  status[DO_WRITE] <= ext_data_i[DO_WRITE];
                  status[ERROR_WRITE] <= ext_data[ERROR_WRITE];
                  status[ERROR_READ] <= ext_data[ERROR_READ];
               end
               // save data to write to wb
               DATA: wb_data <= ext_data_i;
               // save low address part
               ADDRESS_L: wb_addr[15:0] <= ext_data_i;
               // save high address part
               ADDRESS_H: wb_addr[31:16] <= ext_data_i;
               // save select bits
               WB_SELECT: wb_sel <= ext_data_i[WB_SEL - 1:0];
               // wrong address write, set error
               default: status[ERROR_WRITE] <= 1;
            endcase
         end
         if (ext_read_i) begin
            case (ext_addr_i[7:0])
               // read status register
               STATUS: ext_data[7:0] <= status;
               // read data value
               DATA: ext_data <= wb_data;
               // read low address part
               ADDRESS_L: ext_data <= wb_addr[15:0];
               // read high address part
               ADDRESS_H: ext_data <= wb_addr[31:16];
               // read result
               RESULT: ext_data <= wb_result;
               // wb select
               WB_SELECT: ext_data <= {{EXT_BUS_WIDTH - WB_SEL{1'b0}},{wb_sel}};
               // put error on the external bus
               default: ext_data <= 16'hE550;
            endcase
         end
         // if RUN bit is set in status register
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
               wb_result <= wb_data_i;
            end
         end
      end
   end

endmodule
