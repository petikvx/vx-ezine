@echo off
goto Start
                           ���������������������
                           �                   � �
                           �    2BACKUP.BAT    � �
                           �                   � �
                           ��������������������� �
                             ���������������������

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
echo                    ��  ��  ��
echo                    ������  ��
echo                    ��  ��  ��
echo                    ���������������������������������������
echo                    Hemodialysis, Inc
echo                    Glendale, CA 91206-4175
echo                    Copyright (c) May 5, 1995
echo.
echo           Backs up all -ordinary- modified files to Drive:
echo.
echo                              ������Ŀ
echo                              � %disk%  �
echo                              ��������
echo.
echo           If that is NOT what you want to do, but wish to ABORT...
echo.
echo                        ������ͻ     �����ķ       �����Ŀ
echo           PRESS:       � Ctrl �  +  �  C  �  then �  Y  �
echo                        ������ͼ     �����Ľ       �����ͼ
echo          Or....
echo.
pause

:: Removes all the "a" file attributes if you are using this batch file
:: for the first time. Makes a zero byte file in your Root directory.
cd\
if exist \~johns.tmp goto SkipAttr

:: Checks to see if you are in Windows, won't run if you are...
set|find/i/c "windir"
if errorlevel 2 if not errorlevel 3 goto FindErr2  ����    ����   ����
if errorlevel 1 if not errorlevel 2 goto NotWin    ����    ����
if errorlevel 0 if not errorlevel 1 goto WinRun    ����    ����
pause                                              ������������   ����
                                                   ����    ����   ����
