@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Recall with standardized environment space
IF NOT (UseStandardizedEnv)==(%2) %COMSPEC% /e:4096 /c %0 _ UseStandardizedEnv
IF NOT (UseStandardizedEnv)==(%2) GOTO EOF

:: Set up for non-ANSI colour
CALL %0 GOTO: _COLOUR COL

:: Initialise working variables
FOR %%V IN (CL CL1 RESUME) DO SET %%V=

:: Use Universal Prefix to load current prompt in variable PR
ECHO. @PROMPT e0'SET PR='$_rcx$_7$_w0$_q>%TEMP%.\_P.BAT
%COMSPEC% /e:4096 /c %TEMP%.\_P.BAT | debug %TEMP%.\_P.BAT>NUL
CD>>%TEMP%.\_P.BAT
FOR %%C IN (CALL DEL) DO %%C %TEMP%.\_P.BAT

:: Start with clear screen
CLS
ECHO.
%COL% g @ "     "
%COL% n c "Tutorial for "
%COL% o c "SUBDEM1.BAT"
%COL% n c " (simple use of Batch Subroutines)"
ECHO.
ECHO.
%COL% n @ " This Tutorial walks you through the code in "
%COL% o d "SUBDEM1.BAT"
%COL% n @ ", which is"
ECHO.
%COL% n @ " a simple example of how to use Batch Subroutines. The "
%COL% o d "SUBDEM1.BAT"
ECHO.
%COL% n @ " example code has a single Subroutine ("
%COL% o c "_SUBR"
%COL% n @ ") and looks like this:"
ECHO.
CALL %0 GOTO: _CODE
ECHO.
%COL% n @ " This Tutorial takes you through a simulated run of the code above"
ECHO.
%COL% n @ " and shows what's happening at each stage and what each line does."
ECHO.
CALL %0 GOTO: _PAUSE

ECHO.
%COL% n @ " A Batch Subroutine is not part of the main Batch code. To use it,"
ECHO.
%COL% n @ " the Batch file must recall itself. Remember, Batch files can call"
ECHO.
%COL% n @ " themselves by using the name they were called with (which Windows"
ECHO.
%COL% n @ " stores in the "
%COL% f o "%%0"
%COL% n @ " parameter). So we'll see the "
%COL% f o "%%0"
%COL% n @ " used frequently."
ECHO.
ECHO.
%COL% n @ " A Batch file can't just recall itself without some code to handle"
ECHO.
%COL% n @ " the recall. If the recall is not handled properly, the code would"
ECHO.
%COL% n @ " just loop endlessly. That's why our "
%COL% o c "Subroutine-Handler"
%COL% n @ " is needed."
ECHO.
ECHO.
%COL% n @ " Let's suppose "
%COL% o d "SUBDEM1.BAT"
%COL% n @ " is now executed with this command line:"
ECHO.
ECHO.
:: Set primary command line in CL
SET CL="%PR%>subdem1.bat MainOne MainTwo "
%COL% @ g %CL%
ECHO.
ECHO.
%COL% n @ " so it will start with these two parameters: "
%COL% f o "%%1"
%COL% n @ "="
%COL% @ g "MainOne"
%COL% n @ " "
%COL% f o "%%2"
%COL% n @ "="
%COL% @ g "MainTwo"
ECHO.
%COL% n @ " (and remember, "
%COL% f o "%%0"
%COL% n @ "="
%COL% @ g "subdem1.bat"
%COL% n @ " will store its own name for recall)"
ECHO.
ECHO.
%COL% n @ " In what follows we look at each line of code "
%COL% n d "highlighted"
%COL% n @ " in turn."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 0
ECHO.
%COL% n @ " This line turns off "
%COL% k @ "ECHO"
%COL% n @ "ing of any following commands. By default"
ECHO.
%COL% n @ " each line of a Batch file "
%COL% k @ "ECHO"
%COL% n @ "es before it's executed. While this"
ECHO.
%COL% n @ " is handy for diagnostic work, in a normal run of a Batch file you"
ECHO.
%COL% n @ " don't want to see commands "
%COL% k @ "ECHO"
%COL% n @ "ed. The "
%COL% k @ "@"
%COL% n @ " prefix turns off "
%COL% k @ "ECHO"
%COL% n @ "ing"
ECHO.
%COL% n @ " of the current line and therefore prevents "
%COL% n d "ECHO OFF"
%COL% n @ " from "
%COL% k @ "ECHO"
%COL% n @ "ing."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 1
ECHO.

