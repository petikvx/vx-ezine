@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}
:: Tutorial for Inception

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Recall self with standardized environment space
IF NOT (UseStandardizedEnv)==(%2) %COMSPEC% /e:4096 /c %0 _ UseStandardizedEnv
:: Finish after recall in child shell
IF NOT (UseStandardizedEnv)==(%2) GOTO EOF

:: Start with clear screen
CLS
:: Check for any _TODAY_.BAT .COM or .EXE conflicts
IF NOT EXIST _TODAY_.BAT IF NOT EXIST _TODAY_.COM IF NOT EXIST _TODAY.EXE GOTO NOCONFLICT
ECHO.
ECHO. The following file(s) conflict with the working of this Tutorial:
ECHO.
FOR %%E IN (BAT EXE COM) DO IF EXIST _TODAY_.%%E ECHO. _TODAY_.%%E
ECHO.
choice /c:ny /n " Delete conflicting file(s) now y/n "
IF NOT ERRORLEVEL 3 IF ERRORLEVEL 2 GOTO DELETEFILES
ECHO.
ECHO. Conflicting file(s) have not been deleted - terminating tutorial.
ECHO.
GOTO EOF

:DELETEFILES
:: Delete the conflicting files
FOR %%E IN (BAT EXE COM) DO IF EXIST _TODAY_.%%E DEL _TODAY_.%%E

:NOCONFLICT
:: Go ahead. Set up for using non-ANSI colour
CALL %0 GOTO: _COLOUR COL

:: Start with clear screen
CLS

:: Create the _TODAY_.BAT workfile and do all the Inception work now
ECHO.SET CDATE=%%3>_TODAY_.BAT
ECHO.SET CTIME=%%4>>_TODAY_.BAT

:: Load the DIR output into _TEMP.BAT
DIR _TODAY_.BAT | find "_TODAY_">_TEMP.BAT

:: Add extra code to _TODAY_.BAT to get the other parameters. These are
:: needed only for the display in this Tutorial
ECHO.SET INAME=%%0>>_TODAY_.BAT
ECHO.SET EXT=%%1>>_TODAY_.BAT
ECHO.SET FSIZE=%%2>>_TODAY_.BAT
ECHO.SET FNAME=%%5>>_TODAY_.BAT

:: Call _TEMP.BAT to get the remaining DIR listing parameter values now
:: for use in the Tutorial text
CALL _TEMP.BAT

:: Reset _TODAY_.BAT to the original file for display in the Tutorial
TYPE _TODAY_.BAT | find "SET C">_TODAY_.BAT

ECHO.
%COL% g @ "         "
%COL% n c " Tutorial for the INCEPT2.BAT Inception technique "
ECHO.
ECHO.
%COL% n @ " This tutorial explains how "
%COL% o d "INCEPT2.BAT"
%COL% n @ " loads the current Date and"
ECHO.
%COL% n @ " Time into environment variables. First we create a Batch workfile"
ECHO.
%COL% n @ " named "
%COL% o d "_TODAY_.BAT"
%COL% n @ " (using "
%COL% o d "_"
%COL% n @ "underscores"
%COL% o d "_"
%COL% n @ " in workfile names makes it"
ECHO.
%COL% n @ " unlikely they will conflict with other files in the same folder)."
ECHO.
ECHO.
%COL% n @ " The "
%COL% o d "_TODAY_.BAT"
%COL% n @ " workfile has two functions:"
ECHO.
%COL% j @ " (1) It will have current Date and Time as its creation date/time."
ECHO.
%COL% j @ " (2) It will have Batch commands that will retrieve the date/time."
ECHO.
ECHO.
%COL% n @ " If we generate a "
%COL% k @ "DIR"
%COL% n @ " listing for "
%COL% o d "_TODAY_.BAT"
%COL% n @ ", it looks like this:"
ECHO.
ECHO.
TYPE _TEMP.BAT
ECHO.
%COL% n @ " And these are the two commands the "
%COL% o d "_TODAY_.BAT"
%COL% n @ " workfile contains:"
ECHO.
ECHO.
TYPE _TODAY_.BAT
CALL %0 GOTO: _PAUSE

