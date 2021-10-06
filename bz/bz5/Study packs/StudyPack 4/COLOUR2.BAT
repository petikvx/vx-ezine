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

:: Clear the screen and write the demonstration text
CLS
ECHO.
%COL% g @ "           "
%COL% n c "This demonstrates the use of the _COLOUR Subroutine"
ECHO.
ECHO.
%COL% n @ "  The Subroutine creates a tiny program ( "
%COL% o d "_COL.COM"
%COL% n @ " ) in your "
%COL% k @ "TEMP"
%COL% n @ " folder"
ECHO.
%COL% n @ "  and loads the full path to the program in the environment variable "
%COL% o d "COL"
ECHO.
%COL% n @ "  Use "
%COL% n m "colour"
%COL% n @ " by expanding this variable (as "
%COL% o d "%%COL%%"
%COL% n @ "), and add "
%COL% j @ "ColourCodes"
%COL% n @ ":"
ECHO.
ECHO.
%COL% g @ "  "
%COL% o d "%%COL%%"
%COL% j @ " ForeGround "
%COL% @ g " BackGround "
%COL% j @ " ""
%COL% m @ "-string to display-"
%COL% j @ """
ECHO.
%COL% j @ "    Low-intensity ColourCodes"
ECHO.
%COL% j @ "      @ = "
%COL% @ g " Black "
%COL% j @ "      a = "
%COL% a g " Blue   "
%COL% j @ "     b = "
%COL% b g " Green "
%COL% j @ "      c = "
%COL% c g " Cyan    "
ECHO.
%COL% j @ "      d = "
%COL% d g " Red   "
%COL% j @ "      e = "
%COL% e g " Purple "
%COL% j @ "     f = "
%COL% f g " Brown "
%COL% j  "       g ="
%COL% g @ " LightGrey"
ECHO.
%COL% j @ "    High-intensity ColourCodes"
ECHO.
%COL% j @ "      h = "
%COL% h g " DarkGrey "
%COL% j @ "   i = "
%COL% i g " LightBlue "
%COL% j @ "  j = "
%COL% j @ "LightGreen"
%COL% j @ "   k = "
%COL% k @ "LightCyan"
ECHO.
%COL% j @ "      l = "
%COL% l @ " LightRed"
%COL% j @ "    m = "
%COL% m @ "LightPurple"
%COL% j @ "  n = "
%COL% n @ "Yellow"
%COL% j @ "       o = "
%COL% o @ "White"
ECHO.
%COL% g @ "  eg: %%COL%% k d ""
%COL% k d "<LightCyan on Red>"
%COL% g @ """
ECHO.
ECHO.
%COL% g @ "   "
%COL% k a "The program writes what's inside the "quotes". Leave only one Space"
ECHO.
%COL% g @ "   "
%COL% k a "between "
%COL% o d "%%COL%%"
%COL% k a ", and each code, and the start of the "quoted string"."
ECHO.
%COL% g @ "   "
%COL% k a "The "
%COL% o d "%%COL%%"
%COL% k a " program doesn't add a CarriageReturn Linefeed, so you can"
ECHO.
%COL% g @ "   "
%COL% k a "write consecutive changes of colour displayed on the same line with"
ECHO.
%COL% g @ "   "
%COL% k a "repeated %%COL%% commands. Use an ordinary "
%COL% n d "ECHO."
%COL% k a " to start a new line."
ECHO.
ECHO.
%COL% g @ "        "
%COL% n f "No third-party add-ons needed, the Subroutine does it all"
ECHO.
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
