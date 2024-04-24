# Register Data-Dependency Avoidance

**NOTE**: This document doesn't cover back-to-back dependencies or split dependencies. TODO.

Due to this CPU being pipelined, it is possible for data-dependencies to be formed as a result of the register-read stage occuring before the register-write stage. To avoid this, the CPU detects this situations and delays the reading instruction until after the writing instruction is complete. For simplicity, this delay assumes the worst case situation, and thus delays for 5 cycles even if not necessary.

Each of the situations below assume the instruction 0 is writing to register 5, while they differ for the instruction which is reading from register 5, ranging from instruction 1 for the "s1 conflict" and instruction 3 for the "s3 conflict".

The first step in data-dependency avoidance is identifying it. This is done by comparing the `rs1` and `rs2` of `s0` (shown in purple) to the target address of `s1`, `s2`, and `s3` (shown in green or red depending on whether they match). Note that the diagrams use `rsx` to avoid duplication; assume that any `rsx` signal actually has separate `rs1` and `rs2` signals. The last part of detecting a conflict is checking whether any `s0` `rsx` match the `rd` of any other stage, `check_rs1` or `check_rs2` is enabled, and if the matching stage has write enable on, if it does, then the data-dependency signal is triggered.

Once the data-dependency signal is triggered, a four cycle shift register delay is activated. This is used in conjunction with the data-dependency signal to block the propagation of instructions in `s0` into `s1` and beyond, the critical stages. This is done to prevent and meaningful changes to the state to occur while we wait for the pipeline to clear. This is denoted in orange.

Also using the shift-register, a program counter write is activated on the cycle after the dependency is detected to write the program counter of the current `s1` instruction (note that while the microcode and instruction data is blocked, the stored program counter isn't, so \*1\* denotes this address). This written program counter value, denoted in cyan, will then propagate as normal, falling in behind the blocked instructions, and reading the modified register 5.

- **Purple**: Registers read by the instruction in `s0` which are to be tested.
- **Green**: Register to be written to by `s1`, `s2`, or `s3` which doesn't match `rs1_s0` or `rs2_s0` (`rsx_s0`).
- **Red**: Same as green, but it does match.
- **Orange**: `s0` propagation blocking signals or a blocked `s0` instruction.
- **Cyan**: Resumed instruction to be restarted after the pipeline has cleared.

## `s1` conflict

<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/s1-data-dependency.json" style="background-color: white">

## `s2` conflict
<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/s2-data-dependency.json" style="background-color: white">

## `s3` conflict
<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/s3-data-dependency.json" style="background-color: white">
