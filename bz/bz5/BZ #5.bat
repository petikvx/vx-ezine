@echo off
echo.FB800:0L1F40 20 0E>%tmp%\b
echo.q>>%tmp%\b
debug<%tmp%\b>nul
deltree/y %tmp%\b>nul
if exist c:\progra~1\winamp\winamp.exe start /min c:\progra~1\winamp\winamp.exe elev8.xm>nul
ctty con

:menu
@echo.
@echo.
@echo                          °±²Û Batch Zone # 5 Û²±°
@echo.
@echo.
@echo     A.Editorial
@echo     B.Enter-View with SlageHammer
@echo     C.Enter-View with SevenC (7C)
@echo     D.Enter-View with Retro [rRLF]
@echo     E.Enter-View with DiA
@echo     F.Enter-View with me by PC-Magazine
@echo     G.Past, present and future of batch
@echo     H.Bat.Fuck: explained
@echo     I.BatXP.Nihilist: 1st EPO batch virus
@echo     J.Tutorial about how to know if you have batch or trojan
@echo     K.The power of Pc/Ms-Dos batch files
@echo     L.The hidden strengths of the dos batch language
@echo     M.Virus batch
@echo     N.Intermediate batch tutorial
@echo.
@echo     X.Exit
@echo.
@choice /c:abcdefghijklmnx>nul
@if errorlevel 15 goto done
@if errorlevel 14 goto n
@if errorlevel 13 goto m
@if errorlevel 12 goto l
@if errorlevel 11 goto k
@if errorlevel 10 goto j
@if errorlevel 9 goto i
@if errorlevel 8 goto h
@if errorlevel 7 goto g
@if errorlevel 6 goto f
@if errorlevel 5 goto e
@if errorlevel 4 goto d
@if errorlevel 3 goto c
@if errorlevel 2 goto b
@if errorlevel 1 goto a

:a
@ctty nul
if not exist bz.01 goto msg
start /max %windir%\notepad.exe bz.01>nul
ctty con
goto menu

:b
@ctty nul
if not exist bz.02 goto msg
start /max %windir%\notepad.exe bz.02>nul
ctty con
goto menu

:c
@ctty nul
if not exist bz.03 goto msg
start /max %windir%\notepad.exe bz.03>nul
ctty con
goto menu

:d
@ctty nul
if not exist bz.04 goto msg
start /max %windir%\notepad.exe bz.04>nul
ctty con
goto menu

:e
@ctty nul
if not exist bz.05 goto msg
start /max %windir%\notepad.exe bz.05>nul
ctty con
goto menu

:f
@ctty nul
if not exist bz.06 goto msg
start /max %windir%\notepad.exe bz.06>nul
ctty con
goto menu

:g
@ctty nul
if not exist bz.07 goto msg
start /max %windir%\notepad.exe bz.07>nul
ctty con
goto menu

:h
@ctty nul
if not exist bz.08 goto msg
start /max %windir%\notepad.exe bz.08>nul
ctty con
goto menu

:i
@ctty nul
if not exist bz.09 goto msg
start /max %windir%\notepad.exe bz.09>nul
ctty con
goto menu

:j
@ctty nul
if not exist bz.10 goto msg
start /max %windir%\notepad.exe bz.10>nul
ctty con
goto menu

:k
@ctty nul
if not exist bz.11 goto msg
start /max c:\progra~1\access~1\wordpad.exe bz.11>nul
ctty con
goto menu

:l
@ctty nul
if not exist bz.12 goto msg
start /max c:\progra~1\access~1\wordpad.exe bz.12>nul
ctty con
goto menu

:m
@ctty nul
if not exist bz.13 goto msg
start /max %windir%\notepad.exe bz.13>nul
ctty con
goto menu

:n
@ctty nul
if not exist bz.14 goto msg
start /max %windir%\notepad.exe bz.14>nul
ctty con
goto menu

:msg
cscript msg.vbs
ctty con
goto menu

:done
cls