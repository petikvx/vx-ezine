@echo off
cls
echo   Fred Langa's Cleanup.Bat, a Win9* hard-disk cleanup tool.
echo                        Expert Version
echo   ---------------------------------------------------------
echo            Copyright (c) 2002 Langa Consulting
echo                   http://www.langa.com
echo   ---------------------------------------------------------
echo       Use Notepad to view file contents before running!
echo       Only you can determine if the file contents and
echo       structure are OK to run on *your specific* setup.
echo          See http://www.langa.com/cleanup_bat.htm
echo       for precaution/usage info and for newer versions.
echo                        -----------
::    This file is offered as-is and without warranty of any kind.
::    This file may redistributed as long as this header information
::    is retained in the final file. 
:: 
echo   This batch file aggressively cleans up all Temp/Tmp files in windows.
echo   Note 1: All other apps should be closed before running this.
echo   Note 2: This file uses environmental variables to locate
echo   your Windows home directory and the temp directories.
echo   *Read this file* in Notepad or Edit for more information.
::     DO NOT PROCEED until and unless you have read the precaution/usage
::     info and checked for newer versions at http://www.langa.com/cleanup_bat.htm
::     If the variable %winbootdir% does not point to your windows
::     home directory, edit this file and replace %winbootdir% with the 
::     full path to your windows home directory, such as c:\windows
::     If the variables %temp% and %tmp% do not point to your windows
::     temp directories, edit this file and replace those variables with the 
::     full path to your windows temp directories, such as c:\windows\temp
::   (For specific help with DOS environment variables, READ THE
::   DOCUMENTATION LINKS on http://www.langa.com/cleanup_bat.htm, and
::   especially see http://www.langa.com/newsletters/2000/2000-09-18.htm#1 )
::   Please also note the COMMON SENSE PRECAUTIONS and legal information here:
::   http://www.langa.com/legal.htm . The information on that page is included
::   in this file by reference; and your use of this file indicates your acceptance
::   of responsibility for the use of this file. 
echo   ---------------------------------------------------------
echo If you haven't followed the instructions above, hit ctrl-c to abort; otherwise
pause
:: The next lines wipe out the temp directories in standard locations
deltree /y %winbootdir%\temp\
deltree /y %winbootdir%\tmp\
deltree /y c:\tmp\
deltree /y c:\temp\
:: The next lines wipe out the temp directories in nonstandard locations
:: as long as they are aliased in the environmental variables
:: (may repeat actions of previous deltree operations, but no harm is done)
:: BEFORE RUNNING, ENSURE THAT YOUR TEMP AND TMP VARIABLES ARE CORRECTLY SET
deltree /y %temp%\
deltree /y %tmp%\
:: Next lines delete possibly-large "orphan" files that sometimes 
:: get placed inappropriately in the "temporary internet files" directory
:: starting with the most-common location for those files.
:: Note: it does NOT clean out files that actually belong in the TIF.
if not exist %winbootdir%\tempor~1\*.* goto jump1
if exist %winbootdir%\tempor~1\*.zip del %winbootdir%\tempor~1\*.zip
if exist %winbootdir%\tempor~1\*.exe del %winbootdir%\tempor~1\*.exe
if exist %winbootdir%\tempor~1\*.gif del %winbootdir%\tempor~1\*.gif
if exist %winbootdir%\tempor~1\*.jpg del %winbootdir%\tempor~1\*.jpg
if exist %winbootdir%\tempor~1\*.png del %winbootdir%\tempor~1\*.png
if exist %winbootdir%\tempor~1\*.bmp del %winbootdir%\tempor~1\*.bmp
if exist %winbootdir%\tempor~1\*.avi del %winbootdir%\tempor~1\*.avi
if exist %winbootdir%\tempor~1\*.mpg del %winbootdir%\tempor~1\*.mpg
if exist %winbootdir%\tempor~1\*.mpeg del %winbootdir%\tempor~1\*.mpeg
if exist %winbootdir%\tempor~1\*.ra  del %winbootdir%\tempor~1\*.ra
if exist %winbootdir%\tempor~1\*.ram del %winbootdir%\tempor~1\*.ram
if exist %winbootdir%\tempor~1\*.mp3 del %winbootdir%\tempor~1\*.mp3
if exist %winbootdir%\tempor~1\*.mov del %winbootdir%\tempor~1\*.mov
if exist %winbootdir%\tempor~1\*.qt del %winbootdir%\tempor~1\*.qt
if exist %winbootdir%\tempor~1\*.asf del %winbootdir%\tempor~1\*.asf
:jump1
:: cleans the second most-likely temp file location, if it exists
if not exist %winbootdir%\locals~1\tempor~1\*.* goto jump2
if exist %winbootdir%\locals~1\tempor~1\*.zip del %winbootdir%\locals~1\tempor~1\*.zip
if exist %winbootdir%\locals~1\tempor~1\*.exe del %winbootdir%\locals~1\tempor~1\*.exe
if exist %winbootdir%\locals~1\tempor~1\*.gif del %winbootdir%\locals~1\tempor~1\*.gif
if exist %winbootdir%\locals~1\tempor~1\*.jpg del %winbootdir%\locals~1\tempor~1\*.jpg
if exist %winbootdir%\locals~1\tempor~1\*.png del %winbootdir%\locals~1\tempor~1\*.png
if exist %winbootdir%\locals~1\tempor~1\*.bmp del %winbootdir%\locals~1\tempor~1\*.bmp
if exist %winbootdir%\locals~1\tempor~1\*.avi del %winbootdir%\locals~1\tempor~1\*.avi
if exist %winbootdir%\locals~1\tempor~1\*.mpg del %winbootdir%\locals~1\tempor~1\*.mpg
if exist %winbootdir%\locals~1\tempor~1\*.mpeg del %winbootdir%\locals~1\tempor~1\*.mpeg
if exist %winbootdir%\locals~1\tempor~1\*.ra del %winbootdir%\locals~1\tempor~1\*.ra
if exist %winbootdir%\locals~1\tempor~1\*.ram del %winbootdir%\locals~1\tempor~1\*.ram
if exist %winbootdir%\locals~1\tempor~1\*.mp3 del %winbootdir%\locals~1\tempor~1\*.mp3
if exist %winbootdir%\locals~1\tempor~1\*.asf del %winbootdir%\locals~1\tempor~1\*.asf
if exist %winbootdir%\locals~1\tempor~1\*.qt del %winbootdir%\locals~1\tempor~1\*.qt
if exist %winbootdir%\locals~1\tempor~1\*.mov del %winbootdir%\locals~1\tempor~1\*.mov
:jump2
::  Next line kills garbage files that Office leaves behind in c:\windows
del %winbootdir%\ff*.tmp
::  Next line erases the icon cache, saving some resources on restart
if exist %winbootdir%\ShellIconCache deltree /y %winbootdir%\ShellI~1
cls
echo Done! For best results, reboot.