@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Demonstration of self-deleting Batch file

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Main application code goes here
ECHO. This Batch file deletes itself. Press [Return] to continue
PAUSE>NUL
ECHO.
ECHO. Thank you. This Script will now self-delete...

:: Transfer control to the Subroutine to delete ourselves
:: In this case, we don't CALL the Subroutine, we just restart
:: ourself with the Subroutine flag and ID, so the Subroutine runs
:: We don't want (or need) to return from the Subroutine, since
:: we won't be here! (we'll have been deleted)
%0 GOTO: _DELSLF

GOTO EOF {=Subroutine-section-below=}
:_DELSLF (Usage: %0 GOTO: _DELSLF)
:: Use START to get the full path to ourselves in variable SELF
start /w /m %0 GOTO: 1_DELSLF SELF %TEMP%.\_X.BAT
:: On return the _X.BAT file has the full path to ourselves
CALL %TEMP%.\_X.BAT

:: Build the _X.BAT transient Batch file. It has no final CarriageReturn
:: Linefeed, so it can delete itself (and us) without any error message
ECHO.e100'DEL %%1'd a'SET %%2='d a'DEL %%3'>%TEMP%.\_X.BAT
FOR %%C IN (rcx 17 w q) DO ECHO.%%C>>%TEMP%.\_X.BAT
TYPE %TEMP%.\_X.BAT | debug %TEMP%.\_X.BAT>NUL

:: This line transfers control to _X.BAT, which deletes us, and then
:: clears the SELF variable, and finally deletes itself without error
:: so this line is the last one to execute in this current Batch file
%TEMP%.\_X.BAT %SELF% SELF %TEMP%.\_X.BAT

:1_DELSLF
:: This line is called by START, and gets the full path to self
ECHO.SET %3=%0>%4

:EOF {End-of-file}
