@echo off
:: REM variation of NORTONP.BAT using automatic Extended Option Help.
set def=
goto start

:menu
  window, fWHI, tYEL, kred°, s1, c5, auto_help, ~
    h_format, bblu, t1, d0
    header,Norton Utilities
      option,Commander,,,,nc
        help,:NC_Hlp
      option,Disk Doctor,,c:,\nu,ndd
        help,:NDD_Hlp
      option,Utilities,,c:,\nu,NORTON
        help,:Norton_Hlp
      option,Text Editor,e,,,nce
        help,:NE_Hlp
      option,Disk Editor,i,c:,\nu,diskedit
        help,:DE_Hlp
      option,Exit,x
        help,:Exit_Hlp
    f_format, bblu
    footer,Menu Example using Automatic Extended Help
:End_menu

:NC_Hlp
  window, fBLU, bwhi, tred, oblu, c38
    File and directory management
    using 2 side-by-side displays
    that can be sorted in a variety
    of ways. All DOS file functions
    are just a keystroke away.
:End_NC_Hlp

:NDD_Hlp
  window, fBLU, bwhi, tred, oblu, c37
    Automatically detect and correct
    physical and logical disk errors.
    Works on floppies and hard disks.
:End_NDD_Hlp

:Norton_Hlp
  window, fBLU, bwhi, tred, oblu, c39
    A collection of utilities for
    rescuing damaged disks and 
    files, providing safe file 
    deleting and recovery, batch
    file enhancements and more.
:End_Norton_Hlp

:NE_Hlp
  window, fBLU, bwhi, tred, oblu, c36
    Edit ASCII files. Word processing
    features like search and replace,
    paragraph and page formatting.
:End_NE_Hlp

:DE_Hlp
  window, fBLU, bwhi, tred, oblu, c35
    View and edit the entire contents
    of a diskette or hard disk,
    including disks that DOS cannot
    recognize or access. Repair or
    rescue damaged files or their data.
:End_DE_Hlp

:Exit_Hlp
  window, fBLU, bwhi, tred, oblu, c41
    If you can't guess what
    this does, hang it up!
:End_Exit_Hlp

:start
batmnu nortonh.bat %errlev%
:: REM ERRLEV value sets default

if not %ERRLEV%!==! goto start  
:: REM if ERRLEV is set, redisplay menu

if errorlevel 6 goto EXIT           
:: REM Exit selected

if not errorlevel 1 goto EXIT       
:: REM ESC pressed

goto start

:Exit
