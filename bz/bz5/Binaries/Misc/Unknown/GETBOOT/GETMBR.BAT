@echo off
REM  MHH//DF 1995
echo This batch file reads the MBR of the hard drive to a file.
pause
echo a300        >  .\getboot.scr
echo mov ax, 201 >> .\getboot.scr
echo mov bx, 100 >> .\getboot.scr
echo mov cx, 1   >> .\getboot.scr
echo mov dx, 80  >> .\getboot.scr
echo int 13      >> .\getboot.scr
echo int 3       >> .\getboot.scr
echo.            >> .\getboot.scr
echo g=300       >> .\getboot.scr
echo d 100 2ff   >> .\getboot.scr
echo q           >> .\getboot.scr
debug.exe < getboot.scr > mbr.dmp
del getboot.scr > nul
echo Boot sector is now in file MBR.DMP
