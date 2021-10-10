@echo off
cls
if exist example.exe del example.exe
tasm32.exe /s  /m /ml /z example.asm
tlink32.exe -x -c -Tpe -B:0x10000000 example.obj,,,x:\tasm\win\import32.lib
del example.obj
