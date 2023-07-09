include make/rust.mk
include make/c.mk
include make/qemu.mk

$(BUILD_K)/kernel: $(OBJS) $(SRC_K)/kernel.ld $(BUILD_U)/initcode
	$(LD) $(LDFLAGS) -T $(SRC_K)/kernel.ld -o $(BUILD_K)/kernel $(OBJS)
	$(OBJDUMP) -S $(BUILD_K)/kernel > $(INFO_K)/$F.asm
	$(OBJDUMP) -t $(BUILD_K)/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(INFO_K)/kernel.sym

clean: 
	rm -fr $(BUILD_K)/* $(BUILD_U)/* $(BUILD_FS)/* $(INFO_K)/* $(INFO_U)/*
	cd bindgen && cargo clean

