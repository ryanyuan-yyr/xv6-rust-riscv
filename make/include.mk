BUILD = build
BUILD_K = $(BUILD)/kernel
BUILD_U = $(BUILD)/user
BUILD_FS = $(BUILD)/mkfs

SRC = src
SRC_K = $(SRC)/kernel
SRC_U = $(SRC)/user
SRC_FS = $(SRC)/mkfs

INFO = info
INFO_K = $(INFO)/kernel
INFO_U = $(INFO)/user

dir_build:
	@mkdir -p $(BUILD)
	@mkdir -p $(BUILD_K)
	@mkdir -p $(BUILD_U)
	@mkdir -p $(BUILD_FS)

dir_info:
	@mkdir -p $(INFO)
	@mkdir -p $(INFO_K)
	@mkdir -p $(INFO_U)
