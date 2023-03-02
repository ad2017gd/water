ENTRY(main);
SECTIONS
{
    . = 0x100000;
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(main);
        _text = .;
        *(.text);
        _text_end = .;
    }
    .data :
    {
        _data = .;
        *(.bss);
        *(.bss*);
        *(.data);
        *(.rodata*);
        *(COMMON)
        _data_end = .;
    }
}