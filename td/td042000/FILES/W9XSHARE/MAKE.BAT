@echo off
tasm32.exe /m /ml /z example.asm
tlink32.exe -x -c -Tpe example.obj,,,import32.lib
