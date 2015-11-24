CC=or32-elf-gcc
CFLAGS=-mboard=atlys -std=c99 -fgnu89-inline


ifeq ($(PROJECT_PATH),)
	PROJECT_PATH=~/workspace/openriscGEMSCLAIM
endif

ifeq ($(OUT_PATH),)
	OUT_PATH=$(PROJECT_PATH)/../out
endif


BUILD_PATH=$(abspath $(PROJECT_PATH)/../build)
SOURCE_PATH=$(realpath $(PROJECT_PATH)/src/sw/elf)

BUILD_OBJ_PATH  = $(BUILD_PATH)/obj
BUILD_CODE_PATH = $(BUILD_PATH)/src
BUILD_OUT_PATH  = $(BUILD_PATH)/out
      

all: make_dirs copy_src compile link post_process

post_process:
	@echo ">> Post-process >>"
	or32-elf-objcopy -I elf32-or32 $(BUILD_OUT_PATH)/lem_test.elf -O binary $(BUILD_OUT_PATH)/lem_test.bin 
	bin2binsizeword $(BUILD_OUT_PATH)/lem_test.bin $(BUILD_OUT_PATH)/lem_test_bsw.bin
	@mkdir -p $(OUT_PATH)
	cp -r $(BUILD_PATH)/out/* $(OUT_PATH)

link:
	@echo ">> Linking >>"
	cd $(BUILD_OBJ_PATH); $(CC) $(CFLAGS) * -o $(BUILD_OUT_PATH)/lem_test.elf

compile:
	@echo ">> Compilation >>"
	cd $(BUILD_CODE_PATH); find * -name '*.c' | cut -d '.' --complement -f 2 | xargs -n1 -i $(CC) -c {}.c $(CFLAGS) -o $(BUILD_OBJ_PATH)/{}.o


copy_src:
	@echo ">> Copying source files >>"
	@find $(SOURCE_PATH) -type f -exec cp -fvu {} $(BUILD_CODE_PATH) \;

make_dirs:
	@mkdir -p $(BUILD_PATH)
	@mkdir -p $(BUILD_CODE_PATH)
	@mkdir -p $(BUILD_OBJ_PATH)	
	@mkdir -p $(BUILD_OUT_PATH)	

clean:
	@echo "Deleting " $(BUILD_PATH)
	rm -r -f $(BUILD_PATH)
	@echo "Deleting " $(OUT_PATH)
	rm -r -f $(OUT_PATH)

.PHONY: all
