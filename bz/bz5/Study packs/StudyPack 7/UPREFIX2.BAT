@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Begin with a clear display
CLS
ECHO.
ECHO.     Second demonstration of the Universal Prefix technique
ECHO.
ECHO. (a) We make a Universal Prefix file (_P.BAT) in the %%TEMP%% folder
:: Make Universal Prefix file
ECHO.e100'SET %%1='>%TEMP%.\_P.BAT
FOR %%C IN (rcx 7 w q) DO ECHO.%%C>>%TEMP%.\_P.BAT
TYPE %TEMP%.\_P.BAT | debug %TEMP%.\_P.BAT>NUL

ECHO. (b) Append ordered list of files in current folder (newest first)
ECHO. (c) This first file (the newest one) is appended on the same line
ECHO.     as the SET command, so the Universal Prefix file now becomes:
ECHO.
ECHO.SET %%1={first file name, the newest}
ECHO.{any other files on remaining lines}
ECHO.

:: Append the ordered list of files, order = newest first
:: We use /o-d to get the ordered list, and /a-d to exclude folder names
:: Use /-p in case DIRCMD has been loaded with /p to pause the listing
DIR *.* /b /o-d /a-d /-p>>%TEMP%.\_P.BAT

ECHO. (d) We need to filter the result (with FIND) to extract the first
ECHO.     line. Filter on "SET %%1=" (unlikely to appear on other lines)
TYPE %TEMP%.\_P.BAT | find "SET %%1=">%TEMP%.\_P.BAT

ECHO.
ECHO. (e) The resulting %%TEMP%%.\_P.BAT after filtering looks like this:
ECHO.
TYPE %TEMP%.\_P.BAT
ECHO.
ECHO. (f) So we can load the filename to variable FN with command line:
ECHO.
ECHO.CALL %%TEMP%%.\_P.BAT FN
ECHO.

:: Call the Universal Prefix file to grab the filename
CALL %TEMP%.\_P.BAT FN
ECHO. (g) The filename is now retrieved in FN=%FN%
ECHO.

:: Tidy up, delete the Universal Prefix workfile and clear variable
DEL %TEMP%.\_P.BAT
SET FN=
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
