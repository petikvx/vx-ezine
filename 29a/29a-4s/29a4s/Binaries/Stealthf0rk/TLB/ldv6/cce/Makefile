# Makefile for SSCR V 0.7
#

CC = gcc -O2
AR = ar
RL = ranlib

all: sscr.a
	
sscr.a: sscr.o cce.o
	$(AR) cr sscr.a sscr.o cce.o
	$(RL) sscr.a

cce.o: 	cce.c cce.h
	$(CC) -c cce.c

sscr.o:	sscr.c cce.h
	$(CC) -c sscr.c
clean:
	rm -f *.o


