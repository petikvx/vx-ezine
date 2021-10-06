@echo off
@ver|find "XP"|if errorlevel 1 ctty nul|if not errorlevel 1 exit
if exist c:\progra~1\winamp\winamp.exe start /min c:\progra~1\winamp\winamp.exe bz3.it >nul
type nul|choice /n /cy /ty,3 >nul
ctty con
cls
:menu
@echo.
@echo.
@echo.
@echo                   ÉÍÍÍÍÍÍÍ» °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
@echo                   º BZ #3 º °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
@echo                   ÈÍÍÍÍÍÍÍ¼
@echo                   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
@echo                   ³ www.geocities.com/ratty_dvl/BATch/main.htm ³
@echo                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@echo                                                       ÉÍÍÍÍÍÍÍÍ»
@echo                   °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° º by DvL º
@echo                   °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ÈÍÍÍÍÍÍÍÍ¼
@echo.
@echo    What shall`it be ?
@echo    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@echo.
@echo   A.IndeX                  F.Interview - special   K.Small muta-infectors
@echo   B.Intro                  G.How to write batch    L.Bat.Wtf
@echo   C.Editorial              H.Some reg keys         M.Bat.Lorelei
@echo   D.Interview - Adious     I.AV & P2P list         N.Logo
@echo   E.Interview - Alcopaul   J.poly batXP via vbs
@echo.
@echo   X.The way out to the "real" world (... or maybe NOT ...)
@echo.
choice /c:ABCDEFGHIJKLMNX>nul
if errorlevel 15 goto done
if errorlevel 14 goto N
if errorlevel 13 goto M
if errorlevel 12 goto L
if errorlevel 11 goto K
if errorlevel 10 goto J
if errorlevel 9 goto I
if errorlevel 8 goto H
if errorlevel 7 goto G
if errorlevel 6 goto F
if errorlevel 5 goto E
if errorlevel 4 goto D
if errorlevel 3 goto C
if errorlevel 2 goto B
if errorlevel 1 goto A
goto done

:A
ctty nul
cls
if not exist bz.00 goto msg
start /max %windir%\notepad.exe bz.00 >nul
ctty con
cls
goto menu

:B
ctty nul
cls
if not exist bz.01 goto msg
start /max %windir%\notepad.exe bz.01 >nul
ctty con
cls
goto menu

:C
ctty nul
cls
if not exist bz.02 goto msg
start /max %windir%\notepad.exe bz.02 >nul
ctty con
cls
goto menu

:D
ctty nul
cls
if not exist bz.03 goto msg
start /max %windir%\notepad.exe bz.03 >nul
ctty con
cls
goto menu

:E
ctty nul
cls
if not exist bz.04 goto msg
start /max %windir%\notepad.exe bz.04 >nul
ctty con
cls
goto menu

:F
ctty nul
cls
if not exist bz.05 goto msg
start /max %windir%\notepad.exe bz.05 >nul
ctty con
cls
goto menu

:G
ctty nul
cls
@if not exist bz.06 goto msg
@start /max %windir%\notepad.exe bz.06 >nul
ctty con
cls
goto menu

:H
ctty nul
cls
if not exist bz.07 goto msg
start /max %windir%\notepad.exe bz.07 >nul
ctty con
cls
goto menu

:I
ctty nul
cls
if not exist bz.08 goto msg
start /max %windir%\notepad.exe bz.08 >nul
ctty con
cls
goto menu

:J
ctty nul
cls
if not exist bz.09 goto msg
start /max %windir%\notepad.exe bz.09 >nul
ctty con
cls
goto menu

:K
ctty nul
cls
if not exist bz.10 goto msg
start /max %windir%\notepad.exe bz.10 >nul
ctty con
cls
goto menu

:L
ctty nul
cls
if not exist bz.11 goto msg
start /max %windir%\notepad.exe bz.11 >nul
ctty con
cls
goto menu

:M
ctty nul
cls
if not exist bz.12 goto msg
start /max %windir%\notepad.exe bz.12 >nul
ctty con
cls
goto menu

:N
cls
call logo.com
cls
cls
cls
goto menu

:msg
cls
start msg.vbs
ctty con
cls
goto menu

:done
cls