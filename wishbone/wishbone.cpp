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
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.reset_i = 0;

  // set data
  wishbone.addr_i = DATA;
  wishbone.data_i = 0x1234;
  wishbone.write_i = 1;
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.write_i = 0;
  wishbone.data_i = 0x4321;
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  // read data
  int data_out = 0;
  wishbone.addr_i = DATA;
  wishbone.read_i = 1;
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  data_out = wishbone.data_o;
  fprintf(stderr, "Data: %x\n", data_out);
  wishbone.read_i = 0;
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  // set addr_h
  // get addr_h
  // set addr_l
  // get addr_l
  // set wb_sel
  wishbone.addr_i = WB_SELECT;
  wishbone.data_i = 0x3;
  wishbone.write_i = 1;
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  // get wb_sel
  // set write bits in status
//  wishbone.addr_i = STATUS;
  wishbone.addr_i = STATUS;
  wishbone.data_i = 1 << 3 | 1 << 4;
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.write_i = 0;
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 1;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  wishbone.clk_i = 0;
  wishbone.eval();
  if (dumpVcd){
    tfp->dump(tick);
    tick++;
  }
  // get status
  // set read bits in status
  // get status
  // read result
//  wishbone.write_i = 0;
//  wishbone.read_i = 1;
//  wishbone.addr_i = RESULT;


/*
  for (int tick = 0; tick < 0xff * 0xff; ++tick) {
    // neg edge
    fprintf(stderr, "Reference: result of %x and %x is %x\n", tick % 0xff, tick / 0xff, res);
    galois.clk_i = 0;
    galois.first_op_i = tick % 0xff;
    galois.second_op_i = tick / 0xff;
    galois.poly_op_i = 0xC3;
    galois.eval();
    if (dumpVcd){
      tfp->dump(tick);
    }
    // do not check results, don't know how to do it correctly for first tick
    // pos edge
    galois.clk_i = 1;
    galois.eval();
    if (dumpVcd){
      tfp->dump(tick);
    }
    fprintf(stderr, "Verilog: on tick %x data %x %x result %x\n", tick, tick % 0xff, tick / 0xff, galois.result_o);
    if (res != galois.result_o)
    {
        fprintf(stderr, "FAILED %x %x\n", res, galois.result_o);
        return 1;
    }
  }
  */
  wishbone.final();
  if (dumpVcd){
    tfp->close();
  }
  return 0;
}

