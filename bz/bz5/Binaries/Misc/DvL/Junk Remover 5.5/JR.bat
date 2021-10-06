@echo off
:men00
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo.
echo    1    Icons/fonts cache cleaning
echo.
echo    2    Recycle Bin cleaning
echo.
echo    3    Junk cleaning
echo.
echo    4    Registry/MRU cleaning
echo.
echo    5    Help
echo.
echo.
echo.
echo    Q    Quit
echo.
choice /c:12345q>nul
if errorlevel 6 goto done
if errorlevel 5 goto help
if errorlevel 4 goto men01
if errorlevel 3 goto opt02
if errorlevel 2 goto opt01
if errorlevel 1 goto opt00

:opt00
@ctty nul
for %%_ in (%windir%\shelli~1;%windir%\ttfcache) do deltree/y>nul %%_
ctty con
goto men00

:opt01
@ctty nul
for %%_ in (c;d;e;f;g;h;i;j;k;l;m;n;o;p;q;r;s;t;u;v;w;x;y;z) do %comspec% /f /c deltree/y %%_:\recycled\>nul
ctty con
goto men00

:opt02
@ctty nul
for %%_ in (%windir%\help\*.gid;%windir%\system\*.gid;c:\*.gid;%windir%\*.gid;c:\*.bak;%windir%\*.bak;c:\*.bk?;%windir%\*.bk?;%windir%\*.bad) do deltree/y>nul %%_
for %%_ in (%windir%\recent\;%windir%\favorites\;%windir%\history\;%windir%\cookies\;%windir%\tempor~1\;c:\tmp\;c:\temp\;%temp%\) do deltree/y>nul %%_
for %%_ in (c:\*.wc;c:\*.tmp;%windir%\*.tmp;c:\*.~mp;%windir%\*.~mp;c:\*.old;%windir%\*.old;c:\iq-point;c:\*.--?;%windir%\*.--?) do deltree/y>nul %%_
for %%_ in (c:\*.00?;%windir%\*.00?;c:\*.now;%windir%\*.now;%windir%\inf\*.now;%windir%\inf\other\*.now;c:\*.chk;%windir%\*.chk;c:\*.bad) do deltree/y>nul %%_
ctty con
goto men00

:men01
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    Axialis
echo.
echo    2    Microsoft
echo.
echo    3    Real Networks
echo.
echo    4    WinRAR
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:1234bq>nul
if errorlevel 6 goto done
if errorlevel 5 goto men00
if errorlevel 4 goto men06
if errorlevel 3 goto men05
if errorlevel 2 goto men03
if errorlevel 1 goto men02

:men02
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    AX-Icons 4.5
echo.
echo    2    AX-Cursors 4.5
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:12bq>nul
if errorlevel 4 goto done
if errorlevel 3 goto men01
if errorlevel 2 goto opt04
if errorlevel 1 goto opt03

:opt03
@ctty nul
echo.REGEDIT4>%tmp%\axico.reg
echo.>>%tmp%\axico.reg
echo.[-HKEY_CURRENT_USER\SOFTWARE\Axialis\AX-Icons 4.5\Recent File List]>>%tmp%\axico.reg
regedit /s %tmp%\axico.reg
ctty con
goto men02

:opt04
@ctty nul
echo.REGEDIT4>%tmp%\axcurs.reg
echo.>>%tmp%\axcurs.reg
echo.[-HKEY_CURRENT_USER\SOFTWARE\Axialis\AX-Cursors 4.5\Recent File List]>>%tmp%\axcurs.reg
regedit /s %tmp%\axcurs.reg
ctty con
goto men02

:men03
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    Access
echo    2    Excel
echo    3    Media Player
echo    4    PowerPoint
echo    5    WordPad
echo    6    Paint
echo    7    Explorer
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:1234567bq>nul
if errorlevel 9 goto done
if errorlevel 8 goto men01
if errorlevel 7 goto men04
if errorlevel 6 goto opt10
if errorlevel 5 goto opt09
if errorlevel 4 goto opt08
if errorlevel 3 goto opt07
if errorlevel 2 goto opt06
if errorlevel 1 goto opt05

