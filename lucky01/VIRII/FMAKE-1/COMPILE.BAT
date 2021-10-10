@echo off
cls
echo [Fmake-1 v1.0] (cl) -= LUCKY B.R.D 1994-97 =-
echo NE-EXE files infector.
echo Infects DOS part of NE program.
echo Original length: 481 bytes.
echo Press a key to compile...
pause >nul
cls
tasm.exe Fmake-1.asm /m2 >nul
tlink.exe Fmake-1.obj /t >nul
del Fmake-1.map
del Fmake-1.obj
