LOADING ELF FILES UNDER W32

Sometimes, we have a cool program, as a exploit, that only compile for linux.
Porting to w32 can be possible, but is too much work, and we all are busy
peoples. So lets try to load a ELF file under w32, setting up stuffs to it
run as it was supposed to do.

First thing is load ELF in memory, at his default base address, 0x08048000.
For this, we use VirtualAlloc() API, that work, coz this address is usually
free under w32. Note that, coz w32 align memory allocs to 0x10000, we ask
for need size+0x8000, at 0x08048000-0x8000. Thus we have a unused hole at
start of our loaded ELF file.

After we load the ELF file in the desired baseaddress, find and parse the
section headers, searching for sections .PLT, .REL.PLT, .DYNSTR and .DYNSYM.

Now we know the address of these important sections, we get the .PLT and,
using the info in the others named sections, we search for functions from
LIBC. If we have a simulacrum for this function, we build a jump dispatcher
to it. Else, we make this dispatcher point to a UNHANDLED_FUNCTION() routine.

Now, is time to scan program header in ELF file, and set memory protection
to reflect the ELF requests. That step is not really needed, i guess.

By last, we set a SEH frame, pointing to a EXCEPTION() function, and pass
control to to ELF entrypoint.

The LIBC funtions that need be emulated varies with each ELF we need load.
All ones will need __libc_start_main(), that parse the cmdline, and jump to
the 2nd param in stack. In the "Hello, World" sample we emulate, the only
other function emulated is printf().

Together with this article, i included a two working versions of the idea, 
capable to emulate a HelloWorld, in ASM(for MASM) and C(fancier, for BCC).

(c) Vecna/29A 2004