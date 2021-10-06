@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Tutorial for the standard _DTM Batch Subroutine, which extracts
:: date and time tokens from the Real Time Clock CMOS RAM into seven
:: environment variables. Each token is extracted as two digits.

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Recall self with standardized environment space
IF NOT (UseStandardizedEnv)==(%2) %COMSPEC% /e:4096 /c %0 _ UseStandardizedEnv
:: Finish after recall in child shell
IF NOT (UseStandardizedEnv)==(%2) GOTO EOF

:: Set up for using non-ANSI colour
CALL %0 GOTO: _COLOUR COL

:: Start with clear screen
CLS
ECHO.
%COL% g @ "      "
%COL% n c "Date and Time tokens for use in file and folder names"
ECHO.

:: Call the Subroutine (most of the Tutorial is included in it)
CALL %0 GOTO: _DTM
%COL% n @ " The result is seven current Date and Time variables "
%COL% k @ "SET"
%COL% n @ " as below:"
ECHO.
ECHO.
ECHO. C=%C% Y=%Y% MO=%MO% D=%D% H=%H% MI=%MI% S=%S%
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " These seven variables can be expanded in any combination, or with"
ECHO.
%COL% n @ " other text (such as Batch command lines) to create file names and"
ECHO.
%COL% n @ " folder names based on the current Date and Time. It can be useful"
ECHO.
%COL% n @ " to employ these names for repetitive tasks, where a new file name"
ECHO.
%COL% n @ " is needed each time a Batch file runs. Just expand the variables:"
ECHO.
ECHO.
%COL% n @ " "
%COL% m a "%%C%%"
%COL% k a "%%Y%%"
%COL% n @ "-"
%COL% l a "%%MO%%"
%COL% n @ "-"
%COL% j a "%%D%%"
%COL% n @ "  expands to: "
%COL% m a "%C%"
%COL% k a "%Y%"
%COL% n @ "-"
%COL% l a "%MO%"
%COL% n @ "-"
%COL% j a "%D%"
%COL% n @ "    (Date: Year-Month-Day)"
ECHO.
ECHO.
%COL% n @ " and "
%COL% n g "%%H%%"
%COL% n @ "-"
%COL% o g "%%MI%%"
%COL% n @ "-"
%COL% i g "%%S%%"
%COL% n @ " expands to: "
%COL% n g "%H%"
%COL% n @ "-"
%COL% o g "%MI%"
%COL% n @ "-"
%COL% i g "%S%"
%COL% n @ "  (Time: Hour-Minute-Second)"
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
:: Tidy up by clearing workfile. Variables clear as child shell terminates.
DEL %COL%

GOTO EOF {=Subroutine-section-below=}
:_DTM (Usage: CALL %0 GOTO: _DTM)
ECHO.e100 e8 0 0 80 c3 2 88 dc cd 1a 89 97 1e 1 89 8f 22 1 c3>%TEMP%.\_DT.BAT
FOR %%C IN (g d121L7 q) DO ECHO.%%C>>%TEMP%.\_DT.BAT
ECHO.
%COL% n @ " To retrieve the Date and Time data, a transient program is run in"
ECHO.
%COL% k @ " DEBUG"
%COL% n @ ", then erased. The program's output is filtered through "
%COL% k @ "FIND"
ECHO.
%COL% n @ " to extract the 7 date and time tokens. The program's source code,"
ECHO.
%COL% n @ " with comments and explanation, is in the accompanying "
%COL% o d "DATIME.TXT"
%COL% n @ "."
ECHO.
ECHO.
%COL% n @ " The filtered output of this program has a memory address followed"
ECHO.
%COL% n @ " by 7 tokens for the date and time elements, as shown in the line:"
ECHO.
ECHO.
TYPE %TEMP%.\_DT.BAT|debug|find ":">%TEMP%.\_DT.BAT
TYPE %TEMP%.\_DT.BAT
%COL% o g "(address)     S  D  Mo Mi H  Y  C                             ASCII "
ECHO.
ECHO.
%COL% n @ "Key:"
%COL% o g "S "
%COL% n @ "=Second"
ECHO.
%COL% n @ "    "
%COL% o g "D "
%COL% n @ "=Day"
ECHO.
%COL% n @ "    "
%COL% o g "Mo"
%COL% n @ "=Month                                "
%COL% j @ "This order is the most"
ECHO.
%COL% n @ "    "
%COL% o g "Mi"
%COL% n @ "=Minute                               "
%COL% j @ "efficient one in which"
ECHO.
%COL% n @ "    "
%COL% o g "H "
%COL% n @ "=Hour                                 "
%COL% j @ "to extract the tokens."
ECHO.
%COL% n @ "    "
%COL% o g "Y "
%COL% n @ "=Year"
ECHO.
%COL% n @ "    "
%COL% o g "C "
%COL% n @ "=Century"
ECHO.
%COL% n @ "    "
%COL% o g "ASCII"
%COL% n @ "="
%COL% k @ "DEBUG"
%COL% n @ "'s ASCII rendering of the Date and Time data bytes."
ECHO.
CALL %0 GOTO: _PAUSE

