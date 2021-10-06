:: TESTRC testdir dir [dir] ...
:: Tests testdir against all dirs in separated mode
:: copies data and score to each tested dir
:: dir1 ONLY battles dir2 for testing lots of bad redcode
@echo off
if [%1]==[GoTo] goto %2
if [%2]==[] echo no directory specified
if [%2]==[] usage: TESTRC testdir dir [dir] ...
if [%2]==[] goto last

:: set to name of this batch
set batname=TESTRC.BAT

:: set this to the location of the PMARS directory, end with \
:: (unless pmars files are in current dir, then set to blank)
set pmarsdir=d:\cwar\pmars08

:: set this to name of logfile
set out=battle.out

:: set this to name of scorefile
set score=score.out

:: set this to number of rounds per battle
set rounds=25

:: set this to pmars command line options
set options=-b -r %rounds% -l 500

:: set up path and test dir
if not exist %tmp%\nul set tmp=.
set oldpath=%path%
path %pmarsdir%;%path%

:: call with all dirs to test first dir against
set dir1=%1
:call_loop
if .%2==. goto end
call %batname% GoTo testred %2
shift
goto call_loop

:: clear variables and end
:end
path %oldpath%
set oldpath=
set batname=
set pmarsdir=
set out=
set score=
set rounds=
set options=
set dir1=
set dir2=
set war1=
set war2=
goto last

::----------------------------------
:testred
set dir2=%3
echo **** Battling %dir1% and %dir2%
if exist %out% del %out%
for %%a in (%dir1%\*.red) do call %0 GoTo Loop1 %%a
if exist %tmp%\tempscor.$ del %tmp%\tempscor.$
goto scoreit

:Loop1
set war1=%3
for %%b in (%dir2%\*.red) do call %0 GoTo Loop2 %%b
goto last

:Loop2
set war2=%3
>%tmp%\tempscor.$ PMARS %options% %war1% %war2%
type %tmp%\tempscor.$
type %tmp%\tempscor.$>>%out%
goto last

:scoreit
:: process out file to produce score file (code from MARS.BAT)
if not exist %out% echo nothing to score, sorry
if not exist %out% goto last
echo.
echo Computing Scores....
:: preprocess the outfile
type %out%|find " scores ">score$.tmp
:: make temp qbasic program...
echo> score$.bas :on error goto donefile
echo>>score$.bas rounds=val("%rounds%"):if rounds=0 goto done
echo>>score$.bas dim war$(500),score(500),plays(500):maxwar=0
echo>>score$.bas for i=1 to 500:war$(i)="":score(i)=0:plays(i)=0:next i
echo>>score$.bas open "score$.tmp" for input as #1
echo>>score$.bas floop:line input #1,a$:a$=ltrim$(rtrim$(a$))
echo>>score$.bas name$=left$(a$,instr(a$," scores "))
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
sort /R < score$.tmp > %score%
del score$.tmp

:: move log and score to tested dir
move %out% %dir2% >nul
move %score% %dir2% >nul

:last
