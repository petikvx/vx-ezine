@echo off

set masm=x:\masm\
set tasm=x:\tasm\
set tp=x:\tp\bin\

if not exist %tasm%tasm.exe goto error
if not exist %tasm%tlink.exe goto error
if not exist %masm%ml.exe goto error
if not exist %tp%tpc.exe goto error

:success
echo - success
goto done
:error
echo.
echo you must write correct paths in the file SET_PATH.BAT
echo.
:done
