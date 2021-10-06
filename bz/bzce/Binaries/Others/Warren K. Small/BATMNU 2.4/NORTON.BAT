@echo off
:: REM A menu within a batch file, errorlevel format
set def=
goto start

:menu
  window, fWHI, tYEL, kred°, s1, c
    title,Norton Utilities
      option,Commander
      option,Disk Doctor
      option,Utilities
      option,Text Editor,e
      option,Disk Editor,i
      option,Exit,x
:End_menu
 
:start
batmnu norton.bat %def%
if errorlevel 6 goto EXIT
if errorlevel 5 goto NDE
if errorlevel 4 goto NE
if errorlevel 3 goto NI
if errorlevel 2 goto NDD
if errorlevel 1 goto NC
if errorlevel 0 goto EXIT

:NC
set def=1
nc
goto start

:NDD
set def=2
c:
cd \nu
ndd
goto start

:NI
set def=3
c:
cd \nu
Norton
goto start

:NE
set def=4
nce
goto start

:NDE
set def=5
c:
cd \nu
diskedit
goto start

:EXIT
set def=
