@echo off
echo ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท
echo ณ Making the "95-th Harrier from DarkLand" v2.01         บ
echo ณ                          (C) 13-Sep-1997y by TechnoRat บ
echo ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if '%1' == '' goto hint
copy 95inst.asm ..\*.*
if errorlevel 1 goto err
copy 95inf.asm ..\*.*
if errorlevel 1 goto err
%1\tasm32 ..\95inst.asm ..\95inst.obj /m/mx
if errorlevel 1 goto err
%1\tlink32 ..\95inst.obj,..\95inst.exe,,%1\import32.lib /x
if errorlevel 1 goto err
..\asmswap /data ..\95inf.asm ..\95inf.$$$
if errorlevel 1 goto err
..\asmswap prefix ..\95inf.$$$ ..\95inf.asm
if errorlevel 1 goto err
%1\tasm32 ..\95inf.asm ..\95inf.obj /m/mx
if errorlevel 1 goto err
%1\tlink32 ..\95inf.obj,..\95inf.exe,..\95inf.map,%1\import32.lib /m /Af:10h /o
if errorlevel 1 goto err
del ..\95inf.asm
if errorlevel 1 goto err
del ..\95inf.$$$
if errorlevel 1 goto err
del ..\95inst.asm
if errorlevel 1 goto err
del ..\95inf.obj
if errorlevel 1 goto err
del ..\95inst.obj
if errorlevel 1 goto err
..\incfile ..\harrlogo.bmp ..\95inf.exe
if errorlevel 1 goto err
..\incfile ..\harrinfo.ini ..\95inf.exe
if errorlevel 1 goto err
cd ..
pelink 95th\95inf.def
cd 95th
if errorlevel 1 goto err
if exist ..\wh95_r00.exe del ..\wh95_r00.exe
if errorlevel 1 goto err
ren ..\95inst.exe wh95_r00.exe
if errorlevel 1 goto err
del ..\95inf.map
if errorlevel 1 goto err
del ..\95inf.exe
if errorlevel 1 goto err
echo ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท
echo ณ                     Completed OK!                      บ
echo ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
goto ok

:err
echo Errors detected!!!
goto ok

:hint
echo USAGE: MAKE.BAT Path_To_Used_Tools
goto ok
:ok