%COL% n @ " This line handles all Subroutine calls: "
%COL% n d "{Subroutine-Handler}"
%COL% n @ " is a"
ECHO.
%COL% k @ " comment"
%COL% n @ " to explain this. We have just started and so this isn't a"
ECHO.
%COL% n @ " Subroutine call. Let's see how it acts: "
%COL% f o "%%1"
%COL% n @ "="
%COL% @ g "MainOne"
%COL% n @ " and "
%COL% f o "%%2"
%COL% n @ "="
%COL% @ g "MainTwo"
ECHO.
%COL% n @ " so it expands to: "
%COL% n d "IF (GOTO:)==(MainOne) MainOneMainTwo"
%COL% n @ " (we ignore"
ECHO.
%COL% n @ " the "
%COL% k @ "comment"
%COL% n @ " part). The line does nothing at this time because the"
ECHO.
%COL% k @ " IF"
%COL% n @ " test "
%COL% n d "(GOTO:)==(MainOne)"
%COL% n @ " is "
%COL% l @ "FALSE"
%COL% n @ ". This is what we want because"
ECHO.
%COL% n @ " we're not calling a Subroutine (when we are, things will change)."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 2
ECHO.
%COL% n @ " This line "
%COL% k @ "ECHO"
%COL% n @ "es a message to show we're in the main code section"
ECHO.
%COL% n @ " at the moment. To follow what's happening in Batch code that uses"
ECHO.
%COL% n @ " Subroutine calls, we need messages that show where the logic flow"
ECHO.
%COL% n @ " is going. The code lines do "
%COL% l @ "not"
%COL% n @ " run in the order they are listed."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 3
ECHO.
%COL% n @ " Remember, the name used to start the Batch file is in "
%COL% f o "%%0"
%COL% n @ ". In this"
ECHO.
%COL% n @ " simulation, "
%COL% f o "%%0"
%COL% n @ " would be "
%COL% @ g "subdem1.bat"
%COL% n @ ", so the "
%COL% k @ "CALL"
%COL% n @ " line expands to:"
ECHO.
%COL% n d " CALL subdem1.bat GOTO: _SUBR SubParOne SubParTwo"
ECHO.
%COL% n @ " and the Batch file recalls itself (which is the Subroutine call)."
ECHO.
%COL% n @ " In this recall: "
%COL% f o "%%0"
%COL% n @ "="
%COL% @ g "subdem1.bat"
%COL% j @ "  (as before since it calls itself)"
ECHO.
%COL% n @ "                 "
%COL% f o "%%1"
%COL% n @ "="
%COL% @ g "GOTO:"
%COL% j @ "        (flag denoting a Subroutine call)"
ECHO.
%COL% n @ "                 "
%COL% f o "%%2"
%COL% n @ "="
%COL% @ g "_SUBR"
%COL% j @ "        (the Subroutine Identifier or ID)"
ECHO.
%COL% n @ "                 "
%COL% f o "%%3"
%COL% n @ "="
%COL% @ g "SubParOne"
%COL% n @ " and "
%COL% f o "%%4"
%COL% n @ "="
%COL% @ g "SubParTwo"
%COL% j @ "    (new parameters)"
ECHO.
CALL %0 GOTO: _PAUSE

