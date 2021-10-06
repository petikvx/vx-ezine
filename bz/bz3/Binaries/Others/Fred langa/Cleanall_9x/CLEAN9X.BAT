@echo off
cls
echo                  Fred Langa's CleanALL_9x.Bat,
echo           an improved Win9x hard-disk cleanup tool.
echo   ---------------------------------------------------------
echo            Copyright (c) 2002 Langa Consulting
echo                   http://www.langa.com
echo   ---------------------------------------------------------
echo       Use Notepad to view file contents before running!
echo       Only you can determine if the file contents and
echo       structure are OK to run on *your specific* setup.
echo   Info/Documentation/Etc: http://www.langa.com/clean9x.htm
echo                        -----------
::    This file is offered as-is and without warranty of any kind.
::    This file may redistributed as long as all header information
::    is retained in the final file. 
::    DO NOT PROCEED until and unless you have read the precaution/usage
::    info and checked for newer versions at http://www.langa.com/cleanup_bat.htm
echo This batch file aggressively cleans up all Temp files, compacts your
echo Registry and Cookies Index, empties the Temporary Internet File (TIF) area,
echo compacts your Icon Cache (by deletion) and then runs a disk-check utility in
echo order to verify that your hard drive is healthy after the cleanup operation.
echo .
echo Note 1: This file MUST be run from pure DOS, not from a DOS window. Note 2:
echo This file uses the standard DELTREE command usually found in Windows\Command.
echo Note 3: This file uses DOS environment variables to locate your Windows
echo and other directories. *Read this file* in Notepad or Edit to ensure
echo it will operate as intended.
::   (If you need help understanding DOS environment variables, READ THE
::   DOCUMENTATION LINKS on http://www.langa.com/cleanall_bat.htm, and
::   especially see http://www.langa.com/newsletters/2000/2000-09-18.htm#1 )
::   Please also note the COMMON SENSE PRECAUTIONS and legal information here:
::   http://www.langa.com/legal.htm . The information on that page is included
::   in this file by reference; and your use of this file indicates your acceptance
::   of responsibility for the use of this file. 
echo   ---------------------------------------------------------
echo If you haven't followed the instructions above, hit ctrl-c to abort; otherwise
pause
cls
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check that standard environment variables are in use and if not, abort
if %winbootdir% !==! goto noenv
if %temp% !==! goto noenv
if %tmp% !==! goto noenv
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: if the standard smartdrv disk cache is available, use it to speed things up
:: NOTE: Some systems actually work better WITHOUT smartdrv;
:: if you encounter trouble, place two colons "::" in front of the next line.
if exist %winbootdir%\smartdrv.exe %winbootdir%\smartdrv.exe 2048 16
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Next line catches missing/nonstandard deltree directory
if not exist %winbootdir%\command\deltree.exe goto nodeltree
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: The next lines wipe out the temp directories in standard locations
deltree /y %winbootdir%\temp\
deltree /y %winbootdir%\tmp\
deltree /y c:\tmp\
deltree /y c:\temp\
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: The next lines wipe out the temp directories in nonstandard locations
:: as long as they are aliased in the environmental variables
:: (may repeat actions of previous deltree operations, but no harm is done)
deltree /y %temp%\
deltree /y %tmp%\
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Next line kills garbage files that Office leaves behind
del %winbootdir%\ff*.tmp
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Next line erases the icon cache, saving some resources on restart
if exist %winbootdir%\ShellI~1\ deltree /y %winbootdir%\ShellI~1
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
:: if scanreg is available, use it to optimize the registry;
:: if you have trouble with this command, see
:: http://www.langa.com/newsletters/2000/2000-10-05.htm#2
if exist %winbootdir%\command\scanreg.exe %winbootdir%\command\scanreg.exe /opt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: edit this section to invoke the drive-check utility of your choice
:: by placing double colons "::" in front of any lines you DON'T
:: want to run, and removing the colons from any line you DO want to run.
:: By default, Windows' own Scandisk is enabled as follows
scandisk /all /autofix /nosummary
:: if you prefer Norton Disk Doctor, and have it installed,
:: disable the Scandisk line, above, and remove the colons
:: in front of the following line
:: ndd c: /q
:: you also may edit the Norton command any way you wish, or 
:: add commands for any other disk checker you prefer
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:end
echo Done. Please reboot now.
exit