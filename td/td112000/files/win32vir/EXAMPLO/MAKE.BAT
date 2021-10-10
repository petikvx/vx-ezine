@echo off
set tasm32=c:\tasm\
%TASM32%tasm32.exe /s /m /ml /z examplo.asm
%TASM32%tlink32.exe -x -c -Tpe examplo.obj,,,%TASM32%import32.lib
del examplo.obj
