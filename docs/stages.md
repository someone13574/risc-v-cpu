# Stages

This CPU is a 6-staged pipelined, meaning that the all stages execute in parallel if possible. Each stage has one or more responsibilities which are always completed before the next clock cycle, though it is possible for stages to need the same resource at the same time, which causes a *blockage* and then a *rerun*.

## Processes Started by Stage

#### `sf`

- Fetch of the next instruction

#### `si`

- Decoding of instruction into microcode
- Read RS1 & RS2 (whether they are used or not)

#### `s0`

- ALU input multiplexing
- Register data dependency check
- Branch condition check

#### `s1`

- ALU execution
- PC write if the branch condition is true

#### `s2`

- Memory read & write
- Writeback input multiplexing

#### `s3`

- Write to registers (writeback)

## Available Data by Stage

| Stage ID | Instruction | Microcode | Input Registers | Immediates | ALU Inputs | Data Dependency Check | Branch Condition Check | ALU Output | Writeback Input |
| -------- | ----------- | --------- | --------------- | ---------- | ---------- | --------------------- | ---------------------- | ---------- | --------------- |
| `sf`     | ❌          | ❌        | ❌              | ❌         | ❌         | ❌                    | ❌                     | ❌         | ❌              |
| `si`     | ✅          | ❌        | ❌              | ❌         | ❌         | ❌                    | ❌                     | ❌         | ❌              |
| `s0`     | ✅          | ✅        | ✅              | ✅         | ❌         | ❌                    | ❌                     | ❌         | ❌              |
| `s1`     | ✅          | ✅        | ❌              | ✅         | ✅         | ✅                    | ✅                     | ❌         | ❌              |
| `s2`     | ✅          | ✅        | ❌              | ✅         | ❌         | ❌                    | ❌                     | ✅         | ❌              |
| `s3`     | ✅          | ✅        | ❌              | ✅         | ❌         | ❌                    | ❌                     | ❌         | ✅              |
