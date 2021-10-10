----------------------------------------------------------------------
 Anti-Virus Command Line Scanner by Dmitry Znosko
 Copyright (c) 1998                               

 BETA version 0.9.2.14       
 Date: Apr 30 1998 
----------------------------------------------------------------------

----------------------------------------------------------------------
COMMAND-LINE SCANNER
----------------------------------------------------------------------
Contents:

 * About Anti-Virus Command Line Scanner (BETA version)
 * System requirements
 * Installation
 * Scanner command-line switches
 * Comparision with other Anti-Viruses (McAfee VirusScan, Norton AV, AVP,DrWeb)
 * About BETA testing 
 * How to contact me 


----------------------------------------------------------------------
About Anti-Virus Command Line Scanner (BETA version)
----------------------------------------------------------------------
This BETA version of Scanner is freeware.
This Scanner can detect file-viruses in executable dos files .
Scanner detects all types of file-viruses:
 * Troians
 * Trivial viruses
 * Encrypted viruses
 * Polymorphic viruses

Now scanner can detect 7380 viruses.

Why only 7380 ? ... Because now I have only 7466 viruses samples in 
my virus collection ... 

Example of viruses, which can be detected using this Scanner :

MTE.Shocker
SMEG.V3
RDA.Fighter.7408


----------------------------------------------------------------------
System requirements
----------------------------------------------------------------------
Command-Line Scanner has the following system requirements:

 * PC/AT 386 compatible or better
 * Windows95 / WindowsNT 3.5 or higher
 * 1 MBs of available disk space


----------------------------------------------------------------------
Installation
----------------------------------------------------------------------
None of special installation , just copy all files 
to one directory on hard drive .

In this package :
scanner.exe  - Anti-Virus Command Line scanner .
db           - Virus Database with 7380 virus descriptions .
virlist.txt  - Names of viruses detected by Scanner .
readme_r.txt - Russian document.
readme.txt   - English document.

----------------------------------------------------------------------
Scanner command-line switches
----------------------------------------------------------------------
You can run Scanner from the command prompt in Windows or
from the Run dialog box in Windows.

Usage:scanner.exe <files_to_scan> </s>

 /s - scan all subdirectories too

Example:   scanner.exe c:\*.* /s 
    This command will scan all files on logical drive C:


----------------------------------------------------------------------
 Comparision with other Anti-Viruses (speed tests)  
----------------------------------------------------------------------
I tested several anti-virus products on two sets of files :
 
 1. My collection of CLEAR FILES (3027 different software files )

 2. Files from MS-DOS 6.22 , some archiving utilities (PKZIP,ARJ,RAR,..)
     and files from Norton Commander 5.0 . Total 145 files .
     ( Files, that probably often persist on user hard drive )


Name of product              Set 1 (3027 files) I  Set 2 (145 files)
----------------------------------------------------------------------
Scanner by Dmitry Znosko for      I             I
Windows95/NT Command Line         I   429 sec   I   8 sec
 ver BETA 0.9.2.13  7380 viruses  I     *)      I
----------------------------------------------------------------------
McAfee VirusScan for Windows NT   I             I
Command Line (ntscan)             I   738 sec   I  21 sec
 ver 3.1.7    11640 viruses       I             I
----------------------------------------------------------------------
Norton AntiVirus for DOS          I   285 sec   I   9 sec
 ver 1.0     ????? viruses        I             I
----------------------------------------------------------------------
AntiViral Toolkit Pro for DOS     I   341 sec   I  13 sec
 ver 3.0      12409 viruses       I             I
----------------------------------------------------------------------
Dr.Web for DOS                    I  1380 sec   I  23 sec
 ver 3.27      4065 viruses       I             I
----------------------------------------------------------------------

*) On small number of files from SET 1 this BETA version of Scanner works slow 
 (up to 10 sec on file) and this affects on result time . 
Now I am working on this problem , but the solution will be included 
 only in future versions of Scanner.

Also I test quality of detection of some complex viruses.
When I check detection on virus RDA.Fighter.7408, I see that McAfee VirusScan
can't detect RDA.Figter.7408 in half of the samples .Others detect all samples.



----------------------------------------------------------------------
 About BETA testing 
----------------------------------------------------------------------
If you find that Scanner crashes while scanning some file or works 
 incorrectly, please, send this file and your comments to me.
If I find it interesting, you will recieve all future commercial versions
of this product FREE of charge.

E-mail for beta testing: beta_scanner@hotmail.com

----------------------------------------------------------------------
 How to contact me 
----------------------------------------------------------------------

I live in Moscow ,Russia .

If you take a commercial interest in the Scanner, send me your proposals.
My e-mail: dznosko@hotmail.com

----------------------------------------------------------------------

                                                         Dmitry Znosko

