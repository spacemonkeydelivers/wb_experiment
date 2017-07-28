#include <verilated.h>
#include "Vgalois_mul.h"
//#include "Vperm_table_perm_table.h"
#include <random>
#include <iostream>
#include <iomanip>
#include "verilated_vcd_c.h"

// TODO: use args instead
#define VCD_DUMP_FILE "dump.vcd"
// TODO: redesign classes to get rid of globals
VerilatedVcdC* tfp;
// Or use sort of ifdef?
bool dumpVcd = false;

uint8_t kuz_mul_gf256(uint8_t x, uint8_t y)
{
	uint8_t z;
	
	z = 0;
	while (y) {		
		if (y & 1)
			z ^= x;
		x = (x << 1) ^ (x & 0x80 ? 0xC3 : 0x00);
		y >>= 1;
	}
		
	return z;
}

int main(int argc, char **argv){
  // TODO: use args instead
  Verilated::commandArgs(argc, argv);
  Vgalois_mul galois;
  if (dumpVcd) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    galois.trace (tfp, 99);
    tfp->open(VCD_DUMP_FILE);
  }


  for (int tick=0; tick < 0xff * 0xff; ++tick) {
    // neg edge
    uint8_t res = kuz_mul_gf256(tick % 0xff, tick / 0xff);
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
  galois.final();
  std::cout << "\e[1;32m SUCCESS\e[0m\n";

  if (dumpVcd){
    tfp->close();
  }
  return 0;
}

