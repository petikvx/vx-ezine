:: MARS.BAT - by Terry Newton   (version 0.81 Feb 17 97)
::
:: This is a front end batch for the PMARSV graphics Corewar simulator.
:: Uses stock MSDOS 6 commands! Assumes COMMAND, CHOICE, FIND and FC
:: are present and on the path. Also calls EDIT, QBASIC and LIST.
:: Run this batch from the PMARS directory.
::
:: When using both the 286 and 386 versions of the binaries rename the
:: 386 version to PMARSV3.EXE (or rename the 286 to PMARSV2.EXE, works
:: either way) or specify filenames in the "other Functions" menu.
:: One of the main reasons I wrote this batch was to be able to easily
:: switch between the different binaries, on my system the 386 version
:: only works in text mode under windows so if I want graphics I select
:: the 286 binary (or exit Windows).
:: 
:: Undocumented features... (not on menu)
:: Shift-1 or Shift-2 calls LIST to view warrior - to use a different
::  lister (or editor for the edit function) change the settings in
::  this batch or in the MENUCFG.BAT file (press K(eep) to create one)
:: When listing redcode directory (?) you can press ctrl-c to
::  break out of the listing and enter the filename. Almost any
::  other time ctrl-c causes the batch to terminate.
::
:: Added many features to 'tourney' menu to make it easier to
:: test a warrior (or warriors) against a list of warriors or
:: against each other (hill-style I think:) and tally the score.
::
:: I devised these routines for my own use, they might not
:: make sense to anyone else, some features I don't need are
:: missing (like more than two warriors in the core - why?)
::
:: This batch is provided as-is without any guarantees whatsoever.
:: Tested only with Win 3.1, English Dos 6 and PMARSV.EXE version 0.8 
:: Should work with non-English Dos 6 but being batch, who knows...
:: If running Dos 5, get a copy of CHOICE.COM - looks like it'll work.
:: If your command shell program isn't command.com - change 'command '
:: lines to %comspec% and hope it works. 4dos might give it a fit.
:: If running Windows 95, make sure QBASIC is present if scoring and
:: be prepared to do some batch hacking. Good luck...
::
@echo off
if .%1==.Loop goto %2
command /e:4096 /c %0 Loop setupvars
goto quit

:setupvars
:: set the following to preference
:: or just Keep your settings to MENUCFG.BAT
:: color display if 'yes'...
set useansi=no
:: pmarsv binaries...
set core286=PMARSV.EXE
set core386=PMARSV3.EXE
:: default mode 286 or 386...
set corebin=286
set parms=
:: default warriors...
set war1=
set war2=
:: 0=fastest 7=slowest
set speed=0
:: actual mode for graphics
set gmode=1
:: TEXT or GRAPHICS
set mode=TEXT
:: 0=no info 4=max info
set info=4
:: coresize (if set)
set coresize=
:: cycles (if set)
set cycles=
:: max length (if set)
set wlen=500
:: min distance (if set)
set wdist=1000
:: rounds per run (if set)
set rounds=
:: path to warriors...
set warpath=
:: editor...
set edit=EDIT
:: file lister
set list=LIST

:reset
if exist menucfg.bat call menucfg.bat

:: cheezy validations...
if .%mode%==.TEXT goto modeok
if .%mode%==.GRAPHICS goto modeok
set mode=TEXT
:modeok
if .%corebin%==.286 goto binok
if .%corebin%==.386 goto binok
set corebin=286
:binok
if .%core286%==. set core286=PMARSV2.EXE
if .%core386%==. set core386=PMARSV3.EXE
if not exist %core286% set core286=PMARSV.EXE
if not exist %core386% set core386=PMARSV.EXE
if %corebin%==286 set core=%core286%
if %corebin%==386 set core=%core386%
if exist %core% goto coreok
echo Core file %core% missing - can't run
pause
goto quit
:coreok
if exist lastscor.tem del lastscor.tem
if exist %warpath%nul goto loopbin
echo Invalid warrior path... reseting (unless Q)
choice /c:qx /t:x,02
if errorlevel 2 set warpath=

