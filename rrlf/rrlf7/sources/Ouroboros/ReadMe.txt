[PHP.ouroboros]
by: Nomenumbra

PHP.ouroboros is a webworm written in php.
PHP.ouroboros is a PoC-worm, which means it's just a sample of several techniques in the
relatively new field of PHP VXing, and spreading is not encouraged!
PHP.Ouroboros propagates trough multiple webvulns, installing itself on the server
,infecting and backdooring files and defacing the server.
The author is not to be held responsible for any damage or unpleasant stuff coming forth from
this code and/or anything related to it, now SUCK ON THAT!

"usage":

In order to get the worm working (you didn't think i'd give a fully working version out now did you?) you need to remove all
commets out of the code, and merge all files to one (that is, no longer using them as an include, but just dumping all functions in
one bigass file) then you're ready to GOGOGO! (not literally of course XD)

"Modus Operandi":

Worm operations:
  1)Initialize worm, send signature (file was just called by other worm that exploited this server)
  2)Update the worm (if the downloaded version is newer)
  3)Deface current server
  4)Start exploitation routine
  5)Start file infection routine

Exploitation operates as follows:
  1) loop trough all exploit dorks and query google
  2) loop trough a maximum of $MAIN['searchlimit'] google results (starting at a random position) and attempt to exploit them all
  3) query the worm file on the remote server, if it responds with the worm signature, we know it's infected
Notes:
  we won't check on forehand if the server is already infected, although this might make the worm FAAAAAAR speedier
     (and prevent the risk of a huuuge DDoS of the internet in general (adding a bit of code that'd do a check would be easy, but i can't be bothered)), it would allow people to make their server send out false responses
     thus keeping the worm from their servers.

File infection will operate as follows:

  1)Crawl drive for php files.
  2)If filename matches the backdoor regex, we backdoor it and go to step 1.
  3)The file has a 2/5 chance of being infected.
  4)The file has a 1/5 chance of being obfuscated instead of being infected (see 5 for reason).
  5)If infected (and not infected before) , the file has a 1/5 chance of being appended and a 1/5 of being infected with EPO
    techniques. If appended, the file will be obfuscated and scrambled as well, so it will be hard
    to analyze infected files. It won't be a good option to delete just all obfuscated files since
    some non-infected files are obfuscated as well.
  6)Backdoored files will never be scrambled, thus hiding their prescence and due to the fact
    that not all files are infected it'll be hard to spot the backdoor.

Customizing:

  I) Customizing anything is ok, as long as you leave the credit notice intact
  II) It's easy to add new exploit modules to the exploitation engine, just make sure the exploit follows the following rules
     (unless you wanna get into real difficult stuff and actually make an automated "hacker" XD )
       1) Exploit must upload the viral file to the target server
       2) uploaded file must be accessible with a GET request (to activate the worm on that server)
  III) the global $MAIN['changevars'] must not contain common  vars like $i, lest you want to fuck everything up
  IV) The global $MAIN['signature'] must be unique enough not to be present in non-infected files
  V) Make sure you include $MAIN['vx_version'] = <versionnumber> with every new release (for update) and <versionnumber> must always be an integer and higher than the last release

Ideas/Todo:

 -)Using RSA to encrypt the backuped files
 -)Cross-infection (PHP->VBS/JS/BAT) || (PHP->CPP (source code infection))
 -)more exploits
 -)faster/smaller
