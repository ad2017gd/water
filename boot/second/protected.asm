[bits 16]

gdt32info:
   dw gdt32_end - gdt32 - 1 
   dd gdt32
 
gdt32:        dd 0,0 ; null
code32desc:   db 0xff, 0xff, 0, 0, 0, 10011010b, 11001111b, 0 ; code
flat32desc:   db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0 ; data
gdt32_end:

; bootloader to kernel data
waterboot2data:
    
waterboot2data_end:
; kernel to bootloader data
waterboot1data:
    .magic times 10 db 0
    .videoMode db 0
waterboot1data_end:

kernel_bytes dw 0

global jumpToProtected
jumpToProtected:
    mov [kernel_bytes], ax
    cli
    lgdt [gdt32info]
    
    mov eax,cr0
    or eax,1
    mov cr0,eax
    
    jmp 0x08:clear
 
[bits 32]
clear:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax


    ; now long mode
    ; clear da tables
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3

    ;setup paging tables
    mov DWORD [edi], 0x2003 ; 3 = rw
    add edi, 0x1000 ; next 0x1000
    mov DWORD [edi], 0x3003
    add edi, 0x1000 ; next 0x1000
    mov DWORD [edi], 0x4003
    add edi, 0x1000


    ; identity map 2 mbs
    mov ebx, 0x00000003 ; rw
    mov ecx, 512
    ; loop
map:
    mov DWORD [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop map
    ; finally setup paging
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    


    mov ecx, 0xC0000080 ; msr
    rdmsr ; read msr
    or eax, 1 << 8 ; enable msr bit
    wrmsr ; write msr
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    ; COMPAT MODE!
    lgdt [gdt64info]
    jmp 0x08:LongMode

kernel_memory dd 0

[bits 64]
LongMode:
    ; rax = kernel start
    mov rax, 0x10000
    mov rsi, rax
    mov rdi, 0x100000
    xor rcx, rcx
    mov cx, [kernel_bytes]
    add cx, 0
    shl cx, 3
    rep movsq

    jmp 0x100000
    



gdt64info:
   dw gdt64_end - gdt64 - 1 
   dd gdt64
 
gdt64:        dq 0 ; null
code64desc:   db 0xff, 0xff, 0, 0, 0, 10011010b, 1101111b, 0 ; code
flat64desc:   db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0 ; data
tss64desc:    dd 0x00000068, 0x00CF8900                       ; tss
gdt64_end: