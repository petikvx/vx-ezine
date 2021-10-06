@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}
:: Tutorial for the FC /LB1 CON NUL Batch input technique

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
%COL% g @ "       "
%COL% n c " Explanation of the "
%COL% o c "fc /lb1"
%COL% n c " technique for User Input "
ECHO.
ECHO.
%COL% n @ " The main command line to study is the "
%COL% k @ "FC"
%COL% n @ " command: "
%COL% n d "fc /lb1 CON NUL"
ECHO.
%COL% n @ " which compares input from "
%COL% k @ "CON"
%COL% n @ " (the Keyboard) with the "
%COL% k @ "NUL"
%COL% n @ " device."
ECHO.
%COL% n @ " The "
%COL% n d "/lb1"
%COL% n @ " switch says: stop comparing after a single line fails to"
ECHO.
%COL% n @ " match. Since we are comparing with "
%COL% k @ "NUL"
%COL% n @ " (it contains nothing), the"
ECHO.
%COL% n @ " first line is a mismatch. And so "
%COL% k @ "FC"
%COL% n @ " reads no further input lines."
ECHO.
ECHO.
%COL% n @ " We'll execute that command line now. It will display the message:"
ECHO.
%COL% j @ " Comparing files CON and NUL"
%COL% n @ ". Type your name, then press [Return]:"
ECHO.
ECHO.
fc /lb1 CON NUL
%COL% k @ " FC"
%COL% n @ " can't resychronize, but the input appears again "
%COL% l @ "in the output"
%COL% n @ "."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " Now we'll use that command line again but this time we'll capture"
ECHO.
%COL% n @ " the output with redirection, thus "
%COL% n d "fc /lb1 CON NUL>%%TEMP%%.\_IN.BAT"
ECHO.
%COL% n @ " This captures output to the file: "
%COL% o d "_IN.BAT"
%COL% n @ ", in your "
%COL% k @ "%%TEMP%%"
%COL% n @ " folder,"
ECHO.
%COL% n @ " so you see no "
%COL% j @ "Comparing files CON and NUL"
%COL% n @ " message. Type your name"
ECHO.
%COL% n @ " as you did before, and press [Return]:"
ECHO.
fc /lb1 CON NUL>%TEMP%.\_IN.BAT
ECHO.
%COL% n @ " This time you saw no error report because it's sent to "
%COL% k @ "STDOUT"
%COL% n @ " and"
ECHO.
%COL% n @ " was captured by redirection to the file "
%COL% o d "_IN.BAT"
%COL% n @ " and this contains"
ECHO.
%COL% n @ " the result. If we "
%COL% k @ "TYPE"
%COL% n @ " the file we see what we've captured, thus:"
ECHO.
ECHO.
TYPE %TEMP%.\_IN.BAT
%COL% n @ " Amidst "
%COL% k @ "FC"
%COL% n @ "'s messages, there is your input. We need to extract it."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " We can filter "
%COL% o d "_IN.BAT"
%COL% n @ " through "
%COL% k @ "FIND /"
%COL% j @ "n"
%COL% n @ " and "
%COL% j @ "n"
%COL% n @ "umber the lines, with:"
ECHO.
%COL% g @ " "
%COL% n d "TYPE %%TEMP%%.\_IN.BAT | find /"
%COL% j d "n"
%COL% n d " /v """
%COL% n @ " (the "
%COL% n d "/v """
%COL% n @ " means exclude all"
ECHO.
%COL% n @ " lines that aren't null = include all lines). The "
%COL% m @ "v"
%COL% n @ " comes from the"
ECHO.
%COL% m @ " v"
%COL% n @ " in in"
%COL% m @ "v"
%COL% n @ "ert the logic, in case you were wondering why it is used."
ECHO.
ECHO.
%COL% n @ " The result is:"
ECHO.
ECHO.
TYPE %TEMP%.\_IN.BAT | find /n /v ""
ECHO.
%COL% n @ " Notice your input is the "
%COL% j @ "4th"
%COL% n @ " line. We can use "
%COL% j @ ""[4]""
%COL% n @ " to filter it."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " We need to "
%COL% k @ "pipe "
%COL% o d "_IN.BAT"
%COL% n @ " through "
%COL% k @ "FIND"
%COL% n @ " twice, first to "
%COL% j @ "n"
%COL% n @ "umber lines"
ECHO.
%COL% n @ " and second to exclude all lines but the "
%COL% j @ "4th"
%COL% n @ ", which has the input."
ECHO.
ECHO.
%COL% n @ " We use "
%COL% n d "TYPE %%TEMP%%.\_IN.BAT | find /"
%COL% j d "n"
%COL% n d " /v "" | find "
%COL% j d ""[4]""
%COL% n @ " to give:"
ECHO.
ECHO.
TYPE %TEMP%.\_IN.BAT | find /n /v "" | find "[4]"
ECHO.
%COL% n @ " Your input line is now the only line that's left. It contains the"
ECHO.
%COL% n @ " line number "
%COL% j @ "[4]"
%COL% n @ " (which we don't want), and we'd like to place the"
ECHO.
%COL% n @ " input in a variable. To do this we need to replace the "
%COL% j @ "[4]"
%COL% n @ " with a"
ECHO.
%COL% k @ " SET"
%COL% n @ " command, then execute the result, as if it were a Batch file."
ECHO.
ECHO.
%COL% n @ " The ideal format is to have the input prefixed with "
%COL% m @ "SET %%1="
%COL% n @ " thus:"
ECHO.

