CC = gcc
CFLAGS = -O2 -fomit-frame-pointer -g # -Wall
CLEANFILES =	header pheader eheader
bindir = /usr/local/bin
INSTALL = /usr/bin/install -c

all:	eheader pheader sheader	

eheader: eheader.c
	$(CC) $(CFLAGS) eheader.c -o eheader

pheader: pheader.c
	$(CC) $(CFLAGS) pheader.c -o pheader

sheader: sheader.c
	$(CC) $(CFLAGS) sheader.c -o sheader

install: all
	$(INSTALL) -d $(bindir)
	$(INSTALL) -m 755 eheader $(bindir)/eheader
	$(INSTALL) -m 755 pheader $(bindir)/pheader
	$(INSTALL) -m 755 sheader $(bindir)/sheader

clean:
	rm -f $(CLEANFILES)