:: Set secondary command line for _CODE Subroutine
SET CL1="CALL subdem1.bat GOTO: _SUBR SubParOne SubParTwo"
SET RESUME=YES
CALL %0 GOTO: _CODE 0
ECHO.
%COL% n @ " While we're in the Subroutine, we'll show that "
%COL% k @ "CALL"
%COL% n @ " line "
%COL% o g "expanded"
ECHO.
%COL% n @ " above the "
%COL% o d "SUBDEM1.BAT"
%COL% n @ " code as a reminder of the parameters in it."
ECHO.
ECHO.
%COL% n @ " The Subroutine "
%COL% k @ "CALL"
%COL% l @ " restarts"
%COL% n @ " the Batch code, and when this recall"
ECHO.
%COL% n @ " finishes, flow will "
%COL% j @ "resume"
%COL% n @ " at the line "
%COL% l @ "after"
%COL% n @ " the Subroutine "
%COL% k @ "CALL"
%COL% n @ "."
ECHO.
ECHO.
%COL% k @ " ECHO"
%COL% n @ "ing is already "
%COL% k @ "OFF"
%COL% n @ ","
%COL% n @ " so running "
%COL% n d "@ECHO OFF"
%COL% n @ " again has no effect."
ECHO.
SET RESUME=
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 1
ECHO.
%COL% n @ " In this Subroutine recall, "
%COL% f o "%%1"
%COL% n @ "="
%COL% @ g "GOTO:"
%COL% n @ " and "
%COL% f o "%%2"
%COL% n @ "="
%COL% @ g "_SUBR"
%COL% n @ ", and the special"
ECHO.
%COL% n @ " "
%COL% o c "Subroutine-Handler"
%COL% n @ " line expands to "
%COL% n d "IF (GOTO:)==(GOTO:) GOTO:_SUBR"
ECHO.
ECHO.
%COL% n @ " The "
%COL% k @ "IF"
%COL% n @ " test "
%COL% n d "(GOTO:)==(GOTO:)"
%COL% n @ " is "
%COL% j @ "TRUE"
%COL% n @ ", and so the jump, "
%COL% n d "GOTO:_SUBR"
ECHO.
%COL% n @ " is executed. The "
%COL% @ g ":"
%COL% n @ " (colon) after "
%COL% @ g "GOTO"
%COL% n @ " separates it from the "
%COL% @ g "_SUBR"
ECHO.
%COL% n @ " exactly as a "
%COL% o @ "[Space]"
%COL% n @ " would. The "
%COL% k @ "comment"
%COL% n @ " text "
%COL% n d "{Subroutine-Handler}"
ECHO.
%COL% n @ " is ignored by Windows (it merely reminds you what the line does)."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 7
ECHO.
%COL% n @ " Since, this time around, the "
%COL% o c "Subroutine-Handler"
%COL% n @ " line expanded to:"
ECHO.
%COL% o c "  IF (GOTO:)==(GOTO:) GOTO:_SUBR"
ECHO.
ECHO.
%COL% n @ " the jump "
%COL% o c "GOTO:_SUBR"
%COL% n @ " is executed. So, we've jumped straight to the"
ECHO.
%COL% n @ " label "
%COL% n d "_SUBR"
%COL% n @ " (the Subroutine's ID) in the Subroutine code section."
ECHO.
%COL% n @ " Our "
%COL% o c "Subroutine-Handler"
%COL% n @ " line routes all such Subroutine recalls to"
ECHO.
%COL% n @ " the right code: it's the "
%COL% l @ "key"
%COL% n @ " to using Subroutines in Batch files."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 8
ECHO.
%COL% n @ " We "
%COL% k @ "ECHO"
%COL% n @ " a message to show we are now in the "
%COL% o c "_SUBR"
%COL% n @ " Subroutine, and"
ECHO.
%COL% n @ " we're now running the Subroutine code. We indent the "
%COL% k @ "ECHO"
%COL% n @ " message"
ECHO.
%COL% n @ " by extra "
%COL% o @ "[Space]s"
%COL% n @ " so, when "
%COL% o d "SUBDEM1.BAT"
%COL% n @ " runs, the indenting of the"
ECHO.
%COL% n @ " messages shows the way the Subroutine is nested in the main code."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 9
ECHO.
%COL% n @ " This "
%COL% k @ "ECHO"
%COL% n @ " line expands to:"
%COL% n d "  ECHO.   %%3 Parameter passed=SubParOne"
ECHO.
ECHO.
%COL% n @ " Remember, "
%COL% f o "%%%%3"
%COL% n @ " is the way to "
%COL% k @ "ECHO"
%COL% n @ " "
%COL% f o "%%3"
%COL% n @ " literally. In the Subroutine,"
ECHO.
%COL% n @ " the parameters "
%COL% f o "%%1"
%COL% n @ " and "
%COL% f o "%%2"
%COL% n @ " are used for the Subroutine call itself,"
ECHO.
%COL% n @ " so the first useful parameter passed to the Subroutine is held in"
ECHO.
%COL% n @ " the "
%COL% f o "%%3"
%COL% n @ " position. Other parameters are passed in "
%COL% f o "%%4"
%COL% n @ ", "
%COL% f o "%%5"
%COL% n @ " and so on."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE a
ECHO.
%COL% n @ " This "
%COL% k @ "ECHO"
%COL% n @ " line expands to:"
%COL% n d "  ECHO.   %%4 Parameter passed=SubParOne"
ECHO.
ECHO.
%COL% n @ " Again, "
%COL% f o "%%%%4"
%COL% n @ " is the way to "
%COL% k @ "ECHO"
%COL% n @ " "
%COL% f o "%%4"
%COL% n @ " literally. Whenever a pair of "
%COL% f o "%%%%"
ECHO.
%COL% n @ " symbols is parsed in a command line, they are reduced to just one"
ECHO.
%COL% n @ " "
%COL% f o "%%"
%COL% n @ " symbol. Sometimes, lines are parsed several times, such as when"
ECHO.
%COL% n @ " creating temporary Batch workfiles, so you may see many "
%COL% f o "%%"
%COL% n @ "'s used."
ECHO.
CALL %0 GOTO: _PAUSE

