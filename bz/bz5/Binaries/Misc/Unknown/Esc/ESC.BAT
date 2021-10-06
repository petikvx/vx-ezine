@ECHO OFF
ECHO.
ECHO Select a drive for (simulated) Backup.
ECHO.
ECHO   [C] Backup C: Drive
ECHO   [D] Backup D: Drive
ECHO   [E] Backup E: Drive

REM {esc} in next line to be replaced by Escape character
CHOICE /c:cde /n "Enter your choice, ESC exits: "
IF ERRORLEVEL 4 GOTO Terminate
IF ERRORLEVEL 0 IF NOT ERRORLEVEL 1 GOTO Terminate
IF ERRORLEVEL 1 SET DRV=C
IF ERRORLEVEL 2 SET DRV=D
IF ERRORLEVEL 3 SET DRV=E

ECHO Now simulating backup of drive %drv%:
GOTO Exit

:Terminate
ECHO Operation terminated by user

:Exit
