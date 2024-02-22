MEMORY
{
  rom : ORIGIN = 0x00000000, LENGTH = 0x20000
  ram : ORIGIN = 0x20000000, LENGTH = 0x100000
}

SECTIONS
{
    .entry :
    {
        *(.entry*)
    } > rom
    .text :
    {
        *(.text*)
    } > rom
    .rodata :
    {
        *(.rodata*)
    } > rom
    .data :
    {
        *(.data*)
    } > ram AT > rom
    .bss :
    {
        *(.bss*)
    } > ram
    .stack :
    {
        . = ALIGN(16);
        _stack_top = .;
        . = . + 0x4000;
        _stack_bottom = .;
    } > ram
}

ENTRY(_start)
