include make/include.mk

OBJS = \
  $(BUILD_K)/entry.o \
  $(BUILD_K)/start.o \
  $(BUILD_K)/console.o \
  $(BUILD_K)/printf.o \
  $(BUILD_K)/uart.o \
  $(BUILD_K)/kalloc.o \
  $(BUILD_K)/spinlock.o \
  $(BUILD_K)/string.o \
  $(BUILD_K)/main.o \
  $(BUILD_K)/vm.o \
  $(BUILD_K)/proc.o \
  $(BUILD_K)/swtch.o \
  $(BUILD_K)/trampoline.o \
  $(BUILD_K)/trap.o \
  $(BUILD_K)/syscall.o \
  $(BUILD_K)/sysproc.o \
  $(BUILD_K)/bio.o \
  $(BUILD_K)/fs.o \
  $(BUILD_K)/log.o \
  $(BUILD_K)/sleeplock.o \
  $(BUILD_K)/file.o \
  $(BUILD_K)/pipe.o \
  $(BUILD_K)/exec.o \
  $(BUILD_K)/sysfile.o \
  $(BUILD_K)/kernelvec.o \
  $(BUILD_K)/plic.o \
  $(BUILD_K)/virtio_disk.o

# riscv64-unknown-elf- or riscv64-linux-gnu-
# perhaps in /opt/riscv/bin
#TOOLPREFIX = 

# Try to infer the correct TOOLPREFIX if not set
ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	elif riscv64-unknown-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find a riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

QEMU = qemu-system-riscv64

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb -gdwarf-2
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I$(INCLUDE)
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

# Disable PIE when possible (for Ubuntu 16.10 toolchain)
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]no-pie'),)
CFLAGS += -fno-pie -no-pie
endif
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]nopie'),)
CFLAGS += -fno-pie -nopie
endif

$(BUILD_K)/%.o: $(SRC_K)/%.c
	$(CC) $(CFLAGS) -I$(INCLUDE_K) -c -o $@ $<

$(BUILD_K)/%.o: $(SRC_K)/%.S
	$(CC) $(CFLAGS) -I$(INCLUDE_K) -c -o $@ $<

LDFLAGS = -z max-page-size=4096

$(BUILD_U)/initcode: $(SRC_U)/initcode.S
	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I$(INCLUDE_K) -c $(SRC_U)/initcode.S -o $(BUILD_U)/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $(BUILD_U)/initcode.out $(BUILD_U)/initcode.o
	$(OBJCOPY) -S -O binary $(BUILD_U)/initcode.out $(BUILD_U)/initcode
	$(OBJDUMP) -S $(BUILD_U)/initcode.o > $(INFO_U)/initcode.asm

ULIB = $(BUILD_U)/ulib.o $(BUILD_U)/usys.o $(BUILD_U)/printf.o $(BUILD_U)/umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -T $(SRC_U)/user.ld -o $@ $^
	$(OBJDUMP) -S $@ > $(INFO_U)/$(basename $(notdir $*)).asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(INFO_U)/$(basename $(notdir $*)).sym

$(BUILD_U)/usys.S : $(SRC_U)/usys.pl
	perl $(SRC_U)/usys.pl > $(BUILD_U)/usys.S

$(BUILD_U)/usys.o : $(BUILD_U)/usys.S
	$(CC) $(CFLAGS) -c -o $(BUILD_U)/usys.o $(BUILD_U)/usys.S

$(BUILD_U)/_forktest: $(BUILD_U)/forktest.o $(ULIB)
	# forktest has less library code linked in - needs to be small
	# in order to be able to max out the proc table.
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $(BUILD_U)/_forktest $(BUILD_U)/forktest.o $(BUILD_U)/ulib.o $(BUILD_U)/usys.o
	$(OBJDUMP) -S $(BUILD_U)/_forktest > $(INFO_U)/forktest.asm

$(BUILD_U)/%.o: $(SRC_U)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_FS)/mkfs: $(SRC_FS)/mkfs.c $(INCLUDE_K)/fs.h $(INCLUDE_K)/param.h
	gcc -Werror -Wall -I$(INCLUDE) -o $(BUILD_FS)/mkfs $(SRC_FS)/mkfs.c

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

UPROGS=\
	$(BUILD_U)/_cat\
	$(BUILD_U)/_echo\
	$(BUILD_U)/_forktest\
	$(BUILD_U)/_grep\
	$(BUILD_U)/_init\
	$(BUILD_U)/_kill\
	$(BUILD_U)/_ln\
	$(BUILD_U)/_ls\
	$(BUILD_U)/_mkdir\
	$(BUILD_U)/_rm\
	$(BUILD_U)/_sh\
	$(BUILD_U)/_stressfs\
	$(BUILD_U)/_usertests\
	$(BUILD_U)/_grind\
	$(BUILD_U)/_wc\
	$(BUILD_U)/_zombie\

$(BUILD_FS)/fs.img: $(BUILD_FS)/mkfs README $(UPROGS)
	$(BUILD_FS)/mkfs $(BUILD_FS)/fs.img README $(UPROGS)

-include $(BUILD_K)/*.d $(BUILD_U)/*.d