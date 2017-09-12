#include <verilated.h>
#include "Vtop.h"
//#include "Vperm_table_perm_table.h"
#include <random>
#include <iostream>
#include <iomanip>
#include "verilated_vcd_c.h"
#include "wishbone.h"

// TODO: use args instead
#define VCD_DUMP_FILE "dump.vcd"
// TODO: redesign classes to get rid of globals
VerilatedVcdC* tfp;
// Or use sort of ifdef?
bool dumpVcd = true;


#define TICK_NEG()   wishbone.clk_i = 0; \
                     wishbone.eval(); \
                     if (dumpVcd){ \
                         tfp->dump(tick); \
                     } \
                     tick++;

#define TICK_POS() wishbone.clk_i = 1; \
                   wishbone.eval(); \
                   if (dumpVcd){ \
                       tfp->dump(tick); \
                   } \
                   tick++;


int main(int argc, char **argv){
  // TODO: use args instead
  Verilated::commandArgs(argc, argv);
  Vtop wishbone;
  if (dumpVcd) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    wishbone.trace (tfp, 99);
    tfp->open(VCD_DUMP_FILE);
  }
  /* 
  input clk_i,
   input reset_i,
   input read_i,
   input write_i,
   input [`EXT_ADDR_WIDTH - 1:0] addr_i,
   input [`EXT_DATA_WIDTH - 1:0] data_i,
   output [`EXT_DATA_WIDTH - 1:0] data_o,
   output [`WB_DATA_WIDTH - 1:0] leds_o

   enum {
   STATUS,
   DATA,
   ADDRESS_L,
   ADDRESS_H,
   RESULT,
   WB_SELECT
};

enum {
   ERROR_READ,
   ERROR_WRITE,
   DO_READ,
   DO_WRITE,
   RUN_WB,
   BUSY
} status_bits;
*/
  // perform reset
  int tick = 0;
  wishbone.reset_i = 1;
  TICK_POS();
  TICK_NEG();
  TICK_POS();
  wishbone.reset_i = 0;
  TICK_NEG();


  // set data
  wishbone.addr_i = DATA;
  wishbone.data_i = 0x1234;
  wishbone.write_i = 1;
  TICK_POS();

  wishbone.write_i = 0;
  wishbone.data_i = 0x4321;
  TICK_NEG();

  //read data
  int data_out = 0;
  wishbone.addr_i = DATA;
  wishbone.read_i = 1;
  TICK_POS();
  data_out = wishbone.data_o;
  fprintf(stderr, "Data: %x\n", data_out);
  wishbone.read_i = 0;
  TICK_NEG();


  // set write mode
  wishbone.addr_i = STATUS;
  wishbone.data_i = (1 << DO_WRITE);
  wishbone.write_i = 1;
  TICK_POS();
  TICK_NEG();

  // set WB_SEL
  wishbone.addr_i = WB_SELECT;
  wishbone.data_i = (1 << 1);
  TICK_POS();
  TICK_NEG();

  // run wb transact
  wishbone.addr_i = WB_RUN;
  TICK_POS();
  wishbone.write_i = 0;
  TICK_NEG();

  // skip a cycle after the wb transact
  TICK_POS();
  TICK_NEG();

  // request read from the slave
  wishbone.addr_i = STATUS;
  wishbone.data_i = (1 << DO_READ);
  wishbone.write_i = 1;
  TICK_POS();
//  wishbone.write_i = 0;
  TICK_NEG();
  
  // run WB transact
  wishbone.write_i = 1;
  wishbone.addr_i = WB_RUN;
  TICK_POS();
  wishbone.write_i = 0;
  TICK_NEG();
  
  // skip a cycle after the wb transact
  TICK_POS();
  TICK_NEG();

  wishbone.addr_i = RESULT;
  wishbone.read_i = 1;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
  fprintf(stderr, "Data from wb: %x\n", wishbone.data_o);

  wishbone.addr_i = STATUS;
  wishbone.read_i = 1;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
  fprintf(stderr, "Status from wb: %x\n", wishbone.data_o);

  wishbone.addr_i = RESULT;
  wishbone.read_i = 1;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
  fprintf(stderr, "Data from wb: %x\n", wishbone.data_o);


  TICK_POS();
  TICK_NEG();
  TICK_POS();
  TICK_NEG();
  TICK_POS();
  TICK_NEG();

  wishbone.final();
  if (dumpVcd){
    tfp->close();
  }
  return 0;
}