:: We'll grab the input now, so we can refer to it
TYPE %TEMP%.\_IN.BAT | find /n /v "" | find "[4]"|more|more>%TEMP%.\_IN.BAT
:: Use small Debug script to place SET %1= prefix at start of input
ECHO.e100'SET %%1='>%TEMP%.\_IN
FOR %%C IN (w q) DO ECHO.%%C>>%TEMP%.\_IN
debug %TEMP%.\_IN.BAT<%TEMP%.\_IN>NUL
:: Grab the input
CALL %TEMP%.\_IN.BAT INPUT

ECHO.
%COL% m @ "SET %%1="
:: We use COL here instead of ECHO. in case there's a ? or * in the input
:: since we can't leave a [Space] between ECHO. and the %INPUT%
%COL% g @ "%INPUT%"
ECHO.
ECHO.
%COL% n @ " When that is executed as a Batch file then whatever "
%COL% m @ "variable"
%COL% n @ " name"
ECHO.
%COL% n @ " is in the "
%COL% m @ "first parameter"
%COL% n @ " position will be loaded with the input."
ECHO.

CALL %0 GOTO: _PAUSE
ECHO.
%COL% n @ " So far we've seen how to get this output line from an "
%COL% k @ "FC"
%COL% n @ " command:"
ECHO.
ECHO.
%COL% m i "[4]"
ECHO.%INPUT%
ECHO.
%COL% n @ " It has our input, together with those three extra characters: "
%COL% m i "[4]"
ECHO.
ECHO.
%COL% n @ " And as we've said, ideally, we want the output to look like this:"
ECHO.
ECHO.
%COL% m i "SET %%1="
ECHO.%INPUT%
ECHO.
%COL% n @ " which has seven extra characters: "
%COL% m i "SET %%1="
%COL% n @ " four more than we have."
ECHO.
ECHO.
%COL% n @ " We can use "
%COL% k @ "DEBUG"
%COL% n @ " to overwrite characters in the file. It's easier"
ECHO.
%COL% n @ " to do this if we're overwriting "
%COL% l @ "seven"
%COL% n @ " characters with "
%COL% l @ "seven"
%COL% n @ " other"
ECHO.
%COL% n @ " characters. We need to prefix four extra characters on the front."
ECHO.
ECHO.
%COL% n @ " We can do this by piping the file through the "
%COL% k @ "MORE"
%COL% n @ " command, which"
ECHO.
%COL% n @ " has the side effect of prefixing a file with a CarriageReturn and"
ECHO.
%COL% n @ " a Linefeed each time it's "
%COL% k @ "pipe"
%COL% n @ "d through. So we'll use "
%COL% k @ "MORE"
%COL% n @ " twice."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " We can get the input, number lines, and add those four characters"
ECHO.
%COL% n @ " with a single multi-stage "
%COL% k @ "pipe"
%COL% n @ " command line. The command line is:"
ECHO.
ECHO.
%COL% n d "fc /lb1 CON NUL|find /n /v ""|find "[4]"|more|more"
ECHO.
ECHO.
%COL% n @ " Let's review how this complex line does the whole job. This part:"
ECHO.
ECHO.
%COL% n d "fc /lb1 CON NUL|find /n /v ""|find "[4]""
%COL% n @ " produces:"
ECHO.
ECHO.
ECHO.[4]%INPUT%
ECHO.
%COL% n @ " This pair of "
%COL% k @ "MORE pipe"
%COL% n @ "s: "
%COL% n d "|more|more"
%COL% n @ " adds four characters to give:"
ECHO.
%COL% o g "C"
%COL% @ o "L"
%COL% o g "C"
%COL% @ o "L"
ECHO.[4]%INPUT%
ECHO.
%COL% n @ " Where: "
%COL% o g "C"
%COL% n @ " = CarriageReturn (ASCII 13), and "
%COL% @ o "L"
%COL% n @ " = LineFeed (ASCII 10)"
ECHO.
%COL% n @ " We'll overwrite the first seven characters, so it's not important"
ECHO.
%COL% n @ " what they are. Our file just needs that precise amount of "
%COL% g a "padding"
ECHO.
%COL% n @ " so that we do not need to change its length when we overwrite it:"
ECHO.
ECHO.
%COL% o g "C"
%COL% @ o "L"
%COL% o g "C"
%COL% @ o "L"
%COL% g a "[4]"
%COL% g @ "%INPUT%"
%COL% n @ "                      ("
%COL% l @ "before"
%COL% k @ " DEBUG"
%COL% n @ " overwrite)"
ECHO.
%COL% g a "SET %%1="
%COL% g @ "%INPUT%"
%COL% n @ "       (what we'll have "
%COL% l @ "after"
%COL% k @ " DEBUG"
%COL% n @ " overwrite)"
ECHO.
CALL %0 GOTO: _PAUSE
ECHO.
%COL% n @ " We finish off with the "
%COL% k @ "DEBUG"
%COL% n @ " script, to overwrite the first seven"
ECHO.
%COL% n @ " characters to make a transient Batch file. The script looks like:"
ECHO.
ECHO.
%COL% n d "e100'"
%COL% g a "SET %%1="
%COL% n d "'"
%COL% n @ "   ("
%COL% n d "e100"
%COL% n @ "=Enter "
%COL% g a "string"
%COL% n @ " from start="
%COL% n d "100"
%COL% n @ " of memory)"
ECHO.
%COL% n d "w"
%COL% n @ "               ("
%COL% n d "w"
%COL% n @ "rite the file)"
ECHO.
%COL% n d "q"
%COL% n @ "               ("
%COL% n d "q"
%COL% n @ "uit "
%COL% k @ "DEBUG"
%COL% n @ ")"
ECHO.
ECHO.
%COL% n @ " and it's built in "
%COL% l @ "another"
%COL% n @ " temporary file, "
%COL% o d "_IN"
%COL% n @ ", in the "
%COL% k @ "TEMP"
%COL% n @ " folder"
ECHO.
%COL% n @ " and executed by the three lines shown below (remember, to"
%COL% k @ " ECHO "
%COL% g a "%%1"
ECHO.
%COL% n @ " literally to a "
%COL% k @ "DEBUG"
%COL% n @ " script, we need to use "
%COL% g a "%%%%1"
%COL% n @ " in a Batch file):"
ECHO.
ECHO.
%COL% n d "ECHO.e100'SET %%%%1='>%%TEMP%%.\_IN"
ECHO.
%COL% n d "FOR %%%%C IN (w q) DO ECHO.%%%%C>>%%TEMP%%.\_IN"
ECHO.
%COL% n d "debug %%TEMP%%.\_IN.BAT<%%TEMP%%.\_IN>NUL"
ECHO.
CALL %0 GOTO: _PAUSE
ECHO.
%COL% n @ " After that "
%COL% k @ "DEBUG"
%COL% n @ " operation, our output file, "
%COL% o d "_IN.BAT"
%COL% n @ ", looks like:"
ECHO.
ECHO.
ECHO.SET %%1=%INPUT%
ECHO.
%COL% n @ " We use: "
%COL% n d "CALL %%TEMP%%.\_IN.BAT INPUT"
%COL% n @ " which "
%COL% k @ "SET"
%COL% n @ "s the "
%COL% m @ "INPUT"
%COL% n @ " variable."
ECHO.
ECHO.
%COL% n @ " As a result, your input is stored in "
%COL% m @ "INPUT"
%COL% n @ " = "
%COL% o @ "%INPUT%"
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

:: Tidy up by deleting workfiles
FOR %%F IN (_IN.BAT _IN _COL.COM) DO DEL %TEMP%.\%%F

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
