@echo off
cls
echo   Fred Langa's WipeTIF.Bat, a Win98 hard-disk cleanup tool.
echo   ---------------------------------------------------------
echo            Copyright (c) 2002 Langa Consulting
echo                   http://www.langa.com
echo   ---------------------------------------------------------
echo       Use Notepad to view file contents before running!
echo       Only you can determine if the file contents and
echo       structure are OK to run on *your specific* setup.
echo          See http://www.langa.com/wipetif_bat.htm
echo       for precaution/usage info and for newer versions.
echo                        -----------
::    This file is offered as-is and without warranty of any kind.
::    This file may redistributed as long as this header information
::    is retained in the final file. 
::  DO NOT PROCEED until and unless you have read the precaution/usage
::  info and checked for newer versions at http://www.langa.com/wipetif_bat.htm
::   Please also note the COMMON SENSE PRECAUTIONS and legal information here:
::   http://www.langa.com/legal.htm . The information on that page is included
::   in this file by reference; and your use of this file indicates your acceptance
::   of responsibility for the use of this file. 
echo This batch file compacts your Cookies index and cleans out
echo the Temporary Internet File (TIF) area. Note 1: This file MUST
echo be run from pure DOS, not from a DOS window. Note 2: This file
echo uses the DELTREE command; it must be present and accessible (in
echo the path) from DOS. Note 3: This file uses environmental variables
echo to locate your Windows home directory and other directories. 
echo *Read this file* in Notepad or Edit to ensure it will operate as
echo intended on your system!
echo   ---------------------------------------------------------
echo If you haven't followed the instructions above, hit ctrl-c to abort; otherwise
pause
cls
::  (If you need help understanding DOS environment variables, READ THE
::  DOCUMENTATION LINKS at http://www.langa.com/wipetif_bat.htm and
::  especially see http://www.langa.com/newsletters/2000/2000-09-18.htm#1 )
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check that standard environment variables are in use and if not, abort
if %winbootdir% !==! goto noenv
if %temp% !==! goto noenv
if %tmp% !==! goto noenv
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: if the standard smartdrv disk cache is available, use it to speed things up
if exist %winbootdir%\smartdrv.exe %winbootdir%\smartdrv.exe 2048 16
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Next line catches missing/nonstandard deltree directory
if not exist %winbootdir%\command\deltree.exe goto nodeltree
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Next line catches missing/nonstandard cookies directory
if not exist %winbootdir%\cookies\*.* goto nocookie
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Next line deletes index.dat in the normal cookies directory
deltree /y %winbootdir%\cookies\index.dat
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Next line checks for, processes standard TIF
if exist %winbootdir%\tempor~1\*.* goto cleantif1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: If no standard TIF, next line checks for the alternate TIF
:: and if 2nd TIF missing, then no TIF has been found; abort
if not exist %winbootdir%\locals~1\tempor~1\*.* goto notif
:: But if 2nd TIF exists, process it
goto cleantif2
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: this line should never run, but is here for completeness
goto end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:noenv
:: noenv runs if env variables aren't in use
cls 
echo Error! 
echo There's a problem with one or more of your environment variables.
echo Batch process aborted. No files deleted.
echo Please edit this file manually to insert the correct path
echo to the referenced directories.
pause
goto end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:nodeltree
:: nodeltree runs if deltree can't be located
cls 
echo Error! %winbootdir%\command\deltree.exe not found. No files deleted.
echo Please edit this file manually to insert the correct path
echo to your copy of Deltree.exe.
pause
goto end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:nocookie
:: nocookie runs if the cookies directory can't be located
cls 
echo Error! %winbootdir%\cookies\ not found. No cookie or TIF files deleted.
echo Please edit this file manually to insert the correct path
echo to your Cookie directory.
pause
goto end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:notif
:: notif runs if the TIF can't be located in either standard location
cls
echo Error! Cannot locate TIF! No TIF files deleted.
echo Please edit this file manually to insert the correct path
echo to your TIF directory.
pause
goto end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:cleantif1
:: cleantif1 deletes the TIF if in the standard location
if exist %winbootdir%\tempor~1\*.* deltree /y %winbootdir%\tempor~1\
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:cleantif2
:: cleantif2 deletes the TIF if in the usual alternate location
if exist %winbootdir%\locals~1\tempor~1\*.* deltree /y %winbootdir%\locals~1\tempor~1\
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:end
echo Done. Please reboot now.
exit
