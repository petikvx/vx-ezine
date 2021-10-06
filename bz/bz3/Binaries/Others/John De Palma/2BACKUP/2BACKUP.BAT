@echo off
goto Start
                           ÛßßßßßßßßßßßßßßßßßßßÛ
                           Û                   Û ³
                           Û    2BACKUP.BAT    Û ³
                           Û                   Û ³
                           ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ ³
                             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                            Sat 06-10-95 03:51 pm

     COMMAND:

          2BACKUP


     1.   Backs up all modified files from a hard Drive to floppy
          diskettes on the Drive you select.

          If you don't select a drive with the command:

          2BACKUP  a

          Or....

          2BACKUP  b

          then this batch file uses A: Drive.

     2.   You can back up to many diskettes as 2BACKUP.BAT will prompt
          for new diskettes.

     3.   Does not back up *.BAK files.

     4.   Can be configured to not backup other types of files such as:

          a.   *.BDB files...
          b.   *.BKS files...
          c.   ~*.TMP files...
          d.   *.COM files...
          e.   *.EXE files...

          But... you will have to know how to edit a batch file to do
          that. If you decide to do more than just edit 2BACKUP.BAT to do
          this, you may overwrite some of the encrypted code and find
          that this pretty fancy batch file no longer works.

     5.   note bene:

          If you use this batch file inside of Windows 3.11, you will
          have to backup all the *.DLL and *.DRV files that Windows 3.11
          opens when Windows 3.11 starts up. You -can't- exclude them
          with a DOS ATTRIB command.

          *.DRV files are your printer driver files; if you have bunches
          of them... they will all be backed up.

     6.   2BACKUP.BAT =must= be first run from MS-DOS.

     7.   Once configured for the first time in MS-DOS, 2BACKUP.BAT will
          work inside of Windows 3.11, but be careful when using this
          batch file inside Windows 3.11!!

          If you use a bad diskette or one that is "write protected"
          Windows 3.11 will complain that the diskette drive no longer
          exists!!! Or.... worse.

          You will have to reboot to get Windows 3.11 to recognize that
          diskette drive. Best to use from DOS, but -can- be used from
          Windows, if you are careful...

     John De Palma on CompuServe 76076,571


:Start
:: if you didn't enter a floppy disk as "A" or "B" as the first
:: argument, then this program uses A: Drive for destination drive.

if "%1"=="" set disk=a:\
if not "%1"=="" set disk=%1:\

cls
echo.
echo                    ÛÛ  ÛÛ  ßß
echo                    ÛÛÜÜÛÛ  ÜÜ
echo                    ÛÛ  ÛÛ  ÛÛ
echo                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo                    Hemodialysis, Inc
echo                    Glendale, CA 91206-4175
echo                    Copyright (c) May 5, 1995
echo.
echo           Backs up all -ordinary- modified files to Drive:
echo.
echo                              ÚÄÄÄÄÄÄ¿
echo                              ³ %disk%  ³
echo                              ÀÄÄÄÄÄÄÙ
echo.
echo           If that is NOT what you want to do, but wish to ABORT...
echo.
echo                        ÉÍÍÍÍÍÍ»     ÖÄÄÄÄÄ·       ÚÄÄÄÄÄ¿
echo           PRESS:       º Ctrl º  +  º  C  º  then ³  Y  ³
echo                        ÈÍÍÍÍÍÍ¼     ÓÄÄÄÄÄ½       ÈÍÍÍÍÍ¼
echo          Or....
echo.
pause

:: Removes all the "a" file attributes if you are using this batch file
:: for the first time. Makes a zero byte file in your Root directory.
cd\
if exist \~johns.tmp goto SkipAttr

:: Checks to see if you are in Windows, won't run if you are...
set|find/i/c "windir"
if errorlevel 2 if not errorlevel 3 goto FindErr2  ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
if errorlevel 1 if not errorlevel 2 goto NotWin    ÿÿÿÿ    ÿÿÿÿ
if errorlevel 0 if not errorlevel 1 goto WinRun    ÿÿÿÿ    ÿÿÿÿ
pause                                              ÿÿÿÿÿÿÿÿÿÿÿÿ   ÿÿÿÿ
                                                   ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
