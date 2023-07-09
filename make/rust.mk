include make/include.mk

RS_FLAGS = --emit=obj -C panic=abort --target riscv64gc-unknown-linux-gnu

$(BUILD_U)/init.o: $(SRC_U)/init.rs
	rustc $^ $(RS_FLAGS) -o $@
