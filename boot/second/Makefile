SECONDFLAGS = -masm=intel -fdiagnostics-color=always -Wno-error -c -Os -fno-asynchronous-unwind-tables -nostdlib -nodefaultlibs -fno-builtin -Wl,--gc-sections -fno-stack-protector -ffreestanding -Wall -I.
CFILES := boot.c
ASMFILES := protected.asm
OBJS := $(CFILES:.c=.o) $(ASMFILES:.asm=.o)
CC=wsl ia16-elf-gcc
LD=wsl ia16-elf-ld


%.o: %.c
	${CC} ${SECONDFLAGS} -o "$@" "$<"
%.o: %.asm
	nasm "$<" -f elf32 -o "$@"
	

all: ${OBJS}
	${LD} -melf_i386 -static -Tlinker.ld -nostdlib --nmagic -o "boot.elf" ${OBJS}
	objcopy -O binary ${HIGH}boot.elf ../../fs/1BOOT.BIN
	make cleanObj

cleanObj:
	@del /s /q *.s *.o *.elf