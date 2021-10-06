@echo off
cls
> "%Temp%.\typed47.reg" ECHO REGEDIT4
cls
>>"%Temp%.\typed47.reg" ECHO.
cls
>>"%Temp%.\typed47.reg" ECHO [-HKEY_USERS\.DEFAULT\Software\Microsoft\Internet Explorer\TypedURLs]
cls
>>"%Temp%.\typed47.reg" ECHO [-HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TypedURLs]
cls
START /WAIT REGEDIT /S %TEMP%.\TYPED47.REG
cls
> %Temp%.\MRU.reg ECHO REGEDIT4
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Explorer Bars\{C4EE31F3-4768-11D2-BE5C-00A0C9A83DA1}\FilesNamedMRU]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Applets\Wordpad\Recent File List]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List]
cls
>>%Temp%.\MRU.reg ECHO.
cls
>>%Temp%.\MRU.reg ECHO [-HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU]
cls
START /WAIT REGEDIT /S %Temp%\MRU.reg
cls
del %Temp%\MRU.reg
cls
deltree /Y C:\windows\cookies\
cls
move /Y C:\windows\tempor~1\*.* C:\Windows\Temp
cls
deltree /Y C:\windows\temp\
cls
deltree /Y C:\windows\recent\
cls
del C:\Progra~1\Common~1\Real\Common\cookies.txt
cls
deltree /Y C:\windows\applic~1\tempor~1\
cls
deltree /Y C:\windows\locals~1\tempor~1\
cls
attrib -s -h C:\windows\tempor~1\mm256.dat
cls
del c:\windows\tempor~1\mm256.dat
cls
attrib -s -h C:\windows\tempor~1\mm2048.dat
cls
del c:\windows\tempor~1\mm2048.dat
cls
attrib -s -h C:\windows\tempor~1\content.ie5\mm256.dat
cls
del c:\windows\tempor~1\content.ie5\mm256.dat
cls
attrib -s -h C:\windows\tempor~1\content.ie5\mm2048.dat
cls
del C:\windows\tempor~1\content.ie5\mm2048.dat
cls
del C:\WINDOWS\Applic~1\Mozilla\Profiles\default\juoaqjhw.slt\cookies.txt
cls
del C:\WINDOWS\Applic~1\Mozilla\Profiles\default\juoaqjhw.slt\downloads.rdf
cls
del C:\WINDOWS\Applic~1\Mozilla\Profiles\default\juoaqjhw.slt\history.dat
cls
deltree /Y C:\WINDOWS\Applic~1\Mozilla\Profiles\default\juoaqjhw.slt\Cache\
cls
deltree /Y C:\Windows\CONFIG\
cls
del C:\WINDOWS\Applic~1\Microsoft\Intern~1\UserData\index.dat
cls
start inetcpl.cpl
cls

exit