:: Flag for "resume" comment
SET RESUME=YES
CALL %0 GOTO: _CODE b
ECHO.
%COL% n @ " This is our standard "
%COL% o c "End-of-file"
%COL% n @ " label, which comes at the end of"
ECHO.
%COL% n @ " all our Batch files that use Subroutines. We'll see how the label"
ECHO.
%COL% n @ " is used shortly. For now, it's just a commented label, and it has"
ECHO.
%COL% n @ " no effect. We are now at the end of the Batch code, and here this"
ECHO.
%COL% n @ " Subroutine call terminates. We'll "
%COL% j @ "resume"
%COL% n @ " with the line that comes"
ECHO.
%COL% n @ " just "
%COL% l @ "after"
%COL% n @ " the one that called the Subroutine (in the main code)."
ECHO.
CALL %0 GOTO: _PAUSE
SET RESUME=

:: Clear secondary command line as we're no longer in Subroutine
SET CL1=
CALL %0 GOTO: _CODE 4
ECHO.
%COL% n @ " The Subroutine call has returned, and we are now back in the main"
ECHO.
%COL% n @ " code section. This line "
%COL% k @ "ECHO"
%COL% n @ "es a message to show the flow has now"
ECHO.
%COL% n @ " returned to this main code section (the Subroutine was a "
%COL% l @ "detour"
%COL% n @ ")."
ECHO.
ECHO.
%COL% n @ " There may be many Subroutines in a single Batch file, and each of"
ECHO.
%COL% n @ " them may be called several times. In this simple example, there's"
ECHO.
%COL% n @ " just one Subroutine and it's called only once as a demonstration."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 5
ECHO.
%COL% n @ " This line "
%COL% k @ "ECHO"
%COL% n @ "es a message to show the main code section has also"
ECHO.
%COL% n @ " finished. In all Batch files that use Subroutines, the main logic"
ECHO.
%COL% n @ " flow ends when the Subroutine-section starts. The Subroutine code"
ECHO.
%COL% n @ " is used "
%COL% l @ "only when it's invoked"
%COL% n @ " with a valid Subroutine "
%COL% k @ "CALL"
%COL% n @ " line."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE 6
ECHO.
%COL% n @ " This line executes the jump "
%COL% n d "GOTO EOF"
%COL% n @ " which finally takes the flow"
ECHO.
%COL% n @ " to the end of the file, and the entire "
%COL% o d "SUBDEM1.BAT"
%COL% n @ " file finishes."
ECHO.
ECHO.
%COL% n @ " Windows ignores the text "
%COL% n d "{=Subroutine-section-below=}"
%COL% n @ ", which is a"
ECHO.
%COL% n @ " is a "
%COL% k @ "comment"
%COL% n @ " that reminds you where the Subroutine section comes."
ECHO.
CALL %0 GOTO: _PAUSE

