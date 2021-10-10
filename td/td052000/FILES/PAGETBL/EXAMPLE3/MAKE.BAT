@echo off
cls
if exist example3.exe del example3.exe
tasm32.exe /s  /m /ml /z example3.asm
tlink32.exe -x -c -Tpe -B:0x10000000 example3.obj,,,x:\tasm\win\import32.lib
del example3.obj
