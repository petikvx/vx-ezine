REM ===== UNHAPPY.BAT =============
REM This batch file is used to remove the Happy99 worm
REM Recommendation: Keep it on a boot floppy for disinfection purposes
REM and run after booting from the boot floppy.
C:
CD \Windows\SYSTEM
CLS
DEL SKA.EXE
DEL SKA.DLL
IF NOT EXIST WSOCK32.SKA GOTO SavedIt
DEL WSOCK32.DLL
RENAME WSOCK32.SKA WSOCK32.DLL
:SavedIt
PAUSE
@ECHO OFF
ECHO.
ECHO.
ECHO The following files (if any) many need to be deleted too.
ECHO Be sure you know what they are before you delete them!
ECHO (You might want to copy them to 
DIR *.SKA /w
