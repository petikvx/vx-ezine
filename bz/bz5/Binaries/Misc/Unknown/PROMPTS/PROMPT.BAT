@ECHO OFF
REM PROMPTS.BAT
IF NOT '%1'=='' GOTO Label%1
CLS
ECHO Syntax: PROMPTS #
ECHO   where # is a number from 1 to 5
ECHO 1 - Businesslike date and time prompt
ECHO 2 - Windows prompt
ECHO 3 - Face prompt
ECHO 4 - Christmas Tree prompt
ECHO 5 - Raging bull prompt
GOTO End

:Label1
REM * Display current path
PROMPT $p$g
REM * Save cursor position 
PROMPT %PROMPT%$e[s
REM * Move to top left corner of screen
PROMPT %PROMPT%$e[H
REM * Set color to reverse video
PROMPT %PROMPT%$e[0;7m
REM * Clear to end of line
PROMPT %PROMPT%$e[K
REM * Print date
PROMPT %PROMPT%$d
REM * Move to column 73
PROMPT %PROMPT%$e[;73H
REM * Turn off wrap at end of line
PROMPT %PROMPT%$e[=7l
REM * Print time
PROMPT %PROMPT%$t
REM * Turn on wrap at end of line
PROMPT %PROMPT%$e[=7h
REM * Restore default color
PROMPT %PROMPT%$e[0m
REM * Restore cursor position
PROMPT %PROMPT%$e[u
GOTO CLS

:Label2
REM * Set color to white on blue, write "Windows"
PROMPT $e[44;37;1m Windows
REM * Set background to black, new line
PROMPT %PROMPT% $e[40m$_
REM * Draw body of window, new line
PROMPT %PROMPT%€€€€€€€€€$_
REM * Draw part of window body
PROMPT %PROMPT%€€€€€€
REM * Set background to red, write "Prompt"
PROMPT %PROMPT%$e[41m Prompt 
REM * Set background to black, new line
PROMPT %PROMPT%$e[40m$_
REM * Move 6 spaces right, draw window body, new line
PROMPT %PROMPT%$e[6C€€€€€€€€$_
REM * Move 6 spaces right, draw window body
PROMPT %PROMPT%$e[6C€€€€€€€€
REM * Set background black, print current path
PROMPT %PROMPT%$e[40m $p$g
GOTO CLS

:Label3
REM * Set white on grey, draw hair
PROMPT $e[0;47;1m (^??? 
REM * Set black background, new line
PROMPT %PROMPT%$e[40m$_
REM * Set grey background, draw ear
PROMPT %PROMPT%$e[47m{
REM * Set blinking blue foreground, draw eye
PROMPT %PROMPT% $e[34;5;1mo
REM * Set white on grey, draw nose
PROMPT %PROMPT%$e[0;47;1m,
REM * Set blinking blue foreground, draw eye
PROMPT %PROMPT%$e[34;5;1mo
REM * Set white on grey, draw ear
PROMPT %PROMPT%$e[0;47;1m }
REM * Set black background, print, date, new line
PROMPT %PROMPT%$e[40m $d$_
REM * Set grey background, draw jaw
PROMPT %PROMPT%$e[47m \ - /
REM * Set white on black, print current directory
PROMPT %PROMPT% $e[0;1m $p$g
GOTO CLS

:Label4
REM * Set bright green on black, draw tree
PROMPT $e[0;32;1m$_   //\$_  ///\\$_ ////\\\$_/////\\\\
REM * Draw trunk, save cursor position
PROMPT %PROMPT%$_    ∫$e[s
REM * Set blinking cyan on black, draw ornaments
REM * ASCII character #15 ------v 
PROMPT %PROMPT%$e[36;5m$e[5A$e[D$e[2B$e[B$e[4D$e[B$e[4C
REM * Set white on black
PROMPT %PROMPT%$e[0;1m
REM * Restore cursor position, print current directory
PROMPT %PROMPT%$e[u $p$g
GOTO CLS

:Label5
REM * Set brown on black, move 9 spaces right
PROMPT $e[0;33;40m$e[9C
REM * Draw horns, new line
PROMPT %PROMPT%(__)$_
REM * Move 9 spaces right, draw side of face
PROMPT %PROMPT%$e[9C(
REM * Set blinking magenta foreground, draw eyes
PROMPT %PROMPT%$e[35;1;5moo
REM * Restore brown foreground, draw side of face
PROMPT %PROMPT%$e[0;33m)
REM * Draw body
PROMPT %PROMPT%$_  /ƒƒƒƒƒƒƒ\/
PROMPT %PROMPT%$_ / ≥€€€€€≥≥
PROMPT %PROMPT%$_*  ≥≥ƒƒƒƒ≥≥
PROMPT %PROMPT%$_   ^^    ^^$_
REM * Set foreground yellow, print current directory
PROMPT %PROMPT%$e[1;33m$p$g
GOTO CLS

:CLS
CLS
ECHO.

:End