:opt05
@ctty nul
echo.REGEDIT4>%tmp%\access.reg
echo.>>%tmp%\access.reg
echo.[HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Access\Settings]>>%tmp%\access.reg
echo."MRU1"=->>%tmp%\access.reg
echo."MRU2"=->>%tmp%\access.reg
echo."MRU3"=->>%tmp%\access.reg
echo."MRU4"=->>%tmp%\access.reg
echo.>>%tmp%\access.reg
echo.[HKEY_USERS\.DEFAULT\Software\Microsoft\Office\8.0\Access\Settings]>>%tmp%\access.reg
echo."MRU1"=->>%tmp%\access.reg
echo."MRU2"=->>%tmp%\access.reg
echo."MRU3"=->>%tmp%\access.reg
echo."MRU4"=->>%tmp%\access.reg
regedit /s %tmp%\access.reg.reg
ctty con
goto men03

:opt06
@ctty nul
echo.REGEDIT4>%tmp%\excel.reg
echo.>>%tmp%\excel.reg
echo.[HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Excel\Recent File List]>>%tmp%\excel.reg
echo."File1"=->>%tmp%\excel.reg
echo."File2"=->>%tmp%\excel.reg
echo."File3"=->>%tmp%\excel.reg
echo."File4"=->>%tmp%\excel.reg
echo."File5"=->>%tmp%\excel.reg
echo."File6"=->>%tmp%\excel.reg
echo."File7"=->>%tmp%\excel.reg
echo."File8"=->>%tmp%\excel.reg
echo."File9"=->>%tmp%\excel.reg
echo.>>%tmp%\excel.reg
echo.[HKEY_USERS\.DEFAULT\Software\Microsoft\Office\8.0\Excel\Recent File List]>>%tmp%\excel.reg
echo."File1"=->>%tmp%\excel.reg
echo."File2"=->>%tmp%\excel.reg
echo."File3"=->>%tmp%\excel.reg
echo."File4"=->>%tmp%\excel.reg
echo."File5"=->>%tmp%\excel.reg
echo."File6"=->>%tmp%\excel.reg
echo."File7"=->>%tmp%\excel.reg
echo."File8"=->>%tmp%\excel.reg
echo."File9"=->>%tmp%\excel.reg
regedit /s %tmp%\excel.reg
ctty con
goto men03

:opt07
@ctty nul
echo.REGEDIT4>%tmp%\mplayer.reg
echo.>>%tmp%\mplayer.reg
echo.[HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentURLList]>>%tmp%\mplayer.reg
echo."URL0"=->>%tmp%\mplayer.reg
echo."URL1"=->>%tmp%\mplayer.reg
echo."URL2"=->>%tmp%\mplayer.reg
echo."URL3"=->>%tmp%\mplayer.reg
echo."URL4"=->>%tmp%\mplayer.reg
echo."URL5"=->>%tmp%\mplayer.reg
echo."URL6"=->>%tmp%\mplayer.reg
echo."URL7"=->>%tmp%\mplayer.reg
echo."URL8"=->>%tmp%\mplayer.reg
echo."URL9"=->>%tmp%\mplayer.reg
regedit /s %tmp%\mplayer.reg
ctty con
goto men03

:opt08
@ctty nul
echo.REGEDIT4>%tmp%\ppoint.reg
echo.>>%tmp%\ppoint.reg
echo.[HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\PowerPoint\Recent File List]>>%tmp%\ppoint.reg
echo."File1"=->>%tmp%\ppoint.reg
echo."File2"=->>%tmp%\ppoint.reg
echo."File3"=->>%tmp%\ppoint.reg
echo."File4"=->>%tmp%\ppoint.reg
echo."File5"=->>%tmp%\ppoint.reg
echo."File6"=->>%tmp%\ppoint.reg
echo."File7"=->>%tmp%\ppoint.reg
echo."File8"=->>%tmp%\ppoint.reg
echo."File9"=->>%tmp%\ppoint.reg
echo."File0"=->>%tmp%\ppoint.reg
regedit /s %tmp%\ppoint.reg
ctty con
goto men03

:opt09
@ctty nul
echo.REGEDIT4>%tmp%\wordpad.reg
echo.>>%tmp%\wordpad.reg
echo.[-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Applets\Wordpad\Recent File List]>>%tmp%\wordpad.reg
echo.>>%tmp%\wordpad.reg
echo.[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Wordpad\Recent File List]>>%tmp%\wordpad.reg
regedit /s %tmp%\wordpad.reg
ctty con
goto men03

:opt10
@ctty nul
echo.REGEDIT4>%tmp%\paint.reg
echo.>>%tmp%\paint.reg
echo.[-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List]>>%tmp%\paint.reg
echo.>>%tmp%\paint.reg
echo.[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List]>>%tmp%\paint.reg
regedit /s %tmp%\paint.reg
ctty con
goto men03

