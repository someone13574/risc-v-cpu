# Memory-Fetch Conflict

This CPU is designed such that only a single address can be read or written to at once. Normally this isn't an issue as these operations are confined to the same stage, but it does cause an issue as memory must be read by the fetch stage as well. For this reason, the fetch stage needs to be delayed by a cycle if an instruction needs to write memory. Note that the design of a single stage for memory access prevents memory dependencies, but this as well is an issue for the fetch stage. The first issue, shared resources, is prevented by the CPU. The second issue is avoided by not allowing self-modifying code.

In the diagram, the instruction 0 is a memory-access instruction. Everything runs like normal until s1, where the `mem_in_use` microcode is high and causes a program counter write. This re-writes the current program counter (\*4\*), delaying it by a cycle. This is done because in the next cycle, the program counter is poisoned by the memory-access (in this case making it read 42). This isn't a problem however as the poisoned instruction is blocked before it enters s1, the first critical stage, by timing with a shift register. The program counter then increments to 5, which the poisoned stage originally would have been, and everything continues like normal.

<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/memory-fetch-conflict.json" style="background-color: white">

- **Red**: Conflict between the memory-access and the fetch stage.
- **Purple**: Instruction poisoned by the memory-access.
- **Cyan**: Delayed instruction which would have been poisoned.
