SECONDFLAGS = -m64 -masm=intel -fdiagnostics-color=always -Wno-error -c -O2 -fno-asynchronous-unwind-tables -nostdlib -nodefaultlibs -fno-builtin -Wl,--gc-sections -fno-stack-protector -ffreestanding -Wall -I.
CFILES := kernel.c
OBJS := $(CFILES:.c=.o)
CC=D:\gcc\bin\x86_64-elf-gcc
LD=D:\gcc\bin\x86_64-elf-ld


%.o: %.c
	${CC} ${SECONDFLAGS} -o "$@" "$<"
	

all: ${OBJS}
	${LD} -melf_x86_64 -static -Tlinker.ld -nostdlib --nmagic -o "kernel.elf" ${OBJS}
	objcopy -O binary kernel.elf ../fs/1KERNEL.BIN
	make cleanObj

cleanObj:
	@del /s /q *.s *.o *.elf