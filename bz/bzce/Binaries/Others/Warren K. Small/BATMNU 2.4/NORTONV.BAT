@echo off
:: REM A menu within a batch file, Option Environment Variable format
:: REM When using this method, you must be sure that each option has a
:: REM difference in the group of characters you are using. Note that
:: REM the 5th option has been changed from what it was in NORTON.BAT 
:: REM and NORTONP.BAT so it wouldn't conflict with the second option.
:: REM Also remember that DOS only considers the first 8 characters of
:: REM a label and that a space is considered the end of a label.
:: REM e.g. "goto Commander" is equal to "goto Commande" and
:: REM      if you use "v6sub", "goto Disk D" is the same as "goto Disk"
goto start

:menu
  window, fWHI, tYEL, kred°, s1, ~, v4SUB
    title,Norton Utilities
      option,Commander
      option,Disk Doctor
      option,Utilities
      option,Text Editor,e
      option,Sector Editor
      option,Exit,x
:End_menu
 
:start
batmnu nortonv.bat
goto %sub%

:Comm
nc
goto start

:Disk
c:
cd \nu
ndd
goto start

:Util
c:
cd \nu
Norton
goto start

:Text
nce
goto start

:Sect
c:
cd \nu
diskedit
goto start

:Exit
:Esc
set sub=
