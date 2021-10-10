# By using this file, you agree to the terms and conditions set
# forth in the COPYING file which can be found at the top level
# of this distribution.
#
CC=gcc
MAKEPATH=`which make`

all: genopt
	@mkdir -p samples
	./genopt

genopt: genopt.c
	$(CC) -Wall -O2 genopt.c -o genopt -DMAKE=\"$(MAKEPATH)\"

clean:
	-@rm -f genopt
	-@rm -rf samples

.PHONY: all clean
