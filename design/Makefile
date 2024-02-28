OUT = build

.PHONY: all
all: $(OUT)/tb_cpu.vcd

$(OUT)/risc-v-cpu: *.sv tests/*.sv $(OUT)
	iverilog -g2012 -s tb_cpu -o $@ $^

$(OUT)/tb_cpu.vcd: $(OUT)/risc-v-cpu
	vvp $(OUT)/risc-v-cpu

$(OUT):
	mkdir $(OUT)

.PHONY: clean
clean:
	rm -f $(OUT)/*