:: Trim the final ASCII tail off the worfile for display purposes,
:: since we can ignore it
ECHO.e122 d a>%TEMP%.\_DT1.BAT
FOR %%C IN (rcx 24 w q) DO ECHO.%%C>>%TEMP%.\_DT1.BAT
TYPE %TEMP%.\_DT1.BAT|debug %TEMP%.\_DT.BAT>NUL
ECHO.
%COL% n @ " A second "
%COL% k @ "DEBUG"
%COL% n @ " script is used to overwrite the initial characters"
ECHO.
%COL% n @ " of the output. This is done to make it easier to extract the date"
ECHO.
%COL% n @ " and time tokens from the output. In what follows, we have omitted"
ECHO.
%COL% n @ " the ASCII tail of the original "
%COL% k @ "DEBUG"
%COL% n @ " output (it is not relevant)."
ECHO.
ECHO.
%COL% n @ " After this "
%COL% k @ "DEBUG"
%COL% n @ " editing process is over, the original text line:"
ECHO.
ECHO.
TYPE %TEMP%.\_DT.BAT
ECHO.
%COL% n @ " becomes:"
ECHO.
ECHO.

:: Edit the _DT.BAT file on-the-fly and trim off the ASCII tail
ECHO.e100'%%1'20'%%2'20'%%3'20>%TEMP%.\_DT1.BAT
FOR %%C IN (w q) DO ECHO.%%C>>%TEMP%.\_DT1.BAT
TYPE %TEMP%.\_DT1.BAT|debug %TEMP%.\_DT.BAT>NUL
TYPE %TEMP%.\_DT.BAT
ECHO.
%COL% n @ " This new version of the output is redirected to a temporary Batch"
ECHO.
%COL% n @ " file "
%COL% o d "_DT.BAT"
%COL% n @ " in the "
%COL% k @ "TEMP"
%COL% n @ " folder. When we run this file, the three"
ECHO.
%COL% n @ " symbols, "
%COL% f o "%%1"
%COL% n @ ", "
%COL% f o "%%2"
%COL% n @ " and "
%COL% f o "%%3"
%COL% n @ " will be replaced by whatever three command"
ECHO.
%COL% n @ " line parameters we want. We make them recall the "
%COL% n d "_DTM"
%COL% n @ " Subroutine."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " Let's consider this rework of the date and time output carefully:"
ECHO.
ECHO.
TYPE %TEMP%.\_DT.BAT
%COL% m @ " |  |  |"
ECHO.
%COL% m @ " |  |  \"
%COL% n @ "We'll replace this parameter with the Subroutine ID, "
%COL% n d "1_DTM"
ECHO.
%COL% m @ " |  |"
ECHO.
%COL% m @ " |  \"
%COL% n @ "We'll replace this parameter with a Subroutine pointer, "
%COL% n d "GOTO:"
ECHO.
%COL% m @ " |"
ECHO.
%COL% m @ " \"
%COL% n @ "We'll replace this parameter with the parent Batch file name, "
%COL% f o "%%0"
ECHO.
ECHO.
%COL% n @ " Remember, the "
%COL% f o "%%0"
%COL% n @ " symbol holds the name needed to call the current"
ECHO.
%COL% n @ " Batch file. As a result,  the "
%COL% o d "_DT.BAT"
%COL% n @ " file recalls the main Batch"
ECHO.
%COL% n @ " file with current dates and times in its command-line parameters."
ECHO.
ECHO.
%COL% n @ " To achieve it, the "
%COL% o d "_DT.BAT"
%COL% n @ " Batch command line needs to look like:"
ECHO.
ECHO.
ECHO.CALL %%TEMP%%.\_DT.BAT %%0 GOTO: 1_DTM
%COL% j @ " Parameters become:  "
%COL% f o "%%1"
%COL% n @ "  "
%COL% f o "%%2"
%COL% n @ "    "
%COL% f o "%%3"
%COL% j @ "  (when they are used in "
%COL% o d "_DT.BAT"
%COL% j @ ")"
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " This is not easy to follow, so let's review all the stages again:"
ECHO.
ECHO.
%COL% n @ " From the "
%COL% m @ "parent"
%COL% n @ " Batch file, we've created the "
%COL% m @ "child "
%COL% o d "_DT.BAT"
%COL% n @ " file:"
ECHO.
ECHO.
TYPE %TEMP%.\_DT.BAT
ECHO.
%COL% n @ " And we call it from the "
%COL% m @ "parent"
%COL% n @ " Batch file with this command-line:"
ECHO.
ECHO.
ECHO.CALL %%TEMP%%.\_DT.BAT %%0 GOTO: 1_DTM
%COL% j @ " Parameters become:  "
%COL% f o "%%1"
%COL% n @ "  "
%COL% f o "%%2"
%COL% n @ "    "
%COL% f o "%%3"
%COL% j @ "  (when they are used in "
%COL% o d "_DT.BAT"
%COL% j @ ")"
ECHO.
ECHO.
%COL% n @ " And when we run it in this way, our "
%COL% o d "_DT.BAT"
%COL% n @ " temporary Batch file:"
ECHO.
ECHO.
TYPE %TEMP%.\_DT.BAT
ECHO.
%COL% n @ " expands to this (which shows parameter positions in "
%COL% m @ "parent"
%COL% n @ " file):"
ECHO.
ECHO.
CALL %TEMP%.\_DT.BAT ECHO.ParentBatchFileName GOTO: 1_DTM
%COL% j @ " Parameters become:  "
%COL% f o "%%1"
%COL% n @ "    "
%COL% f o "%%2"
%COL% n @ "        "
%COL% f o "%%3"
%COL% n @ " "
%COL% f o "%%4"
%COL% n @ " "
%COL% f o "%%5"
%COL% n @ " "
%COL% f o "%%6"
%COL% n @ " "
%COL% f o "%%7"
%COL% n @ " "
%COL% f o "%%8"
%COL% n @ " "
%COL% f o "%%9"
ECHO.
%COL% j @ "                     (when these parameters are re-used in "
%COL% m @ "parent"
%COL% n @ ")"
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " Let's recap that last stage in which the "
%COL% m @ "child"
%COL% n @ " Batch file "
%COL% o d "_DT.BAT"
ECHO.
%COL% n @ " calls that "
%COL% n d "1_DTM"
%COL% n @ " stage of the "
%COL% n d "_DTM"
%COL% n @ " Subroutine in its "
%COL% m @ "parent"
%COL% n @ " file:"
ECHO.
ECHO.
CALL %TEMP%.\_DT.BAT ECHO.ParentBatchFileName GOTO: 1_DTM
%COL% j @ " Remember, Date and Time token key:  "
%COL% o g "S "
%COL% j @ " "
%COL% o g "D "
%COL% j @ " "
%COL% o g "Mo"
%COL% j @ " "
%COL% o g "Mi"
%COL% j @ " "
%COL% o g "H "
%COL% j @ " "
%COL% o g "Y "
%COL% j @ " "
%COL% o g "C "
ECHO.
%COL% j @ " Parameters become:  "
%COL% f o "%%1"
%COL% n @ "    "
%COL% f o "%%2"
%COL% n @ "        "
%COL% f o "%%3"
%COL% n @ " "
%COL% f o "%%4"
%COL% n @ " "
%COL% f o "%%5"
%COL% n @ " "
%COL% f o "%%6"
%COL% n @ " "
%COL% f o "%%7"
%COL% n @ " "
%COL% f o "%%8"
%COL% n @ " "
%COL% f o "%%9"
ECHO.
%COL% j @ "              (when all of these parameters are re-used in "
%COL% m @ "parent"
%COL% n @ ")"
ECHO.
ECHO.
%COL% n @ " This calls the second part of the "
%COL% n d "_DTM"
%COL% n @ " Subroutine at label "
%COL% n d "1_DTM"
%COL% n @ "."
ECHO.
ECHO.
%COL% n @ " This "
%COL% n d "1_DTM"
%COL% n @ " code section loads all those in a "
%COL% k @ "FOR IN DO"
%COL% n @ " statement:"
ECHO.
ECHO.
%COL% n d "FOR %%%%V IN ("H=%%7" "MI=%%6" "S=%%3" "C=%%9" "Y=%%8" "MO=%%5" "D=%%4") DO SET %%%%V"
ECHO.
ECHO.
CALL %TEMP%.\_DT.BAT %0 GOTO: 1_DTM
DEL %TEMP%.\_DT.BAT
DEL %TEMP%.\_DT1.BAT

GOTO EOF
:1_DTM
FOR %%V IN ("H=%7" "MI=%6" "S=%3" "C=%9" "Y=%8" "MO=%5" "D=%4") DO SET %%V

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

GOTO EOF {=Subroutine-section-below=}
:_PAUSE
ECHO.
%COL% k a " Press [Return] to continue..."
ECHO.
PAUSE>NUL
CLS

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
