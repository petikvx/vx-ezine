@ECHO OFF
:: This is a crude example of a self-deleting Batch file

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: First try to find the name of this file. The %0 symbol
:: contains the name that was used to run this Batch file
SET N=%0

:: The name used may not have included the .BAT extension.
:: Check and add one if needed. In testing for .BAT we append a :
:: (= colon) to the %0 parameter and check for ".BAT:" to make
:: sure we are checking the extension against last three characters
:: in the %0 symbol. Otherwise FIND may locate the .BAT anywhere in
:: the filename (although it is very unlikely to occur elsewhere).
:: FIND /i (case insensitive) since file name may be upper or lowercase
ECHO. %0: | find /i ".BAT:">NUL
IF ERRORLEVEL 1 SET N=%0.BAT

:: Now use a DEL command on the last line of this Batch file, and
:: with no CarriageReturn LineFeed combo at the end of this line
:: When the last line has no final CarriageReturn LineFeed then
:: Windows doesn't show any error message when file self-deletes
ECHO. Deleting file: %N%
:: Following line must have no CarriageReturn or Linefeed termination
DEL %N%