@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Demonstration of the standard _DTM Batch Subroutine to extract
:: date and time tokens from the Real Time Clock CMOS RAM into
:: environment variables. Each token is extracted as two digits.

:: Start with clear screen
CLS
ECHO.     Date and Time tokens for use in file and folder names
ECHO.

:: Call _DTM Subroutine to set 7 date/time variables (C Y MO D H MI S)
CALL %0 GOTO: _DTM

:: Demonstration use of the 7 date tokens: C Y MO D and H MI S
ECHO. The _DTM Subroutine sets the 7 variables, as follows:
ECHO.  Current Date: Two-digit Century in variable C = %C%
ECHO.                Two-digit Year in variable    Y = %Y%
ECHO.                Two-digit Month in variable  MO = %MO%
ECHO.                Two-digit Day in variable     D = %D%
ECHO.
ECHO.  Current Time: Two-digit Hour in variable    H = %H%
ECHO.                Two-digit Minute in variable MI = %MI%
ECHO.                Two-digit Seconds in variable S = %S%
ECHO.
ECHO. Combine the separate tokens as you wish, for example:
ECHO.  Current date in format YYYY-MM-DD = %C%%Y%-%MO%-%D%
ECHO.  Current time in format   HH-MM-SS = %H%-%MI%-%S%
ECHO.
ECHO. You can expand the variables in file or folder names:
ECHO.
ECHO.  Example XCOPY command, using a YYYYMMDD destination:

:: To activate a demo command, remove: ECHO.{demo!}
ECHO.{demo!}xcopy C:\FOLDER\*.* C:\%C%%Y%%MO%%D%\*.* /s /y /d
ECHO.
ECHO.  Example command to rename file to YYYYMMDD-HHMMSS.*:
:: To activate a demo command, remove: ECHO.{demo!}

ECHO.{demo!}REN "C:\My Documents\Myfile.txt" %C%%Y%%MO%%D%-%H%%MI%%S%.*
ECHO.

:: Logic flow ends here, clear up all variables
FOR %%V IN (C Y MO D H MI S TM DT) DO SET %%V=

GOTO EOF {=Subroutine-section-below=}
:_DTM (Usage: CALL %0 GOTO: _DTM)
ECHO.e100 e8 0 0 80 c3 2 88 dc cd 1a 89 97 1e 1 89 8f 22 1 c3>%TEMP%.\_DT.BAT
FOR %%C IN (g d121L7 q) DO ECHO.%%C>>%TEMP%.\_DT.BAT
TYPE %TEMP%.\_DT.BAT|debug|find ":">%TEMP%.\_DT.BAT
FOR %%C IN (e100'%%1'20'%%2'20'%%3'20 w q) DO ECHO.%%C>>%TEMP%.\_DT.BAT
TYPE %TEMP%.\_DT.BAT|debug %TEMP%.\_DT.BAT>NUL
CALL %TEMP%.\_DT.BAT %0 GOTO: 1_DTM
DEL %TEMP%.\_DT.BAT
GOTO EOF
:1_DTM
FOR %%V IN ("H=%7" "MI=%6" "S=%3" "C=%9" "Y=%8" "MO=%5" "D=%4") DO SET %%V

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
