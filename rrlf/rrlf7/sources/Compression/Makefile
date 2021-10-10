CC	= gcc
CFLAGS	= -O2 -Wall -pedantic
MODS	= ari lzw rle
OBJS	= $(MODS:=.o)
INCS	= $(MODS:=.inc)

all: e2inc $(OBJS) $(MODS) $(INCS) test

%.o: %.asm
	nasm -f elf -O2 $< -o $@

%: %.o
	objcopy -j .text -O binary $< $@

%.inc: %
	./e2inc $< `nm -g $<.o | awk '{print $$3" "$$1}'|xargs` > $@

e2inc: e2inc.c
	$(CC) $(CFLAGS) $< -o $@

test: test.c
	$(CC) $(CFLAGS) $< $(OBJS) -o $@
	-@./test test.data1
	-@./test test.data2
	-@./test test.data3

clean:
	-@rm -f *.o $(MODS) *.inc e2inc test

.PHONY: all clean
