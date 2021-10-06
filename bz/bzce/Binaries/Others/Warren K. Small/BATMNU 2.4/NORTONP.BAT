@echo off
:: REM variation of NORTON.BAT using parameters on option line
:: REM also shows help line option and header option with time & date
goto start

:menu
  window, bcya, oBLU, kred°, s1, m5, a, ~
    h_format, bblu, t0, d0
    header,Norton Utilities
      option,Commander,,,,nc
        help,File Management
      option,Disk Doctor,,c:,\nu,ndd
        help,Disk Fixer
      option,Utilities,,c:,\nu,NORTON
        help,File Utilities
      option,Text Editor,e,,,nce
        help,Norton Classic Editor 
      option,Disk Editor,i,c:,\nu,diskedit
        help,Sector Editor
      option,Exit,x
    f_format, bblu
:End_menu
 
:start
batmnu nortonp.bat %ERRLEV%         
rem ERRLEV value sets default

if not "%ERRLEV%" == "" goto start  
rem if ERRLEV is set, redisplay menu

if errorlevel 6 goto EXIT           
rem Exit selected

if not errorlevel 1 goto EXIT       
rem ESC pressed

goto start

:EXIT
