@echo off
cls
if exist example2.exe del example2.exe
tasm32.exe /s  /m /ml /z example2.asm
tlink32.exe -x -c -Tpe -B:0x10000000 example2.obj,,,x:\tasm\win\import32.lib
del example2.obj
