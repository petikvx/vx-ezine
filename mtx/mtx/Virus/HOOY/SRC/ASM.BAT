@echo off
cls
del 1.exe
tasm32.exe /m /ml /z 1.asm
tlink32.exe -x -c -Tpe -B:0x66600000 1.obj,,,import32.lib
del 1.obj
