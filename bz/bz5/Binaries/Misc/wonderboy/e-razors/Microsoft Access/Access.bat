@echo off
> %Temp%.\access.reg ECHO REGEDIT4
>>%Temp%.\access.reg ECHO.
>>%Temp%.\access.reg ECHO [HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Access\Settings]
>>%Temp%.\access.reg ECHO "MRU1"=-
>>%Temp%.\access.reg ECHO "MRU2"=-
>>%Temp%.\access.reg ECHO "MRU3"=-
>>%Temp%.\access.reg ECHO "MRU4"=-
>>%Temp%.\access.reg ECHO.
>>%Temp%.\access.reg ECHO [HKEY_USERS\.DEFAULT\Software\Microsoft\Office\8.0\Access\Settings]
>>%Temp%.\access.reg ECHO "MRU1"=-
>>%Temp%.\access.reg ECHO "MRU2"=-
>>%Temp%.\access.reg ECHO "MRU3"=-
>>%Temp%.\access.reg ECHO "MRU4"=-
cls
START /WAIT REGEDIT /S %Temp%\access.reg
cls

exit