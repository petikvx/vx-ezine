@echo off
> %Temp%.\powerpoint.reg ECHO REGEDIT4
>>%Temp%.\powerpoint.reg ECHO.
>>%Temp%.\powerpoint.reg ECHO [HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\PowerPoint\Recent File List]
>>%Temp%.\powerpoint.reg ECHO "File1"=-
>>%Temp%.\powerpoint.reg ECHO "File2"=-
>>%Temp%.\powerpoint.reg ECHO "File3"=-
>>%Temp%.\powerpoint.reg ECHO "File4"=-
>>%Temp%.\powerpoint.reg ECHO "File5"=-
>>%Temp%.\powerpoint.reg ECHO "File6"=-
>>%Temp%.\powerpoint.reg ECHO "File7"=-
>>%Temp%.\powerpoint.reg ECHO "File8"=-
>>%Temp%.\powerpoint.reg ECHO "File9"=-
>>%Temp%.\powerpoint.reg ECHO "File0"=-
cls
START /WAIT REGEDIT /S %Temp%\powerpoint.reg
cls

exit