@echo off
rem menu-selector batch
rem
rem ------- place for init routines -------
rem mouse
rem ---------------------------------------
:new
rem menu-call
BMENU.EXE MENU.DAT
rem BMENU.EXE %1  REM for sub-calling ( replace in line bevore )
if errorlevel 16 goto m16
if errorlevel 15 goto m15
if errorlevel 14 goto m14
if errorlevel 13 goto m13
if errorlevel 12 goto m12
if errorlevel 11 goto m11
if errorlevel 10 goto m10
if errorlevel 9 goto m9
if errorlevel 8 goto m8
if errorlevel 7 goto m7
if errorlevel 6 goto m6
if errorlevel 5 goto m5
if errorlevel 4 goto m4
if errorlevel 3 goto m3
if errorlevel 2 goto m2
if errorlevel 1 goto m1
if errorlevel 0 goto end
:m16
goto new
:m15
goto new
:m14
goto new
:n13
goto new
:m12
goto new
:m11
goto new
:m10
goto new
:m9
goto new
:m8
goto new
:m7
goto new
:m6
goto new
:m5
goto new
:m4
goto new
:m3
goto new
:m2
goto new
:m1
rem ----- place orders for selection 1 here ------
rem please do not forget to jump back to the calling directory
rem example call from C:\
rem C:
rem CD \WORD
rem WORD.EXE
rem C:
rem CD \
rem ----- end of orders -----
goto new
:end
rem ----- place for final orders -----
rem C:
rem CD \
rem ----------------------------------
