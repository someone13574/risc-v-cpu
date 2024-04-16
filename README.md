# RISC-V CPU

This is a 6-stage, pipelined, microcode risc-v cpu which implements the Unprivledged RV32E ISA. It targets the EPF10K70 on the Altera UP2 Development Kit.

Each stage is executed in a single cycle, but parts of the pipeline can be stalled while different resources are being used. For example, if memory is being read or written to, then new instructions will not be fetched.

The pipeline can also be stalled if a register data-dependency is detected, which will cause the next instruction to wait until the offending register has been written to. The cpu will not attempt to reorder instructions.

Lastly, if a jump is executed, the cpu will wait for the whole pipeline to clear before continuing.

## License

Licensed under [Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0) or [MIT](http://opensource.org/licenses/MIT), at your option. See [COPYRIGHT](./COPYRIGHT) for more details.
