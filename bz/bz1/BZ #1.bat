@echo off
:menu
echo.
echo.
echo              ����             DvL proudly presents           ��ͻ
echo              �                    BATch Zone #1                 �
echo              ���� www.geocities.com/ratty_dvl/BATch/main.htm ��ͼ
echo.
echo.
echo    Read an article
echo    ���������������
echo.
echo.
echo   A.IndeX                B.Editorial            C.Introduction to BATch
echo   D.Learning BATch       E.DMenu 3.0            F.SBC 2.0
echo   G.BATlle-Field         H.Interview - SAD1c    I.Interview - philet0ast3r
echo   J.Interview - SpTh     K.BRNG v 2.0           L.Bat.Antifa
echo   M.Bat.InnerFire        N.Bat.NRG              O.Useful things in Batch
echo   P.Our real faces       Q.BAT.PureFilth
echo.
echo    X - Quit
echo.
echo.
choice /c:ABCDEFGHIJKLMNOPQX>nul
if errorlevel 18 goto done
if errorlevel 17 goto Q
if errorlevel 16 goto P
if errorlevel 15 goto O
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
echo CHOICE missing
goto done

:A
ctty nul
cls
@if not exist bz.00 goto msg
@start /max %windir%\notepad.exe bz.00 >nul
ctty con
cls
goto menu

:B
ctty nul
cls
@if not exist bz.01 goto msg
@start /max %windir%\notepad.exe bz.01 >nul
ctty con
cls
goto menu

:C
ctty nul
cls
@if not exist bz.02 goto msg
@start /max %windir%\notepad.exe bz.02 >nul
ctty con
cls
goto menu

:D
ctty nul
cls
@if not exist bz.03 goto msg
@start /max %windir%\notepad.exe bz.03 >nul
ctty con
cls
goto menu

:E
ctty nul
cls
@if not exist bz.04 goto msg
@start /max %windir%\notepad.exe bz.04 >nul
ctty con
cls
goto menu

:F
ctty nul
cls
@if not exist bz.05 goto msg
@start /max %windir%\notepad.exe bz.05 >nul
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
@if not exist bz.07 goto msg
@start /max %windir%\notepad.exe bz.07 >nul
ctty con
cls
goto menu

:I
ctty nul
cls
@if not exist bz.09 goto msg
@start /max %windir%\notepad.exe bz.09 >nul
ctty con
cls
goto menu

:J
ctty nul
cls
@if not exist bz.08 goto msg
@start /max %windir%\notepad.exe bz.08 >nul
ctty con
cls
goto menu

:K
ctty nul
cls
@if not exist bz.10 goto msg
@start /max %windir%\notepad.exe bz.10 >nul
ctty con
cls
goto menu

:L
ctty nul
cls
@if not exist bz.11 goto msg
@start /max %windir%\notepad.exe bz.11 >nul
ctty con
cls
goto menu

:M
ctty nul
cls
@if not exist bz.14 goto msg
@start /max %windir%\notepad.exe bz.14 >nul
ctty con
cls
goto menu

:N
ctty nul
cls
@if not exist bz.13 goto msg
@start /max %windir%\notepad.exe bz.13 >nul
ctty con
cls
goto menu

:O
ctty nul
cls
@if not exist bz.12 goto msg
@start /max %windir%\notepad.exe bz.12 >nul
ctty con
cls
goto menu

:P
ctty nul
cls
@if not exist bz.15 goto msg
@start /max %windir%\notepad.exe bz.15 >nul
ctty con
cls
goto menu

:Q
ctty nul
cls
@if not exist bz.16 goto msg
@start /max %windir%\notepad.exe bz.16 >nul
ctty con
cls
goto menu

:msg
cls
@if exist msg.vbs goto show
@echo.On Error Resume Next>msg.vbs
@echo.MsgBox " The following article doesn't exists in this directory anymore !~! ", vbOKOnly & vbExclamation, "BZ #1 mag">>msg.vbs
goto show

:show
cls
@start msg.vbs
cls
cls ctty con
goto menu

:done
cls