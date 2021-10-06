echo off
cls
echo ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo บ  WOULD YOU LIKE TO SCAN YOUR COMPUTER FOR VIRUSES? [Y/N]       บ
echo ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
choice /c:yn /t:y,10
if errorlevel 2 goto error2
if errorlevel 1 goto error1
goto end

:error2
copy o:BANNER.TXT k:\    >nul
goto end

:error1
goto end

:end
