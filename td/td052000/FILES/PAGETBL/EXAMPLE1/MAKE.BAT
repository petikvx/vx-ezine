@echo off
cls
if exist example1.exe del example1.exe
tasm32.exe /s  /m /ml /z example1.asm
tlink32.exe -x -c -Tpe -B:0x10000000 example1.obj,,,x:\tasm\win\import32.lib
del example1.obj
