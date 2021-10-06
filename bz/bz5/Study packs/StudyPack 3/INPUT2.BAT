@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

CLS
ECHO.
ECHO.           Demonstration of input into a Batch file
ECHO.         using a Batch Subroutine for the Input code
ECHO.
ECHO. The Subroutine requires the Prompt string passed as a single-word
ECHO. token, so the Prompt itself can't have literal embedded [Space]s.
ECHO. The Prompt is written with no trailing CarriageReturn or Linefeed
ECHO. so the input (it can contain [Spaces]s) appears on the same line.
ECHO.

:: Call the Subroutine with the Variable name and Prompt string
:: In this case the Variable to be loaded with the input is RESULT
:: and the Prompt string to be displayed to the user is EnterSomeText:
:: (By Prompt string we simply mean the string the user is presented
:: with as a request for input, we don't mean the system MS-DOS PROMPT)

CALL %0 GOTO: _INPUT RESULT EnterSomeText:
ECHO.  You entered: %RESULT%
SET RESULT=

:: Use MEM command to test whether or not ANSI.SYS is loaded
mem /m ANSI | find /i "Installed Device=ANSI">NUL
:: Use the ANSI version of this Demo if ANSI.SYS is loaded
IF NOT ERRORLEVEL 1 GOTO ANSISYSInstalled

ECHO.
ECHO. We can use '20' as the code for any [Space]s in the Prompt string
ECHO. and this entire string will be passed as one token to Subroutine.
ECHO. (DEBUG interprets the '20' as the Hexadecimal code for a [Space])
ECHO.
CALL %0 GOTO: _INPUT RESULT '20'Enter'20'your'20'name:
ECHO.     You entered: %RESULT%
SET RESULT=
ECHO.
GOTO EOF

:ANSISYSInstalled
:: This is the ANSI.SYS coloured Prompt string example
ECHO.
ECHO. We can use '20' as the code for any [Space]s in the Prompt string
ECHO. and this entire string will be passed as one token to Subroutine.
ECHO. (DEBUG interprets the '20' as the Hexadecimal code for a [Space])
ECHO.
ECHO. You can use '1b' as an [ESC]ape character and '3b' as a [;] which
ECHO. means ANSI colour codes can be used within the prompting strings.
ECHO.

:: The Prompt string: '1b'[1'3b'33'3b'44m'20'Enter'20'your'20'name:'1b'[m
:: is the ANSI colour graphic sequence, with ESCape characters coded as
:: '1b' and ; (semi-colons) coded as '3b' and [Space]s as '20' (their
:: respective ASCII values in Hexadecimal). This encoding allows text
:: containing delimiters such as ; and [Space] to be sent as a single
:: token (in the %4 parameter position) to the Subroutine
CALL %0 GOTO: _INPUT RESULT '1b'[1'3b'33'3b'44m'20'Enter'20'your'20'name:'1b'[m
ECHO.     You entered: %RESULT%
SET RESULT=
ECHO.
GOTO EOF

GOTO EOF {=Subroutine-section-below=}
:_INPUT (Usage: CALL %0 GOTO: _INPUT VarName PromptText)
:: Write the encoded Prompt string to a DEBUG script and terminate
:: it with a 1a (Ctrl-Z) character. When TYPEd, this Ctrl-Z will
:: terminate the file (which avoids having to calculate how long
:: the Prompt string passed to this Subroutine was)
ECHO.e100'%4'20 1a>%TEMP%.\_IN.BAT
:: Complete the DEBUG script to build the file containing the Prompt
:: string. It has no CarriageReturn Linefeed ending, so when TYPEd
:: the cursor will stay on the same line to receive the user Input
FOR %%C IN (rcx 40 w q) DO ECHO.%%C>>%TEMP%.\_IN.BAT
TYPE %TEMP%.\_IN.BAT|debug %TEMP%.\_IN.BAT>NUL
:: Type the Prompt string file
TYPE %TEMP%.\_IN.BAT
:: Get user input (see INPUT1.BAT for annotated version of this code)
fc /lb1 CON NUL|find /n /v ""|find "[4]"|more|more>%TEMP%.\_IN.BAT
ECHO.e100'SET %%1='>%TEMP%.\_IN.SCR
FOR %%C IN (w q) DO ECHO.%%C>>%TEMP%.\_IN.SCR
debug %TEMP%.\_IN.BAT<%TEMP%.\_IN.SCR>NUL
CALL %TEMP%.\_IN.BAT %3
FOR %%F IN (_IN.BAT _IN.SCR) DO DEL %TEMP%.\%%F

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
