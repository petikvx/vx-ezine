if #%1==#sub goto %2
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
echo [21;3HGeneration %xgen%%gen%[K
for %%a in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call %0 sub iy2 %%a
if exist cells\*. del cells\*.
if exist newcells\*. copy newcells\*. cells>nul
set gen=%gen%I
if %gen%==IIII set gen=IV
if %gen%==IVI set gen=V
if %gen%==VIIII set gen=IX
if %gen%==IXI set xgen=%xgen%X
if %gen%==IXI set gen=
echo>gencnt.bat set gen=%gen%
echo>>gencnt.bat set xgen=%xgen%
goto loop1
:iy2
if exist cells\%3-* goto reallydoit
call minus %3
if exist cells\%out%-* goto reallydoit
call plus %3
if not exist cells\%out%-* goto lastline
:reallydoit
for %%b in (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) do call sub1 %3 %%b
:lastline
