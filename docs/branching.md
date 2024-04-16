# Branching Wave Diagrams

## Branch With Failed Condition

Here we encounter an instruction, 0,  with a conditional jump. This instruction is executed like normal, until s1, where the branch condition result is ready. This condition is false (location denoted by little spikes), so nothing else happens and the pipeline isn't ever blocked.

<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/failed-branch-condition.json" style="background-color: white">

## Branch With Successful Condition

This situation starts the same, an instruction, 0, with a conditional jump. This time the condition resolves to true in s1, which triggers a number of different processes. Firstly, it is used to block the propagation of s0 to s1 for the next instruction, 1. The condition is also delayed for four extra cycles for blocking more instructions from reaching critical stages (>s0) while the post-branch instruction (in cyan) matures. The post-branch instruction is written on the first delayed condition signal (branch_shift).

<img src="https://svg.wavedrom.com/github/someone13574/risc-v-cpu/main/docs/wavedrom/successful-branch.json" style="background-color: white">

- **Orange**: Signals blocking s0 propagation and instructions affected by being blocked.
- **Cyan**: Post-branch instruction
