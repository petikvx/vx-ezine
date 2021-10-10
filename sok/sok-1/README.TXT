
                              -|  Source of Kaos  |-

                              -| Inaugural Editon |-

     Well folks welcome to the preview edition of this new virus based zine.
There has been several discussion's between I and several other people in the
virus community about this zine.  The firts major issue was what should go into
the mag the second issue was the goals of this zine.  Obiviously virus source
code is going to be what goes into this zine, but the nature of this source
code has been the problem.  Needless to say some of what was said has been
taken into consideration for future editions of SOK.  The second discussion
strayed pretty far off of the original intent of this zine.  It did end up
though helping clarify those intents along with coming up with a few more ideas
that will be covered as time goes on.  If you want to take a look at where this
mag will be going and what ideas drive this then take a look at the file
RANTI.001 (Ranting and Ravings)
     This edition will be split into 4 major parts wich should help those
reading get to what they want and avoid that wich they don't want.  The parts
will be as follows:

               1.  Viruses new in nature - 3 months of age or newer.
               2.  Viruses old in nature - let me guess.. older than 3 months.
               3.  Virus writer utilities - New ones and Old ones will show up.
               4.  Virus collector utilities - any age as long as they are
                    usefull.

        See Below for a breakdown of what viruses fall under what parts.

Part I

SOK-I.003 Lauren v1.00     A Non-overwiting, non-tsr .COM infector.
                           A sample of how to really screw up TB-Clean
                           v.1b is included to help show bug fixes and some
                           optimization

SOK-I.004 Dark Radiation   A Non-Overwriting, Non-TSR .COM Infector
[Original/New]             Mild stealth with a simple XOR Loop & int
1st Virus from Dark        replacement


FNStien's Monster v3.xb    Non-Overwriting TSR com infector.
                           Very plain com infector with mild stealth, basic XOR
                           encryption note-worthy only in that avp cant see it
                           and that unless you turn TBAV and fp up to high
                           heuristics neither one of them will think that it's
                           a virus.

     I'll aplogize now for the small number of new viruses, but this was put
together on some short notice.  The 1st full edition will probably run about
5- 8 new viruses ( I hope) of wich there are 4 already.


Part II

SOK-I.001 ScreamingFist_II Memory resident encrypted com/exe infector.
[FP 2.22]                  This is probably a minor variant of a major strain
                           of this virus.

SOK-I.002 CHAD.751         Dangerous memory resident parasitic com infector.
[AVP 2.2]                  Occasionaly displays a some ascii art wich is
                           porbably meant to look like kilroy looking over the
                           fence.

SOK-I.005 ExeHdr.Headerbug TSR non-encrypting exe infector with stealth
                           BIOS-level-stealth EXE header infector
                           infects SMARTDRV.EXE to ensure residency at each
                           boot. Infects on accessed for write OR read
                           (during reads only if A-V monitor is not resident)
                           successfully infects Windows .EXE files without
                           detection even when 32-bit file access is in use
                           does not decrease available memory

SOK-I.006 Assasin_II.959   Dangerous TSR parasitic exe/com infector with stealth
                           Infects on close.  Uses dos file tables vice int21h

SOK-I-007 Ambulance.796.A  Non dangerous non tsr com infector.
[FP 2.22]                  Will search path for files and depending upon
                           infection count it may give you the ascii ambulance
                           and the siren that goes along with it..

SOK-I.008 CorporateLife    Non dangerous tsr polymorphic exe infector.
[AVP 2.2]                  Infects on DOS findfirst/next calls and if a sound
                           blaster is installed you may get something out of
                           the speakers.

SOK-I.009 LittleBrother    Harmless  tsr companion viruses.
[AVP 2.2]                  When an exe file is run you get a .com file with the
                           same name as the exe file.  On November 30th you
                           get some text printed up on the screen.

SOK-I.010 PHX.823          Dangerous tsr com & exe infector.
[AVP 2.2]                  Checks for certain files that are run and if it
                           finds a match it will reset the computer.

SOK-I.011 Shifter          TSR .OBJ file that are to be .com files infector.
[AVP 2.2]                  Infects on file close.

SOK-I.012 Pro-Alife.3423   Dangerous tsr .exe infector.
[AVP 2.2]                  Infects on execution and displays one of several
                           messages upon termination.  If AV software is run it
                           will overwrite the av prg with a trj that displays
                           some cute ascii grafix.

SOK-I.013 DataRape v2.3    Dangerous virus, with destructive code!
                           Only included because AVP doesnt see it.


Part III

MTE                        v.91b and 1.00b of one of the first encryption
                           engines.


Part IV

VDATA14.ZIP                Not as good as tbweeder for getting rid of dupe
                           viruses, but it's very effective for dupe source
                           code.



     Load up the SOK-I.TOC Table of Contents to get an idea of what each article
is actually called.

Required software to compile these viruses:  All to the above viruses compile
either under TASM 2.x or A86

                                                  Armand


Greets to: Torn & Poltergiest - thnx for the quick help on the encryption stuff.
                                and beta.2 readers
           Methyl             - SOK beta.1 reader & anti-tbclean virus
           KDKD               - reminding me to step back from the screen to
                                see the big picture!
           Galar & ShadSeek   - Contributions to the archives!
           Retch              - for the expected source code to be seen in vlad7
           VLAD, IR, 40Hex    - Keep pumping out the info! or thanx for the info
                                you did pump out.
           DC & Genesis       - New groups wich I hope to see provide some good
                                quality viruses and tools!
Legal Shtuff:
TBAV,AVP,Fprot are names of respective AV products and thier name belongs to
them.  TASM is a Borland product thus its name and such belongs to Borland.
This mag is here for educational purposes only. (bridge brooklyn sell ??)

If your stupid enough to infect yourself with something out of this mag than
you deserved it..  No one can be held responsible for your stupidity.
