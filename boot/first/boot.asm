[BITS 16]

[SECTION .text]
[ORG 0x7c00]

; TO BE POPULATED BY THE MEDIA CREATION TOOL
jmp short start
nop
bsOemName               DB      "WatrBOOT" 

bpbBytesPerSector       DW      0
bpbSectorsPerCluster    DB      0
bpbReservedSectors      DW      0
bpbNumberOfFATs         DB      0
bpbRootEntries          DW      0
bpbTotalSectors         DW      0
bpbMedia                DB      0
bpbSectorsPerFAT        DW      0
bpbSectorsPerTrack      DW      0
bpbHeadsPerCylinder     DW      0
bpbHiddenSectors        DD      0
bpbTotalSectorsBig      DD      0

ebrSectorsPerFat        DD      0
ebrFlags                DW      0
ebrFatVersion           DW      0
ebrClusterNumber        DD      0
ebrFSInfoSector         DW      0
ebrBackupSector         DW      0
times 12 db 0
ebrDriveNumber          DB      0
ebrNTFlags              DB      0
ebrSignature            DB      0
ebrSerial               DD      0
ebrVolLabel             DB      "WaterOS    " 
ebrSystemIdent          DB      "FAT32   "
; END FS INFO

start:
    cld

    mov ax, 0050h ;0x500
    mov ss, ax
    mov sp, 4096 ; setup nice 4k stack wayy under bootloader


    mov     [ebrDriveNumber], dl



    xor eax,eax

    mov dx, [ebrSectorsPerFat]
    mov ax, [bpbNumberOfFATs]

    mul dx
    mov cx, [bpbReservedSectors]
    add ax, cx ; first_data_sector nice
    mov [first_data_sector], ax ; for later use



    ; load about 4KiB worth of data (8 sectors)
    ; second stage will probably be very under that

    mov [dap.dapStartLow], eax
    mov ax, 8
    mov [dap.dapSectors], ax
    mov ax, 0x8000
    mov [dap.dapMemory], ax

    mov si, dap
    mov dl, [ebrDriveNumber]
    mov ah, 42h
    int 13h

 ;debug what we just read
;    mov cx,0
;loop:
;    ;expecting some strings here
;    ;WATEROS,BOOT BIN
;    ; theres none =)
;
;
;    mov si, 0x8000
;    add si,cx
;    mov al, [si]
;    mov ah,0Eh
;    int 10h
;
;
;    inc cx
;    cmp cx, 800
;    jne loop

    mov dx, 0
read:
    ;dx offset
    mov ax, dx
    add ax, 11
    add ax, 0x8000
    mov si, ax

    push dx

    mov cx, [si]
    cmp cx, 0x0F
    je SKIP
    mov si, ax
    mov cx, [si]
    cmp cx, 0x08
    je SKIP

    ; found a file!


    mov dx, 0 ; counter, max 11
    sub ax, 11
compare:
    ;dx counter
    ;ax offset for disk
    mov bx, bootfile ; bx offset for expected string
    add ax, dx
    add bx, dx
    mov si, ax
    mov cl, [si]
    mov si, bx
    mov ch, [si]
    cmp cl,ch

    sub ax,dx ; we added the counter to ax, so now remove it

    cmp cl,ch
    jne SKIP
    mov cx, 11
    inc dx
    cmp dx, cx
    jne compare

;;;WE FOUDN THE BOOT FILE!


    pop dx ; how far into the first cluster are we?
    ;; ------------VERY IMPORTANT----------
    ;; BOOTLOADER MAKES THE ASSUMPTION THAT THE CLUSTERS FOR BOOT.BIN
    ;; ARE NOT FRAGMENTED

    add ax, 28
    mov si, ax
    mov cx, [si] ; (MAX 64k) bytes to read
    mov bx, [bpbBytesPerSector]
    dec bx
    add cx, 511
    shr cx, 9

    mov [dap.dapSectors], cx ; CX sectors!
    

    
    sub ax, 2
    mov si, ax
    mov cx, [si]
    sub cx, 2 ; first cluster for the file's data
    
    mov ax,cx
    xor bx,bx
    mov bl, [bpbSectorsPerCluster]
    mul bx ; file data sector offset

    
    


    add ax, [first_data_sector] ; also skip to fist data sector
    add dx, [bpbBytesPerSector]
    dec dx
    shr dx, 9 ; also skip to next cluster
    add ax, dx

        

    
    mov [dap.dapStartLow], ax
    
    mov ax, 0x9000
    mov [dap.dapMemory], ax

    mov si, dap
    mov dl, [ebrDriveNumber]
    mov ah, 42h
    int 13h

    
    push dword 0x9000
    retf
    

    jmp $
    

    SKIP:
    pop dx
    add dx, 32
    jmp read


    jmp $
    hlt


align 4
dap:
    .dapSize db 10h
    .dapZero db 0
    .dapSectors dw 0
    .dapMemory dw 0
    .dapSegment dw 0
    .dapStartLow dd 0
    .dapStartHigh dd 0

bootfile db "1BOOT   BIN"
first_data_sector dw 0

    

times (512-13-($-$$)) db 0
dw      0AA55h



;    mov cx, 10
;loophere:
;    mov dx, 0
;    div cx
;    push ax
;    add dl, '0'
;    mov al, dl
;    mov ah,0Eh
;    int 10h
;    pop ax
;    cmp ax, 0
;    jnz loophere