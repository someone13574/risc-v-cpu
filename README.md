# RISC-V CPU

This is a 6-stage, pipelined, microcode risc-v cpu which implements the Unprivledged RV32E ISA. It targets the EPF10K70 on the Altera UP2 Development Kit.

Each stage is executed in a single cycle, but parts of the pipeline can be stalled while different resources are being used. For example, if memory is being read or written to, then new instructions will not be fetched.

The pipeline can also be stalled if a register data-dependency is detected, which will cause the next instruction to wait until the offending register has been written to. The cpu will not attempt to reorder instructions.

Lastly, if a jump is executed, the cpu will wait for the whole pipeline to clear before continuing.

See [stages.md](./docs/stages.md), [branching.md](./docs/branching.md), [data-dependency.md](./docs/data-dependency.md), and [memory-fetch-conflict.md](./docs/memory-fetch-conflict.md) for more details.

## Repository Structure

The repository is split into four main directories: `design`, `src`, `c_program`, and `docs`.

- `design`: This directory holds the actual SystemVerilog design files. The main module is `cpu` and it is responsible for connecting all of the other modules together. The `README.md` in this directory contains more information on the different modules.
- `src`: This is the source code for the supporting CLI which is used for generating the microcode, uploading programs over uart, and generating memory initialization files if uart uploading isn't used. For an overview of the CLI's commands, see `src/README.md`.
- `c_program`: This directory contains the code, linker script, and build system for a small C program which can run on the CPU. It generates `main.hex` which then can be uploaded to the CPU using the CLI.
- `docs`: This directory contains documentation for the microcode, what data is available internally at each stage, the memory map, and waveforms of how different cases such as branching are handled by the control unit.

## License

Licensed under [Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0) or [MIT](http://opensource.org/licenses/MIT), at your option. See [COPYRIGHT](./COPYRIGHT) for more details.
