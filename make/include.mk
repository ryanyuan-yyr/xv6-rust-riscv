BUILD = build
BUILD_K = $(BUILD)/kernel
BUILD_U = $(BUILD)/user
BUILD_FS = $(BUILD)/mkfs

SRC = src
SRC_K = $(SRC)/kernel
SRC_U = $(SRC)/user
SRC_FS = $(SRC)/mkfs

INCLUDE = includes
INCLUDE_K = $(INCLUDE)/kernel
INCLUDE_U = $(INCLUDE)/user

INFO = info
INFO_K = $(INFO)/kernel
INFO_U = $(INFO)/user

.PHONY: dir

dir: 
	mkdir -p $(BUILD_K) $(BUILD_U) $(BUILD_FS) $(INFO_K) $(INFO_U)
