@ECHO OFF
IF !%1==!. %2

:: mostly the environment isn't checked
:: valid COMSPEC, commands DEBUG,FIND,CHOICE,MODE and MEM in PATH...
::
:: but must have ANSI.SYS installed and often it's not so...

MEM /C |FIND "ANSI ">NUL
IF NOT ERRORLEVEL 1 GOTO START0

ECHO FATAL ERROR: this program requires ANSI.SYS to be installed
ECHO              please put it into your CONFIG.SYS and re-boot
ECHO.
GOTO OUT

:START0

:: make sure we got enough environment

:: this also mean we don't have to clear variables
:: on exit (good because there are lotz)

%COMSPEC% /E:4096 /C %0 . GOTO:START
GOTO OUT

:-----------------: main program starts here :----------------------:

:START

:: initialise some variables
::
:: ESC = character code 27. used for ANSI escape sequences and input routines
:: X   = character code 177. this is a grey block used for graphics
::       in grid vacant square indicator
:: W   = character code 219. this is a solid block used for graphics
:: W2  = 8 lots of character 219. helps build lines in graphics 
:: FB  = indent for the board on screen
:: SPC = space character. mainly as a cosmetic nicety in the code
:: BS  = backspace character code 8. for delete in input routine 
:: COM = macro to invoke command processor with 4k environment
:: TMP0-3= temp working files with BAT extension

SET COM=%COMSPEC%/E:4096
FOR %%_ IN (0 1 2 3) DO SET TMP%%_=%TEMP%.\@%%_.BAT
%COM%/C %0 . GOTO:SEND "SET" 20 "ESC" 3D 1B 0D 0A>%TMP0%
%COM%/C %0 . GOTO:SEND "SET" 20 "X" 3D B1 0D 0A>>%TMP0%
%COM%/C %0 . GOTO:SEND "SET" 20 "BS" 3D 08 0D 0A>>%TMP0%
%COM%/C %0 . GOTO:SEND "SET" 20 "W" 3D DB 0D 0A>>%TMP0%
CALL %TMP0%
SET SPC= %=%
SET FB=                %=%
SET W2=%W%%W%%W%%W%%W%%W%%W%%W%


:: do initialisation title :)

ECHO  ****  **  **  ****   ****   ****   Batch file chess
ECHO ****** **  ** ****** ****** ******  Version 2.1
ECHO **     **  ** **     **     **
ECHO **     ****** ****** *****  *****
ECHO **     ****** ******  *****  *****
ECHO **     **  ** **         **     **  by
ECHO ****** **  ** ****** ****** ******  Laura Fairhead
ECHO  ****  **  **  ****   ****   ****   October 2001
ECHO.
ECHO.

:: SINK= if set then reading moves from a moves file name in %SINK%
SET SINK=%=%

:: create %DBFILE% database for board processing
:: if exists assume it is okay and just re-use
:: see :DBGEN for details

