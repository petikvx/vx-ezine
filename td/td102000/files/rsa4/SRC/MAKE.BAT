@echo off
if exist keygen2.exe del keygen2.exe
%TASM32%tasm32.exe /s  /m /ml /z keygen2.asm
%TASM32%tlink32.exe -x -c -Tpe -B:0x10000000 keygen2.obj,,,%TASM32%import32.lib
del keygen2.obj
move keygen2.exe ..
