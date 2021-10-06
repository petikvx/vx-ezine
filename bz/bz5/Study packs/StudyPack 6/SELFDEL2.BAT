@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

CLS
ECHO.
ECHO.     Demonstration of START method to find path to SELF

:: Call (START) the Subroutine to get full path to self
start /w /m %0 GOTO: _GETSELF SELF %TEMP%.\_SELF.BAT

:: Grab the result and delete the workfile
FOR %%C IN (CALL DEL) DO %%C %TEMP%.\_SELF.BAT

ECHO.
ECHO. Short-form alias FileSpec for this file=%SELF%
ECHO.
ECHO. If we now used a simple DEL command such as this {demo!} command:
ECHO.
ECHO.{demo!}DEL %SELF%
ECHO.
ECHO. this Batch file would indeed be deleted but Windows will continue
ECHO. to try and read the rest of the (now deleted) Batch file and give
ECHO. the error: "Batch file missing" (the solution is in SELFDEL3.BAT)
ECHO.
ECHO. That's because a simple self-delete command needs to be the final
ECHO. command on a special line that has no CarriageReturn or Linefeed.
ECHO.
ECHO. SELFDEL3.BAT demonstrates how to use a full path to SELF together
ECHO. with our MidExit technique to allow a Batch file to delete itself
ECHO. without creating this error, and without the need for a specially
ECHO. edited file with no final CarriageReturn or Linefeed termination.
ECHO.

:: Tidy up by clearing the variable
SET SELF=

GOTO EOF {=Subroutine-section-below=}
:_GETSELF (Usage: %0 GOTO: _GETSELF VariableName Workfile)
:: This line is called by START, and gets the full path to self
:: because the %0 parameter holds this full path when we're run
:: from the START command
ECHO.SET %3=%0>%4

:EOF {End-of-file}
