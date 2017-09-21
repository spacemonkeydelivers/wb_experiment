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
  // perform reset
  int tick = 0;
  wishbone.reset_i = 1;
  TICK_POS();
  TICK_NEG();
  TICK_POS();
  wishbone.reset_i = 0;
  TICK_NEG();

  wishbone.read_i = 1;
  wishbone.addr_i = 0x1234;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
  
  wishbone.read_i = 1;
  wishbone.addr_i = 0x5511;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();

  wishbone.read_i = 1;
  wishbone.addr_i = 0x9876;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
/*  
  wishbone.write_i = 1;
  wishbone.addr_i = 0x7777;
  wishbone.data_i = 0x7777;
  TICK_POS();
  wishbone.write_i = 0;
  TICK_NEG();

  wishbone.read_i = 1;
  wishbone.addr_i = 0x5678;
  TICK_POS();
  wishbone.read_i = 0;
  TICK_NEG();
*/
  TICK_POS();
  TICK_NEG();

  TICK_POS();
  TICK_NEG();

  TICK_POS();
  TICK_NEG();

  TICK_POS();
  TICK_NEG();

  TICK_POS();
  TICK_NEG();

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

