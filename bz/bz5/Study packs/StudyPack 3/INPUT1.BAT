@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

CLS
ECHO.
ECHO.           Simple demonstration of input into a Batch file
ECHO.
ECHO. Input some text and press [Return]

:: Use FC /lb1 to grab the line of input, and FIND to number the lines
:: and filter out the 4th (which will have the input text), then use
:: MORE twice to prefix the line with four extra characters (each MORE
:: adds a newline = a CarriageReturn and a LineFeed). These four extra
:: characters make room for the SET %1= prefix
fc /lb1 CON NUL|find /n /v ""|find "[4]"|more|more>%TEMP%.\_IN.BAT

:: Use small Debug script to place SET %1= prefix at start of input
ECHO.e100'SET %%1='>%TEMP%.\_IN
FOR %%C IN (w q) DO ECHO.%%C>>%TEMP%.\_IN
debug %TEMP%.\_IN.BAT<%TEMP%.\_IN>NUL

:: Call the resulting working Batch script with INPUT as %1 parameter
:: (you can use any name in this postion, of course)
CALL %TEMP%.\_IN.BAT INPUT
ECHO. The text you typed was:%INPUT%

:: Tidy up by deleting workfiles and clearing variable
FOR %%F IN (%TEMP%.\_IN.BAT %TEMP%.\_IN) DO DEL %%F
SET INPUT=
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
