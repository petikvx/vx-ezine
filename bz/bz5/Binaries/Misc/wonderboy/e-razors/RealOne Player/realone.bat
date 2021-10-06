@echo off
cls
> %Temp%.\realone.reg ECHO REGEDIT4
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips1]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips2]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips3]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips4]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips5]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips6]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips7]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
>>%Temp%.\realone.reg ECHO [HKEY_CURRENT_USER\Software\RealNetworks\RealPlayer\6.0\Preferences\MostRecentClips8]
>>%Temp%.\realone.reg ECHO @=""
>>%Temp%.\realone.reg ECHO.
cls
START /WAIT REGEDIT /S %Temp%\realone.reg
cls

exit