@echo off
cls
echo Please wait, compiling...
tasm example1.asm /m9 > nul
tlink example1.obj /t >nul
tasm example2.asm /m9 > nul
tlink example2.obj /t >nul
tasm example3.asm /m9 > nul
tlink example3.obj /t >nul
del example1.obj
del example2.obj
del example3.obj
del example1.map
del example3.map
del example2.map
echo [Examples] (C) CyberShadow (1996)
