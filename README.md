# RISC-V CPU

This is a 6-stage, pipelined, microcode risc-v cpu which implements the Unprivledged RV32E ISA. It targets the EPF10K70 on the Altera UP2 Development Kit.

Each stage is executed in a single cycle, but parts of the pipeline can be stalled while different resources are being used. For example, if memory is being read or written to, then new instructions will not be fetched.

The pipeline can also be stalled if a register data-dependency is detected, which will cause the next instruction to wait until the offending register has been written to. The cpu will not attempt to reorder instructions.

Lastly, if a jump is executed, the cpu will wait for the whole pipeline to clear before continuing.




## Stages

The six stages of the pipeline are as follows:

1. **Fetch (sf)**: Fetches the next instruction from memory.
2. **Decode (sd)**: Converts the raw risc-v instruction into a microcode form (see the [microcode layout](./docs/microcode.md)). Additionally, it reads rs1 & rs2 from the registers.
3. **Alu-mux & Check (s0)**: Multiplexes alu inputs, checks register data dependencies, and does branch comparisons.
4. **Execute (s1)**: Start ALU operations.
5. **Read & Write Memory (s2)**: Read and write to memory, as well as writing the program counter for jumps.
6. **Writeback (s3)**: Writes to registers.
## License

Licensed under [Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0) or [MIT](http://opensource.org/licenses/MIT), at your option. See [COPYRIGHT](./COPYRIGHT) for more details.