:WinRun                                            ����    ����   ����
cls
echo 
echo.
echo.
echo                    ��������������������������������������Ŀ
echo                    �         Running Windows ERROR        �
echo                    �                                      �
echo                    �        Ah.... Oopps....              �
echo                    �                                      �
echo                    �        2BACKUP.BAT should not be     �
echo                    �                                      �
echo                    �        RUN inside Windows 3.11       �
echo                    �                                      �
echo                    �        Sorry.... Have to Abort       �
echo                    �                                      �
echo                    �        CORRECT and try again         �
echo                    �                                      �
echo                    ����������������������������������������
echo.
echo 
pause
goto End
:FindErr2
cls
echo.
echo 
echo                    ���������������������������������������Ŀ
echo                    �                                       �
echo                    �           MS-DOS Program ERROR        �
echo                    �                                       �
echo                    �           FIND.EXE ERROR              �
echo                    �                                       �
echo                    �           Aborting.....               �
echo                    �                                       �
echo                    �                                       �
echo                    �����������������������������������������
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
echo                    ��������������������������������������Ŀ
echo                    �        FIRST RUN of 2BACKUP.BAT      �
echo                    �                                      �
echo                    �   REMOVES the "a" file attribute     �
echo                    �                                      �
echo                    �   from all of the files on this      �
echo                    �                                      �
echo                    �   drive. A Necessary step.           �
echo                    �                                      �
echo                    �   If that is NOT "Ok", PRESS:        �
echo                    �                                      �
echo                    �  ������ͻ     �����ķ       �����Ŀ  �
echo                    �  � Ctrl �  +  �  C  �  then �  Y  �  �
echo                    �  ������ͼ     �����Ľ       �����ͼ  �
echo                    �                                      �
echo                    �         to Abort Backup Process      �
echo                    ����������������������������������������
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
echo                      ���������-
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
echo                             �������������������ͻ
echo                             �  Phase One DONE!  �
echo                             �������������������ͼ
echo 
pause
cls
echo.
echo.
echo.                     PHASE TWO:
echo                      ����������
echo.
echo.
echo                      Put an =empty= diskette into
echo.
echo                      Drive:
echo.
echo                              ������Ŀ
echo                              � %disk%  �
echo                              ��������
echo.
echo                      When ready....
echo.
pause
:Loop
cls
echo.
echo.
xcopy *.* /m/s/v/w %disk%
if errorlevel 5 if not errorlevel 6 goto ERROR5  ����    ����   ����
if errorlevel 4 if not errorlevel 5 goto ERROR4  ����    ����
if errorlevel 3 if not errorlevel 4 goto ERROR3  ����    ����
if errorlevel 2 if not errorlevel 3 goto ERROR2  ������������   ����
if errorlevel 1 if not errorlevel 2 goto ERROR1  ����    ����   ����
if errorlevel 0 if not errorlevel 1 goto ERROR0  ����    ����   ����
pause
:ERROR5
echo 
cls
echo.
echo.
echo                    ��������������������������������������Ŀ
echo                    �                ERROR #5              �
echo                    �                                      �
echo                    �        Disk is Write Protected       �
echo                    �                  or                  �
echo                    �  Corrupted or No diskette in Drive   �
echo                    �                                      �
echo                    �        CORRECT and try again         �
echo                    �                                      �
echo                    �            Or...   PRESS:            �
echo                    �                                      �
echo                    �  ������ͻ     �����ķ       �����Ŀ  �
echo                    �  � Ctrl �  +  �  C  �  then �  Y  �  �
echo                    �  ������ͼ     �����Ľ       �����ͼ  �
echo                    �                                      �
echo                    �         to Abort Backup Process      �
echo                    ����������������������������������������
echo.
pause
goto Loop
:ERROR4
echo 
cls
echo.
echo 
echo               ��������������������������������������������������ķ
echo               �            The Floppy Diskette is FULL!          �
echo               �                                                  �
echo               �            If you wish to STOP....               �
echo               �                                                  �
echo               �             ������ͻ   �����ķ      �����Ŀ      �
echo               �      PRESS: � Ctrl � + �  C  � then �  Y  �      �
echo               �             ������ͼ   �����Ľ      �������      �
echo               ��������������������������������������������������Ľ
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
echo                    ��������������������������������������Ŀ
echo                    �                ERROR #3              �
echo                    �                                      �
echo                    �    Undefined.... What's goin' on???  �
echo                    �                                      �
echo                    �        CORRECT and try again         �
echo                    �                                      �
echo                    ����������������������������������������
echo.
pause
goto End
:ERROR2
echo 
cls
echo.
echo.
echo                    ��������������������������������������Ŀ
echo                    �                ERROR #2              �
echo                    �                                      �
echo                    �        User terminated XCOPY.EXE     �
echo                    �                                      �
echo                    �      ������ͻ   �����Ŀ              �
echo                    �      � Ctrl � + �  C  �  pressed     �
echo                    �      ������ͼ   �������              �
echo                    �                                      �
echo                    ����������������������������������������
echo.
pause
goto End
:ERROR1
echo 
cls
echo.
2echo.
echo                    ��������������������������������������Ŀ
echo                    �                ERROR #1              �
echo                    �                                      �
echo                    �        No files found to copy        �
echo                    �                                      �
echo                    �        CORRECT and try again         �
echo                    �                                      �
echo                    ����������������������������������������
echo.
pause
goto End
:ERROR0
echo 
echo.
echo                             ����������������������Ŀ
echo                             �    Copying Done...   �
echo                             ������������������������
echo.
pause
cls
echo.
echo.
echo.
echo.
echo                    ��  ��  ��
echo                    ������  ��
echo                    ��  ��  ��
echo                    ���������������������������������������
echo                    Hemodialysis, Inc
echo                    Glendale, CA 91206-4175
echo                    Copyright (c) May 5, 1995
echo.
echo                    ��������������������������������������Ŀ
echo                    �  BACKUP Program Done, without ERROR  �
echo                    ����������������������������������������
echo.
echo.|time|find/i "Current"
echo.|date|find/i "Current"
type c:\version.txt
del c:\version.txt
echo 
pause
goto End
:End
