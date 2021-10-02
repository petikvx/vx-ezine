@echo off
if %1.==. goto usage
%ias%\ias %1.asm
%ias%\link %1.obj %lib%\kernel32.lib %lib%\user32.lib /section:.text,erw /entry:%2 /subsystem:console
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename entryname
echo eg. MAKE SHRUG64 SHRUG
echo requires %%ias%% set to Bin directory (eg C:\PROGRA~1\MICROSOFT SDK\BIN\WIN64)
echo and %%lib%% set to Lib directory (eg C:\PROGRA~1\MICROSOFT SDK\LIB\IA64)

:end
echo.