CALL %0 GOTO: _CODE b
ECHO.
%COL% n @ " We've jumped to the end of file, and since we're no longer inside"
ECHO.
%COL% n @ " a Subroutine "
%COL% k @ "CALL"
%COL% n @ ", "
%COL% o d "SUBDEM1.BAT"
%COL% n @ " finishes at this stage. That's it."
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

:: Delete the COLour workfile. Variables clear as child shell closes.
DEL %COL%

GOTO EOF {=Subroutine-section-below=}
:_CODE (Usage: CALL %0 GOTO: _CODE LnForHighlight)
:: This Subroutine displays the SUBDEM1.BAT example code
:: with the appropriate line hightlighted
FOR %%C IN (0 1 2 3 4 5 6 7 8 9 0 a b) DO SET F%%C=o
FOR %%C IN (0 1 2 3 4 5 6 7 8 9 0 a b) DO SET B%%C=c
SET F%3=n
SET B%3=d
%COL% @ g %CL%
ECHO.
:: ECHO the current folder standard PROMPT in grey-on-grey as a spacer
:: to align secondary command line with the length of whatever folder
:: name is being used
IF NOT (%CL1%)==() %COL% g g "%PR%>"
IF NOT (%CL1%)==() %COL% o g %CL1%
IF NOT (%CL1%)==() ECHO.

%COL% %F0% %B0% "  @ECHO OFF                                   "
ECHO.
%COL% %F1% %B1% "  IF (GOTO:)==(%%1) %%1%%2 {Subroutine-Handler}  "
ECHO.
%COL% %F2% %B2% "  ECHO. This is the main code section         "
ECHO.
%COL% %F3% %B3% "  CALL %%0 GOTO: _SUBR SubParOne SubParTwo     "
ECHO.
%COL% %F4% %B4% "  ECHO. Back in the main code section         "

:: Handle any resume message we need to show
IF NOT (%RESUME%)==() %COL% j @ "<- we'll resume here"
ECHO.
%COL% %F5% %B5% "  ECHO. This is the end of main code.         "
ECHO.
%COL% %F6% %B6% "  GOTO EOF {=Subroutine-section-below=}       "
ECHO.
%COL% %F7% %B7% "  :_SUBR                                      "
ECHO.
%COL% %F8% %B8% "  ECHO.   Now in the _SUBR Subroutine         "
ECHO.
%COL% %F9% %B9% "  ECHO.   %%%%3 Parameter passed=%%3             "
ECHO.
%COL% %Fa% %Ba% "  ECHO.   %%%%4 Parameter passed=%%4             "
ECHO.
%COL% %Fb% %Bb% "  :EOF {End-of-file}                          "
ECHO.

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
