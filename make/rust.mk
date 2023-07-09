include make/include.mk

$(BUILD_K)/rust_main.o: src/main.rs
	rustc src/main.rs --emit=obj -C panic=abort --target riscv64gc-unknown-linux-gnu -o $@
