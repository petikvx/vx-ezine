@ECHO OFF
REM ONCEAMON.BAT - Performs specified actions once a month
IF NOT '%2'=='' GOTO GotDate
ECHO @PROMPT %0 $d > C:\BAT\ONCE$$$1.BAT
REM DO NOT substitute CALL for COMMAND /C in next line
COMMAND /C C:\BAT\ONCE$$$1.BAT > C:\BAT\ONCE$$$2.BAT
C:\BAT\ONCE$$$2

:GotDate
REM Now %1 contains day of week, %2 contains date.
DEL C:\BAT\ONCE$$$?.BAT
IF EXIST C:\BAT\%2.DA¥ GOTO End
IF EXIST C:\BAT\*.DA¥ GOTO DayExists
REM If marker doesn't exist, create it.
REM > C:\BAT\XXXXXXXX.DA¥

:DayExists
RENAME C:\BAT\*.DA¥ %2.DA¥
ECHO.
ECHO Insert once-a-day activity here
ECHO.
IF NOT '%1'=='Fri' GOTO NotFriday
ECHO.
ECHO Insert only-on-Friday activity here
ECHO.

:NotFriday
SET Month=
SET WasDate=%2
REM Strip first char from Date
FOR %%v IN (/%WasDate%) DO SET Date=%%v
REM Add stripped first char to Month
FOR %%v IN (/%WasDate%) DO IF '%%v%Date%'=='%WasDate%' SET Month=%%v
SET WasDate=%Date%
REM Strip first char from Date
FOR %%v IN (/%WasDate%) DO SET Date=%%v
REM Add stripped first char to Month
FOR %%v IN (/%WasDate%) DO IF '%%v%Date%'=='%WasDate%' SET Month=%Month%%%v
SET WasDate=
SET Date=
REM Now variable Month contains the two-digit month
IF EXIST C:\BAT\%Month%$$$$$$.MOÑ GOTO End
IF EXIST C:\BAT\??$$$$$$.MOÑ GOTO MonExists
REM If marker doesn't exist, create it.
REM > C:\BAT\XX$$$$$$.MOÑ

:MonExists
CHOICE Perform once-a-month activity
IF ERRORLEVEL 2 GOTO End
RENAME C:\BAT\??$$$$$$.MOÑ %Month%$$$$$$.MOÑ
ECHO.
ECHO Insert once-a-month activity here.
ECHO.

:End
