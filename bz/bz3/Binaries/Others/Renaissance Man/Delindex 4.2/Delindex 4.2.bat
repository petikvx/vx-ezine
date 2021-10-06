:: ษอออออออออออออออออออออออป
:: บ  WELCOME to DELINDEX! บ
:: ศอออออออออออออออออออออออผ
::
:: The blank lines before (sub-)sections and labels are for readability.
:: Comments after :: explain programming logic; non-programming explanations
:: are in :NOTES so they can be viewed in Additional Notes. All menus default
:: to Quit after 99 seconds.
::
:: DEL is used when certain files need to be protected; DELTREE is used for all
:: other files & folders because it never gives a file not found message and it
:: can delete hidden, system, & read only files, and folders that are not empty.
::
:: 95% of this was typed in QEdit Advanced v3.0C (now TSE Jr, semware.com). I
:: also use EditPad Lite (free, jgsoft.com), but QEdit made box drawing/ascii
:: characters easy, and it works with LIST (buerg.com). LIST is THE best DOS
:: file manager/viewer extant; I wouldn't have created DELINDEX without it.
::
:: "The beauty of doing things with DOS batch language is the inherent
:: simplicity & elegance of the limited command set. The challenge is in using
:: these limited commands to accomplish whatever task you might dream up!"
:: --Eric Phelps (ericphelps.com)
::
@echo off
:: This makes the program run faster:
lh c:\windows\smartdrv.exe 4096 16>nul
if "%1"=="delta" goto DELTA
if "%1"=="DELTA" goto DELTA
c:
cd\
cls
set RenMan=%path%
set path=%path%;c:;c:\windows\command
deltree /y c:\RenMan.*>nul
if "%1"=="add" goto ADD
if "%1"=="ADD" goto ADD
REM>c:\RenMan.c2
mem /c|find "ANSI">nul
if errorlevel 1 del c:\RenMan.c2
if "%1"=="notes" goto NOTES
if "%1"=="NOTES" goto NOTES
if "%1"=="run" goto RUN
if "%1"=="RUN" goto RUN
::
:HDR
if exist c:\RenMan.c2 goto ANSI
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ      DELINDEX.BAT 4.2    09/23/2002    Written by Renaissance Man      บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
goto HDRX
:ANSI
echo [44m[2J[1B[1;35;46m   [36m[37m  DELINDEX.BAT 4.2      09/23/02      Written by Renaissance Man   [37m[36m[35m  [0;44m
::
:HDRX
if exist c:\RenMan.m2 goto MENU2
if exist c:\RenMan.r2 goto RUN2
if exist c:\RenMan.n2 goto NOTES2
if exist c:\RenMan.a2 goto ADD2
if exist c:\RenMan.e2 goto END2
if exist c:\RenMan.i2 goto INTRO2
if exist c:\RenMan.a2 goto ADD2
::
echo   DELINDEX DELETES THESE FOLDERS (* = recreated by Windows):
echo    C:\Windows\Cookies*, History*, Recent*,
echo    C:\Windows\Temporary Internet Files* & alt TIF ...\Locals~1\Tempor~1*
echo    C:\Windows Update Setup Files
echo.
echo   DELINDEX DELETES THESE FOLDER CONTENTS:
echo    C:\Windows\Applog; C:\Windows\Temp & C:\Temp
echo    C:\Windows\PCHealth\Helpctr\Datacoll
echo    C:\Program\WindowsUpdate & OfficeUpdate (except log & cfg files)
echo    C:\Windows\Downloaded Program Files (except Google Toolbar)
echo    C:\Windows\Applic~1\Micros~1\Intern~1\UserData\
echo    C:\Windows\Applic~1\Micros~1\Office\Recent\ (optional; see Additional Notes)
echo.
echo   DELINDEX DELETES THESE FILES:
echo    C:\Windows\ShellIconCache
echo    *.tmp in C:\ & C:\Windows\
echo    Windows diagnostic (system log) files
echo    C:\Windows\*.bad & C:\Windows\sysbckup\rbbad.cab
echo    Thumbs.db in C:\My Pictures\ & My Documents\My Pictures\
echo.
pause
::
::
:INTRO
REM>c:\RenMan.i2
goto HDR
::
:INTRO2
del c:\RenMan.i2
echo   So you fully understand what DELINDEX does and why it does it, read
echo    Additional Notes BEFORE first running DELINDEX.
echo.
echo   ฏWARNINGฎ  Record IDs & passwords for websites that require them before you
if exist c:\RenMan.c2 echo   [1A[1;31mฏWARNINGฎ[0;44m
echo    use DELINDEX because you won't be able visit them without signing in. You
echo    can save/restore cookies of your choice; see Additional Notes. Record any
echo    needed web addresses in the drop-down History box in IE; that information
echo    will be deleted.
echo.
echo   COMMAND-LINE SWITCHES: Type C:\DELINDEX RUN to run immediately without user
echo    input. Type C:\DELINDEX NOTES to go directly to Additional Notes. For the
echo    DELTA and ADD switches, see Additional Notes.
echo.
echo   DELINDEX will not delete files & folders if Windows is running; you can use
echo    all other functions and switches. To use RUN from the Menu or command line:
echo   In Windows 98, Reboot into DOS mode. 
echo   In Windows ME, use a StartUp disk; Select #4, Minimal Boot.
echo.
pause
:MENU
REM>c:\RenMan.m2
goto HDR
::
:MENU2
del c:\RenMan.m2
echo.
if exist c:\RenMan.c2 echo [2A[1;33m
echo    R = RUN Delindex
echo    A = ADDITIONAL notes
echo    V = VIEW program code
echo    O = OPENING Screen
echo    Q = QUIT
echo.
if exist c:\RenMan.c2 echo [1A[32m
choice /n/c:qavro/t:q,99 "   Enter R, A, V, O, or Q: "
if errorlevel 5 goto HDR
if errorlevel 4 goto RUN
if errorlevel 3 goto VIEW
if errorlevel 2 goto NOTES
if exist c:\RenMan.c2 echo [0m[2J
if not exist c:\RenMan.c2 cls
goto B4X
::
::
:RUN
REM>c:\RenMan.r2
REM>c:\RenMan.r3
goto HDR
::
:RUN2
del c:\RenMan.r2
xcopy /?|find "/L">nul
if errorlevel 1 goto XWIN
echo.
echo  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ You cannot use the RUN section if Windows is running. บ
echo  บ Reboot to DOS (Win98) or use a Startup Disk (WinME).  บ
echo  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
pause
goto MENU
:XWIN
echo  FREE SPACE BEFORE DELINDEX:>c:\RenMan.B4
echo  FREE SPACE AFTER DELINDEX:>c:\RenMan.Aft
ctty nul
::without ctty nul the next line displays messages
dir c:\asdfghjk|find "free">>c:\RenMan.B4
ctty con
if exist c:\RenMan.c2 echo [1A[1;31m
type c:\RenMan.B4
if exist c:\RenMan.c2 echo [1A[0;44m
echo  Running......
::
::ษอออออออออออป
::บ SECTION 1 บ
::ศอออออออออออผ
::
ctty nul
attrib c:\windows\downlo~1\*.* -r -a -s -h /s
:: Protect Google Toolbar
attrib +r c:\windows\downlo~1\google*.*
:: Add other files here (e.g., PC Pitstop)
echo Y|del c:\windows\downlo~1\*.*
attrib -r c:\windows\downlo~1\google*.*
::
deltree /y c:\windows\temp\
if not exist c:\progra~1\window~2\wuhistv3.log goto NOLOG
move c:\progra~1\window~2\wuhistv3.log c:\windows\temp\
move c:\progra~1\window~2\austate.cfg c:\windows\temp\
deltree /y c:\progra~1\window~2\
move c:\windows\temp\*.* c:\progra~1\window~2\
:NOLOG
::
if not exist c:\progra~1\office~1\ouhistv3.log goto NOLOG2
move c:\progra~1\office~1\ouhistv3.log c:\windows\temp\
deltree /y c:\progra~1\office~1\
move c:\windows\temp\ouhistv3.log c:\progra~1\office~1\
:NOLOG2
::
if exist c:\window~1\thisfo~1.txt deltree /y c:\window~1
ctty con
::
::ษอออออออออออป
::บ SECTION 2 บ
::ศอออออออออออผ
::
For %%Z in (mypict~1\thumbs.db mydocu~1\mypict~1\thumbs.db temp\ *.tmp) do deltree /y c:\%%Z>nul
For %%X in (recent cookies tempor~1 locals~1\tempor~1 history ShellI~1 *.bad sysbckup\rbbad.cab applog\ *.tmp pchealth\helpctr\datacoll\ *log.txt system\sfp\sfplog.txt Applic~1\Micros~1\Intern~1\UserData\ ::Applic~1\Micros~1\Office\Recent\ ::setupapi.log) do deltree /y c:\windows\%%X>nul
::
:: ษอออออออออออออออออออออป
:: บ ADD MORE CODE HERE: บ
:: ศอออออออออออออออออออออผ
::
:END
REM>c:\RenMan.e2
goto HDR
::
:END2
del c:\RenMan.e2
ctty nul
dir c:\asdfghjk|find "free">>c:\RenMan.Aft
ctty con
if exist c:\RenMan.c2 echo [1A[1;32m
type c:\RenMan.Aft
if exist c:\RenMan.c2 echo [1A[31m
type c:\RenMan.B4
if exist c:\RenMan.c2 echo [1A[0;44m
echo  Finished.....
echo.
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ         In Windows ME, remove any floppy and press Ctrl-Alt-Delete        บ
echo  บ         In Windows 98, type WIN and press Enter                           บ
goto BOTLN
::
::
:NOTES
::
REM>c:\RenMan.n2
goto HDR
::
:NOTES2
del c:\RenMan.n2
if not exist c:\RenMan.c2 echo.
echo   I'm grateful for all the help I've gotten from the people who post on the
echo   Computing.net forum, especially Leonardo Pignataro for great answers to my
echo   coding questions, and to ShutMeUpOrDown:) for making DELINDEX available at
echo   his website: http://burzurq.com/forum/delindex.html
echo.
echo   If you run DELINDEX regularly it runs in seconds, but it can take much longer
echo.  on a system that's never been cleaned up.
echo.
echo   Please post problems or questions at www.computing.net on the Windows ME
echo   forum with DELINDEX in the subject line. You may get more advice sooner, and
echo   I want all the help I can get. I welcome your comments and suggestions:
echo   delindex@yahoo.com.
if exist c:\RenMan.c2 echo  [1A[1;33m delindex@yahoo.com[0;44m
echo.
echo   I hope you'll find DELINDEX effective, easy to use, and informative. Enjoy!
echo.
if not exist c:\RenMan.c2 echo   --   Renaissance Man 
if exist c:\RenMan.c2 echo   --[1;31m  [36m Renaissance Man [31m[0;44m
echo.
pause
if exist c:\RenMan.c2 echo [1;31m
cls
echo ษออออออออออออป
echo บ DISCLAIMER บ
echo ศออออออออออออผ
if exist c:\RenMan.c2 echo [1A[0;44m
echo DELINDEX has been extensively tested in WinME/IE 5.5 SP2 and works fine on my
echo Dell Inspiron 7500 laptop, 256MB memory, 20GB hard drive. It also works with
echo IE6. I can't say how well it will work on your system. If you want a guarantee,
echo buy a toaster.
echo.
echo It's YOUR responsibility to make sure that DELINDEX does what you want, that
echo DELINDEX and other programs don't conflict (e.g., DELINDEX restoring cookies &
echo another deleting them), and that it works with your OS.
echo.
echo Win98: See the note in the Windows Update section for a change needed. You must
echo determine if other changes are needed and make them.
echo. 
echo There were no reported problems with the two prior versions. Some "bad command
echo or file name" messages were traced to user error.
echo.
pause
cls
echo ษอออออออออป
echo บ PURPOSE บ
echo ศอออออออออผ
echo The PRIMARY purpose of DELINDEX is to delete Index.dat files which keep getting
echo bigger. They contain all your web surfing history since they were (re)created.
echo Large index.dat files can cause performance issues with browsing; they can't be
echo deleted if Explorer is running. The SECONDARY purpose is to delete junk files
echo for reasons of space, privacy, and performance.
echo.
echo It is NOT the purpose of DELINDEX to safeguard your privacy, although it helps.
echo The time consuming process of wiping free space prevents files from being
echo recovered. Free: Shred from www.pcmag.com & Eraser from www.heidi.ie/eraser.
echo.
echo FYI: Delindex 4.0 (6/21/02) was a major rewrite. Ver 4.1 (7/19/02) added minor
echo tweaks. This version (4.2, 9/23/02) adds minor tweaks; deletes more junk files;
echo Additional Notes has additions, deletions, and corrections.
echo.
pause
cls
echo ษอออออออออออออป
echo บ SUGGESTIONS บ
echo ศอออออออออออออผ
echo  DELINDEX should be on C:\ because it runs MUCH faster than on a floppy. If
echo you run DELINDEX on multiple computers for one-time-only tune-ups, you can put
echo it on a floppy (Win98) or a StartUp disk (WinME) & "carry DELINDEX with you
echo wherever you go," to paraphrase one user.
echo.
echo  Run DELINDEX at weekly. Defrag if you free up a lot of space.
echo.
echo  Get color. In WinME, use an ADD option. In Win98, add this to C:\config.sys:
echo devicehigh=c:\windows\command\ansi.sys
echo.
echo  Make a "Superfast" WinME StartUp Disk.
echo Info: http://computing.net/windowsme/wwwboard/forum/23229.html
echo.
echo  The Recycle Bin is NOT cleaned because many people temporarily park deleted
echo files there before deleting them permanently. It's also very easy to delete the
echo contents directly, indirectly, manually, & automatically, with or without third
echo party software. Empty it regularly when you're sure you don't need the files.
echo.
echo  FYI: dir will NOT find MS index.dat files; use attrib /s index.dat.
echo.
pause
cls
echo ษออออออออออป
echo บ REGISTRY บ
echo ศออออออออออผ
echo IMHO, it's as important to remove junk from your registry as it is from your
echo hard drive. If you don't use a registry cleaner, your registry will be bigger;
echo it will have obsolete and erroneous entries; and it's more likely to cause
echo errors. With any cleaner, do NOT delete "duplicate" files! I use all of these
echo cleaners, and each finds errors the others can't.
echo  EasyCleaner (free; WARNING: in WinME it WILL disable Help UNLESS you put HELP
echo   in the "skip" box; also add _RESTORE, CONTROL)
echo  MS RegClean (free; may cause problems on SOME WinME systems; not mine)
echo  Get the 2 above from http://winguides.com/downloads.php?guide=registry
echo  System Mechanic ($60; iolo.com; very good; overpriced)
echo  Norton WinDoctor in Utilities & NSW (Fix regstry errors yourself! Most Norton
echo   "solutions" are wrong; usually it's best to delete invalid entries).
echo  Remove much of your history with List Zapper (free; PCMagazine.com)
echo  See http://computing.net/windowsme/wwwboard/forum/20552.html
echo   and http://computing.net/windows95/wwwboard/forum/123201.html 
echo  Fix Registry cleaning problems with the cleaner's undo function, or type
echo   scanregw /restore in Start/Run or scanreg /restore at a DOS prompt.
echo  After cleaning, keep registry (& backups) healty & small: in Start/Run, type
echo   scanregw /fix /opt, or scanreg /fix /opt at a DOS prompt. (Win98/ME)
echo.
pause
if exist c:\RenMan.c2 echo [1;31m
cls
echo ษอออออออออออออออออออป
echo บ ฏEDITING WARNINGฎ บ
echo ศอออออออออออออออออออผ
if exist c:\RenMan.c2 echo [1A[0;44m
echo MODIFYING DELINDEX:
echo  Edit this file to meet your needs ONLY if you know batch file/DOS commands.
echo  Back up this file before you edit it.
echo  Put :: in front of a line to keep it from running instead of deleting it;
echo   it's easier to undo. You CAN put :: in front of a folder or file name within
echo   the ( ) in Section 2 to keep it from being deleted.
echo  Do NOT delete other *.dat files!
echo  Add additional code after the heading ADD MORE CODE HERE.
echo.
echo MODIFYING THE DELTA SECTION:
echo  Deleting TEMP folder contents can prevent programs from installing/updating.
echo  Deleting the RECENT folder causes ListZapper to delete files (but not
echo   folders) on C:\.
echo  Do NOT use DELINDEX RUN in Scheduled Tasks or Autoexec.bat; it deletes Temp
echo   files. Deleting other files & folders at (re)boot not tested.
echo.
pause
cls
echo ษอออออออออออออออออออออออออออออป
echo บ HOW TO SAVE SPECIAL COOKIES บ
echo ศอออออออออออออออออออออออออออออผ
echo You may want to save cookies that have IDs and passwords that allow you to
echo visit a site without having to sign in again.
echo.
echo  Create a new folder, C:\GdCookie.
echo.
echo  Copy the cookies you want to save from C:\Windows\Cookies\ to C:\GdCookie\.
echo Some you may recognize by the name (nytimes). You'll have to look inside others
echo with a file viewer or text editor to see what they are (Computing.net's cookie
echo is cgi-bin). It may be easier to find some cookies by deleting everything in
echo the Cookies folder, creating new ones, and then looking.
echo.
echo  Set up the DELTA routine. You MUST use DELTA to copy saved cookies to the
echo Cookies folder; they CANNOT copied correctly by DELINDEX in DOS because of
echo long filenames.
echo.
pause
cls
echo ษอออออออออออออออออออออออป
echo บ COMMAND-LINE SWITCHES บ
echo ศอออออออออออออออออออออออผ
echo These are really command-line parameters or batch-file parameters. Anything
echo following a command is a parameter. A program can process a parameter directly
echo or use it internally to SWITCH to (or skip) a set of instructions. DELINDEX has
echo 4 command-line switches: RUN, to run immediately with no user input; NOTES, to
echo go directly to Additional Notes; and DELTA & ADD, which are explained below.
echo.
echo ษอออออออออออออออออออออออออออออออป
echo บ The DELTA COMMAND-LINE SWITCH บ
echo ศอออออออออออออออออออออออออออออออผ
echo The DELTA routine deletes the FOLDERS the index.dat files are in AND restores
echo any saved cookies each time you (re)boot your computer. Deleting the folders
echo ensures that the index.dat files are rebuilt at minimal size.
echo.
pause
cls
echo ษออออออออออออออออออออออออออออออป
echo บ DELTA SETUP IN WinME & Win98 บ
echo ศออออออออออออออออออออออออออออออผ
echo In Control Panel:
echo  Click on Scheduled tasks; double click on Add Scheduled Task.
echo  In Scheduled Task Wizard, click on Next.
echo  Click on Browse; navigate to DELINDEX.BAT and double click on it.
echo  In the Name box, enter: Delete Index.dat files.
echo  Click on When My Computer Starts; click on Next.
echo  Check Open Advanced Properties; click on Finish.
echo  In the run box on the Task tab you MUST add " DELTA" so the entry is:
echo   C:\DELINDEX DELTA
echo  Click the settings tab; uncheck all boxes; click on Apply; click on OK.
echo.
echo Alernate Delta setup for Win98 ONLY
echo  Put a shortcut to Delindex in C:\Windows\Start Menu\Programs\Startup\; right
echo   click on the shortcut; click on Properties; click on the Program tab; in the
echo   Cmd line box you MUST add " DELTA" so the entry is: C:\DELINDEX DELTA
echo   click on the check box Close On Exit; click on Apply; click on OK.
echo ฏ WARNINGS ฎ   Adding C:\DELINDEX DELTA to c:\autoexec.bat deletes the
if exist c:\RenMan.c2 echo [1A[1;31mฏ WARNINGS ฎ[0;44m
echo   folders, but saved cookies will NOT be copied correctly.  Startup in WinME
echo   runs AFTER Explorer is loaded and index.dat files will NOT be deleted.  
echo.
pause
cls
echo ษอออออออออออออออออออออออออออออป
echo บ The ADD COMMAND-LINE SWITCH บ
echo ศอออออออออออออออออออออออออออออผ
echo This option adds lines to Autoexec.bat on your Startup disk to make it easy to
echo run DELINDEX (and adds a line to Config.sys for color); no editing necessary!
echo To use, or for more info, type C:\DELINDEX ADD at a DOS prompt.
echo.
echo  If you use one of the ADD options, consider editing a:\config.sys; change
echo menudefault=HELP,30 to menudefault=QUICK,10 which selects #4 after 10 seconds.
echo.
echo ษออออออออออออออออออออป
echo บ DID DELINDEX WORK? บ
echo ศออออออออออออออออออออผ
echo You may wonder if Delindex worked at all because Windows & Explorer recreate
echo many of the files & folders deleted (but at a smaller size). To verify that
echo Delindex worked, check the size of the index.dat files before they are deleted
echo and after they're rebuilt; look at the Free Space display; look at the affected
echo files files & folders while you're still in DOS.
echo.
pause
if exist c:\RenMan.c2 echo [1;32m
cls
echo ษอออออออออออออออออออออออออออออออออป
echo บ WHY FILES & FOLDERS ARE DELETED บ
echo ศอออออออออออออออออออออออออออออออออผ
if exist c:\RenMan.c2 echo [1A[0;44m
echo Please read the explanations in the following sections and decide if DELINDEX
echo does what you want. Some people do NOT agree with the rationale given. If you
echo want more info, go to any websites shown or search in Google as I did.
echo.
pause
cls
echo ษออออออออออออออออออออออออออป
echo บ DOWNLOADED PROGRAM FILES บ
echo ศออออออออออออออออออออออออออผ
echo This folder contains ActiveX controls and Java applets. They usually cause no
echo harm, but they can be an entry point for viruses, worms, and & Trojans. You can
echo easily accumulate several MB after a few web sessions. You don't need the files
echo after you have viewed the pages that required them.
echo.
echo "ActiveX programs are only downloaded when they don't already exist on your
echo system. Thereafter, the existing copy is used by any site that requires its
echo function no matter what your security settings. If several people use a
echo computer, one of them can accept an ActiveX download which then could be
echo executed by the other users who think they are protected. If you have reason
echo to doubt the caution of your fellow users add a command to the startup file
echo to delete all files in the Windows\Downloaded Program Files folder each time
echo you logon. If a hacker finds a vulnerability in an ActiveX program its
echo original trust status is worthless." http://ceepeeu.com/b400net.html
echo.
pause
cls
echo ษอออออออออออออออออออออออออป
echo บ WINDOWS & OFFICE UPDATE บ
echo ศอออออออออออออออออออออออออผ
echo These are files you downloaded from the MS Windows Update and Office Update web
echo sites. Once you install these files, they are no longer needed. The contents of
echo the folders are deleted except for the history logs and your Automatic Update
echo preference. See MS KB articles Q193385 & Q304498.
echo.
echo  Win98 NOTE: The window~2 folder is the Windows Media Player. DELINDEX will
echo NOT delete WMP, but Win98 users should change the "...window~2" reference to
echo point to the WindowsUpdate folder.
echo.
echo ษออออออออออออออออออออออออออออป
echo บ WINDOWS UPDATE SETUP FILES บ
echo ศออออออออออออออออออออออออออออผ
echo "Once [this update] is installed and functioning properly on your system, you
echo may delete this folder to free up disk space." (MS)
echo.
pause
cls
echo ษออออออออออออออออออออออออออออออออป
echo บ COOKIES (has 1 Index.dat file) บ
echo ศออออออออออออออออออออออออออออออออผ
echo Some cookies are useful: they get you into sites that would otherwise require
echo you to enter an ID and password. Other cookies are trackers and counters, may
echo contain spyware or adware, or are for sites you'll never visit again. Depending
echo.on your system, a 160 byte cookie takes up 8 or 16KB of disk space. Cookies
echo also indicate your web-surfing habits and history.
echo.
pause
cls
echo ษอออออออออออออออออออออออออออออออออออออออออออออออออป
echo บ TEMPORARY INTERNET FILES (has 1 Index.dat file) บ
echo ศอออออออออออออออออออออออออออออออออออออออออออออออออผ
echo "These are downloaded and stored on your computer's hard disk when you visit
echo web pages on the Internet.... They do not do any harm, but can take up a lot
echo of disk space." http://www.ctv.es/USERS/jcompclb/lectures/springclean.htm
echo.
echo Some people have tens of thousands of files in the Temporary Internet Files
echo folder, a known cause of browsing problems. There are many files for sites
echo you'll never visit again. Deleting these files may slow down the loading of
echo a site the first time you revisit it.
echo.
echo To keep files from building up in TIF, in Internet Explorer click on Tools/
echo Internet Options; on the Advanced tab check the box next to "Empty Temporary
echo Internet Files folder when browser is closed," click on Apply and OK.
echo.
echo ษออออออออออออออออออออออออออออออออออออออออออป
echo บ HISTORY (has 2 Index.dat files) & RECENT บ
echo ศออออออออออออออออออออออออออออออออออออออออออผ
echo The History folder is deleted because of the two index.dat files. The Recent
echo folder is deleted for reasons of space & privacy. Both are rebuilt by Windows.
echo.
pause
cls
echo ษอออออออออออป
echo บ THUMBS.DB บ
echo ศอออออออออออผ
echo Picture folders (e.g., "My Pictures") that display thumbnails have a thumbs.db
echo file that's never resized, even if you delete some (or all) pictures. Windows
echo recreates these files whenever you go back into the folder.
echo.
echo ษออออออออออออออออป
echo บ SHELLICONCACHE บ
echo ศออออออออออออออออผ
echo "ShellIiconCache is a hidden file in the Windows directory that stores icon
echo cache files. Just like the temporary internet files folder, it becomes very
echo unproductive when the file gets too big. This file can become very bloated and
echo corrupted. (Example: black, odd looking icons.)"
echo http://hardwarehell.com/bootclean.htm
echo.
echo A corrupted ShellIconCache file can increase your boot time. On some systems,
echo boot times can also be much longer after ShellIconCache is deleted until it's
echo rebuilt by Windows. If that happens on your system, you can put :: in front of
echo windows\ShellI~1 in Section 2 to prevent deletion.
echo.
pause
cls
echo ษออออออออออออออออออออออป
echo บ BAD REGISTRY BACKUPS บ
echo ศออออออออออออออออออออออผ
echo Sometimes Scanreg[W] with the /opt, /fix, or /restore switches creates new
echo copies of registry files and labels the old ones classes.bad and/or user.bad
echo and/or system.bad and/or rbbad.cab.
echo.
echo ษออออออออป
echo บ APPLOG บ
echo ศออออออออผ
echo "Task Monitor is a MS utility which keeps track of the rate of program usage to
echo make defragging more efficient. With short seek times and high transfer rates
echo of today's hard drives, it is probably superfluous." www2.whidbey.net/djdenham/
echo Uncheck.htm.  "The speed benefit of [using Applog for] the specialized defrag
echo process may not be noticeable and a great number of files can accumulate in the
echo Applog folder." --Neil J. Rubenking.
echo.
echo See http://computing.net/windowsme/wwwboard/forum/24681.html
echo.
echo Consider disabling Task Monitor which puts the files in Applog. Go to Start/Run
echo and type msconfig; under the Startup tab uncheck Task Monitor.
echo.
pause
cls
echo ษออออออออออออออออออออป
echo บ TEMP & *.TMP FILES บ
echo ศออออออออออออออออออออผ
echo "Poorly written programs, improper shutdowns, program hangs, & computer crashes
echo often leave unneeded temporary files on the hard drive. These files accumulate,
echo eating up hard disk space and, at times, impairing computer performance. Some
echo shutdown problems and download problems can be cured by cleaning up your temp
echo files."  http://compukiss.com/ck/tutorials/tutorials_topic.cfm?topic=35
echo "These leftover files not only use up disk space, but can also create printing
echo & scanning problems and even problems with anti-virus programs. It's advisable
echo to delete them."  http://ctv.es/USERS/jcompclb/lectures/springclean.htm
echo.
echo fff*.tmp files are created by MDM.EXE & MS Office in the Windows folder. To
echo keep them from being created, uncheck MDM.EXE in MSConfig/Startup Tab. Also see
echo MS KB article Q221438.
echo.
echo Windows doesn't rebuild TEMP folders, so only the contents are deleted.
echo.
pause
cls
echo ษออออออออออออออออออออออออออออป
echo บ PC HEALTH\HELPCTR\DATACOLL บ
echo ศออออออออออออออออออออออออออออผ
echo This directory becomes bloated with *.xml files.
echo Discussion:  http://computing.net/windowsme/wwwboard/forum/23649.html
echo "The other PC Health item ... builds another set of data that is merely used
echo to describe the system via System Information, for the erudition of user and
echo tech support. Both sub sections of the PC Health group of technologies can be a
echo nuisance sometimes, and it's nice that they can be amputated separately should
echo the need arise."  http://users.iafrica.com/c/cq/cquirke/sr-sfp.htm
echo.
echo ษออออออออออออออออออป
echo บ SYSTEM LOG FILES บ
echo ศออออออออออออออออออผ
echo These Windows Diagnostic files are rarely needed. E.g., the start AND finish of
echo every instance performed by Scheduled Tasks is recorded in Schedlog.txt.
echo.
echo ษอออออออออออป
echo บ USER DATA บ
echo ศอออออออออออผ
echo Yet another instance of useless data MS stores on your hard drive; may contain
echo an index.dat file. See http://computing.net/windowsme/wwwboard/forum/27348.html
echo.
pause
cls
echo ษออออออออออป
echo บ OPTIONAL บ
echo ศออออออออออผ
echo To delete files in Windows\Applic~1\Micros~1\Office\Recent\ or the
echo Windows\Setupapi.log remove :: from either or both of the last 2 items in
echo ( ) in the second line of Section 2. The Setupapi.log file records information
echo.on device and driver installation, service pack installation, and hotfix
echo installation. If the install is successful the log is not needed. Often
echo "errors" are due to a driver not being digitally signed even though there's no
echo problem with the installation of drivers or hardware.
echo.
if exist c:\RenMan.c2 echo [1A[1m
echo ษอออออออออออออออออออออออออป
echo บ END OF ADDITIONAL NOTES บ
echo ศอออออออออออออออออออออออออผ
if exist c:\RenMan.c2 echo [1A[0;44m
echo.
pause
goto MENU
::
::
:VIEW
if exist c:\delindex.bat type c:\delindex.bat|more
if exist c:\delindex.bat goto VU2
if exist a:\delindex.bat type a:\delindex.bat|more
:VU2
echo.
pause
goto MENU
::
::
:DELTA
For %%X in (cookies tempor~1 locals~1\tempor~1 history) do deltree /y c:\windows\%%X>nul
if exist c:\GdCookie\*.* xcopy /y c:\GdCookie\*.* c:\Windows\Cookies\>nul
cls
exit
goto EXIT
::
::
:ADD
REM>c:\RenMan.a2
goto HDR
::
:ADD2
del c:\RenMan.a2
CTTY nul
:: This is  test to see if there's a floppy in a:
%COMSPEC%/F/CDIR/ADH/W/-P a: |FIND.EXE ":\"
CTTY con
if errorlevel 0 if not errorlevel 1 goto AOK
choice /n/c:qc/tq,99 " Insert a Startup disk in A: and press C to continue or Q to quit: "
echo.
if errorlevel 2 goto ADD
cls
goto B4X
::
:AOK
::
type a:\autoexec.bat|find /I "delindex">nul
if not errorlevel 1 goto OK
echo  Add lines to Autoexec.bat & Config.sys on your Startup disk to run DELINDEX
echo  immediately (or Display a Menu: Run, Start Screen, Quit) after bootup. Also
echo  installs DOSKEY (info: type DOSKEY /? at a DOS prompt) & ANSI.SYS (for color).
echo.
echo  Enter M to display a Menu at bootup
echo  Enter R to Run DELINDEX at bootup with NO user input
echo  Enter Q to Quit without updating your Startup disk
echo.
choice /C:mrq/N/T:q,99 " Enter M, R, or Q: "
cls
if errorlevel 3 goto B4X
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ    Autoexec.bat and Config.sys on your StartUp disk are being updated.   บ
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo ::  THE FOLLOWING LINES HAVE BEEN ADDED BY DELINDEX >>a:\autoexec.bat
echo ctty nul>>a:\autoexec.bat
echo doskey /insert /bufsize=4096>>a:\autoexec.bat
echo ctty con>>a:\autoexec.bat
echo c:>>a:\autoexec.bat
if not errorlevel 2 goto ADD3
echo if exist c:\delindex.bat c:\delindex.bat run>>a:\autoexec.bat
echo if exist a:\delindex.bat a:\delindex.bat run>>a:\autoexec.bat
goto DONE
::
:ADD3
echo cls>>a:\autoexec.bat
echo echo.>>a:\autoexec.bat
echo echo  Do you want to run DELINDEX?>>a:\autoexec.bat
echo echo.>>a:\autoexec.bat
echo echo  Enter D for DELINDEX Start Screen>>a:\autoexec.bat
echo echo  Enter R to Run DELINDEX immediately, without user input>>a:\autoexec.bat
echo echo  Enter Q to Quit if you do NOT want to run DELINDEX>>a:\autoexec.bat
echo echo.>>a:\autoexec.bat
echo choice /C:qdr/N/T:q,99 " Enter D, R, or Q: ">>a:\autoexec.bat
echo if errorlevel 3 if exist c:\delindex.bat c:\delindex.bat run>>a:\autoexec.bat
echo if errorlevel 3 if exist a:\delindex.bat a:\delindex.bat run>>a:\autoexec.bat
echo if errorlevel 2 if exist c:\delindex.bat c:\delindex.bat>>a:\autoexec.bat
echo if errorlevel 2 if exist a:\delindex.bat a:\delindex.bat>>a:\autoexec.bat
::
:DONE
echo cls>>a:\autoexec.bat
echo echo.>>a:\autoexec.bat
echo if errorlevel 2 echo   Oops! DELINDEX is not on C:\ or A:\ >>a:\autoexec.bat
if exist a:\config.sys type a:\config.sys|find "ansi">nul
if errorlevel 1 if not errorlevel 2 echo devicehigh=c:\windows\command\ansi.sys>>a:\config.sys
::
cls
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ Your StartUp disk is now updated. You'll see the changes when you reboot.  บ
goto NXTLN
::
:OK
echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo  บ Your StartUp disk is already updated. If you updated BEFORE Delindex 4.0,  บ
echo  บ (6/21/02) run ADD again with a NEW Startup disk; older updates won't work. บ
:NXTLN
echo  บ If you booted with your StartUp disk, you can type C:\DELINDEX [RUN].      บ
:BOTLN
echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.
::
::
:B4X
if exist c:\RenMan.r3 if exist RenMan.c2 echo [0m[7B
deltree /y c:\RenMan.*>nul
set path=%RenMan%
set RenMan=
:
:EXIT
