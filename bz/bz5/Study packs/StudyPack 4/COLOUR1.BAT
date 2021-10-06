@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Low-intensity (subdued) ColourCodes
::  @ = Black
::  a = Blue
::  b = Green
::  c = Cyan
::  d = Red
::  e = Purple
::  f = Brown
::  g = LightGrey
:: High-intensity (bright) ColourCodes
::  h = DarkGrey
::  i = LightBlue
::  j = LightGreen
::  k = LightCyan
::  l = LightRed
::  m = LightPurple
::  n = Yellow
::  o = White

:: To use, first CALL the _COLOUR Subroutine:
:: CALL %0 GOTO: _COLOUR COL
:: This makes a tiny _COL.COM program, and loads path in variable COL
:: Use as:
:: %COL% CharForeGround CharBackGround "Message Can Include <and|and>"

:: Create the %COL% program
CALL %0 GOTO: _COLOUR COL

ECHO.
ECHO.        Simple demonstration of Batch Colour (without ANSI.SYS)
ECHO.

:: Write some coloured text with it (all text appears on one line)
%COL% g @ " Demo "
%COL% o d " <White On Red> "
%COL% k a " <Cyan On Blue> "
%COL% n c " <Yellow On Cyan> "
%COL% @ g " <Reverse Video> "
%COL% g @ " end"

:: Write a CarriageReturn Linefeed to end the coloured text line
ECHO.

ECHO.
ECHO.       No third-party add-ons needed, the Subroutine does it all
ECHO.
:: Tidy up by deleting the temporary program and clearing COL variable
DEL %COL%
SET COL=

GOTO EOF {=Subroutine-section-below=}
:_COLOUR (Usage: CALL %0 GOTO: _COLOUR VarName)
SET %3=%TEMP%.\_COL.COM
%COMSPEC%/c %0 GOTO: 1_COLOUR ECHO. %TEMP%.\_COL.COM|debug>NUL
GOTO EOF
:1_COLOUR
%3 e100 b8 10 0 f6 26 84 0 bb f 0 22 1e 82 0 1 c3
%3 e110 30 ff be 87 0 31 c9 8a e 80 0 83 e9 7 76 1d
%3 e120 51 b9 1 0 b4 9 8a 4 cd 10 53 31 db b4 3 cd
%3 e130 10 80 c2 1 b4 2 cd 10 5b 59 46 e2 e3 cd 20
FOR %%C IN (rbx 0 rcx 3f n%4 w q) DO %3 %%C

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
