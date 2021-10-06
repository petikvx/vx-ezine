:: Conway's Game of Life (in batch!)
:: For DOS 6 with ANSI console driver
:: Uses SUB0.BAT SUB1.BAT PLUS.BAT MINUS.BAT
:: Written by Terry Newton  April 26, 1996
@echo off
if #%1==#sub goto %2
if #%comspec%==# set comspec=command
%comspec% /e:3000 /c %0 sub shell
if exist life$ del life$
if exist running %0
if exist newcells\nul deltree /y newcells>nul
goto lastline
:shell
:: (::) next 3 lines if your driver isn't named "ANSI"
mem /c|find "ANSI">nul
if errorlevel 1 echo This batch requires an ANSI driver
if errorlevel 1 goto lastline
set gen=I
set xgen=
if exist gencnt.bat call gencnt
::char for cell...
set c=O
::char for space...
set s= % %
::color codes...
::(text,dead,survive2,survive3,birth,cursor)
set tc=[0m
set dc=[1;37;44m
set s2c=[1;36;44m%c%
set s3c=[1;32;44m%c%
set bc=[1;33;44m%c%
set cc=[1;37;43m
if not exist cells\nul md cells
set keys=123Q
if exist cells\*. set keys=123Q4
echo %tc%
cls
echo.>running
echo. 
echo  Conway's Game of Life
echo  The Snail Version!
echo.
echo  Select...
echo.
echo   1) Random Start
echo   2) Edit Cells
if exist cells\*. echo   3) Remove All Cells
if exist cells\*. echo   4) Continue Growing
echo   Q) Quit
echo.
choice /c:%keys%>nul
if errorlevel 5 goto generate
if errorlevel 4 goto quit
if exist gencnt.bat del gencnt.bat
set gen=I
set xgen=
if errorlevel 3 goto clearcells
if errorlevel 2 goto editcells
if errorlevel 1 goto randomstart
echo  Sorry, this batch requires DOS 6
goto lastline
:quit
del running
exit
:clearcells
del cells\*.
goto shell
:randomstart
echo %tc%
cls
echo.
echo  Creating Random Cell Pattern...
echo  Press Ctrl-C for menu
if exist cells\*. del cells\*.
for %%a in (9 10 11 12) do call %0 sub iy %%a
goto generate
:iy
if %3==11 echo  Halfway done...
for %%b in (5 6 7 8 9 10 11 12 13 14 15 16) do call %0 sub ix %3 %%b
goto lastline
:ix
echo.|time>life$
set cell=off
find ".1"<life$>nul
if not errorlevel 1 set cell=on
find ".3"<life$>nul
if not errorlevel 1 set cell=on
find ".5"<life$>nul
if not errorlevel 1 set cell=on
find ".8"<life$>nul
if not errorlevel 1 set cell=on
del life$
if %cell%==off goto lastline
echo.>cells\%3-%4
goto lastline
:editcells
echo %tc%
cls
set next=lastline
call sub0 sub display
:edit1
echo [7;30HUse keypad arrows to move
echo [8;30HPress + to add a cell
echo [9;30HPress - to remove a cell
echo [11;30HPress G to generate cells
echo [17;30HPress Ctrl-C for menu
set x=9
set y=9
:editloop
echo [%y%;%x%H%cc%%s%[22H
if exist cells\%y%-%x% echo [%y%;%x%H%cc%%c%[22H
choice /c:4862+-g>nul
echo [%y%;%x%H%dc%%s%[22H
if exist cells\%y%-%x% echo [%y%;%x%H%dc%%c%[22H
if errorlevel 7 goto gen1
if errorlevel 6 goto turnoff
if errorlevel 5 goto turnon
if errorlevel 4 goto move-s
if errorlevel 3 goto move-e
if errorlevel 2 goto move-n
call minus %x%
set x=%out%
goto editloop
:move-n
call minus %y%
set y=%out%
goto editloop
:move-e
call plus %x%
set x=%out%
goto editloop
:move-s
call plus %y%
set y=%out%
goto editloop
:turnoff
if exist cells\%y%-%x% del cells\%y%-%x%
goto editloop
:turnon
echo.>cells\%y%-%x%
goto editloop
:generate
sub0 sub generate
:gen1
sub0 sub gen1 
:lastline
