@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Pipe output of DATE command to _TEMP.BAT
ECHO.|DATE>_TEMP.BAT

:: Create a temporary Batch file called CURRENT.BAT
ECHO.SET CDAY=%%3>CURRENT.BAT
ECHO.SET CDATE=%%4>>CURRENT.BAT

:: Call _TEMP.BAT, which will in turn run CURRENT.BAT
CALL _TEMP.BAT

:: Delete the two workfiles
DEL _TEMP.BAT
DEL CURRENT.BAT

ECHO. Day name today is: %CDAY%
ECHO. The date today is: %CDATE%
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
