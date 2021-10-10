@echo off
del example.exe
tasm32.exe /m /ml /z example.asm
tlink32.exe -x -c -Tpe example.obj,,,x:\tasm\win\import32.lib
del example.obj
