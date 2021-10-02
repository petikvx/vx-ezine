
Package: pib.zip
Date: December 8th, 2004
Author: archphase archphase[at]gmail.com
Site: http://archphase.united.net.kg
Team: http://www.censorednet.org

Summary: pib is a file compressor which stands for
PackItBitch and achieves 30-50% compression rates 
with resource compression turned on.  
Tested compression rates:

Application	UPX 1.25 FSG 2.0 PIB 1.0 MEW 11	Aspack 2.12
notepad.exe	23,552	 30,493	 27,136	 29,143	37,376
IEXPLORE.exe	54,784	 87,545	 44,544	 85,743	93,696

pib also includes a more developmed version of
my weak poly.  The most important feature which
i didn't find in any compressor was the abilty to
fully extend it past its initial abilty and by this
i mean the abilty to write plugins which could encrypt
the compressed data and our stub and aide in the
development of anti-viral and anti-heuristical engines.

Regardless, source is included, enjoy.

Bugs:
 - pibpoly has an issue with stack, i dont perserve esp
   right thus it will fail on a percent of like 20%, just
   re-encrypt the file, it should work.
 - Icon Perservation sucks, I didn't know how to parse the
   IconData when I wrote it so it's sad.  Rewrite it and send
   me your work.

 - pib uses ported Rva2Offset routine from
 - pib uses apLib by Jørgen Ibsen

 Iczelion PE tutorials.

Regards,
archphase