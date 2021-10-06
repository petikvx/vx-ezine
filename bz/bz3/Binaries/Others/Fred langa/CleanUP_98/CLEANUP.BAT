@rem The first group of lines clears the screen and displays program information
@cls
@echo   Fred Langa's Cleanup.Bat, a Win98 hard-disk cleanup tool.
@echo   ---------------------------------------------------------
@echo            Copyright (c) 2002 Langa Consulting
@echo                   http://www.langa.com
@echo   ---------------------------------------------------------
@echo       Use Notepad to view file contents before running!
@echo       In reading the file, you'll see every command that
@echo        will be issued and acted on. If you see anything
@echo       that should NOT be done on or to your system/files,
@echo   delete that line. This file is known to work fine as-is on
@echo    standard Windows98 setups, but only you can determine
@echo           if it's OK to run on *your specific* setup.
@echo           See http://www.langa.com/cleanup_bat.htm
@echo      for precaution/usage info and for newer versions.
@echo                        -----------
@rem    This file is offered as-is and without warranty of any kind.
@rem    This file may be redistributed as long as this header 
@rem    information is retained in the final file. 
@rem    DO NOT PROCEED until and unless you have read the precaution/usage
@rem    info and checked for newer versions at http://www.langa.com/cleanup_bat.htm
::   Please also note the COMMON SENSE PRECAUTIONS and legal information here:
::   http://www.langa.com/legal.htm . The information on that page is included
::   in this file by reference; and your use of this file indicates your acceptance
::   of responsibility for the use of this file. 
@echo   This batch file aggressively cleans up all Temp/Tmp files in standard
@echo   Windows locations. Note: all other apps should be closed before running this.
@echo    ---------------------------------------------------------
@echo If you haven't followed the instructions above, hit ctrl-c to abort; otherwise
@pause
rem     The next line wipes out the entire temp directory(ies), if it(they) exists
deltree /y c:\windows\temp\
deltree /y c:\temp\
deltree /y c:\windows\tmp\
deltree /y c:\tmp\
rem     Next set of "del" lines deletes possibly-large "orphan" files that sometimes 
rem     get placed inappropriately in the "temporary internet files" (TIF) directory.
rem     Note: it does NOT clean out files that actually belong in the TIF.
del c:\windows\tempor~1\*.zip
del c:\windows\tempor~1\*.exe
del c:\windows\tempor~1\*.gif
del c:\windows\tempor~1\*.jpg
del c:\windows\tempor~1\*.mov
del c:\windows\tempor~1\*.qt
del c:\windows\tempor~1\*.png
del c:\windows\tempor~1\*.bmp
del c:\windows\tempor~1\*.avi
del c:\windows\tempor~1\*.mpg
del c:\windows\tempor~1\*.mpeg
del c:\windows\tempor~1\*.ra
del c:\windows\tempor~1\*.ram
del c:\windows\tempor~1\*.mp3
del c:\windows\tempor~1\*.asf
rem     Next line kills garbage files that Office leaves behind in c:\windows
del c:\windows\ff*.tmp
rem   next line erases the icon cache, saving some resources on restart
deltree /y c:\windows\ShellIconCache
cls
exit
rem For best results, reboot after running this file.