all: virus.asm
	nasm -f elf -O2 virus.asm -o virus.o
	ld virus.o -o virus

clean:
	-@rm -f virus virus.o
