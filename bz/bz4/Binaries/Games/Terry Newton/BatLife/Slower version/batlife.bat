:: Conway's Game of Life (in batch!)
:: Requires DOS 6 with ANSI console driver
:: Written by Terry Newton  April 24, 1996
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
::char for cell...
set c=O
::char for space...
set s= % %
::color codes... (text,dead,survive,birth,cursor)
set tc=[0m
set dc=[1;37;44m
set sc=[1;36;44m%c%
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
cls.
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
set next=edit1
goto display
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
call %0 sub minus %x%
set x=%out%
goto editloop
:move-n
call %0 sub minus %y%
set y=%out%
goto editloop
:move-e
call %0 sub plus %x%
set x=%out%
goto editloop
:move-s
call %0 sub plus %y%
set y=%out%
goto editloop
:turnoff
if exist cells\%y%-%x% del cells\%y%-%x%
goto editloop
:turnon
echo.>cells\%y%-%x%
goto editloop
:generate
echo %tc%
cls
set next=gen1
:display
echo [2;1H ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
for %%a in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call %0 sub iy1 %%a
echo  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
goto %next%
:emptyline
echo  ³%dc%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%s%%tc%³
goto lastline
:iy1
if not exist cells\%3-* goto emptyline
set line=
for %%b in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call %0 sub ix1 %3 %%b
echo  ³%dc%%line%%tc%³
goto lastline
:ix1
if exist cells\%3-%4 set line=%line%%c%
if not exist cells\%3-%4 set line=%line%%s%
goto lastline
:gen1
echo %tc%[7;30H[KConway's Game of Life
echo [8;30H[KThe Snail Version!
echo [9;30H[K
echo [11;30H[K
echo [17;30H[KPress Ctrl-C for menu
if not exist newcells\nul md newcells
if exist newcells\*. del newcells\*.
if exist cells\*. copy cells\*. newcells>nul
:loop1
echo [21;3HGeneration %gen%
for %%a in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call %0 sub iy2 %%a
if exist cells\*. del cells\*.
if exist newcells\*. copy newcells\*. cells>nul
set gen=%gen%I
goto loop1
:iy2
if exist cells\%3-* goto reallydoit
call %0 sub minus %3
if exist cells\%out%-* goto reallydoit
call %0 sub plus %3
if not exist cells\%out%-* goto lastline
:reallydoit
for %%b in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call %0 sub ix2 %3 %%b
goto lastline
:ix2
echo [11;30HWorking on cell %3-%4...  [22H
set count=
for %%c in (1 2 3 4 5 6 7 8) do call %0 sub cnt%%c %3 %4
if not exist cells\%3-%4 goto chk3
if #%count%==#... goto survived
if #%count%==#.. goto survived
echo [12;30H(%3-%4 died)      [22H
del newcells\%3-%4
echo [%3;%4H%dc%%s%%tc%[22H
goto lastline
:chk3
if not #%count%==#... goto lastline
echo [12;30H(%3-%4 born)      [22H
echo.>newcells\%3-%4
echo [%3;%4H%bc%%tc%[22H
goto lastline
:survived
echo [12;30H(%3-%4 survived)[22H
echo [%3;%4H%sc%%tc%[22H
goto lastline
:cnt1
call %0 sub minus %3
set y=%out%
call %0 sub minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt2
set y=%3
call %0 sub minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt3
call %0 sub plus %3
set y=%out%
call %0 sub minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt4
call %0 sub minus %3
set y=%out%
set x=%4
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt5
call %0 sub plus %3
set y=%out%
set x=%4
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt6
call %0 sub minus %3
set y=%out%
call %0 sub plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt7
set y=%3
call %0 sub plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt8
call %0 sub plus %3
set y=%out%
call %0 sub plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:minus
if %3==3 set out=18
if %3==4 set out=3
if %3==5 set out=4
if %3==6 set out=5
if %3==7 set out=6
if %3==8 set out=7
if %3==9 set out=8
if %3==10 set out=9
if %3==11 set out=10
if %3==12 set out=11
if %3==13 set out=12
if %3==14 set out=13
if %3==15 set out=14
if %3==16 set out=15
if %3==17 set out=16
if %3==18 set out=17
goto lastline
:plus
if %3==3 set out=4
if %3==4 set out=5
if %3==5 set out=6
if %3==6 set out=7
if %3==7 set out=8
if %3==8 set out=9
if %3==9 set out=10
if %3==10 set out=11
if %3==11 set out=12
if %3==12 set out=13
if %3==13 set out=14
if %3==14 set out=15
if %3==15 set out=16
if %3==16 set out=17
if %3==17 set out=18
if %3==18 set out=3
:lastline
