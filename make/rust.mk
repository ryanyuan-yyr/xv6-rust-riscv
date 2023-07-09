include make/include.mk

RS_FLAGS = --emit=obj -C panic=abort --target riscv64gc-unknown-linux-gnu

KERNEL_INCLUDES = \
	types.h\
	riscv.h\
	spinlock.h\
	sleeplock.h\
	fs.h\
	buf.h\
	elf.h\
	fcntl.h\
	file.h\
	memlayout.h\
	param.h\
	proc.h\
	stat.h\
	syscall.h\
	defs.h\
	virtio.h\

# USER_INCLUDES = \
# 	user.h\

build/kernel/rust_header.rs: 
	cd bindgen && cargo run --release -- $(KERNEL_INCLUDES:%=../$(INCLUDE_K)/%) ../$@

# build/user/rust_header.rs:
# 	cd bindgen && cargo run --release -- $(USER_INCLUDES:%=../$(INCLUDE_U)/%) ../$@

$(BUILD_U)/init.o: $(SRC_U)/init.rs
	rustc $(SRC_U)/init.rs $(RS_FLAGS) -o $@
