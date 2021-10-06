@echo off
@ctty nul
if [%1]==[] %0 20 0E
if [%2]==[] %0 %1 0E
set a=FB800:0L1F40 %1 %2
:loop
if not [%4]==[] for %%c in (set shift shift goto:loop) do %%c a=%a% %3 %4
echo.%a%>b
for %%c in (echo.q set) do %%c a=>>b
debug<b>nul
deltree/y b>nul
if exist c:\progra~1\winamp\winamp.exe start /min c:\progra~1\winamp\winamp.exe game.s3m>nul
type nul|choice /n /cy /ty,1>nul
ctty con

:eng
@echo.
@echo.
@echo                          °±²Û BATCH ZONE IIII Û²±°
@echo.
@echo                        www.geocities.com/batch_zone
@echo.
@echo     A.IndeX
@echo     B.Editorial
@echo     C.Enter-View with Zed
@echo     D.Enter-View with Kefi
@echo     E.The run batch run book
@echo     F.Polymorphic batch tutorial
@echo     G.Microsoft's undocumented features Vol.1 Nr.7
@echo     H.Difference between executing batch files in MS-DOS prompt and in ...
@echo     I.Polymorphism in BatXP
@echo     J.WinInit.ini file removal
@echo     K.Defeating Kaspersky antivirus
@echo     L.Out of environment space error message in MS-DOS programs
@echo     M.BatXP.Limitrophe.d
@echo     N.Collection of undocumented and obscure features in various MS-DOS ...
@echo     O.Conway's game of life
@echo     P.Creating quasi-random numbers using the system clock
@echo     Q.New IRC spreading
@echo.
@echo     X.e X i t
@choice /c:abcdefghijklmnopqx>nul
@if errorlevel 18 goto done
@if errorlevel 17 goto qeng
@if errorlevel 16 goto peng
@if errorlevel 15 goto oeng
@if errorlevel 14 goto neng
@if errorlevel 13 goto meng
@if errorlevel 12 goto leng
@if errorlevel 11 goto keng
@if errorlevel 10 goto jeng
@if errorlevel 9 goto ieng
@if errorlevel 8 goto heng
@if errorlevel 7 goto geng
@if errorlevel 6 goto feng
@if errorlevel 5 goto eeng
@if errorlevel 4 goto deng
@if errorlevel 3 goto ceng
@if errorlevel 2 goto beng
@if errorlevel 1 goto aeng

:aeng
@ctty nul
if not exist bz.00 goto msg
start /max %windir%\notepad.exe bz.00>nul
ctty con
goto eng

:beng
@ctty nul
if not exist bz.01 goto msg
start /max %windir%\notepad.exe bz.01>nul
ctty con
goto eng

:ceng
@ctty nul
if not exist bz.02 goto msg
start /max %windir%\notepad.exe bz.02>nul
ctty con
goto eng

:deng
@ctty nul
if not exist bz.03 goto msg
start /max %windir%\notepad.exe bz.03>nul
ctty con
goto eng

:eeng
@ctty nul
if not exist bz.04 goto msg
start /max c:\progra~1\access~1\wordpad.exe bz.04>nul
ctty con
goto eng

:feng
@ctty nul
if not exist bz.05 goto msg
start /max %windir%\notepad.exe bz.05>nul
ctty con
goto eng

:geng
@ctty nul
if not exist bz.06 goto msg
start /max c:\progra~1\access~1\wordpad.exe bz.06>nul
ctty con
goto eng

:heng
@ctty nul
if not exist bz.07 goto msg
start /max %windir%\notepad.exe bz.07>nul
ctty con
goto eng

:ieng
@ctty nul
if not exist bz.08 goto msg
start /max %windir%\notepad.exe bz.08>nul
ctty con
goto eng

:jeng
@ctty nul
if not exist bz.09 goto msg
start /max %windir%\notepad.exe bz.09>nul
ctty con
goto eng

:keng
@ctty nul
if not exist bz.10 goto msg
start /max %windir%\notepad.exe bz.10>nul
ctty con
goto eng

:leng
@ctty nul
if not exist bz.11 goto msg
start /max %windir%\notepad.exe bz.11>nul
ctty con
goto eng

:meng
@ctty nul
if not exist bz.12 goto msg
start /max %windir%\notepad.exe bz.12>nul
ctty con
goto eng

:neng
@ctty nul
if not exist bz.13 goto msg
start /max %windir%\notepad.exe bz.13>nul
ctty con
goto eng

:oeng
@ctty nul
if not exist bz.14 goto msg
start /max %windir%\notepad.exe bz.14>nul
ctty con
goto eng

:peng
@ctty nul
if not exist bz.15 goto msg
start /max %windir%\notepad.exe bz.15>nul
ctty con
goto eng

:qeng
@ctty nul
if not exist bz.16 goto msgeng
start /max %windir%\notepad.exe bz.16>nul
ctty con
goto eng

:msgeng
start msgeng.vbs
ctty con
goto eng

:done
cls