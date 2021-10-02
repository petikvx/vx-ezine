@echo off
echo ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท
echo ณ Making the "ASM Swapper" v1.3 tool-kit                 บ
echo ณ                          (C) 14-Aug-1997y by TechnoRat บ
echo ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if '%1' == '' goto hint
copy asmswap.pas ..\asmswap.pas
if errorlevel 1 goto err
%1\tpc ..\asmswap.pas /m
if errorlevel 1 goto err
del ..\asmswap.pas
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
