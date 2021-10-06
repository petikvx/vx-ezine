@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Basic TEMPLATE for writing a Batch file that uses Subroutines

CLS
ECHO.
ECHO. A TEMPLATE to use when writing Batch files that call Subroutines.
ECHO.                  === The main code goes here ===
ECHO.

:: Typical syntax for Subroutine call
CALL %0 GOTO: _SUBR the parameters go here

ECHO.
ECHO. Further main code may also be used anywhere before the Subroutine
ECHO. section itself starts. And, of course, there can be many calls of
ECHO. each of the Subroutines included in the Subroutine section below.
ECHO.
ECHO. The main code flow ends here, just before the Subroutine Section.
ECHO.

:: All Subroutines go in the section below
GOTO EOF {=Subroutine-section-below=}
:_SUBR (Usage: CALL %0 GOTO: _SUBR parameters go here)

ECHO.   Now in Subroutine %3
ECHO.     The Subroutine-Handler flag is in %%1 = [%1]
ECHO.     This specific Subroutine ID is in %%2 = [%2]
ECHO.
ECHO.     This Subroutine's parameters are as follows:
ECHO.       %%3=[%3]
ECHO.       %%4=[%4]
ECHO.       %%5=[%5]
ECHO.       %%6=[%6] and so on...

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
