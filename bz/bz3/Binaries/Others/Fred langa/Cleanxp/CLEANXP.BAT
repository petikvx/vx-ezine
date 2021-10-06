@echo off
cls
echo         Fred Langa's CleanXP Script For WinME/2K/XP
echo   ---------------------------------------------------------
echo         Copyright (c) 2002 Langa Consulting
echo                   http://www.langa.com
echo   ---------------------------------------------------------
echo   Use Notepad to view this script's contents before running!
echo       Only you can determine if the file contents and
echo       structure are OK to run on *your specific* setup.
echo                   Info/Documentation/Etc:
echo     http://www.langa.com/newsletters/2002/2002-04-04.htm
echo                        -----------
::  This file is offered as-is and without warranty of any kind.
::  
::  Please note that this is NOT a finished, ready-to-run tool, but is
::  a kind of template you can use to *create* a custom tool that’s specific to
::  your own particular setup and needs. PLEASE follow the instructions in the
::  link above and inside the rest of this file to ensure that the file
::  contents and structure are OK to run on *your specific* setup.
::  
::  Because I don't know your system or setup or needs, I regret that I cannot
::  offer one-on-one advice on modifying the script for your particular system.
::  But you can find all you need via the info above. Or, if you’re new to batch files,
::  check out http://content.techweb.com/winmag/columns/explorer/2000/21.htm .
::  Combined, those links either directly contain everything you need to know about
::  working with this batch file, or have pointers to other sites that will tell you
::  all you need to know. 
::  
::  Legal Info: Your use of this file constitutes your acknowledgement and acceptance of the
::  disclaimers at http://www.langa.com/legal.htm#Disclaimer, which are incorporated
::  into this file by reference.
::  
::  This file may be redistributed as long as all header/footer information
::  is retained in the final file, and as long as all user modifications are noted.
::
::
echo This script silently deletes all files--- including read-only files! ---
echo          from the designated directories and subdirectories. 
echo   ---------------------------------------------------------
echo DO NOT PROCEED until and unless you have read the precaution/usage
echo         info inside this file and at the site above.
echo   ---------------------------------------------------------
echo Hit ctrl-c to abort this script; or, if you have fully examined this file and
echo you know it's OK to run your system, then
pause
:: for automatic operation, delete the "pause" above 
   cls
:: cls line clears the screen
::
::
:: next lines switch to C: drive, change to first folder where you want to delete files
   c:
   cd "C:\Documents and Settings\[username]\Local Settings\Temp"
:: edit the line above with the correct path and name of the first directory/folder you want to clean out
::
::
:: XP/2k ONLY:
:: if you're using WinXP/2K, REMOVE the two colons from the front of the "del /p /s /f *.*" line below 
:: del /p /s /f *.*
:: After you run CleanXP and are sure that you're deleting the correct files, you can change the /p to /q for faster, no-prompt deletions
::
::
::
:: WinME ONLY:
:: if you're using WinME, REMOVE the two colons from the front of the "deltree *.*" line below 
:: deltree *.*
:: After you run CleanXP and are sure that you're deleting the correct files, add a "/y" to the line above, thus: "deltree /y *.*" (minus the quotes) for faster, no-prompt deletions
::
::
:: ALL VERSIONS--- now change to next folder where you want to delete files
   cd "C:\Documents and Settings\[username]\Local Settings\Temporary Internet Files"
:: edit the line above with the correct path and name of the next directory/folder you want to clean out
::
::
::
:: XP/2k ONLY:
:: if you're using WinXP/2K, REMOVE the two colons from the front of the "del /p /s /f *.*" line below 
:: del /p /s /f *.*
:: After you run CleanXP and are sure that you're deleting the correct files, you can change the /p to /q for faster, no-prompt deletions
::
::
::
:: WinME ONLY:
:: if you're using WinME, REMOVE the two colons from the front of the "deltree *.*" line below 
:: deltree *.*
:: After you run CleanXP and are sure that you're deleting the correct files, add a "/y" to the line above, thus: "deltree /y *.*" (minus the quotes) for faster, no-prompt deletions
::
::
::
:: ALL VERSIONS---
:: For each additional folder/directory you wish to clean out, repeat the above pattern: Add a CD "FULL PATH TO FOLDER WITH FILES TO DELETE" followed by either the DEL or DELTREE command (as above) according to which operating system you're running.
:: Of course, you replace "FULL PATH TO FOLDER WITH FILES TO DELETE" with the actual path and name of a folder whose contents you want to delete
:: There is no limit to the number of folders/directories you can process this way.
::
::
::
:: ALL VERSIONS---
   cleanmgr /sagerun:99
:: The above line assumes you've previously run a "cleanmgr /sageset:99" command. See full instructions.
::
exit