if #%1==#sub goto %2
:ix2
echo [11;30HWorking on cell %1-%2...  [22H
set count=
for %%c in (1 2 3 4 5 6 7 8) do call %0 sub cnt%%c %1 %2
if not exist cells\%1-%2 goto chk3
if #%count%==#... goto sur3
if #%count%==#.. goto sur2
echo [12;30H(%1-%2 died)        [22H
del newcells\%1-%2
echo [%1;%2H%dc%%s%%tc%[22H
goto lastline
:chk3
if not #%count%==#... goto lastline
echo [12;30H(%1-%2 born)        [22H
echo.>newcells\%1-%2
echo [%1;%2H%bc%%tc%[22H
goto lastline
:sur2
echo [12;30H(%1-%2 lives by 2)  [22H
echo [%1;%2H%s2c%%tc%[22H
goto lastline
:sur3
echo [12;30H(%1-%2 lives by 3)  [22H
echo [%1;%2H%s3c%%tc%[22H
goto lastline
:cnt1
call minus %3
set y=%out%
call minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt2
set y=%3
call minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt3
call plus %3
set y=%out%
call minus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt4
call minus %3
set y=%out%
set x=%4
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt5
call plus %3
set y=%out%
set x=%4
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt6
call minus %3
set y=%out%
call plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt7
set y=%3
call plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
goto lastline
:cnt8
call plus %3
set y=%out%
call plus %4
set x=%out%
if exist cells\%y%-%x% set count=%count%.
:lastline
