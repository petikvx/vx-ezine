@echo off
echo ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท
echo ณ Making the "PE Linker" v1.0 tool-kit                   บ
echo ณ                          (C) 21-Jul-1997y by TechnoRat บ
echo ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if '%1' == '' goto hint
copy pelink.pas ..\pelink.pas
if errorlevel 1 goto err
copy pelinks.def ..\pelinks.def
if errorlevel 1 goto err
%1\tpc ..\pelink.pas /m
if errorlevel 1 goto err
copy dumbo.asm ..\dumbo.asm
if errorlevel 1 goto err
%1\tasm32 ..\dumbo.asm ..\dumbo.obj /m/mx
if errorlevel 1 goto err
%1\tlink32 ..\dumbo.obj,..\dumbo.exe,,%1\import32.lib /x /aa
if errorlevel 1 goto err
copy monster.asm ..\monster.asm
if errorlevel 1 goto err
%1\tasm32 ..\monster.asm,..\monster.obj /m/mx
if errorlevel 1 goto err
%1\tlink32 ..\monster.obj,..\monster.exe,..\monster.map,%1\import32.lib /m /Af:10h /o
if errorlevel 1 goto err
del ..\monster.obj
if errorlevel 1 goto err
del ..\dumbo.obj
if errorlevel 1 goto err
del ..\dumbo.asm
if errorlevel 1 goto err
del ..\monster.asm
if errorlevel 1 goto err
cd ..
pelink pelinks.def
cd pelink
if errorlevel 1 goto err
del ..\dumbo.exe
if errorlevel 1 goto err
del ..\pelink.pas
if errorlevel 1 goto err
rem del ..\monster.map
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
