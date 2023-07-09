include rust.mk
include c.mk

$(BUILD_K)/kernel: $(OBJS) $(SRC_K)/kernel.ld $(BUILD_U)/initcode $(BUILD_K)/rust_main.o
	$(LD) $(LDFLAGS) -T $(SRC_K)/kernel.ld -o $(BUILD_K)/kernel $(OBJS) $(BUILD_K)/rust_main.o
	$(OBJDUMP) -S $(BUILD_K)/kernel > $(INFO_K)/$F.asm
	$(OBJDUMP) -t $(BUILD_K)/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(INFO_K)/kernel.sym

clean: 
	rm -fr $(BUILD) $(INFO)

include qemu.mk
