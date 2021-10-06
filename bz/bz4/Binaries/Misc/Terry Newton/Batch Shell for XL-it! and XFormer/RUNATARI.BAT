:: RUNATARI.BAT version 0.22a Feb 11 98
:: Requires Dos 6 or Win95 w/ QBasic
:: This batch runs the XL-it! and XFormer Atari emulators.
:: Associate .ATR/.XFD files with this, press ESC when loading
:: to adjust pararamers, saves settings for the disk when the
:: emulator is run.
@echo off
if .%1==.GotoInput goto input
if .%1==.GotoShell goto shell
%comspec% /e:8192 /c %0 GotoShell %1
goto lastline
:shell
:: !!! Modify below to match your setup (after =) 
:: **** program drive and directory...
set progdir=D:\OLDCOMP\ATARI800
:: **** XL-it! filenames...
set xlprog=ATARIXL.EXE
set xldocs=XL_DOC.TXT
:: **** xformer filenames and options...
set xfprog=XFORMER.EXE
set xfdocs=XFORMER.TXT
:: **** file viewer...
set listprog=LIST
:: **** default XL-it! settings...
:: on is 'set -nopatch=-nopatch' 
set -nobasic=-nobasic
set -joyswap=-joyswap
set -nosound=-nosound
set -artifact=
set -nopatch=
set hddir=.
:: **** default xformer setttings...
:: Joy Turbo Sound Ad-less Nobasic 800-mode
:: on is 'set -J=-J' for example
set -J=
set -T=
set -S=
set -A=-A
set -N=
set -8=

::default emulator...
set usexf=
::set usexf=-usexf

set atrdisks=
set fid=
%progdir%\
cd %progdir%

:: derive an id from filename using QBasic...
echo>runat$$.bas f$="%2":if sgn(4-len(f$))=1 then system
echo>>runat$$.bas open "runat$$.bat" for output as #1
echo>>runat$$.bas ? #1,"set fid=";:fp=len(f$)-4 
echo>>runat$$.bas fidloop:if fp=0 or mid$(f$,fp,1)="\" goto x
echo>>runat$$.bas ? #1,mid$(f$,fp,1);:fp=fp-1:goto fidloop
echo>>runat$$.bas x:? #1,"":close #1:system
qbasic /run runat$$.bas
if exist runat$$.bat call runat$$.bat
del runat$$.*
set fid=*%fid%*

:: check for config entry
if not exist runatari.cfg goto askconfig
find "%fid%"<runatari.cfg>runatari.$$
copy runatari.$$ runatari.$$$>nul
del runatari.$$
if not exist runatari.$$$ goto askconfig

:: does exist... check and set flags

:: set atrdisks variable
find "%%"<runatari.$$$>runat$$.bat
call runat$$.bat
del runat$$.bat

set usexf=
find "-usexf"<runatari.$$$>nul
if not errorlevel 1 set usexf=-usexf
if .%usexf%==. goto getxlp

set -J=
find "-J"<runatari.$$$>nul
if not errorlevel 1 set -J=-J 
set -N=
find "-N"<runatari.$$$>nul
if not errorlevel 1 set -N=-N 
set -T=
find "-T"<runatari.$$$>nul
if not errorlevel 1 set -T=-T 
set -A=
find "-A"<runatari.$$$>nul
if not errorlevel 1 set -A=-A 
set -S=
find "-S"<runatari.$$$>nul
if not errorlevel 1 set -S=-S 
set -8=
find "-8"<runatari.$$$>nul
if not errorlevel 1 set -8=-8 
del runatari.$$$
goto askconfig

:getxlp
set -nobasic=
find "-nobasic"<runatari.$$$>nul
if not errorlevel 1 set -nobasic=-nobasic
set -joyswap=
find "-joyswap"<runatari.$$$>nul
if not errorlevel 1 set -joyswap=-joyswap
set -nosound=
find "-nosound"<runatari.$$$>nul
if not errorlevel 1 set -nosound=-nosound
set -artifact=
find "-artifact"<runatari.$$$>nul
if not errorlevel 1 set -artifact=-artifact
set -nopatch=
find "-nopatch"<runatari.$$$>nul
if not errorlevel 1 set -nopatch=-nopatch
del runatari.$$$

