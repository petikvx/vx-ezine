@echo off
if %1.==. goto usage
%yasm%\yasm -m amd64 -f win32 -o %1.obj %1.asm
%yasm%\link %1.obj %lib%\kernel32.lib %lib%\user32.lib /section:.text,erw /entry:%2 /subsystem:console
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename entryname
echo eg. MAKE SHRUG64 SHRUG
echo requires %%yasm%% set to Bin directory
echo and %%lib%% set to Lib directory

:end
echo.