:men04
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    Typed URLs
echo    2    Find Computer
echo    3    Run
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:123bq>nul
if errorlevel 5 goto done
if errorlevel 4 goto men03
if errorlevel 3 goto opt13
if errorlevel 2 goto opt12
if errorlevel 1 goto opt11

:opt11
@ctty nul
echo.REGEDIT4>%tmp%\typedurl.reg
echo.>>%tmp%\typedurl.reg
echo.[-HKEY_USERS\.DEFAULT\Software\Microsoft\Internet Explorer\TypedURLs]>>%tmp%\typedurl.reg
regedit /s %tmp%\typedurl.reg
ctty con
goto men04

:opt12
@ctty nul
echo.REGEDIT4>%tmp%\findcpu.reg
echo.>>%tmp%\findcpu.reg
echo.[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FindComputerMRU]>>%tmp%\findcpu.reg
echo."a"=->>%tmp%\findcpu.reg
echo."MRUList"="abcdefghij">>%tmp%\findcpu.reg
echo."b"=->>%tmp%\findcpu.reg
echo."c"=->>%tmp%\findcpu.reg
echo."d"=->>%tmp%\findcpu.reg
echo."e"=->>%tmp%\findcpu.reg
echo."f"=->>%tmp%\findcpu.reg
echo."g"=->>%tmp%\findcpu.reg
echo."h"=->>%tmp%\findcpu.reg
echo."i"=->>%tmp%\findcpu.reg
echo."j"=->>%tmp%\findcpu.reg
regedit /s %tmp%\findcpu.reg
ctty con
goto men04

:opt13
@ctty nul
echo.REGEDIT4>%tmp%\run.reg
echo.>>%tmp%\run.reg
echo.[-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU]>>%tmp%\run.reg
regedit /s %tmp%\run.reg
ctty con
goto men04

:men05
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    Real Player  
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:1bq>nul
if errorlevel 3 goto done
if errorlevel 2 goto men01
if errorlevel 1 goto opt14

:opt14
@ctty nul
echo.REGEDIT4>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips1]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips2]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips3]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips4]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips5]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips6]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips7]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
echo.[HKEY_CLASSES_ROOT\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips8]>>%tmp%\realplay.reg
echo.@="">>%tmp%\realplay.reg
echo.>>%tmp%\realplay.reg
regedit /s %tmp%\realplay.reg
ctty con
goto men05

:men06
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo    1    WinRAR 2.90
echo.
echo.
echo    B    Back
echo    Q    Quit
echo.
choice /c:1bq>nul
if errorlevel 3 goto done
if errorlevel 2 goto men01
if errorlevel 1 goto opt15

:opt15
@ctty nul
echo.REGEDIT4>%tmp%\winrar.reg
echo.>>%tmp%\winrar.reg
echo.[-HKEY_CURRENT_USER\SOFTWARE\WinRAR\DialogEditHistory\ArcName]>>%tmp%\winrar.reg
echo.>>%tmp%\winrar.reg
echo.[-HKEY_USERS\.DEFAULT\SOFTWARE\WinRAR\DialogEditHistory\ArcName]>>%tmp%\winrar.reg
regedit /s %tmp%\winrar.reg
ctty con
goto men06

:help
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo.
echo     Icons/fonts cache cleaning
echo     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo.
echo.
echo     This option deletes ShellIconCache & ttfCache files.
echo     You should use this option if you experience displaying problems.
echo     I recommend to use this option once or twice a week.
echo.
echo.
echo     Next page ...
pause>nul
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo.
echo     Recycle Bin cleaning
echo     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo.
echo.
echo     This option deletes all files from your Recycle Bin(s).
echo     You should ONLY use this option if you think a virus/file is hidding
echo     in here.
echo.
echo.
echo     Next page ...
pause>nul
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo.
echo     Junk cleaning
echo     ÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo.
echo.
echo     This option deletes all unnecesary/temp/unwanted files.
echo     I recommend to use this option once or twice a week.
echo.
echo.
echo     Next page ...
pause>nul
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.5 [DvL] Û²±° ³
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                             www.batch-zone.de.vu
echo.
echo.
echo.
echo     Registry/MRU cleaning
echo     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo.
echo.
echo     This option deletes all Most Recently Used history.
echo     I recommend to use this option once or twice a week.
echo.
echo.
echo     Main menu ...
pause>nul
goto men00

:done
cls