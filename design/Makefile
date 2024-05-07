OUT = build
WARNS = -Wall -Wno-PINMISSING -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL

.PHONY: all
all: $(OUT)/Vtb_cpu.h

$(OUT)/Vtb_cpu.h: *.sv tests/*.sv
	verilator --cc --timing -sv ${WARNS} --top tb_cpu -Mdir $(OUT) $^

$(OUT):
	mkdir $(OUT)

.PHONY: clean
clean:
	rm -f $(OUT)/*
