@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Call the _DTM Subroutine to set the seven variables
CALL %0 GOTO: _DTM
ECHO. Current date: Century=%C% Year=%Y% Month=%MO% Day=%D%
ECHO. Current time: Hour=%H% Minute=%MI% Second=%S%

:: Tidy up: clear the variables set by _DTM Subroutine
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
