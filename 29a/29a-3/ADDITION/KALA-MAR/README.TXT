Reed-Solomon error correction code for virus

Error correction code (ECC) is a code used often in telecommunications, to
recover data loss in noisy connections. Several ways to do this are know,
and here i shown one of these way, specialy tailored for virus coding. The
routine presented here is a implementation of the Reed-Solomon algorithm,
that is able to correct till to 4 bytes in a 249 bytes long buffer (1.6%).
Dont seens good, but keep in mind that this code can correct bytes overwrited
from your virus code! This mean that AVs cant patch anymore your code with
a simple jump to disinfect it in mem. If your ECC routine code hooked, lets
said, int8, it will correct the patched code 1/18 secs after! You can hook
also int1c or even int9, correcting the virus code each time that the user
touch the keyboard.

The given routine encode a 249 buffer in a 256 code lenght, and vice-versa.
This mean that each 249 bytes of virus code need 256 of memory space. You
can do this by careful programming, putting a jmp $+8 / db 6 dup (0) after
each 247 bytes of code, or can store the in memory or even unused spaces of
the harddrive. In this case, each time the ECC is called, it read 256 bytes
from memory or disk, and correct 249 bytes of virus code.

The best way, anyway, is only store the 6 correction bytes in a buffer, and
have a routine to calculate the range of the requested offset in the ECC
table. Something like this:

  int GetECCTablePosition(c,t)
  {
         return (((c/249)*6)+t);
  }

Where c is the code offset what we want to access the ECC value, and t is the
offset of the ECC table.

Of course, in the virus code, you need add some lines like these ones:

  extrn rsencode : near
  extrn rsdecode : near

To compile the C routines, i used Turbo C++ 3.0, a good'n'old C compiler. The
code is, more or less, ANSI based, so, you will have not problem using other
compiler, like DJGPP or Watcom. I use this params to compile:

  tcc -Z -d -mt -2 -O -a -c -p gflib.c
  tcc -Z -d -mt -2 -O -a -c -p rslib.c

These option means model tiny, 286 opcodes, compile without link, optimize
jumps and registers reload, and, specialy, Pascal callings. I use Pascal
callings because they make the routine smaller, make easier to call from
assembler, and clean the stack. Fell free to modify this is you want.

In the virus code, to call the encode routine, make something like this:

   push offset BufferToProcess
   push offset DestinationBuffer
   call rsencode

The return buffer should contain the reversed entry buffer and the 6 ECC
codes. You can save all it, of just the ECC codes. To fix a block, the code
is the following:

   push offset BufferAndECCCode
   push offset DestinationBuffer
   push offset NumberOfBytesChanged
   call rsencode

The first buffer is the reversed virus code together with the 6 ECC codes.
The destination buffer will have the corrected virus code, and the memory
word pointed for the last parameter is the number of errors detected. Remember
that is this word is above 4, the code wasnt corrected, because too much
errors where detected. Take the apropriated action them, like format the HD
or, more likely, reboot. Users will blame the AV for this. :->

Thanks to the Pascal calling convention, the ECC routines clean the stack, so
the pushed params dont mess the virus. If you want the ASM code of the C
routines, just add a -S command switch to the compiler. The code produced
can be optimized by hand, saving much bytes (well, at least in my old compiler
that dont have a good optimization).

To finish this article, the most common approach will be a virus using these
routines. I'm very new in virus community, and cant code a real good virus to
show these technics. So,i put a little command line utility to test these
routines. But you can see these technics in real virus, as they're present
in some virus, like Yankee Doddle, XPEH and RDA.Fighter, altought the routines
present in RDA are only a hack of the Yankee Doddle code.

The utility have 3 possible parameters. For encoding, use /e. For decoding,
use /d. And to show the version of the prog, use /v. Get a text file, lets
said, readme.txt, and do the following

  ecc -e <readme.txt >encode.ecc

The result file will look as the input file with some garbage inserted. These
garbage are the ECC codes. Get a text editor and change some bytes. Make a
'A' to 'Z', this kind of stuff, but dont change too much bytes together. Then
run the utility to decode:

  ecc -d <encode.ecc >result.ecc

As you will see, all the errors introduced where corrected!!!

I wish to thanks Vecna, for translating this stuff from portuguese to english,
and (try) to teach me how code a virus, and for all 29A, for accepting this
contribution. The 29A zines are the best ones ever!

                                                    Kala-Marai

PS: Do you dont know what a Kala-Marai is?? Ask Q, or watch the StartTrek
"Deja Q" episody. :->
