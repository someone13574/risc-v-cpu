RISCV_PATH = /opt/riscv/bin
ARCH = rv32i
ABI = ilp32

CFLAGS = -march=$(ARCH) -mabi=$(ABI) -ffunction-sections
LDFLAGS = -march=$(ARCH) -mabi=$(ABI) -melf32lriscv -T linker.ld

CC = $(RISCV_PATH)/riscv32-unknown-elf-gcc
LD = $(RISCV_PATH)/riscv32-unknown-elf-ld
ELF2HEX = /usr/local/bin/riscv32-unknown-elf-elf2hex
OBJDUMP = $(RISCV_PATH)/riscv32-unknown-elf-objdump

OUT = build

.PHONY: all
all: $(OUT)/main.hex $(OUT)/main.hex_dis

$(OUT)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OUT)/%.elf: $(OUT)/%.o
	$(LD) $(LDFLAGS) -o $@ $<

$(OUT)/%.hex: $(OUT)/%.elf
	$(ELF2HEX) --bit-width 32 --input $< --output $@

$(OUT)/%.hex_dis: $(OUT)/%.elf
	$(OBJDUMP) --disassemble $< > $@

.PHONY: clean
clean:
	rm -f build/*