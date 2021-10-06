@echo off
REM  MHH//DF 1995
echo This batch file reads a boot sector of a floppy disk to a file.
echo Insert diskette to drive A:
pause
echo l 100 0 0 1 >  .\getboot.scr
echo rcx         >> .\getboot.scr
echo 200         >> .\getboot.scr
echo nboot.boo   >> .\getboot.scr
echo w           >> .\getboot.scr
echo q           >> .\getboot.scr
debug.exe < getboot.scr > nul
del getboot.scr > nul
echo Boot sector is now in file BOOT.BOO