:askconfig
if .%2==. goto configure
if not exist %2 goto configure

echo [1;37;44m
cls
echo.
echo.
echo         Atari 800 Emulator Shell
echo         ========================
echo.
echo         Mounted: %2%atrdisks%
echo.
echo.
echo.
echo.
echo         Press ESC to configure...
echo.
choice /c:x /t:x,2>nul
if errorlevel 2 goto configure

:run
echo [0m
cls
if not .%usexf%==. goto runxf
set -hd=
if not .%hddir%==. set -hd=-hd %hddir%
set option=
%xlprog% %-hd% %-nobasic% %-joyswap% %-artifact% %-nosound% %-nopatch% %2 %atrdisks%
if not .%2==. goto end
goto configure
:runxf
%xfprog% %-J% %-S% %-N% %-A% %-T% %-8% %2 %atrdisks%
if not .%2==. goto end

:configure
echo [1;37;44m
cls
echo.
echo.
echo         Atari 800 Emulator Shell
echo         ========================
echo.
echo         Mounted: %2%atrdisks%
set atrdmod=Yes
echo %atrdisks%>runatari.$$
find "."<runatari.$$>nul
if errorlevel 1 set atrdmod=No
del runatari.$$
echo.
if not .%usexf%==. goto xfset
if .%-nobasic%==. echo         1 - BASIC is Enabled
if not .%-nobasic%==. echo         1 - BASIC is Disabled
if .%-nosound%==. echo         2 - Sound effects are Enabled
if not .%-nosound%==. echo         2 - Sound effects are Disabled
if .%-artifact%==. echo         3 - Artifacting is Disabled
if not .%-artifact%==. echo         3 - Artifacting is Enabled
if .%-joyswap%==. echo         4 - Joysticks are not swapped
if not .%-joyswap%==. echo         4 - Joysticks are swapped
if .%-nopatch%==. echo         5 - OS is patched
if not .%-nopatch%==. echo         5 - OS is not patched
if .%hddir%==. echo         6 - Specify hard disk dir
if not .%hddir%==. echo         6 - Hard disk dir = %hddir%
echo.
echo         E - Emulator: XL-it!
goto comset
:xfset
if .%-N%==. echo         1 - BASIC is Enabled
if not .%-N%==. echo         1 - BASIC is Disabled
if .%-S%==. echo         2 - Sound effects are Disabled
if not .%-S%==. echo         2 - Sound effects are Enabled
if .%-A%==. echo         3 - Show startup screen
if not .%-A%==. echo         3 - Skip startup screen
if .%-J%==. echo         4 - Joysticks are Disabled
if not .%-J%==. echo         4 - Joysticks are Enabled
if .%-T%==. echo         5 - Normal speed
if not .%-T%==. echo         5 - Turbo speed
if .%-8%==. echo         6 - XL emulation
if not .%-8%==. echo         6 - 800 emulation
echo.
echo         E - Emulator: Xformer
:comset
echo         F - Mount file
echo         M - Mount ATR disk
echo         C - Copy ATR disk
echo         U - Unmount disks
echo.
echo         G - Go! Run Simulator
echo         L - List simulator docs
echo         Q - Quit
echo.
choice /c:123456MCUGLEFQ >nul
if errorlevel 14 goto end
if errorlevel 13 goto addfile
if errorlevel 12 goto swe
if errorlevel 11 goto listdocs
if errorlevel 10 goto save&run
if errorlevel 9 goto unmount
if errorlevel 8 goto copyatr
if errorlevel 7 goto mount
if errorlevel 6 goto sw6
if errorlevel 5 goto sw5
if errorlevel 4 goto sw4
if errorlevel 3 goto sw3
if errorlevel 2 goto sw2
if errorlevel 1 goto sw1
goto end
:sw1
if .%-nobasic%==. set -nobasic=x
if .%-nobasic%==.-nobasic set -nobasic=
if .%-nobasic%==.x set -nobasic=-nobasic
if .%-N%==. set -N=x
if .%-N%==.-N set -N=
if .%-N%==.x set -N=-N
goto configure
:sw2
if .%-nosound%==. set -nosound=x
if .%-nosound%==.-nosound set -nosound=
if .%-nosound%==.x set -nosound=-nosound
if .%-S%==. set -S=x
if .%-S%==.-S set -S=
if .%-S%==.x set -S=-S
goto configure
:sw3
if .%-artifact%==. set -artifact=x
if .%-artifact%==.-artifact set -artifact=
if .%-artifact%==.x set -artifact=-artifact
if .%-A%==. set -A=x
if .%-A%==.-A set -A=
if .%-A%==.x set -A=-A
goto configure
:sw4
if .%-joyswap%==. set -joyswap=x
if .%-joyswap%==.-joyswap set -joyswap=
if .%-joyswap%==.x set -joyswap=-joyswap
if .%-J%==. set -J=x
if .%-J%==.-J set -J=
if .%-J%==.x set -J=-J
goto configure
:sw5
if .%-nopatch%==. set -nopatch=x
if .%-nopatch%==.-nopatch set -nopatch=
if .%-nopatch%==.x set -nopatch=-nopatch
if .%-T%==. set -T=x
if .%-T%==.-T set -T=
if .%-T%==.x set -T=-T
goto configure
:sw6
if .%usexf%==. goto hd
if .%-8%==. set -8=x
if .%-8%==.-8 set -8=
if .%-8%==.x set -8=-8
goto configure
:swe
if .%usexf%==. set usexf=x
if .%usexf%==.-usexf set usexf=
if .%usexf%==.x set usexf=-usexf
goto configure

:save&run
if .%fid%==. goto run
rem>>runatari.cfg
find/v "%fid%"<runatari.cfg>runatari.$$
if %atrdmod%==No goto save2
echo>>runatari.$$ set atrdisks=%atrdisks%%% %fid%%%
:save2
if .%usexf%==. goto save3
echo>>runatari.$$ %fid% %usexf% %-J% %-S% %-N% %-A% %-T% %-8%
goto save4
:save3
echo>>runatari.$$ %fid% %-nobasic% %-joyswap% %-nosound% %-artifact% %-nopatch%
:save4
copy runatari.$$ runatari.cfg>nul
del runatari.$$
goto run

:listdocs
set str=%xldocs%
if not .%usexf%==. set str=%xfdocs%
call %listprog% %str%
goto configure

:hd
echo.
echo Enter hard drive directory...
call %0 GotoInput
set hddir=%str%
if .%hddir%==. goto configure
if not exist %hddir%\nul set hddir=
goto configure

:mount
echo [0m
cls
echo.
echo.
echo         Atari 800 Emulator Shell
echo         ========================
echo.
echo         Mounted: %2%atrdisks%
echo.
echo         Select file to mount...
echo.
selfile *.atr
call selfile$
del selfile$.bat
if exist %main%.%ext% set atrdisks=%atrdisks% %main%.%ext%
goto configure

:unmount
set atrdisks=
goto configure

:addfile
echo [0m
cls
echo.
echo.
echo         Atari 800 Emulator Shell
echo         ========================
echo.
echo         Mounted: %2%atrdisks%
echo.
echo         Select file to mount...
echo.
selfile *.*
call selfile$
del selfile$.bat
if exist %main%.%ext% set atrdisks=%atrdisks% %main%.%ext%
goto configure

:copyatr
echo [0m
cls
echo.
echo.
echo         Atari 800 Emulator Shell
echo         ========================
echo.
echo         Select ATR file to duplicate...
echo.
selfile *.atr
call selfile$
del selfile$.bat
if not exist %main%.%ext% goto configure
echo.
echo Enter new disk name (no ext)...
call %0 GotoInput
if .%str%==. goto configure
copy %main%.%ext% %str%.%ext% >nul
goto configure

:end
echo [0m
cls
echo.
goto lastline

:input
if exist enter.bat echo input disabled - remove ENTER.BAT file
if exist enter.bat goto lastline
> en#er.bat fc con nul /lb1 /n|date|find "    1:  "
> enter.bat echo set str=
>>enter.bat echo :loop
>>enter.bat echo if not .%%str%%==. set str=%%str%% %%5
>>enter.bat echo if .%%str%%==. set str=%%5
>>enter.bat echo shift
>>enter.bat echo if not .%%5==. goto loop
call en#er.bat
for %%a in (enter.bat en#er.bat) do del %%a

:lastline