ECHO.
ECHO.
%COL% n @ " Consider that "
%COL% k @ "DIR"
%COL% n @ " listing in more detail, and especially note the"
ECHO.
%COL% n @ " positions of the items in the line. Let's mark those positions as"
ECHO.
%COL% n @ " if they are the command-line parameters used to run a Batch file:"
ECHO.
ECHO.
%COL% g @ "   "
%COL% f o "%%0"
%COL% g @ "    "
%COL% f o "%%1"
%COL% g @ "             "
%COL% f o "%%2"
%COL% g @ "     "
%COL% f o "%%3"
%COL% g @ "      "
%COL% f o "%%4"
%COL% g @ "       "
%COL% f o "%%5"
ECHO.
TYPE _TEMP.BAT
ECHO.
%COL% n @ " If we typed in that line of text it would execute our "
%COL% o d "_TODAY_.BAT"
ECHO.
%COL% n @ " temporary Batch file with its command line parameters as follows:"
ECHO.
ECHO.
%COL% n @ "  "
%COL% f o "%%0"
%COL% n @ "="
%COL% g @ "%INAME%"
%COL% n @ "        ("
%COL% f o "%%0"
%COL% n @ " holds name used to invoke "
%COL% o d "_TODAY_.BAT"
%COL% n @ ")"
ECHO.
%COL% n @ "  "
%COL% f o "%%1"
%COL% n @ "="
%COL% g @ "%EXT%"
%COL% n @ "            (the Extension - we can ignore this)"
ECHO.
%COL% n @ "  "
%COL% f o "%%2"
%COL% n @ "="
%COL% g @ "%FSIZE%"
%COL% n @ "             (the FileSize - we can ignore this)"
ECHO.
%COL% n @ "  "
%COL% f o "%%3"
%COL% n @ "="
ECHO.%CDATE%
%COL% n @ "  "
%COL% f o "%%4"
%COL% n @ "="
ECHO.%CTIME%
%COL% n @ "  "
%COL% f o "%%5"
%COL% n @ "="
%COL% g @ "%FNAME%"
%COL% n @ "    (the Name+Extension - we can ignore this)"
ECHO.
ECHO.
%COL% n @ " Note that the "
%COL% f o "%%3"
%COL% n @ " and "
%COL% f o "%%4"
%COL% n @ " parameters are the current Date and Time,"
ECHO.
%COL% n @ " so our workfile would be called with exactly those items we need."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " Remember that we have loaded "
%COL% o d "_TODAY_.BAT"
%COL% n @ " with these two commands:"
ECHO.
ECHO.
TYPE _TODAY_.BAT
ECHO.
%COL% n @ " so if we did run the text from the "
%COL% k @ "DIR"
%COL% n @ " listing as a command line:"
ECHO.
ECHO.
%COL% g @ "   "
%COL% f o "%%0"
%COL% g @ "    "
%COL% f o "%%1"
%COL% g @ "             "
%COL% f o "%%2"
%COL% g @ "     "
%COL% f o "%%3"
%COL% g @ "      "
%COL% f o "%%4"
%COL% g @ "       "
%COL% f o "%%5"
ECHO.
TYPE _TEMP.BAT
ECHO.
%COL% n @ " our "
%COL% o d "_TODAY_.BAT"
%COL% n @ " workfile will set "
%COL% m @ "CDATE"
%COL% n @ " and "
%COL% m @ "CTIME"
%COL% n @ " to its own date"
ECHO.
%COL% n @ " and time of creation. Since they're the current Date and Time, it"
ECHO.
%COL% n @ " will save the current Date and Time in two environment variables."
ECHO.
ECHO.
%COL% n @ " To execute that line of "
%COL% k @ "DIR"
%COL% n @ " text as if it were a command line, we"
ECHO.
%COL% n @ " will need to capture it into another workfile with "
%COL% k @ ">"
%COL% n @ " redirection."
ECHO.
ECHO.
%COL% n @ " We'll pipe it into a workfile called "
%COL% o d "_TEMP.BAT"
%COL% n @ ", and use this "
%COL% k @ "FIND"
ECHO.
%COL% n @ " pipe to filter out all the "
%COL% k @ "DIR"
%COL% n @ " list lines except the one we want:"
ECHO.
ECHO.
%COL% g @ " "
%COL% n d "DIR _TODAY_.BAT|find ""
%COL% g @ "_TODAY_"

