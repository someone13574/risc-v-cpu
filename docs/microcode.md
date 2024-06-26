# Microcode

## Microcode bits

| Bit(s) | Stage   | Name                       | Description                                                                                                                    |
| ------ | ------- | ---------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| 0      | s0      | `check_rs1_dep`            | Enables data dependency check for rs1.                                                                                         |
| 1      | s0      | `check_rs2_dep`            | Enables data dependency check for rs2.                                                                                         |
| 2-3    | s0      | `pre_alu_a_select`         | Used to multiplex alu input a's input ahead of time.                                                                           |
| 4-6    | s0      | `pre_alu_b_select`         | Used to multiplex alu input b's input ahead of time.                                                                           |
| 7-9    | s0      | `cmp_op_select`            | Selects a comparison operation for branching.                                                                                  |
| 10     | s1      | `mem_in_use`               | Signals that memory is used by this operation, thus stalling the pipeline.                                                     |
| 11-14  | s1      | `alu_op_select`            | Selects an ALU operation.                                                                                                      |
| 15     | s2      | `mem_write_enable`         | Enables the write signal for memory.                                                                                           |
| 16     | s2 & s3 | `enable_upper_half`        | Enables memory read and write for [16:31].                                                                                     |
| 17     | s2 & s3 | `enable_byte_1`            | Enables memory read and write for [8:15].                                                                                      |
| 18     | s2      | `alu_out_to_mem_addr`      | Toggles between connecting the alu output or the program counter to the memory address.                                        |
| 19     | s2      | `jump_if_branch`           | Executes a jump if the branch condition is true.                                                                               |
| 20-21  | s2      | `pre_writeback_select`     | Used to multiplex the memory input ahead of time.                                                                              |
| 22     | s3      | `reg_write_enable`         | Enables the write signal for the registers.                                                                                    |
| 23     | s3      | `use_pre_wb_over_mem_data` | Toggles between using the multiplexed `pre_writeback` and using the output memory data as an input to the register input data. |
| 24     | s3      | `sext_mem_data_out`        | Sign-extends `mem_data_out` after truncating based on `enable_x`.                                                              |

## `pre_alu_a_select` Enumeration
| Pattern | Source            |
| ------- | ----------------- |
| 00      | Upper immediate   |
| 01      | J-Type immediate  |
| 10      | B-Type immediate  |
| 11      | Register output a |

## `pre_alu_a_select` Enumeration
| Pattern | Source             |
| ------- | ------------------ |
| 000     | Lower immediate    |
| 001     | S-Type immediate   |
| 010     | Program counter    |
| 011     | RS2 / Shift Amount |
| 100     | Register output B  |

## `pre_writeback_select` Enumeration
| Pattern | Source          |
| ------- | --------------- |
| 00      | Upper immediate |
| 01      | ALU output      |
| 10      | Return address  |
