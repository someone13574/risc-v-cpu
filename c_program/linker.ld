ROM_SIZE   = 0x00000400;
RAM_SIZE   = 0x00000400;
STACK_SIZE = 0x00000100;

MEMORY
{
    rom  (rx) : ORIGIN = 0x00000000, LENGTH = ROM_SIZE
    ram (rwx) : ORIGIN = ROM_SIZE, LENGTH = RAM_SIZE
}

SECTIONS
{
    .text : ALIGN(4)
    {
        *(.text*._start)
        *(.text*)
    } > rom
    .rodata : ALIGN(4)
    {
        *(.rodata*)
    } > rom
    .data : ALIGN(4)
    {
        *(.data*)
    } > ram AT > rom
    .bss : ALIGN(4)
    {
        *(.bss*)
    } > ram
    .stack : ALIGN(4)
    {
        _stack_top = .;
        . = . + STACK_SIZE;
        _stack_bottom = .;
    } > ram
}

ENTRY(_start)
