@echo off
del %1.exe
tasm32.exe /m /ml /z %1.asm
tlink32.exe -x -c -Tpe %1.obj,,,x:\tasm\win\import32.lib
del %1.obj