all:
	verilator -Wall --cc --trace top.v wb_leds.v wb_master --exe wishbone.cpp --CFLAGS "--std=c++11 -g"
	make -C obj_dir -f Vtop.mk Vtop
	mv obj_dir/Vtop wishbone

clean:
	rm -rf obj_dir wishbone
