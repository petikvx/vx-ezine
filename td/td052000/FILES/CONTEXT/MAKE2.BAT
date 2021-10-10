@echo off
cls
if exist context2.exe del context2.exe
tasm32.exe /s  /m /ml /z context2.asm
tlink32.exe -x -c -Tpe -B:0x10000000 context2.obj,,,x:\tasm\win\import32.lib
del context2.obj
