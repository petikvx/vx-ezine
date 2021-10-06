@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Start with clear screen
CLS
ECHO.
ECHO.                Using a Subroutine to process files
ECHO.
ECHO. This example shows the syntax to have a Batch Subroutine process,
ECHO. one by one, all files of a particular type in the current folder.
ECHO.
ECHO. Press [Return] to continue...
PAUSE>NUL
ECHO.
ECHO. First we create some .TXT files to use with the Subroutine. These
ECHO. text files are created by redirection. We use the /? help text in
ECHO. several Batch commands (to create files with differing contents).

:: This FOR IN DO statement calls the Subroutine _CREATE for each file
:: passing a different digit each time that the Subroutine is called
FOR %%T IN (1 2 3 4 5 6 7 8 9) DO CALL %0 GOTO: _CREATE %%T
ECHO.
ECHO.             Sample files created as follows:
:: Display a filtered list of the SAMPLE?.TXT files
DIR SAMPLE?.TXT | find "SAMPLE"
ECHO.
ECHO. Press [Return] to continue...
PAUSE>NUL
CLS
ECHO.
ECHO. We now use a FOR IN DO statement to scan for SAMPLE?.TXT and pass
ECHO. each of the filenames to Subroutine _FSCAN (as its %%3 parameter).
ECHO.
ECHO. In the Subroutine, as an example of processing each file in turn,
ECHO. we will count how many lines in each file contain the word "the",
ECHO. how many lines contain "and", then count each file's total lines.
ECHO.
ECHO. Press [Return] to continue...
PAUSE>NUL
CLS
FOR %%F IN (SAMPLE?.TXT) DO CALL %0 GOTO: _FSCAN %%F
ECHO.
ECHO. All SAMPLE?.TXT files have been processed through the Subroutine.
ECHO.

:: Tidy up by deleting the sample files
FOR %%T IN (1 2 3 4 5 6 7 8 9) DO DEL SAMPLE%%T.TXT

GOTO EOF {=Subroutine-section-below=}
:_FSCAN (Usage: CALL %0 GOTO: _FSCAN FileName)
:: This Subroutine is called by the FOR IN DO line, and each file
:: name found in the FOR IN DO scan is passed in turn in the %3
:: parameter position.

:: In this Subroutine we can process each file passed with any
:: Batch commands we please. We simply use %3 as the filename,
:: and the code will operate on each file in turn

CLS
ECHO.
ECHO.   ==In Subroutine== _FSCAN, filename %%3 = %3
ECHO.
ECHO.   Number of lines in %3 containing word "the"
:: Use FIND to /c=count the relevant lines in %3
find /i /c "the" %3

ECHO.
ECHO.
ECHO.   Number of lines in %3 containing word "and"
:: Use FIND to /c=count the relevant lines in %3
find /i /c "and" %3

ECHO.
ECHO.
ECHO.   Total number of lines in %3
:: Use FIND to count the lines, we do this by counting (=/c) all
:: the lines that don't contain (=/v) nothing at all (= "")
find /v /c "" %3
ECHO.
ECHO.
ECHO.   Press [Return] to continue with any remaining files...
PAUSE>NUL

GOTO EOF {=Subroutine-section-below=}
:_CREATE (Usage: CALL %0 GOTO: _CREATE Counter)

REM Initialise text file for current counter>SAMPLE%3.TXT
:: We append help text for one of nine Batch commands to the file.
:: This is purely to create files with differing content for the
:: word count exercise in the filescan (_FSCAN) Subroutine. The help
:: text is appended only when the IF comparison matches the %3 count,
:: otherwise NOTHING is appended. For this type of operation, you must
:: use >> append. If you use > (redirect to new file) a false IF
:: comparison would  clear the file concerned, since the redirection
:: operator at the end of an IF line is used whether or not the IF
:: test is true. A false IF TEST results in no output, and so normal
:: redirection with > operator would put no output in a file (=clear
:: it) overwriting any output from an earlier line.
IF (1)==(%3) attrib /?>>SAMPLE%3.TXT
IF (2)==(%3) choice /?>>SAMPLE%3.TXT
IF (3)==(%3) deltree /?>>SAMPLE%3.TXT
IF (4)==(%3) fc /?>>SAMPLE%3.TXT
IF (5)==(%3) find /?>>SAMPLE%3.TXT
IF (6)==(%3) mem /?>>SAMPLE%3.TXT
IF (7)==(%3) more /?>>SAMPLE%3.TXT
IF (8)==(%3) move /?>>SAMPLE%3.TXT
IF (9)==(%3) xcopy /?>>SAMPLE%3.TXT

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