:loopbin
if %corebin%==286 set core=%core286%
if %corebin%==386 set core=%core386%

:loop
if .%useansi%==.yes echo [1;37;44m
set warret=loop
cls
echo.
echo          PMarsV CoreWar System
echo          ---------------------
echo          1: Warrior #1 = %war1%
echo          2: Warrior #2 = %war2%
echo          P: War Path   = %warpath% 
echo          B: Bin Type   = %corebin%
echo          M: Video Mode = %mode%
echo          I: Info Level = %info%
echo          S: Speed      = %speed%
echo          R: Rounds     = %rounds%
echo          C: Cycles     = %cycles%
echo          Z: Core Size  = %coresize%
echo          D: Distance   = %wdist%
echo          L: Max Length = %wlen%
echo          X: ExtraParms = %parms%
echo.
echo          G: Go!                Q: Quit
echo          E: Edit Warrior       H: sHell to DOS
echo          K: Keep variables     O: lOad last keep
echo          F: other Functions    T: Tourney mode  
echo.
choice /c:12BXSMIGEHKOQRCZPDLFT!@>nul
if errorlevel 22 goto listwarrior
if errorlevel 21 goto tourney
if errorlevel 20 goto otherfun
if errorlevel 19 goto maxlen
if errorlevel 18 goto mindist
if errorlevel 17 goto warpath
if errorlevel 16 goto coresize
if errorlevel 15 goto cycles
if errorlevel 14 goto turns
if errorlevel 13 goto quit
if errorlevel 12 goto reset
if errorlevel 11 goto keep
if errorlevel 10 goto shelldos
if errorlevel 9 goto editwar
if errorlevel 8 goto go
if errorlevel 7 goto info
if errorlevel 6 goto mode
if errorlevel 5 goto speed
if errorlevel 4 goto getparms
if errorlevel 3 goto getbin
if errorlevel 1 goto getwar
echo EEEKS! No CHOICE!
goto quit

:listwarrior
set str=%war1%
if errorlevel 23 set str=%war2%
if .%str%==. goto loop
if not exist %str% goto loop
call %list% %str%
goto loop

:getbin
if %corebin%==386 set corebin=x
if %corebin%==286 set corebin=386
if %corebin%==x set corebin=286
goto loopbin

:info
if %info%==4 set info=x
if %info%==3 set info=4
if %info%==2 set info=3
if %info%==1 set info=2
if %info%==0 set info=1
if %info%==x set info=0
goto loop

:speed
if %speed%==7 set speed=x
if %speed%==6 set speed=7
if %speed%==5 set speed=6
if %speed%==4 set speed=5
if %speed%==3 set speed=4
if %speed%==2 set speed=3
if %speed%==1 set speed=2
if %speed%==0 set speed=1
if %speed%==x set speed=0
goto loop

:mode
if %mode%==GRAPHICS set mode=x
if %mode%==TEXT set mode=GRAPHICS
if %mode%==x set mode=TEXT
goto loop

:getwar
set wn=1
if errorlevel 2 set wn=2
:getwar1
echo Enter Warrior #%wn%... (? for list)
call %0 Loop input
if %str%.==. set war%wn%=
if %str%.==. goto loop
if %str%==? goto wardirectory
if exist %str% set wart=%str%
if not exist %str% set wart=%warpath%%str%
if not exist %wart% set wart=%warpath%%str%.red
if not exist %wart% goto warnotfound
set war%wn%=%wart%
goto %warret%
:warnotfound
echo Warrior not found
pause
goto %warret%
:wardirectory
command /c dir %warpath%*.red /w /p /on
goto getwar1

:listparms
%core%
:getparms
echo Enter extra parameters (? for list)...
call %0 Loop input
if .%str%==.? goto listparms
set parms=%str%
goto loop

:cycles
echo Enter maximum cycles before draw...
call %0 Loop input
set cycles=%str%
goto loop

:turns
echo Enter number of rounds per run...
call %0 Loop input
set rounds=%str%
goto %warret%

:coresize
echo Enter core size...
call %0 Loop input
set coresize=%str%
goto loop

:mindist
echo Enter minimum spacing between warriors...
call %0 Loop input
set wdist=%str%
goto loop

:maxlen
echo Enter maximum warrior length...
call %0 Loop input
set wlen=%str%
goto loop

:warpath
echo Enter Warrior Directory... (end with "\")
call %0 Loop input
set warpath=%str%
if .%str%==. goto %warret%
if exist %str%*.red goto %warret%
echo Warrior files not found
goto warpath

:shelldos
if .%useansi%==.yes echo [0m
cls
echo.
echo Warning!
echo If you change directory come back to
cd
echo before returning to menu (EXIT)
echo.
command /e:2000
goto loop

:editwar
echo Edit Warrior 1, 2, Another or Quit?
choice /c:12AQ>nul
if errorlevel 4 goto loop
if errorlevel 3 goto getedit 
if errorlevel 1 set str=%war1%
if errorlevel 2 set str=%war2%
:edit1
call %edit% %str%
goto loop
:getedit
echo Enter filename to edit...
call %0 Loop input
goto edit1

:otherfun
cls
echo.
echo.
echo          386 Binary = %core386%
echo          286 Binary = %core286%
echo.           
echo          2 - 25 line text mode
echo          4 - 43 line text mode
echo          5 - 50 line text mode
echo          B - change Binary filenames
echo          G - actual Graphics mode = %gmode%
echo          Q - Quit this menu
echo.
choice /c:245BGQ>nul
if errorlevel 6 goto loop
if errorlevel 5 goto getgmode
if errorlevel 4 goto getbins
if errorlevel 3 goto 50lines
if errorlevel 2 goto 43lines
mode con lines=25
goto loop
:43lines
mode con lines=43
goto loop
:50lines
mode con lines=50
goto loop
:getbins
echo (be sure to Keep these)
echo Enter 386 binary filename...
call %0 Loop input
if .%str%==. goto otherfun
if not exist %str% goto bnfnd
set core386=%str%
echo.
echo Enter 286 binary filename...
call %0 Loop input
if .%str%==. goto otherfun
if not exist %str% goto bnfnd
set core286=%str%
goto loopbin
:bnfnd
echo Binary not found
pause
goto otherfun
:getgmode
echo Enter new mode for graphics...
call %0 Loop input
if .%str%==. goto otherfun
set gmode=%str%
goto otherfun

:keep
echo          Saving...
> menucfg.bat echo :: Default parameter file for MARS.BAT
>>menucfg.bat echo :: color display if yes...
>>menucfg.bat echo set useansi=%useansi%
>>menucfg.bat echo :: PMARSV filenames...
>>menucfg.bat echo set core286=%core286%
>>menucfg.bat echo set core386=%core386%
>>menucfg.bat echo :: Binary type to use...
>>menucfg.bat echo set corebin=%corebin%
>>menucfg.bat echo :: Optional parameters...
>>menucfg.bat echo set parms=%parms%
>>menucfg.bat echo :: Default mode TEXT or GRAPHICS (must be correct!)
>>menucfg.bat echo set mode=%mode%
>>menucfg.bat echo :: Actual PMARSV mode used for graphics
>>menucfg.bat echo set gmode=%gmode%
>>menucfg.bat echo :: Warrior Names...
>>menucfg.bat echo set war1=%war1%
>>menucfg.bat echo set war2=%war2%
>>menucfg.bat echo :: 0=fastest 7=slowest...
>>menucfg.bat echo set speed=%speed%
>>menucfg.bat echo :: core display - 0=min info 4=max info
>>menucfg.bat echo set info=%info%
>>menucfg.bat echo :: coresize (if set)...
>>menucfg.bat echo set coresize=%coresize%
>>menucfg.bat echo :: cycles (if set)...
>>menucfg.bat echo set cycles=%cycles%
>>menucfg.bat echo :: max length (if set)...
>>menucfg.bat echo set wlen=%wlen%
>>menucfg.bat echo :: min distance (if set)...
>>menucfg.bat echo set wdist=%wdist%
>>menucfg.bat echo :: rounds per run (if set)...
>>menucfg.bat echo set rounds=%rounds%
>>menucfg.bat echo :: path to warriors... (end with "\")
>>menucfg.bat echo set warpath=%warpath%
>>menucfg.bat echo :: name of tourney log...
>>menucfg.bat echo set outfile=%outfile%
>>menucfg.bat echo :: list of test warriors...
>>menucfg.bat echo set wl=%wl%
>>menucfg.bat echo :: editor...
>>menucfg.bat echo set edit=%edit%
>>menucfg.bat echo :: file lister...
>>menucfg.bat echo set list=%list%
goto loop

:go
cls
set option=-v %speed%
if %mode%==TEXT set option=%option%0
if %mode%==GRAPHICS set option=%option%%gmode%
set option=%parms% %option%%info%
if not .%wlen%==. set option=%option% -l %wlen%
if not .%wdist%==. set option=%option% -d %wdist%
if not .%rounds%==. set option=%option% -r %rounds%
if not .%cycles%==. set option=%option% -c %cycles%
if not .%coresize%==. set option=%option% -s %coresize%
echo %core% %option% %war1% %war2%
%core% %option% %war1% %war2%
set error=OK
if errorlevel 1 set error=file not found
if errorlevel 2 set error=command line
if errorlevel 3 set error=assembly
if errorlevel 4 set error=user exited program
if errorlevel 5 set error=unknown, I just don't know...
if errorlevel 252 set error=graphics
if errorlevel 253 set error=no 386
if errorlevel 254 set error=memory allocation
if errorlevel 255 set error=serious error - contact developers
if not %error%==OK echo Error! %error%
:waitkey 
pause
goto loop

:tourney
if .%rounds%==. set rounds=10
set option=%parms%
if not .%wlen%==. set option=%option% -l %wlen%
if not .%wdist%==. set option=%option% -d %wdist%
if not .%rounds%==. set option=%option% -r %rounds%
if not .%cycles%==. set option=%option% -c %cycles%
if not .%coresize%==. set option=%option% -s %coresize%

set pmv=-v %speed%
if %mode%==TEXT set pmv=%pmv%0
if %mode%==GRAPHICS set pmv=%pmv%%gmode%
set pmv=%core% %option% %pmv%%info%
set upmv=No

:tmenu
set pmars=PMARS %option%
if %upmv%==Yes set pmars=%pmv%
if .%outfile%==. set outfile=DEFAULT.OUT
set warret=tourney
cls
echo.
echo    Tourney Mode - Multiple Battles
echo    ===============================
echo.
echo    1: Warrior #1  = %war1%
echo    2: Warrior #2  = %war2%
echo    P: War Path    = %warpath%
if not exist %outfile% echo    O: Output file = %outfile%
if exist %outfile%     echo    O: Output file = %outfile% (append)
echo    R: Rounds      = %rounds%
echo    V: Use PMARSV  = %upmv%
echo.
echo    G: Run Warrior #1 against Warrior #2
echo    A: Run all in Path against Warrior #2
echo    E: Enter/display List of warriors 
echo    M: Run all in Path against List (deletes outfile)
echo    H: Run all in Path against Path (deletes outfile)
echo    C: Run Path against another dir (deletes outfile)
echo    I: Isolate and chart a single warrior from outfile
echo    L: List output file     D: Delete output file
echo    T: Tally scores         X: Exit to main menu
echo.
choice /c:12OLGRDXPAMEHTCIV>nul
if errorlevel 17 goto swupmv
if errorlevel 16 goto inspect
if errorlevel 15 goto mwarp
if errorlevel 14 goto tally
if errorlevel 13 goto warhill
if errorlevel 12 goto warlist
if errorlevel 11 goto multiwar
if errorlevel 10 goto warall
if errorlevel 9 goto warpath
if errorlevel 8 goto exturny
if errorlevel 7 goto deloutfile
if errorlevel 6 goto turns
if errorlevel 5 goto runtourney
if errorlevel 4 goto listscore
if errorlevel 3 goto getoutfile
if errorlevel 1 goto getwarx
goto quit
:swupmv
if %upmv%==No set upmv=Maybe
if %upmv%==Yes set upmv=No
if %upmv%==Maybe set upmv=Yes
goto tmenu
:getwarx
if exist lastscor.tem del lastscor.tem
goto getwar
:exturny
if exist lastscor.tem del lastscor.tem
goto loop
:getoutfile
echo Enter name for output log...
call %0 Loop input
set outfile=%str%
goto tmenu
:deloutfile
echo Delete %outfile% - Are You Sure?
choice /c:ny>nul
if errorlevel 2 del %outfile%
goto tmenu
:listscore
call %list% %outfile%
goto tmenu
:mgetrounds
echo Enter number of rounds...
call %0 Loop input
set rounds=%str%
goto tourney

:tally
if .%outfile%==. goto tmenu
if not exist %outfile% goto tmenu
cls
echo.
echo Scoring battles, please wait...
:: make temp qbasic program...
echo> score$.bas :on error goto donefile
echo>>score$.bas dim war$(500),score(500),plays(500):maxwar=0
:: figure out rounds
echo>>score$.bas open "%outfile%" for input as #1
echo>>score$.bas L:line input #1,a$:if instr(a$, "Results:")=0 goto L
echo>>score$.bas close #1:x=instr(a$," "):y=instr(x+1,a$," ")
echo>>score$.bas z=instr(y+1,a$," "):q=val(mid$(a$,x,y-x))
echo>>score$.bas r=val(mid$(a$,y,z-y)):s=val(right$(a$,len(a$)-z))
echo>>score$.bas rounds=q+r+s:if rounds=0 goto done
:: separate and total up all warrior scores
echo>>score$.bas for i=1 to 500:war$(i)="":score(i)=0:plays(i)=0:next i
echo>>score$.bas open "%outfile%" for input as #1
echo>>score$.bas floop:line input #1,a$:a$=ltrim$(rtrim$(a$))
echo>>score$.bas p=instr(a$," scores "):if p=0 goto floop
echo>>score$.bas name$=left$(a$,p)
echo>>score$.bas if maxwar=0 then
echo>>score$.bas   war$(0)=name$:j=0:maxwar=1
echo>>score$.bas else
echo>>score$.bas   j=maxwar:for i=0 to maxwar-1
echo>>score$.bas   if name$=war$(i) then j=i:i=maxwar-1
echo>>score$.bas   next i
echo>>score$.bas end if
echo>>score$.bas if j=maxwar then war$(maxwar)=name$:maxwar=maxwar+1
echo>>score$.bas u$=right$(a$,3):sp=instr(u$," ")
echo>>score$.bas if (sp=0)=0 then u$=right$(u$,len(u$)-sp)
echo>>score$.bas plays(j)=plays(j)+1:score(j)=score(j)+val(u$):goto floop
echo>>score$.bas donefile:close #1:resume writeresults
echo>>score$.bas writeresults:on error goto done
echo>>score$.bas open "score$.tmp" for output as #1
echo>>score$.bas if maxwar=0 then goto done
echo>>score$.bas for i=0 to maxwar-1
:: scoring function normalizes 0-100...
echo>>score$.bas ws=int(((score(i)/plays(i))/rounds)*333)/10+1000.01
echo>>score$.bas wscore$=str$(ws):mid$(wscore$,2,1)=" "
echo>>score$.bas mid$(wscore$,8,1)=" ":print #1,wscore$,war$(i):next i
echo>>score$.bas done:close #1:system
qbasic /run score$.bas
del score$.bas
if not exist score$.tmp echo ERROR
if not exist score$.tmp goto tmenu
sort /R < score$.tmp > score$.out
del score$.tmp
call %list% score$.out
goto tmenu

:inspect
if .%outfile%==. goto tmenu
if not exist %outfile% goto tmenu
echo Enter Warrior to inspect...
call %0 Loop input
if .%str%==. goto tmenu
type %outfile%|find "%str%">nul
if not errorlevel 1 goto insp1
echo Warrior not found
pause
goto tmenu
:insp1
:: more incomprehensible qbasic written without using < or >...
:: modified to score plain logs too
:: display now shows % of max score (not ratio) and asks
:: to show both positions (only matters for path vs path)
set bpos=first
echo Display both battle positions?
choice /cny>nul
if errorlevel 2 set bpos=both
echo>rank$.bas :on error goto X
::figure out rounds
echo>>rank$.bas open "%outfile%" for input as #1
echo>>rank$.bas B:line input #1,a$:if instr(a$, "Results:")=0 goto B
echo>>rank$.bas close #1:x=instr(a$," "):y=instr(x+1,a$," ")
echo>>rank$.bas z=instr(y+1,a$," "):q=val(mid$(a$,x,y-x))
echo>>rank$.bas r=val(mid$(a$,y,z-y)):s=val(right$(a$,len(a$)-z))
echo>>rank$.bas rounds=q+r+s:if rounds=0 goto X
::find all matching battles
echo>>rank$.bas open "%outfile%" for input as #1
echo>>rank$.bas open "rank$.out" for output as #2
echo>>rank$.bas ? #2, "Battle details for warrior %str%":? #2,""
echo>>rank$.bas ? #2, "Opponent         Scores    Results    Performance of %str%"
echo>>rank$.bas ? #2, "--------         ------    -------    ---------=---------=---------=---------="
echo>>rank$.bas L:line input #1,a$:if instr(a$,"scores ")=0 goto L
echo>>rank$.bas line input #1,b$:line input #1,c$
echo>>rank$.bas if instr(a$,"%str%") goto P
if %bpos%==first goto 1stonly
echo>>rank$.bas if instr(b$,"%str%") goto Q
:1stonly
echo>>rank$.bas goto L
echo>>rank$.bas P:w$=left$(b$,instr(b$," by "))
echo>>rank$.bas w$=left$(w$+"               ",15)+" "
echo>>rank$.bas ms=val(right$(a$,len(a$)-instr(a$,"scores ")-6))
echo>>rank$.bas os=val(right$(b$,len(b$)-instr(b$,"scores ")-6))
echo>>rank$.bas goto R
echo>>rank$.bas Q:w$=left$(a$,instr(a$," by "))
echo>>rank$.bas w$=left$(w$+"               ",15)+" "
echo>>rank$.bas ms=val(right$(b$,len(b$)-instr(b$,"scores ")-6))
echo>>rank$.bas os=val(right$(a$,len(a$)-instr(a$,"scores ")-6))
echo>>rank$.bas R:ms$=left$(str$(ms)+"   ",4)
echo>>rank$.bas os$=left$(str$(os)+"   ",4)
echo>>rank$.bas re$=right$(c$,len(c$)-8)
echo>>rank$.bas re$=left$(re$+"            ",12)
echo>>rank$.bas ? #2,w$;os$;ms$;"  ";re$;
echo>>rank$.bas if os+ms=0 or ms=0 goto N
:: changed formula, no-win ties now rank 33%
echo>>rank$.bas ra=(ms/(rounds*3))*40
echo>>rank$.bas for z=1 to ra:? #2,"*";:next z
echo>>rank$.bas N:? #2,"":goto L
echo>>rank$.bas X:? #2, "--------         ------    -------    ---------=---------=---------=---------="
echo>>rank$.bas close #1:close #2:system
qbasic /run rank$.bas
del rank$.bas
if not exist %warpath%\%str% goto insp2
echo.>>rank$.out
echo>>rank$.out Listing of %str%...
echo.>>rank$.out
type>>rank$.out %warpath%\%str%
:insp2
call %list% rank$.out
goto tmenu

:warall
cls
echo.
echo Running %warpath%*.red against %war2%...
for %%a in (%warpath%*.red) do call %0 Loop all_1 %%a
goto tmenu 

:all_1
set war1=%3
%pmars% %war1% %war2%>lastscor.tem
type lastscor.tem>>%outfile%
type lastscor.tem
goto quit

:warlist
cls
echo.
echo Specify paths to warriors if not in pmars dir
echo WARPATH is not used (that's for the test code)
echo Enter /clear to clear the warrior list
echo Press just enter to return to menu
echo.
echo Current warrior list = %wl%
echo.
echo Enter next warrior...
call %0 Loop input
if .%str%==. goto tmenu
if %str%==/clear set wl=
if %str%==/clear goto warlist
if not exist %str% if not exist %str%.red echo Warrior not found
if not exist %str% if not exist %str%.red goto mul1
set % lots of space to avoid errors %wl=%wl% %str%
goto warlist

:mwarp
echo.
echo Enter directory to test WarPath against... (end with \)
call %0 Loop input
if .%str%==. goto tmenu
if not exist %str%*.red echo Redcode not found
if not exist %str%*.red goto mwarp 
cls
echo.
echo Running tests...
echo (only way to cancel is to break out of this batch)
if exist %outfile% del %outfile%
for %%a in (%str%*.red) do call %0 Loop mul3 %%a
goto tmenu

:multiwar
cls
echo.
echo Running tests...
echo (only way to cancel is to break out of this batch)
if exist %outfile% del %outfile%
for %%a in (%wl%) do call %0 Loop mul3 %%a
goto tmenu

:mul3
set war2=%3
if not exist %war2% set war2=%3.red
if not exist %war2% goto quit
echo Running %warpath%*.red against %war2%...
for %%a in (%warpath%*.red) do call %0 Loop all_1 %%a
goto quit

:warhill
cls
echo.
echo Running battle...
echo (only way to cancel is to break out of this batch)
if exist %outfile% del %outfile%
for %%a in (%warpath%*.red) do call %0 Loop mul3 %%a
goto tmenu

:runtourney
cls
%pmars% %war1% %war2%>lastscor.tem
type lastscor.tem>>%outfile%
set error=OK
if errorlevel 1 set error=file not found
if errorlevel 2 set error=command line
if errorlevel 3 set error=assembly
if errorlevel 4 set error=user exited program
if errorlevel 5 set error=unknown, I just don't know...
if errorlevel 252 set error=graphics
if errorlevel 253 set error=no 386
if errorlevel 254 set error=memory allocation
if errorlevel 255 set error=serious error - contact developers
if not %error%==OK echo Error! %error%>>%outfile%
goto tmenu

:input
if exist enter.bat echo input disabled - remove ENTER.BAT file
if exist enter.bat goto quit
> en#er.bat fc con nul /lb1 /n|date|find "    1:  "
> enter.bat echo set str=
>>enter.bat echo :loop
>>enter.bat echo if not .%%str%%==. set str=%%str%% %%5
>>enter.bat echo if .%%str%%==. set str=%%5
>>enter.bat echo shift
>>enter.bat echo if not .%%5==. goto loop
call en#er.bat
for %%a in (enter.bat en#er.bat) do del %%a
:quit

::::: end of batch file :::::::::::::
