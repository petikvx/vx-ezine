@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Begin with a clear display
CLS
ECHO.
ECHO.      Simple demonstration of the Universal Prefix technique
ECHO.
ECHO. First, a DIR C:\README.TXT /b /s command is used to create a list
ECHO. of all files called README.TXT on your C: drive. The list file is
ECHO. _LIST in your %%TEMP%% folder (intended for any temporary files).
ECHO.
ECHO. Please wait while the list is built...

:: Run DIR command and write output into _LIST in %TEMP% folder.
:: Some users place /p in the variable DIRCMD, which makes DIR pause
:: after each screenful, waiting for [Return] to be pressed. This could
:: stall a Batch script if the DIR listing was longer than a screenful.
:: To avoid a stall, we use /-p in the DIR line (this overrides DIRCMD)
DIR C:\README.TXT /b /s /-p>%TEMP%.\_LIST

ECHO.
ECHO. We then use FIND/c to count the number of lines in this list file
ECHO. so counting the total number of files found with the DIR command.
ECHO.
ECHO. The FIND/c output is simply the count of lines in the file, thus:
ECHO.

find "" /v /c<%TEMP%.\_LIST
:: This is the standard way of counting all lines. The /v "" says pass
:: through all lines that don't contain the target (/v = inVerted logic).
:: Since the target is "" (nothing, a null string), and FIND regards even
:: a blank line as containing something (a CarriageReturn), this is the
:: same as saying pass through ALL lines (and the /c counts them).

ECHO.
ECHO. The Universal Prefix technique can grab this to a variable, thus:

:: Make Universal Prefix file
ECHO.e100'SET %%1='>%TEMP%.\_P.BAT
FOR %%C IN (rcx 7 w q) DO ECHO.%%C>>%TEMP%.\_P.BAT
TYPE %TEMP%.\_P.BAT | debug %TEMP%.\_P.BAT>NUL

:: Append the output of the FIND command to this _P.BAT file
FIND "" /v /c<%TEMP%.\_LIST>>%TEMP%.\_P.BAT

:: Grab the line of text in variable COUNT
CALL %TEMP%.\_P.BAT COUNT
ECHO.
ECHO. And the number of files called README.TXT on C: = %COUNT%
ECHO.

:: Tidy up, delete the workfiles and clear variable
DEL %TEMP%.\_LIST
DEL %TEMP%.\_P.BAT
SET COUNT=
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
