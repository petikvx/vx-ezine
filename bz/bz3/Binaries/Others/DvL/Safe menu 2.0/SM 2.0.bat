@echo off
@ver|find "XP"|if errorlevel 1 goto main|if not errorlevel 1 exit
:main
cls
ctty nul
@deltree/y report.txt >nul
@echo.>>report.txt
@echo.Safe Menu 2.0 Report File>>report.txt
@echo.=-=-=-=-=-=-=-=-=-=-=-=-=>>report.txt
@echo.>>report.txt
@echo.@prompt set date=$d$_set time=$t$_set>1.bat
@%comspec% /c 1.bat>2.bat
@for %%_ in (2.bat del) do call %%_ ?.bat
@echo.Report created on %date% at %time%>>report.txt
@echo.>>report.txt
ctty con
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                         ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                         ³ °±²Û Safe Menu 2.0 Û²±° ³ [DvL]
echo                         ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo.
@find "eicar" %1 %2 %3 %4 %5 %6 %7 %8 %9|if errorlevel 1 goto b1|if not errorlevel 1 goto 001
:001
@echo.The EICAR string was found in your scan process. This string is sometimes used in>>report.txt
@echo.batch virii to hide them from AV`z.>>report.txt
@echo.>>report.txt
goto b1
:b1
@find "ctty nul" %1 %2 %3 %4 %5 %6 %7 %8 %9|if errorlevel 1 goto b2|if not errorlevel 1 goto 002
:002
@echo.Redirection to NUL string was found in your scan process. This string is very used in>>report.txt
@echo.batch virii to hide the infection process.>>report.txt
@echo.>>report.txt
goto b2
:b2
@find "set" %1 %2 %3 %4 %5 %6 %7 %8 %9|if errorlevel 1 goto b3|if not errorlevel 1 goto 003
:003
@echo.The SET string was found in your scan process. This string is usually used to encrypt>>report.txt
@echo.batch virii.>>report.txt
@echo.>>report.txt
:b3
@find "format c:" %1 %2 %3 %4 %5 %6 %7 %8 %9|if errorlevel 1 goto done|if not errorlevel 1 goto 004
:004
@echo.FORMAT C: string was found in your scan process. This string formats your C hard>>report.txt
@echo.drive. Be careful at what you execute.>>report.txt
@start /max c:\windows\notepad.exe report.txt >nul
:done
cls