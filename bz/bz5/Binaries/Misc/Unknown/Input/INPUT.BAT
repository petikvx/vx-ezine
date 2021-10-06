@ECHO OFF
REM INPUT.BAT - Returns a line of user input in
REM   environment variable MInput
> EN#ER.BAT  FC CON NUL /LB1 /N | DATE | FIND "    1:  "

> ENTER.BAT  ECHO SET MInput=
>>ENTER.BAT  ECHO :Loop
>>ENTER.BAT  ECHO IF NOT '%%MInput%%'=='' SET MInput=%%MInput%% %%5
>>ENTER.BAT  ECHO IF '%%MInput%%'=='' SET MInput=%%5
>>ENTER.BAT  ECHO SHIFT
>>ENTER.BAT  ECHO IF NOT '%%5'=='' GOTO Loop

CALL EN#ER.BAT
DEL EN?ER.BAT
