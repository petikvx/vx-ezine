@echo off
cls
if exist context.exe del context.exe
tasm32.exe /s  /m /ml /z context.asm
tlink32.exe -x -c -Tpe -B:0x10000000 context.obj,,,x:\tasm\win\import32.lib
del context.obj