:: Use [-] instead of " to start string since we need an odd number
:: of quotes in string to prevent > redirection operator from being
:: seen as an operator. The _COLOUR Subroutine just snips off the
:: first and last characters, it doesn't matter if they're not "quotes",
:: but "quotes" are usually the most convenient characters to use.
%COL% n d -">_TEMP.BAT "
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " Now "
%COL% o d "_TEMP.BAT"
%COL% n @ " holds that "
%COL% k @ "DIR"
%COL% n @ " output, including the Date and Time:"
ECHO.
ECHO.
TYPE _TEMP.BAT
ECHO.
%COL% n @ " so if we "
%COL% k @ "CALL "
%COL% o d "_TEMP.BAT"
%COL% n @ ", it will in turn run "
%COL% o d "_TODAY_.BAT"
%COL% n @ " with the"
ECHO.
%COL% n @ " parameters in the positions "
%COL% o d "_TODAY_.BAT"
%COL% n @ " uses to set both Date and"
ECHO.
%COL% n @ " Time variables:"
ECHO.
ECHO.
%COL% g @ "   "
%COL% f o "%%0"
%COL% g @ "    "
%COL% f o "%%1"
%COL% g @ "             "
%COL% f o "%%2"
%COL% g @ "     "
%COL% f o "%%3"
%COL% g @ "      "
%COL% f o "%%4"
%COL% g @ "       "
%COL% f o "%%5"
ECHO.
TYPE _TEMP.BAT
ECHO.
%COL% n @ " When "
%COL% o d "_TODAY_.BAT"
%COL% n @ " runs, its "
%COL% f o "%%3"
%COL% n @ " and "
%COL% f o "%%4"
%COL% n @ " parameters will each expand:"
ECHO.
ECHO.
ECHO. SET CDATE=%CDATE%
ECHO. SET CTIME=%CTIME%
ECHO.
%COL% n @ " as above, and the result is to set "
%COL% m @ "CDATE"
%COL% n @ " to the current Date, and"
ECHO.
%COL% n @ " to set "
%COL% m @ "CTIME"
%COL% n @ " to the current Time, and that's just what we wanted."
ECHO.
%COL% n @ " All that remains is to delete the workfiles and show the results."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " And with that done, we can display both current Date and the Time"
ECHO.
%COL% n @ " by expanding the variables "
%COL% m @ "%%CDATE%%"
%COL% n @ " and "
%COL% m @ "%%CTIME%%"
%COL% n @ ", in the usual way."
ECHO.
ECHO.
%COL% n @ " For example: "
%COL% m @ "%%CDATE%%"
%COL% n @ "="
%COL% o @ "%CDATE%"
%COL% n @ " and "
%COL% m @ "%%CTIME%%"
%COL% n @ "="
%COL% o @ "%CTIME%"
ECHO.
ECHO.
%COL% g @ " "
%COL% l o "Note"
%COL% k a " The variables for this Tutorial were extracted at the moment"
ECHO.
%COL% g @ " "
%COL% k a "you started, and the time shown above may be several minutes ago."
ECHO.
ECHO.
ECHO.
%COL% j @ "            We hope you found this Batch Tutorial useful"
ECHO.
ECHO.
%COL% g @ "                    "
%COL% n i " William and Linda Allen "
ECHO.
%COL% j @ "    "
%COL% o l "(c)"
%COL% n i " Copyright Allen & Company 2003 - all rights reserved "
%COL% o l "(c)"
ECHO.
ECHO.
ECHO.
ECHO.
:: Tidy up workfiles. Variables will clear as child shell closes.
FOR %%F IN (_TEMP.BAT _TODAY_.BAT %COL%) DO DEL %%F

GOTO EOF {=Subroutine-section-below=}
:: The _COLOUR Subroutine is documented in our Batch Study Pack 4
:: and the use of Batch Subroutines is documented in Study Pack 1
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

GOTO EOF {=Subroutine-section-below=}
:_PAUSE (Usage: CALL %0 GOTO: _PAUSE)
ECHO.
%COL% k a " Press [Return] to continue..."
ECHO.
PAUSE>NUL
CLS

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
