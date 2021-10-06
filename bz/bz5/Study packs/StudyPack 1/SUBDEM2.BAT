@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Start with clear screen
CLS
ECHO.
ECHO.              Mutiple Subroutine CALL demonstration
ECHO.

ECHO. =MainCode= Calling the _WAIT Subroutine
:: Example CALL of _WAIT Subroutine with parameter=5 seconds
CALL %0 GOTO: _WAIT 5

ECHO. =MainCode= Calling _LOCATE Subroutine to find files matching WINVER.?X?
:: Example CALL of _LOCATE Subroutine with parameter=WINVER.?X?
CALL %0 GOTO: _LOCATE WINVER.?X?

ECHO. =MainCode= Calling the _WAIT Subroutine (again)
:: Example CALL of _WAIT Subroutine with parameter=3 seconds
CALL %0 GOTO: _WAIT 3

ECHO. =MainCode= Calling _LOCATE Subroutine to find files matching Myxyzptlk.*
:: Example CALL of _LOCATE Subroutine with parameter=Myxyzptlk.*
CALL %0 GOTO: _LOCATE Myxyzptlk.*

ECHO. =MainCode= Back in main code section, and finishing.
ECHO.

GOTO EOF {=Subroutine-section-below=}
:_LOCATE (Usage: CALL %0 GOTO: _LOCATE FileName)
:: Subroutine to locate files on C: matching FileName
ECHO.    =SubroutineCode= In _LOCATE Subroutine
ECHO.    =SubroutineCode= Looking for files matching %3 on C:

:: Some users place /p in the variable DIRCMD, which makes DIR pause
:: after each screenful, waiting for [Return] to be pressed. This could
:: stall a Batch script if the DIR listing was longer than a screenful.
:: To avoid a stall, we use /-p in the DIR line (this overrides DIRCMD)
DIR C:\%3 /b /-p /s /a-d | find "C:"
IF ERRORLEVEL 1 ECHO.    =SubroutineCode= No files matching %3 found
ECHO.

GOTO EOF {=Subroutine-section-below=}
:_WAIT (Usage: CALL %0 GOTO: _WAIT SecondsToWait)
:: Subroutine to wait for 1 - 99 seconds
ECHO.    =SubroutineCode= In _WAIT Subroutine
ECHO.    =SubroutineCode= Pausing for %3 seconds...
REM | choice /c:delay /td,%3>NUL
ECHO.

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
