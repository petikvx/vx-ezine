
		Win2k/XP Shell codes
		====================

Here, are some shellcodes for Windows 2000 & XP operating systems.
They were not of any practical use to me, but I learned enough about
them to understand how they worked, and how to create them, which was
my intention.

It only covers the functional part rather than features that can
be included such as compression/encryption or even polymorphism. ( although
i hardly see such a situation with polymorphic engine...atleast a REAL one. )

A polymorphic engine could modify the shell codes obfuscation algorithm before of
course being sent to exploit a buffer overflow, for example, but
don't be misled by past articles on "polymorphic shellcodes"

There are quite a number of shellcodes out there already, but
I found alot of the sources with bugs, or just hard to follow,
so i went about writing my own.
( not to say that some people won't be confused by what i've done!,
or that these are any better written ) 

Any similarities in the code here with other code is purely coincidental..
Unless otherwise stated, of course!
And I haven't forgot to mention and give credit to those who deserve it. 

Hopefully, those of you who haven't covered this stuff before will learn
something out of it.

They were created just after Jan 04, but have been modified,
and tweaked a little since then, if only just by a few bytes around May/Nov 2004.

I also reccommend looking at work by ..

Z0MBiE http://z0mbie.host.sk/ & LSD http://lsd-pl.net/

I was influenced alot by those guys and also (in alphabetical order)
Benny/29a,Greenant,GriYo/29a,Ratter/29a & Vecna/29a

Forgot to mention David Litchfield, H D Moore.
Also, metasploit..

Greetings to pendulum & twisted

Dec 2004	bcom@hushmail.com

Example:
	Using rev_overlap.exe or rev_pipes on local computer.
	Setup up netcat listener with command line: nc -vLp31337 localhost
	Then execute either module, and a prompt should appear in netcat window.
	Type 'exit' in console window to escape routine.