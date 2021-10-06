@echo off
cls
> %Temp%.\mediaplayer.reg ECHO REGEDIT4
>>%Temp%.\mediaplayer.reg ECHO.
>>%Temp%.\mediaplayer.reg ECHO [HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentFileList]
>>%Temp%.\mediaplayer.reg ECHO "File0"=-
>>%Temp%.\mediaplayer.reg ECHO "File1"=-
>>%Temp%.\mediaplayer.reg ECHO "File2"=-
>>%Temp%.\mediaplayer.reg ECHO "File3"=-
>>%Temp%.\mediaplayer.reg ECHO "File4"=-
>>%Temp%.\mediaplayer.reg ECHO "File5"=-
>>%Temp%.\mediaplayer.reg ECHO "File6"=-
>>%Temp%.\mediaplayer.reg ECHO "File7"=-
>>%Temp%.\mediaplayer.reg ECHO "File8"=-
>>%Temp%.\mediaplayer.reg ECHO "File9"=-
cls
START /WAIT REGEDIT /S %Temp%\mediaplayer.reg
cls

exit