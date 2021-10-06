@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

ECHO. This is the main code section

CALL %0 GOTO: _SUBR SubParOne SubParTwo

ECHO. Back in the main code section
ECHO. This is the end of main code.

GOTO EOF {=Subroutine-section-below=}
:_SUBR
ECHO.   Now in the _SUBR Subroutine
ECHO.   %%3 Parameter passed=%3
ECHO.   %%4 Parameter passed=%4

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
