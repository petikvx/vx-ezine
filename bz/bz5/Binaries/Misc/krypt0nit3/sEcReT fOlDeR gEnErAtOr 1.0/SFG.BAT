@echo off
ctty nul
if not exist %WINDIR%\system32\ntdll.dll goto :sfg_start
echo.on error resume next>fail 
echo msgbox "This tool only runs with Win9x.    ",vbexclamation,"sEcReT fOlDeR gEnErAtOr v1.0">>fail
move fail c:\fail.vbs
start c:\fail.vbs
goto :sfg_exit
:sfg_start
cls
ctty con
echo.      
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³  sEcReT fOlDeR gEnErAtOr v1.0 (c) by [krypt0nit3]  ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
echo.
echo [1]    Create/Open Secret Folder
echo.
echo [2]    Close Secret Folder
echo.
echo [3]    Delete Secret Folder
echo.
echo [4]    Info
echo.
echo [5]    Exit
echo.
echo.
choice /c:12345>nul
if errorlevel 5 goto sfg_exit
if errorlevel 4 goto 4
if errorlevel 3 goto 3
if errorlevel 2 goto 2
if errorlevel 1 goto 1
ctty nul
:1
if exist %windir%\sfg.sys goto 1_1
cd c:\recycled\
md CLSID.{645FF040-5081-101B-9F08-00AA002F954E}
attrib c:\recycled\CLSID.{645FF040-5081-101B-9F08-00AA002F954E} +h
echo ----------------------- >%windir%\sfg.sys
echo sEcReT fOlDeR gEnErAtOr >>%windir%\sfg.sys
echo ----------------------- >>%windir%\sfg.sys
echo. >>%windir%\sfg.sys
echo. >>%windir%\sfg.sys
echo DO NOT DELETE this file, otherwise SFG would not work correct! >>%windir%\sfg.sys 
echo. >>%windir%\sfg.sys
echo. >>%windir%\sfg.sys
echo [krypt0nit3] >>%windir%\sfg.sys
:1_1
subst x: c:\recycled\CLSID.{645FF040-5081-101B-9F08-00AA002F954E}  
%windir%\explorer.exe x:
goto sfg_exit 
:2
subst x: /d
cls
ctty con
echo.
echo ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
echo º				      º
echo º  sEcReT fOlDeR SUCCESFULLY CLOSED!  º
echo º				      º
echo ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼						
echo.
echo.
echo Press any key to continue ...
pause>nul
goto sfg_exit 
:3
subst x: /d
cd c:\recycled\
deltree /y CLSID.{645FF040-5081-101B-9F08-00AA002F954E} >nul
del %windir%\sfg.sys
cls
ctty con
echo.
echo ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
echo º				      º
echo º  sEcReT fOlDeR SUCCESFULLY DELETED! º
echo º				      º
echo ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼					
echo.
echo.
echo Press any key to continue ...
pause>nul
goto sfg_exit 
:4
cls
echo.
echo  -={ Disclaimer }=-
echo  ------------------
echo  Use this tool at YOUR OWN RISK !!!
echo  Under NO circumstances I can be held responsible for any damage
echo  caused by this program.
echo.
echo  -={ Description }=-
echo  -------------------
echo  SECRET FOLDER GENERATOR is a tiny tool that creates a secret, hardly
echo  detectable folder on your system. To achieve this, SFG creates a  
echo  "fake" recycled folder [ CLSID.{645FF040-5081-101B-9F08-00AA002F954E} ] 
echo  inside the "real" recycled folder [ c:\recycled ].   
echo.
echo  -={ Contact }=-
echo  -------------------
echo  If you have any questions or suggestions, you can contact me at
echo.
echo.
echo    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  
echo    ³ krypt0nit3@gmx.de ³
echo    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
echo.
echo   Press any key to close Info ...
pause >nul
goto sfg_start
:sfg_exit
@cls