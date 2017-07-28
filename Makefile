all:
	verilator -Wall --cc --trace galois_mul.v  --exe verify.cpp --CFLAGS "--std=c++11 -g"
	make -C obj_dir -f Vgalois_mul.mk Vgalois_mul
	mv obj_dir/Vgalois_mul galois

clean:
	rm -rf obj_dir galois xor
