@echo off
echo ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท
echo ณ Making the "Include Support" v1.0 tool-kit             บ
echo ณ                          (C) 04-Sep-1997y by TechnoRat บ
echo ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if '%1' == '' goto hint
copy harrlogo.bmp ..\harrlogo.bmp
if errorlevel 1 goto err
copy harrinfo.ini ..\harrinfo.ini
if errorlevel 1 goto err
copy deffile.pas ..\deffile.pas
if errorlevel 1 goto err
copy incfile.pas ..\incfile.pas
if errorlevel 1 goto err
%1\tpc ..\deffile.pas /m
if errorlevel 1 goto err
%1\tpc ..\incfile.pas /m
if errorlevel 1 goto err
del ..\incfile.pas
if errorlevel 1 goto err
del ..\deffile.pas
if errorlevel 1 goto err
echo ; Parameters for including OEM ;-) files >..\harrinc.inc
..\deffile HarrBtMpFile ..\harrlogo.bmp >>..\harrinc.inc
if errorlevel 1 goto err
..\deffile HarrInfoFile ..\harrinfo.ini >>..\harrinc.inc
if errorlevel 1 goto err
del ..\deffile.exe
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
