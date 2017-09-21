module wb_pipeline_master(
   // external address to operate on
   input [EXT_ADDR_WIDTH - 1:0]  ext_addr_i,
   // external data to operate 
   input [EXT_BUS_WIDTH - 1:0]   ext_data_i,
   // data to the external
   output [EXT_BUS_WIDTH - 1:0]  ext_data_o,
   // external write request
   input ext_write_i,
   // external read request
   input ext_read_i,
   // another input clock from the external?
   input ext_clk_i,
    
   // reset WB state
   input wb_reset_i,
   // wb part clock  
   input wb_clk_i,
   // data to be read from the WB
   input [WB_BUS_WIDTH - 1:0] wb_data_i,
   // termination of a normal bus cycle
   input wb_ack_i,
   // current slave is not able to accept the transfer
   input wb_stall_i,
   // abnormal cycle termination
   input wb_err_i,
   // interface is not ready to accept or send data, cycle should be retried
   input wb_rty_i,
   // tag associated with the input data 
   input [TAG_WIDTH - 1 : 0] wb_tgd_i,
   
   // data to put on the WB
   output [WB_BUS_WIDTH - 1:0] wb_data_o,
   // address to put on the bus
   output [WB_ADDR_WIDTH - 1:0] wb_addr_o,
   // indicates a valid bus cycle, asserted for the duration of all bys cycles
   output wb_cyc_o,
   // select the data size for the transaction
   output [WB_SEL_WIDTH - 1:0] wb_sel_o,
   // indicates a valid data transfer cycle
   output wb_stb_o,
   // if asserted to 1, means this is a write cycle
   output wb_we_o,
   // current bus cycle is uninterruptible
   output wb_lock_o,
   // tag associated with the transaction address
   output [TAG_WIDTH - 1 : 0] wb_tga_o,
   // tag associated with the cycle
   output [TAG_WIDTH - 1 : 0] wb_tgc_o,
   // tag associated with the output data
   output [TAG_WIDTH - 1 : 0] wb_tgd_o
);
   localparam BYTE_SIZE     = 8;
   localparam SHORT_SIZE    = BYTE_SIZE * 2;
   localparam WORD_SIZE     = BYTE_SIZE * 4;
   localparam DWORD_SIZE    = BYTE_SIZE * 8;
   parameter WB_BUS_WIDTH   = 16;
   parameter WB_ADDR_WIDTH  = 32;
   parameter EXT_BUS_WIDTH  = 16;
   parameter EXT_ADDR_WIDTH = 26;
   parameter LED_WIDTH      = 16;
   parameter TAG_WIDTH      = 4;
   localparam WB_SEL_WIDTH  = WB_BUS_WIDTH / BYTE_SIZE;

   localparam STATE_IDLE = 0;
   localparam STATE_BUSY = 1;

   // assert to 0 unused signals
   assign wb_tga_o = 0;
   assign wb_tgc_o = 0;
   assign wb_tgd_o = 0;
   assign wb_lock_o = 0;

   reg [10:0] state;

   // dual clock fifo to queue requests? 


   // asserted to 1 if any external request is present
   wire accessed;
   assign accessed = ext_read_i || ext_write_i;

   always @ (posedge wb_clk_i) begin
      if (wb_reset_i) begin
         state <= STATE_IDLE;
      end else begin
         if (state == STATE_IDLE && accessed) begin
            state <= STATE_BUSY;
         end else if (state == STATE_BUSY) begin
            state <= STATE_IDLE;
         end
      end
   end

endmodule
