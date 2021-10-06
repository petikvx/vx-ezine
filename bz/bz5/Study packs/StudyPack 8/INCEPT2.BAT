@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Create a new file called _TODAY_.BAT - since it's a new file
:: its creation Date/Time will be the current Date and Time
:: Its DIR listing will show this creation Date and Time, thus:

::  Name    Ext           Size  Date     Time    FileName
::Position:  1              2     3        4        5
:: _TODAY_  BAT             0  dd/mm/yy  hh:mm _TODAY_.BAT

:: Note the positions of the Date and Time. If we think of the DIR
:: listing as a command line, the Date=%3 and the Time=%4

:: We'll use those positions in SET commands in our new file

:: Create the file so it has two SET commands, thus:
ECHO.SET CDATE=%%3>_TODAY_.BAT
ECHO.SET CTIME=%%4>>_TODAY_.BAT

:: Next we extract its DIR listing to a temporary Batch file: _TEMP.BAT

DIR _TODAY_.BAT|find "_TODAY_">_TEMP.BAT

:: _TEMP.BAT now holds that DIR listing as if it were a command line
:: If we CALL _TEMP.BAT that DIR line will be executed as a command
:: and run our newly created _TODAY_.BAT file with the rest of the DIR
:: listing line as the command-line parameters to _TODAY_.BAT

CALL _TEMP.BAT

:: _TEMP.BAT ran _TODAY_.BAT with Current Date as %3 and with
:: Current Time as %4. And _TODAY_.BAT has exactly the SET commands
:: needed to load those to variables CDATE and CTIME respectively,
:: so now we can expand them as %CDATE% and %CTIME%

ECHO. The current Date = %CDATE% and the current Time = %CTIME%

:: Tidy up by deleting our two workfiles and clearing the variables
DEL _TODAY_.BAT
DEL _TEMP.BAT
SET CTIME=
SET CDATE=
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