:WinRun                                            ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
cls
echo 
echo.
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³         Running Windows ERROR        ³
echo                    ³                                      ³
echo                    ³        Ah.... Oopps....              ³
echo                    ³                                      ³
echo                    ³        2BACKUP.BAT should not be     ³
echo                    ³                                      ³
echo                    ³        RUN inside Windows 3.11       ³
echo                    ³                                      ³
echo                    ³        Sorry.... Have to Abort       ³
echo                    ³                                      ³
echo                    ³        CORRECT and try again         ³
echo                    ³                                      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
echo 
pause
goto End
:FindErr2
cls
echo.
echo 
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³                                       ³
echo                    ³           MS-DOS Program ERROR        ³
echo                    ³                                       ³
echo                    ³           FIND.EXE ERROR              ³
echo                    ³                                       ³
echo                    ³           Aborting.....               ³
echo                    ³                                       ³
echo                    ³                                       ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
goto End
:NotWin
:: If we get to here, we can go on
::echo  ERRORLEVEL 1
::echo  you NOT are running windows!
::echo.
::pause

cls
echo 
echo.
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³        FIRST RUN of 2BACKUP.BAT      ³
echo                    ³                                      ³
echo                    ³   REMOVES the "a" file attribute     ³
echo                    ³                                      ³
echo                    ³   from all of the files on this      ³
echo                    ³                                      ³
echo                    ³   drive. A Necessary step.           ³
echo                    ³                                      ³
echo                    ³   If that is NOT "Ok", PRESS:        ³
echo                    ³                                      ³
echo                    ³  ÉÍÍÍÍÍÍ»     ÖÄÄÄÄÄ·       ÚÄÄÄÄÄ¿  ³
echo                    ³  º Ctrl º  +  º  C  º  then ³  Y  ³  ³
echo                    ³  ÈÍÍÍÍÍÍ¼     ÓÄÄÄÄÄ½       ÈÍÍÍÍÍ¼  ³
echo                    ³                                      ³
echo                    ³         to Abort Backup Process      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
echo                     Or... to continue with 2BACKUP.BAT
echo.
pause
attrib -a *.*/s
cd\
echo on > \~johns.tmp
attrib +s \~johns.tmp
@echo off

