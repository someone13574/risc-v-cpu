OUT = build
WARNS = -Wall

.PHONY: all
all: $(OUT)/Vtb_cpu.h

$(OUT)/Vtb_cpu.h: *.sv tests/*.sv
	verilator --cc -sv ${WARNS} --top tb_cpu -Mdir $(OUT) $^

$(OUT):
	mkdir $(OUT)

.PHONY: clean
clean:
	rm -f $(OUT)/*
