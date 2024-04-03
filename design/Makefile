OUT = build

.PHONY: all
all: $(OUT)/Vcpu.h

$(OUT)/Vcpu.h: *.sv tests/*.sv
	verilator --cc -sv --top cpu -Mdir $(OUT) $^

$(OUT):
	mkdir $(OUT)

.PHONY: clean
clean:
	rm -f $(OUT)/*
