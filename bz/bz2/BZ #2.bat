@echo off
cls
:menu
cls
echo.
echo.
echo.
echo.           ɻ
echo            �����ͻ           ��    presenting    Ļ           ���ͻ
echo              �   �����������ͼ    BATch Zone 2    �����������͹   �
echo            �����ͼ www.geocities.com/ratty_dvl/BATch/main.htm ���ͼ
echo.           ȼ
echo.
echo.
echo    What shall`it be ?
echo    ������������������
echo.
echo.
echo.
echo   A.IndeX                B.Editorial            C.BAT Tips & tricks I
echo   D.Payloads in batch    E.BAT Startup Methods  F.Bat\BatXP.Iaafe
echo   G.Nice Batch Payloads  H.Bat.Bush             I.Interview with Adious
echo   J.Interview with me    K.BZ logo
echo.
echo.
echo   X.e X i t - [the way out to the "real" world]
echo.
echo.
choice /c:ABCDEFGHIJKX>nul
if errorlevel 12 goto done
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
@if not exist bz.08 goto msg
@start /max %windir%\notepad.exe bz.08 >nul
ctty con
cls
goto menu

:J
ctty nul
cls
@if not exist bz.09 goto msg
@start /max %windir%\notepad.exe bz.09 >nul
ctty con
cls
goto menu

:K
cls
@echo.
@echo.
@echo.
@echo    ����Ŀ  �����Ŀ �����Ŀ �����Ŀ �����Ŀ
@echo    �  B �� �  A  � �  T  � �  C  � �  H  �
@echo    �     � �     � ��   �� �    Ĵ �     �
@echo    �     � �     �  �   �  �     � �     �
@echo    ������� �������  �����  ������� �������
@echo    �����Ŀ �����Ŀ �����Ŀ �����Ŀ
@echo    �� Z  � �  O  � �  N  � �  E Ĵ
@echo    �     � �  �  � �     � �    Ĵ
@echo    �    Ĵ �     � �     � �     �
@echo    ������� ������� ������� �������
@echo.
@echo    The first batch and batch related zine.
@echo.
@echo.
@echo.
@type nul | choice /n /cy /ty,4 >nul
goto menu

:msg
cls
@if exist msg.vbs goto show
@echo.On Error Resume Next>msg.vbs
@echo.MsgBox " The following article doesn't exists in this directory anymore ! ",4160, "BZ #2 mag">>msg.vbs
goto show

:show
cls
@start msg.vbs
cls
cls ctty con
goto menu

:done
cls