ECHO.
ECHO %ESC%[ACREATING %TEMP%.\DB$$.BAT%ESC%[s
%COM%/C %0 . GOTO:SEND 1B "[u"

SET DBFILE=%TEMP%.\DB$$.BAT
IF EXIST %DBFILE% ECHO  (FOUND EXISTING COPY)
IF NOT EXIST %DBFILE% CALL %0 . GOTO:DBGEN

:: create TRACK$$.BAT  routine to look down files/ranks/diagonals
:: see :TRGEN for details

ECHO CREATING %TEMP%.\TRACK$$.BAT

SET TRACK=%TEMP%.\TRACK$$.BAT
%COM%/C %0 . GOTO:TRGEN>%TRACK%

:: create CVCHK$$.BAT. a lot of IF/THENs to translate vacant squares
:: on the board to shaded characters. this is generated to save lines
:: in the program (would be 32 lines of code in DISPLAY routine)

ECHO CREATING %TEMP%.\CVCHK$$.BAT

%COM%/C %0 . GOTO:CVCHK 28 48 68 88 17 37 57 77 26 46 66 86 15 35 55 75>%TEMP%.\CVCHK$$.BAT
%COM%/C %0 . GOTO:CVCHK 24 44 64 84 13 33 53 73 22 42 62 82 11 31 51 71>>%TEMP%.\CVCHK$$.BAT

:: use empty batch for mid-file exits
ECHO.>%TEMP%.\RTN.BAT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:NEWGAME0
SET MOVE1=WHITE

:NEWGAME

:: initialise board

:: the game board is kept in 64 environment varibles of
:: the form;  _[column][row]
:: where [column] is one digit column number from 1 to 8
:: and [row] is one digit row number from 1 to 8
:: variable _11 is equivalent to whites bottom left or A1

:: each variable holds the piece that is currently occupying
:: that square. this is a %X% character if it is vacant
:: or else it is one of;
::
:: R=white rook               r=black rook
:: N=white knight             n=black knight
:: B=white bishop             b=black bishop
:: Q=white queen              q=black queen
:: K=white king               k=black king
:: P=white pawn               p=black pawn
::
:: This is exactly the same as the display format for
:: simplicity.

CALL %0 . GOTO:CLRBOARD
CALL %0 . GOTO:SETV _11 R _21 N _31 B _41 Q _51 K _61 B _71 N _81 R
FOR %%_ IN (1 2 3 4 5 6 7 8) DO SET _%%_2=P
FOR %%_ IN (1 2 3 4 5 6 7 8) DO SET _%%_7=p
CALL %0 . GOTO:SETV _18 r _28 n _38 b _48 q _58 k _68 b _78 n _88 r
SET WHITEK=51
SET BLACKK=58

:NEWGAME1
MODE CON LINES=43
SET COLR=BLACK
SET MOVE=000
SET MOVED=
SET MOVEP=
SET INVALID=
IF %MOVE1%==BLACK CALL %0 . GOTO:INCMOVE

:: new MOVES$$.BAT file

ECHO.%%1>%TEMP%.\MOVES$$.BAT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:NEXTMOVE

CALL %0 . GOTO:INCMOVE

:MAINLP2

IF NOT !%SINK%==! IF !%SINKDISP%==!FALSE GOTO GETMOVE
:: CLS
%COM%/C %0 . GOTO:DISPLAY

:GETMOVE

IF NOT !%SINK%==! IF !%SINKDISP%==!FALSE GOTO GETMOVE2

CALL %0 . GOTO:CLRMENU
ECHO.
ECHO.
ECHO %X%  MOVE NUMBER   [ %MOVE% ]
ECHO %X%  COLOUR        [ %COLR% ]
ECHO.
IF !%INVALID%==! SET INVALID=%MOVED%
ECHO %X%  %INVALID%
ECHO.
ECHO %X%  PLEASE ENTER YOUR MOVE: ..-..                       %X%
ECHO.
ECHO %X%  [DEL] DELETES      [ESC] FOR MENU                   %X%%ESC%[3A
SET INVALID=

:GETMOVE2

IF !%SINK%==! GOTO STDIN

:: moves being sinked from input file

IF !%MOVE%==!%SINKMOVE% IF !%COLR%==!%SINKCOLR% GOTO STOPSINK

CALL %SINK% GOTO:%COLR%%MOVE%
CALL %0 . GOTO:SETV %_%
GOTO DOMV

:STOPSINK

:: sink has finished here, reset and start reading from STDIN again
SET SINK=
IF !%SINKDISP%==!FALSE GOTO MAINLP2

:: get move from user

:STDIN

SET P=%X%  PLEASE ENTER YOUR MOVE: %=%
%COM%/C %0 . GOTO:INPUT>%TMP0%
CALL %TMP0%
IF %ABORT%==TRUE GOTO MENU

:: ------------------------------------------------------------------

:DOMV

:: POS = source position location
:: POT = target position location
:: P0  = piece at source position
:: P1  = piece at target position

SET POS=%M0%%M1%
SET POT=%M2%%M3%
CALL %DBFILE% GOTO:_%POT%
SET P1=%_%
CALL %DBFILE% GOTO:_%POS%
SET P0=%_%

:: UNDO = list of sets in SETV    format to undo any changes
::        we haven't done these changes yet so this might
::        go to the bottom (SETMV)

SET UNDO=_%POS% %P0% _%POT% %P1% %=%

:: ------------------------ basic validation ------------------------

:: must be a piece of your colour
SET @=0
SET _=Q N B R P K
IF %COLR%==BLACK SET _=q n b r p k
FOR %%_ IN (%_%) DO IF %%_==%P0% SET @=1
IF %@%==0 GOTO INVALID

:: target can't be a piece of your colour
FOR %%_ IN (%_%) DO IF %%_==%P1% SET @=0
IF %@%==0 GOTO INVALID

SET SU=
IF !%SINK%==! SET PR=

:: ------------------- validate QUEEN  move -------------------------

IF NOT %P0%==Q IF NOT %P0%==q GOTO NOTQUEEN
SET TRACKMV=TRUE
SET TRACKDG=TRUE
SET TRACKVH=TRUE
CALL %TRACK%
IF NOT %TRACKMV%==FOUND GOTO INVALID
GOTO SETMV

:NOTQUEEN

:: ------------------- validate ROOK   move -------------------------

IF NOT %P0%==R IF NOT %P0%==r GOTO NOTROOK
SET TRACKMV=TRUE
SET TRACKDG=FALSE
SET TRACKVH=TRUE
CALL %TRACK%
IF NOT %TRACKMV%==FOUND GOTO INVALID
GOTO SETMV

:NOTROOK

:: ------------------- validate BISHOP move -------------------------

IF NOT %P0%==B IF NOT %P0%==b GOTO NOTBISH
SET TRACKMV=TRUE
SET TRACKDG=TRUE
SET TRACKVH=FALSE
CALL %TRACK%
IF NOT %TRACKMV%==FOUND GOTO INVALID
GOTO SETMV

:NOTBISH

:: ------------------- validate KNIGHT move -------------------------

IF NOT %P0%==n IF NOT %P0%==N GOTO NOTKN

CALL %DBFILE% GOTO:_%POS%
FOR %%_ IN (%_KN%) DO IF %POT%==%%_ SET _=FOUND
IF NOT %_%==FOUND GOTO INVALID
GOTO SETMV

:NOTKN

:: ------------------- validate PAWN move ----------------------------

IF %P0%==p GOTO BPAWN
IF NOT %P0%==P GOTO NOTPAWN

:: --------------------- WHITE PAWN ---------------------------------
CALL %DBFILE% GOTO:_%POS%
IF %P1%==%X% GOTO WPAWN1
:: destination is occupied so this must be ordinary capture
IF NOT !%POT%==!%_NE% IF NOT !%POT%==!%_NW% GOTO INVALID
GOTO PROMO
:WPAWN1
:: normal pawn advance 1 ?
IF !%POT%==!%_N% GOTO PROMO
:: 
IF NOT !%POT%==!%_NE% IF NOT !%POT%==!%_NW% GOTO WPAWN0
:: must be en-passant capture, check it is okay
CALL %DBFILE% GOTO:_%M2%5
IF NOT %M1%%_%%MOVEP%==5p%M2%7%M2%5 GOTO INVALID
SET _%M2%5=%X%
SET UNDO=%UNDO%_%M2%5 p %=%
SET SU=EP
GOTO SETMV
:WPAWN0
:: only pawn advancing 2 is valid here
:: north must exist for a pawn due to promotion
CALL %DBFILE% GOTO:_%_N%
IF NOT %M1%%_%%POT%==2%X%%_N% GOTO INVALID
GOTO SETMV

:: the black pawn code is symetric duplicate of white pawn code

:: --------------------- BLACK PAWN ---------------------------------
:BPAWN
CALL %DBFILE% GOTO:_%POS%
IF %P1%==%X% GOTO BPAWN1
:: destination is occupied so this must be ordinary capture
IF NOT !%POT%==!%_SE% IF NOT !%POT%==!%_SW% GOTO INVALID
GOTO PROMO
:BPAWN1
:: normal pawn advance 1 ?
IF !%POT%==!%_S% GOTO PROMO
:: 
IF NOT !%POT%==!%_SE% IF NOT !%POT%==!%_SW% GOTO BPAWN0
:: must be en-passant capture, check it is okay
CALL %DBFILE% GOTO:_%M2%4
IF NOT %M1%%_%%MOVEP%==4P%M2%2%M2%4 GOTO INVALID
SET _%M2%4=%X%
SET UNDO=%UNDO%_%M2%4 P %=%
SET SU=EP
GOTO SETMV
:BPAWN0
:: only pawn advancing 2 is valid here
:: north must exist for a pawn due to promotion
CALL %DBFILE% GOTO:_%_S%
IF NOT %M1%%_%%POT%==7%X%%_S% GOTO INVALID
GOTO SETMV

:: ------------------- promotion check -------------------------------

:PROMO

IF %M3%%P0%==8P GOTO WPROMO
IF %M3%%P0%==1p GOTO BPROMO
GOTO SETMV

:WPROMO
IF NOT !%SINK%==! SET P0=%PR%
IF NOT !%SINK%==! GOTO SETMV

CHOICE /CQNBR%ESC% %X%  PROMOTE TO %=%
IF ERRORLEVEL 5 GOTO MENU
SET P0=Q
IF ERRORLEVEL 2 SET P0=N
IF ERRORLEVEL 3 SET P0=B
IF ERRORLEVEL 4 SET P0=R
SET PR=%P0%
GOTO SETMV

:BPROMO
IF NOT !%SINK%==! SET P0=%PR%
IF NOT !%SINK%==! GOTO SETMV

CHOICE /CQNBR%ESC% %X%  PROMOTE TO %=%
IF ERRORLEVEL 5 GOTO MENU
SET P0=q
IF ERRORLEVEL 2 SET P0=n
IF ERRORLEVEL 3 SET P0=b
IF ERRORLEVEL 4 SET P0=r
SET PR=%P0%
GOTO SETMV

:NOTPAWN

:: ------------------- VALIDATE KING MOVE ---------------------------

:: castling ?
SET RTN2=
IF %P0%%POS%%POT%==K5171 SET RTN2=WCA0
IF %P0%%POS%%POT%==K5131 SET RTN2=WCA1
IF %P0%%POS%%POT%==k5878 SET RTN2=BCA0
IF %P0%%POS%%POT%==k5838 SET RTN2=BCA1
IF !%RTN2%==! GOTO NOCA

:: going to look at move history to determine
:: if rook/king has already moved
:: get the SET _=M0 %M0% M1 %M1% M2 %M2% M3 %M3% ...
:: lines into MOVE1$$.BAT

FIND "SET _=" <%TEMP%.\MOVES$$.BAT >%TEMP%.\MOVE1$$.BAT

:: can't castle out of check
SET TRACKMV=%PREVCOLR%
SET POS=%BLACKK%
SET POS2=%WHITEK%
IF %COLR%==WHITE SET POS=%WHITEK%
IF %COLR%==WHITE SET POS2=%BLACKK%
CALL %0 . GOTO:KNCK
SET POS=%M0%%M1%
IF %TRACKMV%==FOUND GOTO INVALID

GOTO %RTN2%

:BCA0
:: -----------Black kings side castle
IF NOT %_68%%_78%%_88%==%X%%X%r GOTO INVALID

:: neither king nor rook can have moved
FIND "M0 5 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID
FIND "M0 8 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID

:: no castling through check
CALL %0 . GOTO:SETV _58 %X% _68 k POS 68
CALL %0 . GOTO:KNCK
CALL %0 . GOTO:SETV _58 k _68 %X% POS %M0%%M1%
IF %TRACKMV%==FOUND GOTO INVALID

SET _88=%X%
SET _68=r
SET UNDO=%UNDO%_88 r _68 %X% %=%
GOTO KINGV

:BCA1
:: -----------Black queens side castle
IF NOT %_18%%_28%%_38%%_48%==r%X%%X%%X% GOTO INVALID

:: neither king nor rook can have moved
FIND "M0 5 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID
FIND "M0 1 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID

:: no castling through check
CALL %0 . GOTO:SETV _48 k _58 %X% POS 48
CALL %0 . GOTO:KNCK
CALL %0 . GOTO:SETV _48 %X% _58 k POS %M0%%M1%
IF %TRACKMV%==FOUND GOTO INVALID

SET _18=%X%
SET _48=r
SET UNDO=%UNDO%_18 r _48 %X% %=%
GOTO KINGV

:WCA0
:: -----------White kings side castle
IF NOT %_61%%_71%%_81%==%X%%X%R GOTO INVALID

:: neither king nor rook can have moved
FIND "M0 5 M1 1 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID
FIND "M0 8 M1 1 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID

:: no castling through check
CALL %0 . GOTO:SETV _51 %X% _61 K POS 61
CALL %0 . GOTO:KNCK
CALL %0 . GOTO:SETV _51 K _61 %X% POS %M0%%M1%
IF %TRACKMV%==FOUND GOTO INVALID

SET _81=%X%
SET _61=R
SET UNDO=%UNDO%_81 R _61 %X% %=%
GOTO KINGV

:WCA1
:: -----------White queens side castle
IF NOT %_11%%_21%%_31%%_41%==R%X%%X%%X% GOTO INVALID

:: neither king nor rook can have moved
FIND "M0 5 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID
FIND "M0 1 M1 8 " <%TEMP%.\MOVE1$$.BAT >NUL
IF NOT ERRORLEVEL 1 GOTO INVALID

:: no castling through check
CALL %0 . GOTO:SETV _41 K _51 %X% POS 41
CALL %0 . GOTO:KNCK
CALL %0 . GOTO:SETV _41 %X% _51 K POS %M0%%M1%
IF %TRACKMV%==FOUND GOTO INVALID

SET _11=%X%
SET _41=R
SET UNDO=%UNDO%_11 R _41 %X% %=%
GOTO KINGV

:NOCA
:: ------------------- normal king move? ----------------------------

CALL %DBFILE% GOTO:_%POS%
FOR %%_ IN (%_N% %_E% %_S% %_W% %_NE% %_NW% %_SE% %_SW%) DO IF %%_==%POT% SET _=FOUND
IF NOT %_%==FOUND GOTO INVALID

:KINGV
IF %COLR%==WHITE SET UNDO=%UNDO% WHITEK %POS% %=%
IF %COLR%==WHITE SET WHITEK=%POT%
IF %COLR%==BLACK SET UNDO=%UNDO% BLACKK %POS% %=%
IF %COLR%==BLACK SET BLACKK=%POT%
GOTO SETMV

:NOTKING

:: ------------------- move piece -----------------------------------

:SETMV

:: do main move
SET _%POS%=%X%
SET _%POT%=%P0%

:: test if we are in check
SET TRACKMV=%PREVCOLR%
SET POS=%BLACKK%
SET POS2=%WHITEK%
IF %COLR%==WHITE SET POS=%WHITEK%
IF %COLR%==WHITE SET POS2=%BLACKK%
CALL %0 . GOTO:KNCK
IF NOT %TRACKMV%==FOUND GOTO SETMV0

:: if so undo changes and invalid move
CALL %0 . GOTO:SETV %UNDO%
GOTO INVALID
:SETMV0

:: work out formated MOVED string

IF NOT !%PR%==! SET SU=(%PR%)
SET MID=-
IF NOT %P1%==%X% SET MID=x
IF !%SU%==!EP SET MID=x

:: is this check to the opposing king?

SET TRACKMV=%COLR%
SET POS=%WHITEK%
SET POS2=%BLACKK%
IF %COLR%==WHITE SET POS=%BLACKK%
IF %COLR%==WHITE SET POS2=%WHITEK%
CALL %0 . GOTO:KNCK

SET _= %=%
IF !%SU%==!EP SET _=  %=%
IF !%SU%==! SET _=    %=%

IF %TRACKMV%==FOUND SET SU=%SU%+%_%
IF NOT %TRACKMV%==FOUND SET SU=%SU% %_%

::
SET MOVET=%L0%%M1%%MID%%L2%%M3% %SU%

:: add move to MOVES$$.BAT file
%COM% /C %0 . GOTO:ADDMV >>%TEMP%.\MOVES$$.BAT

SET MOVED=%MOVET%
SET MOVEP=%M0%%M1%%M2%%M3%
GOTO NEXTMOVE

:: information to add to moves file
:ADDMV
:: %COLR%%MOVE% is tag to uniquely identify this section in file
:: is put on every line in file using a void variable; '% WHITE017 %'
SET _=%% %COLR%%MOVE% %%
ECHO :%COLR%%MOVE%  ( %L0%%M1%-%L2%%M3% )
ECHO %_%SET _=M0 %M0% M1 %M1% M2 %M2% M3 %M3% L0 %L0% L2 %L2%
ECHO %_%SET PR=%PR%
ECHO %_%SET MOVED=%MOVED%
ECHO %_%SET MOVEP=%MOVEP%
ECHO %_%SET MOVET=%MOVET%
ECHO %_%SET PREVMOVE=%PREVMOVE%
ECHO %_%SET PREVCOLR=%PREVCOLR%
ECHO %_%SET UNDO=%UNDO%
ECHO %_%SET WHITEK=%WHITEK%
ECHO %_%SET BLACKK=%BLACKK%
ECHO %_%%%TEMP%%.\RTN.BAT
EXIT

:: ------------------- detected invalid move ------------------------

:INVALID
SET INVALID=%L0%%M1%-%L2%%M3% IS AN INVALID MOVE!
GOTO MAINLP2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:MENU

CALL %0 . GOTO:CLRMENU

ECHO.
ECHO.
ECHO %X%  [B] BACK ONE MOVE        [N] NEW GAME               %X%
ECHO %X%  [S] SAVE GAME            [Q] QUIT                   %X%
ECHO %X%  [L] LOAD GAME            [R] REPLAY ALL MOVES       %X%
ECHO %X%  [M] SAVE MOVE LIST       [E] ENTER POSITION         %X%
ECHO.
ECHO.
ECHO.
ECHO %X%  [ESC] TO CANCEL                                     %X%%ESC%[3A

CHOICE /CBSLNQRME%ESC% /N %X%  PLEASE SELECT YOUR CHOICE: %=%

IF ERRORLEVEL 9 GOTO GETMOVE
IF ERRORLEVEL 8 GOTO ENTER
IF ERRORLEVEL 7 GOTO SAVEMOVE
IF ERRORLEVEL 6 GOTO REPLAY
IF ERRORLEVEL 5 GOTO QUIT
IF ERRORLEVEL 4 GOTO NEWGAME0
IF ERRORLEVEL 3 GOTO LOAD
IF ERRORLEVEL 2 GOTO SAVE


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: back move

:: can't go back before 1st move!

IF %PREVMOVE%==000 GOTO MENU
IF %MOVE1%%MOVE%%COLR%==BLACK001BLACK GOTO MENU

::
SET MOVE=%PREVMOVE%
SET COLR=%PREVCOLR%
CALL %TEMP%.\MOVES$$.BAT GOTO:%COLR%%MOVE%
CALL %0 . GOTO:SETV %UNDO%
FIND /V "%COLR%%MOVE%" <%TEMP%.\MOVES$$.BAT >%TEMP%.\MOVE0$$.BAT
COPY /Y %TEMP%.\MOVE0$$.BAT %TEMP%.\MOVES$$.BAT >NUL

GOTO MAINLP2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: replay. just replays all moves to the present one.

:REPLAY
COPY %TEMP%.\MOVES$$.BAT %TEMP%.\MOVE0$$.BAT>NUL
SET SINK=%TEMP%.\MOVE0$$.BAT
SET SINKMOVE=%MOVE%
SET SINKCOLR=%COLR%
SET SINKDISP=TRUE
GOTO NEWGAME

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: save move list to MOVELIST file

:SAVEMOVE
%COM% /C %0 . GOTO:SM0>MOVELIST
GOTO MAINLP2

:SM0
SET SINKMOVE=%MOVE%
SET SINKCOLR=%COLR%

:: ?WHITEK  will get on last record anyhow
:: ?BLACKK
ECHO SET MOVED=%MOVED%>%TMP1%
ECHO SET MOVEP=%MOVEP%>>%TMP1%

SET MOVE=000
SET COLR=BLACK

SET @=(001) ...        %=%
IF %MOVE1%==BLACK CALL %0 . GOTO:INCMOVE
IF %MOVE1%==BLACK GOTO SM1

:SML
CALL %0 . GOTO:INCMOVE
IF %SINKCOLR%%SINKMOVE%==%COLR%%MOVE% GOTO SMDON
ECHO %ESC%[A%X%  SAVING MOVE [ %MOVE% ] \       %=%>CON
CALL %TEMP%.\MOVES$$.BAT GOTO:%COLR%%MOVE%
SET @=(%MOVE%) %MOVET%
:SM1
CALL %0 . GOTO:INCMOVE
IF %SINKCOLR%%SINKMOVE%==%COLR%%MOVE% GOTO SMDON1
ECHO %ESC%[A%X%  SAVING MOVE [ %MOVE% ] /       %=%>CON
CALL %TEMP%.\MOVES$$.BAT GOTO:%COLR%%MOVE%
ECHO %@%      %MOVET%
GOTO SML

:SMDON1
IF NOT %MOVE1%%MOVE%==BLACK001 ECHO %@%
:SMDON
CALL %TMP1%
GOTO OUT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: load current game moves+position from SAVEGAME.BAT

:LOAD
IF NOT EXIST SAVEGAME.BAT GOTO MAINLP2
CALL SAVEGAME.BAT
FIND /V "%% !SAVEGAME %%" <SAVEGAME.BAT >%TEMP%.\MOVES$$.BAT
GOTO MAINLP2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: save current game moves+position in SAVEGAME.BAT

:SAVE
SET _=%% !SAVEGAME %%
ECHO @ECHO OFF>%TMP0%
%COM%/C %0 . GOTO:SAVE1 1 2 3 4 5 6 7 8 >>%TMP0%
%COM%/C %TMP0% >SAVEGAME.BAT
%COM%/C %0 . GOTO:SAVE2>>SAVEGAME.BAT
GOTO GETMOVE

:SAVE2
ECHO %_%SET COLR=%COLR%
ECHO %_%SET MOVE=%MOVE%
ECHO %_%SET PREVCOLR=%PREVCOLR%
ECHO %_%SET PREVMOVE=%PREVMOVE%
ECHO %_%SET MOVED=%MOVED%
ECHO %_%SET MOVEP=%MOVEP%
ECHO %_%SET WHITEK=%WHITEK%
ECHO %_%SET BLACKK=%BLACKK%
ECHO %_%SET MOVE1=%MOVE1%
ECHO %_%%%TEMP%%.\RTN.BAT
TYPE %TEMP%.\MOVES$$.BAT
EXIT

:SAVE1
FOR %%@ IN (1 2 3 4 5 6 7 8) DO ECHO ECHO %%_%%SET _%%@%3=%%_%%@%3%%
SHIFT
IF NOT !%3==! GOTO SAVE1
EXIT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:QUIT

:: program termination, clean up temporary files

FOR %%_ IN (CVCHK$$ MOVES$$ MOVE0$$) DO IF EXIST %TEMP%.\%%_.BAT DEL %TEMP%.\%%_.BAT
FOR %%_ IN (MOVE1$$ RTN) DO IF EXIST %TEMP%.\%%_.BAT DEL %TEMP%.\%%_.BAT
FOR %%_ IN (%TRACK% %TMP0% %TMP1% %TMP2% ) DO IF EXIST %%_ DEL %%_

:: goodbye message

ECHO.
ECHO.
ECHO.
ECHO.
ECHO GOODBYE!

GOTO OUT

::::::::::::::::: KNCK is king in check test ::::::::::::::::::::::::

:: on entry:  TRACKMV=colour of opposing side
::            POS    =position of king
::            POS2   =position of opposing sides king
:: on exit:   TRACKMV=is set to FOUND if king is in check
:KNCK

CALL %DBFILE% GOTO:_%POS%

:: check for adjacent king
FOR %%_ IN (%_N% %_S% %_E% %_W% %_NE% %_NW% %_SE% %_SW%) DO IF %%_==%POS2% SET TRACKMV=FOUND

:: check for knight attacker
SET _=N
IF %TRACKMV%==BLACK SET _=n
SET @=
CALL %0 . GOTO:KNCK0 %_KN%
ECHO SET @=%@%>%TMP0%
ECHO FOR %%%%_ IN (%%@%%) DO IF %%%%_==%_% SET TRACKMV=FOUND>>%TMP0%
CALL %TMP0%

:: check for pawn attacker (note: %_%=n or N,soDont need check directions set)
ECHO IF %TRACKMV%==BLACK IF %%_%_NE%%%==p SET TRACKMV=FOUND>%TMP0%
ECHO IF %TRACKMV%==BLACK IF %%_%_NW%%%==p SET TRACKMV=FOUND>>%TMP0%
ECHO IF %TRACKMV%==WHITE IF %%_%_SE%%%==P SET TRACKMV=FOUND>>%TMP0%
ECHO IF %TRACKMV%==WHITE IF %%_%_SW%%%==P SET TRACKMV=FOUND>>%TMP0%
CALL %TMP0%
IF %TRACKMV%==FOUND GOTO OUT

:: check for any VHD attacker (rook,queen,bishop)
SET TRACKVH=TRUE
SET TRACKDG=TRUE
CALL %TRACK%

GOTO OUT

:KNCK0 
SET @=%@% %%_%3%%
SHIFT
IF NOT !%3==! GOTO KNCK0
GOTO OUT

::::::::::::::::::: track for V/H/D move or attacker ::::::::::::::::

:: routine is created here by TRGEN
::
:: thereafter invoked by program as 'CALL %TRACK%'
::
:: on entry:  TRACKMV=TRUE => looking for move %POT%
::                    WHITE=> looking for white attacker
::                    BLACK=> looking for black attacker
::            TRACKVH=TRUE => look down file and rank
::                    FALSE
::            TRACKDG=TRUE => look down diagonal
::                    FALSE
::            POS    =start location
::            POT    =target location if looking for move (TRACKMV=TRUE)
::
:: on exit:   TRACKMV=FOUND=> found move/attacker
::            else TRACKMV is preserved
::
::            uses variables: CPOS, @, RTN itself and also
::            calls %DBFILE%

:TRGEN
ECHO IF %%TRACKVH%%==FALSE GOTO TRACKDG
ECHO IF %%TRACKMV%%==BLACK SET @=q r
ECHO IF %%TRACKMV%%==WHITE SET @=Q R
CALL %0 . GOTO:TRGEN2 N E S W TE TS TW TRACKDG
ECHO :TRACKDG
ECHO IF %%TRACKDG%%==FALSE GOTO OUT
ECHO IF %%TRACKMV%%==BLACK SET @=q b
ECHO IF %%TRACKMV%%==WHITE SET @=Q B
CALL %0 . GOTO:TRGEN2 NE NW SE SW TNW TSE TSW OUT
ECHO GOTO OUT
ECHO :TRTN1
ECHO SET TRACKMV=FOUND
ECHO GOTO OUT
ECHO :TENDLN
ECHO IF %%TRACKMV%%==TRUE GOTO %%RTN%%
ECHO FOR %%%%_ IN (%%@%%) DO IF %%_%%==%%%%_ SET TRACKMV=FOUND
ECHO IF %%TRACKMV%%==FOUND GOTO OUT
ECHO GOTO %%RTN%%
ECHO :OUT
GOTO OUT

:TRGEN2
ECHO :T%3
ECHO SET CPOS=%%POS%%
ECHO SET RTN=%7
ECHO :TL%3
ECHO CALL %%DBFILE%% GOTO:_%%CPOS%%
ECHO IF %%TRACKMV%%==TRUE IF %%CPOS%%==%%POT%% GOTO TRTN1
ECHO IF NOT %%CPOS%%==%%POS%% IF NOT %%_%%==%%X%% GOTO TENDLN
ECHO SET CPOS=%%_%3%%
ECHO IF NOT !%%_%3%%==! GOTO TL%3
SHIFT
IF NOT !%7==! GOTO TRGEN2
GOTO OUT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DBGEN
::
:: generate database batch file %DBFILE%
::
:: for each square _xy there is one entry in the form;
::
:: :_xy                (label allows record retrival)
:: SET _=%_xy%         _ is set with piece on that square
:: [SET _dir=ij]+      for each valid direction N,E,S,W,NE,NW,SE,SW
::                     _dir is set with the square 1 move in that direction
:: SET _KN=movelist    _KN is set with valid knight moves
:: (return)            (return with record data)
::
SET @=%0
ECHO %%1>%DBFILE%
%COM% /C %0 . GOTO:DBG0 . . 1 2 3 4 5 6 7 8 . .>>%DBFILE%
ECHO.
GOTO OUT                          
:DBG0
:: status indication dots to display
%COM% /C %@% . GOTO:SEND 2E>CON
SET _=%3 %4 %5 %6 %7
CALL %@% . GOTO:DBG1 . . 1 2 3 4 5 6 7 8 . .
SHIFT
IF NOT %3==7 GOTO DBG0
GOTO OUT
:DBG1
CALL %@% . GOTO:DBG2 %3 %4 %5 %6 %7 %_%
SHIFT
IF NOT %3==7 GOTO DBG1
GOTO OUT
:DBG2   %0 %1 %2 %3 %4   (%5 %6 %7 %8 %9)
SHIFT
SHIFT
SHIFT
ECHO :_%2%7
ECHO SET _=%%_%2%7%%
FOR %%_ IN (N E S W NE NW SE SW) DO SET _%%_=
IF NOT %8==. SET _N=%2%8
IF NOT %6==. SET _S=%2%6
IF NOT %1==. SET _W=%1%7
IF NOT %3==. SET _E=%3%7
IF NOT %8==. IF NOT %1==. SET _NW=%1%8
IF NOT %8==. IF NOT %3==. SET _NE=%3%8
IF NOT %6==. IF NOT %1==. SET _SW=%1%6
IF NOT %6==. IF NOT %3==. SET _SE=%3%6
ECHO SET _N=%_N%
ECHO SET _S=%_S%
ECHO SET _E=%_E%
ECHO SET _W=%_W%
ECHO SET _NE=%_NE%
ECHO SET _NW=%_NW%
ECHO SET _SE=%_SE%
ECHO SET _SW=%_SW%
::---------------  KNIGHT MOVES  ------------------------------------
::
::       09  |19|  29  |39|  49
::      |08|  18   28   38  |48|
::       07   17  *27*  37   47
::      |06|  16   26   36  |46|
::       05  |15|  25  |35|  45
SET _KN=
IF NOT %0==. IF NOT %8==. SET _KN=%_KN% %0%8
IF NOT %0==. IF NOT %6==. SET _KN=%_KN% %0%6
IF NOT %1==. IF NOT %9==. SET _KN=%_KN% %1%9
IF NOT %1==. IF NOT %5==. SET _KN=%_KN% %1%5
IF NOT %3==. IF NOT %9==. SET _KN=%_KN% %3%9
IF NOT %3==. IF NOT %5==. SET _KN=%_KN% %3%5
IF NOT %4==. IF NOT %8==. SET _KN=%_KN% %4%8
IF NOT %4==. IF NOT %6==. SET _KN=%_KN% %4%6
ECHO SET _KN=%_KN%

ECHO %%TEMP%%.\RTN.BAT
GOTO OUT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::: get input move routine ::::::::::::::::::::::::::::::

:: passes back variables:
::
::  M0,M1 = numeric source square  M0=column M1=row
::  L0    = alphabetic version of M0
::  M2,M3 = numeric target square  M2=column M3=row
::  L2    = alphabetic version of M2
::
::  ABORT = 'TRUE' if the user press ESC during input
::
::  the variable P on entry is a prompt string to use
::

:INPUT
ECHO.>CON
:LI0
CHOICE /CABCDEFGH%ESC% /N %ESC%[A%P%.%BS%>CON
IF ERRORLEVEL 9 GOTO ABORT
FOR %%_ IN (1 2 3 4 5 6 7 8) DO IF ERRORLEVEL %%_ SET M0=%%_
ECHO SET L0=%%%M0%>%TMP1%
CALL %TMP1% A B C D E F G H
ECHO SET M0=%M0%
ECHO SET L0=%L0%
:LI1
CHOICE /C12345678%ESC%%BS% /N %ESC%[A%P%%L0%.%BS%>CON
IF ERRORLEVEL 10 GOTO LI0
IF ERRORLEVEL 9 GOTO ABORT
FOR %%_ IN (1 2 3 4 5 6 7 8) DO IF ERRORLEVEL %%_ SET M1=%%_
ECHO SET M1=%M1%
:LI2
CHOICE /CABCDEFGH%ESC%%BS% /N %ESC%[A%P%%L0%%M1%-.%BS%>CON
IF ERRORLEVEL 10 GOTO LI1
IF ERRORLEVEL 9 GOTO ABORT
FOR %%_ IN (1 2 3 4 5 6 7 8) DO IF ERRORLEVEL %%_ SET M2=%%_
ECHO SET L2=%%%M2%>%TMP1%
CALL %TMP1% A B C D E F G H
ECHO SET M2=%M2%
ECHO SET L2=%L2%

CHOICE /C12345678%ESC%%BS% /N %ESC%[A%P%%L0%%M1%-%L2%>CON
IF ERRORLEVEL 10 GOTO LI2
IF ERRORLEVEL 9 GOTO ABORT
FOR %%_ IN (1 2 3 4 5 6 7 8) DO IF ERRORLEVEL %%_ SET M3=%%_
ECHO SET M3=%M3%
ECHO %ESC%[A%P%%L0%%M1%-%L2%%M3%>CON
ECHO SET ABORT=FALSE
EXIT

:ABORT
ECHO SET ABORT=TRUE
EXIT

::::::::::::::::::: auxillary to create batch to help display routine

:CVCHK
ECHO IF !%%_%3%%==!%%X%% SET _%3=%%SPC%%
SHIFT
IF NOT !%3==! GOTO CVCHK
EXIT

::::::::::::::::::: increment move count ::::::::::::::::::::::::::::

:INCMOVE
SET PREVMOVE=%MOVE%
SET PREVCOLR=%COLR%
IF NOT %COLR%==BLACK GOTO LA0
SET COLR=WHITE
:: every white move increment the move counter
ECHO %MOVE%* |%COM%/C %0 . GOTO:INC MOVE>%TMP0%
CALL %TMP0%
GOTO OUT
:LA0
SET COLR=BLACK
GOTO OUT

::::::::::::::::::: display chess board routine :::::::::::::::::::::

:DISPLAY

:: change vacant squares that are in blank areas to SPACE characters
CALL %TEMP%.\CVCHK$$.BAT

:: display board
ECHO %ESC%[H%FB%  %W%%W2%%W2%%W2%%W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%8 %W%%X%%_18%%X% %_28% %X%%_38%%X% %_48% %X%%_58%%X% %_68% %X%%_78%%X% %_88% %W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%7 %W% %_17% %X%%_27%%X% %_37% %X%%_47%%X% %_57% %X%%_67%%X% %_77% %X%%_87%%X%%W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%6 %W%%X%%_16%%X% %_26% %X%%_36%%X% %_46% %X%%_56%%X% %_66% %X%%_76%%X% %_86% %W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%5 %W% %_15% %X%%_25%%X% %_35% %X%%_45%%X% %_55% %X%%_65%%X% %_75% %X%%_85%%X%%W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%4 %W%%X%%_14%%X% %_24% %X%%_34%%X% %_44% %X%%_54%%X% %_64% %X%%_74%%X% %_84% %W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%3 %W% %_13% %X%%_23%%X% %_33% %X%%_43%%X% %_53% %X%%_63%%X% %_73% %X%%_83%%X%%W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%2 %W%%X%%_12%%X% %_22% %X%%_32%%X% %_42% %X%%_52%%X% %_62% %X%%_72%%X% %_82% %W%
ECHO %FB%  %W%%X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%1 %W% %_11% %X%%_21%%X% %_31% %X%%_41%%X% %_51% %X%%_61%%X% %_71% %X%%_81%%X%%W%
ECHO %FB%  %W%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%   %X%%X%%X%%W%
ECHO %FB%  %W%%W2%%W2%%W2%%W%
ECHO.
ECHO %FB%    A  B  C  D  E  F  G  H

EXIT

::::::::::::::::::: clear menu area and set cursor position to top:::

:CLRMENU

ECHO %ESC%[29;1H
SET X2=%X%%X%%X%%X%%X%%X%%X%%X%%X%%X%
SET X2=%X2%%X2%%X2%%X2%%X2%%X%%X%%X%%X%%X%%X%
ECHO %X2%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X%                                                      %X%
ECHO %X2%%ESC%[29;1H
GOTO OUT

::::::::::::::: increment value routine :::::::::::::::::::::::::::::

:INC # increment stdin value by 1 and return "SET %3=value+1"

FOR %%_ IN (V0 W0 V1 V2) DO SET %%_=
:L0
CHOICE /C*--------0123456789>NUL
IF NOT ERRORLEVEL 10 GOTO DONIT
FOR %%_ IN (0 1 2 3 4 5 6 7 8 9) DO IF ERRORLEVEL 1%%_ SET C=%%_
IF NOT ERRORLEVEL 19 SET V2=%V2%%V1%%V0%
IF NOT ERRORLEVEL 19 SET V1=%C%
IF NOT ERRORLEVEL 19 SET V0=
IF NOT ERRORLEVEL 19 SET W0=
IF ERRORLEVEL 19 SET V0=%V0%9
IF ERRORLEVEL 19 SET W0=%W0%0
GOTO L0
:DONIT
IF !%V1%==! SET V1=0
ECHO %V1%|CHOICE /C012345678>NUL
FOR %%_ IN (1 2 3 4 5 6 7 8 9) DO IF ERRORLEVEL %%_ SET V0=%V2%%%_%W0%
ECHO SET %3=%V0%
EXIT

::::::::::::::::::: routine for setting variables :::::::::::::::::::

:SETV
SET %3=%4
SHIFT
SHIFT
IF NOT !%3==! GOTO SETV
GOTO OUT

::::::::::::::::::: generalized output routine ::::::::::::::::::::::

:SEND
ECHO E0 %3 %4 %5 %6 %7 %8 %9 1A>%TMP1%
FOR %%_ IN (RCX FF N%TMP2% W0 Q) DO ECHO %%_>>%TMP1%
DEBUG>NUL <%TMP1%
TYPE %TMP2%
EXIT

::::::::::::::::::: enter board position ::::::::::::::::::::::::::::

:ENTER
SET M0=18
SET M2=88
SET POS=18
SET M1=!!!!!!!
SET M3=0

SET WHITEK=
SET BLACKK=

REM>%TMP3%
FOR %%_ IN (F100L100''20 N%TMP0% L) DO ECHO %%_>>%TMP3%
FOR %%_ IN (25 3C 3D 3E 7C 22) DO ECHO S100L100 %%_>>%TMP3%
FOR %%_ IN (E100'SET'20'_'3D W Q) DO ECHO %%_>>%TMP3%

CALL %0 . GOTO:CLRBOARD
SET _%POS%=%W%
%COM% /C %0 . GOTO:DISPLAY

:ENL
SET M1=!%M1%
IF NOT %M1%==!!!!!!!! GOTO ENR2
CALL %0 . GOTO:CLRMENU
ECHO.
IF %M3%==0 ECHO %X%  PIECE LETTER ENTERS PIECE, - DELETES
IF %M3%==0 ECHO %X%  1-8 ENTER CORRESPONDING NUMBER OF SPACES
IF %M3%==0 ECHO.
ECHO %X%  ENTER POSITION [SINGLE NEWLINE TERMINATES]
ECHO %ESC%[s

SET M1=
IF %M3%==0 SET M1=!!!
SET M3=1

:ENR2
%COM% /C %0 . GOTO:SEND 1B "[u%X%" 20 20 3A 20
FC /LB1 CON NUL |FIND /N /V "" |FIND /N "4">%TMP0%
DEBUG <%TMP3% |FIND ":" |FIND /N /V "" |FIND "[2]">NUL
IF NOT ERRORLEVEL 1 ECHO %X%  INVALID INPUT!
ECHO %ESC%[s
IF NOT ERRORLEVEL 1 GOTO ENL
CALL %TMP0%
IF !%_%==! GOTO ENDON

SET @=
ECHO %_%%%|%COM% /C %0 . GOTO:SPLIT>%TMP0%
CALL %TMP0%
CALL %0 . GOTO:ENR0 %@%
IF NOT !%POS%==! SET _%POS%=%W%

%COM% /C %0 . GOTO:DISPLAY

IF NOT !%POS%==! GOTO ENL

:ENDON

::   only allow positions with both kings!!
IF NOT !%POS%==! SET _%POS%=%X%
IF NOT !%POS%==! %COM% /C %0 . GOTO:DISPLAY

CHOICE /CBW %ESC%[u%X%  FIRST MOVE %=%
SET MOVE1=BLACK
IF ERRORLEVEL 2 SET MOVE1=WHITE

GOTO NEWGAME1

:ENR0
IF !%3==! GOTO OUT
IF %3==K SET WHITEK=%POS%
IF %3==k SET BLACKK=%POS%
CALL %DBFILE% GOTO:_%POS%
IF NOT %3==- GOTO ENR3
SET _%POS%=%X%
SET POS=%_W%
IF NOT !%_W%==! GOTO ENR1
CALL %DBFILE% GOTO:_%M0%
IF NOT !%_N%==! SET M0=%_N%
CALL %DBFILE% GOTO:_%M2%
IF NOT !%_N%==! SET M2=%_N%
SET POS=%M2%
GOTO ENR1

:ENR3
SET _%POS%=%3

SET POS=%_E%
IF NOT !%_E%==! GOTO ENR1
CALL %DBFILE% GOTO:_%M0%
SET M0=%_S%
CALL %DBFILE% GOTO:_%M2%
SET M2=%_S%
SET POS=%M0%
IF !%POS%==! GOTO OUT
:ENR1
SHIFT
GOTO ENR0

:SPLIT
CHOICE /S /C%%knqrpbKNQRPBBBBBBBB12345678->NUL
SET _=
IF ERRORLEVEL 2 SET _=k
IF ERRORLEVEL 3 SET _=n
IF ERRORLEVEL 4 SET _=q
IF ERRORLEVEL 5 SET _=r
IF ERRORLEVEL 6 SET _=p
IF ERRORLEVEL 7 SET _=b
IF ERRORLEVEL 8 SET _=K
IF ERRORLEVEL 9 SET _=N
IF ERRORLEVEL 10 SET _=Q
IF ERRORLEVEL 11 SET _=R
IF ERRORLEVEL 12 SET _=P
IF ERRORLEVEL 13 SET _=B
IF ERRORLEVEL 21 SET _=%X%
IF ERRORLEVEL 22 SET _=%X% %X%
IF ERRORLEVEL 23 SET _=%X% %X% %X%
IF ERRORLEVEL 24 SET _=%X% %X% %X% %X%
IF ERRORLEVEL 25 SET _=%X% %X% %X% %X% %X%
IF ERRORLEVEL 26 SET _=%X% %X% %X% %X% %X% %X%
IF ERRORLEVEL 27 SET _=%X% %X% %X% %X% %X% %X% %X%
IF ERRORLEVEL 28 SET _=%X% %X% %X% %X% %X% %X% %X% %X%
IF ERRORLEVEL 29 SET _=-

SET @=%@% %_%
IF ERRORLEVEL 2 GOTO SPLIT
ECHO SET @=%@%
EXIT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CLRBOARD
FOR %%_ IN (18 28 38 48 58 68 78 88) DO SET _%%_=%X%
FOR %%_ IN (17 27 37 47 57 67 77 87) DO SET _%%_=%X%
FOR %%_ IN (16 26 36 46 56 66 76 86) DO SET _%%_=%X%
FOR %%_ IN (15 25 35 45 55 65 75 85) DO SET _%%_=%X%
FOR %%_ IN (14 24 34 44 54 64 74 84) DO SET _%%_=%X%
FOR %%_ IN (13 23 33 43 53 63 73 83) DO SET _%%_=%X%
FOR %%_ IN (12 22 32 42 52 62 72 82) DO SET _%%_=%X%
FOR %%_ IN (11 21 31 41 51 61 71 81) DO SET _%%_=%X%
GOTO OUT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OUT