:: All of the above is skipped after the first time.
:SkipAttr
cls
echo.
echo.
echo.
echo.|time|find/i "Current"
echo.|date|find/i "Current"
echo @prompt $v > c:\version.bat
command/c c:\version.bat > c:\version.txt
del c:\version.bat
type c:\version.txt
attrib -a c:\version.txt
echo.
echo.
echo                      PHASE ONE:
echo                      ÄÄÄÄÄÄÄÄÄ-
echo                      Discarding backup for:
echo.
echo                          1.   *.BAK files...
:: next types of files are NOT displayed or discarded. You would have to
:: edit this batch file to include them.
:: Just remove the double colons (::) from in front of the commands
:: to make those commands work.
:: Add the ATTRIB commands too!!
::echo                        2.   *.BDB files...
::echo                        3.   *.BKS files...
::echo                        4.   ~*.TMP files...
::echo                        5.   *.COM files...
::echo                        6.   *.EXE files...
echo.
echo                                Working....
attrib -a *.bak/s
::attrib -a *.bdb/s
::attrib -a *.bks/s
::attrib -a ~*.tmp/s
::attrib -a *.com/s
::attrib -a *.exe/s
echo.
echo                             ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
echo                             º  Phase One DONE!  º
echo                             ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
echo 
pause
cls
echo.
echo.
echo.                     PHASE TWO:
echo                      ÄÄÄÄÄÄÄÄÄÄ
echo.
echo.
echo                      Put an =empty= diskette into
echo.
echo                      Drive:
echo.
echo                              ÚÄÄÄÄÄÄ¿
echo                              ³ %disk%  ³
echo                              ÀÄÄÄÄÄÄÙ
echo.
echo                      When ready....
echo.
pause
:Loop
cls
echo.
echo.
xcopy *.* /m/s/v/w %disk%
if errorlevel 5 if not errorlevel 6 goto ERROR5  ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
if errorlevel 4 if not errorlevel 5 goto ERROR4  ÿÿÿÿ    ÿÿÿÿ
if errorlevel 3 if not errorlevel 4 goto ERROR3  ÿÿÿÿ    ÿÿÿÿ
if errorlevel 2 if not errorlevel 3 goto ERROR2  ÿÿÿÿÿÿÿÿÿÿÿÿ   ÿÿÿÿ
if errorlevel 1 if not errorlevel 2 goto ERROR1  ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
if errorlevel 0 if not errorlevel 1 goto ERROR0  ÿÿÿÿ    ÿÿÿÿ   ÿÿÿÿ
pause
:ERROR5
echo 
cls
echo.
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³                ERROR #5              ³
echo                    ³                                      ³
echo                    ³        Disk is Write Protected       ³
echo                    ³                  or                  ³
echo                    ³  Corrupted or No diskette in Drive   ³
echo                    ³                                      ³
echo                    ³        CORRECT and try again         ³
echo                    ³                                      ³
echo                    ³            Or...   PRESS:            ³
echo                    ³                                      ³
echo                    ³  ÉÍÍÍÍÍÍ»     ÖÄÄÄÄÄ·       ÚÄÄÄÄÄ¿  ³
echo                    ³  º Ctrl º  +  º  C  º  then ³  Y  ³  ³
echo                    ³  ÈÍÍÍÍÍÍ¼     ÓÄÄÄÄÄ½       ÈÍÍÍÍÍ¼  ³
echo                    ³                                      ³
echo                    ³         to Abort Backup Process      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
goto Loop
:ERROR4
echo 
cls
echo.
echo 
echo               ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
echo               º            The Floppy Diskette is FULL!          º
echo               º                                                  º
echo               º            If you wish to STOP....               º
echo               º                                                  º
echo               º             ÉÍÍÍÍÍÍ»   ÖÄÄÄÄÄ·      ÚÄÄÄÄÄ¿      º
echo               º      PRESS: º Ctrl º + º  C  º then ³  Y  ³      º
echo               º             ÈÍÍÍÍÍÍ¼   ÓÄÄÄÄÄ½      ÀÄÄÄÄÄÙ      º
echo               ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
echo.
echo                     To Continue Backing up files...
echo.
echo                     INSERT an =empty= Diskette into %disk% Drive
echo.
echo                     Now......
echo.
pause
goto Loop
goto End
:ERROR3
echo 
cls
echo.
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³                ERROR #3              ³
echo                    ³                                      ³
echo                    ³    Undefined.... What's goin' on???  ³
echo                    ³                                      ³
echo                    ³        CORRECT and try again         ³
echo                    ³                                      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
goto End
:ERROR2
echo 
cls
echo.
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³                ERROR #2              ³
echo                    ³                                      ³
echo                    ³        User terminated XCOPY.EXE     ³
echo                    ³                                      ³
echo                    ³      ÉÍÍÍÍÍÍ»   ÚÄÄÄÄÄ¿              ³
echo                    ³      º Ctrl º + ³  C  ³  pressed     ³
echo                    ³      ÈÍÍÍÍÍÍ¼   ÀÄÄÄÄÄÙ              ³
echo                    ³                                      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
goto End
:ERROR1
echo 
cls
echo.
2echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³                ERROR #1              ³
echo                    ³                                      ³
echo                    ³        No files found to copy        ³
echo                    ³                                      ³
echo                    ³        CORRECT and try again         ³
echo                    ³                                      ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
goto End
:ERROR0
echo 
echo.
echo                             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                             ³    Copying Done...   ³
echo                             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
cls
echo.
echo.
echo.
echo.
echo                    ÛÛ  ÛÛ  ßß
echo                    ÛÛÜÜÛÛ  ÜÜ
echo                    ÛÛ  ÛÛ  ÛÛ
echo                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
echo                    Hemodialysis, Inc
echo                    Glendale, CA 91206-4175
echo                    Copyright (c) May 5, 1995
echo.
echo                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                    ³  BACKUP Program Done, without ERROR  ³
echo                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
echo.|time|find/i "Current"
echo.|date|find/i "Current"
type c:\version.txt
del c:\version.txt
echo 
pause
goto End
:End
