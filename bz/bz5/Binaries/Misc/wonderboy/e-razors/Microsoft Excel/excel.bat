@echo off
> %Temp%.\excel.reg ECHO REGEDIT4
>>%Temp%.\excel.reg ECHO.
>>%Temp%.\excel.reg ECHO [HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Excel\Recent File List]
>>%Temp%.\excel.reg ECHO "File1"=-
>>%Temp%.\excel.reg ECHO "File2"=-
>>%Temp%.\excel.reg ECHO "File3"=-
>>%Temp%.\excel.reg ECHO "File4"=-
>>%Temp%.\excel.reg ECHO "File5"=-
>>%Temp%.\excel.reg ECHO "File6"=-
>>%Temp%.\excel.reg ECHO "File7"=-
>>%Temp%.\excel.reg ECHO "File8"=-
>>%Temp%.\excel.reg ECHO "File9"=-
>>%Temp%.\excel.reg ECHO.
>>%Temp%.\excel.reg ECHO [HKEY_USERS\.DEFAULT\Software\Microsoft\Office\8.0\Excel\Recent File List]
>>%Temp%.\excel.reg ECHO "File1"=-
>>%Temp%.\excel.reg ECHO "File2"=-
>>%Temp%.\excel.reg ECHO "File3"=-
>>%Temp%.\excel.reg ECHO "File4"=-
>>%Temp%.\excel.reg ECHO "File5"=-
>>%Temp%.\excel.reg ECHO "File6"=-
>>%Temp%.\excel.reg ECHO "File7"=-
>>%Temp%.\excel.reg ECHO "File8"=-
>>%Temp%.\excel.reg ECHO "File9"=-
cls
START /WAIT REGEDIT /S %Temp%\excel.reg
cls

exit