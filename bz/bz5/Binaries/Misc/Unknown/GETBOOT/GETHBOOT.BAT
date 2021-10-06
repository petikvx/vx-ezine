@echo off
REM  MHH//DF 1998
echo This batch file reads the first DBR of the hard drive to a file.
pause
echo a300        >  .\getboot.scr
echo mov ax, 0201>> .\getboot.scr
echo mov bx, 0100>> .\getboot.scr
echo mov cx, 0001>> .\getboot.scr
echo mov dx, 0180>> .\getboot.scr
echo int 13      >> .\getboot.scr
echo int 3       >> .\getboot.scr
echo.            >> .\getboot.scr
echo g=300       >> .\getboot.scr
echo d 100 2ff   >> .\getboot.scr
echo q           >> .\getboot.scr
debug.exe < getboot.scr > dbr.dmp
del .\getboot.scr>nul
echo Boot sector is now in file DBR.DMP
