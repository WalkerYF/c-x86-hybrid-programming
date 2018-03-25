LD=ld 
LDFLAGS=-melf_i386 -N
CC=gcc
CCFLAGS=-march=i386 -m16 -mpreferred-stack-boundary=2 -ffreestanding
AS=nasm
ASFLAGS=

all: kernel.bin loader.bin

kernel.bin: kernel.o utilities.o
	$(LD) $(LDFLAGS) -Ttext 0xA100 --oformat binary -o $@ $^
kernel.o: kernel.c utilities.h
	$(CC) $(CCFLAGS) -c $^
utilities.o: utilities.asm
	$(AS) $(ASFLAGS) -f elf32 -o $@ $^
loader.o: loader.asm
	$(AS) $(ASFLAGS) -f elf32 -o $@ $^
loader.bin: loader.o
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $@ $^

build:
	dd if=loader.bin of=OS.img conv=notrunc
	dd if=kernel.bin of=OS.img conv=notrunc oflag=seek_bytes seek=512
clean:
	rm *.bin -f 
	rm *.o -f 
	rm *.gch -f
run:
	bochs -q