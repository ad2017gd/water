.PHONY: all clean cleanObj



CC=D:\gcc\bin\x86_64-elf-gcc
LD=D:\gcc\bin\x86_64-elf-ld
DIR=$(shell cd)

FIRSTBOOT.BIN:
	make all -C "boot/first"
SECONDBOOT.BIN:
	make all -C "boot/second"
KERNEL.ELF:
	make all -C "kernel"

	

buildImage:
	wsl make buildWsl
	
buildWsl:
	dd if=/dev/zero of=disk.img bs=1MB count=100
	mformat -v "WaterOS" -r 1 -c 1 -F -i disk.img ::
	dd if=FIRSTBOOT.BIN of=disk.img bs=1 count=448 seek=90 conv=notrunc skip=90
	cd fs; mcopy -i ../disk.img -s * ::
	



all: FIRSTBOOT.BIN SECONDBOOT.BIN KERNEL.ELF buildImage
	make cleanObj
	qemu-system-x86_64 -drive format=raw,file=disk.img 
#	@${CC} ${SECONDFLAGS} -S -o kernel.s kernel.c
#	@${CC} ${SECONDFLAGS} -o kernel.o kernel.c

#	@${LD} -melf_i386 -static -Tkrnl.ld -nostdlib --nmagic -o kernel.elf kernel.o
#	@objcopy -O binary kernel.elf KRNL.BIN

	
clean:
	@del /s /q *.BIN *.s *.o *.elf
cleanObj:
	@del /s /q *.s *.o