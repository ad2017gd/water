ENTRY(main);
SECTIONS
{
    . = 0x9000;
    .text : AT(0x9000)
    {
        *(__start);
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
    .end : AT(0xA000)
    {
        SHORT(0x0000);
    }
}