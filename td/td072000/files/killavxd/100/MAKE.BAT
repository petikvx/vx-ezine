@echo off
tasm32.exe /ml /m /z example.asm
tlink32.exe -Tpe -c -x example.obj,,,import32.lib
del example.obj
